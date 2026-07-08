package AutonomousIndoorRobot {
  doc
  /* Ziel: Ein autonomer Indoor-Roboter transportiert kleine
     Gegenstaende innerhalb eines Gebaeudes zu ausgewaehlten Zielen.
     Er faehrt selbststaendig, erkennt Hindernisse und kehrt bei
     niedrigem Akkustand zur Ladestation zurueck.

     Umfang: Dieses Modell beschreibt Navigation, Wahrnehmung,
     Energieversorgung, Bedienung und Sicherheit des Roboters.

     Systemgrenze: Zur Ladestation und zum Gebaeude gehoert die
     physische Infrastruktur, die der Roboter nutzt, aber nicht
     selbst steuert. Personen sind externe Akteure. */

  part def Robot;
  part def ChargingStation; // extern, aber modellrelevant
}
