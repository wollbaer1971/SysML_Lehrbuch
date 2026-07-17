#!/usr/bin/env python3
import re, os, sys

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
CHAPTERS_DIR = os.path.join(SCRIPT_DIR, "chapters")

CHAPTER_FILES = [
    "01_systems_engineering.tex", "02_mbse.tex", "03_sysml_grundlagen.tex",
    "04_sysml_v2_werkzeuge.tex", "05_praxisprojekt.tex", "06_anforderungen.tex",
    "07_stakeholder_use_cases.tex", "08_bdd.tex", "09_ibd.tex",
    "10_schnittstellen.tex", "11_activity_diagrams.tex", "12_state_machines.tex",
    "13_parametrik.tex", "14_ros2_grundlagen.tex", "15_ros2_architektur.tex",
    "16_sysml_ros2_mapping.tex", "17_ros2_python.tex", "18_ml_integration.tex",
    "19_tests_verifikation.tex", "20_traceability.tex",
    "21_abschlussprojekt.tex", "22_ausblick.tex",
]

BOX_ENVIRONMENTS = ["lernziele", "praxisbox", "hinweisbox", "uebungbox"]

# Verzeichnis mit den vorgerenderten 300dpi-PNGs aus render_figures_epub.sh.
# Muss mit OUT_DIR in render_figures_epub.sh uebereinstimmen.
FIGURES_EPUB_DIR = "figures_epub"

PREAMBLE = r"""\documentclass{book}
\usepackage[ngerman]{babel}
\usepackage[T1]{fontenc}
\usepackage[utf8]{inputenc}
\usepackage{listings}
\usepackage{graphicx}
\usepackage{hyperref}
\lstdefinestyle{code}{basicstyle=\ttfamily\small,breaklines=true}
\lstset{style=code}
\begin{document}
"""

# Erkennt \input{figures/fig_...} (mit oder ohne .tex-Endung), so wie es in
# allen Kapiteln zur Einbindung der TikZ-Abbildungen verwendet wird. Ersetzt
# es durch \includegraphics auf das vorgerenderte PNG, damit Pandoc ein
# echtes Bild einbettet statt (wie bisher) beim Aufloesen von
# \input{...fig.tikz} lautlos zu scheitern, weil Pandocs LaTeX-Reader an
# Include-Pfade automatisch ".tex" anhaengt.
FIGURE_INPUT_RE = re.compile(
    r"\\input\{figures/(fig_[A-Za-z0-9_]+?)(?:\.tex)?\}")

# Manche Kapitel wrappen \input{figures/...} zusaetzlich in
# \resizebox{<b1>}{<b2>}{...}, damit die (fuers Druckformat teils sehr
# breiten) Diagramme im Print auf Textbreite skaliert werden. Pandocs
# LaTeX-Reader kennt \resizebox nicht und ueberspringt den kompletten
# Aufruf samt Inhalt - das hat 4 Diagramme lautlos aus dem eBook entfernt.
# Da \includegraphics bereits eine eigene Breite bekommt, wird der
# resizebox-Wrapper fuers eBook einfach entfernt und nur der Inhalt
# behalten.
RESIZEBOX_RE = re.compile(
    r"\\resizebox\{[^{}]*\}\{[^{}]*\}\{(\\includegraphics\[[^\]]*\]\{[^{}]*\})\}")

# Seit 2026-07-17 nutzt Kapitel 11 statt \resizebox einen \adjustbox-Wrapper
# (max width=..., max totalheight=...) fuer ein sehr hohes Diagramm, siehe
# figures/fig_kap11_aktivitaet_rueckkehr_ladestation.tikz. Gleiches Problem
# wie bei \resizebox: Pandocs LaTeX-Reader kennt \adjustbox nicht und wuerde
# den kompletten Aufruf samt Inhalt stillschweigend verschlucken. Deshalb
# hier analog entfernen und nur das \includegraphics behalten.
ADJUSTBOX_RE = re.compile(
    r"\\adjustbox\{[^{}]*\}\{(\\includegraphics\[[^\]]*\]\{[^{}]*\})\}")

