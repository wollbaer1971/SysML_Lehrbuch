// ============================================================
// 05_interfaces.sysml
// AutonomousIndoorRobot – Ports, Verbindungen und Schnittstellen
// SysML v2
// ============================================================

package Interfaces {

    doc
        /*
         * Schnittstellenmodell des autonomen Indoor-Roboters.
         *
         * Inhalt:
         *   1. Datentypen (attribute def)
         *   2. Port-Definitionen (port def)
         *   3. Interface-Definitionen (interface def)
         *   4. Verbindungsmodell zwischen Subsystemen (connection)
         *
         * Jede Schnittstelle ist definiert durch:
         *   - Sender und Empfänger
         *   - Datenformat (ROS 2 Message Type)
         *   - Topic-Name
         *   - Frequenz
         */

    // ==========================================================
    // Port-Definitionen
    // ==========================================================

    port def CameraImagePort {
        doc /* Kamerabild-Ausgabe der Camera zu PersonDetector. */
        attribute topic   : String = "/camera/image_raw";
        attribute type    : String = "sensor_msgs/Image";
        attribute rate    : Real   = 30.0;  // Hz
    }

    port def ScanPort {
        doc /* Lidar-Scan-Ausgabe zu ObstacleMapper und Localization. */
        attribute topic : String = "/scan";
        attribute type  : String = "sensor_msgs/LaserScan";
        attribute rate  : Real   = 10.0;  // Hz
    }

    port def CmdVelPort {
        doc /* Fahrbefehl vom FollowController zum MotorController.
               Überschrieben durch SafetyWatchdog im Sicherheitsfall. */
        attribute topic : String = "/cmd_vel";
        attribute type  : String = "geometry_msgs/Twist";
        attribute rate  : Real   = 10.0;  // Hz
    }

    port def BatteryStatePort {
        doc /* Akkustatus vom BatteryMonitor zu SafetyLogic und UserInterface. */
        attribute topic : String = "/battery_state";
        attribute type  : String = "sensor_msgs/BatteryState";
        attribute rate  : Real   = 1.0;  // Hz
    }

    port def RobotStatusPort {
        doc /* Betriebszustand von StatusNode zur Leitstation. */
        attribute topic : String = "/robot_status";
        attribute type  : String = "std_msgs/String";
        attribute rate  : Real   = 1.0;  // Hz
    }

    port def MissionGoalPort {
        doc /* Missionsziel von der Leitstation zum MissionReceiver. */
        attribute topic : String = "/mission_goal";
        attribute type  : String = "geometry_msgs/PoseStamped";
    }

    port def PersonsDetectedPort {
        doc /* Ergebnis der Personenerkennung zu SafetyWatchdog. */
        attribute topic : String = "/persons_detected";
        attribute type  : String = "std_msgs/String";   // JSON
        attribute rate  : Real   = 10.0;  // Hz
    }

    port def LocalCostmapPort {
        doc /* Lokale Hinderniskarte von ObstacleMapper zu FollowController. */
        attribute topic : String = "/local_costmap";
        attribute type  : String = "nav_msgs/OccupancyGrid";
        attribute rate  : Real   = 5.0;  // Hz
    }

    port def AmclPosePort {
        doc /* Geschätzte Roboterposition von Localization zu FollowController. */
        attribute topic : String = "/amcl_pose";
        attribute type  : String = "geometry_msgs/PoseWithCovarianceStamped";
        attribute rate  : Real   = 10.0;  // Hz
    }

    port def OdomPort {
        doc /* Odometrie von OdometrySensor zu Localization. */
        attribute topic : String = "/odom";
        attribute type  : String = "nav_msgs/Odometry";
        attribute rate  : Real   = 50.0;  // Hz
    }

    port def MapPort {
        doc /* Gebäudekarte von externem Kartenanbieter zu PathPlanner und Localization. */
        attribute topic : String = "/map";
        attribute type  : String = "nav_msgs/OccupancyGrid";
    }

    port def SafetyCmdVelPort {
        doc /* Override-Fahrbefehl vom SafetyWatchdog bei Notfall. */
        attribute topic : String = "/safety_cmd_vel";
        attribute type  : String = "geometry_msgs/Twist";
    }

    port def EmergencyPort {
        doc /* Nothaltsignal (Hardware-Button oder Software-Befehl). */
        attribute topic : String = "/emergency_active";
        attribute type  : String = "std_msgs/Bool";
    }

    port def PowerSupplyPort {
        doc /* Physische Ladeverbindung zwischen Roboter und Ladestation. */
        attribute voltage  : Real = 29.4;  // Volt (Ladespannung)
        attribute maxAmps  : Real = 10.0;  // Ampere
    }

    // ==========================================================
    // Interface-Definitionen (externe Systemgrenzen)
    // ==========================================================

    interface def PowerSupplyInterface {
        doc
        /*
         * Schnittstelle zwischen ChargingInterface (Robot) und ChargingStation.
         * Physisch: Federkontaktplatten, 24V/10A.
         * Andocktoleranz: +/- 3 cm lateral, +/- 2° Winkel.
         */
        end robotSide     : ~PowerSupplyPort;
        end stationSide   : PowerSupplyPort;
    }

    interface def WLANInterface {
        doc
        /*
         * WLAN-Schnittstelle zwischen Roboter und Leitstation.
         * Standard: IEEE 802.11n, 2,4 GHz.
         * Protokoll: ROS 2 DDS over UDP.
         * Latenz: < 50 ms (Anforderung für Statusmeldungen).
         * Topics über diese Schnittstelle:
         *   /robot_status   (Roboter -> Leitstation)
         *   /mission_goal   (Leitstation -> Roboter)
         */
    }

    interface def EnvironmentSensingInterface {
        doc
        /*
         * Logische Schnittstelle zwischen Sensoren und physischer Umgebung.
         * Lidar: optisches Rückstreusignal von Oberflächen
         * Kamera: einfallendes Licht aus der Umgebung
         * Einschränkungen:
         *   - Glas und stark reflektierende Flächen können Fehlmessungen erzeugen
         *   - Kameraleistung bei < 50 lx eingeschränkt
         */
    }

    interface def MotionInterface {
        doc
        /*
         * Schnittstelle zwischen Antrieb und physischer Umgebung.
         * Antriebsräder setzen /cmd_vel in Bodenbewegung um.
         * Haftreibungskoeffizient: > 0,4 (trockene Innenbodenfläche).
         * Maximale Steigung: 5° (Rampen in Innenräumen).
         */
    }

    // ==========================================================
    // Verbindungsmodell: Datenflüsse zwischen Subsystemen
    // ==========================================================

    connection def InternalDataFlow {
        doc
        /*
         * Vollständige Darstellung aller internen Datenflüsse.
         * Jede connection verbindet einen Sender-Port mit einem Empfänger-Port.
         *
         * Schnittstellentabelle:
         * -----------------------------------------------------------------------
         * Sender           | Empfänger             | Topic               | Hz
         * -----------------------------------------------------------------------
         * Camera           | PersonDetector        | /camera/image_raw   | 30
         * Lidar            | ObstacleMapper        | /scan               | 10
         * Lidar            | Localization          | /scan               | 10
         * OdometrySensor   | Localization          | /odom               | 50
         * ObstacleMapper   | FollowController      | /local_costmap      |  5
         * Localization     | FollowController      | /amcl_pose          | 10
         * PathPlanner      | FollowController      | /planned_path       |  1
         * FollowController | MotorController       | /cmd_vel            | 10
         * SafetyWatchdog   | MotorController       | /safety_cmd_vel     | 10
         * PersonDetector   | SafetyWatchdog        | /persons_detected   | 10
         * BatteryMonitor   | StatusNode            | /battery_state      |  1
         * BatteryMonitor   | SafetyLogic           | /battery_state      |  1
         * StatusNode       | ControlStation (ext.) | /robot_status       |  1
         * MissionReceiver  | PathPlanner           | /mission_goal       | -
         * ControlStation   | MissionReceiver (ext.)| /mission_goal       | -
         * -----------------------------------------------------------------------
         */
    }

    // Datenflüsse textuell (ausgewählte Schlüsselverbindungen)

    connection camToDetector {
        doc /* Kamerabild -> Personendetektor */
        end source : ~CameraImagePort;   // Camera.frontCamera
        end target : CameraImagePort;    // PersonDetector.detector
    }

    connection lidarToMapper {
        doc /* Lidar-Scan -> Hinderniskarte */
        end source : ~ScanPort;
        end target : ScanPort;
    }

    connection mapperToController {
        doc /* Lokale Hinderniskarte -> Pfadverfolger */
        end source : ~LocalCostmapPort;
        end target : LocalCostmapPort;
    }

    connection controllerToMotor {
        doc /* Fahrbefehl -> Motorsteuerung */
        end source : ~CmdVelPort;
        end target : CmdVelPort;
    }

    connection safetyOverride {
        doc /* Sicherheits-Override -> Motorsteuerung (Priorität über /cmd_vel) */
        end source : ~SafetyCmdVelPort;
        end target : SafetyCmdVelPort;
    }

    connection batteryToStatus {
        doc /* Akkuzustand -> Statusmeldung */
        end source : ~BatteryStatePort;
        end target : BatteryStatePort;
    }
}
