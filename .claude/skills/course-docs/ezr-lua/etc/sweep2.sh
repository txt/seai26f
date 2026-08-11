#!/bin/zsh
sc=/private/tmp/claude-502/-Users-timm-gits-timm-src-sas/786a3e8a-9172-4638-8620-e902f71272bd/scratchpad
out=$sc/bench-small2.tsv
: > $out
while read f; do
  cd /Users/timm/gits/timm/src/ezr-py
  for rt in python3 pypy3; do
    /usr/bin/time -l $rt xai-eg.py tree acquire --file=$f \
      > /dev/null 2> $sc/t.err
    ok=$?
    awk -v rt=$rt -v f=$f -v ok=$ok \
      '/ real /{r=$1; c=$3+$5} /maximum resident/{m=$1}
       END{print rt"\t"f"\t"r"\t"c"\t"m"\t"ok}' \
      $sc/t.err >> $out
  done
  cd $sc/bench2
  /usr/bin/time -l lua xai-eg.lua -f $f --tree --acquire \
    > /dev/null 2> $sc/t.err
  ok=$?
  awk -v rt=lua -v f=$f -v ok=$ok \
    '/ real /{r=$1; c=$3+$5} /maximum resident/{m=$1}
     END{print rt"\t"f"\t"r"\t"c"\t"m"\t"ok}' $sc/t.err >> $out
  /usr/bin/time -l luajit xai-eg-jit.lua -f $f --tree --acquire \
    > /dev/null 2> $sc/t.err
  ok=$?
  awk -v rt=luajit -v f=$f -v ok=$ok \
    '/ real /{r=$1; c=$3+$5} /maximum resident/{m=$1}
     END{print rt"\t"f"\t"r"\t"c"\t"m"\t"ok}' $sc/t.err >> $out
done < $sc/small.txt
