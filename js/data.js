/* Demo market data for EYES-Screener.
 * The first ten tokens mirror the design. The rest are generated deterministically so
 * pagination, filters and sorting have something to work with. Swap `EYES_DATA.tokens`
 * for a real feed (e.g. DexScreener / Bitquery) with the same shape to go live. */
(function () {
  var IMG = 'assets/img/tokens/';

  var featured = [
    { name: 'BabyDoge', symbol: 'BABYDOGE', icon: 'babydoge', price: 0.00000215, change: 72.36, liq: 12.4e6, vol: 18.7e6, mcap: 156.4e6, txns: 38.7e3, risk: 'Low', signal: 82, cats: ['bsc', 'memes'], age: 900, trend: 95 },
    { name: 'TST', symbol: 'TST', icon: 'tst', price: 0.0214, change: 56.72, liq: 4.8e6, vol: 9.3e6, mcap: 78.6e6, txns: 22.1e3, risk: 'Medium', signal: 76, cats: ['bsc', 'memes', 'social'], age: 3, trend: 99 },
    { name: 'Neiro', symbol: 'NEIRO', icon: 'neiro', price: 0.0018, change: 48.2, liq: 7.6e6, vol: 12.4e6, mcap: 134.2e6, txns: 54.3e3, risk: 'Low', signal: 71, cats: ['bsc', 'memes'], age: 420, trend: 90 },
    { name: 'Floki', symbol: 'FLOKI', icon: 'floki', price: 0.000184, change: 42.17, liq: 34.2e6, vol: 71.6e6, mcap: 412.6e6, txns: 91.6e3, risk: 'Low', signal: 69, cats: ['bsc', 'memes', 'gaming'], age: 1400, trend: 88 },
    { name: 'Pepe Unchained', symbol: 'PEPU', icon: 'pepu', price: 0.0063, change: 38.56, liq: 11.8e6, vol: 27.5e6, mcap: 98.4e6, txns: 41.2e3, risk: 'Low', signal: 66, cats: ['bsc', 'memes', 'defi'], age: 210, trend: 84 },
    { name: 'WIF', symbol: 'WIF', icon: 'wif', price: 1.23, change: 34.28, liq: 28.4e6, vol: 52.7e6, mcap: 281.6e6, txns: 72.8e3, risk: 'Medium', signal: 64, cats: ['bsc', 'memes'], age: 800, trend: 86 },
    { name: 'CAT IN A DOGS WORLD', symbol: 'MEW', icon: 'mew', price: 0.0039, change: 31.76, liq: 5.7e6, vol: 16.2e6, mcap: 92.3e6, txns: 33.4e3, risk: 'Low', signal: 62, cats: ['bsc', 'memes', 'social'], age: 300, trend: 80 },
    { name: 'BOME', symbol: 'BOME', icon: 'bome', price: 0.0067, change: 28.34, liq: 8.9e6, vol: 21.8e6, mcap: 114.7e6, txns: 45.2e3, risk: 'Medium', signal: 58, cats: ['bsc', 'memes', 'nft'], age: 500, trend: 77 },
    { name: 'PEPE', symbol: 'PEPE', icon: 'pepe', price: 0.0000128, change: 24.67, liq: 16.5e6, vol: 36.4e6, mcap: 206.7e6, txns: 68.1e3, risk: 'Low', signal: 54, cats: ['bsc', 'memes'], age: 1200, trend: 82 },
    { name: 'DOGE', symbol: 'DOGE', icon: 'doge', price: 0.0812, change: 21.45, liq: 42.7e6, vol: 98.3e6, mcap: 1.2e9, txns: 127.6e3, risk: 'Medium', signal: 48, cats: ['bsc', 'memes'], age: 2000, trend: 79 }
  ];

  // Deterministic PRNG so the generated list is stable between reloads.
  var seed = 20261021;
  function rnd() { seed = (seed * 1664525 + 1013904223) % 4294967296; return seed / 4294967296; }
  function pick(a) { return a[Math.floor(rnd() * a.length)]; }

  var pre = ['Moon', 'Baby', 'Mega', 'Safe', 'Turbo', 'Based', 'Shiba', 'Cake', 'Bit', 'Hyper', 'Quantum', 'Lucky', 'Golden', 'Rocket', 'Neo', 'Alpha', 'Pixel', 'Meta', 'Astro', 'Frog', 'Cyber', 'Degen', 'Sun', 'Lion'];
  var suf = ['Cat', 'Inu', 'Doge', 'Swap', 'Fi', 'Verse', 'Bot', 'Chain', 'Pad', 'Punk', 'AI', 'Coin', 'Yield', 'Bull', 'Pepe', 'Floki', 'Land', 'Labs', 'Dao', 'X'];
  var catBySuf = { Swap: 'defi', Fi: 'defi', Yield: 'defi', Dao: 'defi', Bot: 'ai', AI: 'ai', Verse: 'gaming', Land: 'gaming', Punk: 'nft', Pad: 'other', Chain: 'other', Labs: 'other', Coin: 'social', X: 'social' };
  var colors = ['#F5B700', '#16A34A', '#2563EB', '#DB2777', '#7C3AED', '#EA580C', '#0891B2', '#DC2626', '#65A30D', '#475569'];

  var used = {};
  featured.forEach(function (t) { used[t.symbol] = 1; });
  var generated = [];
  var change = 21;
  while (generated.length < 204) {
    var a = pick(pre), b = pick(suf), name = a + b;
    var sym = (a.slice(0, 2) + b.slice(0, 3)).toUpperCase().replace(/[^A-Z]/g, '');
    if (used[sym]) continue;
    used[sym] = 1;
    change -= rnd() * 0.45;
    var mcap = Math.pow(10, 6 + rnd() * 2.6);
    var liq = mcap * (0.04 + rnd() * 0.12);
    var vol = liq * (0.8 + rnd() * 2.4);
    var cat = catBySuf[b] || 'memes';
    var signal = Math.max(12, Math.min(95, Math.round(30 + rnd() * 50)));
    generated.push({
      name: name, symbol: sym, icon: null, color: pick(colors),
      price: Math.pow(10, -7 + rnd() * 7.5), change: +change.toFixed(2),
      liq: liq, vol: vol, mcap: mcap, txns: Math.round(vol / (180 + rnd() * 420)),
      risk: rnd() < 0.55 ? 'Low' : rnd() < 0.75 ? 'Medium' : 'High',
      signal: signal, cats: ['bsc', cat], age: Math.round(rnd() * 3000), trend: Math.round(rnd() * 78)
    });
  }

  var tokens = featured.concat(generated).map(function (t, i) {
    t.id = t.symbol;
    t.img = t.icon ? IMG + t.icon + '.png' : null;
    t.address = '0x' + (function () { var s = ''; for (var k = 0; k < 40; k++) s += '0123456789abcdef'[Math.floor(rnd() * 16)]; return s; })();
    return t;
  });

  window.EYES_DATA = {
    tokens: tokens,
    // Chain-wide gainers (not limited to the screener's filtered list).
    gainers: [
      { name: 'TST', img: IMG + 'tst.png', change: 128.45 },
      { name: 'BabyDoge', img: IMG + 'babydoge.png', change: 72.36 },
      { name: 'PONKE', img: IMG + 'ponke.png', change: 56.72 },
      { name: 'Neiro', img: IMG + 'neiro.png', change: 48.2 },
      { name: 'FLOKI', img: IMG + 'floki.png', change: 42.17 }
    ],
    pairs: [
      { base: 'TST', quote: 'WBNB', img: IMG + 'tst.png', mins: 3 },
      { base: 'DOGEAI', quote: 'WBNB', img: IMG + 'dogeai.png', mins: 12 },
      { base: 'PEPE2.0', quote: 'WBNB', img: IMG + 'pepe2.png', mins: 18 },
      { base: 'KONG', quote: 'WBNB', img: IMG + 'kong.png', mins: 26 },
      { base: 'SHIBI', quote: 'WBNB', img: IMG + 'shibi.png', mins: 34 }
    ],
    overview: { mcap: 72.4e9, vol: 6.8e9, pairs: 12482 }
  };
})();
