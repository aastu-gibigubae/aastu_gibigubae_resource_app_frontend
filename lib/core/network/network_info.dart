import 'package:connectivity_plus/connectivity_plus.dart';

/// ================================================================
/// NETWORK INFO
///
/// Abstraction over connectivity_plus so the rest of the app
/// does not depend on the package directly.
/// ================================================================

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity _connectivity;

  const NetworkInfoImpl(this._connectivity);

  @override
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return result.any((r) => r != ConnectivityResult.none);
  }
}
