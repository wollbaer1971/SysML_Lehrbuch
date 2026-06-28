// ============================================================
// 06_tests.sysml
// AutonomousIndoorRobot – Testfälle und Verifikation
// SysML v2
// ============================================================

package Tests {

    doc
        /*
         * Testmodell des autonomen Indoor-Roboters.
         *
         * Jeder Testfall (verification def TC_XXX) beschreibt:
         *   - Vorbedingung: Systemzustand vor dem Test
         *   - Aktion: Was ausgelöst oder simuliert wird
         *   - Erwartung: Messbares Ergebnis
         *   - Akzeptanzkriterium: Grenzwert für Bestehen/Nichtbestehen
         *
         * Die verify-Beziehung verbindet Testfall mit Anforderung.
         * Sie stellt die Nachvollziehbarkeit (Traceability) sicher:
         *   Anforderung <- verify <- Testfall <- Testergebnis
         *
         * Testtypen:
         *   TC-001 bis TC-003 : Sicherheit
         *   TC-004 bis TC-006 : Navigation
         *   TC-007 bis TC-009 : Energiemanagement
         *   TC-010            : Schnittstellen
         */

    // ==========================================================
    // Sicherheit
    // ==========================================================

    verification def TC_001_ObstacleStop {
        doc
        /*
         * ID: TC-001
         * Titel: Vollstopp vor Hindernis
         *
         * Vorbedingung:
         *   - Roboter fährt mit 0,3 m/s in Richtung Hindernis
         *   - Lidar-Sensor aktiv und kalibriert
         *
         * Aktion:
         *   - Hindernis wird in 0,4 m Abstand in Fahrrichtung platziert
         *
         * Erwartung:
         *   - Roboter beginnt Bremsen bei 0,5 m
         *   - Roboter kommt bei >= 0,2 m Abstand zum Stillstand
         *   - /robot_status publiziert 'obstacle_stop'
         *
         * Akzeptanzkriterium:
         *   - Stopp innerhalb von 2,0 Sekunden
         *   - Mindestabstand zum Hindernis: 0,20 m (+ 0,02 m Toleranz)
         *   - Keine Kollision
         *
         * Testumgebung: Reale Hardware ODER Gazebo-Simulation
         */
    }

    verification def TC_002_PersonSlowdown {
        doc
        /*
         * ID: TC-002
         * Titel: Geschwindigkeitsreduktion bei Personenerkennung
         *
         * Vorbedingung:
         *   - Roboter navigiert mit 0,5 m/s
         *   - PersonDetector läuft
         *
         * Aktion:
         *   - Testperson tritt in 0,8 m Abstand seitlich in den Fahrbereich
         *
         * Erwartung:
         *   - PersonDetector publiziert Person auf /persons_detected
         *   - SafetyWatchdog reduziert /cmd_vel auf max. 0,2 m/s
         *   - Roboter hält >= 0,5 m Abstand
         *   - /robot_status bleibt 'navigating' (kein Vollstopp)
         *
         * Akzeptanzkriterium:
         *   - Geschwindigkeit <= 0,20 m/s innerhalb 1,0 s nach Erkennung
         *   - Abstand >= 0,50 m in gesamter Messzeit
         */
    }

    verification def TC_003_EmergencyStop {
        doc
        /*
         * ID: TC-003
         * Titel: Nothalttaste
         *
         * Vorbedingung:
         *   - Roboter navigiert mit beliebiger Geschwindigkeit
         *
         * Aktion:
         *   - Hardware-Nothalttaste wird betätigt (oder /emergency_active = true)
         *
         * Erwartung:
         *   - Roboter bremst auf 0 m/s
         *   - /robot_status wechselt auf 'emergency_stop'
         *   - Keine Bewegung bis zur Quittierung durch Operator
         *
         * Akzeptanzkriterium:
         *   - Geschwindigkeit = 0 m/s innerhalb von 0,50 Sekunden
         *   - Gesperrter Zustand hält an bis Operator-Quittierung
         */
    }

    // ==========================================================
    // Navigation
    // ==========================================================

    verification def TC_004_GoalReached {
        doc
        /*
         * ID: TC-004
         * Titel: Ziel anfahren und bestätigen
         *
         * Vorbedingung:
         *   - Roboter im Zustand 'idle'
         *   - Gebäudekarte vorhanden
         *   - Ziel ist erreichbar (freie Route)
         *
         * Aktion:
         *   - /mission_goal mit Zielkoordinaten (5,0 m, 3,0 m) publizieren
         *
         * Erwartung:
         *   - Roboter wechselt auf 'navigating'
         *   - Roboter erreicht Zielposition
         *   - /robot_status publiziert 'goal_reached'
         *
         * Akzeptanzkriterium:
         *   - Ziel erreicht innerhalb von 300 Sekunden
         *   - Endposition innerhalb 0,20 m des Ziels
         *   - Keine Kollision auf dem Weg
         */
    }

    verification def TC_005_NavigationTimeout {
        doc
        /*
         * ID: TC-005
         * Titel: Navigations-Timeout bei blockiertem Weg
         *
         * Vorbedingung:
         *   - Roboter navigiert zu einem Ziel
         *   - Fahrweg ist dauerhaft durch Hindernis blockiert
         *
         * Aktion:
         *   - Hindernis blockiert vollständig alle Ausweichrouten
         *   - System wartet >= 300 Sekunden
         *
         * Erwartung:
         *   - Roboter stoppt nach 300 s
         *   - /robot_status publiziert 'navigation_timeout'
         *   - Keine Endlosschleife
         *
         * Akzeptanzkriterium:
         *   - Statuswechsel zu 'navigation_timeout' nach 300 (+/- 5) Sekunden
         */
    }

    verification def TC_006_LocalizationAccuracy {
        doc
        /*
         * ID: TC-006
         * Titel: Lokalisierungsgenauigkeit
         *
         * Vorbedingung:
         *   - Bekannte Karte geladen
         *   - Roboter an bekannter Startposition
         *
         * Aktion:
         *   - Roboter fährt eine definierte Route von 10 m
         *   - /amcl_pose wird kontinuierlich aufgezeichnet
         *
         * Erwartung:
         *   - Abweichung zwischen /amcl_pose und Bodenwahrheit <= 0,10 m
         *
         * Akzeptanzkriterium:
         *   - Max. Positionsfehler <= 0,10 m (95%-Perzentil über Route)
         */
    }

    // ==========================================================
    // Energiemanagement
    // ==========================================================

    verification def TC_007_BatteryLowReturn {
        doc
        /*
         * ID: TC-007
         * Titel: Rückkehr zur Ladestation bei niedrigem Akku
         *
         * Vorbedingung:
         *   - Roboter navigiert zu einem Ziel
         *   - Akkustand: 25 % (simuliert oder real)
         *   - Position der Ladestation bekannt
         *
         * Aktion:
         *   - Akkustand fällt auf 19 % (unterhalb 20 %-Schwelle)
         *
         * Erwartung:
         *   - Roboter bricht Navigation ab
         *   - Roboter wechselt in Zustand 'returning'
         *   - Roboter dockt an Ladestation an
         *   - /robot_status publiziert 'charging' nach Andocken
         *
         * Akzeptanzkriterium:
         *   - Ladestation innerhalb 120 Sekunden erreicht
         *   - Abbruch der Navigation innerhalb 2 Sekunden nach Unterschreitung
         */
    }

    verification def TC_008_BatteryWarning {
        doc
        /*
         * ID: TC-008
         * Titel: Akkuwarnung bei 30 %
         *
         * Vorbedingung:
         *   - Roboter im Betrieb, Akkustand: 35 %
         *
         * Aktion:
         *   - Akkustand sinkt auf 29 % (unterhalb 30 %-Schwelle)
         *
         * Erwartung:
         *   - /robot_status publiziert 'battery_low'
         *   - Roboter setzt aktuelle Mission fort (kein Abbruch)
         *
         * Akzeptanzkriterium:
         *   - Statusmeldung innerhalb 2 Sekunden nach Unterschreitung
         */
    }

    verification def TC_009_MinOperatingTime {
        doc
        /*
         * ID: TC-009
         * Titel: Mindestbetriebszeit 4 Stunden
         *
         * Vorbedingung:
         *   - Akku vollgeladen (100 %)
         *   - Normalbetrieb (Navigation, Sensorbetrieb)
         *
         * Aktion:
         *   - Roboter fährt Standardprofil: 60 % Fahren, 40 % Idle
         *   - Akkustand wird kontinuierlich aufgezeichnet
         *
         * Erwartung:
         *   - Akku verbleibt > 20 % nach 4 Stunden
         *
         * Akzeptanzkriterium:
         *   - Akkustand nach 240 Minuten >= 20 % (Abbruchschwelle)
         */
    }

    // ==========================================================
    // Schnittstellentest
    // ==========================================================

    verification def TC_010_StatusTopicRate {
        doc
        /*
         * ID: TC-010
         * Titel: /robot_status Publishrate
         *
         * Vorbedingung:
         *   - System gestartet, Roboter im Zustand 'idle'
         *
         * Aktion:
         *   - /robot_status für 60 Sekunden aufzeichnen
         *
         * Erwartung:
         *   - Mindestens 55 Nachrichten in 60 Sekunden (1 Hz - 10 % Toleranz)
         *
         * Akzeptanzkriterium:
         *   - Nachrichtenrate >= 0,9 Hz
         */
    }

    // ==========================================================
    // Verify-Beziehungen (Testfall -> Anforderung)
    // ==========================================================

    part robot : Robot {

        // Sicherheit
        verify REQ_DetectObstacles  by tc1  : TC_001_ObstacleStop;
        verify REQ_StopSafely       by tc1b : TC_001_ObstacleStop;
        verify REQ_PersonSafety     by tc2  : TC_002_PersonSlowdown;
        verify REQ_EmergencyStop    by tc3  : TC_003_EmergencyStop;

        // Navigation
        verify REQ_Navigate         by tc4  : TC_004_GoalReached;
        verify REQ_PathPlanning     by tc4b : TC_004_GoalReached;
        verify REQ_GoalReachConfirmation by tc4c : TC_004_GoalReached;
        verify REQ_NavigationTimeout by tc5 : TC_005_NavigationTimeout;
        verify REQ_Localization     by tc6  : TC_006_LocalizationAccuracy;

        // Energie
        verify REQ_ReturnToDock     by tc7  : TC_007_BatteryLowReturn;
        verify REQ_MonitorBattery   by tc8  : TC_008_BatteryWarning;
        verify REQ_LowBatteryWarning by tc8b : TC_008_BatteryWarning;
        verify REQ_MinOperatingTime by tc9  : TC_009_MinOperatingTime;

        // Schnittstelle
        verify REQ_StatusFeedback   by tc10 : TC_010_StatusTopicRate;
    }
}
