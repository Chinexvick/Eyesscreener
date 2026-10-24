(function () {
  'use strict';
  var E = window.EYES, D = E.data, fmt = E.fmt, $ = E.$;
  var out = $('#aiOut'), input = $('#aiInput'), busy = false;

  $('#aiList').innerHTML = D.tokens.slice(0, 60).map(function (t) { return '<option value="' + fmt.esc(t.symbol) + '">' + fmt.esc(t.name) + '</option>'; }).join('');
  $('#aiSuggest').insertAdjacentHTML('beforeend', ['TST', 'BABYDOGE', 'FLOKI'].concat(D.tokens.filter(function (t) { return t.risk === 'High'; }).slice(0, 2).map(function (t) { return t.symbol; })).map(function (s) {
    return '<button type="button" class="chip" data-s="' + fmt.esc(s) + '">' + fmt.esc(s) + '</button>';
  }).join(''));

  // Unknown contract addresses get a synthetic token so the demo always answers.
  function synth(addr) {
    var r = E.seeded(addr.toLowerCase());
    var risk = r() < 0.4 ? 'Low' : r() < 0.6 ? 'Medium' : 'High';
    var liq = Math.pow(10, 4.5 + r() * 2.8), vol = liq * (0.4 + r() * 2);
    var sym = '0x' + addr.slice(2, 6).toUpperCase();
    return { id: sym + addr.slice(-4), name: 'Unlisted token', symbol: sym, address: addr, img: null, color: '#64748b', price: Math.pow(10, -8 + r() * 6), change: +((r() - 0.4) * 60).toFixed(2),
      liq: liq, vol: vol, mcap: liq * (8 + r() * 20), txns: Math.round(vol / 300), risk: risk, signal: Math.round(25 + r() * 50), age: Math.round(r() * 120), cats: ['bsc'], synthetic: true };
  }

  function resolve(q) {
    q = q.trim();
    var t = E.find(q);
    if (t) return t;
    var m = D.tokens.filter(function (x) { return x.name.toLowerCase().indexOf(q.toLowerCase()) >= 0 || x.symbol.toLowerCase().indexOf(q.toLowerCase()) >= 0; })[0];
    if (m) return m;
    if (/^0x[a-fA-F0-9]{40}$/.test(q)) return synth(q);
    return null;
  }

  function statusIcon(s) { return s === 'good' ? '#i-check' : s === 'warn' ? '#i-alert' : '#i-x'; }

  function report(t) {
    var a = E.analyse(t), col = a.score >= 75 ? 'good' : a.score >= 50 ? 'warn' : 'bad';
    var watched = E.watch.has(t.id);
    var watchOut = a.flags.filter(function (f) { return f.status !== 'good'; })
      .sort(function (x, y) { return (x.status === 'bad' ? 0 : 1) - (y.status === 'bad' ? 0 : 1); })
      .map(function (f) { return f.label + ': ' + f.detail + '.'; });
    if (!watchOut.length) watchOut.push('Nothing alarming stood out. Keep position sizes sensible and re-check before large trades.');

    return '<div class="grid" style="gap:14px">' +
      '<div class="card pad"><div class="report-head">' +
        '<div class="gauge c-' + col + '" style="--p:' + a.score + '"><div><b>' + a.score + '</b><small>Safety score</small></div></div>' +
        '<div class="info"><h2>' + E.avatar(t, 'tok-ic') + fmt.esc(t.name) + ' <span class="muted" style="font-size:14px;font-weight:500">' + fmt.esc(t.symbol) + '</span><span class="chip-s c-' + col + '">' + a.verdict + '</span></h2>' +
        '<p>' + fmt.esc(a.summary) + '</p>' +
        '<span class="addr" id="copyAddr" title="Copy address"><svg><use href="#i-copy"/></svg>' + fmt.short(t.address) + '</span></div></div>' +
        '<div class="row" style="margin-top:16px">' +
          '<button class="btn sm" id="aiWatch">' + (watched ? 'Remove from watchlist' : 'Add to watchlist') + '</button>' +
          '<a class="btn ghost sm" href="/signal-alerts?s=' + encodeURIComponent(t.symbol) + '">Create alert</a>' +
          (t.synthetic ? '' : '<a class="btn ghost sm" href="/token?s=' + encodeURIComponent(t.symbol) + '">Token page</a>') +
          '<a class="btn ghost sm" href="https://bscscan.com/token/' + t.address + '" target="_blank" rel="noopener">BscScan <svg><use href="#i-external"/></svg></a></div></div>' +
      '<div class="split"><div class="card pad"><h2 class="card-title"><svg><use href="#i-shield"/></svg>Security checks</h2><ul class="flags">' +
        a.flags.map(function (f) { return '<li class="c-' + f.status + '"><span class="dot"><svg><use href="' + statusIcon(f.status) + '"/></svg></span><div><b>' + f.label + '</b><small>' + fmt.esc(f.detail) + '</small></div></li>'; }).join('') +
      '</ul></div>' +
      '<div class="grid" style="gap:14px"><div class="card pad"><h2 class="card-title"><svg><use href="#i-chart"/></svg>Key numbers</h2><dl class="kv">' +
        '<div><dt>Price</dt><dd>' + fmt.price(t.price) + '</dd></div><div><dt>24h change</dt><dd class="' + (t.change >= 0 ? 'up' : 'down') + '">' + fmt.pct(t.change) + '</dd></div>' +
        '<div><dt>Liquidity</dt><dd>' + fmt.money(t.liq) + '</dd></div><div><dt>24h volume</dt><dd>' + fmt.money(t.vol) + '</dd></div>' +
        '<div><dt>Market cap</dt><dd>' + fmt.money(t.mcap) + '</dd></div><div><dt>Holders</dt><dd>' + a.holders.toLocaleString('en-US') + '</dd></div>' +
        '<div><dt>Pair age</dt><dd>' + (a.ageDays > 60 ? Math.round(a.ageDays / 30) + ' months' : a.ageDays + ' days') + '</dd></div><div><dt>AI signal</dt><dd>' + t.signal + '/100</dd></div></dl>' +
        '<div style="margin-top:16px"><div class="row between" style="font-size:12px;color:var(--muted);margin-bottom:6px"><span>Top 10 holders</span><b style="color:var(--text)">' + a.top10 + '%</b></div><div class="meter c-' + (a.top10 <= 30 ? 'good' : a.top10 <= 50 ? 'warn' : 'bad') + '" style="--p:' + a.top10 + '"><i></i></div></div></div>' +
      '<div class="card pad"><h2 class="card-title"><svg><use href="#i-flag"/></svg>What to watch</h2><ul style="margin:0;padding-left:18px;font-size:13.5px;line-height:1.6;color:var(--text-2)">' +
        watchOut.map(function (w) { return '<li style="margin-bottom:6px">' + fmt.esc(w) + '</li>'; }).join('') + '</ul></div></div></div></div>';
  }

  function bindReport(t) {
    var w = $('#aiWatch');
    if (w) w.addEventListener('click', function () {
      var on = E.watch.toggle(t.id);
      w.textContent = on ? 'Remove from watchlist' : 'Add to watchlist';
      E.toast(on ? t.name + ' added to Watchlist' : t.name + ' removed from Watchlist');
    });
    var c = $('#copyAddr');
    if (c) c.addEventListener('click', function () {
      if (navigator.clipboard) navigator.clipboard.writeText(t.address).then(function () { E.toast('Address copied'); }, function () { E.toast(t.address); });
      else E.toast(t.address);
    });
  }

  function run(q) {
    if (busy) return;
    if (!q.trim()) { E.toast('Enter a token name, symbol or contract address'); return; }
    var t = resolve(q);
    if (!t) {
      out.innerHTML = '<div class="card empty-state"><div class="big"><svg><use href="#i-search"/></svg></div><h3>No token found</h3><p>We could not find “' + fmt.esc(q) + '”. Try a symbol like TST, or paste a full 42-character 0x contract address.</p></div>';
      return;
    }
    busy = true;
    var steps = ['Reading contract and ownership', 'Simulating buys and sells', 'Checking liquidity lock', 'Analysing holder distribution', 'Writing report'];
    out.innerHTML = '<div class="card"><div class="thinking"><span class="spinner"></span>Investigating ' + fmt.esc(t.symbol) + '…</div><ul class="steps" id="aiSteps">' +
      steps.map(function (s) { return '<li>' + s + '</li>'; }).join('') + '</ul></div>';
    var lis = E.$$('#aiSteps li'), i = 0;
    var iv = setInterval(function () {
      if (lis[i]) lis[i].classList.add('done');
      i++;
      if (i > lis.length) {
        clearInterval(iv); busy = false;
        out.innerHTML = report(t);
        bindReport(t);
        out.scrollIntoView({ behavior: 'smooth', block: 'start' });
      }
    }, 380);
  }

  $('#aiForm').addEventListener('submit', function (e) { e.preventDefault(); run(input.value); });
  $('#aiSuggest').addEventListener('click', function (e) {
    var b = e.target.closest('.chip');
    if (b) { input.value = b.dataset.s; run(b.dataset.s); }
  });

  var q = new URLSearchParams(location.search).get('q');
  if (q) { input.value = q; run(q); }
})();
