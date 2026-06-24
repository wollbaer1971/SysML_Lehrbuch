package RobotStructure {
    part def Robot {
        part perceptionSystem : PerceptionSystem;
        part navigationSystem : NavigationSystem;
        part batterySystem : BatterySystem;
        part motionControl : MotionControl;
    } // part def Robot

    part def PerceptionSystem {
        port sensorData : ~SensorDataPort;
        part camera : Camera;
        part lidar : Lidar;
        part detector : ObjectDetector;
    } // part def PerceptionSystem

    part def NavigationSystem;
    part def BatterySystem;
    part def MotionControl;
} // package RobotStructure
