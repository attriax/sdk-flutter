const _botUaPatterns = <String>[
  'bot',
  'crawler',
  'spider',
  'scraper',
  'wget',
  'curl',
  'headless',
  'gptbot',
  'claudebot',
  'anthropic',
  'googlebot',
  'bingbot',
  'yandexbot',
  'baiduspider',
  'facebookbot',
  'twitterbot',
  'linkedinbot',
  'commoncrawl',
  'semrush',
  'ahrefs',
  'mj12bot',
  'applebot',
  'duckduckbot',
  'petalbot',
  'whatsapp',
  'slackbot',
  'telegrambot',
  'discordbot',
  'redditbot',
];

class AttriaxBotEnvironmentSnapshot {
  const AttriaxBotEnvironmentSnapshot({this.isBot = false, this.detectedVia});

  final bool isBot;
  final String? detectedVia;

  static String? detectFromUserAgent(String? userAgent) {
    if (userAgent == null || userAgent.isEmpty) {
      return null;
    }
    final lower = userAgent.toLowerCase();
    for (final pattern in _botUaPatterns) {
      if (lower.contains(pattern)) {
        return 'user_agent';
      }
    }
    return null;
  }
}

AttriaxBotEnvironmentSnapshot currentAttriaxBotEnvironment() =>
    const AttriaxBotEnvironmentSnapshot();
