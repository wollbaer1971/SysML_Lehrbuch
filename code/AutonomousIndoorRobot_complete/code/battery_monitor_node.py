#!/usr/bin/env python3
"""
battery_monitor_node.py

HERKUNFT DIESES CODES
======================
Fuer battery_monitor_node.py druckt das Lehrbuch keinen vollstaendigen
Code ab. Kapitel 17.13 "Uebungen" (Uebung 1) formuliert ausdruecklich nur
eine konzeptionelle Aufgabe, keine Musterloesung:

    "Implementieren Sie konzeptionell einen battery_monitor_node,
    der regelmaessig einen simulierten Akkustand veroeffentlicht."

Es existiert also keine woertliche Buchvorlage fuer diesen Node. Dieses
Skript trennt deshalb bewusst zwei Anteile:

1) Direkt aus dem einzigen vollstaendig abgedruckten Node-Beispiel im
   Buch, status_node.py (Kapitel 17.3), UEBERNOMMENER Stil:
   - Imports (rclpy, rclpy.node.Node)
   - Klassenaufbau als Subklasse von Node mit __init__() / super().__init__()
   - create_publisher(<MsgType>, <topic>, 10) und create_timer(1.0, callback)
   - schlichte main()-Funktion: rclpy.init() -> Node erzeugen -> rclpy.spin()
     -> destroy_node() -> rclpy.shutdown()
   - bewusst minimaler Code ohne Fehlerbehandlung/Parameter/Logging, vgl.
     Kapitel 17 "Hinweis": "Der Code ist bewusst minimal. In realen
     Projekten kommen Fehlerbehandlung, Parameter, Logging, ... hinzu."

2) EIGENE Umsetzung der Buch-Uebungsaufgabe (da keine Musterloesung
   existiert), abgeleitet aus Modell und Anforderungen des Buchprojekts:
   - Topic /battery_state mit Nachrichtentyp sensor_msgs/BatteryState und
     1 Hz Publish-Rate gemaess model/07_ros2_mapping.sysml
     (BatterySystem_ROS2: topicOut = "/battery_state", Kommentar "1 Hz").
   - REQ_MonitorBattery (model/02_requirements.sysml): der Akkustand muss
     kontinuierlich ueberwacht werden -> periodischer Timer statt
     Einzelmeldung.
   - REQ_ReturnToDock (model/02_requirements.sysml): Schwellwert 20 Prozent
     -> im Code als Konstante BATTERY_RETURN_THRESHOLD dokumentiert. Die
     eigentliche Rueckkehr zur Ladestation wird laut 07_ros2_mapping.sysml
     nicht von diesem Node, sondern vom NavigationSystem/nav2_stack
     ausgeloest, der /battery_state abonniert. battery_monitor_node meldet
     hier deshalb nur den Zustand und markiert ihn per Log-Hinweis, loest
     aber keine Navigation aus.
   - Simulierter, langsam sinkender Akkustand, wie in Kapitel 17.10
     vorgeschlagen: "Ein sinnvoller naechster Schritt ist ein simulierter
     Batterieknoten. Er veroeffentlicht regelmaessig einen Akkustand, der
     langsam sinkt."

Es wird bewusst KEIN zusaetzliches, im Buch/Modell nicht gedecktes Feature
ergaenzt (z.B. kein separates Warn-Topic, kein Parameter-Server, keine
eigene Ladelogik) - das ginge ueber den Umfang der Uebungsaufgabe und die
in 07_ros2_mapping.sysml dokumentierte Schnittstelle hinaus.
"""

import rclpy
from rclpy.node import Node
from sensor_msgs.msg import BatteryState

# REQ_ReturnToDock (02_requirements.sysml): Akkustand < 20 Prozent
# -> Roboter faehrt selbststaendig zur Ladestation. Dieser Node prueft den
# Schwellwert nur zu Informationszwecken (Log-Hinweis); die Rueckkehr
# selbst uebernimmt laut 07_ros2_mapping.sysml das NavigationSystem.
BATTERY_RETURN_THRESHOLD = 0.20


class BatteryMonitorNode(Node):
    def __init__(self):
        super().__init__('battery_monitor_node')
        self.publisher = self.create_publisher(BatteryState, '/battery_state', 10)
        self.timer = self.create_timer(1.0, self.publish_battery_state)

        # Eigene Simulation (keine Buchvorlage): Start bei 100 % Akkustand.
        # sensor_msgs/BatteryState.percentage ist auf den Bereich 0.0 - 1.0
        # normiert.
        self.percentage = 1.0

    def publish_battery_state(self):
        msg = BatteryState()
        msg.percentage = self.percentage
        msg.present = True
        msg.power_supply_status = BatteryState.POWER_SUPPLY_STATUS_DISCHARGING

        self.publisher.publish(msg)

        if self.percentage < BATTERY_RETURN_THRESHOLD:
            self.get_logger().info(
                'Akkustand unter 20 Prozent (REQ_ReturnToDock) - '
                'Rueckkehr zur Ladestation wird vom NavigationSystem erwartet.'
            )

        # Akkustand fuer die naechste Veroeffentlichung leicht absenken,
        # nicht unter 0 fallen lassen (einfache Simulation, kein Lade-
        # vorgang modelliert).
        self.percentage = max(0.0, self.percentage - 0.01)


def main():
    rclpy.init()
    node = BatteryMonitorNode()
    rclpy.spin(node)
    node.destroy_node()
    rclpy.shutdown()


if __name__ == '__main__':
    main()
