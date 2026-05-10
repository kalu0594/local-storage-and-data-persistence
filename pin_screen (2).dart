// lib/screens/pin_screen.dart
import 'package:flutter/material.dart';
import '../services/pin_vault.dart';
import '../services/expenses_db.dart';
import '../services/prefs_service.dart';
import 'expenses_screen.dart';

class PinScreen extends StatefulWidget {
  final bool isSetup;
  const PinScreen({super.key, required this.isSetup});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  final _vault = PinVault();
  final _prefs = PrefsService();
  String _entered = '';
  String _message = '';

  void _onDigit(String d) {
    if (_entered.length >= 4) return;
    setState(() => _entered += d);
    if (_entered.length == 4) _submit();
  }

  void _onDelete() {
    if (_entered.isEmpty) return;
    setState(() => _entered = _entered.substring(0, _entered.length - 1));
  }

  Future<void> _submit() async {
    if (widget.isSetup) {
      await _vault.savePin(_entered);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ExpensesScreen()),
      );
    } else {
      final ok = await _vault.verifyPin(_entered);
      if (ok) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ExpensesScreen()),
        );
      } else {
        setState(() {
          _entered = '';
          _message = 'Incorrect PIN. Try again.';
        });
      }
    }
  }

  Future<void> _resetPin() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reset PIN'),
        content: const Text(
            'This will delete your PIN and ALL expense records. Continue?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Reset', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await _vault.deletePin();
      await ExpensesDb.instance.deleteAll();
      await _prefs.clearAll();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PinScreen(isSetup: true)),
      );
    }
  }

  Widget _buildDot(int index) {
    final filled = index < _entered.length;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
        border: Border.all(color: Colors.grey.shade400),
      ),
    );
  }

  Widget _buildKey(String label, {VoidCallback? onTap, Color? color}) {
    return Expanded(
      child: TextButton(
        onPressed: onTap,
        child: Text(
          label,
          style: TextStyle(fontSize: 24, color: color ?? Colors.black87),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isSetup ? 'Set Your PIN' : 'Enter PIN'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.isSetup ? 'Create a 4-digit PIN' : 'Enter your PIN to continue',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, _buildDot),
            ),
            const SizedBox(height: 16),
            if (_message.isNotEmpty)
              Text(_message, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 24),
            // Keypad
            for (var row in [
              ['1', '2', '3'],
              ['4', '5', '6'],
              ['7', '8', '9'],
            ])
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: row.map((d) => _buildKey(d, onTap: () => _onDigit(d))).toList(),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildKey('', color: Colors.transparent),
                _buildKey('0', onTap: () => _onDigit('0')),
                _buildKey('⌫', onTap: _onDelete, color: Colors.red.shade400),
              ],
            ),
            const SizedBox(height: 24),
            if (!widget.isSetup)
              TextButton(
                onPressed: _resetPin,
                child: const Text('Reset PIN & clear all data',
                    style: TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ),
    );
  }
}
