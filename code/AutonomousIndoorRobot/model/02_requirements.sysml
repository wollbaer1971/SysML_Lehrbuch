package Requirements {

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
}
