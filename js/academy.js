(function () {
  'use strict';
  var E = window.EYES, fmt = E.fmt, $ = E.$, $$ = E.$$;
  var KEY = 'eyes-academy';
  var done = E.store.get(KEY, {});
  var open = null;

  var COURSES = [
    { id: 'basics', title: 'Crypto Basics', level: 'Beginner', color: 'linear-gradient(135deg,#1f9d3a,#0d5b24)', icon: '#i-cube', blurb: 'Wallets, keys, gas and how BNB Chain works.', lessons: [
      { t: 'What is a blockchain?', m: 4, b: 'A blockchain is a shared ledger that thousands of computers keep in sync. Once a transaction is confirmed it is extremely hard to change.<ul><li>Blocks group transactions</li><li>Validators confirm them</li><li>Everyone can inspect the history</li></ul>' },
      { t: 'Wallets and seed phrases', m: 5, b: 'A wallet holds your keys, not your coins. Your seed phrase is the master key. <b>Never share it</b> with anyone, including support staff or anyone who DMs you.' },
      { t: 'Gas fees on BNB Chain', m: 4, b: 'Every transaction costs a small fee in BNB. Keep a little BNB in your wallet for fees. Fees are usually cents, but spike when the network is busy.' } ] },
    { id: 'screener', title: 'Reading a Token Screener', level: 'Beginner', color: 'linear-gradient(135deg,#f6b90f,#b98300)', icon: '#i-bars', blurb: 'Make sense of liquidity, volume and market cap.', lessons: [
      { t: 'Liquidity: the number that matters most', m: 5, b: 'Liquidity is how much money sits in the trading pool. Low liquidity means a small buy or sell moves the price a lot, and exiting can be impossible.' },
      { t: 'Volume vs market cap', m: 4, b: 'High volume relative to liquidity can mean real interest, or wash trading. Compare 24h volume with liquidity and transaction counts before trusting it.' },
      { t: 'What the AI signal means', m: 3, b: 'The AI signal blends momentum, liquidity, holder behaviour and safety into one 0–100 score. It is a starting point for research, never a buy or sell instruction.' } ] },
    { id: 'rugs', title: 'Spotting Rug Pulls', level: 'Essential', color: 'linear-gradient(135deg,#e5484d,#8a1c1c)', icon: '#i-alert', blurb: 'The red flags that protect your money.', lessons: [
      { t: 'Honeypots: you can buy but not sell', m: 5, b: 'A honeypot contract blocks or heavily taxes selling. Always run a honeypot check in the AI Investigator before buying a new token.' },
      { t: 'Locked vs unlocked liquidity', m: 5, b: 'If the developer can withdraw the liquidity pool, they can drain it. Look for liquidity locked for months, ideally with a reputable locker.' },
      { t: 'Whales, taxes and mint functions', m: 6, b: 'Check what share the top 10 wallets hold, whether the buy and sell tax is under about 5%, and whether the owner can mint new supply.' } ] },
    { id: 'defi', title: 'DeFi on BNB Chain', level: 'Intermediate', color: 'linear-gradient(135deg,#2563eb,#1e3a8a)', icon: '#i-droplet', blurb: 'Swaps, liquidity pools and staking safely.', lessons: [
      { t: 'How a DEX swap works', m: 5, b: 'Decentralised exchanges use pools instead of order books. Slippage is how far the price moves while your trade executes. Set it as low as the token allows.' },
      { t: 'Approvals and revoking access', m: 4, b: 'When you trade you approve a contract to spend your tokens. Review and revoke old approvals regularly so a compromised contract cannot touch your wallet.' },
      { t: 'Risk management basics', m: 4, b: 'Only invest what you can lose, split entries, and write down an exit plan before you buy.' } ] }
  ];

  var GLOSS = [
    ['Liquidity', 'Money in a trading pool that lets you buy and sell without moving the price too much.'],
    ['Slippage', 'The difference between the price you expected and the price you actually got.'],
    ['Market cap', 'Price multiplied by circulating supply. A rough measure of size, not of safety.'],
    ['Rug pull', 'When developers drain liquidity or dump their holdings and leave investors with worthless tokens.'],
    ['Honeypot', 'A token you can buy but cannot sell.'],
    ['LP lock', 'Liquidity tokens locked in a contract so the developer cannot withdraw the pool.'],
    ['Renounced ownership', 'The developer gave up admin control of the contract.'],
    ['Tokenomics', 'How a token is distributed, its supply, taxes and incentives.'],
    ['Whale', 'A wallet that holds a large share of a token’s supply.'],
    ['Gas', 'The fee paid to process a transaction on the blockchain.'],
    ['DEX', 'Decentralised exchange: a swap venue run by smart contracts, like PancakeSwap.'],
    ['Seed phrase', 'The 12 or 24 words that restore your wallet. Never share it.']
  ];

  function total() { return COURSES.reduce(function (s, c) { return s + c.lessons.length; }, 0); }
  function count(c) { return c.lessons.filter(function (_, i) { return done[c.id + ':' + i]; }).length; }

  function progress() {
    var n = Object.keys(done).filter(function (k) { return done[k]; }).length, tot = total(), pct = Math.round(n / tot * 100);
    $('#acPct').textContent = pct + '%';
    $('#acGauge').style.setProperty('--p', pct);
    $('#acBar').style.setProperty('--p', pct);
    $('#acText').textContent = n + ' of ' + tot + ' lessons complete' + (n === tot ? ' — well done!' : '');
  }

  function renderCourses() {
    $('#acCourses').innerHTML = COURSES.map(function (c) {
      var n = count(c), pct = Math.round(n / c.lessons.length * 100);
      return '<article class="card course"><div class="cover" style="background:' + c.color + '"><svg><use href="' + c.icon + '"/></svg><span>' + c.level + '</span></div>' +
        '<div class="cb"><h3>' + c.title + '</h3><p>' + c.blurb + '</p><div class="meter c-good" style="--p:' + pct + ';margin-top:6px"><i></i></div>' +
        '<div class="meta"><span>' + c.lessons.length + ' lessons</span><span>' + c.lessons.reduce(function (s, l) { return s + l.m; }, 0) + ' min</span><span>' + n + '/' + c.lessons.length + ' done</span></div>' +
        '<button class="btn ' + (open === c.id ? 'ghost' : '') + ' sm" data-open="' + c.id + '" style="margin-top:10px">' + (n === c.lessons.length ? 'Review' : n ? 'Continue' : 'Start course') + '</button></div></article>';
    }).join('');
  }

  var openLesson = null;
  function renderPanel() {
    var panel = $('#acPanel'), c = COURSES.filter(function (x) { return x.id === open; })[0];
    panel.hidden = !c;
    if (!c) return;
    panel.innerHTML = '<div class="row between" style="margin-bottom:6px"><h2 class="card-title" style="margin:0">' + c.title + '</h2><button class="btn ghost sm" data-close="1">Close</button></div>' +
      c.lessons.map(function (l, i) {
        var k = c.id + ':' + i, isOpen = openLesson === k;
        return '<div class="lesson' + (done[k] ? ' done' : '') + '"><button class="num" data-done="' + k + '" aria-label="Mark complete" aria-pressed="' + !!done[k] + '">' +
          (done[k] ? '<svg><use href="#i-check"/></svg>' : (i + 1)) + '</button>' +
          '<div class="t"><button data-lesson="' + k + '" style="text-align:left;font-weight:500;font-size:14px;width:100%">' + l.t + '<small>' + l.m + ' min read</small></button></div>' +
          '<svg style="width:16px;height:16px;color:var(--faint);transform:rotate(' + (isOpen ? 90 : 0) + 'deg)"><use href="#i-chev-right"/></svg></div>' +
          (isOpen ? '<div class="lesson-body">' + l.b + '<div style="margin-top:12px"><button class="btn sm" data-done="' + k + '">' + (done[k] ? 'Mark as not done' : 'Mark complete') + '</button></div></div>' : '');
      }).join('');
  }

  function renderGloss() {
    var q = $('#acSearch').value.trim().toLowerCase();
    var l = GLOSS.filter(function (g) { return !q || g[0].toLowerCase().indexOf(q) >= 0 || g[1].toLowerCase().indexOf(q) >= 0; });
    $('#acGloss').innerHTML = l.length ? l.map(function (g) { return '<div><dt>' + g[0] + '</dt><dd>' + g[1] + '</dd></div>'; }).join('') : '<div><dd>No matching terms.</dd></div>';
  }

  function all() { progress(); renderCourses(); renderPanel(); }

  $('#acCourses').addEventListener('click', function (e) {
    var b = e.target.closest('[data-open]'); if (!b) return;
    open = open === b.dataset.open ? null : b.dataset.open; openLesson = null;
    var c = COURSES.filter(function (x) { return x.id === open; })[0];
    if (c) { var next = c.lessons.findIndex(function (_, i) { return !done[c.id + ':' + i]; }); openLesson = c.id + ':' + Math.max(0, next); }
    all();
    if (open) $('#acPanel').scrollIntoView({ behavior: 'smooth', block: 'start' });
  });
  $('#acPanel').addEventListener('click', function (e) {
    var d = e.target.closest('[data-done]'), l = e.target.closest('[data-lesson]');
    if (e.target.closest('[data-close]')) { open = null; all(); return; }
    if (d) { var k = d.dataset.done; done[k] = !done[k]; E.store.set(KEY, done); all(); if (done[k]) E.toast('Lesson complete'); }
    else if (l) { openLesson = openLesson === l.dataset.lesson ? null : l.dataset.lesson; renderPanel(); }
  });
  $('#acSearch').addEventListener('input', renderGloss);
  all(); renderGloss();
})();