def replace_box_env(content, env_name):
    pattern = re.compile(
        r"\\begin\{" + re.escape(env_name) + r"\}(.*?)\\end\{" + re.escape(env_name) + r"\}",
        re.DOTALL)
    def repl(m):
        return "\\begin{quote}\\textbf{" + env_name + "}\n\n" + m.group(1) + "\\end{quote}"
    return pattern.sub(repl, content)

def replace_figure_inputs(content, source_name):
    def repl(m):
        fig_name = m.group(1)
        png_path = os.path.join(FIGURES_EPUB_DIR, fig_name + ".png")
        if not os.path.exists(os.path.join(SCRIPT_DIR, png_path)):
            sys.stderr.write(
                "FEHLER: " + png_path + " fehlt (referenziert in " +
                source_name + "). Erst 'bash render_figures_epub.sh' "
                "ausfuehren.\n")
            sys.exit(1)
        return r"\includegraphics[width=0.92\linewidth]{" + png_path + "}"
    content = FIGURE_INPUT_RE.sub(repl, content)
    content = RESIZEBOX_RE.sub(r"\1", content)
    content = ADJUSTBOX_RE.sub(r"\1", content)
    return content

def check_no_raw_tikz(content, source_name):
    # Nach replace_figure_inputs sollte kein rohes tikzpicture mehr uebrig
    # sein. Falls doch (z. B. neue Abbildung, die nicht dem
    # \input{figures/...}-Muster folgt), laut scheitern statt die Abbildung
    # still zu verlieren wie im alten Preprocessor.
    if re.search(r"\\begin\{tikzpicture\}", content):
        sys.stderr.write(
            "FEHLER: " + source_name + " enthaelt noch ein rohes "
            "tikzpicture, das nicht ueber figures/*.tikz + "
            "\\input{figures/...} eingebunden ist. Bitte nach figures/ "
            "auslagern (siehe figures/fig_kap02_dokumente_"
            "modellbeziehungen.tex als Vorlage), sonst fehlt die "
            "Abbildung im eBook.\n")
        sys.exit(1)
    if re.search(r"\\resizebox", content):
        sys.stderr.write(
            "FEHLER: " + source_name + " enthaelt noch ein \\resizebox, "
            "das nicht auf ein bekanntes \\includegraphics-Muster passt. "
            "Bitte pruefen, sonst fehlt die Abbildung im eBook.\n")
        sys.exit(1)
    if re.search(r"\\adjustbox", content):
        sys.stderr.write(
            "FEHLER: " + source_name + " enthaelt noch ein \\adjustbox, "
            "das nicht auf ein bekanntes \\includegraphics-Muster passt. "
            "Bitte pruefen, sonst fehlt die Abbildung im eBook.\n")
        sys.exit(1)

def clean_unsupported(content):
    content = re.sub(r"\\index\{[^}]*\}", "", content)
    content = re.sub(r"\\glsdisp\{[^}]*\}\{([^}]+)\}", r"\1", content)
    content = re.sub(r"\\[Gg]ls(?:pl)?\{([^}]+)\}", r"\1", content)
    content = re.sub(r"\\glsfirst\{([^}]+)\}", r"\1", content)
    content = re.sub(r"\\(makeglossaries|makeindex|printglossary|printindex)[^\n]*\n", "\n", content)
    return content

def process_file(filepath):
    with open(filepath, encoding="utf-8") as f:
        content = f.read()
    content = re.sub(r"(?<!\\)%[^\n]*", "", content)
    for env in BOX_ENVIRONMENTS:
        content = replace_box_env(content, env)
    content = replace_figure_inputs(content, os.path.basename(filepath))
    check_no_raw_tikz(content, os.path.basename(filepath))
    content = clean_unsupported(content)
    return content

def build_document():
    parts = [PREAMBLE]
    for fname in CHAPTER_FILES:
        fpath = os.path.join(CHAPTERS_DIR, fname)
        if not os.path.exists(fpath):
            sys.stderr.write("WARNUNG: " + fname + " nicht gefunden\n")
            continue
        parts.append("\n% === " + fname + " ===\n")
        parts.append(process_file(fpath))
    parts.append("\n\\end{document}\n")
    return "\n".join(parts)

if __name__ == "__main__":
    print(build_document())
