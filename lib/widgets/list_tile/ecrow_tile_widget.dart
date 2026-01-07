import 'package:intl/intl.dart';
import 'package:peacepay/controller/dashboard/profiles/update_profile_controller.dart';

import '../../backend/download_file.dart';
import '../../backend/models/escrow/escrow_index_model.dart';
import '../../backend/constants/peacelink_constants.dart';
import '../../utils/basic_widget_imports.dart';
import '../text_labels/title_heading5_widget.dart';
import 'status_widget.dart';
import 'text_descrption_form_widget.dart';
import 'text_status_form_widget.dart';
import 'text_value_form_widget.dart';

import '../buttons/primary_button.dart';
import '../../controller/dashboard/btm_navs_controller/my_escrow_controller.dart';
import '../../widgets/dialog_helper.dart';

/// EscrowTileWidget - Updated based on Re-Engineering Specification v2.0
/// Bug fixes:
/// - OTP only visible after DSP assigned
/// - Correct button labels ("Cancel Order" not "Return Item")
/// - Cancel button visible for merchants after DSP assignment
/// - DSP cancel delivery button
class EscrowTileWidget extends StatefulWidget with DownloadFile {
  const EscrowTileWidget(
      {super.key,
      required this.onSelected,
      required this.data,
      this.havePayment = false,
      required this.onTap,
      required this.expansion});

  final Function(String)? onSelected;
  final EscrowDatum data;
  final bool havePayment;
  final VoidCallback onTap;
  final bool expansion;

  @override
  State<EscrowTileWidget> createState() => _EscrowTileWidgetState();
}

class _EscrowTileWidgetState extends State<EscrowTileWidget> {
  final deliveryController = TextEditingController();

  @override
  void dispose() {
    deliveryController.dispose();
    super.dispose();
  }

  /// Get current user role
  String get _userRole {
    return Get.find<UpdateProfileController>().selectedUserType.value;
  }

  /// Check if OTP should be visible
  /// BUG FIX: OTP only visible after DSP is assigned
  bool get _isOtpVisible {
    return PeaceLinkConstants.isOtpVisibleToBuyer(widget.data.status) &&
           widget.data.pin_code != null &&
           widget.data.pin_code.toString().isNotEmpty;
  }

  /// Check if buyer can cancel
  bool get _canBuyerCancel {
    return _userRole == 'buyer' && 
           PeaceLinkConstants.canBuyerCancel(widget.data.status);
  }

  /// Check if merchant can cancel
  /// BUG FIX: Merchant CAN cancel after DSP assignment
  bool get _canMerchantCancel {
    return _userRole == 'seller' && 
           PeaceLinkConstants.canMerchantCancel(widget.data.status);
  }

  /// Check if DSP can cancel delivery
  bool get _canDspCancel {
    return _userRole == 'delivery' && 
           PeaceLinkConstants.canDspCancel(widget.data.status);
  }

  /// Check if merchant can assign DSP
  bool get _canAssignDsp {
    return _userRole == 'seller' && 
           PeaceLinkConstants.canAssignDsp(widget.data.status);
  }

