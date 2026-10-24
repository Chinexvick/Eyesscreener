/* Screener page: table, filters, tabs, market overview rail. Shared chrome lives in common.js. */
(function () {
  'use strict';

  var E = window.EYES, D = E.data, fmt = E.fmt, $ = E.$, $$ = E.$$;
  var PAGE_SIZE = 10;

  var state = { tab: 'gainers', cat: 'all', query: '', sortKey: null, sortDir: -1, page: 1, tf: '24H' };

  var TAB_SORT = {
    gainers: ['change', -1],
    new: ['age', 1],
    trending: ['trend', -1],
    liquidity: ['liq', -1],
    ai: ['signal', -1]
  };

  // ---------- filtering / sorting ----------
  function num(id) { return parseFloat($(id).value); }

  function visibleTokens() {
    var q = state.query.trim().toLowerCase();
    var minLiq = num('#fLiq'), minVol = num('#fVol'), minMcap = num('#fMcap'), minChg = num('#fChg'), minTx = num('#fTx');
    var list = D.tokens.filter(function (t) {
      if (state.cat !== 'all' && t.cats.indexOf(state.cat) < 0) return false;
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
    var watched = E.watch.has(t.id);
    var chgCls = t.change >= 0 ? 'up' : 'down';
    return '<tr data-id="' + t.id + '">' +
      '<td class="c-rank">' + rank + '</td>' +
      '<td class="c-token"><a class="tok" href="/token?s=' + encodeURIComponent(t.symbol) + '">' + E.avatar(t, 'tok-ic') +
        '<div class="tok-txt"><b>' + fmt.esc(t.name) + '</b><small>' + fmt.esc(t.symbol) + '</small></div></a></td>' +
      '<td class="c-price" data-label="Price">' + fmt.price(t.price) + '</td>' +
      '<td class="c-chg ' + chgCls + '" data-label="24h %">' + fmt.pct(t.change) + '</td>' +
      '<td class="c-liq" data-label="Liquidity">' + fmt.money(t.liq) + '</td>' +
      '<td class="c-vol" data-label="24h Volume">' + fmt.money(t.vol) + '</td>' +
      '<td class="c-mcap" data-label="Market Cap">' + fmt.money(t.mcap) + '</td>' +
      '<td class="c-tx" data-label="Txns">' + fmt.count(t.txns) + '</td>' +
      '<td class="m-stats">' +
        '<div><small>Liquidity</small><b>' + fmt.money(t.liq) + '</b></div>' +
        '<div><small>24h Vol</small><b class="m-vol">' + fmt.money(t.vol) + '</b></div>' +
        '<div><small>MCap</small><b>' + fmt.money(t.mcap) + '</b></div>' +
        '<div><small>Txns</small><b class="m-tx">' + fmt.count(t.txns) + '</b></div>' +
      '</td>' +
      '<td class="c-risk c-center"><span class="pill ' + t.risk.toLowerCase() + '">' + t.risk + '</span></td>' +
      '<td class="c-sig c-center">' + E.ring(t.signal) + '</td>' +
      '<td class="c-act c-center"><div class="acts">' +
        '<button class="act star' + (watched ? ' on' : '') + '" data-act="watch" aria-label="Add to watchlist" aria-pressed="' + watched + '"><svg><use href="#i-star"/></svg></button>' +
        '<a class="act" href="/token?s=' + encodeURIComponent(t.symbol) + '" aria-label="Open details"><svg><use href="#i-eye"/></svg></a>' +
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
      return '<li><span class="n">' + (i + 1) + '</span><img src="/' + g.img + '" alt="" /><b>' + fmt.esc(g.name) + '</b><span class="up">' + fmt.pct(g.change) + '</span></li>';
    }).join('');
    $('#pairsList').innerHTML = D.pairs.map(function (p, i) {
      return '<li><span class="n">' + (i + 1) + '</span><img src="/' + p.img + '" alt="" /><b>' + fmt.esc(p.base) + '<i> / ' + fmt.esc(p.quote) + '</i></b><span class="ago">' + p.mins + 'm ago</span></li>';
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
    if (E.store.get('eyes-settings', {}).live === false) return;
    $$('#tokenBody tr').forEach(function (tr) {
      if (Math.random() > 0.35) return;
      var t = D.tokens.filter(function (x) { return x.id === tr.dataset.id; })[0];
      if (!t) return;
      var drift = (Math.random() - 0.48) * 0.012;
      t.price *= 1 + drift;
      t.change = +(t.change + drift * 100).toFixed(2);
      t.vol *= 1 + Math.abs(drift) * 0.5;
      t.txns += Math.round(Math.random() * 40);
      $('.c-price', tr).textContent = fmt.price(t.price);
      var chg = $('.c-chg', tr);
      chg.textContent = fmt.pct(t.change);
      chg.className = 'c-chg ' + (t.change >= 0 ? 'up' : 'down');
      $('.c-vol', tr).textContent = fmt.money(t.vol);
      $('.c-tx', tr).textContent = fmt.count(t.txns);
      $('.m-vol', tr).textContent = fmt.money(t.vol);
      $('.m-tx', tr).textContent = fmt.count(t.txns);
      tr.classList.remove('flash-up', 'flash-down');
      void tr.offsetWidth;
      tr.classList.add(drift >= 0 ? 'flash-up' : 'flash-down');
    });
  }

  function updateClock() {
    var d = new Date();
    $('#liveClock').textContent = d.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' }) + ' ' +
      d.toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit' });
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

    var filters = ['#fLiq', '#fVol', '#fMcap', '#fChg', '#fTx'];
    filters.forEach(function (id) {
      $(id).addEventListener('change', function () {
        $(id).closest('.filter').classList.toggle('set', $(id).selectedIndex > 0);
        state.page = 1;
        render();
      });
    });
    $('#resetFilters').addEventListener('click', function () {
      filters.forEach(function (id) { $(id).selectedIndex = 0; $(id).closest('.filter').classList.remove('set'); });
      state.query = ''; $('#tableSearch').value = ''; $('#globalSearch').value = '';
      state.page = 1;
      render();
      E.toast('Filters reset');
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
      if ($('.screener').getBoundingClientRect().top < 0) $('.screener').scrollIntoView({ behavior: 'smooth', block: 'start' });
    });

    $('#tokenBody').addEventListener('click', function (e) {
      var b = e.target.closest('button.act');
      if (!b) return;
      var id = b.closest('tr').dataset.id;
      var t = D.tokens.filter(function (x) { return x.id === id; })[0];
      if (b.dataset.act === 'watch') {
        var on = E.watch.toggle(id);
        b.classList.toggle('on', on);
        b.setAttribute('aria-pressed', on);
        E.toast(on ? t.name + ' added to Watchlist' : t.name + ' removed from Watchlist');
      } else {
        window.open('https://dexscreener.com/search?q=' + encodeURIComponent(t.symbol), '_blank', 'noopener');
      }
    });

    $('#tfSeg').addEventListener('click', function (e) {
      var b = e.target.closest('button');
      if (!b) return;
      $$('#tfSeg button').forEach(function (x) { x.classList.toggle('active', x === b); });
      state.tf = b.dataset.tf;
      renderChart();
    });

    var rz;
    window.addEventListener('resize', function () { clearTimeout(rz); rz = setTimeout(renderChart, 120); });
    document.addEventListener('eyes:theme', renderChart);
  }

  // ---------- init ----------
  var initial = new URLSearchParams(location.search).get('q');
  if (initial) { state.query = initial; $('#tableSearch').value = initial; $('#globalSearch').value = initial; }
  var tabParam = new URLSearchParams(location.search).get('tab');
  if (tabParam && TAB_SORT[tabParam]) {
    state.tab = tabParam;
    $$('.tab').forEach(function (x) { x.classList.toggle('active', x.dataset.tab === tabParam); });
  }
  bind();
  render();
  renderRail();
  renderChart();
  updateClock();
  setInterval(updateClock, 15000);
  setInterval(tick, 3500);
})();
