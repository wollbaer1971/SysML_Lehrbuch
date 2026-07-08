# Architekturentscheidungen – AutonomousIndoorRobot

Dieses Dokument hält die wichtigsten Designentscheidungen und ihre Begründungen fest.
Format: ADR (Architecture Decision Record), kurze Version.

---

## ADR-001: Ladestation als externes System

**Datum:** 2026-06  
**Status:** Akzeptiert

**Entscheidung:**  
Die Ladestation gehört nicht zum System-of-Interest (Robot), sondern ist ein externes System.

**Begründung:**  
Der Roboter ist verantwortlich für das autonome Anfahren der Ladestation, aber nicht für deren Betrieb. Die Ladestation kann ausgetauscht oder durch mehrere Stationen ersetzt werden, ohne das Systemmodell des Roboters zu ändern.

**Konsequenz:**  
ChargingStation erscheint als externer Akteur in 00_overview.sysml und 01_context.sysml. Die Schnittstelle ist in 05_interfaces.sysml (PowerSupplyInterface) beschrieben.

---

## ADR-002: Nav2 als Navigationsbasis

**Datum:** 2026-06  
**Status:** Akzeptiert

**Entscheidung:**  
Navigation basiert auf dem ROS 2 Nav2 Stack (extern, nicht selbst entwickelt).

**Begründung:**  
Nav2 ist produktionsreif, dokumentiert und für Differentialantriebe gut geeignet. Eigene Pfadplanung würde den Rahmen des Lehrprojekts überschreiten. Die SysML-Strukturelemente (PathPlanner, FollowController, Localization) bilden die Nav2-Nodes konzeptuell ab.

**Konsequenz:**  
nav2_bringup ist Pflichtabhängigkeit. Launch-Datei muss nav2 einbinden. Anpassungen erfolgen nur über Nav2-Parameter (YAML).

---

## ADR-003: AMCL für Lokalisierung

**Datum:** 2026-06  
**Status:** Akzeptiert

**Entscheidung:**  
Lokalisierung erfolgt mit AMCL (Adaptive Monte Carlo Localization) auf einer vorab erstellten 2D-Karte.

**Begründung:**  
AMCL ist stabil, ressourcensparsam und für strukturierte Innenräume ausreichend genau (Zielgenauigkeit: 10 cm). Alternatives SLAM zur Laufzeit (z.B. SLAM Toolbox) ist optional, aber nicht Standardbetrieb.

**Alternativen verworfen:**  
- SLAM Toolbox: Sinnvoll für unbekannte Umgebungen, aber höherer Rechenaufwand.
- Visual Odometry: Zu empfindlich auf Lichtveränderungen für den Lehrkontext.

---

## ADR-004: SafetyWatchdog als separater Node

**Datum:** 2026-06  
**Status:** Akzeptiert

**Entscheidung:**  
Sicherheitslogik (Notbremsung, Personenabstand) läuft in einem eigenem ROS 2 Node (safety_watchdog_node), der /cmd_vel überschreiben kann.

**Begründung:**  
Klare Trennung von Navigationslogik und Sicherheitslogik. Bei einem Fehler im Nav2-Controller bleibt die Sicherheitsfunktion unabhängig aktiv. Entspricht dem Trennungsprinzip (separation of concerns) in sicherheitskritischen Systemen.

**Konsequenz:**  
Motor-Controller muss /safety_cmd_vel höher priorisieren als /cmd_vel. Reihenfolge: safety > nav2_controller.

---

## ADR-005: YOLOv8n für Personenerkennung

**Datum:** 2026-06  
**Status:** Vorläufig

**Entscheidung:**  
Personenerkennung basiert auf YOLOv8n (nano) in ONNX-Format, ausgeführt auf CPU.

**Begründung:**  
YOLOv8n ist leichtgewichtig genug für Onboard-Ausführung auf Raspberry Pi 4 / Jetson Nano. Genauigkeit bei 640x480 ausreichend für den Nahbereich (< 5 m).

