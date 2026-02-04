import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Overlay widget that shows a banner when device is offline.
/// Extracted from main.dart builder for cleaner architecture.
class ConnectivityOverlay extends StatelessWidget {
  final Widget child;

  const ConnectivityOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        const _OfflineBanner(),
      ],
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ConnectivityResult>>(
      stream: Connectivity().onConnectivityChanged,
      builder: (context, snapshot) {
        final isOffline = snapshot.hasData &&
            (snapshot.data!.contains(ConnectivityResult.none) ||
                snapshot.data!.isEmpty);

        if (!isOffline) {
          return const SizedBox.shrink();
        }

        return Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Material(
            color: Colors.red,
            child: SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.all(8),
                alignment: Alignment.center,
                child: const Text(
                  'No Internet Connection',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
