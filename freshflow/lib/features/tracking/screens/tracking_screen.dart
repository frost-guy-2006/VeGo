import 'dart:async';
import 'dart:convert';
import 'package:freshflow/features/tracking/widgets/granular_timeline_widget.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:freshflow/core/providers/cart_provider.dart';
import 'package:freshflow/core/theme/app_colors.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen>
    with TickerProviderStateMixin {
  // Coordinates for HSR Layout, Sector 2 (Mock)
  final LatLng _userLocation = const LatLng(12.9121, 77.6446);
  final LatLng _riderStartLocation = const LatLng(12.9150, 77.6500);

  List<LatLng> _routePoints = [];
  late LatLng _riderLocation;

  // Animation Logic
  AnimationController? _animController;
  int _currentPointIndex = 0;
  String _eta = "Calculating...";
  double _riderRotation = 0.0;

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
  }

  // ... (Undo Logic Methods remain same: _startUndoTimer, _undoOrder)

  void _startUndoTimer() {
    _undoTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_undoSeconds > 0) {
        setState(() {
          _undoSeconds--;
        });
      } else {
        _undoTimer?.cancel();
        if (mounted) {
          context.read<CartProvider>().clearCart();
        }
      }
    });
  }

  void _undoOrder() {
    _undoTimer?.cancel();
    _animController?.stop();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Order Cancelled'),
      backgroundColor: Colors.red,
    ));
  }

  // ...

  Future<void> _fetchRoute() async {
    try {
      final url = Uri.parse(
          'http://router.project-osrm.org/route/v1/driving/${_riderStartLocation.longitude},${_riderStartLocation.latitude};${_userLocation.longitude},${_userLocation.latitude}?overview=full&geometries=geojson');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final coordinates =
            data['routes'][0]['geometry']['coordinates'] as List;

        if (mounted) {
          setState(() {
            _routePoints = coordinates
                .map(
                    (point) => LatLng(point[1].toDouble(), point[0].toDouble()))
                .toList();
            _currentPointIndex = 0;
            _startSmoothAnimation();
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching route: $e");
      _startSmoothAnimation(); // Fallback
    }
  }

  void _startSmoothAnimation() {
    if (_routePoints.isEmpty || _routePoints.length < 2) return;

    // Dispose previous controller if any
    _animController?.dispose();

    // Create a new controller for the entire route or segment by segment?
    // Segment by segment is easier for bearing updates.
    _animateNextSegment();
  }

  void _animateNextSegment() {
    if (_currentPointIndex >= _routePoints.length - 1) {
      _eta = "Arrived";
      _showOrderCompletedDialog();
      return;
    }

    final start = _routePoints[_currentPointIndex];
    final end = _routePoints[_currentPointIndex + 1];

    // Calculate Bearing
    // Simple bearing approximation
    // Note: LatLng doesn't have bearingTo built-in always, doing simple atan2
    // Or just 0.0 if not critical, but let's try.
    // Actually, we can just leave rotation 0 for MVP or calculate it.
    // Let's omit complex bearing for now to safe typos, just move smooth.

    // Determine duration based on distance? Or fixed for smoothness?
    // Let's say 1 second per segment for demo.
    const segmentDuration = Duration(milliseconds: 1000);

    _animController =
        AnimationController(vsync: this, duration: segmentDuration);

    final latTween = Tween<double>(begin: start.latitude, end: end.latitude);
    final lngTween = Tween<double>(begin: start.longitude, end: end.longitude);

    _animController!.addListener(() {
      if (mounted) {
        setState(() {
          _riderLocation = LatLng(latTween.evaluate(_animController!),
              lngTween.evaluate(_animController!));
        });
      }
    });

    _animController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          setState(() {
            _currentPointIndex++;
            // Update ETA
            int remainingPoints = _routePoints.length - _currentPointIndex;
            int minutes = (remainingPoints / 10).ceil(); // Mock logic
            _eta = minutes < 1 ? "Arriving" : "$minutes mins";
          });
          _animateNextSegment();
        }
      }
    });

    _animController!.forward();
  }

  // ... (Dialog methods remain same)

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
    _animController?.dispose();
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
                userAgentPackageName: 'com.freshflow.app',
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
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
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
                  decoration: BoxDecoration(boxShadow: [
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
