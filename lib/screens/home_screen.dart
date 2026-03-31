import 'package:flutter/material.dart';
import 'alerts_screen.dart';
import 'farmers_screen.dart';
import 'more_screen.dart';
import 'scan_screen.dart';
import '../theme/app_colors.dart';
import '../widgets/card_widget.dart';
import '../widgets/tag_widget.dart';
import '../models/supervisor.dart';
import '../models/farmer.dart';
import '../models/alert.dart';
import '../models/disease_rec.dart';

final List<Farmer> initialFarmers = [
  Farmer(
    id: 1, name: "Kamal Perera", phone: "077-1234567",
    location: "Anuradhapura North", district: "Anuradhapura", area: "3.5 ac",
    variety: "Suwandel", scans: 3, disease: "Blast", lastScan: "Feb 12",
  ),
  Farmer(
    id: 2, name: "Nimal Silva", phone: "071-9876543",
    location: "Polonnaruwa East", district: "Anuradhapura", area: "5.0 ac",
    variety: "Nadu", scans: 2, disease: "Sheath Blight", lastScan: "Feb 15",
  ),
  Farmer(
    id: 3, name: "Sunil Fernando", phone: "076-5551234",
    location: "Kurunegala Central", district: "Anuradhapura", area: "2.2 ac",
    variety: "Rathu Heenati", scans: 4, disease: "Brown Spot", lastScan: "Feb 17",
  ),
];

final List<Alert> initialAlerts = [
  Alert(id: 1, farmer: "Kamal Perera", disease: "Blast", severity: "High", time: "2h ago", read: false),
  Alert(id: 2, farmer: "Nimal Silva", disease: "Sheath Blight", severity: "Medium", time: "1d ago", read: false),
  Alert(id: 3, farmer: "Sunil Fernando", disease: "Brown Spot", severity: "Low", time: "3d ago", read: true),
];

class HomeScreen extends StatefulWidget {
  final Supervisor supervisor;

