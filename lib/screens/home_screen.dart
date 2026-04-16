import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
              Text('Welcome to', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
              const Text('KimKayFX Academy', style: TextStyle(color: Color(0xFF1B5E20), fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),

              // 🟢 YOUR REAL LOGO - NOW ENABLED
              Center(
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C853).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFF00C853).withOpacity(0.3), width: 2),
                    boxShadow: [BoxShadow(color: const Color(0xFF00C853).withOpacity(0.2), blurRadius: 20, spreadRadius: 5)],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ✅ YOUR LOGO IS NOW ACTIVE:
                      Image.asset('assets/images/kimkay_logo.png', width: 120, height: 120, fit: BoxFit.contain),
                    ],
                  ),
                ),
              ).animate().scale(duration: 800.ms, curve: Curves.easeOutBack),
              
              const SizedBox(height: 32),

              // 🟢 RISK DISCLAIMER
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.orange[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(Icons.warning_rounded, color: Colors.orange[700], size: 24),
                      const SizedBox(width: 8),
                      const Text('Risk Disclaimer', style: TextStyle(color: Color(0xFF1B5E20), fontSize: 16, fontWeight: FontWeight.bold)),
                    ]),
                    const SizedBox(height: 12),
                    Text('Trading forex and CFDs involves significant risk of loss and may not be suitable for all investors. Past performance is not indicative of future results. Please trade responsibly.', style: TextStyle(color: Colors.grey[700], fontSize: 13, height: 1.5)),
                  ],
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 300.ms).slideX(begin: -0.1),
              
              const SizedBox(height: 24),

              // 🟢 REAL-TIME STATS (LIVE FROM FIRESTORE)
              const Text('Your Progress', style: TextStyle(color: Color(0xFF1B5E20), fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('signals').snapshots(),
                builder: (context, snapshot) {
                  final signalCount = snapshot.hasData ? snapshot.data!.docs.length : 0;
                  return Row(
                    children: [
                      Expanded(child: _statCard('Signals Received', '$signalCount', Icons.notifications_rounded)),
                      const SizedBox(width: 12),
                      Expanded(child: _statCard('P/L', '......', Icons.trending_up_rounded)),
                    ],
                  ).animate().fadeIn(duration: 600.ms, delay: 400.ms);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(16), 
        border: Border.all(color: const Color(0xFFE0E0E0)), 
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
      ),
      child: Column(children: [
        Icon(icon, color: const Color(0xFF00C853), size: 32),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(color: Color(0xFF1B5E20), fontSize: 24, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12), textAlign: TextAlign.center),
      ]),
    );
  }
}