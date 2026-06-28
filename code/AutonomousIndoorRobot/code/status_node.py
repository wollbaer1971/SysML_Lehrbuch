#!/usr/bin/env python3
"""
status_node.py
AutonomousIndoorRobot – SysML: StatusNode (in UserInterface)

Verantwortlich für:
  REQ-005-1: Betriebszustand mit 1 Hz publizieren
  REQ-002-4: emergency_stop als Zustand anzeigen

Topics:
  Publisher:
    /robot_status       std_msgs/String    1 Hz
  Subscriber:
    /battery_state      sensor_msgs/BatteryState
    /emergency_active   std_msgs/Bool

Mögliche Zustände auf /robot_status:
  'idle'            -- Roboter wartet
  'navigating'      -- Aktive Navigation
  'obstacle_stop'   -- Hindernis im Weg, gestoppt
  'returning'       -- Rückkehr zur Ladestation
  'charging'        -- Lädt an Ladestation
  'emergency_stop'  -- Notstopp aktiv
  'battery_low'     -- Akkuwarnung (Zusatzinfo)
  'error'           -- Systemfehler

ROS 2 Parameter:
  publish_rate   (float, default 1.0)  -- Publishrate in Hz
"""

import rclpy
from rclpy.node import Node
from std_msgs.msg import String, Bool
from sensor_msgs.msg import BatteryState


class StatusNode(Node):

    def __init__(self):
        super().__init__('status_node')

        # Parameter
        self.declare_parameter('publish_rate', 1.0)
        publish_rate = self.get_parameter('publish_rate').value

        # Interner Zustand
        self.current_state    = 'idle'
        self.emergency_active = False
        self.battery_pct      = 100.0
        self.is_charging      = False

        # Publisher
        self.status_pub = self.create_publisher(
            String, '/robot_status', 10)

        # Subscriber
        self.battery_sub = self.create_subscription(
            BatteryState, '/battery_state', self._on_battery, 10)
        self.emergency_sub = self.create_subscription(
            Bool, '/emergency_active', self._on_emergency, 10)

        # Timer
        period = 1.0 / publish_rate
        self.timer = self.create_timer(period, self._publish_status)

        self.get_logger().info('StatusNode gestartet.')

    # ------------------------------------------------------------------

    def _publish_status(self):
        """Publiziert Betriebszustand mit konfigurierter Rate (REQ-005-1)."""

        state = self._compute_state()

        msg = String()
        msg.data = state
        self.status_pub.publish(msg)

        self.get_logger().debug(f'Status: {state}')

    def _compute_state(self) -> str:
        """Leitet den aktuellen Zustand aus den empfangenen Signalen ab."""
        if self.emergency_active:
            return 'emergency_stop'
        if self.is_charging:
            return 'charging'
        if self.current_state == 'returning':
            return 'returning'
        # Standardzustand – kann von Navigation überschrieben werden
        return self.current_state

    def _on_battery(self, msg: BatteryState):
        """Aktualisiert internen Akkuzustand."""
        self.battery_pct = msg.percentage * 100.0
        self.is_charging = (
            msg.power_supply_status == BatteryState.POWER_SUPPLY_STATUS_CHARGING
        )
        # Zustandswechsel durch Akkusignal
        if not self.emergency_active:
            if self.is_charging:
                self.current_state = 'charging'
            elif self.battery_pct < 20.0 and self.current_state not in ('returning', 'charging'):
                self.current_state = 'returning'

    def _on_emergency(self, msg: Bool):
        """Setzt Notstopp-Flag (REQ-002-4)."""
        prev = self.emergency_active
        self.emergency_active = msg.data
        if self.emergency_active and not prev:
            self.get_logger().error('NOTSTOPP aktiviert!')
        elif not self.emergency_active and prev:
            self.current_state = 'idle'
            self.get_logger().info('Notstopp quittiert – zurück zu idle.')

    def set_navigation_state(self, state: str):
        """
        Kann von Navigation-Nodes aufgerufen werden, um den Zustand zu setzen.
        Mögliche Werte: 'navigating', 'obstacle_stop', 'idle', 'error'
        """
        if not self.emergency_active:
            self.current_state = state


def main(args=None):
    rclpy.init(args=args)
    node = StatusNode()
    try:
        rclpy.spin(node)
    except KeyboardInterrupt:
        pass
    finally:
        node.destroy_node()
        rclpy.shutdown()


if __name__ == '__main__':
    main()
