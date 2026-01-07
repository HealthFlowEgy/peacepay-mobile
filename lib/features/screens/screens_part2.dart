// ============================================================================
// PEACEPAY FLUTTER SCREENS - PART 2: WALLET & MONEY SCREENS
// Wallet Tab, Add Money, Send Money, Cashout, Transaction History
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

// Import Part 1 for shared components
// import 'screens_part1.dart';

// ============================================================================
// 1. WALLET TAB (Full Implementation)
// ============================================================================

class WalletTabScreen extends ConsumerWidget {
  const WalletTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletAsync = ref.watch(walletDetailsProvider);

    return Scaffold(
      backgroundColor: PeacePayColors.background,
      appBar: AppBar(
        title: Text(
          'المحفظة',
          style: TextStyle(
            color: PeacePayColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.history_rounded, color: PeacePayColors.textPrimary),
            onPressed: () => context.push('/transactions'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(walletDetailsProvider),
        child: walletAsync.when(
          data: (wallet) => _WalletContent(wallet: wallet),
          loading: () => const _WalletSkeleton(),
          error: (e, _) => _WalletError(error: e.toString()),
        ),
      ),
    );
  }
}

class _WalletContent extends StatelessWidget {
  final WalletDetails wallet;

  const _WalletContent({required this.wallet});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      locale: 'ar_EG',
      symbol: 'ج.م ',
      decimalDigits: 2,
    );

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Main balance card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  PeacePayColors.primary,
                  PeacePayColors.primary.withBlue(200),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: PeacePayColors.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'الرصيد المتاح',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        wallet.kycLevel.label,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  formatter.format(wallet.availableBalance),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _BalanceItem(
                        label: 'محجوز',
                        amount: formatter.format(wallet.holdBalance),
                        icon: Icons.lock_clock_rounded,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    Expanded(
                      child: _BalanceItem(
                        label: 'قيد السحب',
                        amount: formatter.format(wallet.pendingCashout),
                        icon: Icons.pending_rounded,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: _WalletActionButton(
                  icon: Icons.add_rounded,
                  label: 'إضافة رصيد',
                  color: PeacePayColors.success,
                  onTap: () => context.push('/add-money'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _WalletActionButton(
                  icon: Icons.send_rounded,
                  label: 'تحويل',
                  color: PeacePayColors.primary,
                  onTap: () => context.push('/send-money'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _WalletActionButton(
                  icon: Icons.money_off_rounded,
                  label: 'سحب',
                  color: PeacePayColors.warning,
                  onTap: () => context.push('/cashout'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Wallet limits
          Text(
            'حدود المحفظة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: PeacePayColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          _LimitCard(
            title: 'الحد اليومي للتحويل',
            used: wallet.dailyTransferUsed,
            limit: wallet.dailyTransferLimit,
            formatter: formatter,
          ),

          const SizedBox(height: 12),

          _LimitCard(
            title: 'الحد الشهري للسحب',
            used: wallet.monthlyCashoutUsed,
            limit: wallet.monthlyCashoutLimit,
            formatter: formatter,
          ),

          const SizedBox(height: 24),

          // Upgrade KYC banner
          if (wallet.kycLevel != KycLevel.gold)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: PeacePayColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: PeacePayColors.info.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: PeacePayColors.info.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.verified_rounded,
                      color: PeacePayColors.info,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ارفع مستوى حسابك',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: PeacePayColors.textPrimary,
                          ),
                        ),
                        Text(
                          'للحصول على حدود أعلى ومميزات إضافية',
                          style: TextStyle(
                            fontSize: 12,
                            color: PeacePayColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/kyc'),
                    child: Text('ترقية'),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 24),

          // Recent transactions preview
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'آخر المعاملات',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: PeacePayColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () => context.push('/transactions'),
                child: Text('عرض الكل'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ...wallet.recentTransactions
              .take(3)
              .map((tx) => _TransactionPreviewTile(transaction: tx)),
        ],
      ),
    );
  }
}

class _BalanceItem extends StatelessWidget {
  final String label;
  final String amount;
  final IconData icon;

  const _BalanceItem({
    required this.label,
    required this.amount,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.7), size: 18),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 11,
              ),
            ),
            Text(
              amount,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _WalletActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _WalletActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: PeacePayColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LimitCard extends StatelessWidget {
  final String title;
  final double used;
  final double limit;
  final NumberFormat formatter;

  const _LimitCard({
    required this.title,
    required this.used,
    required this.limit,
    required this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    final progress = limit > 0 ? (used / limit).clamp(0.0, 1.0) : 0.0;
    final remaining = limit - used;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: PeacePayColors.textPrimary,
                ),
              ),
              Text(
                'متبقي: ${formatter.format(remaining)}',
                style: TextStyle(
                  fontSize: 12,
                  color: PeacePayColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: PeacePayColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress > 0.8 ? PeacePayColors.error : PeacePayColors.primary,
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatter.format(used),
                style: TextStyle(
                  fontSize: 12,
                  color: PeacePayColors.textSecondary,
                ),
              ),
              Text(
                formatter.format(limit),
                style: TextStyle(
                  fontSize: 12,
                  color: PeacePayColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TransactionPreviewTile extends StatelessWidget {
  final TransactionItem transaction;

  const _TransactionPreviewTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      locale: 'ar_EG',
      symbol: 'ج.م ',
      decimalDigits: 2,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: transaction.type.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              transaction.type.icon,
              color: transaction.type.color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: PeacePayColors.textPrimary,
                  ),
                ),
                Text(
                  transaction.subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: PeacePayColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${transaction.isCredit ? '+' : '-'}${formatter.format(transaction.amount.abs())}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: transaction.isCredit
                      ? PeacePayColors.success
                      : PeacePayColors.error,
                ),
              ),
              Text(
                DateFormat('dd/MM').format(transaction.date),
                style: TextStyle(
                  fontSize: 11,
                  color: PeacePayColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 2. ADD MONEY SCREEN
// ============================================================================

class AddMoneyScreen extends ConsumerStatefulWidget {
  const AddMoneyScreen({super.key});

  @override
  ConsumerState<AddMoneyScreen> createState() => _AddMoneyScreenState();
}

class _AddMoneyScreenState extends ConsumerState<AddMoneyScreen> {
  final _amountController = TextEditingController();
  PaymentMethod? _selectedMethod;
  bool _isLoading = false;

  final List<PaymentMethod> _paymentMethods = [
    PaymentMethod(
      id: 'fawry',
      name: 'فوري',
      icon: 'assets/icons/fawry.png',
      description: 'ادفع نقداً في أي فرع فوري',
      fee: 5.0,
      minAmount: 10,
      maxAmount: 10000,
    ),
    PaymentMethod(
      id: 'vodafone_cash',
      name: 'فودافون كاش',
      icon: 'assets/icons/vodafone.png',
      description: 'من محفظة فودافون كاش',
      fee: 0,
      feePercent: 1.5,
      minAmount: 10,
      maxAmount: 5000,
    ),
    PaymentMethod(
      id: 'card',
      name: 'بطاقة بنكية',
      icon: 'assets/icons/card.png',
      description: 'Visa / Mastercard',
      fee: 0,
      feePercent: 2.5,
      minAmount: 50,
      maxAmount: 50000,
    ),
    PaymentMethod(
      id: 'instapay',
      name: 'انستاباي',
      icon: 'assets/icons/instapay.png',
      description: 'تحويل فوري من حسابك البنكي',
      fee: 0,
      minAmount: 100,
      maxAmount: 100000,
    ),
  ];

  final List<int> _quickAmounts = [100, 200, 500, 1000, 2000, 5000];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double get _amount => double.tryParse(_amountController.text) ?? 0;

  double get _fee {
    if (_selectedMethod == null) return 0;
    return _selectedMethod!.fee +
        (_amount * (_selectedMethod!.feePercent / 100));
  }

  double get _total => _amount + _fee;

  bool get _canProceed {
    if (_selectedMethod == null) return false;
    if (_amount < _selectedMethod!.minAmount) return false;
    if (_amount > _selectedMethod!.maxAmount) return false;
    return true;
  }

  Future<void> _handleAddMoney() async {
    if (!_canProceed) return;

    setState(() => _isLoading = true);

    try {
      final result = await ref.read(walletControllerProvider.notifier).addMoney(
            amount: _amount,
            method: _selectedMethod!.id,
          );

      if (mounted) {
        if (_selectedMethod!.id == 'fawry') {
          context.push('/add-money/fawry', extra: result);
        } else if (_selectedMethod!.id == 'card') {
          context.push('/add-money/card', extra: result);
        } else {
          context.push('/add-money/success', extra: result);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: PeacePayColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      locale: 'ar_EG',
      symbol: 'ج.م ',
      decimalDigits: 2,
    );

    return Scaffold(
      backgroundColor: PeacePayColors.background,
      appBar: AppBar(
        title: Text(
          'إضافة رصيد',
          style: TextStyle(
            color: PeacePayColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: PeacePayColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Amount input
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    'أدخل المبلغ',
                    style: TextStyle(
                      fontSize: 16,
                      color: PeacePayColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: PeacePayColors.primary,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '0',
                      hintStyle: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: PeacePayColors.border,
                      ),
                      suffixText: 'ج.م',
                      suffixStyle: TextStyle(
                        fontSize: 24,
                        color: PeacePayColors.textSecondary,
                      ),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Quick amounts
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickAmounts.map((amount) {
                return ChoiceChip(
                  label: Text('$amount'),
                  selected: _amountController.text == amount.toString(),
                  onSelected: (selected) {
                    if (selected) {
                      _amountController.text = amount.toString();
                      setState(() {});
                    }
                  },
                  selectedColor: PeacePayColors.primary.withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: _amountController.text == amount.toString()
                        ? PeacePayColors.primary
                        : PeacePayColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Payment methods
            Text(
              'طريقة الدفع',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: PeacePayColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            ..._paymentMethods.map((method) {
              final isSelected = _selectedMethod?.id == method.id;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? PeacePayColors.primary
                        : PeacePayColors.border,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: ListTile(
                  onTap: () => setState(() => _selectedMethod = method),
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: PeacePayColors.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.payment_rounded,
                      color: PeacePayColors.primary,
                    ),
                  ),
                  title: Text(
                    method.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    method.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: PeacePayColors.textSecondary,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(
                          Icons.check_circle_rounded,
                          color: PeacePayColors.primary,
                        )
                      : null,
                ),
              );
            }),

            const SizedBox(height: 24),

            // Summary
            if (_selectedMethod != null && _amount > 0) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _SummaryRow(
                      label: 'المبلغ',
                      value: formatter.format(_amount),
                    ),
                    if (_fee > 0) ...[
                      const SizedBox(height: 8),
                      _SummaryRow(
                        label: 'رسوم الخدمة',
                        value: formatter.format(_fee),
                      ),
                    ],
                    const Divider(height: 24),
                    _SummaryRow(
                      label: 'الإجمالي',
                      value: formatter.format(_total),
                      isBold: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Continue button
            PeacePayButton(
              onPressed: _canProceed && !_isLoading ? _handleAddMoney : null,
              label: 'متابعة',
              isLoading: _isLoading,
            ),

            // Validation message
            if (_selectedMethod != null && _amount > 0 && !_canProceed)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  _amount < _selectedMethod!.minAmount
                      ? 'الحد الأدنى: ${formatter.format(_selectedMethod!.minAmount)}'
                      : 'الحد الأقصى: ${formatter.format(_selectedMethod!.maxAmount)}',
                  style: TextStyle(
                    color: PeacePayColors.error,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 3. SEND MONEY SCREEN
// ============================================================================

class SendMoneyScreen extends ConsumerStatefulWidget {
  const SendMoneyScreen({super.key});

  @override
  ConsumerState<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends ConsumerState<SendMoneyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _recipientController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  
  bool _isLoading = false;
  bool _isSearching = false;
  UserSearchResult? _recipient;

  @override
  void dispose() {
    _recipientController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _searchRecipient() async {
    if (_recipientController.text.length < 11) return;

    setState(() => _isSearching = true);

    try {
      final result = await ref.read(userSearchProvider.notifier).search(
            _recipientController.text,
          );
      setState(() => _recipient = result);
    } catch (e) {
      setState(() => _recipient = null);
    } finally {
      setState(() => _isSearching = false);
    }
  }

  Future<void> _handleSend() async {
    if (!_formKey.currentState!.validate()) return;
    if (_recipient == null) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(walletControllerProvider.notifier).sendMoney(
            recipientId: _recipient!.id,
            amount: double.parse(_amountController.text),
            note: _noteController.text,
          );

      if (mounted) {
        context.go('/send-money/success', extra: {
          'recipient': _recipient,
          'amount': _amountController.text,
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: PeacePayColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final walletAsync = ref.watch(walletDetailsProvider);
    final formatter = NumberFormat.currency(
      locale: 'ar_EG',
      symbol: 'ج.م ',
      decimalDigits: 2,
    );

    return Scaffold(
      backgroundColor: PeacePayColors.background,
      appBar: AppBar(
        title: Text(
          'تحويل أموال',
          style: TextStyle(
            color: PeacePayColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: PeacePayColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Available balance
              walletAsync.when(
                data: (wallet) => Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: PeacePayColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet_rounded,
                        color: PeacePayColors.primary,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'الرصيد المتاح',
                            style: TextStyle(
                              fontSize: 12,
                              color: PeacePayColors.textSecondary,
                            ),
                          ),
                          Text(
                            formatter.format(wallet.availableBalance),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: PeacePayColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 24),

              // Recipient
              Text(
                'إلى',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: PeacePayColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _recipientController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'رقم الهاتف',
                  prefixIcon: Icon(Icons.phone_rounded),
                  suffixIcon: _isSearching
                      ? Padding(
                          padding: const EdgeInsets.all(12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : _recipient != null
                          ? Icon(Icons.check_circle, color: PeacePayColors.success)
                          : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                ],
                onChanged: (value) {
                  if (value.length == 11) _searchRecipient();
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'رقم الهاتف مطلوب';
                  }
                  if (value.length != 11) {
                    return 'رقم هاتف غير صحيح';
                  }
                  return null;
                },
              ),

              // Recipient info
              if (_recipient != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: PeacePayColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: PeacePayColors.success.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: PeacePayColors.success,
                        child: Text(
                          _recipient!.name[0].toUpperCase(),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _recipient!.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: PeacePayColors.textPrimary,
                            ),
                          ),
                          Text(
                            _recipient!.phone,
                            style: TextStyle(
                              fontSize: 12,
                              color: PeacePayColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Amount
              Text(
                'المبلغ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: PeacePayColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '0',
                  prefixIcon: Icon(Icons.attach_money_rounded),
                  suffixText: 'ج.م',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'المبلغ مطلوب';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount < 10) {
                    return 'الحد الأدنى 10 جنيه';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Note
              Text(
                'ملاحظة (اختياري)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: PeacePayColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _noteController,
                maxLines: 2,
                maxLength: 100,
                decoration: InputDecoration(
                  hintText: 'أضف ملاحظة...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),

              const SizedBox(height: 32),

              // Send button
              PeacePayButton(
                onPressed: _recipient != null && !_isLoading ? _handleSend : null,
                label: 'تحويل',
                icon: Icons.send_rounded,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 4. CASHOUT SCREEN
// ============================================================================

class CashoutScreen extends ConsumerStatefulWidget {
  const CashoutScreen({super.key});

  @override
  ConsumerState<CashoutScreen> createState() => _CashoutScreenState();
}

class _CashoutScreenState extends ConsumerState<CashoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  CashoutMethod? _selectedMethod;
  bool _isLoading = false;

  // Bank account details
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _accountHolderController = TextEditingController();

  // Mobile wallet details
  final _walletNumberController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _accountHolderController.dispose();
    _walletNumberController.dispose();
    super.dispose();
  }

  double get _amount => double.tryParse(_amountController.text) ?? 0;

  double get _fee {
    // Cash-out fee: 1.5%
    return _amount * 0.015;
  }

  double get _netAmount => _amount - _fee;

  Future<void> _handleCashout() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final details = _selectedMethod == CashoutMethod.bank
          ? {
              'bank_name': _bankNameController.text,
              'account_number': _accountNumberController.text,
              'account_holder': _accountHolderController.text,
            }
          : {
              'wallet_number': _walletNumberController.text,
              'wallet_type': 'vodafone_cash',
            };

      await ref.read(cashoutControllerProvider.notifier).requestCashout(
            amount: _amount,
            method: _selectedMethod!.name,
            details: details,
          );

      if (mounted) {
        context.go('/cashout/success', extra: {
          'amount': _amount,
          'fee': _fee,
          'netAmount': _netAmount,
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: PeacePayColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final walletAsync = ref.watch(walletDetailsProvider);
    final formatter = NumberFormat.currency(
      locale: 'ar_EG',
      symbol: 'ج.م ',
      decimalDigits: 2,
    );

    return Scaffold(
      backgroundColor: PeacePayColors.background,
      appBar: AppBar(
        title: Text(
          'سحب الأموال',
          style: TextStyle(
            color: PeacePayColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: PeacePayColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Available balance
              walletAsync.when(
                data: (wallet) => Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: PeacePayColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet_rounded,
                        color: PeacePayColors.warning,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'الرصيد المتاح للسحب',
                            style: TextStyle(
                              fontSize: 12,
                              color: PeacePayColors.textSecondary,
                            ),
                          ),
                          Text(
                            formatter.format(wallet.availableBalance),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: PeacePayColors.warning,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 24),

              // Amount
              Text(
                'مبلغ السحب',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: PeacePayColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '0',
                  prefixIcon: Icon(Icons.attach_money_rounded),
                  suffixText: 'ج.م',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (_) => setState(() {}),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'المبلغ مطلوب';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount < 50) {
                    return 'الحد الأدنى للسحب 50 جنيه';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Cashout method
              Text(
                'طريقة السحب',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: PeacePayColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _CashoutMethodCard(
                      method: CashoutMethod.bank,
                      icon: Icons.account_balance_rounded,
                      label: 'حساب بنكي',
                      isSelected: _selectedMethod == CashoutMethod.bank,
                      onTap: () => setState(() => _selectedMethod = CashoutMethod.bank),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _CashoutMethodCard(
                      method: CashoutMethod.wallet,
                      icon: Icons.phone_android_rounded,
                      label: 'محفظة إلكترونية',
                      isSelected: _selectedMethod == CashoutMethod.wallet,
                      onTap: () => setState(() => _selectedMethod = CashoutMethod.wallet),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Method details
              if (_selectedMethod == CashoutMethod.bank) ...[
                TextFormField(
                  controller: _bankNameController,
                  decoration: InputDecoration(
                    labelText: 'اسم البنك',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (v) => v?.isEmpty ?? true ? 'مطلوب' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _accountNumberController,
                  decoration: InputDecoration(
                    labelText: 'رقم الحساب / IBAN',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (v) => v?.isEmpty ?? true ? 'مطلوب' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _accountHolderController,
                  decoration: InputDecoration(
                    labelText: 'اسم صاحب الحساب',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (v) => v?.isEmpty ?? true ? 'مطلوب' : null,
                ),
              ],

              if (_selectedMethod == CashoutMethod.wallet) ...[
                TextFormField(
                  controller: _walletNumberController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'رقم المحفظة',
                    hintText: '01xxxxxxxxx',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                  ],
                  validator: (v) {
                    if (v?.isEmpty ?? true) return 'مطلوب';
                    if (v!.length != 11) return 'رقم غير صحيح';
                    return null;
                  },
                ),
              ],

              const SizedBox(height: 24),

              // Fee notice
              if (_amount > 0)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _SummaryRow(
                        label: 'مبلغ السحب',
                        value: formatter.format(_amount),
                      ),
                      const SizedBox(height: 8),
                      _SummaryRow(
                        label: 'رسوم السحب (1.5%)',
                        value: formatter.format(_fee),
                        valueColor: PeacePayColors.error,
                      ),
                      const Divider(height: 24),
                      _SummaryRow(
                        label: 'المبلغ الصافي',
                        value: formatter.format(_netAmount),
                        isBold: true,
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // Warning
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: PeacePayColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_rounded,
                      color: PeacePayColors.warning,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'رسوم السحب تُخصم وقت الطلب. التحويل خلال 1-3 أيام عمل.',
                        style: TextStyle(
                          fontSize: 12,
                          color: PeacePayColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Submit button
              PeacePayButton(
                onPressed:
                    _selectedMethod != null && !_isLoading ? _handleCashout : null,
                label: 'تأكيد السحب',
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CashoutMethodCard extends StatelessWidget {
  final CashoutMethod method;
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CashoutMethodCard({
    required this.method,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? PeacePayColors.primary : PeacePayColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected
                  ? PeacePayColors.primary
                  : PeacePayColors.textSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? PeacePayColors.primary
                    : PeacePayColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 5. TRANSACTION HISTORY SCREEN
// ============================================================================

class TransactionHistoryScreen extends ConsumerStatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  ConsumerState<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState
    extends ConsumerState<TransactionHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TransactionFilter _filter = TransactionFilter.all;
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PeacePayColors.background,
      appBar: AppBar(
        title: Text(
          'سجل المعاملات',
          style: TextStyle(
            color: PeacePayColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: PeacePayColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list_rounded, color: PeacePayColors.textPrimary),
            onPressed: _showFilterSheet,
          ),
          IconButton(
            icon: Icon(Icons.download_rounded, color: PeacePayColors.textPrimary),
            onPressed: _exportTransactions,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: PeacePayColors.primary,
          unselectedLabelColor: PeacePayColors.textSecondary,
          indicatorColor: PeacePayColors.primary,
          tabs: const [
            Tab(text: 'الكل'),
            Tab(text: 'وارد'),
            Tab(text: 'صادر'),
            Tab(text: 'PeaceLink'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _TransactionList(filter: TransactionFilter.all, dateRange: _dateRange),
          _TransactionList(filter: TransactionFilter.credit, dateRange: _dateRange),
          _TransactionList(filter: TransactionFilter.debit, dateRange: _dateRange),
          _TransactionList(filter: TransactionFilter.peacelink, dateRange: _dateRange),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _FilterBottomSheet(
        currentDateRange: _dateRange,
        onApply: (range) {
          setState(() => _dateRange = range);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _exportTransactions() {
    // Export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('جاري تصدير المعاملات...')),
    );
  }
}

class _TransactionList extends ConsumerWidget {
  final TransactionFilter filter;
  final DateTimeRange? dateRange;

  const _TransactionList({
    required this.filter,
    this.dateRange,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(
      transactionsProvider(filter: filter, dateRange: dateRange),
    );

    return transactionsAsync.when(
      data: (transactions) {
        if (transactions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long_rounded,
                  size: 64,
                  color: PeacePayColors.border,
                ),
                const SizedBox(height: 16),
                Text(
                  'لا توجد معاملات',
                  style: TextStyle(
                    color: PeacePayColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        // Group by date
        final grouped = <String, List<TransactionItem>>{};
        for (final tx in transactions) {
          final dateKey = DateFormat('yyyy-MM-dd').format(tx.date);
          grouped.putIfAbsent(dateKey, () => []).add(tx);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: grouped.length,
          itemBuilder: (context, index) {
            final dateKey = grouped.keys.elementAt(index);
            final dayTransactions = grouped[dateKey]!;
            final date = DateTime.parse(dateKey);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    _formatDateHeader(date),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: PeacePayColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
                ...dayTransactions.map(
                  (tx) => _DetailedTransactionTile(
                    transaction: tx,
                    onTap: () => context.push('/transaction/${tx.id}'),
                  ),
                ),
              ],
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('خطأ: $e')),
    );
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) return 'اليوم';
    if (dateOnly == yesterday) return 'أمس';
    return DateFormat('EEEE، d MMMM', 'ar').format(date);
  }
}

class _DetailedTransactionTile extends StatelessWidget {
  final TransactionItem transaction;
  final VoidCallback onTap;

  const _DetailedTransactionTile({
    required this.transaction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      locale: 'ar_EG',
      symbol: 'ج.م ',
      decimalDigits: 2,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: transaction.type.color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            transaction.type.icon,
            color: transaction.type.color,
          ),
        ),
        title: Text(
          transaction.title,
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              transaction.subtitle,
              style: TextStyle(fontSize: 12),
            ),
            Text(
              DateFormat('h:mm a', 'ar').format(transaction.date),
              style: TextStyle(
                fontSize: 11,
                color: PeacePayColors.textSecondary,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${transaction.isCredit ? '+' : '-'}${formatter.format(transaction.amount.abs())}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: transaction.isCredit
                    ? PeacePayColors.success
                    : PeacePayColors.error,
              ),
            ),
            StatusBadge(status: transaction.status),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}

// ============================================================================
// SHARED WIDGETS & MODELS
// ============================================================================

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: PeacePayColors.textSecondary,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? PeacePayColors.textPrimary,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        _getStatusLabel(status),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return PeacePayColors.success;
      case 'pending':
        return PeacePayColors.warning;
      case 'failed':
        return PeacePayColors.error;
      default:
        return PeacePayColors.textSecondary;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'completed':
        return 'مكتمل';
      case 'pending':
        return 'قيد التنفيذ';
      case 'failed':
        return 'فشل';
      default:
        return status;
    }
  }
}

class _FilterBottomSheet extends StatefulWidget {
  final DateTimeRange? currentDateRange;
  final Function(DateTimeRange?) onApply;

  const _FilterBottomSheet({
    this.currentDateRange,
    required this.onApply,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  DateTimeRange? _selectedRange;

  @override
  void initState() {
    super.initState();
    _selectedRange = widget.currentDateRange;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'تصفية حسب التاريخ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: Icon(Icons.calendar_today_rounded),
            title: Text(_selectedRange != null
                ? '${DateFormat('dd/MM/yyyy').format(_selectedRange!.start)} - ${DateFormat('dd/MM/yyyy').format(_selectedRange!.end)}'
                : 'اختر الفترة'),
            trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16),
            onTap: () async {
              final range = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                initialDateRange: _selectedRange,
                locale: const Locale('ar'),
              );
              if (range != null) {
                setState(() => _selectedRange = range);
              }
            },
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => widget.onApply(null),
                  child: Text('إعادة تعيين'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => widget.onApply(_selectedRange),
                  child: Text('تطبيق'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ============================================================================
// PLACEHOLDER CLASSES & PROVIDERS
// ============================================================================

// Wallet skeleton
class _WalletSkeleton extends StatelessWidget {
  const _WalletSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _WalletError extends StatelessWidget {
  final String error;
  const _WalletError({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Error: $error'));
  }
}

// Models
class WalletDetails {
  final double availableBalance;
  final double holdBalance;
  final double pendingCashout;
  final KycLevel kycLevel;
  final double dailyTransferUsed;
  final double dailyTransferLimit;
  final double monthlyCashoutUsed;
  final double monthlyCashoutLimit;
  final List<TransactionItem> recentTransactions;

  WalletDetails({
    this.availableBalance = 0,
    this.holdBalance = 0,
    this.pendingCashout = 0,
    this.kycLevel = KycLevel.basic,
    this.dailyTransferUsed = 0,
    this.dailyTransferLimit = 5000,
    this.monthlyCashoutUsed = 0,
    this.monthlyCashoutLimit = 30000,
    this.recentTransactions = const [],
  });
}

class TransactionItem {
  final String id;
  final String title;
  final String subtitle;
  final double amount;
  final bool isCredit;
  final DateTime date;
  final TransactionType type;
  final String status;

  TransactionItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isCredit,
    required this.date,
    required this.type,
    this.status = 'completed',
  });
}

enum TransactionType {
  transfer,
  receive,
  addMoney,
  cashout,
  peacelink,
  fee;

  IconData get icon {
    switch (this) {
      case TransactionType.transfer:
        return Icons.arrow_upward_rounded;
      case TransactionType.receive:
        return Icons.arrow_downward_rounded;
      case TransactionType.addMoney:
        return Icons.add_rounded;
      case TransactionType.cashout:
        return Icons.money_off_rounded;
      case TransactionType.peacelink:
        return Icons.shield_rounded;
      case TransactionType.fee:
        return Icons.receipt_rounded;
    }
  }

  Color get color {
    switch (this) {
      case TransactionType.transfer:
        return PeacePayColors.error;
      case TransactionType.receive:
        return PeacePayColors.success;
      case TransactionType.addMoney:
        return PeacePayColors.success;
      case TransactionType.cashout:
        return PeacePayColors.warning;
      case TransactionType.peacelink:
        return PeacePayColors.info;
      case TransactionType.fee:
        return PeacePayColors.textSecondary;
    }
  }
}

enum KycLevel {
  basic,
  silver,
  gold;

  String get label {
    switch (this) {
      case KycLevel.basic:
        return 'أساسي';
      case KycLevel.silver:
        return 'فضي';
      case KycLevel.gold:
        return 'ذهبي';
    }
  }
}

enum CashoutMethod { bank, wallet }

enum TransactionFilter { all, credit, debit, peacelink }

class PaymentMethod {
  final String id;
  final String name;
  final String icon;
  final String description;
  final double fee;
  final double feePercent;
  final double minAmount;
  final double maxAmount;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    this.fee = 0,
    this.feePercent = 0,
    required this.minAmount,
    required this.maxAmount,
  });
}

class UserSearchResult {
  final String id;
  final String name;
  final String phone;

  UserSearchResult({
    required this.id,
    required this.name,
    required this.phone,
  });
}

// Placeholder providers
final walletDetailsProvider = FutureProvider<WalletDetails>((ref) async => WalletDetails());
final walletControllerProvider = StateNotifierProvider<WalletController, AsyncValue<void>>((ref) => WalletController(ref));
final cashoutControllerProvider = StateNotifierProvider<CashoutController, AsyncValue<void>>((ref) => CashoutController(ref));
final userSearchProvider = StateNotifierProvider<UserSearchController, AsyncValue<UserSearchResult?>>((ref) => UserSearchController(ref));
final transactionsProvider = FutureProvider.family<List<TransactionItem>, ({TransactionFilter filter, DateTimeRange? dateRange})>((ref, params) async => []);

class WalletController extends StateNotifier<AsyncValue<void>> {
  WalletController(this.ref) : super(const AsyncValue.data(null));
  final Ref ref;
  Future<Map<String, dynamic>> addMoney({required double amount, required String method}) async => {};
  Future<void> sendMoney({required String recipientId, required double amount, String? note}) async {}
}

class CashoutController extends StateNotifier<AsyncValue<void>> {
  CashoutController(this.ref) : super(const AsyncValue.data(null));
  final Ref ref;
  Future<void> requestCashout({required double amount, required String method, required Map<String, dynamic> details}) async {}
}

class UserSearchController extends StateNotifier<AsyncValue<UserSearchResult?>> {
  UserSearchController(this.ref) : super(const AsyncValue.data(null));
  final Ref ref;
  Future<UserSearchResult> search(String phone) async => UserSearchResult(id: '', name: '', phone: phone);
}
