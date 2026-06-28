// ============================================================
// 03_structure.sysml
// AutonomousIndoorRobot – Systemstruktur (part def)
// SysML v2
// ============================================================

package Structure {

    doc
        /*
         * Strukturmodell des autonomen Indoor-Roboters.
         *
         * Leseanleitung
         * -------------
         * part def XYZ  = Typdefinition (Vorlage, wie eine Klasse)
         * part xyz : XYZ = Instanz (wie ein Objekt)
         *
         * Lesen Sie die Struktur top-down:
         *   Robot -> 6 Hauptsysteme -> Untersysteme -> Komponenten
         *
         * Ports und Verbindungen zwischen den Teilen stehen in
         * 05_interfaces.sysml.
         */

    // ==========================================================
    // Hauptsystem
    // ==========================================================

    part def Robot {
        doc
        /*
         * Gesamtsystem. Enthält alle funktionalen Subsysteme.
         * Verantwortlich für autonome Navigation, Wahrnehmung,
         * Energieversorgung, Sicherheit und Bedienung.
         */

        part perception  : PerceptionSystem;
        part navigation  : NavigationSystem;
        part motion      : MotionControl;
        part battery     : BatterySystem;
        part ui          : UserInterface;
        part safety      : SafetyLogic;
    }

    // ==========================================================
    // 1. Wahrnehmungssystem
    // ==========================================================

    part def PerceptionSystem {
        doc
        /*
         * Nimmt Sensordaten auf und verarbeitet sie zu:
         *   - Hindernisliste (statisch + dynamisch)
         *   - Personenerkennung (Bounding Boxes)
         *   - Lidar-Punktwolke für Navigation und SLAM
         * Verantwortlich für REQ-002-1, REQ-004-1, REQ-004-2.
         */

        part frontCamera  : Camera;
        part lidar        : Lidar;
        part detector     : PersonDetector;
        part obstacleMap  : ObstacleMapper;
    }

    part def Camera {
        doc
        /*
         * RGB-Kamera, Auflösung 640x480, 30 fps.
         * Sichtfeld: 62° horizontal.
         * Ausgabe: sensor_msgs/Image auf /camera/image_raw
         * Anforderung: REQ-004-2 (Personenerkennung bei 50-1000 lx)
         */

        attribute resolution  : String  = "640x480";
        attribute framerate   : Real    = 30.0;   // fps
        attribute fovH        : Real    = 62.0;   // Grad
        attribute topic       : String  = "/camera/image_raw";
    }

    part def Lidar {
        doc
        /*
         * 2D-Lidar, 270° Sichtfeld, 10 Hz.
         * Messbereich: 0,1 m – 12,0 m, Genauigkeit +/- 3 cm.
         * Ausgabe: sensor_msgs/LaserScan auf /scan
         * Anforderung: REQ-004-1
         */

        attribute range_min   : Real = 0.1;    // Meter
        attribute range_max   : Real = 12.0;   // Meter
        attribute accuracy    : Real = 0.03;   // Meter
        attribute fov         : Real = 270.0;  // Grad
        attribute rate        : Real = 10.0;   // Hz
        attribute topic       : String = "/scan";
    }

    part def PersonDetector {
        doc
        /*
         * ML-basierte Personenerkennung (YOLOv8-tiny oder MobileNet-SSD).
         * Eingabe: /camera/image_raw
         * Ausgabe: std_msgs/String (JSON-Liste erkannter Personen) auf /persons_detected
         * Anforderung: REQ-004-2, REQ-002-3
         */

        attribute modelName : String = "yolov8n";
        attribute topicIn   : String = "/camera/image_raw";
        attribute topicOut  : String = "/persons_detected";
    }

    part def ObstacleMapper {
        doc
        /*
         * Verarbeitet Lidar-Daten zu lokaler Hindernisdarstellung.
         * Ausgabe: nav_msgs/OccupancyGrid auf /local_costmap
         * Genutzt von: NavigationSystem
         */

        attribute topicIn  : String = "/scan";
        attribute topicOut : String = "/local_costmap";
    }

    // ==========================================================
    // 2. Navigationssystem
    // ==========================================================

    part def NavigationSystem {
        doc
        /*
         * Plant und überwacht den Fahrtweg zum Ziel.
         * Basiert auf Nav2 (ROS 2 Navigation Stack).
         * Verantwortlich für REQ-001 (Navigate) gesamt.
         */

        part planner    : PathPlanner;
        part controller : FollowController;
        part locator    : Localization;
    }

    part def PathPlanner {
        doc
        /*
         * Globale Pfadplanung auf der Gebäudekarte (A* oder NavFn).
         * Eingabe:  /map, /mission_goal
         * Ausgabe:  /planned_path (nav_msgs/Path)
         * Anforderung: REQ-001-1
         */

        attribute algorithm : String = "NavFn";
        attribute topicIn   : String = "/map, /mission_goal";
        attribute topicOut  : String = "/planned_path";
    }

    part def FollowController {
        doc
        /*
         * Lokale Pfadverfolgung. Sendet Fahrbefehle an Antrieb.
         * Eingabe:  /planned_path, /local_costmap, /amcl_pose
         * Ausgabe:  /cmd_vel (geometry_msgs/Twist)
         * Anforderung: REQ-001, REQ-002-2
         */

        attribute topicIn  : String = "/planned_path, /local_costmap, /amcl_pose";
        attribute topicOut : String = "/cmd_vel";
        attribute maxSpeed : Real   = 0.5;  // m/s
    }

    part def Localization {
        doc
        /*
         * AMCL-basierte Positionsschätzung (Adaptive Monte Carlo Localization).
         * Eingabe:  /scan, /map
         * Ausgabe:  /amcl_pose (geometry_msgs/PoseWithCovarianceStamped)
         * Anforderung: REQ-004-3
         */

        attribute method    : String = "AMCL";
        attribute accuracy  : Real   = 0.10;  // Meter
        attribute topicIn   : String = "/scan, /map";
        attribute topicOut  : String = "/amcl_pose";
    }

    // ==========================================================
    // 3. Antrieb
    // ==========================================================

    part def MotionControl {
        doc
        /*
         * Setzt Fahrbefehle (/cmd_vel) in Motoransteuerung um.
         * Differentialantrieb mit zwei Antriebsrädern.
         * Maximale Geschwindigkeit: 0,5 m/s (soft limit).
         */

        part leftMotor  : DriveMotor;
        part rightMotor : DriveMotor;
        part motorCtrl  : MotorController;
        part odometry   : OdometrySensor;
    }

    part def DriveMotor {
        doc
        /*
         * DC-Brushlessmotor mit Encoder (500 CPR).
         * Nennleistung: 30 W.
         */

        attribute power   : Real = 30.0;  // Watt
        attribute encoder : Real = 500.0; // Counts per Revolution
    }

    part def MotorController {
        doc
        /*
         * Wandelt /cmd_vel in PWM-Signale für beide Motoren um.
         * Eingabe:  /cmd_vel
         * Ausgabe:  PWM (intern, kein ROS Topic)
         */

        attribute topicIn : String = "/cmd_vel";
    }

    part def OdometrySensor {
        doc
        /*
         * Berechnet Odometrie aus Encoder-Daten.
         * Ausgabe: /odom (nav_msgs/Odometry) mit 50 Hz
         */

        attribute rate     : Real   = 50.0;  // Hz
        attribute topicOut : String = "/odom";
    }

    // ==========================================================
    // 4. Energiesystem
    // ==========================================================

    part def BatterySystem {
        doc
        /*
         * Überwacht Akkustand und verwaltet Energiezufuhr.
         * Verantwortlich für REQ-003 (Battery) gesamt.
         */

        part cell     : BatteryCell;
        part monitor  : BatteryMonitor;
        part charger  : ChargingInterface;
    }

    part def BatteryCell {
        doc
        /*
         * LiFePO4-Akkupack.
         * Kapazität: 20 Ah bei 24 V (480 Wh).
         * Betriebstemperatur: 0°C – 45°C.
         */

        attribute capacity   : Real = 20.0;  // Ah
        attribute voltage    : Real = 24.0;  // V
        attribute technology : String = "LiFePO4";
    }

    part def BatteryMonitor {
        doc
        /*
         * Liest Spannung und Strom des Akkus und berechnet Ladestand.
         * Ausgabe: sensor_msgs/BatteryState auf /battery_state (1 Hz)
         * Anforderung: REQ-003-1
         */

        attribute rate     : Real   = 1.0;  // Hz
        attribute topicOut : String = "/battery_state";
        attribute warnAt   : Real   = 30.0; // Prozent -> REQ-003-3
        attribute dockAt   : Real   = 20.0; // Prozent -> REQ-003-2
    }

    part def ChargingInterface {
        doc
        /*
         * Kontaktplatten für automatisches Andocken an Ladestation.
         * Detektiert Ladevorgang und meldet Ladestatus.
         * Ausgabe: std_msgs/Bool auf /charging_active
         */

        attribute topicOut : String = "/charging_active";
    }

    // ==========================================================
    // 5. Benutzerschnittstelle
    // ==========================================================

    part def UserInterface {
        doc
        /*
         * Eingabe: Missionsbefehle vom Operator (via Leitstation).
         * Ausgabe: Statusmeldungen und Warnungen.
         * Anforderung: REQ-005 gesamt.
         */

        part statusPublisher : StatusNode;
        part missionReceiver : MissionReceiver;
        part buzzer          : Buzzer;
    }

    part def StatusNode {
        doc
        /*
         * Publiziert Betriebszustand mit 1 Hz.
         * Zustände: 'idle', 'navigating', 'charging',
         *           'obstacle_stop', 'emergency_stop', 'error'
         * Topic: /robot_status (std_msgs/String)
         * Anforderung: REQ-005-1
         */

        attribute topicOut : String = "/robot_status";
        attribute rate     : Real   = 1.0;  // Hz
    }

    part def MissionReceiver {
        doc
        /*
         * Empfängt Missionsbefehle von der Leitstation.
         * Topic: /mission_goal (geometry_msgs/PoseStamped)
         * Leitet Ziel an NavigationSystem weiter.
         * Anforderung: REQ-005-2
         */

        attribute topicIn : String = "/mission_goal";
    }

    part def Buzzer {
        doc
        /*
         * Akustisches Warnsignal bei Personenannäherung < 1,0 m.
         * Steuerung: std_msgs/Bool auf /buzzer_cmd
         * Anforderung: REQ-002-3 (Warnsignal)
         */

        attribute topicIn : String = "/buzzer_cmd";
    }

    // ==========================================================
    // 6. Sicherheitslogik
    // ==========================================================

    part def SafetyLogic {
        doc
        /*
         * Überwacht alle sicherheitsrelevanten Signale.
         * Kann Fahrbefehl /cmd_vel überschreiben (Notfall-Override).
         * Verantwortlich für REQ-002 gesamt.
         */

        part watchdog  : SafetyWatchdog;
        part eStop     : EmergencyStopHandler;
    }

    part def SafetyWatchdog {
        doc
        /*
         * Überwacht Lidar-Distanzen und Personendetektor-Ausgabe.
         * Löst automatischen Stopp aus bei:
         *   - Hindernis < 0,2 m (REQ-002-2)
         *   - Person < 0,5 m   (REQ-002-3)
         * Ausgabe: /safety_cmd_vel (geometry_msgs/Twist) – Override
         */

        attribute topicIn   : String = "/scan, /persons_detected";
        attribute topicOut  : String = "/safety_cmd_vel";
        attribute stopDist  : Real   = 0.2;  // Meter
        attribute slowDist  : Real   = 0.5;  // Meter
    }

    part def EmergencyStopHandler {
        doc
        /*
         * Verarbeitet hardwareseitiges Nothaltsignal.
         * Setzt /cmd_vel auf 0 und sperrt Navigation.
         * Zustand wird über /robot_status gemeldet.
         * Anforderung: REQ-002-4
         */

        attribute topicOut : String = "/emergency_active";
        attribute stopTimeMs : Real = 500.0;  // Millisekunden
    }
}
