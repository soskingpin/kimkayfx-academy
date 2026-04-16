import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'license_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _licenseKey = 'Loading...';
  int _daysRemaining = 0;
  int _totalSignals = 0;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _listenToSignals();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final key = prefs.getString('license_key') ?? 'Not Activated';
    final expires = prefs.getString('expires_at');
    
    int days = 0;
    if (expires != null) {
      final expiryDate = DateTime.parse(expires);
      final now = DateTime.now();
      days = expiryDate.difference(now).inDays;
      if (days < 0) days = 0;
    }

    if (mounted) {
      setState(() {
        _licenseKey = key;
        _daysRemaining = days;
      });
    }
  }

  void _listenToSignals() {
    FirebaseFirestore.instance.collection('signals').snapshots().listen((snapshot) {
      if (mounted) setState(() => _totalSignals = snapshot.docs.length);
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LicenseScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(children: [
                  Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(color: const Color(0xFF00C853).withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: const Color(0xFF00C853), width: 3)),
                    child: const Icon(Icons.person_rounded, size: 50, color: Color(0xFF1B5E20)),
                  ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                  const SizedBox(height: 12),
                  const Text('Premium Trader', style: TextStyle(color: Color(0xFF1B5E20), fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(_licenseKey, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                ]),
              ),
              const SizedBox(height: 32),

              _sectionTitle('License Status'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _daysRemaining > 7 ? Colors.green[50] : Colors.orange[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _daysRemaining > 7 ? Colors.green[300]! : Colors.orange[300]!),
                ),
                child: Row(children: [
                  Icon(Icons.verified_user_rounded, color: _daysRemaining > 7 ? Colors.green[700] : Colors.orange[700], size: 32),
                  const SizedBox(width: 16),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(_daysRemaining > 7 ? 'Active License' : 'Expiring Soon', style: TextStyle(color: _daysRemaining > 7 ? Colors.green[700] : Colors.orange[700], fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('$_daysRemaining days remaining', style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                  ])),
                  Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey[400], size: 16),
                ]),
              ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.1),
              
              const SizedBox(height: 24),

              _sectionTitle('Your Statistics'),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _statBox('Signals Received', '$_totalSignals', Icons.notifications_rounded, const Color(0xFF00C853))),
                const SizedBox(width: 12),
                Expanded(child: _statBox('P/L', '......', Icons.trending_up_rounded, Colors.blue)),
              ]).animate().fadeIn(duration: 600.ms, delay: 200.ms),
              
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton.icon(onPressed: _logout, icon: const Icon(Icons.logout_rounded), label: const Text('Logout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), style: ElevatedButton.styleFrom(backgroundColor: Colors.red[600], foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)))),
              ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(title, style: const TextStyle(color: Color(0xFF1B5E20), fontSize: 18, fontWeight: FontWeight.bold));

  Widget _statBox(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE0E0E0)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: Column(children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 11), textAlign: TextAlign.center),
      ]),
    );
  }
}