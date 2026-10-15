import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'network_status.dart';
import 'pokemon_api.dart';

/// Thin JSON-over-HTTP layer shared by the PokéAPI services.
///
/// - Every request has a [timeout].
/// - Transient failures (network, 5xx) are retried up to [maxAttempts] times.
/// - Failures are reported as [PokemonApiException], never as `null`.
class PokeApiClient {
  PokeApiClient({
    http.Client? client,
    this.timeout = const Duration(seconds: 15),
    this.retryDelay = const Duration(milliseconds: 500),
    this.maxAttempts = 2,
    this.status,
  }) : _client = client ?? http.Client();

  static const baseUrl = 'https://pokeapi.co/api/v2';

  final http.Client _client;
  final Duration timeout;
  final Duration retryDelay;
  final int maxAttempts;

  /// Told after every request whether PokéAPI could be reached.
  final NetworkStatus? status;

  /// GETs [url] and returns the decoded JSON body.
  ///
  /// [notFoundMessage] is used when the server answers 404.
  Future<Map<String, dynamic>> getJson(
    String url, {
    String notFoundMessage = 'Not found',
  }) async {
    PokemonApiException? last;

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      if (attempt > 1) await Future<void>.delayed(retryDelay);
      try {
        return await _request(url, notFoundMessage);
      } on PokemonApiException catch (e) {
        last = e;
        final retryable =
            e.type == PokemonApiErrorType.network ||
            e.type == PokemonApiErrorType.server;
        if (!retryable) break;
      }
    }
    throw last!;
  }

  Future<Map<String, dynamic>> _request(
    String url,
    String notFoundMessage,
  ) async {
    final http.Response response;
    try {
      response = await _client.get(Uri.parse(url)).timeout(timeout);
    } catch (e) {
      status?.reportFailure();
      throw PokemonApiException(PokemonApiErrorType.network, '$e');
    }
    status?.reportSuccess(); // any answer, even an error status, means online

    if (response.statusCode == 404) {
      throw PokemonApiException(PokemonApiErrorType.notFound, notFoundMessage);
    }
    if (response.statusCode != 200) {
      throw PokemonApiException(
        PokemonApiErrorType.server,
        'HTTP ${response.statusCode}',
      );
    }

    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      throw PokemonApiException(PokemonApiErrorType.parse, '$e');
    }
  }
}
