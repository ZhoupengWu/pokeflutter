import 'package:flutter/foundation.dart';

/// Whether PokéAPI could be reached the last time the app tried.
///
/// The API clients report every request; the UI listens to show an "offline"
/// hint. It is deliberately derived from real requests rather than from the
/// device's connectivity flag: what matters is whether the data can be loaded.
class NetworkStatus extends ChangeNotifier {
  bool _offline = false;

  /// True after a request failed for lack of a connection, until one succeeds.
  bool get isOffline => _offline;

  void reportSuccess() => _set(false);

  void reportFailure() => _set(true);

  void _set(bool offline) {
    if (offline == _offline) return;
    _offline = offline;
    notifyListeners();
  }
}
