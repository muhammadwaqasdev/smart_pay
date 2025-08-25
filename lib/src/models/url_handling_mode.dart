/// How to handle URLs in URL-based payment systems
enum UrlHandlingMode {
  /// Automatically redirect to external browser (default)
  autoRedirect,

  /// Return the URL to developer for manual handling
  manual,
}
