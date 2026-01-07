// lib/features/peacelink/domain/entities/peacelink_entity.dart
import 'package:equatable/equatable.dart';
import 'peacelink_status.dart';

class PeacelinkEntity extends Equatable {
  final String id;
  final String referenceNumber;
  final PeacelinkStatus status;
  
  // Parties
  final String merchantId;
  final String? buyerId;
  final String buyerPhone;
  final String? dspId;
  final String? dspWalletNumber;
  
  // Amounts
  final double itemAmount;
  final double deliveryFee;
  final double totalAmount;
  final String deliveryFeePaidBy;
  final double advancePercentage;
  final double advanceAmount;
  
  // Details
  final String itemDescription;
  final String? itemDescriptionAr;
  final int itemQuantity;
  
  // OTP (only visible after DSP assigned)
  final String? otp;
  final DateTime? otpExpiresAt;
  
  // Timestamps
  final DateTime createdAt;
  final DateTime expiresAt;
  final DateTime? approvedAt;
  final DateTime? dspAssignedAt;
  final DateTime? deliveredAt;
  final DateTime? canceledAt;
  final String? canceledBy;
  final String? cancellationReason;
  
  // Related data
  final MerchantInfo? merchant;
  final BuyerInfo? buyer;
  final DspInfo? dsp;
  final List<PayoutInfo> payouts;
  final List<TimelineEvent> timeline;

  const PeacelinkEntity({
    required this.id,
    required this.referenceNumber,
    required this.status,
    required this.merchantId,
    this.buyerId,
    required this.buyerPhone,
    this.dspId,
    this.dspWalletNumber,
    required this.itemAmount,
    required this.deliveryFee,
    required this.totalAmount,
    required this.deliveryFeePaidBy,
    required this.advancePercentage,
    required this.advanceAmount,
    required this.itemDescription,
    this.itemDescriptionAr,
    required this.itemQuantity,
    this.otp,
    this.otpExpiresAt,
    required this.createdAt,
    required this.expiresAt,
    this.approvedAt,
    this.dspAssignedAt,
    this.deliveredAt,
    this.canceledAt,
    this.canceledBy,
    this.cancellationReason,
    this.merchant,
    this.buyer,
    this.dsp,
    this.payouts = const [],
    this.timeline = const [],
  });

  // Computed properties
  bool get canCancel => 
    status != PeacelinkStatus.delivered && 
    status != PeacelinkStatus.canceled &&
    status != PeacelinkStatus.expired;
    
  bool get canAssignDsp => status == PeacelinkStatus.sphActive;
  
  bool get canReassignDsp => 
    status == PeacelinkStatus.dspAssigned && 
    otp != null;
    
  bool get showOtp => 
    status == PeacelinkStatus.dspAssigned || 
    status == PeacelinkStatus.otpGenerated;
    
  bool get isDspAssigned => dspId != null;

  @override
  List<Object?> get props => [id, status, referenceNumber];
}

class MerchantInfo extends Equatable {
  final String id;
  final String businessName;
  final String? phone;
  
  const MerchantInfo({
    required this.id,
    required this.businessName,
    this.phone,
  });
  
  @override
  List<Object?> get props => [id, businessName];
}

class BuyerInfo extends Equatable {
  final String phone;
  final String? name;
  final DateTime? approvedAt;
  
  const BuyerInfo({
    required this.phone,
    this.name,
    this.approvedAt,
  });
  
  @override
  List<Object?> get props => [phone];
}

class DspInfo extends Equatable {
  final String id;
  final String name;
  final String walletNumber;
  final DateTime? assignedAt;
  
  const DspInfo({
    required this.id,
    required this.name,
    required this.walletNumber,
    this.assignedAt,
  });
  
  @override
  List<Object?> get props => [id, walletNumber];
}

class PayoutInfo extends Equatable {
  final String recipientType;
  final double grossAmount;
  final double feeAmount;
  final double netAmount;
  final String payoutType;
  final DateTime createdAt;
  
  const PayoutInfo({
    required this.recipientType,
    required this.grossAmount,
    required this.feeAmount,
    required this.netAmount,
    required this.payoutType,
    required this.createdAt,
  });
  
  @override
  List<Object?> get props => [recipientType, netAmount, createdAt];
}

