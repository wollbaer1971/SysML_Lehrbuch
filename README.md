# SysML_Lehrbuch

LaTeX-Lehrbuch für Einsteiger: **SysML v2, MBSE und ROS2** am Beispiel eines autonomen Indoor-Roboters.

Status: alle 22 Kapitel inhaltlich fertiggestellt, Qualitätskontrolle läuft (siehe `Qualitaetskontrolle_SysML_Lehrbuch.docx`).

## Struktur

```text
SysML_Lehrbuch/
├── main.tex                 # Hauptdokument (scrbook, deutsch)
├── glossary.tex              # Glossar- und Abkürzungseinträge
├── references.bib            # Literaturverzeichnis
├── chapters/                  # 22 Kapitel (01–22, siehe unten)
├── figures/                    # TikZ-Abbildungen (.tikz + Wrapper .tex), ca. 40 Abbildungen
├── tables/
├── code/
│   ├── robot.sysml
│   ├── AutonomousIndoorRobot/          # Praxisprojekt, Lernstand (Kapitel-Begleitmaterial)
│   └── AutonomousIndoorRobot_complete/  # Praxisprojekt, vollständige Referenzlösung
├── build_epub.sh + preprocess.py + epub_filter.lua + epub.css   # EPUB-Build-Kette
├── Cover_ebook.jpg / Cover_ebook_korr.jpg / Cover_ChatGPT_korr.png  # Cover-Varianten
├── Amazon_KDP_Buchbeschreibung.html    # Produktbeschreibung für KDP
├── Qualitaetskontrolle_SysML_Lehrbuch.docx  # Laufende QS-Notizen
├── README.md
└── .gitignore
```

## Kapitelübersicht

1. Systems Engineering verstehen
2. Einführung in Model-Based Systems Engineering
3. SysML-Grundlagen
4. Werkzeuge für SysML v2 einrichten
5. Das Praxisprojekt: Autonomer Indoor-Roboter
6. Anforderungen modellieren
7. Stakeholder und Use Cases
8. Strukturmodellierung mit `part def`
9. Verbindungsmodellierung mit `port` und `connection`
10. Schnittstellenmodellierung
11. Verhaltensmodellierung mit Activity Diagrams
12. Zustandsmodellierung mit State Machines
13. Parametrische Modellierung
14. ROS2-Grundlagen
15. Architektur von ROS2-Systemen
16. Von SysML v2 zu ROS2
17. ROS2-Implementierung mit Python
18. Machine Learning in ROS2 integrieren
19. Test und Verifikation
20. Traceability und Änderungsmanagement
21. Abschlussprojekt
22. Ausblick

## Praxisprojekt-Code

`code/` enthält das durchgängige Beispiel (autonomer Indoor-Roboter) als lauffähige SysML-v2-Modelle und ROS2-Python-Nodes:

- `AutonomousIndoorRobot/` – Zwischenstand, wie er sich kapitelweise im Buch aufbaut.
- `AutonomousIndoorRobot_complete/` – vollständige Referenzlösung (Modell + `battery_monitor_node.py`, `safety_watchdog_node.py`, `status_node.py`, `docs/decisions.md`).

Beide Projekte gliedern sich in `model/00_overview.sysml` bis `07_ros2_mapping.sysml` sowie `code/` und `docs/`.

Alle SysML-v2-Codebeispiele wurden mit dem Syside Editor geprüft (Version 0.10.2, Stand 07.07.2026).

## Nutzung in Overleaf

1. ZIP-Datei in Overleaf hochladen.
2. `main.tex` als Hauptdatei setzen.
3. Compiler: `pdfLaTeX`.
4. Für Glossar/Abkürzungen gegebenenfalls `makeglossaries` aktivieren oder mehrfach kompilieren.

## Lokal kompilieren (PDF)

```bash
pdflatex main.tex
bibtex main
makeglossaries main
pdflatex main.tex
pdflatex main.tex
```

## EPUB bauen

```bash
bash build_epub.sh
```

Voraussetzungen: `pandoc` (≥2.9), `python3`. Das Skript wandelt die LaTeX-Quellen über `preprocess.py` und `epub_filter.lua` in `SysML_Lehrbuch_neu.epub` um (Cover: `Cover_ebook.jpg`).

## Veröffentlichung

- `Amazon_KDP_Buchbeschreibung.html` – Produktbeschreibung für den KDP-Eintrag.
- `Cover_ebook_korr.jpg`, `Cover_ChatGPT_korr.png` – aktuelle Cover-Varianten für Print/E-Book.
- `SysML_Lehrbuch.epub` / `SysML_Lehrbuch_neu.epub` – gebaute EPUB-Stände.

## Zielgruppe

Einsteiger ohne Vorkenntnisse in SysML v2, MBSE oder ROS2.

## Inhalt

Das Lehrbuch behandelt:
- Systems Engineering
- MBSE
- SysML-v2-Grundlagen
- kostenlose SysML-v2-Werkzeuge mit VS Code, Syside Editor und optional SysON
- Anforderungen
- Struktur- und Schnittstellensichten
- Verhaltensmodellierung
- ROS2-Grundlagen
- Mapping von SysML auf ROS2
- Python-Nodes
- ML-Integration
- Tests und Traceability
