import 'dart:async';
import 'dart:convert';
import 'package:vego/features/tracking/widgets/granular_timeline_widget.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:vego/core/providers/cart_provider.dart';
import 'package:vego/core/theme/app_colors.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  // Coordinates for HSR Layout, Sector 2 (Mock)
  final LatLng _userLocation = const LatLng(12.9121, 77.6446);
  final LatLng _riderStartLocation = const LatLng(12.9150, 77.6500);

  List<LatLng> _routePoints = [];
  late LatLng _riderLocation;
  Timer? _timer;
  int _currentPointIndex = 0;
  String _eta = "Calculating...";

  // Undo Logic
  int _undoSeconds = 60;
  Timer? _undoTimer;

  @override
  void initState() {
    super.initState();
    _riderLocation = _riderStartLocation;
    // Initialize with straight line while fetching
    _routePoints = [_riderStartLocation, _userLocation];
    _fetchRoute();
    _startUndoTimer();

    // Auto-clear cart when entering tracking (Order Placed)
    // Delay slightly to allow Undo to maybe revert it?
    // Actually, "Slide to Pay" should technically clear cart but we might want to keep it
    // if we want to support "Undo" restoring it?
    // Current flow: Slide to Pay -> Pushes Tracking.
    // Cart is NOT cleared in previous screen. It should be cleared here or on "Undo" pop.
    // If Undo -> Pop (Cart is still full).
    // If Timer ends -> Cart cleared.
    // Let's implement that.
  }

  void _startUndoTimer() {
    _undoTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_undoSeconds > 0) {
        setState(() {
          _undoSeconds--;
        });
      } else {
        _undoTimer?.cancel();
        // Commit order: Clear cart now
        if (mounted) {
          context.read<CartProvider>().clearCart();
        }
      }
    });
  }

  void _undoOrder() {
    _undoTimer?.cancel();
    Navigator.pop(context); // Go back to Cart
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Order Cancelled'),
      backgroundColor: Colors.red,
    ));
  }

  Future<void> _fetchRoute() async {
    try {
      final url = Uri.parse(
          'http://router.project-osrm.org/route/v1/driving/${_riderStartLocation.longitude},${_riderStartLocation.latitude};${_userLocation.longitude},${_userLocation.latitude}?overview=full&geometries=geojson');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final coordinates =
            data['routes'][0]['geometry']['coordinates'] as List;

        setState(() {
          _routePoints = coordinates
              .map((point) => LatLng(point[1].toDouble(), point[0].toDouble()))
              .toList();
          _currentPointIndex = 0;
          _startSimulation();
        });
      }
    } catch (e) {
      debugPrint("Error fetching route: $e");
      // Fallback to simulation on straight line if fetch fails
      _startSimulation();
    }
  }

  void _startSimulation() {
    if (_routePoints.isEmpty) return;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!mounted) return;

      setState(() {
        if (_currentPointIndex < _routePoints.length - 1) {
          _currentPointIndex++;
          _riderLocation = _routePoints[_currentPointIndex];

          // Calculate simple OTA
          int remainingPoints = _routePoints.length - _currentPointIndex;
          int minutes = (remainingPoints / 10).ceil();
          // Assuming each point takes 0.5 sec, roughly estimatation.
          // Adjust logic for better realistic OTA if needed.
          _eta = minutes < 1 ? "Arriving" : "$minutes mins";
        } else {
          _timer?.cancel();
          _eta = "Arrived";
          _showOrderCompletedDialog();
        }
      });
    });
  }

  void _showOrderCompletedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            Text(
              'Order Delivered!',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'Enjoy your fresh vegetables! How was the delivery?',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
              context.read<CartProvider>().clearCart();
            },
            child: Text(
              'Back to Home',
              style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _undoTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: _userLocation,
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.vego.app',
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _routePoints,
                    strokeWidth: 4.0,
                    color: AppColors.primary.withValues(alpha: 0.5),
                  ),
                  Polyline(
                    points: _routePoints.sublist(_currentPointIndex),
                    strokeWidth: 4.0,
                    color: AppColors.primary, // Active path remaining
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  // User Marker
                  Marker(
                    point: _userLocation,
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.location_on,
                        color: AppColors.accent, size: 40),
                  ),
                  // Rider Marker
                  Marker(
                    point: _riderLocation,
                    width: 40,
                    height: 40,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(blurRadius: 5, color: Colors.black26)
                        ],
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const Icon(Icons.delivery_dining,
                          color: AppColors.primary, size: 24),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Back Button
          Positioned(
            top: 50,
            left: 16,
            child: CircleAvatar(
              backgroundColor: context.surfaceColor,
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: context.textPrimary),
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  // Don't clear cart if just backing out, but usually tracking implies order placed.
                  // If backing out without undo, order continues.
                  // For this demo, let's assume back goes home and keeps order running in background (simulated).
                  context.read<CartProvider>().clearCart();
                },
              ),
            ),
          ),

          // Hero Feature 3: Undo Button (60s Timer)
          if (_undoSeconds > 0)
            Positioned(
              bottom: 240, // Above status panel
              left: 0, right: 0,
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: const BoxDecoration(boxShadow: [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4))
                  ]),
                  child: ElevatedButton.icon(
                    onPressed: _undoOrder,
                    icon: const Icon(Icons.undo, color: Colors.white),
                    label: Text(
                      'Undo Order ($_undoSeconds s)',
                      style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                ),
              ),
            ),

          // Status Panel
          Positioned(
            bottom: 30,
            left: 16,
            right: 16,
            child: GranularTimelineWidget(
              eta: _eta,
              onCallRider: () {},
            ),
          ),
        ],
      ),
    );
  }
}
