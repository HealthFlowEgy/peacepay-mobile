// lib/shared/presentation/widgets/buttons/primary_button.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final double? height;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: height ?? 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: AppColors.textOnPrimary,
          disabledBackgroundColor: AppColors.primaryGreen.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Text(label),
                ],
              ),
      ),
    );
  }
}

// lib/shared/presentation/widgets/buttons/danger_button.dart
class DangerButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final bool isOutlined;

  const DangerButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: 48,
      child: isOutlined
          ? OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
              child: _buildChild(),
            )
          : ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.textOnPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
              child: _buildChild(),
            ),
    );
  }

  Widget _buildChild() {
    return isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : Text(label);
  }
}

// lib/shared/presentation/widgets/cards/wallet_card.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters/currency_formatter.dart';

class WalletCard extends StatefulWidget {
  final double balance;
  final double heldBalance;
  final String currency;
  final VoidCallback? onTopUp;
  final VoidCallback? onCashOut;

  const WalletCard({
    super.key,
    required this.balance,
    required this.heldBalance,
    this.currency = 'EGP',
    this.onTopUp,
    this.onCashOut,
  });

  @override
  State<WalletCard> createState() => _WalletCardState();
}

class _WalletCardState extends State<WalletCard> {
  bool _isBalanceVisible = true;

  double get availableBalance => widget.balance - widget.heldBalance;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: AppColors.walletGradient,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الرصيد المتاح',
                style: AppTypography.labelLarge.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              IconButton(
                icon: Icon(
                  _isBalanceVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white.withOpacity(0.8),
                  size: 20,
                ),
                onPressed: () {
                  setState(() => _isBalanceVisible = !_isBalanceVisible);
                },
              ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.sm),
          
