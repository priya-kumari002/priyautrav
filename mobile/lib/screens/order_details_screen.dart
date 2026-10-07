import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../screens/home_screen.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class OrderDetailsScreen extends StatefulWidget {
  const OrderDetailsScreen({super.key});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  final _senderName = TextEditingController();
  final _senderPhone = TextEditingController();
  final _receiverName = TextEditingController();
  final _receiverPhone = TextEditingController();
  final _remarks = TextEditingController();
  bool _receiverIsSelf = false;
  String _bodyType = 'open';
  bool _saving = false;

  @override
  void dispose() {
    _senderName.dispose();
    _senderPhone.dispose();
    _receiverName.dispose();
    _receiverPhone.dispose();
    _remarks.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_senderName.text.trim().length < 2 ||
        _senderPhone.text.replaceAll(RegExp(r'\D'), '').length < 10 ||
        _receiverName.text.trim().length < 2 ||
        _receiverPhone.text.replaceAll(RegExp(r'\D'), '').length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fill all required fields with valid data')),
      );
      return;
    }

    final draft = HomeScreen.bookingDraft;
    setState(() => _saving = true);
    try {
      await ApiService.instance.createBooking({
        'transportCode': draft.transportCode,
        'pickupAddress': draft.pickupAddress,
        'dropoffAddress': draft.dropoffAddress,
        'senderName': _senderName.text.trim(),
        'senderPhone': _senderPhone.text.replaceAll(RegExp(r'\D'), ''),
        'receiverName': _receiverName.text.trim(),
        'receiverPhone': _receiverPhone.text.replaceAll(RegExp(r'\D'), ''),
        'receiverIsSelf': _receiverIsSelf,
        'vehicleBodyType': _bodyType,
        'remarks': _remarks.text.trim(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking saved successfully')),
      );
      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final transport = HomeScreen.bookingDraft.transportLabel ?? 'Transport';
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.pop(context)),
        title: const Text('Order Details'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Chip(
            label: Text(transport),
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            labelStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          _sectionTitle('Sender Details'),
          _field(_senderName, 'Sender Name'),
          const SizedBox(height: 12),
          _field(_senderPhone, 'Sender phone number', phone: true),
          const SizedBox(height: 20),
          _sectionTitle('Receiver Details'),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Select me as receiver'),
            value: _receiverIsSelf,
            activeColor: AppColors.primary,
            onChanged: (v) => setState(() => _receiverIsSelf = v ?? false),
          ),
          _field(_receiverName, 'Receiver Name'),
          const SizedBox(height: 12),
          _field(_receiverPhone, 'Receiver phone number', phone: true),
          const SizedBox(height: 20),
          _sectionTitle('Vehicle Body Type'),
          Row(
            children: [
              Expanded(child: _radio('Open', 'open')),
              Expanded(child: _radio('Box', 'box')),
            ],
          ),
          const SizedBox(height: 20),
          _sectionTitle('Remarks / Instruction'),
          TextField(
            controller: _remarks,
            maxLines: 3,
            decoration: const InputDecoration(hintText: 'Optional notes for driver'),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(t, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
      );

  Widget _field(TextEditingController c, String hint, {bool phone = false}) {
    return TextField(
      controller: c,
      keyboardType: phone ? TextInputType.phone : TextInputType.name,
      inputFormatters: phone
          ? [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)]
          : null,
      decoration: InputDecoration(hintText: hint),
    );
  }

  Widget _radio(String label, String value) {
    return RadioListTile<String>(
      title: Text(label),
      value: value,
      groupValue: _bodyType,
      activeColor: AppColors.primary,
      onChanged: (v) => setState(() => _bodyType = v ?? 'open'),
    );
  }
}
