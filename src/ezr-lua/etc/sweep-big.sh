#!/bin/zsh
# sweep: tree+acquire on every mid-band model, 4 runtimes.
# TSV: runtime, model, real_s, cpu_s, maxrss_bytes, exit
sc=/private/tmp/claude-502/-Users-timm-gits-timm-src-sas/786a3e8a-9172-4638-8620-e902f71272bd/scratchpad
out=$sc/bench-big.tsv
: > $out
while read f; do
  cd /Users/timm/gits/timm/src/ezr-py
  for rt in python3 pypy3; do
    /usr/bin/time -l $rt xai-eg.py tree acquire --file=$f \
      > $sc/t.out 2> $sc/t.err
    ok=$?
    awk -v rt=$rt -v f=$f -v ok=$ok \
      '/ real /{r=$1; c=$3+$5} /maximum resident/{m=$1}
       END{print rt"\t"f"\t"r"\t"c"\t"m"\t"ok}' \
      $sc/t.err >> $out
  done
  cd /Users/timm/gits/timm/src/ezr-lua
  /usr/bin/time -l lua xai-eg.lua -f $f --tree --acquire \
    > $sc/t.out 2> $sc/t.err
  ok=$?
  awk -v rt=lua -v f=$f -v ok=$ok \
    '/ real /{r=$1; c=$3+$5} /maximum resident/{m=$1}
     END{print rt"\t"f"\t"r"\t"c"\t"m"\t"ok}' \
    $sc/t.err >> $out
  /usr/bin/time -l luajit $sc/xai-eg-jit.lua -f $f \
    --tree --acquire > $sc/t.out 2> $sc/t.err
  ok=$?
  awk -v rt=luajit -v f=$f -v ok=$ok \
    '/ real /{r=$1; c=$3+$5} /maximum resident/{m=$1}
     END{print rt"\t"f"\t"r"\t"c"\t"m"\t"ok}' \
    $sc/t.err >> $out
done < $sc/big.txt
wc -l $out
