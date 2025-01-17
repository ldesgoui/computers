#!/usr/bin/env bash

if knotc status >/dev/null 2>&1; then
  echo "[install-knot-zones]: knot is running, i will freeze and thaw"
  running=true
else
  running=false
fi

for src in "$ZONES"/*; do
  filename=$(basename "$src")
  zone=${filename%zone}
  out="/var/lib/knot/$filename"
  tmp=$(mktemp -d)

  if [ "$running" = true ]; then
    knotc -b zone-freeze "$zone"
    knotc -b zone-flush "$zone"
  fi

  if [ -f "$out" ]; then
    awk -f "$KEEP_RECORDS_AWK" "$out" > "$tmp"/keep    
  else
    touch "$tmp"/keep
  fi

  cat "$src" "$tmp"/keep > "$tmp"/out
  install --backup=simple --owner knot --group knot --mode 660 -T "$tmp"/out "$out"

  if [ "$running" = true ]; then
    knotc -b zone-reload "$zone"
    knotc zone-thaw "$zone"
    knotc zone-flush "$zone"
  fi
done
