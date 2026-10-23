import 'package:share_plus/share_plus.dart';

/// Hands a piece of text to the system share sheet. Behind an interface so
/// that pages can be tested without a platform channel.
abstract class ShareService {
  Future<void> shareText(String text);
}

/// The real thing, backed by `share_plus`.
class SystemShareService implements ShareService {
  const SystemShareService();

  @override
  Future<void> shareText(String text) async {
    await SharePlus.instance.share(ShareParams(text: text));
  }
}
