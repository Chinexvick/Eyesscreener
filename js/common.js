/* Shared behaviour for every page: helpers, storage, risk model, theme, menu, wallet, toasts. */
(function () {
  'use strict';

  var D = window.EYES_DATA;
  var $ = function (s, r) { return (r || document).querySelector(s); };
  var $$ = function (s, r) { return Array.prototype.slice.call((r || document).querySelectorAll(s)); };

  // ---------- storage (best effort) ----------
  var store = {
    get: function (key, fallback) {
      try { var v = localStorage.getItem(key); return v ? JSON.parse(v) : fallback; } catch (e) { return fallback; }
    },
    set: function (key, val) {
      try { localStorage.setItem(key, JSON.stringify(val)); } catch (e) {}
    }
  };

  // ---------- formatting ----------
  var fmt = {
    price: function (p) {
      if (p >= 1000) return '$' + p.toLocaleString('en-US', { maximumFractionDigits: 0 });
      if (p >= 1) return '$' + p.toFixed(2);
      var dec = Math.ceil(-Math.log10(p)) + 2;
      return '$' + p.toFixed(Math.min(dec, 12)).replace(/(\.\d*?[1-9])0+$/, '$1');
    },
    money: function (n) {
      if (n >= 1e9) return '$' + (n / 1e9).toFixed(1) + 'B';
      if (n >= 1e6) return '$' + (n / 1e6).toFixed(1) + 'M';
      if (n >= 1e3) return '$' + (n / 1e3).toFixed(1) + 'K';
      return '$' + n.toFixed(0);
    },
    count: function (n) {
      if (n >= 1e6) return (n / 1e6).toFixed(1) + 'M';
      if (n >= 1e3) return (n / 1e3).toFixed(1) + 'K';
      return String(Math.round(n));
    },
    pct: function (n) { return (n >= 0 ? '+' : '') + n.toFixed(2) + '%'; },
    ago: function (mins) {
      if (mins < 60) return Math.max(1, Math.round(mins)) + 'm ago';
      if (mins < 1440) return Math.round(mins / 60) + 'h ago';
      return Math.round(mins / 1440) + 'd ago';
    },
    esc: function (s) {
      return String(s).replace(/[&<>"']/g, function (c) { return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]; });
    },
    short: function (a) { return a.slice(0, 6) + '…' + a.slice(-4); }
  };

  // ---------- tokens ----------
  var RISK_N = { Low: 1, Medium: 2, High: 3 };
  if (D) D.tokens.forEach(function (t) { t.riskN = RISK_N[t.risk]; });

  function findToken(q) {
    if (!q || !D) return null;
    q = String(q).trim().toLowerCase();
    return D.tokens.filter(function (t) {
      return t.symbol.toLowerCase() === q || t.address.toLowerCase() === q || t.name.toLowerCase() === q;
    })[0] || null;
  }

  function avatar(t, cls) {
    if (t.img) return '<img class="' + cls + '" src="/' + t.img + '" alt="" loading="lazy" />';
    return '<span class="' + cls + ' letter" style="--tc:' + t.color + '">' + fmt.esc(t.symbol.slice(0, 2)) + '</span>';
  }

  function signalColor(v) {
    var t = Math.max(0, Math.min(1, (v - 45) / 40));
    return 'hsl(' + (45 + t * 97).toFixed(0) + ' 78% 45%)';
  }

  function ring(v) {
    return '<span class="ring" style="--p:' + v + ';--c:' + signalColor(v) + '"><span>' + v + '</span></span>';
  }

  // ---------- deterministic risk model (demo) ----------
  function seeded(str) {
    var h = 2166136261;
    for (var i = 0; i < str.length; i++) { h ^= str.charCodeAt(i); h = Math.imul(h, 16777619); }
    return function () { h = Math.imul(h ^ (h >>> 15), 2246822507); h = Math.imul(h ^ (h >>> 13), 3266489909); h ^= h >>> 16; return (h >>> 0) / 4294967296; };
  }
  function between(r, a, b) { return a + (b - a) * r(); }

  var analysisCache = {};
  function analyse(t) {
    if (analysisCache[t.id]) return analysisCache[t.id];
    var r = seeded(t.id + ':risk');
    var lvl = t.risk;
    var a = {
      lpLocked: Math.round(lvl === 'Low' ? between(r, 86, 100) : lvl === 'Medium' ? between(r, 40, 80) : between(r, 0, 35)),
      lockDays: Math.round(lvl === 'Low' ? between(r, 180, 720) : lvl === 'Medium' ? between(r, 30, 150) : between(r, 0, 20)),
      renounced: lvl === 'Low' ? true : lvl === 'Medium' ? r() > 0.5 : false,
      buyTax: +(lvl === 'Low' ? between(r, 0, 3) : lvl === 'Medium' ? between(r, 3, 8) : between(r, 8, 20)).toFixed(1),
      sellTax: +(lvl === 'Low' ? between(r, 0, 3) : lvl === 'Medium' ? between(r, 3, 9) : between(r, 10, 28)).toFixed(1),
      top10: Math.round(lvl === 'Low' ? between(r, 14, 30) : lvl === 'Medium' ? between(r, 30, 48) : between(r, 50, 82)),
      holders: Math.round(Math.max(300, t.txns * between(r, 0.5, 2.2))),
      honeypot: lvl === 'High' && r() > 0.6,
      verified: lvl === 'High' ? r() > 0.55 : true,
      mintable: lvl === 'High' ? r() > 0.4 : lvl === 'Medium' ? r() > 0.8 : false,
      ageDays: Math.max(1, Math.round(t.age))
    };
    var score = lvl === 'Low' ? between(r, 78, 95) : lvl === 'Medium' ? between(r, 52, 72) : between(r, 14, 44);
    if (a.honeypot) score = Math.min(score, 18);
    a.score = Math.round(score);
    a.level = lvl;

    var flags = [];
    var TAGS = { honeypot: 'Honeypot', lp: 'Unlocked LP', owner: 'Owner not renounced', tax: 'High tax', holders: 'Whale heavy', mint: 'Mintable', verified: 'Unverified' };
    function flag(id, label, status, detail) { flags.push({ id: id, label: label, tag: TAGS[id], status: status, detail: detail }); }
    flag('honeypot', 'Honeypot check', a.honeypot ? 'bad' : 'good', a.honeypot ? 'Sells are blocked or heavily restricted in simulation' : 'Buy and sell simulation passed');
    flag('lp', 'Liquidity locked', a.lpLocked >= 80 ? 'good' : a.lpLocked >= 40 ? 'warn' : 'bad', a.lpLocked + '% of LP locked' + (a.lockDays ? ' for ' + a.lockDays + ' more days' : ' — can be removed any time'));
    flag('owner', 'Ownership', a.renounced ? 'good' : 'warn', a.renounced ? 'Contract ownership renounced' : 'Owner can still change contract settings');
    flag('tax', 'Buy / sell tax', a.sellTax <= 5 ? 'good' : a.sellTax <= 10 ? 'warn' : 'bad', 'Buy ' + a.buyTax + '% · Sell ' + a.sellTax + '%');
    flag('holders', 'Holder concentration', a.top10 <= 30 ? 'good' : a.top10 <= 50 ? 'warn' : 'bad', 'Top 10 wallets hold ' + a.top10 + '% of supply');
    flag('mint', 'Mint function', a.mintable ? 'bad' : 'good', a.mintable ? 'Owner can mint new tokens' : 'No mint function found');
    flag('verified', 'Source code', a.verified ? 'good' : 'warn', a.verified ? 'Verified on BscScan' : 'Contract source is not verified');
    a.flags = flags;
    a.bad = flags.filter(function (f) { return f.status === 'bad'; }).length;
    a.warn = flags.filter(function (f) { return f.status === 'warn'; }).length;

    var verdict = a.score >= 75 ? 'Looks relatively safe' : a.score >= 50 ? 'Proceed with caution' : 'High risk';
    a.verdict = verdict;
    a.summary = t.name + ' (' + t.symbol + ') scores ' + a.score + '/100 for safety — ' + verdict.toLowerCase() + '. ' +
      (a.bad ? a.bad + ' critical issue' + (a.bad > 1 ? 's' : '') + ' found' + (a.warn ? ' and ' + a.warn + ' warning' + (a.warn > 1 ? 's' : '') : '') + '. ' :
        a.warn ? 'No critical issues, but ' + a.warn + ' warning' + (a.warn > 1 ? 's' : '') + ' to review. ' : 'No critical issues were found. ') +
      'It is trading ' + fmt.pct(t.change) + ' over 24h on ' + fmt.money(t.vol) + ' of volume, with ' + fmt.money(t.liq) + ' of liquidity.';
    analysisCache[t.id] = a;
    return a;
  }

  // ---------- watchlist ----------
  var watch = {
    list: function () { return store.get('eyes-watchlist', ['BABYDOGE']); },
    has: function (id) { return watch.list().indexOf(id) >= 0; },
    toggle: function (id) {
      var l = watch.list(), i = l.indexOf(id);
      if (i >= 0) l.splice(i, 1); else l.push(id);
      store.set('eyes-watchlist', l);
      syncWatchCount();
      return i < 0;
    }
  };
  function syncWatchCount() {
    var n = watch.list().length, el = $('#navWatchCount');
    if (!el) return;
    el.textContent = n;
    el.hidden = n === 0;
  }

  // ---------- toast ----------
  var toastTimer;
  function toast(msg) {
    var el = $('#toast');
    if (!el) {
      el = document.createElement('div');
      el.id = 'toast'; el.className = 'toast'; el.setAttribute('role', 'status'); el.setAttribute('aria-live', 'polite');
      document.body.appendChild(el);
    }
    el.textContent = msg;
    el.classList.add('show');
    clearTimeout(toastTimer);
    toastTimer = setTimeout(function () { el.classList.remove('show'); }, 2600);
  }

  // ---------- chrome ----------
  function setNav(open) { document.body.classList.toggle('nav-open', open); }

  function applyTheme(theme, persist) {
    document.documentElement.dataset.theme = theme;
    var use = $('#themeBtn use');
    if (use) use.setAttribute('href', theme === 'dark' ? '#i-moon' : '#i-sun');
    if (persist) { try { localStorage.setItem('eyes-theme', theme); localStorage.setItem('eyes-theme-mode', theme); } catch (e) {} }
    document.dispatchEvent(new CustomEvent('eyes:theme', { detail: theme }));
  }
  function currentTheme() {
    var t = document.documentElement.dataset.theme;
    if (t) return t;
    return window.matchMedia && matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
  }

  function bindChrome() {
    var menu = $('#menuBtn'), close = $('#closeMenu'), scrim = $('#scrim'), more = $('#bnMore');
    if (menu) menu.addEventListener('click', function () { setNav(true); });
    if (close) close.addEventListener('click', function () { setNav(false); });
    if (scrim) scrim.addEventListener('click', function () { setNav(false); });
    // On phones the bottom "More" opens the full menu; the menu's own "More" goes to the hub page.
    if (more) more.addEventListener('click', function (e) {
      if (window.matchMedia('(max-width: 1024px)').matches) { e.preventDefault(); setNav(true); }
    });
    document.addEventListener('keydown', function (e) {
      if (e.key === 'Escape') { setNav(false); var p = $('#notifPop'); if (p) p.hidden = true; }
    });

    var themeBtn = $('#themeBtn');
    if (themeBtn) themeBtn.addEventListener('click', function () { applyTheme(currentTheme() === 'dark' ? 'light' : 'dark', true); });

    var nb = $('#notifBtn'), pop = $('#notifPop');
    if (nb && pop) {
      nb.addEventListener('click', function (e) {
        e.stopPropagation();
        pop.hidden = !pop.hidden;
        nb.setAttribute('aria-expanded', !pop.hidden);
        var badge = $('.badge', nb); if (badge) badge.hidden = true;
      });
      document.addEventListener('click', function (e) { if (!e.target.closest('.notif-wrap')) pop.hidden = true; });
    }

    var wb = $('#walletBtn');
    if (wb) wb.addEventListener('click', function () {
      if (!window.ethereum) { toast('No wallet found. Install MetaMask or Trust Wallet to connect.'); return; }
      window.ethereum.request({ method: 'eth_requestAccounts' }).then(function (accs) {
        var a = accs && accs[0];
        if (!a) return;
        $('span', wb).textContent = fmt.short(a);
        wb.classList.add('connected');
        toast('Wallet connected');
      }).catch(function () { toast('Wallet connection cancelled'); });
    });

    // Header search: the screener filters in place; other pages jump to it.
    var gs = $('#globalSearch');
    if (gs && document.body.dataset.page !== 'screener') {
      gs.addEventListener('keydown', function (e) {
        if (e.key !== 'Enter' || !gs.value.trim()) return;
        var t = findToken(gs.value);
        location.href = t ? '/token?s=' + encodeURIComponent(t.symbol) : '/?q=' + encodeURIComponent(gs.value.trim());
      });
    }
  }

  function init() {
    applyTheme(currentTheme(), false);
    bindChrome();
    syncWatchCount();
  }

  window.EYES = {
    data: D, $: $, $$: $$, store: store, fmt: fmt, find: findToken, avatar: avatar, ring: ring,
    signalColor: signalColor, analyse: analyse, watch: watch, toast: toast, seeded: seeded, setNav: setNav
  };

  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init); else init();
})();
