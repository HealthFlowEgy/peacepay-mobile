/// Transaction Export Screen
/// Export transaction history to CSV or PDF
/// 
/// MISSING COMPONENT FIX - From Mobile App Audit Report

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class Transaction {
  final String id;
  final String type;
  final double amount;
  final DateTime date;
  final String status;
  final String? peacelinkId;
  final String? counterparty;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.date,
    required this.status,
    this.peacelinkId,
    this.counterparty,
  });
}

class TransactionExportScreen extends StatefulWidget {
  const TransactionExportScreen({super.key});

  @override
  State<TransactionExportScreen> createState() => _TransactionExportScreenState();
}

class _TransactionExportScreenState extends State<TransactionExportScreen> {
  DateTimeRange? _dateRange;
  String _selectedType = 'all';
  bool _isExporting = false;
  
  final List<Transaction> _transactions = [
    // Mock data - would come from API
    Transaction(
      id: 'TXN001',
      type: 'peacelink',
      amount: 1500,
      date: DateTime.now().subtract(const Duration(days: 1)),
      status: 'completed',
      peacelinkId: 'PL123456',
      counterparty: 'متجر التقنية',
    ),
    Transaction(
      id: 'TXN002',
      type: 'cashout',
      amount: -500,
      date: DateTime.now().subtract(const Duration(days: 2)),
      status: 'completed',
    ),
    Transaction(
      id: 'TXN003',
      type: 'topup',
      amount: 1000,
      date: DateTime.now().subtract(const Duration(days: 3)),
      status: 'completed',
    ),
  ];

  List<Transaction> get _filteredTransactions {
    return _transactions.where((t) {
      if (_selectedType != 'all' && t.type != _selectedType) return false;
      if (_dateRange != null) {
        if (t.date.isBefore(_dateRange!.start) || t.date.isAfter(_dateRange!.end)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  Future<void> _selectDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
      locale: const Locale('ar'),
    );
    if (range != null) {
      setState(() => _dateRange = range);
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'peacelink':
        return 'PeaceLink';
      case 'cashout':
        return 'سحب';
      case 'topup':
        return 'إيداع';
      case 'fee':
        return 'رسوم';
      default:
        return type;
    }
  }

  Future<void> _exportCSV() async {
    setState(() => _isExporting = true);
    
    try {
      final transactions = _filteredTransactions;
      final buffer = StringBuffer();
      
      // Header
      buffer.writeln('رقم المعاملة,النوع,المبلغ,التاريخ,الحالة,رقم PeaceLink,الطرف الآخر');
      
      // Data
      for (final t in transactions) {
        buffer.writeln(
          '${t.id},'
          '${_getTypeLabel(t.type)},'
          '${t.amount},'
          '${DateFormat('yyyy-MM-dd HH:mm').format(t.date)},'
          '${t.status},'
          '${t.peacelinkId ?? ""},'
          '${t.counterparty ?? ""}'
        );
      }

      // Save file
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/transactions_${DateTime.now().millisecondsSinceEpoch}.csv');
      await file.writeAsString(buffer.toString());

      // Share
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'سجل المعاملات - PeacePay',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _exportPDF() async {
    setState(() => _isExporting = true);
    
    try {
      final transactions = _filteredTransactions;
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          textDirection: pw.TextDirection.rtl,
          build: (context) => [
            pw.Header(
              level: 0,
              child: pw.Text(
                'سجل المعاملات - PeacePay',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'تاريخ التصدير: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 12),
            ),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headers: ['رقم المعاملة', 'النوع', 'المبلغ', 'التاريخ', 'الحالة'],
              data: transactions.map((t) => [
                t.id,
                _getTypeLabel(t.type),
                '${t.amount.abs()} ج.م',
                DateFormat('yyyy-MM-dd').format(t.date),
                t.status == 'completed' ? 'مكتمل' : t.status,
              ]).toList(),
            ),
            pw.SizedBox(height: 20),
            pw.Divider(),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('إجمالي المعاملات: ${transactions.length}'),
                pw.Text(
                  'الصافي: ${transactions.fold<double>(0, (sum, t) => sum + t.amount).toStringAsFixed(2)} ج.م',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      );

      // Save file
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/transactions_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(await pdf.save());

      // Share
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'سجل المعاملات - PeacePay',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تصدير المعاملات'),
          backgroundColor: const Color(0xFF1E3A8A),
          foregroundColor: Colors.white,
        ),
        body: Column(
          children: [
            // Filters
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[100],
              child: Column(
                children: [
                  // Date Range
                  InkWell(
                    onTap: _selectDateRange,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.date_range, color: Color(0xFF1E3A8A)),
                          const SizedBox(width: 8),
                          Text(
                            _dateRange == null
                                ? 'اختر الفترة الزمنية'
                                : '${DateFormat('yyyy/MM/dd').format(_dateRange!.start)} - ${DateFormat('yyyy/MM/dd').format(_dateRange!.end)}',
                          ),
                          const Spacer(),
                          if (_dateRange != null)
                            IconButton(
                              icon: const Icon(Icons.close, size: 20),
                              onPressed: () => setState(() => _dateRange = null),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Type Filter
                  Row(
                    children: [
                      const Text('النوع: '),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildFilterChip('all', 'الكل'),
                              _buildFilterChip('peacelink', 'PeaceLink'),
                              _buildFilterChip('cashout', 'سحب'),
                              _buildFilterChip('topup', 'إيداع'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Preview
            Expanded(
              child: _filteredTransactions.isEmpty
                  ? const Center(child: Text('لا توجد معاملات'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredTransactions.length,
                      itemBuilder: (context, index) {
                        final t = _filteredTransactions[index];
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: t.amount >= 0
                                  ? Colors.green[100]
                                  : Colors.red[100],
                              child: Icon(
                                t.amount >= 0
                                    ? Icons.arrow_downward
                                    : Icons.arrow_upward,
                                color: t.amount >= 0 ? Colors.green : Colors.red,
                              ),
                            ),
                            title: Text(_getTypeLabel(t.type)),
                            subtitle: Text(
                              DateFormat('yyyy/MM/dd HH:mm').format(t.date),
                            ),
                            trailing: Text(
                              '${t.amount >= 0 ? "+" : ""}${t.amount.toStringAsFixed(2)} ج.م',
                              style: TextStyle(
                                color: t.amount >= 0 ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Summary
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[100],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${_filteredTransactions.length} معاملة'),
                  Text(
                    'الصافي: ${_filteredTransactions.fold<double>(0, (sum, t) => sum + t.amount).toStringAsFixed(2)} ج.م',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            // Export Buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isExporting ? null : _exportCSV,
                      icon: const Icon(Icons.table_chart),
                      label: const Text('تصدير CSV'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B4D8),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isExporting ? null : _exportPDF,
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('تصدير PDF'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
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

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedType == value;
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _selectedType = selected ? value : 'all');
        },
        selectedColor: const Color(0xFF1E3A8A).withOpacity(0.2),
        checkmarkColor: const Color(0xFF1E3A8A),
      ),
    );
  }
}
