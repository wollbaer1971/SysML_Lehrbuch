package Structure {
  doc
  /* HINWEIS: Kapitel 8 (Strukturmodellierung mit part def) zeigt in 8.3 ein
     eigenstaendiges, paralleles Lehrbeispiel "package RobotStructure" mit
     teils anderen Instanznamen (perceptionSystem, navigationSystem,
     motionControl, batterySystem, userInterface, safetyLogic) und einem
     zusaetzlichen Subsystem communicationSystem : CommunicationSystem, das
     in diesem Projektmodell nicht uebernommen wird. Die vorliegende Datei
     behaelt die hier etablierten Namen (perception, navigation, motion,
     battery, ui, safety, cell, monitor, charger, frontCamera, lidar,
     detector) bei und ergaenzt nur die Dekomposition der zuvor leeren
     part def anhand der in Kapitel 8 und 9 tatsaechlich abgedruckten
     Inhalte. */

  part def Robot {
    doc /* Das Gesamtsystem. Enthaelt alle funktionalen Subsysteme. */

    part perception : PerceptionSystem;
    part navigation : NavigationSystem;
    part motion : MotionControl;
    part battery : BatterySystem;
    part ui : UserInterface;
    part safety : SafetyLogic;
  }

  part def PerceptionSystem {
    doc /* Nimmt Sensordaten auf und verarbeitet sie zu
           Objektlisten und Hindernissignalen. */

    part frontCamera : Camera;
    part lidar : Lidar;
    part detector : ObjectDetector;
  }

  part def BatterySystem {
    doc /* Ueberwacht den Akkustand und meldet kritische Werte. */

    part cell : Battery;
    part monitor : BatteryMonitor;
    part charger : ChargingInterface;
  }

  part def NavigationSystem {
    doc /* Uebernimmt Lokalisierung, Kartennutzung, Pfadplanung und
           Pfadverfolgung (Kapitel 9.6). Voraussetzung: Eine initiale Karte
           ist vorhanden. Lokalisierung arbeitet relativ zum map-Frame
           (Kapitel 9.7).
           Hinweis: Abschnitt 8.5 nennt fuer dieses Teilsystem alternativ
           die Bezeichnung "mapping : Mapping" statt "mapProvider :
           MapProvider". Diese Datei verwendet durchgaengig mapProvider,
           damit die Namen zum Verbindungsmodell in 05_interfaces.sysml
           (Kapitel 9.6) passen. */

    part localization : Localization;
    part mapProvider : MapProvider;
    part pathPlanner : PathPlanner;
    part pathFollower : PathFollower;
  }

  part def MotionControl {
    doc /* Setzt geplante Pfade in Antriebsbefehle um. Abschnitt 8.7 nennt
           MotionControl als eines der Systemteile, die gemeinsam mit
           BatterySystem und NavigationSystem die Anforderung "bei
           niedrigem Akkustand zur Ladestation fahren" erfuellen. Eine
           weitere Dekomposition von MotionControl wird im Buch nicht
           gezeigt. */
  }

  part def UserInterface {
    doc /* Nutzerschnittstelle fuer Transportauftraege und Statusanzeige.
           Laut 8.7 moeglicherweise ebenfalls an der Erfuellung von REQ-006
           beteiligt. Eine Dekomposition dieses Systemteils wird im Buch
           nicht gezeigt. */
  }

  part def SafetyLogic {
    doc /* Sicherheitslogik des Roboters. Eine Dekomposition dieses
           Systemteils wird im Buch nicht gezeigt. */
  }

  part def Camera {
    doc /* Physischer Bildsensor (vgl. 8.6: "Camera ist eher physisch").
           Abschnitt 8.8 zeigt, dass Camera als part def wiederverwendbar
           ist und mehrfach instanziiert werden kann (Beispiel:
           frontCamera und rearCamera) - dieses Projekt nutzt bislang nur
           eine Instanz (frontCamera). Ports fuer Camera siehe
           05_interfaces.sysml (Kapitel 9.3). */
  }

  part def Lidar {
    doc /* Physischer Laserscanner. Ports siehe 05_interfaces.sysml
           (Kapitel 9.3). */
  }

  part def ObjectDetector {
    doc /* Softwarebezogene Objekterkennung (vgl. 8.6: "ObjectDetector ist
           eher softwarebezogen"). Ports siehe 05_interfaces.sysml
           (Kapitel 9.3). */
  }

  part def Localization;
  part def MapProvider;
  part def PathPlanner;
  part def PathFollower;

  part def Battery {
    doc /* Akkuzelle. Konkrete Attribute (z. B. Kapazitaet, Ladezustand)
           werden im Buch an dieser Stelle nicht beziffert und daher hier
           nicht erfunden. */
  }

  part def BatteryMonitor {
    doc /* Ueberwacht den Akkustand (vgl. 8.10: Akkuzelle, Ueberwachung
           und Ladeschnittstelle haben unterschiedliche
           Verantwortlichkeiten). Konkrete Attribute oder Schwellwerte
           nennt das Buch an dieser Stelle nicht. */
  }

  part def ChargingInterface {
    doc /* Ladeschnittstelle. Eine weitere Dekomposition wird im Buch
           nicht gezeigt. */
  }
}
