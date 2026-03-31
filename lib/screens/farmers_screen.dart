import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/card_widget.dart';
import '../widgets/top_bar.dart';
import '../widgets/input_field.dart';
import '../widgets/button_widget.dart';
import '../widgets/tag_widget.dart';
import 'package:image_picker/image_picker.dart';
import '../models/disease_rec.dart';
import '../models/farmer.dart';

class FarmersScreen extends StatefulWidget {
  final List<Farmer> farmers;

  const FarmersScreen({super.key, required this.farmers});

  @override
  State<FarmersScreen> createState() => _FarmersScreenState();
}

class _FarmersScreenState extends State<FarmersScreen> {
  String _subPage = 'list';
  Farmer? _selectedFarmer;
  final Map<String, String> _form = {
    'name': '', 'phone': '', 'location': '', 'district': '', 'area': '', 'variety': '',
  };
  final TextEditingController _searchController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<Farmer> _filteredFarmers = [];

  @override
  void initState() {
    super.initState();
    _filteredFarmers = List.from(widget.farmers);
    _searchController.addListener(_filterFarmers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterFarmers() {
    setState(() {
      _filteredFarmers = widget.farmers.where((f) =>
          f.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          (f.location?.toLowerCase().contains(_searchController.text.toLowerCase()) ?? false)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_subPage == 'add') return _buildAddScreen();
    if (_subPage == 'detail' && _selectedFarmer != null) return _buildDetailScreen();
    return _buildListScreen();
  }

  Widget _buildListScreen() {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            TopBar(
              title: 'Farmers',
              right: GestureDetector(
                onTap: () => setState(() => _subPage = 'add'),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.forest,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(child: Text('+', style: TextStyle(fontSize: 22, color: Colors.white))),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 100),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.8),
                        border: Border.all(color: AppColors.border.withOpacity(0.9), width: 1.0),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(color: AppColors.forest.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search farmers...',
                          hintStyle: TextStyle(color: AppColors.sub, fontSize: 14),
                          prefixIcon: Text('🔍', style: TextStyle(fontSize: 15)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Expanded(
                      child: ListView.separated(
                        itemCount: _filteredFarmers.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final f = _filteredFarmers[index];
                          final rec = diseaseRecs[f.disease] ?? diseaseRecs['Healthy']!;
                          return CardWidget(
                            onTap: () => setState(() {
                              _selectedFarmer = f;
                              _subPage = 'detail';
                            }),
                            child: Row(
                              children: [
                                Container(
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    color: AppColors.greenPale,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Center(child: Text('👤', style: TextStyle(fontSize: 20))),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(f.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.text)),
                                      const SizedBox(height: 2),
                                      Text(
                                        '📍 ${f.location ?? f.district} · ${f.variety}',
                                        style: const TextStyle(fontSize: 14, color: AppColors.sub),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Last: ${f.lastScan} · ${f.scans} scans',
                                        style: const TextStyle(fontSize: 13, color: AppColors.sub),
                                      ),
                                    ],
                                  ),
                                ),
                                if (f.disease != 'None')
                                  TagWidget(text: f.disease, color: rec.color),
                                const SizedBox(width: 8),
                                const Text('›', style: TextStyle(fontSize: 20, color: AppColors.sub)),
                              ],
                            ),
                          );
                        },
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

  Widget _buildAddScreen() {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            TopBar(title: 'Add Farmer', onBack: () => setState(() => _subPage = 'list')),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 100),
                child: Column(
                  children: [
                    InputField(
                      label: 'Full Name',
                      icon: '✏️',
                      value: _form['name']!,
                      onChanged: (v) => _form['name'] = v,
                      placeholder: 'e.g. Kamal Perera',
                    ),
                    InputField(
                      label: 'Phone Number',
                      icon: '📞',
                      type: 'tel',
                      value: _form['phone']!,
                      onChanged: (v) => _form['phone'] = v,
                      placeholder: '07X-XXXXXXX',
                    ),
                    InputField(
                      label: 'Location / Village',
                      icon: '📍',
                      value: _form['location']!,
                      onChanged: (v) => _form['location'] = v,
                      placeholder: 'e.g. Anuradhapura North',
                    ),
                    InputField(
                      label: 'District',
                      icon: '🗺️',
                      value: _form['district']!,
                      onChanged: (v) => _form['district'] = v,
                      options: const [
                        'Anuradhapura', 'Polonnaruwa', 'Kurunegala', 'Kandy', 'Galle',
                        'Hambantota', 'Matale', 'Jaffna', 'Batticaloa'
                      ],
                    ),
                    InputField(
                      label: 'Area Size (acres)',
                      icon: '📐',
                      value: _form['area']!,
                      onChanged: (v) => _form['area'] = v,
                      placeholder: 'e.g. 3.5',
                    ),
                    InputField(
                      label: 'Rice Variety',
                      icon: '🌾',
                      value: _form['variety']!,
                      onChanged: (v) => _form['variety'] = v,
                      options: const [
                        'Suwandel', 'Nadu', 'Rathu Heenati', 'Bg 300', 'Bg 360',
                        'At 307', 'Ld 365', 'Bg 250', 'Pachchaperumal'
                      ],
                    ),
                    const SizedBox(height: 16),
                    ButtonWidget(
                      text: 'Save Farmer',
                      onPressed: () {
                        if (_form['name']!.isNotEmpty && _form['phone']!.isNotEmpty) {
                          Navigator.pop(context);
                        }
                      },
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

  Widget _buildDetailScreen() {
    final f = _selectedFarmer!;
    final rec = diseaseRecs[f.disease] ?? diseaseRecs['Healthy']!;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            TopBar(title: 'Farmer Profile', onBack: () => setState(() => _subPage = 'list')),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 100),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.forest, AppColors.green],
                        ),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(color: AppColors.forest.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10)),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: const Center(child: Text('👤', style: TextStyle(fontSize: 26))),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      f.name,
                                      style: const TextStyle(
                                        fontFamily: 'DM Serif Display',
                                        fontSize: 28,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '📞 ${f.phone}',
                                      style: const TextStyle(color: Colors.white60, fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              _buildInfoTile('📍 Location', f.location ?? f.district),
                              const SizedBox(width: 10),
                              _buildInfoTile('🌾 Variety', f.variety),
                              const SizedBox(width: 10),
                              _buildInfoTile('📐 Area', f.area),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: CardWidget(
                            child: Column(
                              children: [
                                Text(f.scans.toString(), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.green)),
                                const Text('Total Scans', style: TextStyle(fontSize: 14, color: AppColors.sub)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CardWidget(
                            child: Column(
                              children: [
                                Text(f.lastScan, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.accent)),
                                const Text('Last Scan', style: TextStyle(fontSize: 14, color: AppColors.sub)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (f.disease != 'None')
                      Padding(
                        padding: const EdgeInsets.only(top: 18),
                        child: CardWidget(
                          backgroundColor: AppColors.dangerPale,
                          child: Row(
                            children: [
                              const Text('⚠️ ', style: TextStyle(fontSize: 16)),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Active Disease', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.danger)),
                                  const SizedBox(height: 2),
                                  Text(f.disease, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.text)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 18),
                    ButtonWidget(
                      icon: '🔬',
                      text: 'Scan Leaf Now',
                      onPressed: () => _showScanOptions(context),
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

  void _showScanOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),),
            const SizedBox(height: 24),
            const Text(
              'Capture Leaf Image',
              style: TextStyle(fontFamily: 'DM Serif Display', fontSize: 24, color: AppColors.forest),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose a source to analyze this farmer\'s rice leaf',
              style: TextStyle(color: AppColors.sub, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                _buildPickerCard(context, 'Camera', '📸', ImageSource.camera),
                const SizedBox(width: 16),
                _buildPickerCard(context, 'Gallery', '🖼️', ImageSource.gallery),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerCard(BuildContext context, String title, String icon, ImageSource source) {
    return Expanded(
      child: GestureDetector(
        onTap: () async {
          Navigator.pop(context);
          try {
            final XFile? image = await _picker.pickImage(source: source);
            if (image != null) {
              _simulateAnalysis(context);
            } else {
              debugPrint('Image selection cancelled by user.');
            }
          } catch (e) {
            debugPrint('Error picking image: $e');
            // Show a friendly error snackbar
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Could not open ${title.toLowerCase()}. Please check your device settings or if you are on a simulator.'),
                  backgroundColor: AppColors.danger,
                ),
              );
            }
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: AppColors.greenPale,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.green.withOpacity(0.12)),
          ),
          child: Column(
            children: [
              Text(icon, style: const TextStyle(fontSize: 34)),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.forest, fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _simulateAnalysis(BuildContext context) {
    // Show a premium snackbar feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Text('🔍', style: TextStyle(fontSize: 18)),
            SizedBox(width: 12),
            Text('Leaf captured! Initializing AI scan...', style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        backgroundColor: AppColors.forest,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
            const SizedBox(height: 3),
            Text(
              value,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}