/// PeaceLink Constants
/// Based on Re-Engineering Specification v2.0
/// Defines all status codes, labels, and helper methods for PeaceLink transactions

class PeaceLinkConstants {
  // ============ STATUS CODES ============
  // Initial States
  static const int CREATED = 0;
  static const int PENDING_APPROVAL = 3;
  
  // Active States
  static const int SPH_ACTIVE = 1;
  static const int DSP_ASSIGNED = 4;
  static const int OTP_GENERATED = 5;
  static const int IN_TRANSIT = 6;
  
  // Terminal States
  static const int DELIVERED = 7;
  static const int CANCELED = 2;
  static const int EXPIRED = 8;
  static const int ACTIVE_DISPUTE = 10;
  static const int DISPUTE_RESOLVED = 11;
  
  // Legacy states (for backward compatibility)
  static const int ONGOING = 1;
  static const int APPROVAL_PENDING = 3;
  static const int PAYMENT_PENDING = 9;
  
  // ============ CANCELLATION PARTIES ============
  static const String CANCEL_BY_BUYER = 'buyer';
  static const String CANCEL_BY_MERCHANT = 'merchant';
  static const String CANCEL_BY_DSP = 'dsp';
  static const String CANCEL_BY_ADMIN = 'admin';
  static const String CANCEL_BY_SYSTEM = 'system';
  
  // ============ USER ROLES ============
  static const String ROLE_BUYER = 'buyer';
  static const String ROLE_MERCHANT = 'seller';
  static const String ROLE_DSP = 'delivery';
  
  // ============ STATUS LABELS (English) ============
  static String getStatusName(int status) {
    switch (status) {
      case CREATED:
        return 'Created';
      case SPH_ACTIVE:
        return 'Payment Held';
      case CANCELED:
        return 'Canceled';
      case PENDING_APPROVAL:
        return 'Pending Approval';
      case DSP_ASSIGNED:
        return 'Delivery Assigned';
      case OTP_GENERATED:
        return 'Ready for Delivery';
      case IN_TRANSIT:
        return 'In Transit';
      case DELIVERED:
        return 'Delivered';
      case EXPIRED:
        return 'Expired';
      case PAYMENT_PENDING:
        return 'Payment Pending';
      case ACTIVE_DISPUTE:
        return 'Dispute Active';
      case DISPUTE_RESOLVED:
        return 'Dispute Resolved';
      default:
        return 'Unknown';
    }
  }
  
  // ============ STATUS LABELS (Arabic) ============
  static String getStatusNameAr(int status) {
    switch (status) {
      case CREATED:
        return 'تم الإنشاء';
      case SPH_ACTIVE:
        return 'الدفع محجوز';
      case CANCELED:
        return 'ملغي';
      case PENDING_APPROVAL:
        return 'في انتظار الموافقة';
      case DSP_ASSIGNED:
        return 'تم تعيين التوصيل';
      case OTP_GENERATED:
        return 'جاهز للتوصيل';
      case IN_TRANSIT:
        return 'قيد التوصيل';
      case DELIVERED:
        return 'تم التوصيل';
      case EXPIRED:
        return 'منتهي الصلاحية';
      case PAYMENT_PENDING:
        return 'في انتظار الدفع';
      case ACTIVE_DISPUTE:
        return 'نزاع نشط';
      case DISPUTE_RESOLVED:
        return 'تم حل النزاع';
      default:
        return 'غير معروف';
    }
  }
  
  // ============ STATE CHECKS ============
  
  /// Check if DSP has been assigned (status >= DSP_ASSIGNED)
  static bool isDspAssigned(int status) {
    return status == DSP_ASSIGNED || 
           status == OTP_GENERATED || 
           status == IN_TRANSIT ||
           status == DELIVERED;
  }
  
  /// Check if OTP should be visible to buyer
  /// BUG FIX: OTP only visible AFTER DSP is assigned
  static bool isOtpVisibleToBuyer(int status) {
    return isDspAssigned(status);
  }
  
  /// Check if buyer can cancel
  static bool canBuyerCancel(int status) {
    return status == SPH_ACTIVE || 
           status == DSP_ASSIGNED || 
           status == OTP_GENERATED;
  }
  
  /// Check if merchant can cancel
  /// BUG FIX: Merchant CAN cancel after DSP assignment (pays DSP fee)
  static bool canMerchantCancel(int status) {
    return status == CREATED ||
           status == PENDING_APPROVAL ||
           status == SPH_ACTIVE ||
           status == DSP_ASSIGNED ||
           status == OTP_GENERATED;
  }
  
  /// Check if DSP can cancel their delivery
  static bool canDspCancel(int status) {
    return status == DSP_ASSIGNED || status == OTP_GENERATED;
  }
  
  /// Check if transaction is in terminal state
  static bool isTerminal(int status) {
    return status == DELIVERED ||
           status == CANCELED ||
           status == EXPIRED ||
           status == DISPUTE_RESOLVED;
  }
  
  /// Check if transaction can have dispute opened
  static bool canOpenDispute(int status) {
    return status == DELIVERED;
  }
  
  /// Check if merchant can assign DSP
  static bool canAssignDsp(int status) {
    return status == SPH_ACTIVE;
  }
  
  /// Check if merchant can change DSP
  static bool canChangeDsp(int status, int reassignmentCount) {
    return (status == DSP_ASSIGNED || status == OTP_GENERATED) && 
           reassignmentCount < 2;
  }
  
  // ============ BUTTON LABELS ============
  
  /// Get cancel button label based on user role
  /// BUG FIX: "Cancel Order" for buyer, not "Return Item"
  static String getCancelButtonLabel(String userRole, {bool isArabic = false}) {
    if (isArabic) {
      switch (userRole) {
        case ROLE_BUYER:
          return 'إلغاء الطلب';
        case ROLE_MERCHANT:
          return 'إلغاء الرابط';
        case ROLE_DSP:
          return 'إلغاء التوصيل';
        default:
          return 'إلغاء';
      }
    } else {
      switch (userRole) {
        case ROLE_BUYER:
          return 'Cancel Order';
        case ROLE_MERCHANT:
          return 'Cancel PeaceLink';
        case ROLE_DSP:
          return 'Cancel Delivery';
        default:
          return 'Cancel';
      }
    }
  }
  
  /// Get action button label
  static String getActionButtonLabel(String action, {bool isArabic = false}) {
    if (isArabic) {
      switch (action) {
        case 'assign_dsp':
          return 'تعيين التوصيل';
        case 'change_dsp':
          return 'تغيير التوصيل';
        case 'enter_otp':
          return 'إدخال رمز التحقق';
        case 'dispute':
          return 'الإبلاغ عن مشكلة';
        default:
          return action;
      }
    } else {
      switch (action) {
        case 'assign_dsp':
          return 'Assign Delivery';
        case 'change_dsp':
          return 'Change Delivery';
        case 'enter_otp':
          return 'Enter OTP';
        case 'dispute':
          return 'Report Issue';
        default:
          return action;
      }
    }
  }
}
