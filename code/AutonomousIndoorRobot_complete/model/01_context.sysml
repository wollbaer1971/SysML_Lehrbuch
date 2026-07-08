package Context {
  doc
  /* Systemkontext des autonomen Indoor-Roboters.

     Quelle: Kapitel 1.7 "Stakeholderanalyse" mit Abbildung 1.2 (zehn
     Stakeholder mit je einem typischen Interesse), Kapitel 1.8.3
     "Kontext des Systems" (externe Akteure und Systeme) sowie Kapitel 7
     "Stakeholder und Use Cases" (7.2 Stakeholder identifizieren, 7.3
     Stakeholder-Tabelle mit Interesse/Anforderung, 7.4-7.9 Use Cases).

     Das Buch zeigt an diesen Stellen bewusst keinen SysML-Code, sondern
     Fließtext, eine Tabelle und ein Use-Case-Diagramm (Abbildung 7.1).
     Diese Datei übersetzt die dort beschriebenen Inhalte in SysML-v2-
     Elemente. Robot und ChargingStation werden aus 00_overview.sysml
     (package AutonomousIndoorRobot) übernommen, nicht neu definiert. */

  import AutonomousIndoorRobot::*;

  // ---------------------------------------------------------------
  // Stakeholder
  //
  // Kapitel 1.7 "Stakeholderanalyse" / Abbildung 1.2 nennt zehn
  // Stakeholder mit je einem typischen Interesse. Kapitel 7.3 listet
  // dieselben (bzw. überlappende) Stakeholder zusammen mit Interesse
  // UND einer möglichen Anforderung. Beide Quellen sind unten pro
  // Stakeholder im doc-Kommentar zitiert.
  // ---------------------------------------------------------------

  part def Nutzer {
    doc /* Abb. 1.2: Interesse "Ziel erreichen".
           7.3: Interesse "Ziel einfach vorgeben";
           moegliche Anforderung "Auftrag mit hoechstens drei
           Eingaben starten". */
  }

  part def PersonImGebaeude {
    doc /* Abb. 1.2: "Personen im Gebaeude", Interesse "sicher
           bleiben". Laut 1.7 bewegen sich diese Personen im Gebaeude,
           ohne den Roboter selbst zu bedienen. */
  }

  part def Betreiber {
    doc /* Abb. 1.2: Interesse "wirtschaftlicher Betrieb".
           7.3: Interesse "Zuverlaessiger Betrieb"; moegliche
           Anforderung "Betriebszustand jederzeit anzeigen". */
  }

  part def Wartungspersonal {
    doc /* Abb. 1.2: Interesse "Fehler erkennen".
           7.3 (dort "Wartung"): Interesse "Fehler schnell finden";
           moegliche Anforderung "Diagnoseinformationen
           bereitstellen". */
  }

  part def Entwicklung {
    doc /* Abb. 1.2 (dort "Entwickler"): Interesse "System
           verstehen".
           7.3: Interesse "Klare Architektur"; moegliche Anforderung
           "Schnittstellen dokumentieren". */
  }

  part def Sicherheitsbeauftragte {
    doc /* Abb. 1.2: Interesse "Risiken bewerten".
           7.3 (dort "Sicherheitsverantwortliche"): Interesse
           "Personen schuetzen"; moegliche Anforderung "Bei Hindernis
           sicher stoppen". */
  }

  part def Datenschutzverantwortliche {
    doc /* Abb. 1.2: Interesse "Daten schuetzen".
           7.3 (dort "Datenschutz"): Interesse "Bilddaten schuetzen";
           moegliche Anforderung "Kameradaten lokal verarbeiten".
           Vgl. auch 1.7.2 Praxisbeispiel: Bilder sollen nur lokal
           verarbeitet und nicht dauerhaft gespeichert werden. */
  }

  part def EinkaufManagement {
    doc /* Abb. 1.2 (dort "Einkauf / Management"): Interesse "Kosten
           kontrollieren".
           7.3 (dort "Management"): Interesse "Kosten kontrollieren";
           moegliche Anforderung "Komponenten begruendet
           auswaehlen". */
  }

  part def Reinigungspersonal {
    doc /* Abb. 1.2: Interesse "nicht behindert werden". In 7.3 nicht
           gesondert aufgefuehrt. */
  }

  part def ITAdministration {
    doc /* Abb. 1.2: Interesse "Netzwerk absichern" (vgl. auch 1.7:
           "Wie wird der Roboter ins Netzwerk eingebunden?"). In 7.3
           nicht gesondert aufgefuehrt. */
  }

  // ---------------------------------------------------------------
  // Weitere Kontextelemente (Kapitel 1.8.3 "Kontext des Systems")
  //
  // Außerhalb der Systemgrenze liegt laut 1.8.3 der Systemkontext:
  // externe Akteure und Systeme, mit denen der Roboter interagiert.
  // ChargingStation ist bereits in AutonomousIndoorRobot definiert
  // (Kapitel 4, Variante "externes System", vgl. 1.8.2) und wird hier
  // nur referenziert.
  // ---------------------------------------------------------------

  part def Gebaeudeinfrastruktur {
    doc /* 1.8.3: "Tueren, Aufzuege, Flure und Raeume". */
  }

  part def Netzwerk {
    doc /* 1.8.3: "WLAN oder anderes Netzwerk". */
  }

  part def Bedienoberflaeche {
    doc /* 1.8.3: "Bedienoberflaeche auf Tablet oder PC". */
  }

  part def Wartungswerkzeug {
    doc /* 1.8.3: "Wartungswerkzeug". */
  }

  part def Gebaeudemanagementsystem {
    doc /* 1.8.3: "Gebaeudemanagementsystem". */
  }

  // 1.8.3 nennt zusaetzlich "rechtliche und organisatorische
  // Vorgaben" als Teil des Kontexts. Das Buch beschreibt diese nicht
  // als eigenes System oder Akteur, sondern als Randbedingung; sie
  // wird hier daher bewusst nicht als part def modelliert, sondern
  // bleibt offen.

  // ---------------------------------------------------------------
  // Systemkontext: Robot im Zentrum, umgeben von Stakeholdern und
  // externen Systemen/Akteuren.
  // ---------------------------------------------------------------

  part indoorRobotContext {
    doc /* Gesamtkontext des betrachteten Systems (Robot, aus
           AutonomousIndoorRobot) mit allen Stakeholdern aus 1.7/7.3
           und den externen Systemen aus 1.8.3. */

    part robot : Robot;

    part nutzer : Nutzer;
    part personImGebaeude : PersonImGebaeude;
    part betreiber : Betreiber;
    part wartungspersonal : Wartungspersonal;
    part entwicklung : Entwicklung;
    part sicherheitsbeauftragte : Sicherheitsbeauftragte;
    part datenschutzverantwortliche : Datenschutzverantwortliche;
    part einkaufManagement : EinkaufManagement;
    part reinigungspersonal : Reinigungspersonal;
    part itAdministration : ITAdministration;

    part chargingStation : ChargingStation;
    part gebaeudeinfrastruktur : Gebaeudeinfrastruktur;
    part netzwerk : Netzwerk;
    part bedienoberflaeche : Bedienoberflaeche;
    part wartungswerkzeug : Wartungswerkzeug;
    part gebaeudemanagementsystem : Gebaeudemanagementsystem;
  }

  // ---------------------------------------------------------------
  // Use Cases (Kapitel 7.4 "Use Cases" bis 7.9 "Praxisleitfaden")
  //
  // 7.9 nennt sechs Use Cases fuer ein Einsteigermodell; 7.5
  // beschreibt "Ziel anfahren" (dort auch "Ziel autonom anfahren"
  // genannt, 7.9) im Detail mit Vorbedingung, Ablauf, Alternativen
  // und Ergebnis. Abbildung 7.1 zeigt die sechs Use Cases mit den
  // Akteuren Nutzer, Sicherheitsverantwortliche und Wartungspersonal;
  // da die Textextraktion des Diagramms die genauen Verbindungslinien
  // nicht eindeutig wiedergibt, sind einzelne Akteurzuordnungen unten
  // nach Position/Inhalt sinngemaess uebernommen und entsprechend
  // gekennzeichnet. Kapitel 7.7 stellt klar, dass dieses Buch bei Use
  // Cases bewusst auf Text und Diagramm setzt und die formale
  // SysML-v2-Textsyntax nicht vertieft; die folgenden use case def
  // nutzen dennoch die SysML-v2-Grundsyntax (actor/subject), um die
  // im Buch beschriebenen Inhalte modellhaft festzuhalten.
  // ---------------------------------------------------------------

  use case def ZielAnfahren {
    doc /* 7.5 "Beispiel: Ziel anfahren" (= "Ziel autonom anfahren"
           in der Liste aus 7.9).
           Akteur: Nutzer.
           Ziel: Roboter faehrt zu einem ausgewaehlten Zielpunkt.
           Vorbedingung: Roboter ist eingeschaltet, lokalisiert und
           besitzt ausreichend Akkuladung.
           Ablauf: (1) Nutzer waehlt Ziel, (2) Roboter prueft
           Verfuegbarkeit der Karte, (3) Roboter prueft Akkustand,
           (4) Roboter plant Pfad, (5) Roboter faehrt los,
           (6) Roboter weicht Hindernissen aus oder stoppt sicher,
           (7) Roboter erreicht Ziel, (8) Roboter meldet Abschluss.
           Alternativen: Ziel nicht erreichbar, Akkustand zu niedrig,
           Hindernis blockiert Pfad.
           Ergebnis: Auftrag ist abgeschlossen oder nachvollziehbar
           abgebrochen.
           Laut 7.6 fuehrt dieser Use Case zu Anforderungen an
           Zielauswahl, Kartennutzung, Lokalisierung, Pfadplanung,
           Hinderniserkennung, Statusmeldung und Fehlerbehandlung. */

    actor nutzer : Nutzer;
    subject robot : Robot;
  }

  use case def TransportauftragStarten {
    doc /* 7.9: erster Use Case des Einsteigermodells. Der Nutzer
           startet einen Transportauftrag (Bedienung). */

    actor nutzer : Nutzer;
    subject robot : Robot;
  }

  use case def HindernisBehandeln {
    doc /* 7.9: Der Roboter behandelt ein erkanntes Hindernis
           (vgl. Ablaufschritt 6 in "Ziel anfahren", 7.5: weicht aus
           oder stoppt sicher). Das Buch nennt fuer diesen Use Case
           keinen expliziten menschlichen Akteur; er ist Teil der
           Gruppe "Sicherheit" (7.9). */

    subject robot : Robot;
  }

  use case def ZurLadestationZurueckkehren {
    doc /* 7.9: "Zur Ladestation zurueckkehren". Uebung 1 (7.12)
           fordert ausdruecklich, diesen Use Case auszuformulieren
           und mindestens drei Anforderungen daraus abzuleiten -- das
           Buch selbst laesst Vorbedingung, Ablauf und Alternativen
           an dieser Stelle bewusst offen und gibt sie (anders als bei
           "Ziel anfahren") nicht vor. Hier daher nur mit den im Buch
           genannten Eckpunkten modelliert: externes System
           ChargingStation ist beteiligt (vgl. Kapitel 16.7
           Traceability-Kette zu REQ-006). */

    subject robot : Robot;
    part chargingStation : ChargingStation;
  }

  use case def FehlerDiagnostizieren {
    doc /* 7.9: "Fehler diagnostizieren", fuehrt zu Anforderungen an
           Statusmeldungen, Logdaten und Wartungszugriff. Akteur laut
           Abbildung 7.1: Wartungspersonal. */

    actor wartungspersonal : Wartungspersonal;
    subject robot : Robot;
  }

  use case def RoboterAusserBetriebNehmen {
    doc /* 7.9: "Roboter ausser Betrieb nehmen", fuehrt zu
           Anforderungen an sichere Abschaltung und klare
           Bedienrueckmeldung. Akteur laut Abbildung 7.1:
           Sicherheitsverantwortliche. */

    actor sicherheitsbeauftragte : Sicherheitsbeauftragte;
    subject robot : Robot;
  }
}
