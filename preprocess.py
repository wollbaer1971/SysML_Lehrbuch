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

PREAMBLE = r"""\documentclass{book}
\usepackage[ngerman]{babel}
\usepackage[T1]{fontenc}
\usepackage[utf8]{inputenc}
\usepackage{listings}
\usepackage{hyperref}
\lstdefinestyle{code}{basicstyle=\ttfamily\small,breaklines=true}
\lstset{style=code}
\begin{document}
"""

TIKZ_PLACEHOLDER = "\n\\emph{[Diagramm: siehe Druckversion]}\n"

def replace_box_env(content, env_name):
    pattern = re.compile(
        r"\\begin\{" + re.escape(env_name) + r"\}(.*?)\\end\{" + re.escape(env_name) + r"\}",
        re.DOTALL)
    def repl(m):
        return "\\begin{quote}\\textbf{" + env_name + "}\n\n" + m.group(1) + "\\end{quote}"
    return pattern.sub(repl, content)

def replace_tikz(content):
    # Mit umgebendem center-Block
    content = re.sub(
        r"\\begin\{center\}\s*\\begin\{tikzpicture\}.*?\\end\{tikzpicture\}\s*\\end\{center\}",
        lambda m: TIKZ_PLACEHOLDER, content, flags=re.DOTALL)
    # Ohne center
    content = re.sub(
        r"\\begin\{tikzpicture\}.*?\\end\{tikzpicture\}",
        lambda m: TIKZ_PLACEHOLDER, content, flags=re.DOTALL)
    return content

def clean_unsupported(content):
    content = re.sub(r"\\index\{[^}]*\}", "", content)
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
    content = replace_tikz(content)
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
