) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text('$label: ', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      ],
    );
  }
}

class _CreatePolicySheet extends StatefulWidget {
  const _CreatePolicySheet();

  @override
  State<_CreatePolicySheet> createState() => _CreatePolicySheetState();
}

class _CreatePolicySheetState extends State<_CreatePolicySheet> {
  final _nameController = TextEditingController();
  double _advancedPayment = 0;
  double _deliveryFee = 50;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text('إنشاء سياسة جديدة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _nameController,
            label: 'اسم السياسة',
            hint: 'مثال: سياسة المنتجات الغالية',
          ),
          const SizedBox(height: 16),
          Text('نسبة الدفع المقدم: ${_advancedPayment.toInt()}%'),
          Slider(
            value: _advancedPayment,
            min: 0,
            max: 100,
            divisions: 20,
            label: '${_advancedPayment.toInt()}%',
            onChanged: (value) => setState(() => _advancedPayment = value),
          ),
          const SizedBox(height: 8),
          Text('رسوم التوصيل: ${_deliveryFee.toInt()} ج.م'),
          Slider(
            value: _deliveryFee,
            min: 0,
            max: 200,
            divisions: 40,
            label: '${_deliveryFee.toInt()} ج.م',
            onChanged: (value) => setState(() => _deliveryFee = value),
          ),
          const SizedBox(height: 24),
          GradientButton(
            onPressed: () {
              Navigator.pop(context);
              // Create policy
            },
            child: const Text('إنشاء السياسة'),
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }
}
