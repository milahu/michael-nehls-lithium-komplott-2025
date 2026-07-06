#!/usr/bin/env bash

set -eu

# dst=$(basename "$0" .sh).epub
dst=.

doc_title="$(head -n1 readme.md | sed 's/^#\s*//')"

if false; then
  scan_resolution=600
else
  source 030-measure-page-size.txt
fi

if [ "$dst" != "." ] && [ -e "$dst" ]; then
  echo "error: output exists: $dst"
  exit 1
fi

# downscale to 300 dpi
# 600 dpi -> 300 dpi: 90 MB -> 60 MB
scale=$(python -c "print(300 / $scan_resolution)")

args=(
  hocr-to-epub-fxl
  --output "$dst"
)
if [ "$dst" = "." ]; then
  args+=(
    --output-unpacked
  )
fi

doc_modified=$(
  {
    git show -s --format=%cI HEAD
    stat -c%y 090-ocr | sed -E 's/^([0-9-]+) ([0-9:]+)\.[0-9]+ ([+-][0-9]{2})([0-9]{2})$/\1T\2\3:\4/'
  } |
  LANG=C sort |
  tail -n1
)

args+=(
  --scale "$scale"
  --image-format avif
  --text-format html
  --doc-modified "$doc_modified"
  --color-image-pages 465,466,469
  --doc-title "Das Lithium-Komplott"
  --doc-subtitle "Plädoyer für ein essentielles Spurenelement - Der verbotene Schlüssel zur mentalen Gesundheit"
  --doc-description "Eine medizinische und gesellschaftliche Revolution.

Lithium ist ein Spurenelement,
das seit Urzeiten für die Entwicklung allen Lebens unentbehrlich ist.
Der Mensch bildet da keine Ausnahme.

Aber leider herrscht ein weit verbreiteter Mangel,
der unsere Lebensqualität mindert.
Er führt zu einer Zunahme von Depressionen und Alzheimer-Demenz,
zu vermehrten Einweisungen in psychiatrische Kliniken,
zu mehr gewalttätigem Verhalten,
zu höheren Suizidraten und letztlich sogar zu einer verkürzten Lebenserwartung!

Die fatalen Folgen des Mangels werden uns jedoch als unabänderliche Normalität verkauft,
und gleichzeitig weigern sich die zuständigen Behörden,
die essentielle Bedeutung dieses Spurenelements anzuerkennen.
Perfiderweise sind lithiumhaltige Nahrungsergänzungsmittel in Europa – wie auch in den meisten anderen Ländern der Welt – sogar verboten.

Allein die Tatsache,
dass viele mangelbedingte Verhaltensstörungen in der kindlichen Entwicklung
meist erfolglos mit nebenwirkungsreichen, aber höchst lukrativen Medikamenten behandelt werden,
lässt monetäre Interessen hinter diesem Missstand vermuten.

Geht es aber wirklich nur um Profit
oder haben wir es gar mit einem pervertierten Machtanspruch über den Geist des Menschen zu tun?
Wem nützt eine Gesellschaft,
die körperlich und psychisch immer kränker und weniger belastbar wird
und in chronischer Zukunftsangst lebt?

Das Lithium-Komplott liefert dringend benötigte Antworten
und ist gleichzeitig ein medizinisches Plädoyer
für die längst überfällige Anerkennung der essentiellen Bedeutung von Lithium
als Schlüssel zu einer gesünderen,
psychisch stabileren und friedensfähigeren Gesellschaft.

Schließlich bietet es einen hochwirksamen,
natürlichen Schutz gegen chronische Entzündungen,
hirntoxischen Stress und Angststörungen – Leiden mit neuerdings pandemischem Charakter.

So könnte essentielles Lithium zum Symbol für den Aufbruch der Menschheit in eine neue Ära der Medizin werden,
die den natürlichen Bedürfnissen des Menschen gerecht wird."
  --doc-subject "nutrition, health, medicine"
  --doc-date 2025-04-30
  --doc-edition 2
  --doc-extent "464 pages"
  --doc-author "Michael Nehls"
  #--doc-introducer ""
  #--doc-contributor ""
  #--doc-translator ""
  --doc-publisher "Mental Enterprises"
  --doc-language de
  --doc-isbn 9783981404890
  --doc-cover-image 070-deskew/465.jpg
  --canonical-url-base https://milahu.github.io/michael-nehls-lithium-komplott-2025/
)

 printf '>'
for a in "${args[@]}" "$@"; do printf ' %q' "$a"; done
echo ' *-ocr/*.hocr'

"${args[@]}" "$@" *-ocr/*.hocr

if [ "$dst" = "." ]; then
  echo "done ./index.xhtml"
  exit
fi

echo "done $dst"

rm -rf $dst.unzip
mkdir $dst.unzip
cd $dst.unzip
unzip -q ../$dst
cd ..

echo "done $dst.unzip/index.html"
