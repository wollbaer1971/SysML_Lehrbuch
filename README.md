# SysML_Lehrbuch

LaTeX-Lehrbuch für Einsteiger: **SysML v2, MBSE und ROS2** am Beispiel eines autonomen Indoor-Roboters.

## Struktur

```text
SysML_Lehrbuch/
├── main.tex
├── glossary.tex
├── references.bib
├── chapters/
│   ├── 01_systems_engineering.tex
│   ├── ...
│   └── 22_ausblick.tex
├── figures/
├── tables/
├── code/
├── README.md
└── .gitignore
```

## Nutzung in Overleaf

1. ZIP-Datei in Overleaf hochladen.
2. `main.tex` als Hauptdatei setzen.
3. Compiler: `pdfLaTeX`.
4. Für Glossar/Abkürzungen gegebenenfalls `makeglossaries` aktivieren oder mehrfach kompilieren.

## Lokal kompilieren

```bash
pdflatex main.tex
bibtex main
makeglossaries main
pdflatex main.tex
pdflatex main.tex
```

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
