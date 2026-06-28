// ============================================================
// 02_requirements.sysml
// AutonomousIndoorRobot – Anforderungen
// SysML v2
// ============================================================

package Requirements {

    doc
        /*
         * Anforderungshierarchie des autonomen Indoor-Roboters.
         *
         * Leseanleitung
         * -------------
         * REQ_XXX   = Systemanforderung (what, not how)
         * Jede Anforderung hat:
         *   - id    : eindeutiger Bezeichner
         *   - doc   : Anforderungstext (vollständiger Satz, testbar)
         * Testfälle (TC_XXX) stehen in 06_tests.sysml
         * und sind dort mit verify auf die Anforderungen verknüpft.
         */

    // ==========================================================
    // 1. Navigation
    // ==========================================================

    requirement REQ_Navigate {
        doc
        /*
         * ID: REQ-001
         * Der Roboter muss in einem bekannten Innenraumbereich
         * autonom ein vom Operator vorgegebenes Ziel anfahren können.
         */

        requirement REQ_PathPlanning {
            doc
            /*
             * ID: REQ-001-1
             * Der Roboter muss aus einer digitalen 2D-Gebäudekarte
             * einen kollisionsfreien Pfad zum Ziel berechnen.
             */
        }

        requirement REQ_GoalReachConfirmation {
            doc
            /*
             * ID: REQ-001-2
             * Der Roboter muss nach Erreichen des Ziels eine
             * Bestätigung (status: 'goal_reached') auf /robot_status
             * publizieren.
             */
        }

        requirement REQ_NavigationTimeout {
            doc
            /*
             * ID: REQ-001-3
             * Wenn das Ziel nach 300 Sekunden nicht erreicht wird,
             * muss der Roboter abbrechen und 'navigation_timeout'
             * melden.
             */
        }
    }

    // ==========================================================
    // 2. Sicherheit
    // ==========================================================

    requirement REQ_Safety {
        doc
        /*
         * ID: REQ-002
         * Der Roboter muss zu jeder Zeit kollisionsfrei und
         * personensicher betrieben werden können.
         */

        requirement REQ_DetectObstacles {
            doc
            /*
             * ID: REQ-002-1
             * Der Roboter muss statische und dynamische Hindernisse
             * im Fahrweg innerhalb eines 270°-Sichtfelds erkennen.
             */
        }

        requirement REQ_StopSafely {
            doc
            /*
             * ID: REQ-002-2
             * Bei einem Hindernis in weniger als 0,5 m Abstand muss
             * der Roboter bremsen. Bei weniger als 0,2 m muss er
             * vollständig stoppen. Stopp innerhalb von 2 Sekunden.
             */
        }

        requirement REQ_PersonSafety {
            doc
            /*
             * ID: REQ-002-3
             * Wenn eine Person erkannt wird, muss der Roboter seine
             * Geschwindigkeit auf maximal 0,2 m/s reduzieren und
             * einen Mindestabstand von 0,5 m einhalten.
             */
        }

        requirement REQ_EmergencyStop {
            doc
            /*
             * ID: REQ-002-4
             * Nach Betätigung des Notstopp-Signals muss der Roboter
             * innerhalb von 0,5 Sekunden auf 0 m/s abbremsen.
             * Wiederanlauf erst nach expliziter Operator-Quittierung.
             */
        }
    }

    // ==========================================================
    // 3. Energieversorgung
    // ==========================================================

    requirement REQ_Battery {
        doc
        /*
         * ID: REQ-003
         * Der Roboter muss seine Energieversorgung autonom verwalten
         * und einen unterbrechungsfreien Betrieb gewährleisten.
         */

        requirement REQ_MonitorBattery {
            doc
            /*
             * ID: REQ-003-1
             * Der Roboter muss den Akkustand kontinuierlich mit
             * einer Rate von mindestens 1 Hz überwachen und auf
             * /battery_state publizieren.
             */
        }

        requirement REQ_ReturnToDock {
            doc
            /*
             * ID: REQ-003-2
             * Wenn der Akkustand unter 20 % sinkt, muss der Roboter
             * die aktive Mission unterbrechen und die Ladestation
             * innerhalb von 120 Sekunden anfahren.
             */
        }

        requirement REQ_LowBatteryWarning {
            doc
            /*
             * ID: REQ-003-3
             * Wenn der Akkustand unter 30 % sinkt, muss der Roboter
             * eine Warnung ('battery_low') auf /robot_status publizieren.
             */
        }

        requirement REQ_MinOperatingTime {
            doc
            /*
             * ID: REQ-003-4
             * Der Roboter muss bei vollgeladener Batterie mindestens
             * 4 Stunden kontinuierlich betrieben werden können.
             */
        }
    }

    // ==========================================================
    // 4. Wahrnehmung
    // ==========================================================

    requirement REQ_Perception {
        doc
        /*
         * ID: REQ-004
         * Der Roboter muss seine Umgebung zuverlässig erfassen
         * und eine konsistente Zustandsdarstellung aufrechterhalten.
         */

        requirement REQ_Lidar {
            doc
            /*
             * ID: REQ-004-1
             * Der Lidar-Sensor muss Entfernungen im Bereich von
             * 0,1 m bis 12,0 m mit einer Genauigkeit von +/- 3 cm
             * erfassen (270° Sichtfeld, 10 Hz).
             */
        }

        requirement REQ_Camera {
            doc
            /*
             * ID: REQ-004-2
             * Die Kamera muss Personen bei Beleuchtungsstärken
             * von 50 lx bis 1000 lx mit einer False-Negative-Rate
             * von maximal 5 % erkennen.
             */
        }

        requirement REQ_Localization {
            doc
            /*
             * ID: REQ-004-3
             * Der Roboter muss seine Position in der Gebäudekarte
             * mit einer Genauigkeit von +/- 10 cm bestimmen können.
             */
        }
    }

    // ==========================================================
    // 5. Bedienung und Kommunikation
    // ==========================================================

    requirement REQ_UI {
        doc
        /*
         * ID: REQ-005
         * Der Roboter muss über eine klar verständliche
         * Mensch-Maschine-Schnittstelle verfügen.
         */

        requirement REQ_StatusFeedback {
            doc
            /*
             * ID: REQ-005-1
             * Der Roboter muss seinen Betriebszustand (idle,
             * navigating, charging, error) auf /robot_status
             * mit einer Rate von 1 Hz publizieren.
             */
        }

        requirement REQ_MissionInput {
            doc
            /*
             * ID: REQ-005-2
             * Der Roboter muss Missionsziele als
             * geometry_msgs/PoseStamped auf /mission_goal
             * empfangen und verarbeiten können.
             */
        }
    }

    // ==========================================================
    // 6. Randbedingungen
    // ==========================================================

    requirement REQ_Constraints {
        doc
        /*
         * ID: REQ-006
         * Nicht-funktionale Randbedingungen für den Betrieb.
         */

        requirement REQ_MaxSpeed {
            doc
            /*
             * ID: REQ-006-1
             * Die maximale Fahrgeschwindigkeit beträgt 0,5 m/s.
             * Im Personennahbereich (< 1,0 m) maximal 0,2 m/s.
             */
        }

        requirement REQ_Dimensions {
            doc
            /*
             * ID: REQ-006-2
             * Der Roboter muss Durchgänge mit einer lichten
             * Breite von >= 0,9 m passieren können.
             * Maximale Fahrzeugbreite: 0,6 m.
             */
        }

        requirement REQ_Noise {
            doc
            /*
             * ID: REQ-006-3
             * Der Roboter darf im Betrieb maximal 55 dB(A)
             * Schalldruckpegel in 1 m Abstand erzeugen.
             */
        }
    }
}
