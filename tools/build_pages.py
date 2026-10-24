"""Assemble static pages from src/ into the repo root.

Each src/pages/<name>.html starts with a front-matter block:
    ---
    title: Page title
    key: nav key (home|screener|ai|risk|alerts|watchlist|academy|more)
    desc: meta description
    rail: true|false      (right column; default false)
    scripts: js/a.js js/b.js
    ---
followed by the <main> markup (and an <aside class="rail"> when rail is true).

Usage: python3 tools/build_pages.py
"""
import glob
import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(ROOT, "src")


def read(path):
    with open(os.path.join(SRC, path), encoding="utf-8") as f:
        return f.read()


def parse(text):
    m = re.match(r"---\n(.*?)\n---\n", text, re.S)
    meta = {}
    for line in m.group(1).splitlines():
        k, v = line.split(":", 1)
        meta[k.strip()] = v.strip()
    return meta, text[m.end():]


def main():
    sprite = read("partials/sprite.html").replace("  </svg>\n", read("partials/sprite-extra.html") + "  </svg>\n")
    header, sidebar, bottom = (read(f"partials/{n}.html") for n in ("header", "sidebar", "bottom"))
    for path in sorted(glob.glob(os.path.join(SRC, "pages", "*.html"))):
        name = os.path.basename(path)
        meta, body = parse(open(path, encoding="utf-8").read())
        key = meta["key"]
        nav = lambda html: re.sub(
            r'<a href="([^"]*)"((?: class="[^"]*")?) data-key="%s"' % key,
            lambda m: '<a href="%s" class="%s active" aria-current="page" data-key="%s"' % (
                m.group(1), re.sub(r'class="|"', "", m.group(2)).strip(), key),
            html)
        scripts = "".join('  <script src="%s"></script>\n' % s for s in meta.get("scripts", "").split())
        out = f"""<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover" />
  <title>{meta["title"]}</title>
  <meta name="description" content="{meta["desc"]}" />
  <meta name="theme-color" content="#F5C518" />
  <link rel="icon" href="/assets/img/logo.png" />
  <link rel="preconnect" href="https://fonts.googleapis.com" />
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=Poppins:wght@700;800&display=swap" rel="stylesheet" />
  <link rel="stylesheet" href="/css/styles.css" />
  <link rel="stylesheet" href="/css/pages.css" />
  <script>
    try {{ var t = localStorage.getItem('eyes-theme'); if (t) document.documentElement.dataset.theme = t; }} catch (e) {{}}
  </script>
</head>
<body data-page="{key}">
  <!-- Icon sprite -->
  {sprite}
  {header}  <div class="layout{'' if meta.get('rail') == 'true' else ' no-rail'}">
    {nav(sidebar)}
    {body.strip()}
  </div>

  {nav(bottom)}
  <script src="/js/data.js"></script>
  <script src="/js/common.js"></script>
{scripts}</body>
</html>
"""
        out = out.replace('src="assets/', 'src="/assets/')
        dest = os.path.join(ROOT, name)
        with open(dest, "w", encoding="utf-8") as f:
            f.write(out)
        print("wrote", name)


if __name__ == "__main__":
    main()
