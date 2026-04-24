import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vego/core/providers/riverpod/providers.dart';
import 'package:vego/core/theme/app_colors.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vego/features/tracking/widgets/delivery_header_widget.dart';
import 'package:vego/features/tracking/widgets/rider_info_card.dart';
import 'package:vego/features/tracking/widgets/tip_section_widget.dart';
import 'package:vego/features/tracking/widgets/delivery_instructions_card.dart';
import 'package:vego/features/tracking/widgets/order_details_card.dart';

class TrackingScreen extends ConsumerStatefulWidget {
  const TrackingScreen({super.key});

  @override
  ConsumerState<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends ConsumerState<TrackingScreen> {
  // Coordinates for HSR Layout, Sector 2 (Mock)
  final LatLng _userLocation = const LatLng(12.9121, 77.6446);
  final LatLng _riderStartLocation = const LatLng(12.9150, 77.6500);

  List<LatLng> _routePoints = [];
  late LatLng _riderLocation;
  Timer? _timer;
  int _currentPointIndex = 0;
  String _eta = "Calculating...";
  int _currentStep = 0;

  // Undo Logic
  int _undoSeconds = 60;
  Timer? _undoTimer;

  @override
  void initState() {
    super.initState();
    _riderLocation = _riderStartLocation;
    _routePoints = [_riderStartLocation, _userLocation];
    _fetchRoute();
    _startUndoTimer();
    _startDemoTimeline();
  }

  void _startDemoTimeline() async {
    // Simulate steps: 0=Placed, 1=Packing, 2=Assigned, 3=OnWay
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _currentStep = 1);

    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _currentStep = 2);

    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _currentStep = 3);
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
          ref.read(cartProvider.notifier).clearCart();
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

          int remainingPoints = _routePoints.length - _currentPointIndex;
          int minutes = (remainingPoints / 10).ceil();
          _eta = minutes < 1 ? "Arriving shortly" : "$minutes minutes";
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
              ref.read(cartProvider.notifier).clearCart();
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

  String _getStatusSentence() {
    if (_currentStep == 0) return "Order placed, waiting for confirmation.";
    if (_currentStep == 1) return "Packing your fresh items.";
    if (_currentStep == 2) {
      return "Tapabrata has been assigned as your partner.";
    }
    return "I have picked up your order, and I am on the way.";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: Stack(
        children: [
          // Scrollable Content
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Spacer for the sticky header
              SliverToBoxAdapter(
                child:
                    SizedBox(height: MediaQuery.of(context).padding.top + 80),
              ),

              // Embedded Map Card
              SliverToBoxAdapter(
                child: Container(
                  height: 250,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Stack(
                      children: [
                        FlutterMap(
                          options: MapOptions(
                            initialCenter: _userLocation,
                            initialZoom: 15.0,
                            interactionOptions: const InteractionOptions(
                              flags: InteractiveFlag.none, // Static map snippet
                            ),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? 'https://cartodb-basemaps-{s}.global.ssl.fastly.net/dark_all/{z}/{x}/{y}.png'
                                  : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.vego.app',
                            ),
                            PolylineLayer(
                              polylines: [
                                Polyline(
                                  points: _routePoints,
                                  strokeWidth: 4.0,
                                  color:
                                      AppColors.primary.withValues(alpha: 0.3),
                                ),
                                Polyline(
                                  points:
                                      _routePoints.sublist(_currentPointIndex),
                                  strokeWidth: 4.0,
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: _userLocation,
                                  width: 40,
                                  height: 40,
                                  child: const Icon(Icons.location_on,
                                      color: AppColors.accent, size: 40),
                                ),
                                Marker(
                                  point: _riderLocation,
                                  width: 40,
                                  height: 40,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                            blurRadius: 5,
                                            color: Colors.black26)
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
                        // Expand Map Button
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            decoration: BoxDecoration(
                              color:
                                  context.surfaceColor.withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(Icons.open_in_full,
                                  size: 18, color: context.textPrimary),
                              onPressed: () {
                                // Expand map modal logic here
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Rider Info Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: RiderInfoCard(
                    riderName: 'Tapabrata',
                    statusMessage: _getStatusSentence(),
                    currentStep: _currentStep,
                    onCall: () {},
                  ),
                ),
              ),

              // Tip Section
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: TipSectionWidget(),
                ),
              ),

              // Delivery Instructions
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: DeliveryInstructionsCard(),
                ),
              ),

              // Order Details
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: OrderDetailsCard(),
                ),
              ),

              // Bottom spacing
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),

          // Sticky Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: DeliveryHeaderWidget(
              statusText: 'Order is on the way',
              eta: _currentStep < 3 ? 'Preparing...' : 'Arriving in $_eta',
              onBack: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
                ref.read(cartProvider.notifier).clearCart();
              },
            ),
          ),

          // Floating Undo Button (Kept from original)
          if (_undoSeconds > 0)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 4))
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: _undoOrder,
                        icon: const Icon(Icons.undo, color: Colors.white),
                        label: Text(
                          'Undo Order ($_undoSeconds s)',
                          style: GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.redAccent.withValues(alpha: 0.9),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
