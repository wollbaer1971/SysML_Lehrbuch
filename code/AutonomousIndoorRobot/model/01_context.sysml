// ============================================================
// 01_context.sysml
// AutonomousIndoorRobot – Systemkontext, Stakeholder & externe Systeme
// SysML v2
// ============================================================

package Context {

    doc
        /*
         * Systemkontext
         * =============
         * Diese Datei beschreibt den Kontext des autonomen Indoor-Roboters.
         * Sie listet alle Stakeholder, externen Systeme und Umgebungsbedingungen,
         * die das System beeinflussen oder von ihm beeinflusst werden.
         *
         * Die Systemgrenze trennt das System-of-Interest (Robot) von allem,
         * was außerhalb liegt. Externe Elemente sind modellrelevant, weil der
         * Roboter mit ihnen interagiert, aber nicht verantwortlich für sie ist.
         */

    // ==========================================================
    // Stakeholder
    // ==========================================================

    part def Operator {
        doc
        /*
         * Techniker oder autorisierter Nutzer.
         * Konfiguriert Missionen, überwacht den Betrieb,
         * löst Fehler und löst Nothalte aus.
         * Erwartungen:
         *   - Einfache Bedienbarkeit ohne Robotikexpertise
         *   - Klare Statusrückmeldung (Akku, Missionsstatus)
         *   - Nothalttaste muss innerhalb von 0,5 s wirken
         */
    }

    part def Maintenance {
        doc
        /*
         * Wartungstechniker.
         * Führt Hardwarewartung, Softwareupdates und Kalibrierung durch.
         * Erwartungen:
         *   - Diagnoseschnittstelle (Log-Zugriff, Sensortests)
         *   - Wartungsintervall >= 200 Betriebsstunden
         */
    }

    part def BuildingManager {
        doc
        /*
         * Gebäudeverantwortlicher.
         * Legt erlaubte Fahrbereiche und Zeiten fest.
         * Erwartungen:
         *   - Keine Beschädigung von Infrastruktur oder Personen
         *   - Betrieb innerhalb festgelegter Fahrzonen
         */
    }

    part def Bystander {
        doc
        /*
         * Personen im Fahrbereich (kein aktiver Nutzer des Roboters).
         * Sicherheitsanforderungen:
         *   - Kollisionsschutz in allen Betriebssituationen
         *   - Hör- oder Sichtbares Warnsignal bei Annäherung < 1,0 m
         */
    }

    // ==========================================================
    // Externe Systeme
    // ==========================================================

    part def ChargingStation {
        doc
        /*
         * Stationäre Ladeeinheit.
         * Liefert Energie über Kontaktplatten oder induktive Übertragung.
         * Schnittstelle: PowerSupplyInterface (siehe 05_interfaces.sysml)
         * Anforderung an ext. System:
         *   - Ladeposition muss durch AR-Marker oder Infrarotsignal
         *     identifizierbar sein (Andockhilfe)
         */
    }

    part def ControlStation {
        doc
        /*
         * Softwarebasierte Leitstation.
         * Sendet Missionsbefehle (Zielkoordinaten, Missionspakete)
         * und empfängt Statusmeldungen via ROS 2 Topics.
         * Kommunikationsprotokoll: WLAN 802.11n / ROS 2 DDS
         * Relevante Topics:
         *   /mission_goal  (geometry_msgs/PoseStamped)
         *   /robot_status  (std_msgs/String)
         */
    }

    part def Map {
        doc
        /*
         * Digitale Gebäudekarte (2D-Occupancy Grid oder 3D-Punktwolke).
         * Wird vorab erstellt oder im Betrieb per SLAM aufgebaut.
         * Format: nav_msgs/OccupancyGrid  (ROS 2)
         * Topic:  /map
         * Relevant für: NavigationSystem
         */
    }

    part def IndoorEnvironment {
        doc
        /*
         * Physische Einsatzumgebung.
         * Statische Hindernisse: Wände, Möbel, Türrahmen
         * Dynamische Hindernisse: Personen, Rollstühle, Türen
         * Besondere Bedingungen:
         *   - Glatte Böden (Parkett, Linoleum): Rutschgefahr
         *   - Glasflächen: Probleme für Lidar-Reflexion
         *   - Enge Durchgänge: Mindestbreite >= 0,9 m
         *   - Wechselnde Lichtverhältnisse: Kamera muss robust sein
         */
    }

    // ==========================================================
    // Systemkontext-Gesamtbild
    // ==========================================================

    part def SystemContext {
        doc
        /*
         * Verbindet alle externen Akteure und das System-of-Interest.
         * Diese Übersicht zeigt, mit wem / was der Roboter interagiert.
         */

        // System-of-Interest
        part robot : AutonomousIndoorRobot;

        // Stakeholder
        part operator       : Operator;
        part maintenance    : Maintenance;
        part buildingMgr    : BuildingManager;
        part bystanders     : Bystander;

        // Externe Systeme
        part chargingStation : ChargingStation;
        part controlStation  : ControlStation;
        part map             : Map;
        part environment     : IndoorEnvironment;
    }

    // ==========================================================
    // Anwendungsfälle (Use Cases) im Überblick
    // ==========================================================

    use case def UC_NavigateToGoal {
        doc
        /*
         * Operator gibt Zielposition vor.
         * Roboter plant Route, fährt autonom und bestätigt Ankunft.
         * Normalfall: Ziel erreichbar, keine Hindernisse.
         * Sonderfall: Hindernis im Weg -> Ausweichen oder Stopp + Meldung.
         */
        subject robot : AutonomousIndoorRobot;
        actor   op    : Operator;
    }

    use case def UC_ReturnToCharger {
        doc
        /*
         * Auslöser: Akkustand < 20 % oder Missionsende.
         * Roboter bricht aktive Mission ab und fährt Ladestation an.
         * Akzeptanzkriterium: Ladestation erreicht innerhalb 120 s.
         */
        subject robot : AutonomousIndoorRobot;
    }

    use case def UC_ObstacleAvoidance {
        doc
        /*
         * Hindernis erscheint im Fahrweg.
         * Roboter bremst, bewertet Ausweichmöglichkeit,
         * weicht aus oder stoppt und sendet Statusmeldung.
         */
        subject robot : AutonomousIndoorRobot;
    }

    use case def UC_EmergencyStop {
        doc
        /*
         * Operator löst Nothalttaste aus.
         * Roboter bremst innerhalb von 0,5 s auf 0 m/s.
         * Alle Aktionen werden pausiert. Quittierung durch Operator erforderlich.
         */
        subject robot : AutonomousIndoorRobot;
        actor   op    : Operator;
    }

    use case def UC_PersonDetection {
        doc
        /*
         * Kamera erkennt Person im Fahrbereich.
         * Roboter reduziert Geschwindigkeit auf <= 0,2 m/s
         * und hält Sicherheitsabstand von >= 0,5 m ein.
         */
        subject robot : AutonomousIndoorRobot;
    }
}
