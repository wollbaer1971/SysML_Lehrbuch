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

*Letzte Aktualisierung: Juni 2026*
