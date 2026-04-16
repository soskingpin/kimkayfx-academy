import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SignalsScreen extends StatefulWidget {
  const SignalsScreen({super.key});
  @override
  State<SignalsScreen> createState() => _SignalsScreenState();
}

class _SignalsScreenState extends State<SignalsScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() { _pageController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Column(
          children: [
            // 🟢 PAGE INDICATOR TABS
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _pageIndicator('Live Signals', 0),
                  const SizedBox(width: 12),
                  _pageIndicator('History', 1),
                ],
              ),
            ),
            // 🟢 HORIZONTAL SWIPE PAGES
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: const [_LiveSignalsPage(), _HistoryPage()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pageIndicator(String label, int index) {
    final isSelected = _currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF00C853) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF00C853)),
      ),
      child: Text(label, style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF00C853), fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }
}

// 🟢 LIVE SIGNALS PAGE WITH STATUS BADGES
class _LiveSignalsPage extends StatelessWidget {
  const _LiveSignalsPage();

  // ✅ STATUS BADGE CONFIG (Admin sets these in Firestore)
  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE': return const Color(0xFF00C853); // Green
      case 'TP HIT': return const Color(0xFF00C853); // Green
      case 'SL HIT': return Colors.red; // Red
      case 'HOLD': return Colors.orange; // Orange
      case 'ADD MORE POSITIONS': return Colors.blue; // Blue
      case 'EXIT': return Colors.grey; // Grey
      case 'INVALIDATED': return Colors.black; // Black
      default: return const Color(0xFF00C853);
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE': return Icons.check_circle_rounded;
      case 'TP HIT': return Icons.trending_up_rounded;
      case 'SL HIT': return Icons.trending_down_rounded;
      case 'HOLD': return Icons.pause_circle_rounded;
      case 'ADD MORE POSITIONS': return Icons.add_circle_rounded;
      case 'EXIT': return Icons.logout_rounded;
      case 'INVALIDATED': return Icons.cancel_rounded;
      default: return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('signals').orderBy('timestamp', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFF00C853)));
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.signal_cellular_off_rounded, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('No Active Signals', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
            Text('Waiting for admin to send signals', style: TextStyle(color: Colors.grey[400], fontSize: 13)),
          ]));
        }

        final signals = snapshot.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: signals.length,
          itemBuilder: (_, i) {
            final s = signals[i].data() as Map<String, dynamic>;
            final pair = s['pair'] ?? 'EUR/USD';
            final type = (s['type'] ?? 'BUY').toString().toUpperCase();
            final entry = s['entry'] ?? '0.0000';
            final tp = s['tp'] ?? '0.0000';
            final sl = s['sl'] ?? '0.0000';
            final status = s['status'] ?? 'ACTIVE'; // ✅ Admin sets this
            final isBuy = type.contains('BUY');
            final statusColor = _getStatusColor(status);
            final statusIcon = _getStatusIcon(status);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: statusColor.withOpacity(0.3)),
                boxShadow: [BoxShadow(color: statusColor.withOpacity(0.1), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  // 🟢 HEADER: Pair + Status Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(pair.toString(), style: const TextStyle(color: Color(0xFF1B5E20), fontSize: 18, fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(statusIcon, color: statusColor, size: 14),
                          const SizedBox(width: 4),
                          Text(status.toString().toUpperCase(), style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                        ]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // 🟢 TRADE DETAILS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _detail('Entry', entry.toString(), Colors.grey[700]!),
                      _detail('TP', tp.toString(), const Color(0xFF00C853)),
                      _detail('SL', sl.toString(), Colors.red),
                    ],
                  ),
                  // 🟢 TYPE BADGE
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(color: (isBuy ? const Color(0xFF00C853) : Colors.red).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Center(child: Text(type, style: TextStyle(color: isBuy ? const Color(0xFF00C853) : Colors.red, fontWeight: FontWeight.bold, fontSize: 13))),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 500.ms, delay: Duration(milliseconds: i * 100)).slideX(begin: 0.1);
          },
        );
      },
    );
  }

  Widget _detail(String label, String value, Color color) {
    return Column(children: [
      Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      const SizedBox(height: 4),
      Text(value, style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.bold)),
    ]);
  }
}

// 🟢 HISTORY PAGE (Shows closed/invalidated signals)
class _HistoryPage extends StatelessWidget {
  const _HistoryPage();
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('signals').where('status', whereIn: ['EXIT', 'INVALIDATED', 'TP HIT', 'SL HIT']).orderBy('timestamp', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFF00C853)));
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.history_rounded, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('No Closed Signals', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
            Text('Finished signals will appear here', style: TextStyle(color: Colors.grey[400], fontSize: 13)),
          ]));
        }
        final signals = snapshot.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: signals.length,
          itemBuilder: (_, i) {
            final s = signals[i].data() as Map<String, dynamic>;
            final pair = s['pair'] ?? 'EUR/USD';
            final status = s['status'] ?? 'EXIT';
            final statusColor = _getStatusColor(status);
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(16), border: Border.all(color: statusColor.withOpacity(0.3))),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(pair.toString(), style: const TextStyle(color: Color(0xFF1B5E20), fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Status: $status', style: TextStyle(color: statusColor, fontSize: 13, fontWeight: FontWeight.w500)),
                ]),
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(6)), child: Text(status.toString().toUpperCase(), style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11))),
              ]),
            ).animate().fadeIn(duration: 500.ms, delay: Duration(milliseconds: i * 100));
          },
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'TP HIT': return const Color(0xFF00C853);
      case 'SL HIT': return Colors.red;
      case 'EXIT': return Colors.grey;
      case 'INVALIDATED': return Colors.black;
      default: return Colors.grey;
    }
  }
}