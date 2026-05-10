// lib/screens/expenses_screen.dart
import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/expenses_db.dart';
import '../services/prefs_service.dart';
import 'expense_editor.dart';
import 'settings_screen.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final _db = ExpensesDb.instance;
  final _prefs = PrefsService();
  List<Expense> _expenses = [];
  double _monthTotal = 0;
  String _currency = 'ETB';

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final now = DateTime.now();
    final list = await _db.getAll();
    final total = await _db.getTotalByMonth(now.year, now.month);
    final currency = await _prefs.getCurrency();
    setState(() {
      _expenses = list;
      _monthTotal = total;
      _currency = currency;
    });
  }

  Future<void> _openEditor({Expense? existing}) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ExpenseEditor(expense: existing)),
    );
    if (saved == true) _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthName = _monthName(now.month);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MyMoney'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
              _refresh();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Monthly total header
          Container(
            width: double.infinity,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Text(
              '$monthName total: $_currency ${_monthTotal.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          // Expense list
          Expanded(
            child: _expenses.isEmpty
                ? const Center(child: Text('No expenses yet. Tap + to add one.'))
                : ListView.builder(
                    itemCount: _expenses.length,
                    itemBuilder: (_, i) {
                      final e = _expenses[i];
                      return Dismissible(
                        key: ValueKey(e.id),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) async {
                          await _db.delete(e.id!);
                          _refresh();
                        },
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(e.category[0].toUpperCase()),
                          ),
                          title: Text('$_currency ${e.amount.toStringAsFixed(2)}'),
                          subtitle: Text('${e.category}  •  ${e.note}',
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          trailing: Text(
                            '${e.date.day}/${e.date.month}/${e.date.year}',
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          onTap: () => _openEditor(existing: e),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const names = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return names[month];
  }
}