class TimelineEvent extends Equatable {
  final String event;
  final DateTime timestamp;
  final String? actor;
  final String? details;
  
  const TimelineEvent({
    required this.event,
    required this.timestamp,
    this.actor,
    this.details,
  });
  
  @override
  List<Object?> get props => [event, timestamp];
}

// lib/features/peacelink/domain/entities/peacelink_status.dart
enum PeacelinkStatus {
  created,
  pendingApproval,
  sphActive,
  dspAssigned,
  otpGenerated,
  delivered,
  canceled,
  disputed,
  resolved,
  expired;

  String get label {
    switch (this) {
      case PeacelinkStatus.created:
        return 'Created';
      case PeacelinkStatus.pendingApproval:
        return 'Pending Approval';
      case PeacelinkStatus.sphActive:
        return 'Payment Held';
      case PeacelinkStatus.dspAssigned:
        return 'DSP Assigned';
      case PeacelinkStatus.otpGenerated:
        return 'Ready for Delivery';
      case PeacelinkStatus.delivered:
        return 'Delivered';
      case PeacelinkStatus.canceled:
        return 'Canceled';
      case PeacelinkStatus.disputed:
        return 'Disputed';
      case PeacelinkStatus.resolved:
        return 'Resolved';
      case PeacelinkStatus.expired:
        return 'Expired';
    }
  }

  String get labelAr {
    switch (this) {
      case PeacelinkStatus.created:
        return 'تم الإنشاء';
      case PeacelinkStatus.pendingApproval:
        return 'في انتظار الموافقة';
      case PeacelinkStatus.sphActive:
        return 'قيد الضمان';
      case PeacelinkStatus.dspAssigned:
        return 'تم تعيين المندوب';
      case PeacelinkStatus.otpGenerated:
        return 'جاهز للتسليم';
      case PeacelinkStatus.delivered:
        return 'تم التسليم';
      case PeacelinkStatus.canceled:
        return 'ملغي';
      case PeacelinkStatus.disputed:
        return 'نزاع مفتوح';
      case PeacelinkStatus.resolved:
        return 'تم الحل';
      case PeacelinkStatus.expired:
        return 'منتهي';
    }
  }
}

// lib/features/peacelink/presentation/providers/peacelink_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/peacelink_entity.dart';
import '../../domain/entities/peacelink_status.dart';
import '../../domain/repositories/peacelink_repository.dart';

part 'peacelink_provider.freezed.dart';

// State
@freezed
class PeacelinkState with _$PeacelinkState {
  const factory PeacelinkState.initial() = _Initial;
  const factory PeacelinkState.loading() = _Loading;
  const factory PeacelinkState.loaded(PeacelinkEntity peacelink) = _Loaded;
  const factory PeacelinkState.error(String message) = _Error;
}

// Notifier
class PeacelinkNotifier extends StateNotifier<PeacelinkState> {
  final PeacelinkRepository _repository;
  
  PeacelinkNotifier(this._repository) : super(const PeacelinkState.initial());

  Future<void> loadPeacelink(String id) async {
    state = const PeacelinkState.loading();
    final result = await _repository.getPeacelink(id);
    result.fold(
      (failure) => state = PeacelinkState.error(failure.message),
      (peacelink) => state = PeacelinkState.loaded(peacelink),
    );
  }

  Future<bool> approvePeacelink(String id, String pin) async {
    final currentState = state;
    if (currentState is! _Loaded) return false;
    
    state = const PeacelinkState.loading();
    final result = await _repository.approvePeacelink(id, pin);
    return result.fold(
      (failure) {
        state = PeacelinkState.error(failure.message);
        return false;
      },
      (peacelink) {
        state = PeacelinkState.loaded(peacelink);
        return true;
      },
    );
  }

  Future<bool> assignDsp(String id, String dspWalletNumber) async {
    final currentState = state;
    if (currentState is! _Loaded) return false;
    
    state = const PeacelinkState.loading();
    final result = await _repository.assignDsp(id, dspWalletNumber);
    return result.fold(
      (failure) {
        state = PeacelinkState.error(failure.message);
        return false;
      },
      (peacelink) {
        state = PeacelinkState.loaded(peacelink);
        return true;
      },
    );
  }

