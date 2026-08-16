# md2html.awk : turns small markdown into one html file. Inlines the css.
#
# One rule per line. Left side: what you write. Right side: what you get.
#
#   title: My Page               <title>My Page</title>   (write on line 1)
#   icon: X                      favicon from one emoji (write near line 1)
#   footer: made by hand         <footer>, printed last
#   # A  ## B  ### C  #### D     <h1>A</h1> .. <h4>D</h4>
#   ### History {#past}          <h3 id="past">History</h3>
#   ---                          <hr>
#   --- #past                    <hr id="past">
#   -                            starts a numbered item: <ol> ... <li>
#   - some text                  bullet item: <ul> ... <li>some text</li>
#   | a | b |                    table row; first row = headers;
#   |---|---:|                   separator row; trailing ":" right-aligns
#   @ [T](url). Authors. UIST 2007.   reference div. Ends the item.
#   .                            </ol>. Ends the list.
#   (blank line)                 new paragraph. Inside an item: <br><br>
#   [text](url)                  <a href="url">text</a>
#   **bold**  *em*               <b>bold</b>  <em>em</em>
#   word[^nope]                  numbered footnote mark, links down
#   [^nope]: Some text.          the footnote body, printed where written
#   <div>raw</div>               html block passes through, unwrapped
#   &mdash;                      entities pass through

function span(s, re, n, tag,    out, mid) {   # wrap *x* / **x** in a tag
  out = ""
  while (match(s, re)) {
    mid = substr(s, RSTART+n, RLENGTH - 2*n)
    out = out substr(s, 1, RSTART-1) "<" tag ">" mid "</" tag ">"
    s = substr(s, RSTART + RLENGTH)
  }
  return out s
}

function inline(s,    out, mid, txt, url) {   # [text](url) -> <a>
  out = ""
  while (match(s, /\[\^[A-Za-z0-9_-]+\]/)) {  # [^name] -> footnote mark
    mid = substr(s, RSTART+2, RLENGTH-3)
    if (!(mid in fnum)) fnum[mid] = ++FN
    out = out substr(s, 1, RSTART-1) \
          "<sup id=\"r-" mid "\"><a href=\"#fn-" mid "\">" fnum[mid] "</a></sup>"
    s = substr(s, RSTART + RLENGTH)
  }
  s = out s
  out = ""
  while (match(s, /\[[^]]+\]\([^)]+\)/)) {
    mid = substr(s, RSTART, RLENGTH)
    txt = mid; sub(/^\[/, "", txt); sub(/\]\(.*$/, "", txt)
    url = mid; sub(/^.*\]\(/, "", url); sub(/\)$/, "", url)
    out = out substr(s, 1, RSTART-1) "<a href=\"" url "\">" txt "</a>"
    s = substr(s, RSTART + RLENGTH)
  }
  s = span(out s, "\\*\\*[^*]+\\*\\*", 2, "b")
  return span(s, "\\*[^*]+\\*", 1, "em")
}

