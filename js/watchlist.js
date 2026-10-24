(function () {
  'use strict';
  var E = window.EYES, D = E.data, fmt = E.fmt, $ = E.$;

  $('#wList').innerHTML = D.tokens.slice(0, 80).map(function (t) { return '<option value="' + fmt.esc(t.symbol) + '">' + fmt.esc(t.name) + '</option>'; }).join('');

  function render() {
    var list = E.watch.list().map(function (id) { return D.tokens.filter(function (t) { return t.id === id; })[0]; }).filter(Boolean);
    $('#wEmpty').hidden = list.length > 0;
    $('.wl-table').hidden = list.length === 0;
    if (!list.length) { $('#wStats').innerHTML = ''; $('#wBody').innerHTML = ''; return; }

    var avg = list.reduce(function (s, t) { return s + t.change; }, 0) / list.length;
    var best = list.slice().sort(function (a, b) { return b.change - a.change; })[0];
    var risky = list.filter(function (t) { return t.risk === 'High'; }).length;
    $('#wStats').innerHTML =
      '<div class="card stat"><small>Tokens tracked</small><b>' + list.length + '</b><span class="delta muted">in your watchlist</span></div>' +
      '<div class="card stat"><small>Average 24h change</small><b class="' + (avg >= 0 ? 'up' : 'down') + '">' + fmt.pct(avg) + '</b><span class="delta muted">across all tokens</span></div>' +
      '<div class="card stat"><small>Best performer</small><b>' + fmt.esc(best.symbol) + '</b><span class="delta ' + (best.change >= 0 ? 'up' : 'down') + '">' + fmt.pct(best.change) + '</span></div>';

    $('#wBody').innerHTML = list.map(function (t) {
      return '<tr data-id="' + t.id + '">' +
        '<td class="w-tok"><a class="tok" href="/token?s=' + encodeURIComponent(t.symbol) + '">' + E.avatar(t, 'tok-ic') + '<div class="tok-txt"><b>' + fmt.esc(t.name) + '</b><small>' + fmt.esc(t.symbol) + '</small></div></a></td>' +
        '<td class="w-price">' + fmt.price(t.price) + '</td>' +
        '<td class="w-chg ' + (t.change >= 0 ? 'up' : 'down') + '">' + fmt.pct(t.change) + '</td>' +
        '<td class="w-liq">' + fmt.money(t.liq) + '</td><td class="w-vol">' + fmt.money(t.vol) + '</td>' +
        '<td class="w-meta"><span><small class="muted">Liquidity</small><br /><b>' + fmt.money(t.liq) + '</b></span><span><small class="muted">24h Vol</small><br /><b>' + fmt.money(t.vol) + '</b></span>' +
          '<span class="pill ' + t.risk.toLowerCase() + '">' + t.risk + '</span>' + E.ring(t.signal) + '</td>' +
        '<td class="w-risk c-center"><span class="pill ' + t.risk.toLowerCase() + '">' + t.risk + '</span></td>' +
        '<td class="w-sig c-center">' + E.ring(t.signal) + '</td>' +
        '<td class="w-act c-center"><a class="btn ghost sm" href="/ai-investigator?q=' + encodeURIComponent(t.symbol) + '">Investigate</a> ' +
          '<button class="btn danger sm" data-rm="' + t.id + '">Remove</button></td></tr>';
    }).join('');
  }

  $('#wBody').addEventListener('click', function (e) {
    var b = e.target.closest('[data-rm]'); if (!b) return;
    E.watch.toggle(b.dataset.rm); E.toast('Removed from Watchlist'); render();
  });
  $('#wForm').addEventListener('submit', function (e) {
    e.preventDefault();
    var t = E.find($('#wAdd').value);
    if (!t) { E.toast('Pick a token from the list'); return; }
    if (E.watch.has(t.id)) { E.toast(t.symbol + ' is already in your watchlist'); return; }
    E.watch.toggle(t.id); $('#wAdd').value = ''; E.toast(t.name + ' added to Watchlist'); render();
  });
  render();
})();
