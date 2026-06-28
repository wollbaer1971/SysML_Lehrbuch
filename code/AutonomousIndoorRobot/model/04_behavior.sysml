// ============================================================
// 04_behavior.sysml
// AutonomousIndoorRobot – Verhalten (Actions & States)
// SysML v2
// ============================================================

package Behavior {

    doc
        /*
         * Verhaltensmodell des autonomen Indoor-Roboters.
         *
         * Inhalt:
         *   1. Aktionsdefinitionen (action def) – Was der Roboter tut
         *   2. Zustandsmaschine (state def)     – In welchem Modus er ist
         *
         * Jeder action def beschreibt einen abgrenzbaren Vorgang.
         * Die state def RobotOperation beschreibt alle Betriebsmodi
         * und die Übergänge zwischen ihnen.
         */

    // ==========================================================
    // Aktionsdefinitionen
    // ==========================================================

    action def MonitorBattery {
        doc
        /*
         * Liest Akkustand (1 Hz) und publiziert sensor_msgs/BatteryState.
         * Löst 'battery_low'-Warnung bei < 30 % aus.
         * Löst Rückkehr zur Ladestation bei < 20 % aus.
         * Verantwortlich für: REQ-003-1, REQ-003-2, REQ-003-3
         */

        in  currentLevel  : Real;    // Akkustand in Prozent
        out batteryMsg    : BatteryState;
        out triggerReturn : Boolean; // true wenn < 20 %
        out triggerWarn   : Boolean; // true wenn < 30 %
    }

    action def NavigateToGoal {
        doc
        /*
         * Empfängt Zielpose, plant Route, fährt Roboter zum Ziel.
         * Überwacht laufend lokale Hindernisse und passt Pfad an.
         * Gibt 'goal_reached' oder 'navigation_failed' zurück.
         * Verantwortlich für: REQ-001
         */

        in  goal          : Pose;
        in  currentMap    : OccupancyGrid;
        in  currentPose   : Pose;
        out cmdVel        : Twist;
        out status        : String;  // 'navigating' | 'goal_reached' | 'navigation_failed'
    }

    action def AvoidObstacle {
        doc
        /*
         * Reagiert auf Hindernisse im Fahrbereich.
         * Stufe 1 (< 0,5 m): Geschwindigkeit reduzieren
         * Stufe 2 (< 0,2 m): Vollstopp
         * Gibt Kontrolle an NavigateToGoal zurück sobald Weg frei ist.
         * Verantwortlich für: REQ-002-1, REQ-002-2
         */

        in  obstacleDistance : Real;   // Meter zum nächsten Hindernis
        out cmdVel           : Twist;  // angepasster Fahrbefehl
        out statusMsg        : String; // 'slowing' | 'stopped' | 'clear'
    }

    action def DetectPersons {
        doc
        /*
         * Verarbeitet Kamerabild und erkennt Personen per ML-Modell.
         * Ausgabe: Liste erkannter Personen mit Abstand und Richtung.
         * Verantwortlich für: REQ-004-2, REQ-002-3
         */

        in  cameraFrame   : Image;
        out personsFound  : Boolean;
        out minDistance   : Real;    // Meter zum nächsten Erkannten
    }

    action def ReturnToCharger {
        doc
        /*
         * Fährt Roboter zur Ladestation und initiiert Ladevorgang.
         * Ladestation wird über Infrarot-Marker oder gespeicherte
         * Position lokalisiert.
         * Verantwortlich für: REQ-003-2
         */

        in  chargingStationPose : Pose;
        out cmdVel              : Twist;
        out dockingStatus       : String; // 'approaching' | 'docked' | 'charging'
    }

    action def EmergencyBrake {
        doc
        /*
         * Bringt den Roboter innerhalb von 0,5 s auf 0 m/s.
         * Sperrt alle anderen Fahrbefehle bis zur Quittierung.
         * Verantwortlich für: REQ-002-4
         */

        out cmdVel : Twist; // Twist mit linear.x=0, angular.z=0
        out locked : Boolean; // true = gesperrt bis Quittierung
    }

    action def PublishStatus {
        doc
        /*
         * Publiziert aktuellen Betriebszustand auf /robot_status (1 Hz).
         * Zustandstext: 'idle' | 'navigating' | 'obstacle_stop' |
         *               'charging' | 'emergency_stop' | 'error'
         * Verantwortlich für: REQ-005-1
         */

        in  state  : String;
        out status : String;
    }

    // ==========================================================
    // Zustandsmaschine: Betriebsmodi des Roboters
    // ==========================================================

    state def RobotOperation {
        doc
        /*
         * Beschreibt alle Betriebsmodi des Roboters und die
         * möglichen Übergänge zwischen ihnen.
         *
         * Zustandsübersicht:
         *   idle           – Bereit, wartet auf Mission
         *   navigating     – Fährt aktiv zu einem Ziel
         *   avoidingObs    – Ausweichmanöver läuft
         *   slowForPerson  – Personenmodus, Geschwindigkeit reduziert
         *   returning      – Fährt zur Ladestation (Akku < 20 %)
         *   charging       – Angedockt und lädt
         *   emergencyStopped – Notstopp aktiv, gesperrt
         *   error          – Fehler, Neustart oder Operator-Eingriff erforderlich
         */

        // Startzustand
        entry; then idle;

        // ----------------------------------------------------------
        state idle {
            doc /* Roboter steht, wartet auf Missionsbefehl oder Ereignis. */

            do action PublishStatus { in state = "idle"; }

            transition accept GoalReceived
                then navigating;

            transition accept BatteryLow    // < 20 %
                then returning;

            transition accept EmergencySignal
                then emergencyStopped;
        }

        // ----------------------------------------------------------
        state navigating {
            doc /* Roboter fährt aktiv zu einem Ziel. */

            do action NavigateToGoal;
            do action MonitorBattery;
            do action PublishStatus { in state = "navigating"; }

            transition accept GoalReached
                then idle;

            transition accept ObstacleDetected   // Hindernis < 0,5 m
                then avoidingObs;

            transition accept PersonDetected
                then slowForPerson;

            transition accept BatteryLow         // < 20 %
                then returning;

            transition accept NavigationFailed
                then error;

            transition accept EmergencySignal
                then emergencyStopped;
        }

        // ----------------------------------------------------------
        state avoidingObs {
            doc /* Hindernisausweichung läuft.
                   Stoppt vollständig bei < 0,2 m. */

            do action AvoidObstacle;
            do action PublishStatus { in state = "obstacle_stop"; }

            transition accept PathClear
                then navigating;

            transition accept BatteryLow
                then returning;

            transition accept EmergencySignal
                then emergencyStopped;

            transition accept TimeoutExceeded   // > 30 s im Ausweichmodus
                then error;
        }

        // ----------------------------------------------------------
        state slowForPerson {
            doc /* Person erkannt, Geschwindigkeit <= 0,2 m/s. */

            do action DetectPersons;
            do action NavigateToGoal;

            transition accept PersonGone        // > 1,0 m Abstand
                then navigating;

            transition accept BatteryLow
                then returning;

            transition accept EmergencySignal
                then emergencyStopped;
        }

        // ----------------------------------------------------------
        state returning {
            doc /* Fährt zur Ladestation wegen niedrigem Akku. */

            do action ReturnToCharger;
            do action PublishStatus { in state = "returning"; }

            transition accept Docked
                then charging;

            transition accept EmergencySignal
                then emergencyStopped;

            transition accept NavigationFailed
                then error;
        }

        // ----------------------------------------------------------
        state charging {
            doc /* Roboter ist angedockt und lädt.
                   Verlässt Zustand bei Akku >= 90 %. */

            do action MonitorBattery;
            do action PublishStatus { in state = "charging"; }

            transition accept BatteryFull       // >= 90 %
                then idle;
        }

        // ----------------------------------------------------------
        state emergencyStopped {
            doc /* Notstopp aktiv. Alle Bewegungen gesperrt.
                   Rückkehr zu idle erst nach Operator-Quittierung. */

            do action EmergencyBrake;
            do action PublishStatus { in state = "emergency_stop"; }

            transition accept OperatorAck
                then idle;
        }

        // ----------------------------------------------------------
        state error {
            doc /* Systemfehler. Roboter steht.
                   Operator oder Watchdog muss eingreifen. */

            do action PublishStatus { in state = "error"; }

            transition accept SystemReset
                then idle;
        }
    }
}
