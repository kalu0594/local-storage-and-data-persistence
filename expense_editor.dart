// lib/screens/expense_editor.dart
import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/expenses_db.dart';

class ExpenseEditor extends StatefulWidget {
  final Expense? expense;
  const ExpenseEditor({super.key, this.expense});

  @override
  State<ExpenseEditor> createState() => _ExpenseEditorState();
}

class _ExpenseEditorState extends State<ExpenseEditor> {
  final _amountCtl = TextEditingController();
  final _noteCtl = TextEditingController();
  String _category = 'Food';
  DateTime _date = DateTime.now();

  static const _categories = [
    'Food', 'Transport', 'Health', 'Education', 'Entertainment', 'Shopping', 'Other'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      final e = widget.expense!;
      _amountCtl.text = e.amount.toString();
      _noteCtl.text = e.note;
      _category = e.category;
      _date = e.date;
    }
  }

  @override
  void dispose() {
    _amountCtl.dispose();
    _noteCtl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    final amountText = _amountCtl.text.trim();
    if (amountText.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please enter an amount')));
      return;
    }
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Enter a valid positive amount')));
      return;
    }

    final expense = Expense(
      id: widget.expense?.id,
      amount: amount,
      category: _category,
      note: _noteCtl.text.trim(),
      date: _date,
    );

    if (expense.id == null) {
      await ExpensesDb.instance.insert(expense);
    } else {
      await ExpensesDb.instance.update(expense);
    }

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expense == null ? 'Add Expense' : 'Edit Expense'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _amountCtl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category),
                border: OutlineInputBorder(),
              ),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteCtl,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                prefixIcon: Icon(Icons.note),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: Text(
                  'Date: ${_date.day}/${_date.month}/${_date.year}'),
              trailing: TextButton(
                  onPressed: _pickDate, child: const Text('Change')),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text('Save Expense'),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
