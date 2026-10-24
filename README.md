# EYES-Screener

BNB Chain token screener — *See everything. Invest wisely.*

A static site (HTML + CSS + vanilla JS, no build step) built from the design in
`assets/design/mockup.jpg`.

## Run

```sh
python3 -m http.server 8000   # then open http://localhost:8000
```

Any static host works (Vercel, Netlify, GitHub Pages, Cloudflare Pages).

## Pages

| Route | What it is |
| --- | --- |
| `/` | EYES-Screener: filterable, sortable token table with market overview |
| `/home` | Overview: market stats, top movers, new pairs, tool shortcuts |
| `/ai-investigator` | Paste a name or contract, get an AI-style safety report |
| `/risk-radar` | Radar and list of tokens scored for safety, filterable by red flag |
| `/signal-alerts` | Create price / momentum / risk alerts and see the signal feed |
| `/watchlist` | Starred tokens (saved in the browser) |
| `/academy` | Courses with saved progress and a glossary |
| `/token?s=TST` | Token detail: chart, stats and risk breakdown |
| `/more`, `/eyes`, `/settings` | Hub, $EYES ecosystem preview, theme and data controls |

Everything responsive: desktop 3-column, tablet, and a phone layout with a slide-out menu,
bottom nav and card-style tables. Light and dark themes.

## Structure

```
src/partials/            shared header, sidebar, bottom nav, icon sprite
src/pages/*.html         one source file per page (front-matter + <main>)
tools/build_pages.py     assembles src/ into the root *.html files  ->  python3 tools/build_pages.py
index.html, home.html …  generated output (committed, served as-is)
css/styles.css           base styles, theme tokens, screener
css/pages.css            inner-page styles
js/data.js               demo market data (swap for a real feed with the same shape)
js/common.js             shared helpers, risk model, theme, menu, wallet
js/app.js, ai.js, …      one script per page
assets/img/              images (tokens/ = real logos)
tools/fetch_token_logos.py    downloads real token logos
tools/fetch_remote_assets.sh  build step: pulls Higgsfield-generated banner art (see vercel.json)
tools/extract_assets.py       crops fallback images from the mockup
```

Edit a page in `src/`, run `python3 tools/build_pages.py`, commit both. Market data and risk
scores are demo data; to go live replace `EYES_DATA.tokens` and `EYES.analyse` with a real provider.
