import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'app_shell.dart';
import 'purchase_screen.dart';

class LicenseScreen extends StatefulWidget {
  const LicenseScreen({super.key});
  @override
  State<LicenseScreen> createState() => _LicenseScreenState();
}

class _LicenseScreenState extends State<LicenseScreen> {
  final _keyCtrl = TextEditingController();
  bool _isLoading = false;
  String _errorMsg = '';

  static const Color omariGreen = Color(0xFF00C853);
  static const Color omariDarkGreen = Color(0xFF1B5E20);
  static const Color bgWhite = Color(0xFFFFFFFF);
  static const Color inputBg = Color(0xFFF5F5F5);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textGray = Color(0xFF757575);
  static const Color borderColor = Color(0xFFE0E0E0);

  @override
  void initState() { super.initState(); _checkLocalSession(); }
  @override
  void dispose() { _keyCtrl.dispose(); super.dispose(); }

  Future<String> _getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    var deviceId = prefs.getString('device_id');
    if (deviceId == null) {
      deviceId = 'KFX_WEB_${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString('device_id', deviceId);
    }
    return deviceId;
  }

  Future<void> _checkLocalSession() async {
    final prefs = await SharedPreferences.getInstance();
    final key = prefs.getString('license_key');
    final expiresAt = prefs.getString('expires_at');
    if (key != null && expiresAt != null) {
      try {
        if (DateTime.now().isBefore(DateTime.parse(expiresAt))) {
          if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AppShell()));
          return;
        }
      } catch (_) {}
      prefs.remove('license_key');
      prefs.remove('expires_at');
      if (mounted) setState(() => _errorMsg = 'License expired. Please renew.');
    }
  }

  Future<void> _activate() async {
    if (_isLoading) return;
    setState(() { _isLoading = true; _errorMsg = ''; });
    final input = _keyCtrl.text.trim().toUpperCase();
    if (input.isEmpty) {
      setState(() { _isLoading = false; _errorMsg = 'Please enter your license key'; });
      return;
    }
    try {
      final snap = await FirebaseFirestore.instance.collection('licenses').doc(input).get();
      final deviceId = await _getDeviceId();
      if (!snap.exists) {
        setState(() => _errorMsg = 'Invalid license key');
        return;
      }
      final data = snap.data()!;
      final isUsed = data['is_used'] ?? false;
      final usedDevice = data['used_device_id'] ?? '';
      int durationDays = 7;
      final rawDuration = data['duration_days'];
      if (rawDuration != null) {
        if (rawDuration is num) durationDays = rawDuration.toInt();
        else { final parsed = int.tryParse(rawDuration.toString()); if (parsed != null) durationDays = parsed; }
      }
      if (isUsed && usedDevice != deviceId) {
        setState(() => _errorMsg = 'License already used on another device');
        return;
      }
      final now = DateTime.now();
      final expiresAt = now.add(Duration(days: durationDays));
      await snap.reference.update({
        'is_used': true, 'used_device_id': deviceId,
        'activated_at': FieldValue.serverTimestamp(),
        'expires_at': expiresAt.toIso8601String(),
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('license_key', input);
      await prefs.setString('expires_at', expiresAt.toIso8601String());
      await prefs.setString('device_id', deviceId);
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AppShell()));
    } catch (e) {
      print('🔥 LICENSE ERROR: $e');
      if (mounted) setState(() => _errorMsg = 'Error: $e');
    } finally { if (mounted) setState(() => _isLoading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgWhite,
      appBar: AppBar(
        backgroundColor: omariGreen, elevation: 0,
        title: const Text('KimKayFX Signals', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(color: omariGreen.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: omariGreen.withOpacity(0.3), width: 2)),
                  child: const Icon(Icons.verified_user_rounded, color: omariDarkGreen, size: 40),
                ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                const SizedBox(height: 24),
                const Text('Welcome Back', style: TextStyle(color: textDark, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Enter your license key to access signals', style: TextStyle(color: textGray, fontSize: 14)),
                const SizedBox(height: 40),
                Container(
                  width: double.infinity, padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderColor), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('License Key', style: TextStyle(color: omariDarkGreen, fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(color: inputBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderColor)),
                      child: TextField(
                        controller: _keyCtrl, textAlign: TextAlign.center,
                        style: TextStyle(color: textDark, fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 2),
                        decoration: const InputDecoration(hintText: 'KFX-XXXX-XXXX', hintStyle: TextStyle(color: Color(0xFFBDBDBD)), border: InputBorder.none, errorBorder: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none),
                      ),
                    ),
                    if (_errorMsg.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 12), child: Text(_errorMsg, style: const TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w500))).animate().shake(duration: 400.ms),
                  ]),
                ).animate().fadeIn(duration: 500.ms, delay: 200.ms).slideY(begin: 0.1),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity, height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _activate,
                    style: ElevatedButton.styleFrom(backgroundColor: omariGreen, foregroundColor: Colors.white, elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
                    child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation(Colors.white))) : const Text('ACTIVATE NOW', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ),
                ).animate().fadeIn(duration: 500.ms, delay: 300.ms).slideY(begin: 0.1),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PurchaseScreen())),
                  child: RichText(text: const TextSpan(style: TextStyle(color: Color(0xFF00C853), fontSize: 14), children: [TextSpan(text: "Don't have a key? "), TextSpan(text: 'Purchase Now', style: TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline))])),
                ).animate().fadeIn(duration: 600.ms, delay: 500.ms),
                const SizedBox(height: 8),
                Text('Secured by KimKayFX Academy', style: TextStyle(color: textGray, fontSize: 12)).animate().fadeIn(duration: 800.ms, delay: 500.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}