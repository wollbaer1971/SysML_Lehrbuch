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
#
# Seit 2026-07-17 nutzt Kapitel 11 statt \resizebox einen \adjustbox-Wrapper
# (max width=..., max totalheight=...) fuer ein sehr hohes Diagramm, siehe
# figures/fig_kap11_aktivitaet_rueckkehr_ladestation.tikz. Seit 2026-07-19
# wrappt Kapitel 3 zusaetzlich eine Tabelle (nicht nur eine Abbildung) in
# \adjustbox{max width=\linewidth}{...\begin{tabular}...\end{tabular}}. Eine
# feste Regex, die nur \includegraphics als Inhalt kennt, erkennt diesen
# Fall nicht und preprocess.py bricht (bewusst laut, siehe
# check_no_raw_tikz) mit "enthaelt noch ein \adjustbox" ab. Deshalb hier
# generisch mit Klammer-Balancierung: findet \resizebox/\adjustbox, ueber-
# springt die Dimensions-/Options-Gruppe(n) und behaelt nur den Inhalt der
# letzten Gruppe - unabhaengig davon, ob darin \includegraphics, eine
# Tabelle oder sonstiger LaTeX-Inhalt mit eigenen geschweiften Klammern
# steht.

def find_matching_brace(s, open_pos):
    """Gibt den Index der zu s[open_pos] ('{') passenden schliessenden
    Klammer zurueck (Klammer-balanciert, verschachtelungssicher)."""
    assert s[open_pos] == "{"
    depth = 0
    for k in range(open_pos, len(s)):
        if s[k] == "{":
            depth += 1
        elif s[k] == "}":
            depth -= 1
            if depth == 0:
                return k
    raise ValueError("Unbalancierte geschweifte Klammern ab Position %d" % open_pos)

def strip_scaling_wrapper(content, macro, skip_groups=1):
    """Entfernt \\macro{...}{...}...{inhalt} und behaelt nur 'inhalt'.
    skip_groups gibt an, wie viele Gruppen vor der Inhaltsgruppe stehen
    (\\adjustbox: 1 Options-Gruppe, \\resizebox: 2 Dimensions-Gruppen)."""
    pattern = "\\" + macro + "{"
    result = []
    i = 0
    while True:
        idx = content.find(pattern, i)
        if idx == -1:
            result.append(content[i:])
            break
        result.append(content[i:idx])
        pos = idx + len(pattern) - 1
        end = find_matching_brace(content, pos)
        for _ in range(skip_groups - 1):
            j = end + 1
            while j < len(content) and content[j] in " \t\n":
                j += 1
            if j >= len(content) or content[j] != "{":
                break
            end = find_matching_brace(content, j)
        j = end + 1
        while j < len(content) and content[j] in " \t\n":
            j += 1
        if j < len(content) and content[j] == "{":
            end2 = find_matching_brace(content, j)
            result.append(content[j + 1:end2])
            i = end2 + 1
        else:
            # Unerwartetes Muster: unveraendert stehen lassen, damit
            # check_no_raw_tikz() das laut meldet statt still zu verlieren.
            result.append(content[idx:end + 1])
            i = end + 1
    return "".join(result)

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
    content = strip_scaling_wrapper(content, "resizebox", skip_groups=2)
    content = strip_scaling_wrapper(content, "adjustbox", skip_groups=1)
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
