package Structure {

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

  part def NavigationSystem;
  part def MotionControl;
  part def UserInterface;
  part def SafetyLogic;
  part def Camera;
  part def Lidar;
  part def ObjectDetector;
  part def Battery;
  part def BatteryMonitor;
  part def ChargingInterface;
}
