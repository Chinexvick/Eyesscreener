(function () {
  'use strict';
  var E = window.EYES, D = E.data, fmt = E.fmt, $ = E.$;

  var movers = D.tokens.slice().sort(function (a, b) { return b.change - a.change; }).slice(0, 6);
  $('#hMovers').innerHTML = movers.map(function (t) {
    return '<tr><td><a class="tok" href="/token?s=' + encodeURIComponent(t.symbol) + '">' + E.avatar(t, 'tok-ic') + '<span><b>' + fmt.esc(t.name) + '</b></span></a></td>' +
      '<td class="r muted">' + fmt.price(t.price) + '</td><td class="r up"><b>' + fmt.pct(t.change) + '</b></td></tr>';
  }).join('');

  $('#hPairs').innerHTML = D.pairs.map(function (p) {
    return '<tr><td><span class="tok" style="display:flex;align-items:center;gap:9px"><img class="tok-ic" src="/' + p.img + '" alt="" /><b>' + fmt.esc(p.base) + '</b><span class="muted">/ ' + fmt.esc(p.quote) + '</span></span></td>' +
      '<td class="r muted">' + p.mins + 'm ago</td></tr>';
  }).join('');

  var high = D.tokens.filter(function (t) { return t.risk === 'High'; }).length;
  $('#hRisk').textContent = high;
})();
