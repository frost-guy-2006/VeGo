import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vego/core/models/address_model.dart';
import 'dart:convert';

/// Provider for managing user addresses
class AddressProvider extends ChangeNotifier {
  final List<Address> _addresses = [];
  static const String _storageKey = 'user_addresses';

  List<Address> get addresses => List.unmodifiable(_addresses);
  int get addressCount => _addresses.length;

  /// Get the default address
  Address? get defaultAddress {
    try {
      return _addresses.firstWhere((a) => a.isDefault);
    } catch (e) {
      return _addresses.isNotEmpty ? _addresses.first : null;
    }
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
    _addresses.removeWhere((a) => a.id == addressId);

    // If we deleted the default and there are still addresses, make first one default
    if (wasDefault && _addresses.isNotEmpty) {
      _addresses[0] = _addresses[0].copyWith(isDefault: true);
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

  /// Load addresses from persistent storage
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

  /// Save addresses to persistent storage
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

  /// Generate a unique ID for new addresses
  String generateId() {
    return 'addr_${DateTime.now().millisecondsSinceEpoch}';
  }
}
