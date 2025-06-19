#!/bin/bash
# # # # # # # # # USE # # # ME # # # # # # # # # #
#  zettel "TITLE" [BODY...]     <- slug only     #
#  zettel -e "TITLE" [BODY...]  <- opens editor  #
#  zettel -o "TITLE" [BODY...]  <- opens Obsidian#
# # # # # # # # # # # # # v.3 # !now y3k safe! # #

NOTES_DIR="$HOME/Documents/Zettelkessel/SLUGS"

zettel () {
  open_editor=false
  open_obsidian=false
  args=()

  # Parse flags and args
  while (( "$#" )); do
    case "$1" in
      -e|--edit) open_editor=true; shift ;;
      -o|--obsidian) open_obsidian=true; shift ;;
      --) shift; break ;;
      *) args+=("$1"); shift ;;
    esac
  done

  note_name="${args[*]}"
  body=("$@")

  # Help flag: if user passed -h or --help as first "non-flag" argument
  if [[ "$note_name" == "-h" || "$note_name" == "--help" ]]; then
    cat <<EOF
# # # # # # # # # USE # # # ME # # # # # # # # # #
#  zettel "TITLE" [BODY...]     <- slug only     #
#  zettel -e "TITLE" [BODY...]  <- opens editor  #
#  zettel -o "TITLE" [BODY...]  <- opens Obsidian#
#        -h or --help           <- this screen   #
# # # # # # # # # # # # # v.3 # !now y3k safe! # #
EOF
    return 0
  fi

  if [[ -z "$note_name" ]]; then
    echo "Error: Please name your slug."
    return 1
  fi

  slug=$(echo "$note_name" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | sed "s/[^a-z0-9-]//g")

  year3=$(date +%Y | cut -c2- | sed 's/^0*//')
  day_of_year=$(date +%j)
  minutes_since_midnight=$((10#$(date +%H)*60 + 10#$(date +%M)))
  minutes_padded=$(printf "%04d" "$minutes_since_midnight")

  filename="${year3}${day_of_year}T${minutes_padded}-$slug.md"
  filepath="${NOTES_DIR}/${filename}"

  mkdir -p "$NOTES_DIR"

  if [ -e "$filepath" ]; then
    echo "Duplicate slug detected: $filename. Slugs must be unique or they’ll fight."
    return 1
  fi

  {
    echo "# $note_name"
    echo ""
    echo "> born $(date --iso-8601=seconds)"
    echo ""
    printf '%s ' "${body[@]}"
    echo
  } > "$filepath"

  echo "Slug saved as $filename"

  if $open_obsidian; then
    winpath=$(cygpath -w "$filepath" | sed 's/\\/\\%5C/g')
    powershell.exe start "obsidian://open?file=${winpath}"
    return
  fi

  if $open_editor; then
    if [ -z "$EDITOR" ]; then
      echo "Error: \$EDITOR not set."
      return 1
    fi
    "$EDITOR" "$filepath"
  fi
}
