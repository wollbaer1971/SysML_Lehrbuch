package ROS2Mapping {

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
}
