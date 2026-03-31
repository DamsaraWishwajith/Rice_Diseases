import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import '../theme/app_colors.dart';
import '../widgets/card_widget.dart';
import '../widgets/top_bar.dart';
import '../widgets/button_widget.dart';
import '../models/farmer.dart';
import '../models/supervisor.dart';
import '../models/disease_rec.dart';
import 'login_screen.dart';

class MoreScreen extends StatefulWidget {
  final List<Farmer> farmers;
  final Supervisor supervisor;

  const MoreScreen({super.key, required this.farmers, required this.supervisor});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  String _subPage = 'menu';
  bool _generating = false;

  final List<Map<String, dynamic>> analytics = [
    {'name': 'Blast', 'value': 38, 'color': AppColors.danger},
    {'name': 'Sheath Blight', 'value': 27, 'color': AppColors.warn},
    {'name': 'Brown Spot', 'value': 20, 'color': const Color(0xFFA0522D)},
    {'name': 'Tungro', 'value': 10, 'color': const Color(0xFF7C3AED)},
    {'name': 'Healthy', 'value': 5, 'color': AppColors.greenL},
  ];

  @override
  Widget build(BuildContext context) {
    if (_subPage == 'analytics') return _buildAnalyticsScreen();
    if (_subPage == 'reports') return _buildReportsScreen();
    return _buildMenuScreen();
  }

  Widget _buildMenuScreen() {
    final items = [
      {'icon': '📊', 'label': 'Analytics', 'desc': 'Disease trends & district stats', 'page': 'analytics'},
      {'icon': '📄', 'label': 'Reports', 'desc': 'Download farmer PDF reports', 'page': 'reports'},
      {'icon': '⚙️', 'label': 'Settings', 'desc': 'App preferences', 'page': 'menu'},
      {'icon': '❓', 'label': 'Help', 'desc': 'User guide & support', 'page': 'menu'},
      {'icon': '🚪', 'label': 'Logout', 'desc': 'Sign out of your account', 'page': 'logout'},
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const TopBar(title: 'More'),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 100),
                child: ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return CardWidget(
                      onTap: () async {
                        if (item['page'] == 'logout') {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Logout', style: TextStyle(fontFamily: 'DM Serif Display')),
                              content: const Text('Are you sure you want to sign out?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Logout', style: TextStyle(color: AppColors.danger)),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.remove('supervisor');
                            if (mounted) {
                              Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (_) => const LoginScreen()),
                                (route) => false,
                              );
                            }
                          }
                        } else {
                          setState(() => _subPage = item['page'] as String);
                        }
                      },
                      child: Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: AppColors.greenPale,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(child: Text(item['icon'] as String, style: const TextStyle(fontSize: 22))),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item['label'] as String, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                                const SizedBox(height: 2),
                                Text(item['desc'] as String, style: const TextStyle(fontSize: 12, color: AppColors.sub)),
                              ],
                            ),
                          ),
                          const Text('›', style: TextStyle(fontSize: 22, color: AppColors.sub)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsScreen() {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            TopBar(title: 'Analytics', onBack: () => setState(() => _subPage = 'menu')),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 100),
                child: Column(
                  children: [
                    Text(
                      'Disease distribution · ${widget.supervisor.district} District',
                      style: const TextStyle(fontSize: 13, color: AppColors.sub),
                    ),
                    const SizedBox(height: 18),
                    CardWidget(
                      child: Column(
                        children: [
                          const Text(
                            'Disease Breakdown',
                            style: TextStyle(fontFamily: 'DM Serif Display', fontSize: 18, color: AppColors.text),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'All farmers · All scans',
                            style: TextStyle(fontSize: 12, color: AppColors.sub),
                          ),
                          const SizedBox(height: 18),
                          _buildPieChart(),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 16,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: analytics.map((d) {
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: d['color'] as Color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${d['name']} ${d['value']}%',
                                    style: const TextStyle(fontSize: 12, color: AppColors.sub),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'By Disease Type',
                        style: TextStyle(fontFamily: 'DM Serif Display', fontSize: 18, color: AppColors.text),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...analytics.map((d) => _buildDiseaseTile(d)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    final total = analytics.fold(0, (sum, item) => sum + (item['value'] as int));
    var startAngle = -pi / 2;
    final size = 180.0;
    final center = Offset(size / 2, size / 2);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _PieChartPainter(analytics, total.toDouble(), startAngle),
      ),
    );
  }

  Widget _buildDiseaseTile(Map<String, dynamic> d) {
    final rec = diseaseRecs[d['name']];
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: CardWidget(
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: d['color'] as Color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    d['name'] as String,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.text),
                  ),
                ),
                Text(
                  '${d['value']}%',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: d['color'] as Color),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(6),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (d['value'] as int) / 100,
                child: Container(
                  decoration: BoxDecoration(
                    color: d['color'] as Color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
            if (d['name'] != 'Healthy' && rec != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '💊 ${rec.ferts[0]}',
                  style: const TextStyle(fontSize: 12, color: AppColors.sub),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportsScreen() {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            TopBar(title: 'Reports', onBack: () => setState(() => _subPage = 'menu')),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 100),
                child: Column(
                  children: [
                    CardWidget(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppColors.greenPale,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: const Center(child: Text('📄', style: TextStyle(fontSize: 22))),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Full District Report',
                                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                                    ),
                                    Text(
                                      '${widget.farmers.length} farmers · ${widget.supervisor.district}',
                                      style: const TextStyle(fontSize: 12, color: AppColors.sub),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          ButtonWidget(
                            variant: 'green',
                            icon: '⬇️',
                            text: _generating ? 'Generating PDF...' : 'Download PDF Report',
                            onPressed: () {
                              setState(() => _generating = true);
                              Future.delayed(const Duration(milliseconds: 1800), () {
                                setState(() => _generating = false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('✅ PDF Downloaded!')),
                                );
                              });
                            },
                            disabled: _generating,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final double total;
  double startAngle;

  _PieChartPainter(this.data, this.total, this.startAngle);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    for (var item in data) {
      final sweepAngle = (item['value'] as int) / total * 2 * pi;
      final paint = Paint()
        ..color = item['color'] as Color
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}