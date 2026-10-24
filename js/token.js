(function () {
  'use strict';
  var E = window.EYES, D = E.data, fmt = E.fmt, $ = E.$;
  var sym = new URLSearchParams(location.search).get('s');
  var t = E.find(sym);
  var body = $('#tkBody');

  if (!t) {
    document.title = 'Token not found — EYES-Screener';
    body.innerHTML = '<div class="card not-found"><div class="empty-state"><div class="big"><svg><use href="#i-search"/></svg></div><h3>Token not found</h3><p>We could not find “' + fmt.esc(sym || '') + '”. Try searching the screener.</p><a class="btn" href="/">Back to the screener</a></div></div>';
    return;
  }
  document.title = t.name + ' (' + t.symbol + ') — EYES-Screener';
  $('#tkCrumb').textContent = t.name;
  var a = E.analyse(t), col = a.score >= 75 ? 'good' : a.score >= 50 ? 'warn' : 'bad';

  function icon(s) { return s === 'good' ? '#i-check' : s === 'warn' ? '#i-alert' : '#i-x'; }

  body.innerHTML = '<div class="grid" style="gap:14px">' +
    '<div class="card pad"><div class="tk-head">' + E.avatar(t, 'tok-ic') +
      '<div><h1>' + fmt.esc(t.name) + ' <small>' + fmt.esc(t.symbol) + ' / WBNB</small></h1>' +
      '<div class="row" style="margin-top:8px;gap:8px"><span class="pill ' + t.risk.toLowerCase() + '">' + t.risk + ' risk</span>' +
      t.cats.map(function (c) { return '<span class="chip-s" style="--c:var(--muted)">' + c.toUpperCase() + '</span>'; }).join('') + '</div></div>' +
      '<div class="tk-price"><b>' + fmt.price(t.price) + '</b><span class="' + (t.change >= 0 ? 'up' : 'down') + '" style="font-weight:600">' + fmt.pct(t.change) + ' (24h)</span></div></div>' +
      '<div class="tk-chart" id="tkChart"></div>' +
      '<div class="seg-inline" id="tkTf" style="margin-top:12px"><button data-tf="1H">1H</button><button data-tf="24H" class="active">24H</button><button data-tf="7D">7D</button><button data-tf="30D">30D</button></div></div>' +

    '<div class="grid g4">' +
      '<div class="card stat"><small>Liquidity</small><b>' + fmt.money(t.liq) + '</b></div>' +
      '<div class="card stat"><small>24h volume</small><b>' + fmt.money(t.vol) + '</b></div>' +
      '<div class="card stat"><small>Market cap</small><b>' + fmt.money(t.mcap) + '</b></div>' +
      '<div class="card stat"><small>Transactions (24h)</small><b>' + fmt.count(t.txns) + '</b></div></div>' +

    '<div class="split"><div class="card pad"><h2 class="card-title"><svg><use href="#i-shield"/></svg>Risk breakdown<span class="sp" style="color:var(--muted)">' + a.bad + ' critical · ' + a.warn + ' warnings</span></h2><ul class="flags">' +
      a.flags.map(function (f) { return '<li class="c-' + f.status + '"><span class="dot"><svg><use href="' + icon(f.status) + '"/></svg></span><div><b>' + f.label + '</b><small>' + fmt.esc(f.detail) + '</small></div></li>'; }).join('') + '</ul></div>' +
      '<div class="grid" style="gap:14px"><div class="card pad"><div class="report-head" style="gap:16px"><div class="gauge sm c-' + col + '" style="--p:' + a.score + '"><div><b>' + a.score + '</b></div></div>' +
        '<div class="info" style="min-width:0"><b style="font-size:15px">' + a.verdict + '</b><p style="font-size:13px;margin-top:6px">' + fmt.esc(a.summary) + '</p></div></div></div>' +
      '<div class="card pad"><h2 class="card-title"><svg><use href="#i-brain"/></svg>AI signal</h2><div class="row" style="gap:14px">' + E.ring(t.signal) +
        '<p class="muted" style="margin:0;font-size:13px;line-height:1.5;flex:1;min-width:180px">Momentum, liquidity and holder behaviour combine to a score of <b style="color:var(--text)">' + t.signal + '/100</b>.</p></div></div>' +
      '<div class="card pad"><dl class="kv"><div><dt>Contract</dt><dd style="font-size:13px">' + fmt.short(t.address) + '</dd></div><div><dt>Holders</dt><dd>' + a.holders.toLocaleString('en-US') + '</dd></div></dl>' +
        '<div class="row" style="margin-top:16px"><button class="btn sm" id="tkWatch"></button>' +
        '<a class="btn ghost sm" href="/ai-investigator?q=' + encodeURIComponent(t.symbol) + '">Full AI report</a>' +
        '<a class="btn ghost sm" href="/signal-alerts?s=' + encodeURIComponent(t.symbol) + '">Create alert</a>' +
        '<a class="btn ghost sm" href="https://bscscan.com/token/' + t.address + '" target="_blank" rel="noopener">BscScan <svg><use href="#i-external"/></svg></a></div></div></div></div>' +
    '<p class="disclaimer">Demo data. Not financial advice.</p></div>';

  function paintWatch() { $('#tkWatch').textContent = E.watch.has(t.id) ? '★ In watchlist' : '☆ Add to watchlist'; }
  $('#tkWatch').addEventListener('click', function () { var on = E.watch.toggle(t.id); paintWatch(); E.toast(on ? t.name + ' added to Watchlist' : t.name + ' removed from Watchlist'); });
  paintWatch();

  // Price chart seeded from the symbol so it is stable between visits and ends at the current price.
  var TF = { '1H': [60, 0.4], '24H': [72, 1], '7D': [84, 1.8], '30D': [90, 2.6] }, tf = '24H';
  function chart() {
    var el = $('#tkChart'), w = el.clientWidth || 600, h = el.clientHeight || 240, cfg = TF[tf];
    var r = E.seeded(t.id + tf), v = 50, pts = [];
    for (var i = 0; i < cfg[0]; i++) { v += (r() - (t.change >= 0 ? 0.43 : 0.57)) * 6 * cfg[1] + Math.sin(i / 3) * 1.5; pts.push(v); }
    var mn = Math.min.apply(null, pts), mx = Math.max.apply(null, pts);
    var xy = pts.map(function (p, i) { return [(i / (pts.length - 1)) * (w - 8) + 2, h - 14 - ((p - mn) / (mx - mn || 1)) * (h - 34)]; });
    var line = xy.map(function (p, i) { return (i ? 'L' : 'M') + p[0].toFixed(1) + ' ' + p[1].toFixed(1); }).join(' ');
    var last = xy[xy.length - 1], up = pts[pts.length - 1] >= pts[0], c = up ? 'var(--up)' : 'var(--down)';
    var grid = [0.25, 0.5, 0.75].map(function (g) { return '<line x1="0" x2="' + w + '" y1="' + (h * g).toFixed(0) + '" y2="' + (h * g).toFixed(0) + '" stroke="var(--line)" />'; }).join('');
    el.innerHTML = '<svg viewBox="0 0 ' + w + ' ' + h + '" width="' + w + '" height="' + h + '" aria-label="Price chart"><defs><linearGradient id="tkg" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="' + c + '" stop-opacity=".28"/><stop offset="1" stop-color="' + c + '" stop-opacity="0"/></linearGradient></defs>' +
      grid + '<path d="' + line + ' L' + last[0].toFixed(1) + ' ' + h + ' L2 ' + h + ' Z" fill="url(#tkg)" stroke="none"/><path d="' + line + '" fill="none" stroke="' + c + '" stroke-width="2" stroke-linejoin="round"/>' +
      '<circle cx="' + last[0].toFixed(1) + '" cy="' + last[1].toFixed(1) + '" r="4" fill="' + c + '" stroke="var(--card)" stroke-width="2"/></svg>';
  }
  $('#tkTf').addEventListener('click', function (e) {
    var b = e.target.closest('button'); if (!b) return;
    E.$$('#tkTf button').forEach(function (x) { x.classList.toggle('active', x === b); });
    tf = b.dataset.tf; chart();
  });
  chart();
  window.addEventListener('resize', chart);
})();
