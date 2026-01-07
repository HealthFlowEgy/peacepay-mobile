
// ignore_for_file: constant_identifier_names

import '../../language/language_controller.dart';
import '../../backend/constants/peacelink_constants.dart';
import '../../utils/basic_widget_imports.dart';

class StatusWidget extends StatelessWidget {
  const StatusWidget({super.key, required this.statusValue});

  final int statusValue;
  /*

    const ONGOING           = 1;
    const PAYMENT_PENDING   = 2;
    const APPROVAL_PENDING  = 3;
    const RELEASED          = 4;
    const ACTIVE_DISPUTE    = 5;
    const DISPUTED          = 6;
    const CANCELED          = 7;
    const REFUNDED          = 8;
   */

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: Dimensions.heightSize * 1.4,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeHorizontal * .15,
          vertical: Dimensions.paddingSizeVertical * .15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radius * .3),
        color: StatusConstants.getStatusColor(statusValue).withOpacity(.1)
      ),
      child: Text(
          Get.find<LanguageSettingController>().getTranslation(StatusConstants.getStatusString(statusValue)),
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: Dimensions.headingTextSize6,
          color: StatusConstants.getStatusColor(statusValue)
        ),
      ),
    );
  }
}


/// StatusConstants - Updated based on Re-Engineering Specification v2.0
/// Added new PeaceLink states while maintaining backward compatibility
class StatusConstants {
  static String getStatusString(int statusCode) {
    // Use new PeaceLinkConstants for status names
    return PeaceLinkConstants.getStatusName(statusCode);
  }

  static Color getStatusColor(int statusCode) {
    switch (statusCode) {
      // Success states
      case PeaceLinkConstants.DELIVERED:
      case RELEASED:
      case REFUNDED:
        return Colors.green;
      
      // Active/In-progress states
      case PeaceLinkConstants.SPH_ACTIVE:
      case ONGOING:
        return Colors.blue;
      
      // Pending states
      case PeaceLinkConstants.PENDING_APPROVAL:
      case APPROVAL_PENDING:
      case PAYMENT_PENDING:
      case PAYMENT_WAITING:
        return Colors.orange;
      
      // DSP states (new)
      case PeaceLinkConstants.DSP_ASSIGNED:
      case PeaceLinkConstants.OTP_GENERATED:
      case PeaceLinkConstants.IN_TRANSIT:
        return Colors.blueAccent;
      
      // Canceled/Error states
      case PeaceLinkConstants.CANCELED:
      case CANCELED:
      case PeaceLinkConstants.EXPIRED:
        return Colors.red;
      
      // Dispute states
      case PeaceLinkConstants.ACTIVE_DISPUTE:
      case ACTIVE_DISPUTE:
        return Colors.deepOrange;
      case DISPUTED:
      case PeaceLinkConstants.DISPUTE_RESOLVED:
        return Colors.purple;
      
      default:
        return Colors.black;
    }
  }

  // Legacy constants (for backward compatibility)
  static const ONGOING = 1;
  static const PAYMENT_PENDING = 2;
  static const APPROVAL_PENDING = 3;
  static const RELEASED = 4;
  static const ACTIVE_DISPUTE = 5;
  static const DISPUTED = 6;
  static const CANCELED = 7;
  static const REFUNDED = 8;
  static const PAYMENT_WAITING = 9;
  
  // New PeaceLink states
  static const DSP_ASSIGNED = PeaceLinkConstants.DSP_ASSIGNED;
  static const OTP_GENERATED = PeaceLinkConstants.OTP_GENERATED;
  static const IN_TRANSIT = PeaceLinkConstants.IN_TRANSIT;
  static const DELIVERED = PeaceLinkConstants.DELIVERED;
  static const EXPIRED = PeaceLinkConstants.EXPIRED;
}
