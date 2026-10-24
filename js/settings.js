(function () {
  'use strict';
  var E = window.EYES, $ = E.$, $$ = E.$$;
  var SKEY = 'eyes-settings';
  var s = E.store.get(SKEY, { live: true });

  function mode() { try { return localStorage.getItem('eyes-theme-mode') || 'system'; } catch (e) { return 'system'; } }
  function paintTheme() { $$('#sTheme button').forEach(function (b) { b.classList.toggle('active', b.dataset.t === mode()); }); }
  function paintLive() { $('#sLive').setAttribute('aria-checked', s.live !== false); }
  function counts() {
    var w = E.watch.list().length, a = (E.store.get('eyes-alerts', []) || []).length, p = Object.keys(E.store.get('eyes-academy', {})).filter(function (k) { return E.store.get('eyes-academy', {})[k]; }).length;
    $('#sWatch').textContent = w + ' token' + (w === 1 ? '' : 's') + ' saved';
    $('#sAlerts').textContent = a + ' alert' + (a === 1 ? '' : 's') + ' saved';
    $('#sAcad').textContent = p + ' lesson' + (p === 1 ? '' : 's') + ' completed';
  }

  $('#sTheme').addEventListener('click', function (e) {
    var b = e.target.closest('button'); if (!b) return;
    try { localStorage.setItem('eyes-theme-mode', b.dataset.t); } catch (x) {}
    if (b.dataset.t === 'system') {
      try { localStorage.removeItem('eyes-theme'); } catch (x) {}
      delete document.documentElement.dataset.theme;
      var dark = window.matchMedia('(prefers-color-scheme: dark)').matches;
      document.documentElement.dataset.theme = dark ? 'dark' : 'light';
      try { localStorage.removeItem('eyes-theme'); } catch (x) {}
    } else {
      document.documentElement.dataset.theme = b.dataset.t;
      try { localStorage.setItem('eyes-theme', b.dataset.t); } catch (x) {}
    }
    paintTheme();
  });
  $('#sLive').addEventListener('click', function () { s.live = !(s.live !== false); E.store.set(SKEY, s); paintLive(); E.toast(s.live ? 'Live updates on' : 'Live updates off'); });
  document.addEventListener('click', function (e) {
    var b = e.target.closest('[data-clear]'); if (!b) return;
    try { localStorage.removeItem(b.dataset.clear); } catch (x) {}
    counts(); E.toast('Cleared');
  });
  paintTheme(); paintLive(); counts();
})();
