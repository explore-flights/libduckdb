#!/bin/sh
set -eux
mkdir -p "objs-$1"
cd "objs-$1"

ftemp=$(mktemp)
cp "../$1" "$ftemp"

i=0
while true
do
  member=$(ar t "$ftemp" | head -n 1)
  if [ -z "$member" ]; then
    break
  fi

  (mkdir -p "$i" && cd "$i" && ar x "$ftemp" "$member")
  ar d "$ftemp" "$member"
  i=$((i+1))
done

rm "$ftemp"