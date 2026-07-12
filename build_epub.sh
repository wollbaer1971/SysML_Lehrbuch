#!/usr/bin/env bash
# build_epub.sh – SysML_Lehrbuch als EPUB bauen
#
# Voraussetzungen:
#   - pandoc  (getestet mit 2.9+)
#   - python3
#
# Aufruf: bash build_epub.sh
# Ergebnis: SysML_Lehrbuch_neu.epub im gleichen Verzeichnis

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

OUTPUT="SysML_Lehrbuch_neu.epub"
MERGED="/tmp/sysml_merged.tex"
COVER="Cover_ebook.jpg"
FILTER="epub_filter.lua"
CSS="epub.css"

echo "── Schritt 0: TikZ-Diagramme als PNG rendern ──────────────────"
bash render_figures_epub.sh

echo ""
echo "── Schritt 1: LaTeX-Quellen vorverarbeiten ───────────────────"
python3 preprocess.py > "$MERGED"
echo "   Merged: $MERGED ($(wc -l < "$MERGED") Zeilen)"

# Sicherheitsnetz: preprocess.py bricht selbst mit Exit 1 ab, wenn ein PNG
# fehlt oder ein rohes tikzpicture uebrig bleibt. Zusaetzlich hier pruefen,
# falls die Merge-Datei trotzdem (leer/fehlerhaft) entstanden ist.
if [ ! -s "$MERGED" ]; then
    echo "FEHLER: $MERGED ist leer oder wurde nicht erzeugt. Abbruch." >&2
    exit 1
fi

echo ""
echo "── Schritt 2: EPUB mit Pandoc erzeugen ───────────────────────"

PANDOC_ARGS=(
  "$MERGED"
  --from=latex
  --output="$OUTPUT"
  --lua-filter="$FILTER"
  --css="$CSS"
  --epub-cover-image="$COVER"
  --metadata="title:SysML v2, MBSE und ROS2 für Einsteiger"
  --metadata="author:Wolfgang Becker"
  --metadata="lang:de"
  --metadata="publisher:Eigenverlag"
  --toc
  --toc-depth=2
  --standalone
)

pandoc "${PANDOC_ARGS[@]}"

echo ""
echo "── Fertig! ───────────────────────────────────────────────────"
echo "   Ausgabe: $SCRIPT_DIR/$OUTPUT"
echo "   Größe:   $(du -h "$OUTPUT" | cut -f1)"
