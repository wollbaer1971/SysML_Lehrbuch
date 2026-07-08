package ROS2Mapping {
  doc
  /* ROS2-Mapping (Kapitel 15 "Architektur von ROS2-Systemen", S. 108-112,
     und Kapitel 16 "Von SysML v2 zu ROS2", S. 113-120).

     Kapitel-4-Basisversion (unveraendert uebernommen): part def
     BatterySystem_ROS2 und NavigationSystem_ROS2 unten.

     Ergaenzung aus Kapitel 15: Abschnitt 15.2 (S. 108) nennt den
     vollstaendigen Node-Graphen des Projekts mit neun Nodes: camera_node,
     lidar_node, slam_node, navigation_node, object_detector_node,
     battery_monitor_node, motion_control_node, user_interface_node,
     robot_state_node. Abschnitt 15.3 / Abbildung 15.1 (S. 108f.) nennt
     dazu folgende Topic-Verbindungen:
       camera_node -> /camera/image_raw -> object_detector_node
       lidar_node -> /scan -> slam_node
       slam_node -> /map -> navigation_node
       navigation_node -> /cmd_vel -> motion_control_node
       battery_monitor_node -> /battery_state -> navigation_node
       object_detector_node -> /detected_objects -> navigation_node
       robot_state_node -> /robot/status -> user_interface_node

     Abschnitt 16.3 "Beispieltabelle" (S. 113-115) ordnet ausserdem
     folgende SysML-v2-Part-Definitions den ROS2-Nodes zu:
       ObjectDetector    -> object_detector_node (fuehrt ML-Inferenz aus)
       Camera            -> camera_node
       NavigationSystem  -> navigation_node
       BatterySystem     -> battery_monitor_node
       MotionControl     -> motion_control_node
       UserInterface     -> user_interface_node

     Fuer SafetyLogic (vgl. 03_structure.sysml) macht das Buch an keiner
     gelesenen Stelle (Kapitel 14-20) eine ROS2-Zuordnungsaussage (kein
     eigener Node, kein Topic). Es wird deshalb hier bewusst KEIN
     SafetyLogic_ROS2 ergaenzt, um keine Node-Zuordnung zu erfinden.

     slam_node und robot_state_node aus dem Node-Graphen (15.2/15.3)
     entsprechen keinem eigenen part def in 03_structure.sysml (dort gibt
     es keine "Slam"- oder "RobotState"-Komponente). Ihre Topics /map und
     /robot/status werden unten als dokumentierte Eingaenge anderer
     gemappter Nodes (navigation_node, user_interface_node) uebernommen;
     eigene part def_ROS2 fuer slam_node/robot_state_node werden aber
     nicht erfunden, weil kein zugehoeriges SysML-Systemelement existiert -
     das bleibt eine bewusste Luecke. */

  part def BatterySystem_ROS2 {
    doc /* ROS2-Umsetzung des BatterySystem.

        Node: battery_monitor_node
        Paket: autonomous_indoor_robot/battery_monitor

        Publizierte Topics:
          /battery_state (sensor_msgs/BatteryState) -- Akkustand, 1 Hz

        Abonnierte Topics:
          keine

        Verbindung zum Modell:
          BatterySystem.monitor -> battery_monitor_node
          REQ_MonitorBattery wird durch diesen Node erfuellt. */

    attribute rosNode : String = "battery_monitor_node";
    attribute topicOut : String = "/battery_state";
  }

  part def NavigationSystem_ROS2 {
    doc /* ROS2-Umsetzung des NavigationSystem.

        Nodes: nav2_stack (extern), path_planner_node
        Abonnierte Topics:
          /battery_state -- triggert Rueckkehr bei niedrigem Akku
          /scan (sensor_msgs/LaserScan) -- Lidardaten
          /map (nav_msgs/OccupancyGrid) -- Karte

        Publizierte Topics:
          /cmd_vel (geometry_msgs/Twist) -- Fahrbefehle
          /robot_status (std_msgs/String) -- Betriebszustand

        Verbindung zum Modell:
          REQ_Navigate und REQ_ReturnToDock werden durch diese Nodes erfuellt. */

    attribute rosNode : String = "nav2_stack";
    attribute topicIn : String = "/battery_state, /scan, /map";
    attribute topicOut : String = "/cmd_vel, /robot_status";
  }

  // Ergaenzung: PerceptionSystem_ROS2 (vgl. PerceptionSystem in
  // 03_structure.sysml, dort mit frontCamera : Camera, lidar : Lidar,
  // detector : ObjectDetector). Abschnitt 16.3 (S. 113) ordnet Camera dem
  // camera_node und ObjectDetector dem object_detector_node zu; Abschnitt
  // 15.2/15.3 (S. 108f.) nennt zusaetzlich lidar_node fuer den Lidar.
  part def PerceptionSystem_ROS2 {
    doc /* ROS2-Umsetzung des PerceptionSystem (frontCamera, lidar,
        detector aus 03_structure.sysml).

        Node: camera_node
        Aufgabe (14.3, S. 104): liest Kamerabilder.
        Publiziert: /camera/image_raw (15.3, S. 108).

        Node: lidar_node
        Aufgabe (14.3, S. 104): liest Laserscans.
        Publiziert: /scan (15.3, S. 108).
        Hinweis: /scan wird laut 15.3 von slam_node abonniert, das
        wiederum /map veroeffentlicht. slam_node ist im Strukturmodell
        dieses Projekts (03_structure.sysml) nicht als eigenes
        Systemteil enthalten (dort nur localization, mapProvider,
        pathPlanner, pathFollower unter NavigationSystem) - dieser Punkt
        bleibt eine bewusste, im Buch an dieser Stelle nicht aufgeloeste
        Luecke.

        Node: object_detector_node
        Aufgabe (16.3, S. 113): fuehrt ML-Inferenz aus; erkennt Objekte
        oder Personen (14.3, S. 104).
        Abonniert: /camera/image_raw (15.3, S. 108).
        Publiziert: /detected_objects (15.3, S. 108), abonniert von
        navigation_node; Abschnitt 18.3 (S. 126) nennt als Empfaenger
        alternativ auch user_interface_node ("-> navigation_node oder
        user_interface_node").

        Praxisbeispiel (16.6, S. 116): Im Buch wird REQ-004 "Personen
        erkennen" als durch die Part Definition ObjectDetector erfuellt
        beschrieben, umgesetzt durch object_detector_node, veroeffentlicht
        ueber /detected_objects und durch einen Testfall zur
        Personenerkennung geprueft. In diesem Projekt ist REQ-004 nicht
        als eigenes requirement-Element definiert (02_requirements.sysml
        kennt keine "Personen erkennen"-Anforderung); die Aussage wird
        daher hier nur als Kontext dokumentiert, nicht als verify-
        Beziehung modelliert. */

    attribute rosNodeCamera : String = "camera_node";
    attribute topicCameraOut : String = "/camera/image_raw";

    attribute rosNodeLidar : String = "lidar_node";
    attribute topicLidarOut : String = "/scan";

    attribute rosNodeDetector : String = "object_detector_node";
    attribute topicDetectorIn : String = "/camera/image_raw";
    attribute topicDetectorOut : String = "/detected_objects";
  }

  // Ergaenzung: MotionControl_ROS2 (vgl. MotionControl in
  // 03_structure.sysml). Abschnitt 16.3 (S. 113) ordnet MotionControl dem
  // motion_control_node zu; Abschnitt 15.3 (S. 108) nennt die
  // Eingangsverbindung navigation_node -> /cmd_vel -> motion_control_node.
  part def MotionControl_ROS2 {
    doc /* ROS2-Umsetzung von MotionControl.

        Node: motion_control_node
        Aufgabe (16.3, S. 113): setzt Geschwindigkeitsbefehle um.
        Abonniert: /cmd_vel (15.3, S. 108), veroeffentlicht von
        navigation_node.

        Das Buch nennt an den gelesenen Stellen keine von
        motion_control_node veroeffentlichten Topics; ein Ausgangstopic
        wird daher hier nicht erfunden. */

    attribute rosNode : String = "motion_control_node";
    attribute topicIn : String = "/cmd_vel";
  }

  // Ergaenzung: UserInterface_ROS2 (vgl. UserInterface in
  // 03_structure.sysml). Abschnitt 16.3 (S. 113) ordnet UserInterface dem
  // user_interface_node zu; Abschnitt 15.3 (S. 108) nennt die
  // Eingangsverbindung robot_state_node -> /robot/status ->
  // user_interface_node, Abschnitt 18.3 (S. 126) zusaetzlich
  // object_detector_node -> /detected_objects -> ... user_interface_node.
  part def UserInterface_ROS2 {
    doc /* ROS2-Umsetzung von UserInterface.

        Node: user_interface_node
        Aufgabe (16.3, S. 113): nimmt Auftraege entgegen.
        Abonniert: /robot/status (15.3, S. 108), veroeffentlicht von
        robot_state_node; und gemaess 18.3 (S. 126) optional
        /detected_objects.

        robot_state_node ist im Strukturmodell dieses Projekts
        (03_structure.sysml) nicht als eigenes Systemteil enthalten;
        seine Zuordnung zu einem part def_ROS2 wird daher hier nicht
        erfunden, das Topic /robot/status wird aber als dokumentierter
        Eingang von user_interface_node uebernommen, weil das Buch es an
        dieser Stelle so nennt. */

    attribute rosNode : String = "user_interface_node";
    attribute topicIn : String = "/robot/status, /detected_objects";
  }

  // Traceability-Kette gemaess Abschnitt 16.7 "Von Anforderungen bis
  // Code" und Abbildung 16.2 (S. 117f.): Das Buch zeigt dort woertlich
  // die folgende Kette (dort mit "REQ-006" bezeichnet, entspricht in
  // diesem Projekt REQ_ReturnToDock aus 02_requirements.sysml):
  //   REQ-006 Zur Ladestation zurueckkehren
  //   -> Action: Akkustand ueberwachen
  //   -> Part Definition: BatterySystem
  //   -> Node: battery_monitor_node
  //   -> Topic: /battery_state
  //   -> Node: navigation_node
  //   -> Action: NavigateToDock
  //   -> Test: TC-006 Rueckkehr bei niedrigem Akkustand
  // "Action: Akkustand ueberwachen" und "Action: NavigateToDock" sind im
  // Buch nur Prosa-/Diagrammbezeichnungen (vgl. den Hinweis zu action def
  // in 04_behavior.sysml, wo das Buch an keiner Stelle einen abgedruckten
  // action-def-Block zeigt); es werden hier daher keine SysML action def
  // erfunden, sondern die Kette wird - wie im Buch - als Kommentar
  // dokumentiert. Der Testfall TC-006 entspricht TC_BatteryLowReturn bzw.
  // test def TC_006 in 06_tests.sysml.
  //
  // Abschnitt 16.5 "Mapping von Schnittstellen" (S. 116) nennt zusaetzlich
  // fuer die Zielnavigation eine Action NavigateToPose (statt eines
  // einfachen Topics), ebenfalls nur als Bezeichnung ohne SysML-
  // Codebeispiel:
  //   Zielnavigation: Action NavigateToPose
}
