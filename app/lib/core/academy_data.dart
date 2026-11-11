import 'package:flutter/material.dart';

class Lesson {
  const Lesson(this.title, this.minutes, this.body);
  final String title, body;
  final int minutes;
}

class Course {
  const Course(
    this.id,
    this.title,
    this.level,
    this.blurb,
    this.icon,
    this.colors,
    this.lessons,
  );
  final String id, title, level, blurb;
  final IconData icon;
  final List<Color> colors;
  final List<Lesson> lessons;

  int get minutes => lessons.fold(0, (s, l) => s + l.minutes);
}

class AcademyData {
  static const courses = [
    Course(
      'basics',
      'Crypto Basics',
      'Beginner',
      'Wallets, keys, gas and how BNB Chain works.',
      Icons.view_in_ar_rounded,
      [Color(0xFF1F9D3A), Color(0xFF0D5B24)],
      [
        Lesson(
          'What is a blockchain?',
          4,
          'A blockchain is a shared ledger that thousands of computers keep in sync. Once a transaction is confirmed it is extremely hard to change.\n\n• Blocks group transactions\n• Validators confirm them\n• Everyone can inspect the history',
        ),
        Lesson(
          'Wallets and seed phrases',
          5,
          'A wallet holds your keys, not your coins. Your seed phrase is the master key.\n\nNever share it with anyone, including support staff or anyone who messages you.',
        ),
        Lesson(
          'Gas fees on BNB Chain',
          4,
          'Every transaction costs a small fee in BNB. Keep a little BNB in your wallet for fees. Fees are usually cents, but spike when the network is busy.',
        ),
      ],
    ),
    Course(
      'screener',
      'Reading a Token Screener',
      'Beginner',
      'Make sense of liquidity, volume and market cap.',
      Icons.candlestick_chart_rounded,
      [Color(0xFFF6B90F), Color(0xFF9A6B00)],
      [
        Lesson(
          'Liquidity: the number that matters most',
          5,
          'Liquidity is how much money sits in the trading pool. Low liquidity means a small buy or sell moves the price a lot, and exiting can be impossible.',
        ),
        Lesson(
          'Volume vs market cap',
          4,
          'High volume relative to liquidity can mean real interest, or wash trading. Compare 24h volume with liquidity and transaction counts before trusting it.',
        ),
        Lesson(
          'What the AI signal means',
          3,
          'The AI signal blends momentum, liquidity, holder behaviour and safety into one 0–100 score. It is a starting point for research, never a buy or sell instruction.',
        ),
      ],
    ),
    Course(
      'rugs',
      'Spotting Rug Pulls',
      'Essential',
      'The red flags that protect your money.',
      Icons.warning_amber_rounded,
      [Color(0xFFE5484D), Color(0xFF8A1C1C)],
      [
        Lesson(
          'Honeypots: you can buy but not sell',
          5,
          'A honeypot contract blocks or heavily taxes selling. Always run a honeypot check in the AI Investigator before buying a new token.',
        ),
        Lesson(
          'Locked vs unlocked liquidity',
          5,
          'If the developer can withdraw the liquidity pool, they can drain it. Look for liquidity locked for months, ideally with a reputable locker.',
        ),
        Lesson(
          'Whales, taxes and mint functions',
          6,
          'Check what share the top 10 wallets hold, whether the buy and sell tax is under about 5%, and whether the owner can mint new supply.',
        ),
      ],
    ),
    Course(
      'defi',
      'DeFi on BNB Chain',
      'Intermediate',
      'Swaps, liquidity pools and staking safely.',
      Icons.water_drop_rounded,
      [Color(0xFF2563EB), Color(0xFF1E3A8A)],
      [
        Lesson(
          'How a DEX swap works',
          5,
          'Decentralised exchanges use pools instead of order books. Slippage is how far the price moves while your trade executes. Set it as low as the token allows.',
        ),
        Lesson(
          'Approvals and revoking access',
          4,
          'When you trade you approve a contract to spend your tokens. Review and revoke old approvals regularly so a compromised contract cannot touch your wallet.',
        ),
        Lesson(
          'Risk management basics',
          4,
          'Only invest what you can lose, split entries, and write down an exit plan before you buy.',
        ),
      ],
    ),
  ];

  static const glossary = [
    (
      'Liquidity',
      'Money in a trading pool that lets you buy and sell without moving the price too much.',
    ),
    (
      'Slippage',
      'The difference between the price you expected and the price you actually got.',
    ),
    (
      'Market cap',
      'Price multiplied by circulating supply. A rough measure of size, not of safety.',
    ),
    (
      'Rug pull',
      'When developers drain liquidity or dump their holdings and leave investors with worthless tokens.',
    ),
    ('Honeypot', 'A token you can buy but cannot sell.'),
    (
      'LP lock',
      'Liquidity tokens locked in a contract so the developer cannot withdraw the pool.',
    ),
    (
      'Renounced ownership',
      'The developer gave up admin control of the contract.',
    ),
    (
      'Tokenomics',
      'How a token is distributed, its supply, taxes and incentives.',
    ),
    ('Whale', 'A wallet that holds a large share of a token’s supply.'),
    ('Gas', 'The fee paid to process a transaction on the blockchain.'),
    (
      'DEX',
      'Decentralised exchange: a swap venue run by smart contracts, like PancakeSwap.',
    ),
    (
      'Seed phrase',
      'The 12 or 24 words that restore your wallet. Never share it.',
    ),
  ];

  static int get totalLessons =>
      courses.fold(0, (s, c) => s + c.lessons.length);
}
