(function () {
  'use strict';
  var E = window.EYES, D = E.data, fmt = E.fmt, $ = E.$, $$ = E.$$;
  var state = { level: 'all', flags: [], shown: 12, hl: null };
  var colOf = function (a) { return a.score >= 75 ? 'good' : a.score >= 50 ? 'warn' : 'bad'; };

  var rows = D.tokens.map(function (t) { return { t: t, a: E.analyse(t) }; });
  $('#rLow').textContent = rows.filter(function (r) { return r.t.risk === 'Low'; }).length;
  $('#rMed').textContent = rows.filter(function (r) { return r.t.risk === 'Medium'; }).length;
  $('#rHigh').textContent = rows.filter(function (r) { return r.t.risk === 'High'; }).length;

  // Radar: distance from the centre = risk, angle is stable per token.
  var radar = $('#radar');
  radar.insertAdjacentHTML('beforeend', rows.slice().sort(function (x, y) { return y.t.mcap - x.t.mcap; }).slice(0, 36).map(function (r) {
    var rnd = E.seeded(r.t.id + ':pos'), ang = rnd() * Math.PI * 2;
    var rad = (0.14 + (100 - r.a.score) / 100 * 0.78) * 50;
    return '<button class="blip c-' + colOf(r.a) + '" data-id="' + r.t.id + '" style="left:' + (50 + Math.cos(ang) * rad).toFixed(1) + '%;top:' + (50 + Math.sin(ang) * rad).toFixed(1) + '%" aria-label="' + fmt.esc(r.t.symbol) + ' safety ' + r.a.score + '"></button>';
  }).join(''));
  radar.addEventListener('click', function (e) {
    var b = e.target.closest('.blip');
    if (!b) return;
    state.hl = b.dataset.id; state.level = 'all'; state.flags = [];
    $$('#rLevel button').forEach(function (x) { x.classList.toggle('active', x.dataset.l === 'all'); });
    $$('#rFlags .chip').forEach(function (x) { x.classList.remove('active'); });
    render(true);
  });

  function tagsFor(a) {
    return a.flags.filter(function (f) { return f.status !== 'good'; }).map(function (f) {
      return '<span class="chip-s c-' + f.status + '">' + f.tag + '</span>';
    }).join('') || '<span class="chip-s c-good">No issues found</span>';
  }

  function render(scroll) {
    var list = rows.filter(function (r) {
      if (state.level !== 'all' && r.t.risk !== state.level) return false;
      return state.flags.every(function (f) {
        var fl = r.a.flags.filter(function (x) { return x.id === f; })[0];
        return fl && fl.status !== 'good';
      });
    }).sort(function (x, y) { return x.a.score - y.a.score; });
    if (state.hl) {
      var i = list.findIndex(function (r) { return r.t.id === state.hl; });
      if (i > 0) list.unshift(list.splice(i, 1)[0]);
    }
    $('#rCount').textContent = list.length + ' match' + (list.length === 1 ? '' : 'es');
    $('#rMore').parentNode.hidden = list.length <= state.shown;
    $('#rList').innerHTML = list.length ? list.slice(0, state.shown).map(function (r) {
      var t = r.t, w = E.watch.has(t.id);
      return '<div class="rr-row" data-id="' + t.id + '"' + (state.hl === t.id ? ' style="background:var(--yellow-soft)"' : '') + '>' +
        '<a class="tok" href="/token?s=' + encodeURIComponent(t.symbol) + '">' + E.avatar(t, 'tok-ic') + '<div class="tok-txt"><b>' + fmt.esc(t.name) + '</b><small>' + fmt.esc(t.symbol) + ' · ' + fmt.money(t.liq) + ' liquidity</small></div></a>' +
        '<div class="gauge sm c-' + colOf(r.a) + '" style="--p:' + r.a.score + '"><div><b>' + r.a.score + '</b></div></div>' +
        '<div class="tags meterwrap">' + tagsFor(r.a) + '</div>' +
        '<div class="acts"><a class="act" href="/ai-investigator?q=' + encodeURIComponent(t.symbol) + '" aria-label="Investigate"><svg><use href="#i-brain"/></svg></a>' +
        '<button class="act star' + (w ? ' on' : '') + '" data-w="' + t.id + '" aria-label="Toggle watchlist"><svg><use href="#i-star"/></svg></button></div></div>';
    }).join('') : '<div class="rr-empty">No tokens match these filters.</div>';
    if (scroll) { var el = $('#rList .rr-row'); if (el) el.scrollIntoView({ behavior: 'smooth', block: 'center' }); }
  }

  $('#rLevel').addEventListener('click', function (e) {
    var b = e.target.closest('button'); if (!b) return;
    $$('#rLevel button').forEach(function (x) { x.classList.toggle('active', x === b); });
    state.level = b.dataset.l; state.shown = 12; state.hl = null; render();
  });
  $('#rFlags').addEventListener('click', function (e) {
    var b = e.target.closest('.chip'); if (!b) return;
    b.classList.toggle('active');
    state.flags = $$('#rFlags .chip.active').map(function (x) { return x.dataset.f; });
    state.shown = 12; state.hl = null; render();
  });
  $('#rMore').addEventListener('click', function () { state.shown += 12; render(); });
  $('#rList').addEventListener('click', function (e) {
    var b = e.target.closest('[data-w]'); if (!b) return;
    var on = E.watch.toggle(b.dataset.w); b.classList.toggle('on', on);
    E.toast(on ? 'Added to Watchlist' : 'Removed from Watchlist');
  });
  render();
})();