**Einschränkungen:**  
CPU-Inferenz: ca. 200 ms Latenz. Höhere Modelle (YOLOv8s/m) nur bei GPU-Beschleunigung.

**Überprüfungspunkt:**  
Wenn Falsch-Negativ-Rate > 5 % in Realtests: Wechsel auf YOLOv8s oder Kamerawechsel.

---

## ADR-006: LiFePO4-Akkutechnologie

**Datum:** 2026-06  
**Status:** Akzeptiert

**Entscheidung:**  
Akkupack: LiFePO4, 24 V / 20 Ah (480 Wh).

**Begründung:**  
LiFePO4 ist sicherer als LiPo (kein Thermisches Durchgehen), langlebiger (> 2000 Zyklen) und für Innenraumanwendungen geeignet. Ausreichend für 4+ Stunden Betrieb (Anforderung REQ-003-4).

**Berechnung:**  
Leistungsaufnahme gesamt: ca. 80–100 W (Antrieb + Rechner + Sensoren)  
Betriebszeit: 480 Wh / 100 W = 4,8 h (theoretisch, 20 % Reserve eingerechnet: 3,8 h Praxis)  
→ Anforderung mit 4 h grenzwertig erfüllt. Effizienzoptimierungen (Idle-Modus) notwendig.

---

## ADR-007: Textuelle SysML v2 Modellierung

**Datum:** 2026-06  
**Status:** Akzeptiert

**Entscheidung:**  
Das gesamte SysML-Modell wird textuell in .sysml-Dateien geschrieben (Syside Editor in VS Code).

**Begründung:**  
- Versionierbar in Git
- Direkte Verwendung als Lehrbuchbeispiel
- Plattformunabhängig, kostenlos
- Grafische Sichten können in Eclipse SysON erzeugt werden

**Konsequenz:**  
Keine proprietäre Werkzeugbindung. Modell ist ohne Lizenz les- und pflegbar.

---

## ADR-008: Systemgrenze explizit im doc-Block dokumentieren

**Datum:** 2026-07  
**Status:** Akzeptiert

**Entscheidung:**  
Ziel, Umfang und Systemgrenze werden explizit als doc-Kommentar in 00_overview.sysml festgehalten, bevor Anforderungen oder Part Definitions modelliert werden.

**Begründung:**  
Das Buch nennt das Unterlassen dieser Klärung als typischen Anfängerfehler ("Häufiger Anfängerfehler: Systemgrenze unklar lassen. Wenn Sie nicht entscheiden, ob die Ladestation 'im System' oder 'außen' ist, entstehen später Widersprüche in Anforderungen und Tests."). Die Systemgrenze-Entscheidung prägt alle späteren Anforderungen und Tests.

**Konsequenz:**  
00_overview.sysml enthält einen doc-Block mit Ziel/Umfang/Systemgrenze. Die konkrete Grenzziehung (ChargingStation extern, aber modellrelevant) ist bereits in ADR-001 festgehalten.

**(Quelle: Kapitel 4.5, 4.14.1)**

---

## ADR-009: Feste Namenskonventionen für Modell- und Codeartefakte

**Datum:** 2026-07  
**Status:** Akzeptiert

**Entscheidung:**  
Für alle Modell- und Codeartefakte gilt ein einheitliches Namensschema: Part Definitions in PascalCase (Robot, BatterySystem), Parts/Instanzen in camelCase (battery, navigation), Anforderungen mit Präfix REQ_ (REQ_DetectObstacles, REQ_ReturnToDock), Testfälle mit Präfix TC_ (TC_BatteryLowReturn), ROS2-Nodes und Topics in snake_case bzw. mit führendem Slash (battery_monitor_node, /battery_state).