function id(s) {                       # pull optional trailing {#id}
  Id = ""
  if (match(s, /[ \t]*\{#[^}]+\}[ \t]*$/)) {
    Id = substr(s, RSTART, RLENGTH)
    sub(/^[ \t]*\{#/, "", Id); sub(/\}[ \t]*$/, "", Id)
    s = substr(s, 1, RSTART-1)
  }
  return s
}

function attr() { return Id == "" ? "" : " id=\"" Id "\"" }

function flush() {
  if (buf == "") { fnname = ""; return }
  if (fnname != "") {                # footnote body
    print "<div class=\"footnote\" id=\"fn-" fnname "\">" \
          "<a href=\"#r-" fnname "\">" fnum[fnname] "</a>. " inline(buf) "</div>"
    fnname = ""
  }
  else if (ulitem) {                 # bullet list item
    if (!inul) { print "<ul>"; inul = 1 }
    print "<li>" inline(buf) "</li>"
    ulitem = 0
  }
  else {
    afterul = inul || intab          # no <br><br> right after a list or table
    endul(); endtab()
    if      (buf ~ /^</) print buf   # raw html block passes through unwrapped
    else if (inli) { printf "%s%s\n", (nlip++ && !afterul ? "<br><br>\n" : ""), inline(buf) }
    else           { printf "<p>\n%s\n</p>\n", inline(buf) }
  }
  buf = ""
}

function endli() { endul(); endtab(); if (inli) { print "</li>"; inli = 0 } }
function endul() { if (inul) { print "</ul>"; inul = 0 } }
function endtab() { if (intab) { print "</table>"; intab = 0; tabhead = 0; split("", align) } }

BEGIN {
  print "<!doctype html>\n<html lang=\"en\">\n<head>\n<meta charset=\"utf-8\">"
  TITLE = "untitled"; HEAD = 0
}

function head() {
  if (HEAD++) return
  print "<title>" TITLE "</title>"
  if (ICON != "")
    print "<link rel=\"icon\" href=\"data:image/svg+xml;charset=utf-8," \
          "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'>" \
          "<text y='.9em' font-size='90'>" ICON "</text></svg>\">"
  print "<meta name=\"viewport\" content=\"width=device-width\" />"
  print "<style>"
  while ((getline css_line < css) > 0) print css_line
  close(css)
  print "</style>\n</head>\n<body>\n<main>"
}

/^title:[ \t]*/  { sub(/^title:[ \t]*/, ""); TITLE = $0; next }
/^icon:[ \t]*/   { sub(/^icon:[ \t]*/, "");  ICON  = $0; next }
                 { head() }
/^footer:[ \t]*/ { sub(/^footer:[ \t]*/, ""); FOOTER = $0; next }

/^####[ \t]/ { flush(); endul(); sub(/^####[ \t]+/, ""); t = id($0); print "<h4" attr() ">" inline(t) "</h4>"; next }
/^###[ \t]/  { flush(); endul(); sub(/^###[ \t]+/, "");  t = id($0); print "<h3" attr() ">" inline(t) "</h3>"; next }
/^##[ \t]/   { flush(); endul(); sub(/^##[ \t]+/, "");   t = id($0); print "<h2" attr() ">" inline(t) "</h2>"; next }
/^#[ \t]/    { flush(); endul(); sub(/^#[ \t]+/, "");    t = id($0); print "<h1" attr() ">" inline(t) "</h1>"; next }

/^---([ \t]+#[A-Za-z0-9_-]+)?[ \t]*$/ {
  flush(); endli()
  Id = ""; if (match($0, /#[A-Za-z0-9_-]+/)) Id = substr($0, RSTART+1, RLENGTH-1)
  print "<hr" attr() ">"; next
}

/^\|/ {                                # table row
  flush()
  if (!intab) { print "<table>"; intab = 1 }
  row = $0; sub(/^\|/, "", row); sub(/\|[ \t]*$/, "", row)
  n = split(row, cells, "|")
  if ($0 ~ /^\|[ \t:|-]+$/) {          # separator row: read alignment, print nothing
    for (i = 1; i <= n; i++) if (cells[i] ~ /:[ \t]*$/) align[i] = " style=\"text-align:right\""
    next
  }
  tag = tabhead++ ? "td" : "th"
  line = "<tr>"
  for (i = 1; i <= n; i++) {
    c = cells[i]; gsub(/^[ \t]+/, "", c); gsub(/[ \t]+$/, "", c)
    line = line "<" tag (tag == "td" ? align[i] : "") ">" inline(c) "</" tag ">"
  }
  print line "</tr>"
  next
}

/^-[ \t]+[^ \t]/ {                     # bullet list item
  flush()
  sub(/^-[ \t]+/, "")
  buf = $0; ulitem = 1; next
}

/^-[ \t]*$/ {                          # new numbered item
  flush(); endli()
  if (!inol) { print "<ol>"; inol = 1 }
  print "<li>"; inli = 1; nlip = 0; next
}

/^\[\^[A-Za-z0-9_-]+\]:[ \t]/ {        # footnote body starts; ends at blank line
  flush()
  fnname = $0; sub(/^\[\^/, "", fnname); sub(/\]:.*$/, "", fnname)
  if (!(fnname in fnum)) fnum[fnname] = ++FN
  sub(/^\[\^[A-Za-z0-9_-]+\]:[ \t]+/, "")
  buf = $0; next
}

/^@[ \t[]/ {                           # reference; the item stays open
  flush(); sub(/^@[ \t]*/, "")
  print (refrun++ ? "" : "<br><br>") "<div class=\"reference\">\n" inline($0) "\n</div>"
  next
}

/^\.[ \t]*$/ { flush(); endli(); if (inol) { print "</ol>"; inol = 0 }; next }

/^[ \t]*$/ { flush(); next }

{ buf = buf (buf == "" ? "" : " ") $0; refrun = 0 }

END {
  head(); flush(); endli()
  if (inol) print "</ol>"
  if (FOOTER != "") print "<footer>" inline(FOOTER) "</footer>"
  print "</main>\n</body>\n</html>"
}
