#!/usr/bin/env python3
"""
battery_monitor_node.py
AutonomousIndoorRobot – SysML: BatteryMonitor (in BatterySystem)

Verantwortlich für:
  REQ-003-1: Akkustand kontinuierlich mit 1 Hz überwachen
  REQ-003-2: Rückkehr zur Ladestation auslösen bei < 20 %
  REQ-003-3: Warnung publizieren bei < 30 %

Topics:
  Publisher:
    /battery_state      sensor_msgs/BatteryState   1 Hz
    /robot_status       std_msgs/String             (Statuswarnungen)
  Subscriber:
    /charging_active    std_msgs/Bool               (ob Ladestation angedockt)

ROS 2 Parameter:
  warn_threshold    (float, default 30.0)  -- Warnschwelle in Prozent
  dock_threshold    (float, default 20.0)  -- Rückfahrschwelle in Prozent
  publish_rate      (float, default 1.0)   -- Publishrate in Hz
"""

import rclpy
from rclpy.node import Node
from sensor_msgs.msg import BatteryState
from std_msgs.msg import String, Bool


class BatteryMonitorNode(Node):

    def __init__(self):
        super().__init__('battery_monitor_node')

        # Parameter deklarieren
        self.declare_parameter('warn_threshold', 30.0)
        self.declare_parameter('dock_threshold', 20.0)
        self.declare_parameter('publish_rate', 1.0)

        self.warn_threshold = self.get_parameter('warn_threshold').value
        self.dock_threshold = self.get_parameter('dock_threshold').value
        publish_rate        = self.get_parameter('publish_rate').value

        # Zustand
        self.percentage    = 100.0   # Startwert: voll
        self.is_charging   = False
        self.warned_low    = False   # Verhindert wiederholte Warnung
        self.dock_trigger  = False   # Verhindert wiederholten Dockauftrag

        # Publisher
        self.battery_pub = self.create_publisher(
            BatteryState, '/battery_state', 10)
        self.status_pub  = self.create_publisher(
            String, '/robot_status', 10)

        # Subscriber
        self.charging_sub = self.create_subscription(
            Bool, '/charging_active', self._on_charging, 10)

        # Timer
        period = 1.0 / publish_rate
        self.timer = self.create_timer(period, self._publish_battery)

        self.get_logger().info(
            f'BatteryMonitorNode gestartet. '
            f'Warnschwelle: {self.warn_threshold}%, '
            f'Andockschwelle: {self.dock_threshold}%'
        )

    # ------------------------------------------------------------------

    def _publish_battery(self):
        """Publiziert aktuellen Akkustand (REQ-003-1)."""

        # Simulation: Akku entlädt sich langsam (in realer HW: Sensorwert lesen)
        if not self.is_charging:
            self.percentage = max(0.0, self.percentage - 0.1)
        else:
            self.percentage = min(100.0, self.percentage + 2.0)
            if self.percentage >= 90.0:
                self.warned_low  = False
                self.dock_trigger = False

        # BatteryState-Nachricht aufbauen
        msg = BatteryState()
        msg.header.stamp    = self.get_clock().now().to_msg()
        msg.percentage      = float(self.percentage) / 100.0  # 0.0 – 1.0
        msg.voltage         = 24.0 * (0.7 + 0.3 * self.percentage / 100.0)
        msg.present         = True
        msg.power_supply_status = (
            BatteryState.POWER_SUPPLY_STATUS_CHARGING
            if self.is_charging
            else BatteryState.POWER_SUPPLY_STATUS_DISCHARGING
        )

        self.battery_pub.publish(msg)

        self.get_logger().debug(
            f'Akkustand: {self.percentage:.1f}%'
        )

        # Warnung bei < 30 % (REQ-003-3)
        if self.percentage < self.warn_threshold and not self.warned_low:
            self.warned_low = True
            self._publish_status('battery_low')
            self.get_logger().warn(
                f'Akkustand unter {self.warn_threshold}%: {self.percentage:.1f}%'
            )

        # Rückkehrauftrag bei < 20 % (REQ-003-2)
        if self.percentage < self.dock_threshold and not self.dock_trigger:
            self.dock_trigger = True
            self._publish_status('return_to_dock')
            self.get_logger().error(
                f'Akkustand unter {self.dock_threshold}%: Rückkehr zur Ladestation!'
            )

    def _on_charging(self, msg: Bool):
        """Reagiert auf Ladestation-Andocken."""
        self.is_charging = msg.data
        if self.is_charging:
            self.get_logger().info('Ladestation angedockt – Laden aktiv.')

    def _publish_status(self, status: str):
        """Hilfsfunktion zum Publizieren von Statusmeldungen."""
        msg = String()
        msg.data = status
        self.status_pub.publish(msg)


def main(args=None):
    rclpy.init(args=args)
    node = BatteryMonitorNode()
    try:
        rclpy.spin(node)
    except KeyboardInterrupt:
        pass
    finally:
        node.destroy_node()
        rclpy.shutdown()


if __name__ == '__main__':
    main()
