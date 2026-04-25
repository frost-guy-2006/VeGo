import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vego/core/models/address_model.dart';
import 'package:vego/core/repositories/address_repository.dart';

/// Address state for Riverpod.
class AddressState {
  final List<Address> addresses;
  final Address? selectedDeliveryAddress;
  final bool isLoading;
  final String? error;

  const AddressState({
    this.addresses = const [],
    this.selectedDeliveryAddress,
    this.isLoading = false,
    this.error,
  });

  int get addressCount => addresses.length;

  /// Get the default address
  Address? get defaultAddress {
    try {
      return addresses.firstWhere((a) => a.isDefault);
    } catch (e) {
      return addresses.isNotEmpty ? addresses.first : null;
    }
  }

  /// Effective delivery address (selected or default)
  Address? get effectiveDeliveryAddress =>
      selectedDeliveryAddress ?? defaultAddress;

  AddressState copyWith({
    List<Address>? addresses,
    Address? selectedDeliveryAddress,
    bool? isLoading,
    String? error,
    bool clearSelection = false,
  }) {
    return AddressState(
      addresses: addresses ?? this.addresses,
      selectedDeliveryAddress: clearSelection
          ? null
          : (selectedDeliveryAddress ?? this.selectedDeliveryAddress),
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Address notifier for Riverpod.
class AddressNotifier extends StateNotifier<AddressState> {
  final AddressRepository _repository;
  String? _currentUserId;

  AddressNotifier({AddressRepository? repository})
      : _repository = repository ?? AddressRepository(),
        super(const AddressState());

  /// Initialize for a specific user
  Future<void> initForUser(String? userId) async {
    _currentUserId = userId;
    state = const AddressState();

    if (userId != null) {
      await loadAddresses();
    }
  }

  /// Load addresses from Supabase
  Future<void> loadAddresses() async {
    if (_currentUserId == null) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final addresses =
          await _repository.fetchUserAddresses(_currentUserId!);
      state = state.copyWith(addresses: addresses, isLoading: false);
    } catch (e) {
      debugPrint('AddressNotifier: Error loading addresses: $e');
      state = state.copyWith(isLoading: false, error: 'Failed to load addresses');
    }
  }

  /// Select a delivery address for current order
  void selectDeliveryAddress(Address address) {
    state = state.copyWith(selectedDeliveryAddress: address);
  }

  /// Reset to default address
  void resetToDefaultAddress() {
    state = state.copyWith(clearSelection: true);
  }

  /// Add a new address
  Future<void> addAddress(Address address) async {
    if (_currentUserId == null) return;

    try {
      await _repository.addAddress(
        userId: _currentUserId!,
        address: address,
      );
      await loadAddresses(); // Reload to get consistent state
    } catch (e) {
      debugPrint('AddressNotifier: Error adding address: $e');
      state = state.copyWith(error: 'Operation failed');
    }
  }

  /// Update an existing address
  Future<void> updateAddress(Address address) async {
    if (_currentUserId == null) return;

    try {
      await _repository.updateAddress(
        userId: _currentUserId!,
        address: address,
      );
      await loadAddresses();
    } catch (e) {
      debugPrint('AddressNotifier: Error updating address: $e');
      state = state.copyWith(error: 'Operation failed');
    }
  }

  /// Delete an address
  Future<void> deleteAddress(String addressId) async {
    if (_currentUserId == null) return;

    try {
      await _repository.deleteAddress(
        userId: _currentUserId!,
        addressId: addressId,
      );

      // Reset selection if deleted address was selected
      if (state.selectedDeliveryAddress?.id == addressId) {
        state = state.copyWith(clearSelection: true);
      }

      await loadAddresses();
    } catch (e) {
      debugPrint('AddressNotifier: Error deleting address: $e');
      state = state.copyWith(error: 'Operation failed');
    }
  }

  /// Set an address as default
  Future<void> setAsDefault(String addressId) async {
    if (_currentUserId == null) return;

    try {
      await _repository.setAsDefault(
        userId: _currentUserId!,
        addressId: addressId,
      );
      await loadAddresses();
    } catch (e) {
      debugPrint('AddressNotifier: Error setting default: $e');
      state = state.copyWith(error: 'Operation failed');
    }
  }

  /// Clear state on logout
  void clearForLogout() {
    _currentUserId = null;
    state = const AddressState();
  }
}

/// Riverpod provider for address state.
final addressProvider =
    StateNotifierProvider<AddressNotifier, AddressState>((ref) {
  return AddressNotifier();
});
