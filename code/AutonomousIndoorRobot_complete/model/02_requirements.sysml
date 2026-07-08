package Requirements {

  // ---------------------------------------------------------------
  // Einstiegsanforderungen (Kapitel 4.6 "Anforderungen formulieren")
  // Unveraendert uebernommen, damit bestehende Referenzen (z. B. in
  // 03_structure.sysml) gueltig bleiben.
  // ---------------------------------------------------------------

  requirement REQ_Navigate {
    doc /* Der Roboter muss in einem bekannten Innenraumbereich
           autonom ein ausgewaehltes Ziel anfahren koennen. */
  }

  requirement REQ_Safety {
    doc /* Sicherheitsanforderungen fuer den Betrieb
           in der Naehe von Personen. */

    requirement REQ_DetectObstacles {
      doc /* Der Roboter muss Hindernisse im Fahrweg erkennen. */
    }

    requirement REQ_StopSafely {
      doc /* Der Roboter muss bei einem Hindernis in 0,5 m
             Abstand bremsen und bei 0,2 m stoppen. */
    }
  }

  requirement REQ_Battery {
    doc /* Akkumanagement und Energieversorgung. */

    requirement REQ_MonitorBattery {
      doc /* Der Roboter muss seinen Akkustand kontinuierlich
             ueberwachen. */
    }

    requirement REQ_ReturnToDock {
      doc /* Der Roboter muss bei einem Akkustand unter 20 Prozent
             selbststaendig zur Ladestation fahren. */
    }
  }

  // ---------------------------------------------------------------
  // Durchgaengiges Praxisbeispiel des Buches: numerische Anforderungs-
  // IDs REQ-001 bis REQ-010 (Tabelle in Kapitel 6.4 "Beispielanforder-
  // ungen") und die hierarchischen Sicherheitsanforderungen REQ-SAFE-001
  // bis REQ-SAFE-004 (Kapitel 6.6 "Anforderungen strukturieren").
  // SysML-Schreibweise (REQ_XXX statt REQ-XXX) wie im Codebeispiel aus
  // Kapitel 6.8. Dieselben IDs werden im Buch in Kapitel 16 (Mapping auf
  // ROS2), Kapitel 19 (Testfaelle TC-001 bis TC-008) und Kapitel 20
  // (Traceability-Matrix) durchgaengig weiterverwendet. Die bestehenden
  // Anforderungen oben (REQ_Navigate, REQ_Safety, REQ_Battery) bleiben
  // unveraendert und unbenannt bestehen; das Buch selbst fuehrt beide
  // Benennungsschemata parallel.
  // ---------------------------------------------------------------

  import Structure::PerceptionSystem;

  requirement REQ_SAFE {
    doc /* Kapitel 6.6: uebergeordnete Sicherheitsanforderung, in
           vier konkrete Anforderungen zerlegt (REQ-SAFE-001 bis
           REQ-SAFE-004). Die Schachtelung ist laut 6.8 eine reine
           Namensraum-Gruppierung ohne automatische derive-Beziehung. */

    requirement REQ_SAFE_001 {
      doc /* REQ-SAFE-001 (6.6): Der Roboter muss sicher in der Naehe
             von Menschen betrieben werden. */

      // Wie im Codebeispiel aus Kapitel 6.8 woertlich gezeigt:
      derive REQ_001;
    }

    requirement REQ_SAFE_002 {
      doc /* REQ-SAFE-002 (6.6): Der Roboter muss Hindernisse im
             Fahrweg erkennen. */
    }

    requirement REQ_SAFE_003 {
      doc /* REQ-SAFE-003 (6.6): Der Roboter muss bei Gefahr stoppen. */
    }

    requirement REQ_SAFE_004 {
      doc /* REQ-SAFE-004 (6.6): Der Roboter muss bei Sensorausfall
             einen sicheren Zustand einnehmen. */
    }
  }

  requirement REQ_001 {
    doc /* REQ-001 (6.4): Der Roboter muss autonom in einem bekannten
           Innenraumbereich navigieren koennen. Verifiziert durch
           TC-001 "Autonome Navigation zu Zielpunkt" (19.3). */
  }

  requirement REQ_002 {
    doc /* REQ-002 (6.4): Der Roboter muss Hindernisse im Fahrbereich
           erkennen. Praxisbeispiel (6.7/20.3): wird durch das
           PerceptionSystem erfuellt und durch TC-002 "Hindernis
           rechtzeitig erkennen" verifiziert; zusaetzlich zeigt eine
           trace-Beziehung im Buch den ROS2-Node
           obstacle_detector_node -- dieser liegt ausserhalb des
           SysML-Modells und wird hier bewusst nicht nachgebildet. */
  }

  // Woertlich wie im Codebeispiel aus Kapitel 20.3, dort direkt im
  // Anschluss an die Requirement-Definitionen notiert:
  satisfy requirement REQ_002 by PerceptionSystem;
  derive requirement REQ_002 from REQ_SAFE_002;

  requirement REQ_003 {
    doc /* REQ-003 (6.4): Der Roboter muss erkannte Hindernisse
           umfahren oder rechtzeitig stoppen. Verifiziert durch
           TC-003 "Hindernis sicher behandeln" (19.3). */
  }

  requirement REQ_004 {
    doc /* REQ-004 (6.4): Der Roboter muss Personen im Kamerabild
           erkennen koennen. Praxisbeispiel (16.6): wird durch die
           Part Definition ObjectDetector erfuellt, umgesetzt durch
           den ROS2-Node object_detector_node und ueber
           /detected_objects veroeffentlicht. Verifiziert durch
           TC-004 "Person im Kamerabild erkennen" (19.3). */
  }

  requirement REQ_005 {
    doc /* REQ-005 (6.4): Der Roboter muss seinen Akkustand
           ueberwachen. Verifiziert durch TC-005 "Niedrigen Akkustand
           melden" (19.3). */
  }

  requirement REQ_006 {
    doc /* REQ-006 (6.4): Der Roboter muss bei niedrigem Akkustand
           selbststaendig zur Ladestation fahren. Kapitel 16.7 zeigt
           die vollstaendige Traceability-Kette: Action "Akkustand
           ueberwachen" -> Part Definition BatterySystem -> Node
           battery_monitor_node -> Topic /battery_state -> Node
           navigation_node -> Action NavigateToDock -> Test TC-006
           "Rueckkehr bei niedrigem Akkustand". Verifiziert durch
           TC-006 "Zur Ladestation fahren" (19.3). Beteiligte
           Systemteile laut Kapitel 8.7 Praxisbeispiel: BatterySystem,
           NavigationSystem, MotionControl und moeglicherweise
           UserInterface. */
  }

  requirement REQ_007 {
    doc /* REQ-007 (6.4): Der Roboter muss seinen Betriebszustand
           melden. Verifiziert durch TC-007 "Betriebszustand melden"
           (19.3). Vgl. auch 7.3: Stakeholder "Betreiber" moechte
           Betriebszustand jederzeit angezeigt bekommen. */
  }

  requirement REQ_008 {
    doc /* REQ-008 (6.4): Der Roboter muss einen sicheren Zustand
           einnehmen, wenn ein kritischer Sensor ausfaellt.
           Verifiziert durch TC-008 "Sensorausfall sicher behandeln"
           (19.3). */
  }

  requirement REQ_009 {
    doc /* REQ-009 (6.4): Der Roboter muss Transportauftraege ueber
           eine einfache Benutzerschnittstelle entgegennehmen. Vgl.
           auch 7.3: Stakeholder "Nutzer" moechte einen Auftrag mit
           hoechstens drei Eingaben starten koennen. */
  }

  requirement REQ_010 {
    doc /* REQ-010 (6.4): Der Roboter muss relevante Fehler fuer
           Wartungspersonal nachvollziehbar protokollieren. Vgl. auch
           7.3: Stakeholder "Wartung" moechte Diagnoseinformationen
           bereitgestellt bekommen. */
  }

  // Zu REQ-SAFE-003 und REQ-SAFE-004 sowie zu REQ_003, REQ_005 und
  // REQ_007 bis REQ_010 nennt das Buch keine expliziten satisfy-,
  // derive- oder verify-Codebeispiele (anders als bei REQ_SAFE_001 und
  // REQ_002). Diese Beziehungen werden hier daher bewusst nicht
  // erfunden, sondern bleiben offen.
}
