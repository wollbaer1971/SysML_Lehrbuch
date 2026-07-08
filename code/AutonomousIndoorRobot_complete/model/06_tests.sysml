package Tests {
  doc
  /* Testfaelle und Verifikationsbeziehungen (Kapitel 19 "Test und
     Verifikation", S. 130-136).

     Kapitel-4-Basisversion (unveraendert uebernommen): verification def
     TC_BatteryLowReturn und TC_ObstacleStop mit der Verifikationsbeziehung
     im part robot-Block.

     Ergaenzung aus Kapitel 19: Tabelle 19.3 (S. 132) listet acht Testfaelle
     TC-001 bis TC-008 mit ihren verifizierten Anforderungen REQ-001 bis
     REQ-008. Von diesen acht Testfaellen lassen sich nur die folgenden auf
     tatsaechlich in 02_requirements.sysml definierte Anforderungen
     abbilden:
       TC-001 Autonome Navigation zu Zielpunkt  -> REQ_Navigate
       TC-002 Hindernis rechtzeitig erkennen    -> REQ_DetectObstacles
       TC-003 Hindernis sicher behandeln        -> REQ_StopSafely
                                                    (= TC_ObstacleStop unten)
       TC-005 Niedrigen Akkustand melden        -> REQ_MonitorBattery
       TC-006 Zur Ladestation fahren            -> REQ_ReturnToDock
                                                    (= TC_BatteryLowReturn unten)
     TC-004 (Person im Kamerabild erkennen, REQ-004), TC-007 (Betriebs-
     zustand melden, REQ-007) und TC-008 (Sensorausfall sicher behandeln,
     REQ-008) verifizieren Anforderungen, die im Requirements-Modell
     dieses Projekts (02_requirements.sysml) nicht als eigene requirement-
     Elemente definiert sind. Diese drei Testfaelle werden daher hier
     bewusst NICHT modelliert, um keine Anforderungen zu erfinden, die im
     Buch fuer dieses Projekt nicht definiert wurden. */

  import Requirements::*;

  verification def TC_BatteryLowReturn {
    doc /* Test: Roboter kehrt bei niedrigem Akkustand zurueck.
        Vorbedingung: Roboter navigiert, Akkustand betraegt 25 Prozent.
        Aktion: Akkustand sinkt auf 18 Prozent.
        Erwartung: Roboter bricht Navigation ab und faehrt Ladestation an.
        Akzeptanzkriterium: Ladestation erreicht innerhalb von 120 Sekunden.

        Entspricht TC-006 "Zur Ladestation fahren" aus Tabelle 19.3
        (S. 132) und dem Beispiel in Abschnitt 19.7 / Abbildung 19.2
        (S. 134), das dort REQ-006 zuordnet. */
  }

  verification def TC_ObstacleStop {
    doc /* Test: Roboter haelt vor Hindernis an.
        Vorbedingung: Roboter faehrt mit 0,3 m/s.
        Aktion: Hindernis erscheint in 0,4 m Abstand.
        Erwartung: Roboter bremst und stoppt innerhalb von 0,2 m Sicherheitsabstand.
        Akzeptanzkriterium: Keine Kollision, Stopp in weniger als 2 Sekunden.

        Entspricht TC-003 "Hindernis sicher behandeln" aus Tabelle 19.3
        (S. 132). */
  }

  // Ergaenzung aus Abschnitt 19.3/19.5 (S. 132f.): weitere im Buch
  // genannte Testfaelle, soweit sie auf in 02_requirements.sysml
  // definierte Anforderungen verweisen.

  verification def TC_Navigate {
    doc /* TC-001 "Autonome Navigation zu Zielpunkt" (Tabelle 19.3,
        S. 132). Das Buch nennt fuer TC-001 nur ID, Testfallname und die
        verifizierte Anforderung REQ-001; Vorbedingungen, Ablauf und
        Akzeptanzkriterium werden dort nicht ausgefuehrt und daher hier
        nicht erfunden. */
  }

  verification def TC_DetectObstacle {
    doc /* TC-002 "Hindernis rechtzeitig erkennen" (Tabelle 19.3, S. 132),
        detailliert in Abschnitt 19.5 "Beispiel TC-002" (S. 133):
        Vorbedingung: Roboter faehrt mit definierter Geschwindigkeit.
        Ablauf: Hindernis wird in den Fahrweg gestellt.
        Erwartung: Roboter erkennt Hindernis und stoppt vor Kollision.
        Kriterium: Mindestabstand 20 cm. */
  }

  verification def TC_MonitorBattery {
    doc /* TC-005 "Niedrigen Akkustand melden" (Tabelle 19.3, S. 132).
        Vgl. Abschnitt 19.6.2 "Integrationstests" (S. 133): Beispielhaft
        meldet battery_monitor_node einen niedrigen Akkustand, und
        navigation_node plant daraufhin die Rueckkehr zur Ladestation.
        Detaillierte Vorbedingungen und Akzeptanzkriterien nennt das Buch
        an dieser Stelle nicht. */
  }

  // Abschnitt 19.7 "Tests im Modell" (S. 134) zeigt zusaetzlich eine
  // eigene SysML-v2-Schreibweise mit test def und der Beziehung
  // "verify requirement", woertlich:
  //   package Tests {
  //     import Requirements::*;
  //     test def TC_006 {
  //       doc /* Prueft, ob der Roboter bei niedrigem Akkustand
  //             selbststaendig zur Ladestation faehrt. */
  //       verify requirement REQ_006;
  //     }
  //   }
  // Diese Schreibweise wird hier als eigenstaendiges, zusaetzliches
  // Element uebernommen (mit dem in diesem Projekt tatsaechlich
  // definierten Anforderungsnamen REQ_ReturnToDock anstelle des im Buch
  // generischen REQ_006). Inhaltlich beschreibt sie denselben Testfall
  // wie TC_BatteryLowReturn oben, hier jedoch in der in Abbildung 19.2
  // gezeigten Notation mit inline verify-Beziehung.
  test def TC_006 {
    doc /* Prueft, ob der Roboter bei niedrigem Akkustand
          selbststaendig zur Ladestation faehrt. */
    verify requirement REQ_ReturnToDock;
  }

  part robot : Robot {
    verify REQ_Navigate by tc0 : TC_Navigate;
    verify REQ_DetectObstacles by tcDet : TC_DetectObstacle;
    verify REQ_ReturnToDock by tc1 : TC_BatteryLowReturn;
    verify REQ_StopSafely by tc2 : TC_ObstacleStop;
    verify REQ_MonitorBattery by tcMon : TC_MonitorBattery;
  }
}
