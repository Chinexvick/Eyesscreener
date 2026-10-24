(function () {
  'use strict';
  var E = window.EYES, D = E.data, fmt = E.fmt, $ = E.$;
  var KEY = 'eyes-alerts';
  var rules = E.store.get(KEY, null);
  if (!rules) { rules = [{ id: 1, sym: 'TST', cond: 'changeAbove', val: 100, on: true }, { id: 2, sym: 'FLOKI', cond: 'priceBelow', val: 0.00015, on: true }]; E.store.set(KEY, rules); }

  var COND = {
    priceAbove: { label: function (v) { return 'price goes above ' + fmt.price(v); }, test: function (t, v) { return t.price > v; } },
    priceBelow: { label: function (v) { return 'price falls below ' + fmt.price(v); }, test: function (t, v) { return t.price < v; } },
    changeAbove: { label: function (v) { return '24h change is above ' + v + '%'; }, test: function (t, v) { return t.change > v; } },
    signalAbove: { label: function (v) { return 'AI signal is above ' + v; }, test: function (t, v) { return t.signal > v; } },
    liqBelow: { label: function (v) { return 'liquidity falls below ' + fmt.money(v); }, test: function (t, v) { return t.liq < v; } },
    riskHigh: { label: function () { return 'risk becomes High'; }, test: function (t) { return t.risk === 'High'; } }
  };

  $('#aList').innerHTML = D.tokens.slice(0, 80).map(function (t) { return '<option value="' + fmt.esc(t.symbol) + '">' + fmt.esc(t.name) + '</option>'; }).join('');
  var pre = new URLSearchParams(location.search).get('s');
  if (pre) $('#aToken').value = pre;
  $('#aCond').addEventListener('change', function () { $('#aVal').disabled = this.value === 'riskHigh'; $('#aVal').required = this.value !== 'riskHigh'; });
  $('#aVal').required = true;

  function save() { E.store.set(KEY, rules); }

  function renderRules() {
    $('#aCount').textContent = rules.length ? rules.length + ' active' : '';
    $('#aRules').innerHTML = rules.length ? rules.map(function (r) {
      var t = E.find(r.sym), hit = t && r.on && COND[r.cond].test(t, r.val);
      return '<div class="rule" data-id="' + r.id + '">' + (t ? E.avatar(t, 'tok-ic') : '') +
        '<div class="txt"><b>' + fmt.esc(r.sym) + '</b> ' + COND[r.cond].label(r.val) +
        '<small>' + (hit ? '<span class="t-good">● Triggered now</span> · ' : '') + (t ? 'Now ' + fmt.price(t.price) + ' · ' + fmt.pct(t.change) : 'Token not found') + '</small></div>' +
        '<button class="switch" role="switch" aria-checked="' + r.on + '" data-act="toggle" aria-label="Enable alert"></button>' +
        '<button class="act" data-act="del" aria-label="Delete alert"><svg><use href="#i-trash"/></svg></button></div>';
    }).join('') : '<div class="empty-state"><div class="big"><svg><use href="#i-bell"/></svg></div><h3>No alerts yet</h3><p>Create your first alert above and we will flag it when the condition is met.</p></div>';
  }

  // Signal feed from current data: a mix of momentum, safety and discovery signals.
  function renderFeed() {
    var items = [], bySig = D.tokens.slice().sort(function (a, b) { return b.signal - a.signal; });
    var up = D.tokens.slice().sort(function (a, b) { return b.change - a.change; });
    var hi = D.tokens.filter(function (t) { return t.risk === 'High'; });
    items.push({ c: 'good', i: '#i-trend-up', t: up[0].symbol + ' is up ' + fmt.pct(up[0].change).replace('+', '') + ' in 24h', d: 'Strongest mover on ' + fmt.money(up[0].vol) + ' of volume.', m: 3 });
    items.push({ c: 'good', i: '#i-brain', t: 'AI signal ' + bySig[0].signal + ' on ' + bySig[0].symbol, d: 'Highest AI score across tracked BNB Chain pairs.', m: 9 });
    if (hi[0]) items.push({ c: 'bad', i: '#i-alert', t: 'Risk warning: ' + hi[0].symbol, d: 'Liquidity is mostly unlocked and taxes are high. Be careful.', m: 14 });
    items.push({ c: 'warn', i: '#i-sparkles', t: D.pairs[1].base + '/' + D.pairs[1].quote + ' new pair', d: 'Listed ' + D.pairs[1].mins + ' minutes ago. Early liquidity is thin.', m: D.pairs[1].mins + 6 });
    items.push({ c: 'good', i: '#i-droplet', t: 'Liquidity added to ' + up[2].symbol, d: 'Pool depth is now ' + fmt.money(up[2].liq) + '.', m: 31 });
    if (hi[1]) items.push({ c: 'bad', i: '#i-lock', t: hi[1].symbol + ' liquidity unlocked', d: 'Deployer can withdraw liquidity at any time.', m: 52 });
    $('#aFeed').innerHTML = items.map(function (x) {
      return '<li class="c-' + x.c + '"><span class="ic"><svg><use href="' + x.i + '"/></svg></span><div><b>' + fmt.esc(x.t) + '</b><p>' + fmt.esc(x.d) + '</p></div><time>' + fmt.ago(x.m) + '</time></li>';
    }).join('');
  }

  $('#aForm').addEventListener('submit', function (e) {
    e.preventDefault();
    var t = E.find($('#aToken').value);
    if (!t) { E.toast('Pick a token from the list'); return; }
    var cond = $('#aCond').value, val = parseFloat($('#aVal').value);
    if (cond !== 'riskHigh' && isNaN(val)) { E.toast('Enter a value'); return; }
    rules.unshift({ id: Date.now(), sym: t.symbol, cond: cond, val: cond === 'riskHigh' ? 0 : val, on: true });
    save(); renderRules();
    E.toast('Alert added for ' + t.symbol);
    $('#aVal').value = '';
    if (COND[cond].test(t, val)) setTimeout(function () { E.toast(t.symbol + ' already meets this condition'); }, 2800);
  });

  $('#aRules').addEventListener('click', function (e) {
    var b = e.target.closest('[data-act]'); if (!b) return;
    var id = +b.closest('.rule').dataset.id, i = rules.findIndex(function (r) { return r.id === id; });
    if (b.dataset.act === 'toggle') rules[i].on = !rules[i].on;
    else { rules.splice(i, 1); E.toast('Alert deleted'); }
    save(); renderRules();
  });

  renderRules(); renderFeed();
  var fired = rules.filter(function (r) { var t = E.find(r.sym); return r.on && t && COND[r.cond].test(t, r.val); });
  if (fired.length) setTimeout(function () { E.toast(fired.length + ' alert' + (fired.length > 1 ? 's' : '') + ' triggered'); }, 600);
})();
