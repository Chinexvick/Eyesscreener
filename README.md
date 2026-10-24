# EYES-Screener

BNB Chain token screener — *See everything. Invest wisely.*

A static site (HTML + CSS + vanilla JS, no build step) built from the design in
`assets/design/mockup.jpg`.

## Run

```sh
python3 -m http.server 8000   # then open http://localhost:8000
```

Any static host works (Vercel, Netlify, GitHub Pages, Cloudflare Pages).

## What works

- Tabs (Top Gainers / New Pairs / Trending / Liquidity / AI Picks) re-sort the screener
- Search (header + table, synced), filters, category chips, sortable columns, pagination
- Watchlist stars (saved in the browser) and a Watchlist view from the nav
- Simulated live price ticks with flash highlighting, live clock badge
- Market overview chart with 1H / 24H / 7D / 30D ranges
- Light / dark theme, notifications popover, Connect Wallet via an injected wallet (MetaMask, Trust Wallet…)
- Responsive: 3-column desktop → rail below main (≤1180px) → slide-out sidebar (≤1024px)
  → mobile layout (≤760px) with token cards, scrollable tabs/filters and a bottom nav bar

## Structure

```
index.html            markup + inline SVG icon sprite
css/styles.css        styles, theme tokens, breakpoints
js/data.js            demo market data (swap for a real feed with the same shape)
js/app.js             rendering + interactions
assets/img/           images cropped from the mockup
tools/extract_assets.py  regenerates assets/img from the mockup
tools/fetch_token_logos.py  downloads real token logos
tools/fetch_remote_assets.sh  build step: pulls the Higgsfield-generated banner art (see vercel.json)
```

Market data is demo data. To go live, replace `EYES_DATA.tokens` in `js/data.js` with
data from an API such as DexScreener, keeping the same fields.