  const HomeScreen({super.key, required this.supervisor});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = initialAlerts.where((a) => !a.read).length;
    final name = widget.supervisor.username.replaceAll('_', ' ').split(' ').map((e) =>
        e.isNotEmpty ? e[0].toUpperCase() + e.substring(1).toLowerCase() : e).join(' ');

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _selectedIndex = index);
        },
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildHomeContent(name, unreadCount),
          FarmersScreen(farmers: initialFarmers),
          ScanScreen(farmers: initialFarmers),
          AlertsScreen(supervisor: widget.supervisor),
          MoreScreen(farmers: initialFarmers, supervisor: widget.supervisor),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHomeContent(String name, int unreadCount) {
    return Column(
      children: [
        _buildHeader(name, unreadCount),
        Expanded(
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100, top: 20),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildQuickScanCard(),
                  ),
                  const SizedBox(height: 28),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildRecentAlerts(),
                  ),
                  const SizedBox(height: 28),
                  _buildFarmersSection(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(String name, int unreadCount) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.fromLTRB(20, topPadding + 15, 20, 25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.forest, AppColors.green],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.forest.withOpacity(0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Good morning 👋',
                      style: TextStyle(color: Colors.white70, fontSize: 16, letterSpacing: 0.3),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      name,
                      style: const TextStyle(
                        fontFamily: 'DM Serif Display',
                        color: Colors.white,
                        fontSize: 32,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '📍  ${widget.supervisor.district} District',
                      style: const TextStyle(color: Colors.white60, fontSize: 16, letterSpacing: 0.2),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _pageController.jumpToPage(3),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Stack(
                    children: [
                      const Center(child: Text('🔔', style: TextStyle(fontSize: 22))),
                      if (unreadCount > 0)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.forest, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          Row(
            children: [
              _buildStatCard('👤', '24', 'Farmers'),
              const SizedBox(width: 12),
              _buildStatCard('🔬', '7', 'Scans'),
              const SizedBox(width: 12),
              _buildStatCard('⚠️', '3', 'Alerts', color: AppColors.accent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String icon, String value, String label, {Color? color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          children: [
            Text(icon, style: TextStyle(fontSize: 22, color: color)),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildQuickScanCard() {
    return GestureDetector(
      onTap: () => _pageController.jumpToPage(2),
      child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.accent, const Color(0xFFF5C040)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withOpacity(0.35),
                blurRadius: 32,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'QUICK ACTION',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Scan Rice Leaf',
                      style: TextStyle(
                        fontFamily: 'DM Serif Display',
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Detect disease instantly →',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.only(left: 12),
                child: const Text('🌿', style: TextStyle(fontSize: 64)),
              ),
            ],
        ),
      ),
    );
  }

  Widget _buildRecentAlerts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Alerts',
                style: TextStyle(
                  fontFamily: 'DM Serif Display',
                  fontSize: 22,
                  color: AppColors.text,
                ),
              ),
              GestureDetector(
                onTap: () => _pageController.jumpToPage(3),
                child: const Text(
                  'See all',
                  style: TextStyle(color: AppColors.green, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...initialAlerts.take(2).map((alert) => _buildAlertCard(alert)),
        ],
    );
  }

  Widget _buildAlertCard(Alert alert) {
    final rec = diseaseRecs[alert.disease] ?? diseaseRecs['Healthy']!;
    Color severityColor = alert.severity == 'High'
        ? AppColors.danger
        : alert.severity == 'Medium'
            ? AppColors.warn
            : AppColors.greenL;

    return CardWidget(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: severityColor.withOpacity(0.09),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text(rec.icon, style: const TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${alert.disease} detected',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppColors.text),
                ),
                const SizedBox(height: 2),
                Text(
                  '${alert.farmer} · ${alert.time}',
                  style: const TextStyle(fontSize: 14, color: AppColors.sub),
                ),
              ],
            ),
          ),
          TagWidget(text: alert.severity, color: severityColor),
        ],
      ),
    );
  }

  Widget _buildFarmersSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'My Farmers',
                style: TextStyle(
                  fontFamily: 'DM Serif Display',
                  fontSize: 22,
                  color: AppColors.text,
                ),
              ),
              GestureDetector(
                onTap: () => _pageController.jumpToPage(1),
                child: const Text(
                  'See all',
                  style: TextStyle(color: AppColors.green, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 145,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: initialFarmers.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final farmer = initialFarmers[index];
                final rec = diseaseRecs[farmer.disease] ?? diseaseRecs['Healthy']!;
                return Container(
                  width: 128,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border.withOpacity(0.6), width: 0.8),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.forest.withOpacity(0.04),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: AppColors.greenPale,
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: const Center(child: Text('👤', style: TextStyle(fontSize: 16))),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        farmer.name.split(' ').first,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.text),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        farmer.variety,
                        style: const TextStyle(fontSize: 13, color: AppColors.sub),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 8),
                      TagWidget(text: farmer.disease, color: rec.color),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    final tabs = [
      {'id': 0, 'label': 'Home', 'icon': '🏠'},
      {'id': 1, 'label': 'Farmers', 'icon': '👤'},
      {'id': 2, 'label': 'Scan', 'icon': '🔬', 'big': true},
      {'id': 3, 'label': 'Alerts', 'icon': '🔔'},
      {'id': 4, 'label': 'More', 'icon': '⋯'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border.withOpacity(0.5), width: 1)),
        boxShadow: [
          BoxShadow(
            color: AppColors.forest.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: tabs.map((tab) {
          final isSelected = _selectedIndex == tab['id'];
          final isBig = tab['big'] == true;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                _pageController.jumpToPage(tab['id'] as int);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isBig)
                      Transform.translate(
                        offset: const Offset(0, -22),
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.forest,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.forest.withOpacity(0.45),
                                blurRadius: 18,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Center(child: Text('🔬', style: TextStyle(fontSize: 22))),
                        ),
                      )
                    else
                      Opacity(
                        opacity: isSelected ? 1.0 : 0.38,
                        child: Text(tab['icon'] as String, style: const TextStyle(fontSize: 21)),
                      ),
                    if (!isBig) ...[
                      const SizedBox(height: 3),
                      Text(
                        tab['label'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                          color: isSelected ? AppColors.green : AppColors.sub,
                        ),
                      ),
                    ],
                    if (isSelected && !isBig)
                      Container(
                        width: 18,
                        height: 3,
                        margin: const EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          color: AppColors.green,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}