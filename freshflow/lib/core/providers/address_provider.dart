import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vego/core/models/address_model.dart';
import 'dart:convert';

/// Provider for managing user addresses with user-specific isolation.
/// Each user's addresses are stored separately using their user ID.
class AddressProvider extends ChangeNotifier {
  final List<Address> _addresses = [];
  String? _currentUserId;

  /// Currently selected address for delivery (may differ from default)
  Address? _selectedDeliveryAddress;

  List<Address> get addresses => List.unmodifiable(_addresses);
  int get addressCount => _addresses.length;

  /// Get the currently selected delivery address (for immediate orders)
  Address? get selectedDeliveryAddress =>
      _selectedDeliveryAddress ?? defaultAddress;

  /// Get the default address (saved preference)
  Address? get defaultAddress {
    try {
      return _addresses.firstWhere((a) => a.isDefault);
    } catch (e) {
      return _addresses.isNotEmpty ? _addresses.first : null;
    }
  }

  /// Get storage key specific to current user
  String get _storageKey {
    if (_currentUserId == null) {
      return 'user_addresses_anonymous';
    }
    return 'user_addresses_$_currentUserId';
  }

  /// Initialize provider with current user's data.
  /// Call this when user logs in or app starts.
  Future<void> initForUser(String? userId) async {
    // Clear previous user's data from memory
    _addresses.clear();
    _selectedDeliveryAddress = null;
    _currentUserId = userId;

    if (userId != null) {
      await loadFromStorage();
    }
    notifyListeners();
  }

  /// Select a delivery address for current order (without changing default)
  void selectDeliveryAddress(Address address) {
    _selectedDeliveryAddress = address;
    notifyListeners();
  }

  /// Reset to default address
  void resetToDefaultAddress() {
    _selectedDeliveryAddress = null;
    notifyListeners();
  }

  /// Add a new address
  Future<void> addAddress(Address address) async {
    // If this is the first address or it's set as default, update other defaults
    if (address.isDefault || _addresses.isEmpty) {
      _clearDefaults();
      _addresses.add(address.copyWith(isDefault: true));
    } else {
      _addresses.add(address);
    }
    await _saveToStorage();
    notifyListeners();
  }

  /// Update an existing address
  Future<void> updateAddress(Address address) async {
    final index = _addresses.indexWhere((a) => a.id == address.id);
    if (index != -1) {
      if (address.isDefault) {
        _clearDefaults();
      }
      _addresses[index] = address;
      await _saveToStorage();
      notifyListeners();
    }
  }

  /// Delete an address
  Future<void> deleteAddress(String addressId) async {
    final wasDefault = _addresses.any((a) => a.id == addressId && a.isDefault);
    final wasSelected = _selectedDeliveryAddress?.id == addressId;

    _addresses.removeWhere((a) => a.id == addressId);

    // If we deleted the default and there are still addresses, make first one default
    if (wasDefault && _addresses.isNotEmpty) {
      _addresses[0] = _addresses[0].copyWith(isDefault: true);
    }

    // Reset selection if deleted address was selected
    if (wasSelected) {
      _selectedDeliveryAddress = null;
    }

    await _saveToStorage();
    notifyListeners();
  }

  /// Set an address as default
  Future<void> setAsDefault(String addressId) async {
    _clearDefaults();
    final index = _addresses.indexWhere((a) => a.id == addressId);
    if (index != -1) {
      _addresses[index] = _addresses[index].copyWith(isDefault: true);
      await _saveToStorage();
      notifyListeners();
    }
  }

  void _clearDefaults() {
    for (var i = 0; i < _addresses.length; i++) {
      if (_addresses[i].isDefault) {
        _addresses[i] = _addresses[i].copyWith(isDefault: false);
      }
    }
  }

  /// Load addresses from persistent storage (user-specific)
  Future<void> loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final addressesJson = prefs.getString(_storageKey);

      if (addressesJson != null) {
        final List<dynamic> decoded = json.decode(addressesJson);
        _addresses.clear();
        _addresses.addAll(decoded.map((item) => Address.fromJson(item)));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading addresses from storage: $e');
    }
  }

  /// Save addresses to persistent storage (user-specific)
  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final addressesJson =
          json.encode(_addresses.map((a) => a.toJson()).toList());
      await prefs.setString(_storageKey, addressesJson);
    } catch (e) {
      debugPrint('Error saving addresses to storage: $e');
    }
  }

  /// Clear all addresses for current user (for logout)
  Future<void> clearForLogout() async {
    _addresses.clear();
    _selectedDeliveryAddress = null;
    _currentUserId = null;
    notifyListeners();
  }

  /// Generate a unique ID for new addresses
  String generateId() {
    return 'addr_${DateTime.now().millisecondsSinceEpoch}';
  }
}
