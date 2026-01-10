import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/peacelink.dart';

class PeaceLinkState {
  final List<PeaceLink> peacelinks;
  final bool isLoading;
  final String? error;
  final String? filter;

  const PeaceLinkState({
    this.peacelinks = const [],
    this.isLoading = false,
    this.error,
    this.filter,
  });

  PeaceLinkState copyWith({
    List<PeaceLink>? peacelinks,
    bool? isLoading,
    String? error,
    String? filter,
  }) {
    return PeaceLinkState(
      peacelinks: peacelinks ?? this.peacelinks,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      filter: filter ?? this.filter,
    );
  }
}

class PeaceLinkNotifier extends StateNotifier<PeaceLinkState> {
  PeaceLinkNotifier() : super(const PeaceLinkState());

  Future<void> loadPeaceLinks() async {
    state = state.copyWith(isLoading: true);
    
    try {
      // Mock data - replace with actual API call
      await Future.delayed(const Duration(seconds: 1));
      
      final mockData = [
        PeaceLink(
          id: 'PL123456',
          itemName: 'iPhone 15 Pro Max',
          itemDescription: '256GB، لون أسود، جديد بالكرتونة',
          itemPrice: 45000,
          deliveryFee: 100,
          totalAmount: 45100,
          status: PeaceLinkStatus.inTransit,
          otp: '1234',
          otpVisible: true, // BUG-003: Backend controls this
          deliveryAddress: '15 شارع التحرير، الدقي، الجيزة',
          deliveryDeadline: DateTime.now().add(const Duration(days: 1)),
          trackingCode: 'TRK789456123',
          merchantName: 'متجر التقنية',
          dspName: 'شركة التوصيل السريع',
          advancedPaymentPercentage: 50,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        PeaceLink(
          id: 'PL123457',
          itemName: 'Samsung TV 55"',
          itemDescription: 'شاشة 4K Smart TV',
          itemPrice: 15000,
          deliveryFee: 150,
          totalAmount: 15150,
          status: PeaceLinkStatus.delivered,
          otp: null,
          otpVisible: false,
          deliveryAddress: '22 شارع مكرم عبيد، نصر',
          merchantName: 'سامسونج شوب',
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
        PeaceLink(
          id: 'PL123458',
          itemName: 'MacBook Air M2',
          itemPrice: 55000,
          deliveryFee: 100,
          totalAmount: 55100,
          status: PeaceLinkStatus.created,
          otp: null,
          otpVisible: false, // OTP not visible until DSP assigned
          deliveryAddress: '10 شارع الهرم، الجيزة',
          merchantName: 'Apple Store',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      ];

      state = state.copyWith(
        peacelinks: mockData,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<PeaceLink?> getPeaceLinkDetails(String id) async {
    try {
      // Find in cached list first
      final cached = state.peacelinks.where((p) => p.id == id).firstOrNull;
      if (cached != null) return cached;

      // Mock API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Return mock data
      return PeaceLink(
        id: id,
        itemName: 'iPhone 15 Pro Max',
        itemDescription: '256GB، لون أسود، جديد بالكرتونة',
        itemPrice: 45000,
        deliveryFee: 100,
        totalAmount: 45100,
        status: PeaceLinkStatus.inTransit,
        otp: '1234',
        otpVisible: true, // BUG-003: Backend controls this based on user role and status
        deliveryAddress: '15 شارع التحرير، الدقي، الجيزة',
        deliveryDeadline: DateTime.now().add(const Duration(days: 1)),
        trackingCode: 'TRK789456123',
        merchantName: 'متجر التقنية',
        merchantMobile: '01098765432',
        dspName: 'شركة التوصيل السريع',
        dspMobile: '01055555555',
        policyName: 'السياسة الأساسية',
        advancedPaymentPercentage: 50,
        platformFee: 225, // 0.5% of 45000
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      );
    } catch (e) {
      return null;
    }
  }

  Future<bool> createPeaceLink(Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isLoading: true);
      
      // Mock API call
      await Future.delayed(const Duration(seconds: 1));
      
      // In real app, call API and add to list
      await loadPeaceLinks();
      
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  // REQ-002: Cancel PeaceLink
  Future<bool> cancelPeaceLink(String id) async {
    try {
      // Mock API call - In real app, call peacelinkAPI.cancel(id)
      await Future.delayed(const Duration(seconds: 1));
      
      // Update local state
      final updated = state.peacelinks.map((p) {
        if (p.id == id) {
          return PeaceLink(
            id: p.id,
            itemName: p.itemName,
            itemDescription: p.itemDescription,
            itemPrice: p.itemPrice,
            deliveryFee: p.deliveryFee,
            totalAmount: p.totalAmount,
            status: PeaceLinkStatus.cancelled,
            otp: null,
            otpVisible: false,
            deliveryAddress: p.deliveryAddress,
            deliveryDeadline: p.deliveryDeadline,
            trackingCode: p.trackingCode,
            merchantName: p.merchantName,
            dspName: p.dspName,
            advancedPaymentPercentage: p.advancedPaymentPercentage,
            createdAt: p.createdAt,
            updatedAt: DateTime.now(),
          );
        }
        return p;
      }).toList();
      
      state = state.copyWith(peacelinks: updated);
      return true;
    } catch (e) {
      return false;
    }
  }

  // REQ-002: Confirm Delivery (for DSP)
  Future<bool> confirmDelivery(String id, String otp) async {
    try {
      // Mock API call - In real app, verify OTP with backend
      await Future.delayed(const Duration(seconds: 1));
      
      // Update local state
      final updated = state.peacelinks.map((p) {
        if (p.id == id) {
          return PeaceLink(
            id: p.id,
            itemName: p.itemName,
            itemDescription: p.itemDescription,
            itemPrice: p.itemPrice,
            deliveryFee: p.deliveryFee,
            totalAmount: p.totalAmount,
            status: PeaceLinkStatus.delivered,
            otp: null,
            otpVisible: false,
            deliveryAddress: p.deliveryAddress,
            deliveryDeadline: p.deliveryDeadline,
            trackingCode: p.trackingCode,
            merchantName: p.merchantName,
            dspName: p.dspName,
            advancedPaymentPercentage: p.advancedPaymentPercentage,
            createdAt: p.createdAt,
            updatedAt: DateTime.now(),
          );
        }
        return p;
      }).toList();
      
      state = state.copyWith(peacelinks: updated);
      return true;
    } catch (e) {
      return false;
    }
  }

  void setFilter(String? filter) {
    state = state.copyWith(filter: filter);
  }

  List<PeaceLink> get filteredPeaceLinks {
    if (state.filter == null || state.filter == 'all') {
      return state.peacelinks;
    }
    
    switch (state.filter) {
      case 'active':
        return state.peacelinks.where((p) => 
          [PeaceLinkStatus.created, PeaceLinkStatus.approved, PeaceLinkStatus.dspAssigned, PeaceLinkStatus.inTransit].contains(p.status)
        ).toList();
      case 'completed':
        return state.peacelinks.where((p) => 
          [PeaceLinkStatus.delivered, PeaceLinkStatus.completed].contains(p.status)
        ).toList();
      case 'disputed':
        return state.peacelinks.where((p) => p.status == PeaceLinkStatus.disputed).toList();
      case 'cancelled':
        return state.peacelinks.where((p) => p.status == PeaceLinkStatus.cancelled).toList();
      default:
        return state.peacelinks;
    }
  }
}

final peacelinkProvider = StateNotifierProvider<PeaceLinkNotifier, PeaceLinkState>((ref) {
  return PeaceLinkNotifier();
});
