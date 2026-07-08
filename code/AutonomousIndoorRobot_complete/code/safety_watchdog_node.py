#!/usr/bin/env python3
"""
safety_watchdog_node.py
AutonomousIndoorRobot – SysML: SafetyWatchdog (in SafetyLogic)

HINWEIS ZUR HERKUNFT: Diese Datei kommt im Lehrbuchtext an keiner
Stelle vor (weder als Dateiname noch als Konzept). Sie ist eine
Erweiterung ohne Buchbezug, keine Musterloesung aus dem Text.

Verantwortlich für:
  REQ-002-2: Vollstopp bei Hindernis < 0,2 m; Bremsen < 0,5 m
  REQ-002-3: Geschwindigkeitsreduktion bei Person im Nahbereich

Topics:
  Subscriber:
    /scan               sensor_msgs/LaserScan
    /persons_detected   std_msgs/String (JSON)
  Publisher:
    /safety_cmd_vel     geometry_msgs/Twist   (Override bei Gefahr)
    /buzzer_cmd         std_msgs/Bool

ROS 2 Parameter:
  stop_distance        (float, default 0.20)  -- Vollstopp-Schwelle in Metern
  slow_distance        (float, default 0.50)  -- Bremschwelle in Metern
  person_slow_distance (float, default 1.00)  -- Personennahbereich in Metern
  slow_speed           (float, default 0.20)  -- Max-Geschwindigkeit im Personenmodus
"""

import json
import math

import rclpy
from rclpy.node import Node
from sensor_msgs.msg import LaserScan
from geometry_msgs.msg import Twist
from std_msgs.msg import String, Bool


class SafetyWatchdogNode(Node):

    SAFE  = 'safe'
    SLOW  = 'slow'
    STOP  = 'stop'
    PERSON = 'person'

    def __init__(self):
        super().__init__('safety_watchdog_node')

        # Parameter
        self.declare_parameter('stop_distance',        0.20)
        self.declare_parameter('slow_distance',        0.50)
        self.declare_parameter('person_slow_distance', 1.00)
        self.declare_parameter('slow_speed',           0.20)

        self.stop_dist     = self.get_parameter('stop_distance').value
        self.slow_dist     = self.get_parameter('slow_distance').value
        self.person_dist   = self.get_parameter('person_slow_distance').value
        self.slow_speed    = self.get_parameter('slow_speed').value

        # Zustand
        self.safety_state     = self.SAFE
        self.person_detected  = False
        self.min_obstacle_dist = float('inf')

        # Publisher
        self.cmd_vel_pub  = self.create_publisher(Twist, '/safety_cmd_vel', 10)
        self.buzzer_pub   = self.create_publisher(Bool, '/buzzer_cmd', 10)

        # Subscriber
        self.scan_sub    = self.create_subscription(
            LaserScan, '/scan', self._on_scan, 10)
        self.person_sub  = self.create_subscription(
            String, '/persons_detected', self._on_persons, 10)

        self.get_logger().info(
            f'SafetyWatchdog gestartet. '
            f'Stop: {self.stop_dist} m, Slow: {self.slow_dist} m, '
            f'Person: {self.person_dist} m'
        )

    # ------------------------------------------------------------------

    def _on_scan(self, msg: LaserScan):
        """Wertet Lidar-Scan aus und reagiert auf Hindernisse (REQ-002-2)."""

        # Minimale Distanz aus allen gültigen Messwerten
        valid_ranges = [
            r for r in msg.ranges
            if not math.isnan(r) and not math.isinf(r)
            and msg.range_min <= r <= msg.range_max
        ]

        if not valid_ranges:
            return

        self.min_obstacle_dist = min(valid_ranges)

        new_state = self._evaluate_state()

        if new_state != self.safety_state:
            self.safety_state = new_state
            self.get_logger().info(
                f'Sicherheitszustand: {new_state} '
                f'(min. Abstand: {self.min_obstacle_dist:.2f} m)'
            )

        self._apply_safety_action()

    def _on_persons(self, msg: String):
        """Wertet Personendetektion aus (REQ-002-3)."""
        try:
            persons = json.loads(msg.data)
            self.person_detected = len(persons) > 0
        except (json.JSONDecodeError, TypeError):
            self.person_detected = msg.data.strip() != '[]' and msg.data.strip() != ''

        # Summe: Aktuellen Zustand neu berechnen
        new_state = self._evaluate_state()
        if new_state != self.safety_state:
            self.safety_state = new_state
            self._apply_safety_action()

    def _evaluate_state(self) -> str:
        """Bestimmt Sicherheitszustand aus Distanz und Personenerkennung."""
        if self.min_obstacle_dist < self.stop_dist:
            return self.STOP
        if self.person_detected:
            return self.PERSON
        if self.min_obstacle_dist < self.slow_dist:
            return self.SLOW
        return self.SAFE

    def _apply_safety_action(self):
        """Publiziert Override-Fahrbefehl und Buzzer je nach Zustand."""
        cmd = Twist()
        buzzer = Bool()

        if self.safety_state == self.STOP:
            # Vollstopp (REQ-002-2)
            cmd.linear.x  = 0.0
            cmd.angular.z = 0.0
            buzzer.data = True

        elif self.safety_state == self.PERSON:
            # Geschwindigkeit reduzieren (REQ-002-3)
            cmd.linear.x  = self.slow_speed
            cmd.angular.z = 0.0
            buzzer.data = True

        elif self.safety_state == self.SLOW:
            # Bremsen, noch fahren
            cmd.linear.x  = self.slow_speed
            cmd.angular.z = 0.0
            buzzer.data = False

        else:
            # Sicher – kein Override nötig
            # Trotzdem publizieren, damit Motorcontroller weiß, dass Override passiv
            cmd.linear.x  = -1.0   # Konvention: -1 = kein Override aktiv
            cmd.angular.z = 0.0
            buzzer.data = False

        self.cmd_vel_pub.publish(cmd)
        self.buzzer_pub.publish(buzzer)


def main(args=None):
    rclpy.init(args=args)
    node = SafetyWatchdogNode()
    try:
        rclpy.spin(node)
    except KeyboardInterrupt:
        pass
    finally:
        node.destroy_node()
        rclpy.shutdown()


if __name__ == '__main__':
    main()
