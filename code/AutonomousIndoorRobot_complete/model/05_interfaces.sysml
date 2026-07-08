package Interfaces {
  doc
  /* Ports, Verbindungen und Datenfluesse (Kapitel 9: Verbindungsmodellierung
     mit port und connection). Diese Datei uebernimmt die in 9.2-9.7
     abgedruckten Buch-Listings wortnah, verwendet dabei aber die in
     03_structure.sysml etablierten Instanznamen (frontCamera, lidar,
     detector; navigation, localization, mapProvider, pathPlanner,
     pathFollower), damit beide Dateien konsistent bleiben. Wie schon der
     bisherige Platzhalter anmerkte, druckt das Buch keine eigene,
     projektspezifische Musterloesung fuer 05_interfaces.sysml ab - die
     folgenden Elemente sind die generischen Kapitel-9-Beispiele, an die
     Projekt-Bezeichner angepasst. */

  // 9.2 Portdefinitionen
  port def ImagePort;
  port def ScanPort;
  port def ObjectListPort;

  // 9.3 Ports an den Sensor- und Verarbeitungsteilen. Ergaenzt die
  // gleichnamigen part def aus 03_structure.sysml (dort ohne Ports) um die
  // im Buch gezeigten Schnittstellen. Das Tilde-Zeichen ~ markiert einen
  // konjugierten Port, der empfaengt statt sendet.
  part def Camera {
    port imageOut : ImagePort;
  }

  part def Lidar {
    port scanOut : ScanPort;
  }

  part def ObjectDetector {
    port imageIn : ~ImagePort;
    port objectsOut : ObjectListPort;
  }

  doc
  /* Hinweis zu ObstacleDetector: Das Buch zeigt in 9.3/9.4 zusaetzlich eine
     eigene Komponente ObstacleDetector mit port scanIn : ~ScanPort, die
     Lidar-Scandaten separat von den Kameradaten des ObjectDetector
     verarbeitet. Das Strukturmodell dieses Projekts (03_structure.sysml)
     hat PerceptionSystem bewusst mit nur einer Verarbeitungsinstanz
     (detector : ObjectDetector) modelliert. Ein eigener ScanPort-Eingang
     an detector wird im Buch an keiner Stelle gezeigt und wird hier daher
     nicht erfunden. Die Anbindung von lidar an die Verarbeitung bleibt
     bewusst als offene Annahme dokumentiert (vgl. 9.7 "Annahmen
     dokumentieren"). */

  // 9.4 Verbindungen innerhalb des PerceptionSystem. Die Grundform lautet:
  // connection <Name> connect <Teil1>.<Port1> to <Teil2>.<Port2>;
  part def PerceptionSystem {
    part frontCamera : Camera;
    part lidar : Lidar;
    part detector : ObjectDetector;

    connection c1 connect frontCamera.imageOut
                      to detector.imageIn;
  }

  // 9.6 Verbindungsmodell fuer die Navigation
  part def Localization;
  part def MapProvider;
  part def PathPlanner;
  part def PathFollower;

  part def NavigationSystem {
    doc
    /* Voraussetzung: Eine initiale Karte ist vorhanden. Lokalisierung
       arbeitet relativ zum map-Frame (9.7 "Annahmen dokumentieren"). */

    part localization : Localization;
    part mapProvider : MapProvider;
    part pathPlanner : PathPlanner;
    part pathFollower : PathFollower;

    connection c1 connect localization.poseOut
                      to pathPlanner.poseIn;
    connection c2 connect mapProvider.mapOut
                      to pathPlanner.mapIn;
    connection c3 connect pathPlanner.pathOut
                      to pathFollower.pathIn;
  }

  doc
  /* c1 liefert die aktuelle Pose der Lokalisierung an den Pfadplaner, c2
     liefert die Karte an denselben Pfadplaner, c3 gibt den geplanten Pfad
     an die Bewegungssteuerung (pathFollower) weiter (vgl. Abbildung 9.2).

     Hinweis zu den verwendeten Ports: Das Buch verwendet in 9.6 die
     Portnamen poseOut/poseIn, mapOut/mapIn und pathOut/pathIn direkt in
     den connection-Anweisungen, druckt an dieser Stelle jedoch keine
     eigenen port def-Deklarationen (etwa PosePort, MapPort, PathPort) und
     auch keine Zuordnung dieser Ports zu Localization, MapProvider,
     PathPlanner oder PathFollower ab. Diese Datei uebernimmt die
     connection-Syntax daher wortnah aus dem Buch, ohne die fehlenden
     Port-Typen zu erfinden - das bleibt eine bewusste Luecke. */
}
