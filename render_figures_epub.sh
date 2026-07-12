#!/usr/bin/env bash
# render_figures_epub.sh – rendert alle figures/*.tikz als 300dpi-PNG fuer
# das eBook (KDP/BoD). Wird von build_epub.sh vor dem Pandoc-Lauf
# aufgerufen. Ueberspringt bereits gerenderte, unveraenderte Dateien
# (PNG neuer als .tikz), damit wiederholte Aufrufe schnell sind.
#
# Aufruf: bash render_figures_epub.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

OUT_DIR="figures_epub"
TMP_DIR="/tmp/figrender_$$"
mkdir -p "$OUT_DIR" "$TMP_DIR"

count_total=0
count_rendered=0
count_skipped=0
count_failed=0
failed_list=()

for tikz in figures/fig_*.tikz; do
    base="$(basename "$tikz" .tikz)"
    count_total=$((count_total + 1))
    png="$OUT_DIR/$base.png"

    if [ -f "$png" ] && [ "$png" -nt "$tikz" ]; then
        count_skipped=$((count_skipped + 1))
        continue
    fi

    work="$TMP_DIR/$base"
    mkdir -p "$work"
    cat > "$work/standalone.tex" << EOF
\documentclass[tikz,border=4pt]{standalone}
\usepackage[utf8]{inputenc}
\usepackage[T1]{fontenc}
\usepackage{lmodern}
\usetikzlibrary{positioning,arrows.meta,shadows,calc,quotes,backgrounds}
\begin{document}
\pagecolor{white}
\input{$SCRIPT_DIR/$tikz}
\end{document}
EOF

    if pdflatex -interaction=nonstopmode -halt-on-error \
        -output-directory="$work" "$work/standalone.tex" \
        > "$work/compile.log" 2>&1; then
        if pdftocairo -png -r 300 -singlefile "$work/standalone.pdf" "$OUT_DIR/$base" \
            >> "$work/compile.log" 2>&1; then
            count_rendered=$((count_rendered + 1))
        else
            count_failed=$((count_failed + 1))
            failed_list+=("$base (pdftocairo)")
        fi
    else
        count_failed=$((count_failed + 1))
        failed_list+=("$base (pdflatex, siehe $work/compile.log)")
    fi
done

echo "── Diagramm-Rendering fertig ──────────────────────────────────"
echo "   Gesamt:     $count_total"
echo "   Gerendert:  $count_rendered"
echo "   Uebersprungen (aktuell): $count_skipped"
echo "   Fehlgeschlagen: $count_failed"

if [ "$count_failed" -gt 0 ]; then
    echo ""
    echo "   FEHLGESCHLAGEN:"
    for f in "${failed_list[@]}"; do
        echo "     - $f"
    done
    exit 1
fi

exit 0
