import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'order_details_screen.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final _pickupCtrl = TextEditingController();
  final _dropCtrl = TextEditingController();
  List<dynamic> _recent = [];
  bool _loadingRecent = true;

  @override
  void initState() {
    super.initState();
    _loadRecent();
  }

  Future<void> _loadRecent() async {
    try {
      final list = await ApiService.instance.getRecentLocations();
      setState(() {
        _recent = list;
        _loadingRecent = false;
      });
    } catch (_) {
      setState(() => _loadingRecent = false);
    }
  }

  @override
  void dispose() {
    _pickupCtrl.dispose();
    _dropCtrl.dispose();
    super.dispose();
  }

  void _continue() {
    if (_pickupCtrl.text.trim().length < 3 || _dropCtrl.text.trim().length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter pickup and drop-off addresses')),
      );
      return;
    }
    final draft = HomeScreen.bookingDraft;
    draft.pickupAddress = _pickupCtrl.text.trim();
    draft.dropoffAddress = _dropCtrl.text.trim();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const OrderDetailsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.pop(context)),
        title: const Text('Where to Shift?'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _addressField(
            controller: _pickupCtrl,
            hint: 'Pickup location',
            dotColor: AppColors.pickupGreen,
          ),
          const SizedBox(height: 12),
          _addressField(
            controller: _dropCtrl,
            hint: 'Drop-off location',
            dotColor: AppColors.dropRed,
            isPin: true,
          ),
          const SizedBox(height: 20),
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.map_outlined, size: 64, color: Colors.blue.shade200),
                Positioned(
                  left: 40,
                  top: 50,
                  child: Icon(Icons.place, color: AppColors.pickupGreen, size: 28),
                ),
                Positioned(
                  right: 40,
                  bottom: 36,
                  child: Icon(Icons.place, color: AppColors.dropRed, size: 28),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Recent locations',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          if (_loadingRecent) const LinearProgressIndicator(minHeight: 2),
          ..._recent.map((r) {
            final m = r as Map<String, dynamic>;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.home_outlined, color: Colors.grey.shade600),
              title: Text(m['label']?.toString() ?? ''),
              subtitle: Text(m['address']?.toString() ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
              onTap: () {
                final addr = m['address']?.toString() ?? '';
                if (m['label'] == 'Pickup') {
                  _pickupCtrl.text = addr;
                } else {
                  _dropCtrl.text = addr;
                }
              },
            );
          }),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _continue, child: const Text('Continue')),
        ],
      ),
    );
  }

  Widget _addressField({
    required TextEditingController controller,
    required String hint,
    required Color dotColor,
    bool isPin = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Icon(isPin ? Icons.location_on : Icons.circle, color: dotColor, size: isPin ? 22 : 14),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: controller,
            maxLines: 2,
            decoration: InputDecoration(hintText: hint),
          ),
        ),
      ],
    );
  }
}
