/// App-wide constants
library;

/// Support email - configurable via SUPPORT_EMAIL environment variable
const String kSupportEmail = String.fromEnvironment(
  'SUPPORT_EMAIL',
  defaultValue: 'jokerlin135@gmail.com',
);