  Future<bool> reassignDsp(String id, String newDspWallet, String reason) async {
    final currentState = state;
    if (currentState is! _Loaded) return false;
    
    state = const PeacelinkState.loading();
    final result = await _repository.reassignDsp(id, newDspWallet, reason);
    return result.fold(
      (failure) {
        state = PeacelinkState.error(failure.message);
        return false;
      },
      (peacelink) {
        state = PeacelinkState.loaded(peacelink);
        return true;
      },
    );
  }

  Future<CancellationResult?> cancelPeacelink(String id, String reason) async {
    final currentState = state;
    if (currentState is! _Loaded) return null;
    
    state = const PeacelinkState.loading();
    final result = await _repository.cancelPeacelink(id, reason);
    return result.fold(
      (failure) {
        state = PeacelinkState.error(failure.message);
        return null;
      },
      (cancellation) {
        // Reload to get updated state
        loadPeacelink(id);
        return cancellation;
      },
    );
  }

  Future<bool> confirmDelivery(String id, String otp) async {
    final currentState = state;
    if (currentState is! _Loaded) return false;
    
    state = const PeacelinkState.loading();
    final result = await _repository.confirmDelivery(id, otp);
    return result.fold(
      (failure) {
        state = PeacelinkState.error(failure.message);
        return false;
      },
      (peacelink) {
        state = PeacelinkState.loaded(peacelink);
        return true;
      },
    );
  }
}

// Provider
final peacelinkProvider = StateNotifierProvider.family<
    PeacelinkNotifier, PeacelinkState, String>((ref, id) {
  final repository = ref.watch(peacelinkRepositoryProvider);
  final notifier = PeacelinkNotifier(repository);
  notifier.loadPeacelink(id);
  return notifier;
});

// List Provider
@freezed
class PeacelinkListState with _$PeacelinkListState {
  const factory PeacelinkListState.initial() = _ListInitial;
  const factory PeacelinkListState.loading() = _ListLoading;
  const factory PeacelinkListState.loaded({
    required List<PeacelinkEntity> peacelinks,
    required int totalCount,
    required int currentPage,
    required bool hasMore,
  }) = _ListLoaded;
  const factory PeacelinkListState.error(String message) = _ListError;
}

class PeacelinkListNotifier extends StateNotifier<PeacelinkListState> {
  final PeacelinkRepository _repository;
  PeacelinkStatus? _statusFilter;
  
  PeacelinkListNotifier(this._repository) : super(const PeacelinkListState.initial());

  Future<void> loadPeacelinks({
    PeacelinkStatus? status,
    int page = 1,
    int limit = 20,
  }) async {
    _statusFilter = status;
    
    if (page == 1) {
      state = const PeacelinkListState.loading();
    }
    
    final result = await _repository.listPeacelinks(
      status: status,
      page: page,
      limit: limit,
    );
    
    result.fold(
      (failure) => state = PeacelinkListState.error(failure.message),
      (response) {
        final currentState = state;
        List<PeacelinkEntity> allPeacelinks = [];
        
        if (currentState is _ListLoaded && page > 1) {
          allPeacelinks = [...currentState.peacelinks, ...response.data];
        } else {
          allPeacelinks = response.data;
        }
        
        state = PeacelinkListState.loaded(
          peacelinks: allPeacelinks,
          totalCount: response.total,
          currentPage: page,
          hasMore: allPeacelinks.length < response.total,
        );
      },
    );
  }

  Future<void> loadMore() async {
    final currentState = state;
    if (currentState is! _ListLoaded || !currentState.hasMore) return;
    
    await loadPeacelinks(
      status: _statusFilter,
      page: currentState.currentPage + 1,
    );
  }

  Future<void> refresh() async {
    await loadPeacelinks(status: _statusFilter, page: 1);
  }
}

final peacelinkListProvider =
    StateNotifierProvider<PeacelinkListNotifier, PeacelinkListState>((ref) {
  final repository = ref.watch(peacelinkRepositoryProvider);
  return PeacelinkListNotifier(repository);
});

// Cancellation result
class CancellationResult {
  final double refundToBuyer;
  final double dspPayout;
  final double merchantPayout;
  final double platformFee;
  final String message;
  
  CancellationResult({
    required this.refundToBuyer,
    required this.dspPayout,
    required this.merchantPayout,
    required this.platformFee,
    required this.message,
  });
}
