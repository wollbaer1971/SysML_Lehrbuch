// ============================================================
// 07_ros2_mapping.sysml
// AutonomousIndoorRobot – SysML v2 zu ROS 2 Mapping
// SysML v2
// ============================================================

package ROS2Mapping {

    doc
        /*
         * Mapping-Datei: SysML-Systemelemente <-> ROS 2 Implementierung
         *
         * Für jedes Subsystem aus 03_structure.sysml wird hier angegeben:
         *   - ROS 2 Node Name
         *   - ROS 2 Paket
         *   - Publizierte Topics (Publisher)
         *   - Abonnierte Topics (Subscriber)
         *   - Services und Actions (falls vorhanden)
         *   - Verknüpfte Anforderungen
         *
         * Mapping-Konvention:
         *   SysML part def  <->  ROS 2 Node
         *   SysML port      <->  ROS 2 Topic / Service / Action
         *   SysML attribute <->  ROS 2 Parameter
         *
         * Alle Nodes gehören zum Paket: autonomous_indoor_robot
         */

    // ==========================================================
    // 1. Wahrnehmung
    // ==========================================================

    part def PerceptionSystem_ROS2 {
        doc
        /*
         * SysML: PerceptionSystem
         *
         * Nodes:
         *   camera_node          -- Kameratreiber
         *   lidar_node           -- Lidartreiber
         *   person_detector_node -- ML-Personenerkennung
         *   obstacle_mapper_node -- Hinderniskarte
         *
         * Paket: autonomous_indoor_robot/perception
         */

        attribute camera_node    : String = "camera_node";
        attribute lidar_node     : String = "lidar_node";
        attribute detector_node  : String = "person_detector_node";
        attribute mapper_node    : String = "obstacle_mapper_node";
    }

    part def CameraNode_ROS2 {
        doc
        /*
         * SysML: Camera (in PerceptionSystem)
         * Node:  camera_node
         * Paket: autonomous_indoor_robot/perception
         *
         * Publisher:
         *   /camera/image_raw    sensor_msgs/Image           30 Hz
         *   /camera/camera_info  sensor_msgs/CameraInfo       1 Hz
         *
         * Parameter:
         *   frame_rate   = 30.0   (fps)
         *   resolution   = "640x480"
         *   device       = "/dev/video0"
         *
         * Verknüpfte Anforderung: REQ-004-2
         */

        attribute rosNode   : String = "camera_node";
        attribute topicOut1 : String = "/camera/image_raw";
        attribute topicOut2 : String = "/camera/camera_info";
        attribute paramRate : Real   = 30.0;
    }

    part def LidarNode_ROS2 {
        doc
        /*
         * SysML: Lidar (in PerceptionSystem)
         * Node:  lidar_node (z.B. rplidar_ros oder sick_scan2)
         * Paket: autonomous_indoor_robot/perception
         *
         * Publisher:
         *   /scan   sensor_msgs/LaserScan   10 Hz
         *
         * Parameter:
         *   serial_port     = "/dev/ttyUSB0"
         *   serial_baudrate = 115200
         *   frame_id        = "laser"
         *
         * Verknüpfte Anforderungen: REQ-004-1, REQ-002-1
         */

        attribute rosNode   : String = "lidar_node";
        attribute topicOut  : String = "/scan";
        attribute paramPort : String = "/dev/ttyUSB0";
        attribute paramRate : Real   = 10.0;
    }

    part def PersonDetectorNode_ROS2 {
        doc
        /*
         * SysML: PersonDetector (in PerceptionSystem)
         * Node:  person_detector_node
         * Paket: autonomous_indoor_robot/perception
         *
         * Subscriber:
         *   /camera/image_raw   sensor_msgs/Image
         *
         * Publisher:
         *   /persons_detected   std_msgs/String (JSON-Liste)  10 Hz
         *
         * Parameter:
         *   model_path    = "models/yolov8n.onnx"
         *   confidence    = 0.60
         *   device        = "cpu"
         *
         * Verknüpfte Anforderungen: REQ-004-2, REQ-002-3
         */

        attribute rosNode    : String = "person_detector_node";
        attribute topicIn    : String = "/camera/image_raw";
        attribute topicOut   : String = "/persons_detected";
        attribute paramConf  : Real   = 0.60;
    }

    // ==========================================================
    // 2. Navigation
    // ==========================================================

    part def NavigationSystem_ROS2 {
        doc
        /*
         * SysML: NavigationSystem
         *
         * Nodes (Nav2 Stack):
         *   nav2_planner        -- Globale Pfadplanung
         *   nav2_controller     -- Lokale Pfadverfolgung / Fahrbefehl
         *   nav2_amcl           -- AMCL-Lokalisierung
         *   map_server          -- Statische Karte laden
         *
         * Paket: nav2_bringup (externe Abhängigkeit)
         *
         * Verknüpfte Anforderungen: REQ-001 gesamt, REQ-004-3
         */

        attribute plannerNode    : String = "nav2_planner";
        attribute controllerNode : String = "nav2_controller";
        attribute amclNode       : String = "nav2_amcl";
        attribute mapServerNode  : String = "map_server";
    }

    part def PathPlannerNode_ROS2 {
        doc
        /*
         * SysML: PathPlanner
         * Node:  nav2_planner
         *
         * Subscriber:
         *   /map            nav_msgs/OccupancyGrid
         *   /goal_pose      geometry_msgs/PoseStamped
         *
         * Publisher:
         *   /planned_path   nav_msgs/Path
         *
         * Action Server:
         *   /compute_path_to_pose  (nav2_msgs/ComputePathToPose)
         *
         * Parameter:
         *   planner_plugin = "nav2_navfn_planner/NavfnPlanner"
         *
         * Verknüpfte Anforderung: REQ-001-1
         */

        attribute rosNode   : String = "nav2_planner";
        attribute topicIn1  : String = "/map";
        attribute topicIn2  : String = "/goal_pose";
        attribute topicOut  : String = "/planned_path";
        attribute actionSrv : String = "/compute_path_to_pose";
    }

    part def FollowControllerNode_ROS2 {
        doc
        /*
         * SysML: FollowController
         * Node:  nav2_controller
         *
         * Subscriber:
         *   /planned_path   nav_msgs/Path
         *   /local_costmap  nav_msgs/OccupancyGrid
         *   /amcl_pose      geometry_msgs/PoseWithCovarianceStamped
         *
         * Publisher:
         *   /cmd_vel        geometry_msgs/Twist   10 Hz
         *
         * Action Server:
         *   /follow_path    (nav2_msgs/FollowPath)
         *
         * Parameter:
         *   max_vel_x     = 0.5
         *   min_vel_x     = 0.0
         *   max_speed_xy  = 0.5
         *
         * Verknüpfte Anforderungen: REQ-001, REQ-002-2
         */

        attribute rosNode   : String = "nav2_controller";
        attribute topicOut  : String = "/cmd_vel";
        attribute paramVmax : Real   = 0.5;
    }

    // ==========================================================
    // 3. Energiemanagement
    // ==========================================================

    part def BatteryMonitorNode_ROS2 {
        doc
        /*
         * SysML: BatteryMonitor (in BatterySystem)
         * Node:  battery_monitor_node
         * Paket: autonomous_indoor_robot/battery_monitor
         * Datei: code/battery_monitor_node.py
         *
         * Publisher:
         *   /battery_state  sensor_msgs/BatteryState  1 Hz
         *
         * Parameter:
         *   warn_threshold  = 30.0   (Prozent)
         *   dock_threshold  = 20.0   (Prozent)
         *   publish_rate    = 1.0    (Hz)
         *
         * Verknüpfte Anforderungen: REQ-003-1, REQ-003-2, REQ-003-3
         */

        attribute rosNode      : String = "battery_monitor_node";
        attribute topicOut     : String = "/battery_state";
        attribute paramWarn    : Real   = 30.0;
        attribute paramDock    : Real   = 20.0;
        attribute paramRate    : Real   = 1.0;
    }

    // ==========================================================
    // 4. Statusverwaltung & Bedienung
    // ==========================================================

    part def StatusNode_ROS2 {
        doc
        /*
         * SysML: StatusNode (in UserInterface)
         * Node:  status_node
         * Paket: autonomous_indoor_robot/status
         * Datei: code/status_node.py
         *
         * Subscriber:
         *   /battery_state    sensor_msgs/BatteryState
         *   /emergency_active std_msgs/Bool
         *
         * Publisher:
         *   /robot_status  std_msgs/String  1 Hz
         *
         * Parameter:
         *   publish_rate = 1.0   (Hz)
         *
         * Verknüpfte Anforderungen: REQ-005-1
         */

        attribute rosNode   : String = "status_node";
        attribute topicIn1  : String = "/battery_state";
        attribute topicIn2  : String = "/emergency_active";
        attribute topicOut  : String = "/robot_status";
        attribute paramRate : Real   = 1.0;
    }

    part def MissionReceiverNode_ROS2 {
        doc
        /*
         * SysML: MissionReceiver (in UserInterface)
         * Node:  mission_receiver_node
         * Paket: autonomous_indoor_robot/mission
         *
         * Subscriber:
         *   /mission_goal  geometry_msgs/PoseStamped
         *
         * Publisher:
         *   /goal_pose     geometry_msgs/PoseStamped  (weiter an Nav2)
         *
         * Verknüpfte Anforderung: REQ-005-2
         */

        attribute rosNode  : String = "mission_receiver_node";
        attribute topicIn  : String = "/mission_goal";
        attribute topicOut : String = "/goal_pose";
    }

    // ==========================================================
    // 5. Sicherheitslogik
    // ==========================================================

    part def SafetyWatchdogNode_ROS2 {
        doc
        /*
         * SysML: SafetyWatchdog (in SafetyLogic)
         * Node:  safety_watchdog_node
         * Paket: autonomous_indoor_robot/safety
         *
         * Subscriber:
         *   /scan              sensor_msgs/LaserScan
         *   /persons_detected  std_msgs/String
         *
         * Publisher:
         *   /safety_cmd_vel   geometry_msgs/Twist  (Override)
         *   /buzzer_cmd       std_msgs/Bool
         *
         * Parameter:
         *   stop_distance = 0.20   (Meter)
         *   slow_distance = 0.50   (Meter)
         *   person_slow_distance = 1.00  (Meter)
         *   slow_speed    = 0.20   (m/s)
         *
         * Verknüpfte Anforderungen: REQ-002-2, REQ-002-3
         */

        attribute rosNode      : String = "safety_watchdog_node";
        attribute topicIn1     : String = "/scan";
        attribute topicIn2     : String = "/persons_detected";
        attribute topicOut1    : String = "/safety_cmd_vel";
        attribute topicOut2    : String = "/buzzer_cmd";
        attribute paramStop    : Real   = 0.20;
        attribute paramSlow    : Real   = 0.50;
        attribute paramSlowSpd : Real   = 0.20;
    }

    // ==========================================================
    // Topic-Übersichtstabelle (Kommentar)
    // ==========================================================

    part def TopicRegistry {
        doc
        /*
         * Alle Topics im Überblick
         * ========================
         * Topic                  | Typ                                   | Hz  | Sender                   | Empfänger
         * -----------------------|---------------------------------------|-----|--------------------------|---------------------------
         * /camera/image_raw      | sensor_msgs/Image                     |  30 | camera_node              | person_detector_node
         * /scan                  | sensor_msgs/LaserScan                 |  10 | lidar_node               | obstacle_mapper_node, nav2_amcl, safety_watchdog_node
         * /persons_detected      | std_msgs/String (JSON)                |  10 | person_detector_node     | safety_watchdog_node
         * /local_costmap         | nav_msgs/OccupancyGrid                |   5 | nav2_costmap             | nav2_controller
         * /map                   | nav_msgs/OccupancyGrid                |   - | map_server               | nav2_planner, nav2_amcl
         * /amcl_pose             | geometry_msgs/PoseWithCovarianceStamped| 10 | nav2_amcl               | nav2_controller
         * /odom                  | nav_msgs/Odometry                     |  50 | odometry (hardware)      | nav2_amcl
         * /planned_path          | nav_msgs/Path                         |   1 | nav2_planner             | nav2_controller
         * /cmd_vel               | geometry_msgs/Twist                   |  10 | nav2_controller          | motor_controller (hardware)
         * /safety_cmd_vel        | geometry_msgs/Twist                   |  10 | safety_watchdog_node     | motor_controller (Override)
         * /battery_state         | sensor_msgs/BatteryState              |   1 | battery_monitor_node     | status_node, safety_watchdog_node
         * /robot_status          | std_msgs/String                       |   1 | status_node              | ControlStation (extern, WLAN)
         * /mission_goal          | geometry_msgs/PoseStamped             |   - | ControlStation (extern)  | mission_receiver_node
         * /goal_pose             | geometry_msgs/PoseStamped             |   - | mission_receiver_node    | nav2_planner
         * /emergency_active      | std_msgs/Bool                         |   - | emergency_handler        | status_node, nav2_controller
         * /buzzer_cmd            | std_msgs/Bool                         |  10 | safety_watchdog_node     | buzzer (hardware)
         * /charging_active       | std_msgs/Bool                         |   1 | charging_interface (hw)  | battery_monitor_node
         */
    }
}
