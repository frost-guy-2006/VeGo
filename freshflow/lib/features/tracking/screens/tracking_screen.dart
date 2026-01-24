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

class _TrackingScreenState extends State<TrackingScreen> {
  // Coordinates for HSR Layout, Sector 2 (Mock)
  final LatLng _userLocation = const LatLng(12.9121, 77.6446);
  // Rider starting point (slightly away)
  final LatLng _riderLocation = const LatLng(12.9150, 77.6500);

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
                    points: [_userLocation, _riderLocation],
                    strokeWidth: 4.0,
                    color: AppColors.primary,
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
                    child: const Icon(Icons.location_on, color: AppColors.accent, size: 40),
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
                        boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black26)],
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const Icon(Icons.delivery_dining, color: AppColors.primary, size: 24),
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
                   context.read<CartProvider>().clearCart(); 
                },
              ),
            ),
          ),

          // Status Panel
          Positioned(
            bottom: 30,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Arriving in',
                            style: GoogleFonts.plusJakartaSans(
                              color: AppColors.secondary,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '12 mins',
                            style: GoogleFonts.plusJakartaSans(
                              color: AppColors.textDark,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.phone, color: AppColors.primary, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Call Rider',
                              style: GoogleFonts.plusJakartaSans(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.secondary,
                        backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=33'),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ramesh Kumar',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.textDark,
                            ),
                          ),
                          Text(
                            'Start Rating: 4.8',
                            style: GoogleFonts.plusJakartaSans(
                              color: AppColors.secondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
