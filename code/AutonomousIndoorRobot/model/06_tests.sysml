package Tests {

  verification def TC_BatteryLowReturn {
    doc /* Test: Roboter kehrt bei niedrigem Akkustand zurueck.
        Vorbedingung: Roboter navigiert, Akkustand betraegt 25 Prozent.
        Aktion: Akkustand sinkt auf 18 Prozent.
        Erwartung: Roboter bricht Navigation ab und faehrt Ladestation an.
        Akzeptanzkriterium: Ladestation erreicht innerhalb von 120 Sekunden. */
  }

  verification def TC_ObstacleStop {
    doc /* Test: Roboter haelt vor Hindernis an.
        Vorbedingung: Roboter faehrt mit 0,3 m/s.
        Aktion: Hindernis erscheint in 0,4 m Abstand.
        Erwartung: Roboter bremst und stoppt innerhalb von 0,2 m Sicherheitsabstand.
        Akzeptanzkriterium: Keine Kollision, Stopp in weniger als 2 Sekunden. */
  }

  part robot : Robot {
    verify REQ_ReturnToDock by tc1 : TC_BatteryLowReturn;
    verify REQ_StopSafely by tc2 : TC_ObstacleStop;
  }
}