          // Balance
          Text(
            _isBalanceVisible
                ? CurrencyFormatter.format(availableBalance, widget.currency)
                : '••••••',
            style: AppTypography.amountLarge.copyWith(
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: AppSpacing.sm),
          
          // Held balance
          if (widget.heldBalance > 0)
            Row(
              children: [
                const Icon(Icons.lock, color: Colors.white70, size: 14),
                const SizedBox(width: 4),
                Text(
                  _isBalanceVisible
                      ? 'محجوز: ${CurrencyFormatter.format(widget.heldBalance, widget.currency)}'
                      : 'محجوز: ••••••',
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  label: 'شحن',
                  icon: Icons.add,
                  onTap: widget.onTopUp,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _ActionButton(
                  label: 'سحب',
                  icon: Icons.arrow_downward,
                  onTap: widget.onCashOut,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
          horizontal: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// lib/shared/presentation/widgets/badges/status_badge.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../features/peacelink/domain/entities/peacelink_status.dart';

class StatusBadge extends StatelessWidget {
  final PeacelinkStatus status;
  final bool showIcon;

  const StatusBadge({
    super.key,
    required this.status,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(status);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(config.icon, size: 14, color: config.textColor),
            const SizedBox(width: 4),
          ],
          Text(
            isRtl ? status.labelAr : status.label,
            style: AppTypography.labelSmall.copyWith(
              color: config.textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _getStatusConfig(PeacelinkStatus status) {
    switch (status) {
      case PeacelinkStatus.created:
        return _StatusConfig(
          backgroundColor: AppColors.statusCreated.withOpacity(0.1),
          textColor: AppColors.statusCreated,
          icon: Icons.add_circle_outline,
        );
      case PeacelinkStatus.pendingApproval:
        return _StatusConfig(
          backgroundColor: AppColors.statusPending.withOpacity(0.1),
          textColor: AppColors.statusPending,
          icon: Icons.schedule,
        );
      case PeacelinkStatus.sphActive:
        return _StatusConfig(
          backgroundColor: AppColors.statusActive.withOpacity(0.1),
          textColor: AppColors.statusActive,
          icon: Icons.lock_outline,
        );
      case PeacelinkStatus.dspAssigned:
        return _StatusConfig(
          backgroundColor: AppColors.statusAssigned.withOpacity(0.1),
          textColor: AppColors.statusAssigned,
          icon: Icons.local_shipping_outlined,
        );
      case PeacelinkStatus.otpGenerated:
        return _StatusConfig(
          backgroundColor: AppColors.statusInTransit.withOpacity(0.1),
          textColor: AppColors.statusInTransit,
          icon: Icons.delivery_dining,
        );
      case PeacelinkStatus.delivered:
        return _StatusConfig(
          backgroundColor: AppColors.statusDelivered.withOpacity(0.1),
          textColor: AppColors.statusDelivered,
          icon: Icons.check_circle_outline,
        );
      case PeacelinkStatus.canceled:
        return _StatusConfig(
          backgroundColor: AppColors.statusCanceled.withOpacity(0.1),
          textColor: AppColors.statusCanceled,
          icon: Icons.cancel_outlined,
        );
      case PeacelinkStatus.disputed:
        return _StatusConfig(
          backgroundColor: AppColors.statusDisputed.withOpacity(0.1),
          textColor: AppColors.statusDisputed,
          icon: Icons.warning_amber_outlined,
        );
      case PeacelinkStatus.resolved:
        return _StatusConfig(
          backgroundColor: AppColors.statusResolved.withOpacity(0.1),
          textColor: AppColors.statusResolved,
          icon: Icons.verified_outlined,
        );
      case PeacelinkStatus.expired:
        return _StatusConfig(
          backgroundColor: AppColors.statusExpired.withOpacity(0.1),
          textColor: AppColors.statusExpired,
          icon: Icons.timer_off_outlined,
        );
    }
  }
}

class _StatusConfig {
  final Color backgroundColor;
  final Color textColor;
  final IconData icon;

  _StatusConfig({
    required this.backgroundColor,
    required this.textColor,
    required this.icon,
  });
}

// lib/shared/presentation/widgets/inputs/otp_input.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';

class OtpInput extends StatelessWidget {
  final int length;
  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final bool autofocus;
  final bool obscureText;

  const OtpInput({
    super.key,
    this.length = 6,
    this.onCompleted,
    this.onChanged,
    this.controller,
    this.autofocus = true,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 48,
      height: 56,
      textStyle: AppTypography.headlineLarge.copyWith(
        color: AppColors.textPrimary,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.divider),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.primaryGreen, width: 2),
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.error),
      ),
    );

    return Directionality(
      // OTP should always be LTR
      textDirection: TextDirection.ltr,
      child: Pinput(
        length: length,
        controller: controller,
        autofocus: autofocus,
        obscureText: obscureText,
        defaultPinTheme: defaultPinTheme,
        focusedPinTheme: focusedPinTheme,
        errorPinTheme: errorPinTheme,
        onCompleted: onCompleted,
        onChanged: onChanged,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        keyboardType: TextInputType.number,
        hapticFeedbackType: HapticFeedbackType.lightImpact,
        cursor: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 24,
              height: 2,
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// lib/shared/presentation/widgets/sheets/cancel_confirmation_sheet.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters/currency_formatter.dart';
import '../buttons/primary_button.dart';
import '../buttons/danger_button.dart';

class CancelConfirmationSheet extends StatelessWidget {
  final String title;
  final String message;
  final double? buyerRefund;
  final double? dspPayout;
  final double? merchantDeduction;
  final bool isDspAssigned;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final bool isLoading;

  const CancelConfirmationSheet({
    super.key,
    required this.title,
    required this.message,
    this.buyerRefund,
    this.dspPayout,
    this.merchantDeduction,
    this.isDspAssigned = false,
    required this.onConfirm,
    required this.onCancel,
    this.isLoading = false,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    double? buyerRefund,
    double? dspPayout,
    double? merchantDeduction,
    bool isDspAssigned = false,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CancelConfirmationSheet(
        title: title,
        message: message,
        buyerRefund: buyerRefund,
        dspPayout: dspPayout,
        merchantDeduction: merchantDeduction,
        isDspAssigned: isDspAssigned,
        onConfirm: () => Navigator.pop(context, true),
        onCancel: () => Navigator.pop(context, false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            
            // Warning icon
            Center(
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.warningLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.warning,
                  size: 32,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            
            // Title
            Center(
              child: Text(
                title,
                style: AppTypography.headlineMedium,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            
            // Message
            Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            
            // Breakdown
            if (buyerRefund != null || dspPayout != null || merchantDeduction != null)
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Column(
                  children: [
                    if (buyerRefund != null)
                      _BreakdownRow(
                        label: 'استرداد للمشتري',
                        amount: buyerRefund!,
                        isPositive: true,
                      ),
                    if (dspPayout != null && isDspAssigned)
                      _BreakdownRow(
                        label: 'رسوم التوصيل للمندوب',
                        amount: dspPayout!,
                        isPositive: false,
                      ),
                    if (merchantDeduction != null)
                      _BreakdownRow(
                        label: 'خصم من المحفظة',
                        amount: merchantDeduction!,
                        isPositive: false,
                      ),
                  ],
                ),
              ),
            const SizedBox(height: AppSpacing.lg),
            
            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isLoading ? null : onCancel,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    ),
                    child: const Text('رجوع'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: DangerButton(
                    label: 'تأكيد الإلغاء',
                    onPressed: isLoading ? null : onConfirm,
                    isLoading: isLoading,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool isPositive;

  const _BreakdownRow({
    required this.label,
    required this.amount,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodyMedium),
          Text(
            '${isPositive ? '+' : '-'} ${CurrencyFormatter.format(amount, 'EGP')}',
            style: AppTypography.bodyMedium.copyWith(
              color: isPositive ? AppColors.success : AppColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
