// ============================================================================
// PEACEPAY FLUTTER SCREENS - PART 3: PEACELINK SCREENS
// PeaceLink Tab, Create, Details, OTP Delivery, Dispute
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

// ============================================================================
// 1. PEACELINK TAB - LIST VIEW
// ============================================================================

class PeaceLinkTabScreen extends ConsumerStatefulWidget {
  const PeaceLinkTabScreen({super.key});

  @override
  ConsumerState<PeaceLinkTabScreen> createState() => _PeaceLinkTabScreenState();
}

class _PeaceLinkTabScreenState extends ConsumerState<PeaceLinkTabScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  PeaceLinkRole _viewRole = PeaceLinkRole.buyer;

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
          'PeaceLink',
          style: TextStyle(
            color: PeacePayColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Role toggle
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: SegmentedButton<PeaceLinkRole>(
              segments: const [
                ButtonSegment(
                  value: PeaceLinkRole.buyer,
                  label: Text('مشتري'),
                  icon: Icon(Icons.shopping_bag_rounded, size: 16),
                ),
                ButtonSegment(
                  value: PeaceLinkRole.merchant,
                  label: Text('بائع'),
                  icon: Icon(Icons.store_rounded, size: 16),
                ),
              ],
              selected: {_viewRole},
              onSelectionChanged: (roles) {
                setState(() => _viewRole = roles.first);
              },
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: PeacePayColors.primary,
          unselectedLabelColor: PeacePayColors.textSecondary,
          indicatorColor: PeacePayColors.primary,
          tabs: const [
            Tab(text: 'نشط'),
            Tab(text: 'قيد التوصيل'),
            Tab(text: 'مكتمل'),
            Tab(text: 'ملغي'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _PeaceLinkList(
            role: _viewRole,
            statuses: [PeaceLinkStatus.pending, PeaceLinkStatus.funded, PeaceLinkStatus.dspAssigned],
          ),
          _PeaceLinkList(
            role: _viewRole,
            statuses: [PeaceLinkStatus.inTransit],
          ),
          _PeaceLinkList(
            role: _viewRole,
            statuses: [PeaceLinkStatus.delivered, PeaceLinkStatus.released],
          ),
          _PeaceLinkList(
            role: _viewRole,
            statuses: [PeaceLinkStatus.cancelled, PeaceLinkStatus.refunded],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/peacelink/create'),
        icon: Icon(Icons.add_rounded),
        label: Text('إنشاء PeaceLink'),
        backgroundColor: PeacePayColors.primary,
      ),
    );
  }
}

class _PeaceLinkList extends ConsumerWidget {
  final PeaceLinkRole role;
  final List<PeaceLinkStatus> statuses;

  const _PeaceLinkList({
    required this.role,
    required this.statuses,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final peacelinksAsync = ref.watch(
      peacelinksProvider(role: role, statuses: statuses),
    );

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(peacelinksProvider(role: role, statuses: statuses));
      },
      child: peacelinksAsync.when(
        data: (peacelinks) {
          if (peacelinks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shield_rounded,
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

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: peacelinks.length,
            itemBuilder: (context, index) {
              return PeaceLinkCard(
                peacelink: peacelinks[index],
                role: role,
                onTap: () => context.push('/peacelink/${peacelinks[index].id}'),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطأ: $e')),
      ),
    );
  }
}

class PeaceLinkCard extends StatelessWidget {
  final PeaceLinkModel peacelink;
  final PeaceLinkRole role;
  final VoidCallback onTap;

  const PeaceLinkCard({
    super.key,
    required this.peacelink,
    required this.role,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      locale: 'ar_EG',
      symbol: 'ج.م ',
      decimalDigits: 2,
    );

    final otherParty = role == PeaceLinkRole.buyer
        ? peacelink.merchantName
        : peacelink.buyerName;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: peacelink.status.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          peacelink.status.icon,
                          color: peacelink.status.color,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '#${peacelink.reference}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: PeacePayColors.textPrimary,
                            ),
                          ),
                          Text(
                            otherParty ?? 'غير محدد',
                            style: TextStyle(
                              fontSize: 12,
                              color: PeacePayColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  _PeaceLinkStatusBadge(status: peacelink.status),
                ],
              ),

              const Divider(height: 24),

              // Product info
              Text(
                peacelink.productDescription,
                style: TextStyle(
                  color: PeacePayColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // Amount and date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'المبلغ',
                        style: TextStyle(
                          fontSize: 12,
                          color: PeacePayColors.textSecondary,
                        ),
                      ),
                      Text(
                        formatter.format(peacelink.itemAmount),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: PeacePayColors.primary,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        DateFormat('dd/MM/yyyy').format(peacelink.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: PeacePayColors.textSecondary,
                        ),
                      ),
                      if (peacelink.expiresAt != null)
                        Text(
                          'ينتهي: ${DateFormat('dd/MM').format(peacelink.expiresAt!)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: PeacePayColors.warning,
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              // Progress indicator for in-transit
              if (peacelink.status == PeaceLinkStatus.inTransit) ...[
                const SizedBox(height: 12),
                _DeliveryProgress(peacelink: peacelink),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PeaceLinkStatusBadge extends StatelessWidget {
  final PeaceLinkStatus status;

  const _PeaceLinkStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: status.color.withOpacity(0.3)),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: status.color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _DeliveryProgress extends StatelessWidget {
  final PeaceLinkModel peacelink;

  const _DeliveryProgress({required this.peacelink});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: PeacePayColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_shipping_rounded,
            color: PeacePayColors.info,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'قيد التوصيل',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: PeacePayColors.info,
                  ),
                ),
                if (peacelink.dspName != null)
                  Text(
                    'مندوب: ${peacelink.dspName}',
                    style: TextStyle(
                      fontSize: 11,
                      color: PeacePayColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          if (peacelink.dspPhone != null)
            IconButton(
              icon: Icon(Icons.phone_rounded, color: PeacePayColors.info),
              onPressed: () {
                // Call DSP
              },
              iconSize: 20,
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
            ),
        ],
      ),
    );
  }
}

// ============================================================================
// 2. CREATE PEACELINK SCREEN
// ============================================================================

class CreatePeaceLinkScreen extends ConsumerStatefulWidget {
  const CreatePeaceLinkScreen({super.key});

  @override
  ConsumerState<CreatePeaceLinkScreen> createState() =>
      _CreatePeaceLinkScreenState();
}

class _CreatePeaceLinkScreenState extends ConsumerState<CreatePeaceLinkScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  bool _isLoading = false;

  // Step 1: Product details
  final _productDescController = TextEditingController();
  final _itemAmountController = TextEditingController();
  final _deliveryFeeController = TextEditingController();
  bool _buyerPaysDelivery = true;

  // Step 2: Parties
  final _merchantPhoneController = TextEditingController();
  UserSearchResult? _merchant;
  bool _isSearchingMerchant = false;

  // Step 3: Delivery
  final _deliveryAddressController = TextEditingController();
  final _deliveryNotesController = TextEditingController();
  bool _useInternalDsp = true;

  @override
  void dispose() {
    _productDescController.dispose();
    _itemAmountController.dispose();
    _deliveryFeeController.dispose();
    _merchantPhoneController.dispose();
    _deliveryAddressController.dispose();
    _deliveryNotesController.dispose();
    super.dispose();
  }

  double get _itemAmount => double.tryParse(_itemAmountController.text) ?? 0;
  double get _deliveryFee => double.tryParse(_deliveryFeeController.text) ?? 0;

  double get _buyerTotal {
    double total = _itemAmount;
    if (_buyerPaysDelivery) total += _deliveryFee;
    // Add platform fee (0.5% + 2 EGP)
    total += (_itemAmount * 0.005) + 2;
    return total;
  }

  Future<void> _searchMerchant() async {
    if (_merchantPhoneController.text.length < 11) return;

    setState(() => _isSearchingMerchant = true);

    try {
      final result = await ref.read(userSearchProvider.notifier).search(
            _merchantPhoneController.text,
          );
      setState(() => _merchant = result);
    } catch (e) {
      setState(() => _merchant = null);
    } finally {
      setState(() => _isSearchingMerchant = false);
    }
  }

  Future<void> _handleCreate() async {
    setState(() => _isLoading = true);

    try {
      final peacelink = await ref.read(peacelinkControllerProvider.notifier).create(
            productDescription: _productDescController.text.trim(),
            itemAmount: _itemAmount,
            deliveryFee: _deliveryFee,
            buyerPaysDelivery: _buyerPaysDelivery,
            merchantId: _merchant!.id,
            deliveryAddress: _deliveryAddressController.text.trim(),
            deliveryNotes: _deliveryNotesController.text.trim(),
            useInternalDsp: _useInternalDsp,
          );

      if (mounted) {
        context.go('/peacelink/${peacelink.id}/success');
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
    return Scaffold(
      backgroundColor: PeacePayColors.background,
      appBar: AppBar(
        title: Text(
          'إنشاء PeaceLink',
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
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < 2) {
              if (_validateCurrentStep()) {
                setState(() => _currentStep++);
              }
            } else {
              if (_formKey.currentState!.validate()) {
                _handleCreate();
              }
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            } else {
              context.pop();
            }
          },
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : details.onStepContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PeacePayColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading && _currentStep == 2
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              _currentStep == 2 ? 'إنشاء PeaceLink' : 'التالي',
                            ),
                    ),
                  ),
                  if (_currentStep > 0) ...[
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: details.onStepCancel,
                      child: Text('السابق'),
                    ),
                  ],
                ],
              ),
            );
          },
          steps: [
            // Step 1: Product Details
            Step(
              title: Text('تفاصيل المنتج'),
              subtitle: Text('وصف المنتج والسعر'),
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _productDescController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'وصف المنتج',
                      hintText: 'مثال: iPhone 15 Pro Max 256GB أزرق',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (v) {
                      if (v?.isEmpty ?? true) return 'مطلوب';
                      if (v!.length < 10) return 'الوصف قصير جداً';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _itemAmountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'سعر المنتج',
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
                          validator: (v) {
                            if (v?.isEmpty ?? true) return 'مطلوب';
                            final amount = double.tryParse(v!);
                            if (amount == null || amount < 50) {
                              return 'الحد الأدنى 50 جنيه';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _deliveryFeeController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'رسوم التوصيل',
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
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    value: _buyerPaysDelivery,
                    onChanged: (v) => setState(() => _buyerPaysDelivery = v),
                    title: Text('المشتري يدفع رسوم التوصيل'),
                    contentPadding: EdgeInsets.zero,
                    activeColor: PeacePayColors.primary,
                  ),
                ],
              ),
            ),

            // Step 2: Merchant
            Step(
              title: Text('البائع'),
              subtitle: Text('رقم هاتف البائع'),
              isActive: _currentStep >= 1,
              state: _currentStep > 1 ? StepState.complete : StepState.indexed,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _merchantPhoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'رقم هاتف البائع',
                      hintText: '01xxxxxxxxx',
                      prefixIcon: Icon(Icons.phone_rounded),
                      suffixIcon: _isSearchingMerchant
                          ? Padding(
                              padding: const EdgeInsets.all(12),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : _merchant != null
                              ? Icon(Icons.check_circle,
                                  color: PeacePayColors.success)
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
                      if (value.length == 11) _searchMerchant();
                    },
                    validator: (v) {
                      if (v?.isEmpty ?? true) return 'مطلوب';
                      if (v!.length != 11) return 'رقم غير صحيح';
                      return null;
                    },
                  ),
                  if (_merchant != null) ...[
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
                              _merchant!.name[0].toUpperCase(),
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _merchant!.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'البائع',
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
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: PeacePayColors.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_rounded,
                            color: PeacePayColors.info, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'سيتم إرسال إشعار للبائع لتأكيد المعاملة',
                            style: TextStyle(
                              fontSize: 12,
                              color: PeacePayColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Step 3: Delivery
            Step(
              title: Text('التوصيل'),
              subtitle: Text('عنوان وملاحظات التوصيل'),
              isActive: _currentStep >= 2,
              state: _currentStep > 2 ? StepState.complete : StepState.indexed,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _deliveryAddressController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'عنوان التوصيل',
                      hintText: 'الحي، الشارع، رقم العمارة...',
                      prefixIcon: Icon(Icons.location_on_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (v) {
                      if (v?.isEmpty ?? true) return 'مطلوب';
                      if (v!.length < 10) return 'العنوان قصير جداً';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _deliveryNotesController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'ملاحظات التوصيل (اختياري)',
                      hintText: 'مثال: الطابق الثالث، شقة 5',
                      prefixIcon: Icon(Icons.note_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    value: _useInternalDsp,
                    onChanged: (v) => setState(() => _useInternalDsp = v),
                    title: Text('استخدام مندوب PeacePay'),
                    subtitle: Text(
                      _useInternalDsp
                          ? 'سيتم تعيين مندوب توصيل آمن'
                          : 'البائع سيقوم بالتوصيل بنفسه',
                      style: TextStyle(fontSize: 12),
                    ),
                    contentPadding: EdgeInsets.zero,
                    activeColor: PeacePayColors.primary,
                  ),
                  const SizedBox(height: 24),

                  // Summary
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: PeacePayColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ملخص المعاملة',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _SummaryRow(
                          label: 'سعر المنتج',
                          value: '${_itemAmount.toStringAsFixed(0)} ج.م',
                        ),
                        const SizedBox(height: 8),
                        _SummaryRow(
                          label: 'رسوم التوصيل',
                          value: '${_deliveryFee.toStringAsFixed(0)} ج.م',
                        ),
                        const SizedBox(height: 8),
                        _SummaryRow(
                          label: 'رسوم الخدمة',
                          value:
                              '${((_itemAmount * 0.005) + 2).toStringAsFixed(2)} ج.م',
                          valueColor: PeacePayColors.textSecondary,
                        ),
                        const Divider(height: 16),
                        _SummaryRow(
                          label: 'إجمالي الدفع',
                          value: '${_buyerTotal.toStringAsFixed(2)} ج.م',
                          isBold: true,
                          valueColor: PeacePayColors.primary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _productDescController.text.length >= 10 && _itemAmount >= 50;
      case 1:
        return _merchant != null;
      default:
        return true;
    }
  }
}

// ============================================================================
// 3. PEACELINK DETAILS SCREEN
// ============================================================================

class PeaceLinkDetailsScreen extends ConsumerWidget {
  final String peacelinkId;

  const PeaceLinkDetailsScreen({
    super.key,
    required this.peacelinkId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final peacelinkAsync = ref.watch(peacelinkDetailsProvider(peacelinkId));

    return Scaffold(
      backgroundColor: PeacePayColors.background,
      appBar: AppBar(
        title: Text(
          'تفاصيل المعاملة',
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
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded, color: PeacePayColors.textPrimary),
            onSelected: (value) {
              switch (value) {
                case 'dispute':
                  context.push('/peacelink/$peacelinkId/dispute');
                  break;
                case 'cancel':
                  _showCancelDialog(context, ref);
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'dispute',
                child: Row(
                  children: [
                    Icon(Icons.report_problem_rounded, color: PeacePayColors.warning),
                    const SizedBox(width: 8),
                    Text('فتح نزاع'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'cancel',
                child: Row(
                  children: [
                    Icon(Icons.cancel_rounded, color: PeacePayColors.error),
                    const SizedBox(width: 8),
                    Text('إلغاء المعاملة'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: peacelinkAsync.when(
        data: (peacelink) => _PeaceLinkDetailsContent(peacelink: peacelink),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطأ: $e')),
      ),
    );
  }

  void _showCancelDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('إلغاء المعاملة'),
        content: Text(
          'هل أنت متأكد من إلغاء هذه المعاملة؟ قد يتم تطبيق رسوم حسب حالة المعاملة.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('تراجع'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref
                  .read(peacelinkControllerProvider.notifier)
                  .cancel(peacelinkId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: PeacePayColors.error,
            ),
            child: Text('إلغاء المعاملة'),
          ),
        ],
      ),
    );
  }
}

class _PeaceLinkDetailsContent extends StatelessWidget {
  final PeaceLinkModel peacelink;

  const _PeaceLinkDetailsContent({required this.peacelink});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      locale: 'ar_EG',
      symbol: 'ج.م ',
      decimalDigits: 2,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Status card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  peacelink.status.color,
                  peacelink.status.color.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(
                  peacelink.status.icon,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 12),
                Text(
                  peacelink.status.label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '#${peacelink.reference}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Timeline
          _PeaceLinkTimeline(peacelink: peacelink),

          const SizedBox(height: 24),

          // Product details
          _DetailsSection(
            title: 'تفاصيل المنتج',
            icon: Icons.shopping_bag_rounded,
            children: [
              _DetailRow(label: 'الوصف', value: peacelink.productDescription),
              _DetailRow(
                label: 'سعر المنتج',
                value: formatter.format(peacelink.itemAmount),
              ),
              _DetailRow(
                label: 'رسوم التوصيل',
                value: formatter.format(peacelink.deliveryFee),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Parties
          _DetailsSection(
            title: 'الأطراف',
            icon: Icons.people_rounded,
            children: [
              _DetailRow(
                label: 'المشتري',
                value: peacelink.buyerName ?? 'غير محدد',
              ),
              _DetailRow(
                label: 'البائع',
                value: peacelink.merchantName ?? 'غير محدد',
              ),
              if (peacelink.dspName != null)
                _DetailRow(
                  label: 'مندوب التوصيل',
                  value: peacelink.dspName!,
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Delivery
          _DetailsSection(
            title: 'التوصيل',
            icon: Icons.local_shipping_rounded,
            children: [
              _DetailRow(
                label: 'العنوان',
                value: peacelink.deliveryAddress ?? 'غير محدد',
              ),
              if (peacelink.deliveryNotes != null)
                _DetailRow(
                  label: 'ملاحظات',
                  value: peacelink.deliveryNotes!,
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Financials
          _DetailsSection(
            title: 'التفاصيل المالية',
            icon: Icons.receipt_rounded,
            children: [
              _DetailRow(
                label: 'سعر المنتج',
                value: formatter.format(peacelink.itemAmount),
              ),
              _DetailRow(
                label: 'رسوم التوصيل',
                value: formatter.format(peacelink.deliveryFee),
              ),
              _DetailRow(
                label: 'رسوم الخدمة',
                value: formatter.format(peacelink.platformFee),
              ),
              Divider(height: 16),
              _DetailRow(
                label: 'إجمالي المدفوع',
                value: formatter.format(peacelink.totalAmount),
                isBold: true,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Action buttons based on status
          _PeaceLinkActions(peacelink: peacelink),
        ],
      ),
    );
  }
}

class _PeaceLinkTimeline extends StatelessWidget {
  final PeaceLinkModel peacelink;

  const _PeaceLinkTimeline({required this.peacelink});

  @override
  Widget build(BuildContext context) {
    final steps = [
      _TimelineStep(
        title: 'تم الإنشاء',
        subtitle: DateFormat('dd/MM/yyyy HH:mm').format(peacelink.createdAt),
        isCompleted: true,
        isActive: peacelink.status == PeaceLinkStatus.pending,
      ),
      _TimelineStep(
        title: 'تم التمويل',
        subtitle: peacelink.fundedAt != null
            ? DateFormat('dd/MM/yyyy HH:mm').format(peacelink.fundedAt!)
            : 'في انتظار الدفع',
        isCompleted: peacelink.fundedAt != null,
        isActive: peacelink.status == PeaceLinkStatus.funded,
      ),
      _TimelineStep(
        title: 'قيد التوصيل',
        subtitle: peacelink.dspAssignedAt != null
            ? DateFormat('dd/MM/yyyy HH:mm').format(peacelink.dspAssignedAt!)
            : 'في انتظار المندوب',
        isCompleted: peacelink.dspAssignedAt != null,
        isActive: peacelink.status == PeaceLinkStatus.inTransit,
      ),
      _TimelineStep(
        title: 'تم التسليم',
        subtitle: peacelink.deliveredAt != null
            ? DateFormat('dd/MM/yyyy HH:mm').format(peacelink.deliveredAt!)
            : 'في انتظار التسليم',
        isCompleted: peacelink.deliveredAt != null,
        isActive: peacelink.status == PeaceLinkStatus.delivered,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'مراحل المعاملة',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          ...steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            return _TimelineStepWidget(
              step: step,
              isLast: index == steps.length - 1,
            );
          }),
        ],
      ),
    );
  }
}

class _TimelineStep {
  final String title;
  final String subtitle;
  final bool isCompleted;
  final bool isActive;

  _TimelineStep({
    required this.title,
    required this.subtitle,
    required this.isCompleted,
    required this.isActive,
  });
}

class _TimelineStepWidget extends StatelessWidget {
  final _TimelineStep step;
  final bool isLast;

  const _TimelineStepWidget({
    required this.step,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final color = step.isCompleted
        ? PeacePayColors.success
        : step.isActive
            ? PeacePayColors.primary
            : PeacePayColors.border;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2),
              ),
              child: step.isCompleted
                  ? Icon(Icons.check, size: 14, color: color)
                  : step.isActive
                      ? Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        )
                      : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: step.isCompleted ? color : PeacePayColors.border,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: TextStyle(
                    fontWeight:
                        step.isActive ? FontWeight.bold : FontWeight.normal,
                    color: step.isCompleted || step.isActive
                        ? PeacePayColors.textPrimary
                        : PeacePayColors.textSecondary,
                  ),
                ),
                Text(
                  step.subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: PeacePayColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _DetailsSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
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
            children: [
              Icon(icon, size: 20, color: PeacePayColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _DetailRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: PeacePayColors.textSecondary,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                color: PeacePayColors.textPrimary,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _PeaceLinkActions extends ConsumerWidget {
  final PeaceLinkModel peacelink;

  const _PeaceLinkActions({required this.peacelink});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Different actions based on status and role
    switch (peacelink.status) {
      case PeaceLinkStatus.pending:
        return ElevatedButton.icon(
          onPressed: () => context.push('/peacelink/${peacelink.id}/fund'),
          icon: Icon(Icons.payment_rounded),
          label: Text('ادفع الآن'),
          style: ElevatedButton.styleFrom(
            backgroundColor: PeacePayColors.success,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

      case PeaceLinkStatus.inTransit:
        return ElevatedButton.icon(
          onPressed: () =>
              context.push('/peacelink/${peacelink.id}/confirm-delivery'),
          icon: Icon(Icons.qr_code_scanner_rounded),
          label: Text('تأكيد الاستلام'),
          style: ElevatedButton.styleFrom(
            backgroundColor: PeacePayColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }
}

// ============================================================================
// 4. OTP DELIVERY CONFIRMATION SCREEN
// ============================================================================

class OtpDeliveryScreen extends ConsumerStatefulWidget {
  final String peacelinkId;

  const OtpDeliveryScreen({
    super.key,
    required this.peacelinkId,
  });

  @override
  ConsumerState<OtpDeliveryScreen> createState() => _OtpDeliveryScreenState();
}

class _OtpDeliveryScreenState extends ConsumerState<OtpDeliveryScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _otp => _controllers.map((c) => c.text).join();

  Future<void> _confirmDelivery() async {
    if (_otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('أدخل الرمز المكون من 6 أرقام'),
          backgroundColor: PeacePayColors.warning,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(peacelinkControllerProvider.notifier).confirmDelivery(
            peacelinkId: widget.peacelinkId,
            otp: _otp,
          );

      if (mounted) {
        context.go('/peacelink/${widget.peacelinkId}/success');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: PeacePayColors.error,
          ),
        );
        // Clear OTP
        for (var controller in _controllers) {
          controller.clear();
        }
        _focusNodes[0].requestFocus();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PeacePayColors.background,
      appBar: AppBar(
        title: Text(
          'تأكيد الاستلام',
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icon
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: PeacePayColors.success.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.verified_rounded,
                    size: 50,
                    color: PeacePayColors.success,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              Text(
                'أدخل رمز التسليم',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: PeacePayColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                'اطلب من المشتري إعطاءك رمز التأكيد المكون من 6 أرقام',
                style: TextStyle(
                  fontSize: 14,
                  color: PeacePayColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // OTP input
              Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 48,
                      height: 56,
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: PeacePayColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: PeacePayColors.success,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 5) {
                            _focusNodes[index + 1].requestFocus();
                          }
                          if (value.isEmpty && index > 0) {
                            _focusNodes[index - 1].requestFocus();
                          }
                          if (_otp.length == 6) {
                            _confirmDelivery();
                          }
                        },
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 32),

              // Confirm button
              PeacePayButton(
                onPressed: _isLoading ? null : _confirmDelivery,
                label: 'تأكيد التسليم',
                isLoading: _isLoading,
              ),

              const Spacer(),

              // Warning
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: PeacePayColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: PeacePayColors.warning.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_rounded,
                      color: PeacePayColors.warning,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'لا تشارك هذا الرمز إلا بعد التأكد من استلام المنتج والتحقق منه',
                        style: TextStyle(
                          fontSize: 12,
                          color: PeacePayColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// MODELS & PROVIDERS
// ============================================================================

enum PeaceLinkRole { buyer, merchant, dsp }

enum PeaceLinkStatus {
  pending,
  funded,
  dspAssigned,
  inTransit,
  delivered,
  released,
  cancelled,
  refunded,
  disputed;

  String get label {
    switch (this) {
      case PeaceLinkStatus.pending:
        return 'في انتظار الدفع';
      case PeaceLinkStatus.funded:
        return 'تم الدفع';
      case PeaceLinkStatus.dspAssigned:
        return 'تم تعيين المندوب';
      case PeaceLinkStatus.inTransit:
        return 'قيد التوصيل';
      case PeaceLinkStatus.delivered:
        return 'تم التسليم';
      case PeaceLinkStatus.released:
        return 'مكتمل';
      case PeaceLinkStatus.cancelled:
        return 'ملغي';
      case PeaceLinkStatus.refunded:
        return 'مسترد';
      case PeaceLinkStatus.disputed:
        return 'نزاع';
    }
  }

  IconData get icon {
    switch (this) {
      case PeaceLinkStatus.pending:
        return Icons.hourglass_empty_rounded;
      case PeaceLinkStatus.funded:
        return Icons.payment_rounded;
      case PeaceLinkStatus.dspAssigned:
        return Icons.person_pin_rounded;
      case PeaceLinkStatus.inTransit:
        return Icons.local_shipping_rounded;
      case PeaceLinkStatus.delivered:
        return Icons.inventory_rounded;
      case PeaceLinkStatus.released:
        return Icons.check_circle_rounded;
      case PeaceLinkStatus.cancelled:
        return Icons.cancel_rounded;
      case PeaceLinkStatus.refunded:
        return Icons.undo_rounded;
      case PeaceLinkStatus.disputed:
        return Icons.gavel_rounded;
    }
  }

  Color get color {
    switch (this) {
      case PeaceLinkStatus.pending:
        return PeacePayColors.warning;
      case PeaceLinkStatus.funded:
        return PeacePayColors.info;
      case PeaceLinkStatus.dspAssigned:
        return PeacePayColors.info;
      case PeaceLinkStatus.inTransit:
        return PeacePayColors.primary;
      case PeaceLinkStatus.delivered:
        return PeacePayColors.success;
      case PeaceLinkStatus.released:
        return PeacePayColors.success;
      case PeaceLinkStatus.cancelled:
        return PeacePayColors.error;
      case PeaceLinkStatus.refunded:
        return PeacePayColors.textSecondary;
      case PeaceLinkStatus.disputed:
        return PeacePayColors.error;
    }
  }
}

class PeaceLinkModel {
  final String id;
  final String reference;
  final String productDescription;
  final double itemAmount;
  final double deliveryFee;
  final double platformFee;
  final double totalAmount;
  final PeaceLinkStatus status;
  final String? buyerName;
  final String? buyerPhone;
  final String? merchantName;
  final String? merchantPhone;
  final String? dspName;
  final String? dspPhone;
  final String? deliveryAddress;
  final String? deliveryNotes;
  final DateTime createdAt;
  final DateTime? fundedAt;
  final DateTime? dspAssignedAt;
  final DateTime? deliveredAt;
  final DateTime? expiresAt;

  PeaceLinkModel({
    required this.id,
    required this.reference,
    required this.productDescription,
    required this.itemAmount,
    this.deliveryFee = 0,
    this.platformFee = 0,
    this.totalAmount = 0,
    required this.status,
    this.buyerName,
    this.buyerPhone,
    this.merchantName,
    this.merchantPhone,
    this.dspName,
    this.dspPhone,
    this.deliveryAddress,
    this.deliveryNotes,
    required this.createdAt,
    this.fundedAt,
    this.dspAssignedAt,
    this.deliveredAt,
    this.expiresAt,
  });
}

// Placeholder providers
final peacelinksProvider = FutureProvider.family<
    List<PeaceLinkModel>,
    ({PeaceLinkRole role, List<PeaceLinkStatus> statuses})>((ref, params) async => []);

final peacelinkDetailsProvider =
    FutureProvider.family<PeaceLinkModel, String>((ref, id) async {
  throw UnimplementedError();
});

final peacelinkControllerProvider =
    StateNotifierProvider<PeaceLinkController, AsyncValue<void>>(
        (ref) => PeaceLinkController(ref));

class PeaceLinkController extends StateNotifier<AsyncValue<void>> {
  PeaceLinkController(this.ref) : super(const AsyncValue.data(null));
  final Ref ref;

  Future<PeaceLinkModel> create({
    required String productDescription,
    required double itemAmount,
    required double deliveryFee,
    required bool buyerPaysDelivery,
    required String merchantId,
    required String deliveryAddress,
    String? deliveryNotes,
    required bool useInternalDsp,
  }) async {
    throw UnimplementedError();
  }

  Future<void> cancel(String peacelinkId) async {}

  Future<void> confirmDelivery({
    required String peacelinkId,
    required String otp,
  }) async {}
}

// Summary row widget (shared)
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
