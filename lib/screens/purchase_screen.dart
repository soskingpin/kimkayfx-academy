import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PurchaseScreen extends StatelessWidget {
  const PurchaseScreen({super.key});

  static const List<Map<String, dynamic>> packages = [
    {'name': 'VVIP Signals', 'duration': 'Lifetime', 'price': '\$60', 'colorCode': 0xFF1B5E20},
    {'name': 'VVIP Signals', 'duration': 'Monthly', 'price': '\$30', 'colorCode': 0xFF00C853},
    {'name': 'VIP Signals', 'duration': 'Bi-Weekly', 'price': '\$15', 'colorCode': 0xFF4CAF50},
    {'name': 'VVIP Signals', 'duration': 'Weekly', 'price': '\$10', 'colorCode': 0xFF81C784},
  ];

  Future<void> _openWhatsApp(String package) async {
    final message = Uri.encodeComponent('Hi KimKayFX, I want to purchase: $package');
    final url = 'https://wa.me/263779894763?text=$message';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00C853), foregroundColor: Colors.white, elevation: 0,
        title: const Text('Purchase License', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Select a Package', style: TextStyle(color: Color(0xFF1B5E20), fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Choose the plan that fits your trading goals', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            const SizedBox(height: 24),
            ...packages.map((pkg) => _packageCard(pkg, context)).toList(),
            const SizedBox(height: 32),
            Center(child: TextButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back, color: Color(0xFF00C853)), label: const Text('Back to Activation', style: TextStyle(color: Color(0xFF00C853), fontWeight: FontWeight.w600)))).animate().fadeIn(duration: 600.ms),
          ]),
        ),
      ),
    );
  }

  Widget _packageCard(Map<String, dynamic> pkg, BuildContext context) {
    final color = Color(pkg['colorCode']);
    return Container(
      margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.3)), boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 10)]),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(pkg['name'], style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)), Text(pkg['duration'], style: TextStyle(color: Colors.grey[600], fontSize: 14))]),
          Text(pkg['price'], style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 16),
        SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => _showPaymentMethods(context, pkg['name'], pkg['price']), style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('BUY NOW', style: TextStyle(fontWeight: FontWeight.bold)))),
      ]),
    ).animate().fadeIn(duration: 500.ms).slideX(begin: 0.1);
  }

  void _showPaymentMethods(BuildContext context, String package, String price) {
    showModalBottomSheet(context: context, backgroundColor: Colors.transparent, builder: (ctx) => Container(
      padding: const EdgeInsets.all(24), decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 20),
        Text('Complete Payment: $price', style: const TextStyle(color: Color(0xFF1B5E20), fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Select your preferred payment method', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        const SizedBox(height: 24),
        _paymentOption('assets/images/payments/ecocash_logo.png', 'EcoCash', () => _openWhatsApp(package), context),
        _paymentOption('assets/images/payments/omari_logo.png', 'Omari', () => _openWhatsApp(package), context),
        _paymentOption('assets/images/payments/innbucks_logo.png', 'InnBucks', () => _openWhatsApp(package), context),
        const SizedBox(height: 24),
        Center(child: TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600)))),
      ]),
    ));
  }

  Widget _paymentOption(String assetPath, String name, VoidCallback onTap, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF00C853).withOpacity(0.2))),
      child: Material(color: Colors.transparent, child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12), child: Padding(
        padding: const EdgeInsets.all(16), child: Row(children: [
          Container(width: 50, height: 50, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey[300]!)), child: Padding(padding: const EdgeInsets.all(8), child: Image.asset(assetPath, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.payment_rounded, color: Color(0xFF00C853))))),
          const SizedBox(width: 16), Text(name, style: const TextStyle(color: Color(0xFF1B5E20), fontSize: 16, fontWeight: FontWeight.w600)),
          const Spacer(), Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey[400], size: 18),
        ]),
      ))),
    ).animate().fadeIn(duration: 400.ms);
  }
}