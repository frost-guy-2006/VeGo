import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vego/core/models/address_model.dart';
import 'package:vego/core/models/app_error.dart';

/// Repository for address-related data operations.
/// Handles CRUD against the Supabase `addresses` table.
class AddressRepository {
  final SupabaseClient _client;

  AddressRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  /// Fetch all addresses for a specific user
  Future<List<Address>> fetchUserAddresses(String userId) async {
    try {
      final response = await _client
          .from('addresses')
          .select()
          .eq('user_id', userId)
          .order('is_default', ascending: false)
          .order('created_at', ascending: false);

      return (response as List).map((json) => Address.fromSupabase(json)).toList();
    } catch (e) {
      debugPrint('AddressRepository: Error fetching addresses: $e');
      throw AppError.from(e);
    }
  }

  /// Add a new address
  Future<Address> addAddress({
    required String userId,
    required Address address,
  }) async {
    try {
      // If this is set as default, clear other defaults first
      if (address.isDefault) {
        await _clearDefaults(userId);
      }

      final response = await _client
          .from('addresses')
          .insert({
            'user_id': userId,
            'label': address.label,
            'full_name': address.fullName,
            'phone_number': address.phoneNumber,
            'street': address.addressLine1,
            'address_line_2': address.addressLine2,
            'city': address.city,
            'state': address.state,
            'zip_code': address.pincode,
            'landmark': address.landmark,
            'is_default': address.isDefault,
          })
          .select()
          .single();

      return Address.fromSupabase(response);
    } catch (e) {
      debugPrint('AddressRepository: Error adding address: $e');
      throw AppError.from(e);
    }
  }

  /// Update an existing address
  Future<Address> updateAddress({
    required String userId,
    required Address address,
  }) async {
    try {
      if (address.isDefault) {
        await _clearDefaults(userId);
      }

      final response = await _client
          .from('addresses')
          .update({
            'label': address.label,
            'full_name': address.fullName,
            'phone_number': address.phoneNumber,
            'street': address.addressLine1,
            'address_line_2': address.addressLine2,
            'city': address.city,
            'state': address.state,
            'zip_code': address.pincode,
            'landmark': address.landmark,
            'is_default': address.isDefault,
          })
          .eq('id', address.id)
          .eq('user_id', userId)
          .select()
          .single();

      return Address.fromSupabase(response);
    } catch (e) {
      debugPrint('AddressRepository: Error updating address: $e');
      throw AppError.from(e);
    }
  }

  /// Delete an address
  Future<void> deleteAddress({
    required String userId,
    required String addressId,
  }) async {
    try {
      await _client
          .from('addresses')
          .delete()
          .eq('id', addressId)
          .eq('user_id', userId);
    } catch (e) {
      debugPrint('AddressRepository: Error deleting address: $e');
      throw AppError.from(e);
    }
  }

  /// Set an address as the default
  Future<void> setAsDefault({
    required String userId,
    required String addressId,
  }) async {
    try {
      await _clearDefaults(userId);
      await _client
          .from('addresses')
          .update({'is_default': true})
          .eq('id', addressId)
          .eq('user_id', userId);
    } catch (e) {
      debugPrint('AddressRepository: Error setting default address: $e');
      throw AppError.from(e);
    }
  }

  /// Clear all default flags for a user
  Future<void> _clearDefaults(String userId) async {
    await _client
        .from('addresses')
        .update({'is_default': false})
        .eq('user_id', userId)
        .eq('is_default', true);
  }
}