**Begründung:**  
Das Buch warnt ausdrücklich davor, wechselnde Namen für dasselbe Element zu verwenden ("Wenn ein Element einmal BatterySystem heißt, sollte es nicht an anderer Stelle PowerModule genannt werden"). Konsistente Namen erhöhen Lesbarkeit und erleichtern die Traceability zwischen Requirement, Modellelement, Node und Test.

**Konsequenz:**  
Alle .sysml-Dateien und Python-Nodes im Projekt folgen diesem Schema; Abweichungen sind im Review zu begründen.

**(Quelle: Kapitel 4.12)**

---

## ADR-010: Physische, logische und Software-Systemteile bewusst trennen

**Datum:** 2026-07  
**Status:** Akzeptiert

**Entscheidung:**  
Bei der Dekomposition werden physische Bauteile (z.B. Camera, Lidar), logische Verantwortlichkeiten (z.B. "Hindernis erkennen") und Softwareteile (z.B. ObjectDetector) als unterschiedliche Sichtweisen bewusst getrennt und nicht vermischt.

**Begründung:**  
Das Buch nennt die unklare Vermischung dieser drei Sichtweisen als häufigen Anfängerfehler. Eine klare Trennung macht sichtbar, welche Elemente greifbare Hardware, welche Verantwortlichkeiten und welche späteren Implementierungseinheiten (Software) sind.

**Konsequenz:**  
In PerceptionSystem sind Camera und Lidar als physische parts modelliert, ObjectDetector und ObstacleDetector als softwarenahe parts – auch wenn sie strukturell auf derselben Ebene stehen.

**(Quelle: Kapitel 8.6)**

---

## ADR-011: Durchgängige Traceability-Ketten von Requirement bis Testfall

**Datum:** 2026-07  
**Status:** Akzeptiert

**Entscheidung:**  
Sicherheits- und wahrnehmungsrelevante Anforderungen werden über eine durchgängige Kette Requirement → Part Definition → ROS2-Node → Topic → Testfall nachverfolgt (Praxisbeispiel im Buch: REQ-004 "Personen erkennen" → Part Definition ObjectDetector → Node object_detector_node → Topic /detected_objects → Testfall zur Personenerkennung).

**Begründung:**  
Traceability zeigt, welche Implementierung eine Architekturentscheidung realisiert, und macht Lücken sichtbar, wenn ein Modellelement keinen Node oder Test besitzt.

**Konsequenz:**  
Für die Akkuüberwachung existiert die analoge Kette REQ_MonitorBattery/REQ_ReturnToDock → BatterySystem → battery_monitor_node → /battery_state → Testfall (vgl. die im Buch gezeigte REQ-006-Kette in Kapitel 16.7: BatterySystem → battery_monitor_node → /battery_state → navigation_node → TC-006).

**(Quelle: Kapitel 16.6, 16.7)**

---

## ADR-012: Kein Eins-zu-eins-Zwang zwischen Part Definition und ROS2-Node

**Datum:** 2026-07  
**Status:** Akzeptiert

**Entscheidung:**  
Nicht jede Part Definition wird zwingend auf genau einen ROS2-Node abgebildet. Das Mapping von Part Definitions auf Nodes (07_ros2_mapping.sysml) ist eine bewusste, zu begründende Architekturentscheidung und kein automatisches 1:1-Verfahren.

**Begründung:**  
Das Buch benennt den "Eins-zu-eins-Zwang" ausdrücklich als typischen Fehler. Im Projekt zeigt sich das z.B. am NavigationSystem, das über mehrere Nodes (nav2_stack, path_planner_node) statt über einen einzigen Node abgebildet wird.

**Konsequenz:**  
07_ros2_mapping.sysml muss bei Änderungen der ROS2-Architektur aktiv gepflegt werden, sonst verliert die Traceability ihren Wert; Topic-Namen und Nachrichtentypen werden im Mapping stets mit angegeben, nicht nur grob skizziert.

**(Quelle: Kapitel 16.8.1, 16.8.2, 16.8.3)**

---

*Letzte Aktualisierung: Juli 2026*
