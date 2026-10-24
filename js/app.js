(function () {
  'use strict';

  var D = window.EYES_DATA;
  var PAGE_SIZE = 10;
  var $ = function (s, r) { return (r || document).querySelector(s); };
  var $$ = function (s, r) { return Array.prototype.slice.call((r || document).querySelectorAll(s)); };

  // ---------- storage (best effort) ----------
  function load(key, fallback) {
    try { var v = localStorage.getItem(key); return v ? JSON.parse(v) : fallback; } catch (e) { return fallback; }
  }
  function save(key, val) {
    try { localStorage.setItem(key, JSON.stringify(val)); } catch (e) {}
  }

  var state = {
    tab: 'gainers',
    cat: 'all',
    query: '',
    sortKey: null,
    sortDir: -1,
    page: 1,
    watchOnly: false,
    watch: load('eyes-watchlist', ['BABYDOGE']),
    tf: '24H'
  };

  var TAB_SORT = {
    gainers: ['change', -1],
    new: ['age', 1],
    trending: ['trend', -1],
    liquidity: ['liq', -1],
    ai: ['signal', -1]
  };
  var RISK_N = { Low: 1, Medium: 2, High: 3 };
  D.tokens.forEach(function (t) { t.riskN = RISK_N[t.risk]; });

  // ---------- formatting ----------
  function fmtPrice(p) {
    if (p >= 1000) return '$' + p.toLocaleString('en-US', { maximumFractionDigits: 0 });
    if (p >= 1) return '$' + p.toFixed(2);
    var dec = Math.ceil(-Math.log10(p)) + 2;
    return '$' + p.toFixed(Math.min(dec, 12)).replace(/(\.\d*?[1-9])0+$/, '$1');
  }
  function fmtMoney(n) {
    if (n >= 1e9) return '$' + (n / 1e9).toFixed(1) + 'B';
    if (n >= 1e6) return '$' + (n / 1e6).toFixed(1) + 'M';
    if (n >= 1e3) return '$' + (n / 1e3).toFixed(1) + 'K';
    return '$' + n.toFixed(0);
  }
  function fmtCount(n) {
    if (n >= 1e6) return (n / 1e6).toFixed(1) + 'M';
    if (n >= 1e3) return (n / 1e3).toFixed(1) + 'K';
    return String(Math.round(n));
  }
  function fmtPct(n) { return (n >= 0 ? '+' : '') + n.toFixed(2) + '%'; }
  function esc(s) { return String(s).replace(/[&<>"']/g, function (c) { return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]; }); }

  function signalColor(v) {
    // 45 -> amber, 85 -> green
    var t = Math.max(0, Math.min(1, (v - 45) / 40));
    var hue = 45 + t * 97;
    return 'hsl(' + hue.toFixed(0) + ' 78% 45%)';
  }

  function avatar(t, cls) {
    if (t.img) return '<img class="' + cls + '" src="' + t.img + '" alt="" loading="lazy" />';
    var initials = t.symbol.slice(0, 2);
    return '<span class="' + cls + ' letter" style="--tc:' + t.color + '">' + esc(initials) + '</span>';
  }

  // ---------- filtering / sorting ----------
  function num(id) { return parseFloat($(id).value); }

  function visibleTokens() {
    var q = state.query.trim().toLowerCase();
    var minLiq = num('#fLiq'), minVol = num('#fVol'), minMcap = num('#fMcap'), minChg = num('#fChg'), minTx = num('#fTx');
    var list = D.tokens.filter(function (t) {
      if (state.cat !== 'all' && t.cats.indexOf(state.cat) < 0) return false;
      if (state.watchOnly && state.watch.indexOf(t.id) < 0) return false;
      if (t.liq < minLiq || t.vol < minVol || t.mcap < minMcap || t.change < minChg || t.txns < minTx) return false;
      if (q && t.name.toLowerCase().indexOf(q) < 0 && t.symbol.toLowerCase().indexOf(q) < 0 && t.address.indexOf(q) < 0) return false;
      return true;
    });
    var key = state.sortKey || TAB_SORT[state.tab][0];
    var dir = state.sortKey ? state.sortDir : TAB_SORT[state.tab][1];
    return list.sort(function (a, b) { return (a[key] - b[key]) * dir; });
  }

  // ---------- table ----------
  function rowHtml(t, rank) {
    var watched = state.watch.indexOf(t.id) >= 0;
    var chgCls = t.change >= 0 ? 'up' : 'down';
    return '<tr data-id="' + t.id + '">' +
      '<td class="c-rank">' + rank + '</td>' +
      '<td class="c-token"><div class="tok">' + avatar(t, 'tok-ic') +
        '<div class="tok-txt"><b>' + esc(t.name) + '</b><small>' + esc(t.symbol) + '</small></div></div></td>' +
      '<td class="c-price" data-label="Price">' + fmtPrice(t.price) + '</td>' +
      '<td class="c-chg ' + chgCls + '" data-label="24h %">' + fmtPct(t.change) + '</td>' +
      '<td class="c-liq" data-label="Liquidity">' + fmtMoney(t.liq) + '</td>' +
      '<td class="c-vol" data-label="24h Vol">' + fmtMoney(t.vol) + '</td>' +
      '<td class="c-mcap" data-label="MCap">' + fmtMoney(t.mcap) + '</td>' +
      '<td class="c-tx" data-label="Txns">' + fmtCount(t.txns) + '</td>' +
      '<td class="m-stats">' +
        '<div><small>Liquidity</small><b>' + fmtMoney(t.liq) + '</b></div>' +
        '<div><small>24h Vol</small><b class="m-vol">' + fmtMoney(t.vol) + '</b></div>' +
        '<div><small>MCap</small><b>' + fmtMoney(t.mcap) + '</b></div>' +
        '<div><small>Txns</small><b class="m-tx">' + fmtCount(t.txns) + '</b></div>' +
      '</td>' +
      '<td class="c-risk c-center"><span class="pill ' + t.risk.toLowerCase() + '">' + t.risk + '</span></td>' +
      '<td class="c-sig c-center"><span class="ring" style="--p:' + t.signal + ';--c:' + signalColor(t.signal) + '"><span>' + t.signal + '</span></span></td>' +
      '<td class="c-act c-center"><div class="acts">' +
        '<button class="act star' + (watched ? ' on' : '') + '" data-act="watch" aria-label="Add to watchlist" aria-pressed="' + watched + '"><svg><use href="#i-star"/></svg></button>' +
        '<button class="act" data-act="view" aria-label="Quick view"><svg><use href="#i-eye"/></svg></button>' +
        '<button class="act" data-act="chart" aria-label="Open chart"><svg><use href="#i-chart"/></svg></button>' +
      '</div></td>' +
    '</tr>';
  }

  function render() {
    var list = visibleTokens();
    var pages = Math.max(1, Math.ceil(list.length / PAGE_SIZE));
    if (state.page > pages) state.page = pages;
    var start = (state.page - 1) * PAGE_SIZE;
    var slice = list.slice(start, start + PAGE_SIZE);

    $('#tokenBody').innerHTML = slice.map(function (t, i) { return rowHtml(t, start + i + 1); }).join('');
    $('#emptyState').hidden = slice.length > 0;
    $('#showing').textContent = list.length
      ? 'Showing ' + (start + 1) + '–' + (start + slice.length) + ' of ' + (list.length >= 200 ? '200+' : list.length) + ' tokens'
      : 'Showing 0 tokens';
    renderPager(pages);

    var key = state.sortKey || TAB_SORT[state.tab][0];
    $$('th[data-sort]').forEach(function (th) {
      th.classList.toggle('sorted', !!state.sortKey && th.dataset.sort === key);
      th.classList.toggle('asc', !!state.sortKey && th.dataset.sort === key && state.sortDir === 1);
    });
  }

  function renderPager(pages) {
    var p = state.page, html = '';
    var from = Math.max(1, Math.min(p - 2, pages - 4)), to = Math.min(pages, from + 4);
    html += '<button class="pg nav" data-page="' + (p - 1) + '"' + (p === 1 ? ' disabled' : '') + ' aria-label="Previous page"><svg><use href="#i-chev-left"/></svg></button>';
    for (var i = from; i <= to; i++) html += '<button class="pg' + (i === p ? ' active' : '') + '" data-page="' + i + '">' + i + '</button>';
    if (to < pages) html += '<button class="pg" data-page="' + Math.min(pages, to + 1) + '" aria-label="More pages">…</button>';
    html += '<button class="pg nav" data-page="' + (p + 1) + '"' + (p === pages ? ' disabled' : '') + ' aria-label="Next page"><svg><use href="#i-chev-right"/></svg></button>';
    $('#pages').innerHTML = html;
  }

  // ---------- right rail ----------
  function renderRail() {
    $('#gainersList').innerHTML = D.gainers.map(function (g, i) {
      return '<li><span class="n">' + (i + 1) + '</span><img src="' + g.img + '" alt="" /><b>' + esc(g.name) + '</b><span class="up">' + fmtPct(g.change) + '</span></li>';
    }).join('');
    $('#pairsList').innerHTML = D.pairs.map(function (p, i) {
      return '<li><span class="n">' + (i + 1) + '</span><img src="' + p.img + '" alt="" /><b>' + esc(p.base) + '<i> / ' + esc(p.quote) + '</i></b><span class="ago">' + p.mins + 'm ago</span></li>';
    }).join('');
  }

  // ---------- chart ----------
  var TF = { '1H': [60, 11, 0.6], '24H': [72, 7, 1], '7D': [84, 3, 1.4], '30D': [90, 5, 2] };
  function series(tf) {
    var cfg = TF[tf], n = cfg[0], s = cfg[1] * 7919;
    function r() { s = (s * 16807) % 2147483647; return s / 2147483647; }
    var out = [], v = 40;
    for (var i = 0; i < n; i++) {
      v += (r() - 0.42) * 5 * cfg[2] + Math.sin(i / 2.6) * 2.2;
      out.push(v);
    }
    return out;
  }

  function renderChart() {
    var el = $('#chart');
    var w = el.clientWidth || 280, h = el.clientHeight || 110;
    var data = series(state.tf);
    var min = Math.min.apply(null, data), max = Math.max.apply(null, data);
    var pad = 6;
    var pts = data.map(function (v, i) {
      return [(i / (data.length - 1)) * (w - pad) + 1, h - 6 - ((v - min) / (max - min || 1)) * (h - 22)];
    });
    var line = pts.map(function (p, i) { return (i ? 'L' : 'M') + p[0].toFixed(1) + ' ' + p[1].toFixed(1); }).join(' ');
    var last = pts[pts.length - 1];
    el.innerHTML =
      '<svg width="' + w + '" height="' + h + '" viewBox="0 0 ' + w + ' ' + h + '" aria-label="Market cap trend">' +
        '<defs><linearGradient id="cg" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="var(--chart-fill-top)"/><stop offset="1" stop-color="var(--chart-fill-bottom)"/></linearGradient></defs>' +
        '<path d="' + line + ' L' + last[0].toFixed(1) + ' ' + h + ' L1 ' + h + ' Z" fill="url(#cg)" stroke="none"/>' +
        '<path d="' + line + '" fill="none" stroke="var(--chart-line)" stroke-width="1.8" stroke-linejoin="round"/>' +
        '<circle cx="' + last[0].toFixed(1) + '" cy="' + last[1].toFixed(1) + '" r="3.2" fill="var(--chart-line)" stroke="var(--card)" stroke-width="1.5"/>' +
      '</svg>';
  }

  // ---------- live updates ----------
  function tick() {
    var rows = $$('#tokenBody tr');
    rows.forEach(function (tr) {
      if (Math.random() > 0.35) return;
      var t = D.tokens.find(function (x) { return x.id === tr.dataset.id; });
      if (!t) return;
      var drift = (Math.random() - 0.48) * 0.012;
      t.price *= 1 + drift;
      t.change = +(t.change + drift * 100).toFixed(2);
      t.vol *= 1 + Math.abs(drift) * 0.5;
      t.txns += Math.round(Math.random() * 40);
      $('.c-price', tr).textContent = fmtPrice(t.price);
      var chg = $('.c-chg', tr);
      chg.textContent = fmtPct(t.change);
      chg.className = 'c-chg ' + (t.change >= 0 ? 'up' : 'down');
      $('.c-vol', tr).textContent = fmtMoney(t.vol);
      $('.c-tx', tr).textContent = fmtCount(t.txns);
      $('.m-vol', tr).textContent = fmtMoney(t.vol);
      $('.m-tx', tr).textContent = fmtCount(t.txns);
      tr.classList.remove('flash-up', 'flash-down');
      void tr.offsetWidth;
      tr.classList.add(drift >= 0 ? 'flash-up' : 'flash-down');
    });
  }

  function updateClock() {
    var d = new Date();
    var date = d.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
    var time = d.toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit' });
    $('#liveClock').textContent = date + ' ' + time;
  }

  // ---------- UI helpers ----------
  var toastTimer;
  function toast(msg) {
    var el = $('#toast');
    el.textContent = msg;
    el.classList.add('show');
    clearTimeout(toastTimer);
    toastTimer = setTimeout(function () { el.classList.remove('show'); }, 2600);
  }

  function setNav(open) {
    document.body.classList.toggle('nav-open', open);
  }

  function applyTheme(theme) {
    document.documentElement.dataset.theme = theme;
    $('#themeBtn use').setAttribute('href', theme === 'dark' ? '#i-moon' : '#i-sun');
    try { localStorage.setItem('eyes-theme', theme); } catch (e) {}
    renderChart();
  }

  // ---------- events ----------
  function bind() {
    $$('.tab').forEach(function (b) {
      b.addEventListener('click', function () {
        $$('.tab').forEach(function (x) { x.classList.toggle('active', x === b); x.setAttribute('aria-selected', x === b); });
        state.tab = b.dataset.tab;
        state.sortKey = null;
        state.page = 1;
        render();
      });
    });

    $('#chips').addEventListener('click', function (e) {
      var c = e.target.closest('.chip');
      if (!c) return;
      $$('.chip').forEach(function (x) { x.classList.toggle('active', x === c); });
      state.cat = c.dataset.cat;
      state.page = 1;
      render();
    });

    ['#fLiq', '#fVol', '#fMcap', '#fChg', '#fTx'].forEach(function (id) {
      $(id).addEventListener('change', function () {
        $(id).closest('.filter').classList.toggle('set', $(id).selectedIndex > 0);
        state.page = 1;
        render();
      });
    });
    $('#resetFilters').addEventListener('click', function () {
      ['#fLiq', '#fVol', '#fMcap', '#fChg', '#fTx'].forEach(function (id) { $(id).selectedIndex = 0; $(id).closest('.filter').classList.remove('set'); });
      state.query = ''; $('#tableSearch').value = ''; $('#globalSearch').value = '';
      state.watchOnly = false; $$('[data-nav="watchlist"]').forEach(function (a) { a.classList.remove('on'); });
      state.page = 1;
      render();
      toast('Filters reset');
    });

    function onSearch(e) {
      state.query = e.target.value;
      if (e.target.id === 'globalSearch') $('#tableSearch').value = state.query;
      else $('#globalSearch').value = state.query;
      state.page = 1;
      render();
    }
    $('#tableSearch').addEventListener('input', onSearch);
    $('#globalSearch').addEventListener('input', onSearch);
    $('#globalSearch').addEventListener('keydown', function (e) {
      if (e.key === 'Enter') $('.screener').scrollIntoView({ behavior: 'smooth', block: 'start' });
    });

    $$('th[data-sort]').forEach(function (th) {
      th.addEventListener('click', function () {
        var k = th.dataset.sort;
        if (state.sortKey === k) state.sortDir *= -1;
        else { state.sortKey = k; state.sortDir = -1; }
        render();
      });
    });

    $('#pages').addEventListener('click', function (e) {
      var b = e.target.closest('.pg');
      if (!b || b.disabled) return;
      state.page = +b.dataset.page;
      render();
      var top = $('.screener').getBoundingClientRect().top;
      if (top < 0) $('.screener').scrollIntoView({ behavior: 'smooth', block: 'start' });
    });

    $('#tokenBody').addEventListener('click', function (e) {
      var b = e.target.closest('.act');
      if (!b) return;
      var id = b.closest('tr').dataset.id;
      var t = D.tokens.find(function (x) { return x.id === id; });
      if (b.dataset.act === 'watch') {
        var i = state.watch.indexOf(id);
        if (i >= 0) state.watch.splice(i, 1); else state.watch.push(id);
        save('eyes-watchlist', state.watch);
        b.classList.toggle('on', i < 0);
        b.setAttribute('aria-pressed', i < 0);
        toast(i < 0 ? t.name + ' added to Watchlist' : t.name + ' removed from Watchlist');
        if (state.watchOnly) render();
      } else if (b.dataset.act === 'view') {
        toast(t.name + ' · ' + fmtPrice(t.price) + ' · AI signal ' + t.signal + '/100 · ' + t.risk + ' risk');
      } else {
        window.open('https://dexscreener.com/search?q=' + encodeURIComponent(t.symbol), '_blank', 'noopener');
      }
    });

    $$('[data-nav="watchlist"]').forEach(function (a) {
      a.addEventListener('click', function (e) {
        e.preventDefault();
        state.watchOnly = !state.watchOnly;
        $$('[data-nav="watchlist"]').forEach(function (x) { x.classList.toggle('on', state.watchOnly); });
        state.page = 1;
        render();
        setNav(false);
        toast(state.watchOnly ? 'Showing your Watchlist (' + state.watch.length + ')' : 'Showing all tokens');
      });
    });

    $('#tfSeg').addEventListener('click', function (e) {
      var b = e.target.closest('button');
      if (!b) return;
      $$('#tfSeg button').forEach(function (x) { x.classList.toggle('active', x === b); });
      state.tf = b.dataset.tf;
      renderChart();
    });

    $('#menuBtn').addEventListener('click', function () { setNav(true); });
    $('#bnMore').addEventListener('click', function (e) { e.preventDefault(); setNav(true); });
    $('#closeMenu').addEventListener('click', function () { setNav(false); });
    $('#scrim').addEventListener('click', function () { setNav(false); });
    document.addEventListener('keydown', function (e) { if (e.key === 'Escape') { setNav(false); $('#notifPop').hidden = true; } });

    $('#themeBtn').addEventListener('click', function () {
      applyTheme(document.documentElement.dataset.theme === 'dark' ? 'light' : 'dark');
    });

    $('#notifBtn').addEventListener('click', function (e) {
      e.stopPropagation();
      var pop = $('#notifPop');
      pop.hidden = !pop.hidden;
      $('#notifBtn').setAttribute('aria-expanded', !pop.hidden);
      $('#notifBtn .badge').hidden = true;
    });
    document.addEventListener('click', function (e) {
      if (!e.target.closest('.notif-wrap')) $('#notifPop').hidden = true;
    });

    $('#walletBtn').addEventListener('click', function () {
      var btn = $('#walletBtn');
      if (!window.ethereum) { toast('No wallet found. Install MetaMask or Trust Wallet to connect.'); return; }
      window.ethereum.request({ method: 'eth_requestAccounts' }).then(function (accs) {
        var a = accs && accs[0];
        if (!a) return;
        $('span', btn).textContent = a.slice(0, 6) + '…' + a.slice(-4);
        btn.classList.add('connected');
        toast('Wallet connected');
      }).catch(function () { toast('Wallet connection cancelled'); });
    });

    var rz;
    window.addEventListener('resize', function () { clearTimeout(rz); rz = setTimeout(renderChart, 120); });
  }

  // ---------- init ----------
  bind();
  render();
  renderRail();
  applyTheme(document.documentElement.dataset.theme === 'dark' ? 'dark' : 'light');
  updateClock();
  setInterval(updateClock, 15000);
  setInterval(tick, 3500);
})();
