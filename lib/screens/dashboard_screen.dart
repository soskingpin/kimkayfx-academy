import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Widget _glassCard({required Widget child, Duration delay = Duration.zero}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.25)),
            boxShadow: [BoxShadow(color: const Color(0xFFFFD700).withOpacity(0.1), blurRadius: 12, spreadRadius: 1)],
          ),
          child: child,
        ),
      ),
    ).animate(onPlay: (controller) => controller.repeat()).fadeIn(duration: 500.ms, delay: delay).slideY(begin: 0.12, end: 0, curve: Curves.easeOutCubic);
  }

  Widget _signalDetail(String label, String value, Color color) {
    return Column(children: [
      Text(label, style: TextStyle(color: Colors.white.withOpacity(0.54), fontSize: 11, fontWeight: FontWeight.w500)),
      const SizedBox(height: 4),
      Text(value, style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFFFFD700),
        elevation: 0,
        title: Row(children: const [
          Text('KIMKAYFX', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.2)),
          SizedBox(width: 6),
          Text('SIGNALS', style: TextStyle(fontWeight: FontWeight.w400, color: Colors.white70, letterSpacing: 2.5)),
        ]),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF00FF88).withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF00FF88).withOpacity(0.4)),
              ),
              child: Row(children: const [
                Icon(Icons.circle, size: 8, color: Color(0xFF00FF88)),
                SizedBox(width: 6),
                Text('LIVE', style: TextStyle(color: Color(0xFF00FF88), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ]),
            ).animate(onPlay: (controller) => controller.repeat()).scale(begin: const Offset(0.95, 0.95), end: const Offset(1.0, 1.0), curve: Curves.easeInOut, duration: 600.ms),
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('signals')
              .where('status', isEqualTo: 'ACTIVE')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('Sync Error: ${snapshot.error}', style: TextStyle(color: Colors.white.withOpacity(0.54), fontSize: 14), textAlign: TextAlign.center))).animate().fadeIn().slideY();
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                const SizedBox(height: 80, width: 80, child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation(Color(0xFFFFD700)))),
                const SizedBox(height: 16),
                const Text('Connecting to signals...', style: TextStyle(color: Colors.white60, fontSize: 14)),
              ])).animate().fadeIn();
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: _glassCard(child: Column(mainAxisSize: MainAxisSize.min, children: const [
                Icon(Icons.signal_cellular_alt_rounded, size: 48, color: Colors.white54),
                SizedBox(height: 14),
                Text('Awaiting Admin Signals', style: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('New alerts will appear here in real-time.', style: TextStyle(color: Colors.white54, fontSize: 13), textAlign: TextAlign.center),
              ])));
            }

            final signals = snapshot.data!.docs;
            return RefreshIndicator(
              onRefresh: () async {},
              color: const Color(0xFFFFD700),
              backgroundColor: const Color(0xFF111111),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: signals.length,
                itemBuilder: (_, i) {
                  final s = signals[i].data() as Map<String, dynamic>;
                  final pair = s['pair'] ?? 'EUR/USD';
                  final type = (s['type'] ?? 'BUY').toString().toUpperCase();
                  final entry = s['entry'] ?? '0.0000';
                  final tp = s['tp'] ?? '0.0000';
                  final sl = s['sl'] ?? '0.0000';
                  final isBuy = type.contains('BUY');
                  final color = isBuy ? const Color(0xFF00FF88) : Colors.redAccent;
                  final delay = Duration(milliseconds: i * 120);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _glassCard(delay: delay, child: Column(children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text(pair, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                        Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(8)), child: Text(type, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1)))
                      ]),
                      const SizedBox(height: 12),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        _signalDetail('ENTRY', entry.toString(), Colors.white),
                        _signalDetail('TP', tp.toString(), const Color(0xFF00FF88)),
                        _signalDetail('SL', sl.toString(), Colors.redAccent),
                      ]),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity, 
                        padding: const EdgeInsets.symmetric(vertical: 10), 
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12), 
                          borderRadius: BorderRadius.circular(8), 
                          border: Border.all(color: color.withOpacity(0.3))
                        ), 
                        child: Center(child: Text('🔥 SIGNAL ACTIVE', style: TextStyle(color: color, fontWeight: FontWeight.w600, letterSpacing: 1.5)))
                      ).animate(onPlay: (controller) => controller.repeat()).shimmer(duration: 1500.ms, delay: delay),
                    ])),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}