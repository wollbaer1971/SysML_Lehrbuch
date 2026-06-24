// ============================================================
// 00_overview.sysml
// AutonomousIndoorRobot – Projektziel, Umfang & Systemgrenze
// SysML v2
// ============================================================

package AutonomousIndoorRobot {

    doc
        /*
         * Projektziel
         * -----------
         * Entwicklung eines autonomen Innenraum-Roboters, der selbstständig
         * in strukturierten Gebäudeumgebungen navigiert, Hindernisse erkennt
         * und ausweicht sowie einfache Transportaufgaben ausführt.
         * Der Roboter soll ohne menschliches Eingreifen betrieben werden
         * und sich dabei sicher im Umfeld von Personen bewegen.
         *
         * Umfang (Scope)
         * --------------
         * IN SCOPE:
         *   - Autonome Navigation in bekannten und unbekannten Innenräumen
         *   - Hindernis- und Personenerkennung (Sicherheitsfunktion)
         *   - Aufgabenplanung und Missionsausführung via ROS 2
         *   - Energiemanagement und autonomes Aufladen
         *   - Statusüberwachung und Fehlerdiagnose
         *   - Kommunikation mit einer Leitstation (WLAN/ROS 2 Topics)
         *
         * OUT OF SCOPE:
         *   - Außeneinsatz / Geländefahrten
         *   - Manipulation von Objekten (Greifen, Heben)
         *   - Sprach- oder Gesichtserkennung
         *   - Mehrroboter-Koordination (Multi-Agent)
         */

    // ----------------------------------------------------------
    // Systemdefinition
    // ----------------------------------------------------------

    part def Robot {
        doc /* Wurzelelement: repräsentiert den vollständigen Roboter
               als Black Box an der Systemgrenze. 
            */

        // Physische Schnittstellen zur Umgebung
        port powerPort      : ~PowerSupplyInterface;   // Ladestation
        port wlanPort       : ~WLANInterface;           // Leitstation
        port sensorEnv      : ~EnvironmentSensingInterface; // Sensor → Umgebung
        port actuatorEnv    : ~MotionInterface;         // Antrieb → Umgebung
    }

    // ----------------------------------------------------------
    // Systemgrenze  (System-of-Interest vs. External Actors)
    // ----------------------------------------------------------

    part def SystemContext {
        doc /* Beschreibt alle Akteure und externen Systeme,
               die mit dem Roboter interagieren. */

        // System-of-Interest
        part robot : AutonomousIndoorRobot;

        // Externe Akteure
        part operator        : HumanOperator;
        part chargingStation : ChargingStation;
        part controlStation  : ControlStation;
        part environment     : IndoorEnvironment;
    }

    // ----------------------------------------------------------
    // Externe Akteure (Skelett-Definitionen)
    // ----------------------------------------------------------

    part def HumanOperator {
        doc /* Techniker oder Nutzer, der Missionen konfiguriert
               und den Systemstatus überwacht. Kein Eingriff während
               des autonomen Betriebs vorgesehen. */
    }

    part def ChargingStation {
        doc /* Stationäre Ladeeinheit; wird vom Roboter autonom
               angefahren, sobald der Akkustand einen Schwellwert
               unterschreitet. */
    }

    part def ControlStation {
        doc /* Softwarebasierte Leitstation (z. B. ROS 2 Dashboard);
               empfängt Statustelegramme und sendet Missionsbefehle
               via WLAN. */
    }

    part def IndoorEnvironment {
        doc /* Strukturierte Innenraumumgebung (Büro, Korridor, Lager).
               Enthält statische Hindernisse (Wände, Möbel) und
               dynamische Hindernisse (Personen, Türen). */
    }

    // ----------------------------------------------------------
    // Schnittstellenskelette (werden in 05_interfaces.sysml
    // vollständig spezifiziert)
    // ----------------------------------------------------------

    interface def PowerSupplyInterface;
    interface def WLANInterface;
    interface def EnvironmentSensingInterface;
    interface def MotionInterface;

}
