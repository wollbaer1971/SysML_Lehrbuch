package Behavior {
  doc
  /* Aktionen, Ablaeufe und Zustaende des Roboters (Abschnitt 4.11:
     "04_behavior.sysml: Aktionen, Abläufe und Zustände").

     Diese Datei uebernimmt die im Lehrbuch tatsaechlich abgedruckten
     SysML-v2-Verhaltenskonstrukte und wendet sie auf das Projekt
     AutonomousIndoorRobot an. Es werden keine im Buch nicht belegten
     Zustaende, Ereignisse oder Zahlenwerte hinzuerfunden.

     Kapitel 11 "Verhaltensmodellierung mit Activity Diagrams" (S. 88-93):
     Das Buch stellt Aktivitaeten dort bewusst als Prosa/Diagramm dar,
     NICHT als SysML-v2-Textnotation. Zitat Abschnitt 11.2 (S. 88):
     "In diesem Kapitel stellen wir Aktivitätsdiagramme bewusst über
     Prosa und Diagramme dar statt über die SysML-v2-Textnotation
     (action def, action, then, decide, fork/join) [...], wird hier
     aber zugunsten der Einsteigerfreundlichkeit ausgespart."
     Auch Abschnitt 3.3.4 "Verhaltensmodellierung (action def, action)"
     (S. 38) erklaert das Konzept nur in Prosa, ohne Codebeispiel.
     Das Buch enthaelt daher an keiner Stelle einen abgedruckten
     action-def-Block - auch keinen generischen. Es wird deshalb hier
     bewusst KEIN action def formuliert, um keine Syntax zu erfinden,
     die im Buch nicht vorkommt.

     Zur Dokumentation (nicht als SysML-Code, nur als Kommentar) der
     Beispielablauf "Navigation" aus Abschnitt 11.3 (S. 89), Abbildung 11.1:
       System starten -> Sensoren initialisieren -> Karte laden ->
       Ziel empfangen -> Akkustand pruefen ->
         [Akku niedrig]       -> Rueckkehr zur Ladestation (Abb. 11.2)
         [Akku ausreichend]   -> Pfad planen ->
           (parallel: Sensoren ueberwachen / Bewegung ausfuehren /
            Kommunikation ueberwachen) ->
       Hindernis erkannt? ->
         [Hindernis erkannt]  -> Neu planen
         [Fahrweg frei]       -> Ziel erreicht melden
  */

  // -----------------------------------------------------------------
  // Kapitel 12 "Zustandsmodellierung mit State Machines" (S. 94-98)
  //
  // state def RobotOperation: woertlich aus Abschnitt 12.4 "Beispiel"
  // (S. 95) uebernommen. Zustaende gemaess Abschnitt 12.2 (S. 94:
  // Idle, Navigating, AvoidingObstacle, ReturnToDock, Charging, Error -
  // im Code in camelCase gemaess Hinweis in 12.2). Ereignisse gemaess
  // Abschnitt 12.3 (S. 94f.: GoalReceived, BatteryLow, ObstacleDetected,
  // PathFree, DockReached, ChargingComplete, ErrorDetected, Reset).
  // -----------------------------------------------------------------
  state def RobotOperation {
    entry; then idle;

    state idle {
      transition accept GoalReceived then navigating;
    }
    state navigating {
      transition accept ObstacleDetected then avoidingObstacle;
      transition accept BatteryLow then returnToDock;
      transition accept ErrorDetected then error;
    }
    state avoidingObstacle {
      transition accept PathFree then navigating;
    }
    state returnToDock {
      transition accept DockReached then charging;
    }
    state charging {
      transition accept ChargingComplete then idle;
      // Erweiterung gemaess Fliesstext Abschnitt 12.9 "Praxisbeispiel:
      // Betriebsmodi des Roboters" (S. 97): "Ein Fehler kann während
      // der Navigation, beim Laden oder während der Initialisierung
      // auftreten; ein vollständigeres Modell würde daher zusätzliche
      // Übergänge wie transition accept ErrorDetected then error; auch
      // in charging und einem möglichen Initialisierungszustand
      // ergänzen." Diese konkret benannte Uebergangszeile fuer charging
      // wird hier uebernommen; ein "moeglicher Initialisierungszustand"
      // bleibt bewusst offen, weil das Buch dafuer keinen konkreten
      // Zustandsnamen nennt.
      transition accept ErrorDetected then error;
    }
    state error {
      transition accept Reset then idle;
    }
  }

  // Hinweis zu Guards (Abschnitt 12.5, S. 96): Im gedruckten Listing
  // oben sind Guard-Bedingungen bewusst weggelassen ("Im Codebeispiel
  // weiter oben ist dieser Guard der Übersichtlichkeit halber
  // weggelassen"). Das Buch nennt als Illustration, wie eine ergaenzte
  // Zeile aussehen koennte:
  //   transition accept GoalReceived[batteryOk] then navigating;
  // Diese Guard-Syntax wird hier NICHT in state def RobotOperation
  // uebernommen, weil sie im Buch ausdruecklich nicht Teil des
  // offiziellen Listings ist, sondern nur als Beispiel im Fliesstext
  // dient.

  // -----------------------------------------------------------------
  // Kapitel 13 "Parametrische Modellierung" (S. 99-103)
  //
  // calc def OperatingTimeCalc: woertlich aus Abschnitt 13.6 (S. 101).
  // -----------------------------------------------------------------
  calc def OperatingTimeCalc {
    in energy : Real; // nutzbare Energie in Wh
    in power : Real; // mittlere Leistungsaufnahme in W
    return operatingTime : Real = energy / power;
  }

  // calc def BrakingDistanceCalc: aus Abschnitt 13.5 "Bremsweg" (S. 100),
  // dort woertlich im Fliesstext angegeben: "Analog zu OperatingTimeCalc
  // ließe sich das als calc def BrakingDistanceCalc { in v: Real; in a:
  // Real; return s: Real = v*v/(2*a); } formulieren." Kein eigenes
  // Listing, aber vollstaendige Codezeile im Text. Wird in Abbildung 13.2
  // (S. 100) als Eingang fuer die Bedingung SafeBrakingDistance gezeigt.
  calc def BrakingDistanceCalc {
    in v : Real;
    in a : Real;
    return s : Real = v * v / (2 * a);
  }

  // constraint def SafeBrakingDistance: woertlich aus Abschnitt 13.6
  // (S. 102).
  constraint def SafeBrakingDistance {
    in s : Real; // berechneter Bremsweg in m
    in sMax : Real; // maximal zulaessiger Bremsweg in m
    assert s <= sMax;
  }
}