  /// Check if DSP is assigned
  bool get _isDspAssigned {
    return PeaceLinkConstants.isDspAssigned(widget.data.status);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: widget.onTap,
          child: Container(
            margin: EdgeInsets.only(
              left: Dimensions.paddingSizeHorizontal * .8,
              right: Dimensions.paddingSizeHorizontal * .8,
            ),
            padding: EdgeInsets.only(
              left: Dimensions.paddingSizeHorizontal * .4,
              top: Dimensions.paddingSizeVertical * .3,
              bottom: Dimensions.paddingSizeVertical * .3,
            ),
            decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(Dimensions.radius)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeHorizontal * .3,
                    vertical: Dimensions.paddingSizeVertical * .3,
                  ),
                  decoration: BoxDecoration(
                      color: CustomColor.whiteColor,
                      borderRadius: BorderRadius.circular(Dimensions.radius)),
                  child: Column(
                    children: [
                      TitleHeading1Widget(
                        text: widget.data.createdAt.day.toString(),
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w800,
                        fontSize: Dimensions.headingTextSize3 * 1.7,
                      ),
                      TitleHeading5Widget(
                        text: DateFormat.MMMM().format(widget.data.createdAt),
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                        fontSize: Dimensions.headingTextSize6 * .85,
                      )
                    ],
                  ),
                ),
                horizontalSpace(Dimensions.marginSizeHorizontal * .3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TitleHeading2Widget(
                        text: widget.data.title,
                        fontSize: Dimensions.headingTextSize3 * .85,
                      ),
                      Row(
                        children: [
                          TitleHeading4Widget(
                            text: widget.data.amount,
                            fontSize: Dimensions.headingTextSize4 * .85,
                            color: Theme.of(context).primaryColor,
                            opacity: 1,
                          ),
                          horizontalSpace(4),
                          StatusWidget(
                            statusValue: widget.data.status,
                          )
                        ],
                      )
                    ],
                  ),
                ),
                widget.havePayment
                    ? PopupMenuButton<String>(
                        iconSize: Dimensions.iconSizeDefault * 1.5,
                        onSelected: widget.onSelected,
                        itemBuilder: (BuildContext context) {
                          return [
                            const PopupMenuItem(
                              value: 'message',
                              child: TitleHeading5Widget(text: Strings.message),
                            ),
                            const PopupMenuItem(
                              value: 'pay',
                              child: TitleHeading5Widget(
                                text: Strings.buyerPay,
                              ),
                            ),
                          ];
                        },
                      )
                    : Get.find<UpdateProfileController>()
                                .selectedUserType
                                .value !=
                            'delivery'
                        ? PopupMenuButton<String>(
                            iconSize: Dimensions.iconSizeDefault * 1.5,
                            onSelected: widget.onSelected,
                            itemBuilder: (BuildContext context) {
                              return [
                                const PopupMenuItem(
                                  value: 'message',
                                  child: TitleHeading5Widget(
                                      text: Strings.message),
                                )
                              ];
                            },
                          )
                        : Container(),
              ],
            ),
          ),
        ),
        Visibility(
            visible: widget.expansion,
            child: Container(
              margin: EdgeInsets.only(
                left: Dimensions.paddingSizeHorizontal * .8,
                right: Dimensions.paddingSizeHorizontal * .8,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeHorizontal * .5,
                vertical: Dimensions.paddingSizeVertical * .5,
              ),
              decoration: BoxDecoration(
                  color: CustomColor.whiteColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(Dimensions.radius * 1.5),
                    bottomRight: Radius.circular(Dimensions.radius * 1.5),
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: CustomColor.blackColor.withOpacity(.2),
                        offset: const Offset(0, 8),
                        spreadRadius: 0,
                        blurRadius: 10)
                  ]),
              child: Column(
                children: [
                  // ============ MERCHANT: DSP Assignment Section ============
                  Visibility(
                    visible: _userRole == 'seller' && widget.data.status == 1,
                    child: Column(
                      children: [
                        _divider(),
                        widget.data.delivery_number != null &&
                                widget.data.delivery_number.toString() != "0" &&
                                widget.data.delivery_number!.isNotEmpty
                            ? Column(
                                children: [
                                  TextValueFormWidget(
                                    text: "Delivery Number",
                                    value: widget.data.delivery_number!,
                                  ),
                                  verticalSpace(
                                      Dimensions.marginSizeVertical * .5),
                                  // BUG FIX: "Change Delivery" button for merchant
                                  PrimaryButton(
                                    title: "Change Delivery",
                                    buttonColor: CustomColor.orangeColor,
                                    onPressed: () {
                                      Get.find<MyEscrowController>()
                                          .cancelDeliveryNumber(
                                              id: widget.data.id.toString());
                                    },
                                  )
                                ],
                              )
                            : Column(
                                children: [
                                  PrimaryTextInputWidget(
                                    controller: deliveryController,
                                    labelText: "Delivery Number",
                                  ),
                                  verticalSpace(
                                      Dimensions.marginSizeVertical * .5),
                                  PrimaryButton(
                                    title: "Assign Delivery",
                                    onPressed: () {
                                      Get.find<MyEscrowController>()
                                          .updateDeliveryNumber(
                                              id: widget.data.id.toString(),
                                              number: deliveryController.text);
                                    },
                                  )
                                ],
                              )
                      ],
                    ),
                  ),
                  
                  // ============ BUYER: Cancel Order Button ============
                  // BUG FIX: Changed label from "Cancel Payment" to "Cancel Order"
                  Visibility(
                    visible: _canBuyerCancel,
                    child: Column(
                      children: [
                        _divider(),
                        PrimaryButton(
                          // BUG FIX: Correct label - "Cancel Order" not "Return Item"
                          title: PeaceLinkConstants.getCancelButtonLabel(
                            PeaceLinkConstants.ROLE_BUYER,
                          ),
                          buttonColor: CustomColor.redColor,
                          onPressed: () {
                            String warningMessage = _isDspAssigned
                                ? "Canceling after delivery assignment will forfeit the delivery fee."
                                : "Are you sure you want to cancel this order?";
                            
                            DialogHelper.showAlertDialog(
                              context,
                              title: "Cancel Order",
                              content: warningMessage,
                              btnText: Strings.confirm,
                              onTap: () {
                                Get.back();
                                Get.find<MyEscrowController>().returnPayment(
                                    id: widget.data.id.toString());
                              },
                            );
                          },
                        ),
                        verticalSpace(Dimensions.marginSizeVertical * .5),
                      ],
                    ),
                  ),
                  
                  // ============ MERCHANT: Cancel PeaceLink Button ============
                  // BUG FIX: Show cancel button for merchant even after DSP assignment
                  Visibility(
                    visible: _canMerchantCancel,
                    child: Column(
                      children: [
                        _divider(),
                        PrimaryButton(
                          title: PeaceLinkConstants.getCancelButtonLabel(
                            PeaceLinkConstants.ROLE_MERCHANT,
                          ),
                          buttonColor: CustomColor.redColor,
                          onPressed: () {
                            String warningMessage = _isDspAssigned
                                ? "Canceling after delivery assignment means you will pay the DSP fee."
                                : "Are you sure you want to cancel this PeaceLink?";
                            
                            DialogHelper.showAlertDialog(
                              context,
                              title: "Cancel PeaceLink",
                              content: warningMessage,
                              btnText: Strings.confirm,
                              onTap: () {
                                Get.back();
                                Get.find<MyEscrowController>().cancelPayment(
                                    id: widget.data.id.toString());
                              },
                            );
                          },
                        ),
                        verticalSpace(Dimensions.marginSizeVertical * .5),
                      ],
                    ),
                  ),
                  
                  // ============ DSP: Cancel Delivery Button ============
                  // BUG FIX: Add cancel delivery button for DSP
                  Visibility(
                    visible: _canDspCancel,
                    child: Column(
                      children: [
                        _divider(),
                        PrimaryButton(
                          title: PeaceLinkConstants.getCancelButtonLabel(
                            PeaceLinkConstants.ROLE_DSP,
                          ),
                          buttonColor: CustomColor.orangeColor,
                          onPressed: () {
                            DialogHelper.showAlertDialog(
                              context,
                              title: "Cancel Delivery",
                              content: "Are you sure you want to cancel this delivery? The order will be reassigned to another delivery partner.",
                              btnText: Strings.confirm,
                              onTap: () {
                                Get.back();
                                Get.find<MyEscrowController>()
                                    .cancelDeliveryNumber(
                                        id: widget.data.id.toString());
                              },
                            );
                          },
                        ),
                        verticalSpace(Dimensions.marginSizeVertical * .5),
                      ],
                    ),
                  ),
                  
                  SizedBox(
                    height: 15.h,
                  ),
                  TextValueFormWidget(
                    text: Strings.escrowId,
                    value: widget.data.escrowId,
                  ),
                  
                  // ============ OTP Section ============
                  // BUG FIX: OTP only visible AFTER DSP is assigned
                  Visibility(
                    visible: _isOtpVisible,
                    child: Column(
                      children: [
                        _divider(),
                        TextValueFormWidget(
                          text: "OTP",
                          currency: widget.data.pin_code,
                        ),
                      ],
                    ),
                  ),
                  
                  // Show "Waiting for DSP" message when OTP not yet visible
                  Visibility(
                    visible: !_isOtpVisible && 
                             widget.data.status == PeaceLinkConstants.SPH_ACTIVE &&
                             _userRole == 'buyer',
                    child: Column(
                      children: [
                        _divider(),
                        TextValueFormWidget(
                          text: "OTP",
                          value: "Will be shown after delivery is assigned",
                        ),
                      ],
                    ),
                  ),
                  
                  _divider(),
                  TextValueFormWidget(
                    text: Strings.title,
                    value: widget.data.title,
                  ),
                  _divider(),
                  TextValueFormWidget(
                    text: Strings.myRole,
                    value: widget.data.role == "seller"
                        ? Strings.seller
                        : Strings.buyer,
                  ),
                  _divider(),
                  TextValueFormWidget(
                    text: Strings.amount,
                    currency: widget.data.amount,
                  ),
                  _divider(),
                  TextValueFormWidget(
                    text: Strings.category,
                    value: widget.data.category,
                  ),
                  _divider(),
                  TextValueFormWidget(
                    text: Strings.charge,
                    currency: widget.data.totalCharge,
                  ),
                  _divider(),
                  TextValueFormWidget(
                    text: Strings.chargePayer,
                    value: widget.data.chargePayer,
                  ),
                  _divider(),
                  TextStatusFormWidget(
                    text: Strings.status,
                    status: widget.data.status,
                  ),
                  widget.data.attachments!.isEmpty
                      ? const SizedBox.shrink()
                      : Column(
                          children: [
                            _divider(),
                            Row(
                              children: [
                                Expanded(
                                  child: TextValueFormWidget(
                                    text: Strings.attachments,
                                    currency:
                                        "${widget.data.attachments!.first.fileName.split('.').first.substring(0, 8)}...~.${widget.data.attachments!.first.fileName.split('.').last}",
                                  ),
                                ),
                                horizontalSpace(
                                    Dimensions.paddingSizeHorizontal * .2),
                                InkWell(
                                    onTap: () async {
                                      await widget.downloadFile(
                                          url:
                                              "${widget.data.attachments!.first.filePath}/${widget.data.attachments!.first.fileName}",
                                          name: widget.data.attachments!.first
                                              .fileName);
                                      debugPrint("Download");
                                    },
                                    child: Icon(
                                      Icons.download,
                                      size: Dimensions.iconSizeDefault * 1,
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withOpacity(.5),
                                    ))
                              ],
                            ),
                          ],
                        ),
                  Visibility(
                      visible: widget.data.remarks.isNotEmpty,
                      child: Column(
                        children: [
                          _divider(),
                          TextDescriptionFormWidget(
                            text: Strings.remarks,
                            value: widget.data.remarks,
                          ),
                        ],
                      )),
                ],
              ),
            ))
      ],
    );
  }

  _divider() {
    return Divider(
      color: CustomColor.primaryLightTextColor.withOpacity(.1),
    );
  }
}
