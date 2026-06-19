import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:fl_chart/fl_chart.dart';
import '../../models/ml_model.dart';
import '../../models/paper_model.dart';
import '../../models/glossary_model.dart';
import '../../services/firestore_service.dart';
import '../../utils/app_theme.dart';
import '../../models/user_model.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/delete_confirmation_dialog.dart';


class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}



class _AdminDashboardScreenState extends State<AdminDashboardScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  final _service = FirestoreService();
  Map<String, int> _stats = {};
  List<Map<String, dynamic>> _historyData = [];
  bool _loading = true;

  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color blueAccent = Color(0xFF1565C0);
  static const Color matteBlackCanvas = Color(0xFF121212);
  static const Color darkInputSurface = Color(0xFF1A1A1A);



  double get _currentMaxX {
    if (_historyData.isEmpty) return 4;
    double highestX = 0;
    for (var entry in _historyData) {
      double x = (entry['monthIndex'] ?? 0).toDouble();
      if (x > highestX) highestX = x;
    }
    return highestX;
  }

  double get _currentMaxY {
    if (_historyData.isEmpty) return 12;
    double highestY = 0;
    
    for (var entry in _historyData) {
      final metrics = ['modelsCount', 'papersCount', 'glossaryCount', 'usersCount'];
      for (var key in metrics) {
        double val = (entry[key] ?? 0).toDouble();
        if (val > highestY) highestY = val;
      }
    }
    
    return highestY < 10 ? 12 : (highestY * 1.2);
  }

  Future<void> _loadDashboardData() async {
    setState(() => _loading = true);
    
    try {
      _stats = await _service.getAnalytics();
    } catch (e) {
      _stats = {'models': 8, 'papers': 3, 'glossary': 10, 'users': 4};
    }

    try {
      final data = await _service.getHistoricalAnalytics();
      if (data != null && data.isNotEmpty) {
        _historyData = data;
      } else {
        _loadHistoricalBackup();
      }
    } catch (e) {
      _loadHistoricalBackup();
    }

    setState(() => _loading = false);
  }

  void _loadHistoricalBackup() {
    _historyData = [
      {'monthIndex': 0, 'modelsCount': 2, 'papersCount': 1, 'glossaryCount': 3, 'usersCount': 1},
      {'monthIndex': 1, 'modelsCount': 5, 'papersCount': 2, 'glossaryCount': 6, 'usersCount': 2},
      {'monthIndex': 2, 'modelsCount': 4, 'papersCount': 2, 'glossaryCount': 8, 'usersCount': 2},
      {'monthIndex': 3, 'modelsCount': 7, 'papersCount': 3, 'glossaryCount': 9, 'usersCount': 3},
      {'monthIndex': 4, 'modelsCount': 8, 'papersCount': 3, 'glossaryCount': 10, 'usersCount': 4},
    ];
  }




  List<FlSpot> _getChartSpots(String key) {
    if (_historyData.isEmpty) {
        return [const FlSpot(0, 0)];
      }    

    return _historyData.map((e) {
      final double x = (e['monthIndex'] ?? 0).toDouble();
      final double y = (e[key] ?? 0).toDouble();
      return FlSpot(x, y);
    }).toList();
  }

  String _getGrowthPercentage(String key) {
    if (_historyData.length < 2) return '0%';

    List<Map<String, dynamic>> sortedData = List.from(_historyData);
    sortedData.sort((a, b) => (a['monthIndex'] ?? 0).compareTo(b['monthIndex'] ?? 0));

    final num latestValue = sortedData.last[key] ?? 0;
    final num previousValue = sortedData[sortedData.length - 2][key] ?? 0;

    if (previousValue == 0) {
      return latestValue > 0 ? '+100%' : '0%';
    }

    final double percentageChange = ((latestValue - previousValue) / previousValue) * 100;
    
    final String sign = percentageChange >= 0 ? '+' : '';
    return '$sign${percentageChange.toStringAsFixed(0)}%';
  }

  

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: LoadingOverlay(
        isLoading: _loading,
        loadingText: "Loading analytics...", 
        child: Scaffold(
          backgroundColor: matteBlackCanvas,
          body: SafeArea(
            bottom: false,
            child: NestedScrollView(
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                return [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── HEADER ──
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 16, 20, 8),
                          child: Row(
                            children: [
                              if (Navigator.canPop(context)) ...[
                                IconButton(
                                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                const SizedBox(width: 4),
                              ] else ...[
                                const SizedBox(width: 8),
                              ],
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ADMIN',
                                    style: TextStyle(
                                      color: blueAccent.withOpacity(0.85),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2.0,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Admin Dashboard',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        // ── STATS CARDS ──
                        if (!_loading)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 2,
                              childAspectRatio: 1.35,
                              mainAxisSpacing: 14,
                              crossAxisSpacing: 14,
                              children: [
                                _BubbleStatCard('Total Models', _stats['models'] ?? 0, _getGrowthPercentage('modelsCount'), Icons.psychology, const [Color(0xFF6A11CB), Color(0xFF2575FC)]),
                                _BubbleStatCard('Research Papers', _stats['papers'] ?? 0, _getGrowthPercentage('papersCount'), Icons.article, const [Color(0xFF11998e), Color(0xFF38ef7d)]),
                                _BubbleStatCard('Glossary Terms', _stats['glossary'] ?? 0, _getGrowthPercentage('glossaryCount'), Icons.menu_book, const [Color(0xFFf857a6), Color(0xFFff5858)]),
                                _BubbleStatCard('System Users', _stats['users'] ?? 0, _getGrowthPercentage('usersCount'), Icons.people, const [Color(0xFFe65c00), Color(0xFFF9D423)]),
                              ],
                            ),
                          ),

                        // ── GROWTH CHART ──
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.02),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.white.withOpacity(0.06)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Growth Over Time',
                                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 14,
                                  runSpacing: 6,
                                  children: [
                                    _LegendIndicator(label: 'Models', color: const Color(0xFF2575FC)),
                                    _LegendIndicator(label: 'Papers', color: const Color(0xFF38ef7d)),
                                    _LegendIndicator(label: 'Glossary', color: const Color(0xFFf857a6)),
                                    _LegendIndicator(label: 'Users', color: const Color(0xFFF9D423)),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  height: 180,
                                  child: LineChart(
                                    LineChartData(
                                      minX: 0,
                                      maxX: _currentMaxX,
                                      minY: 0,
                                      maxY: _currentMaxY,
                                      gridData: FlGridData(
                                        show: true,
                                        drawVerticalLine: false,
                                        getDrawingHorizontalLine: (val) => FlLine(color: Colors.white.withOpacity(0.03), strokeWidth: 1),
                                      ),
                                      titlesData: FlTitlesData(
                                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 40,
                                            getTitlesWidget: (v, _) => Text('${v.toInt()}', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10)),
                                          ),
                                        ),
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            interval: 1,
                                            getTitlesWidget: (v, _) {
                                              final yearMonths = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                                              int index = v.toInt();
                                              
                                              if (index < 0 || index >= yearMonths.length) return const Text('');
                                              
                                              return Padding(
                                                padding: const EdgeInsets.only(top: 8.0),
                                                child: Text(
                                                  yearMonths[index], 
                                                  style: TextStyle(
                                                    color: Colors.white.withOpacity(0.4), 
                                                    fontSize: 10, 
                                                    fontWeight: FontWeight.bold
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      borderData: FlBorderData(show: false),
                                      lineBarsData: [
                                        _generateLineBarBarData(_getChartSpots('modelsCount'), const Color(0xFF2575FC)),
                                        _generateLineBarBarData(_getChartSpots('papersCount'), const Color(0xFF38ef7d)),
                                        _generateLineBarBarData(_getChartSpots('glossaryCount'), const Color(0xFFf857a6)),
                                        _generateLineBarBarData(_getChartSpots('usersCount'), const Color(0xFFF9D423)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverTabBarDelegate(
                      TabBar(
                        isScrollable: false,
                        tabs: const [
                          Tab(text: 'Models'),
                          Tab(text: 'Papers'),
                          Tab(text: 'Glossary'),
                          Tab(text: 'Users'),
                        ],
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.white.withOpacity(0.4),
                        indicatorColor: blueAccent,
                        indicatorWeight: 2,
                        indicatorSize: TabBarIndicatorSize.label,
                        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.3),
                      ),
                    ),
                  ),
                ];
              },
              body: TabBarView(
                children: [
                  _ModelsTab(onRefreshMetrics: _loadDashboardData),
                  _PapersTab(onRefreshMetrics: _loadDashboardData),
                  _GlossaryTab(onRefreshMetrics: _loadDashboardData),
                  _UsersTab(onRefreshMetrics: _loadDashboardData),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  LineChartBarData _generateLineBarBarData(List<FlSpot> spots, Color color) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: 2.5,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(show: false),
    );
  }
}

// ── STAT CARD ──
class _BubbleStatCard extends StatelessWidget {
  final String label;
  final int value;
  final String delta;
  final IconData icon;
  final List<Color> gradientColors;

  const _BubbleStatCard(this.label, this.value, this.delta, this.icon, this.gradientColors);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: CircleAvatar(
                radius: 55,
                backgroundColor: Colors.white.withOpacity(0.09),
              ),
            ),
            Positioned(
              right: 15,
              bottom: -25,
              child: CircleAvatar(
                radius: 35,
                backgroundColor: Colors.black.withOpacity(0.06),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: Colors.white, size: 18),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          delta,
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '$value',
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.5),
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        label,
                        style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.78), fontWeight: FontWeight.w600),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── FORM DECORATION ──
class _FormInputDecoration {
  static InputDecoration build({required String labelText}) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(color: Colors.white60, fontSize: 13),
      filled: true,
      fillColor: _AdminDashboardScreenState.darkInputSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 1.5),
      ),
    );
  }
}

class _LegendIndicator extends StatelessWidget {
  final String label;
  final Color color;
  const _LegendIndicator({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(

      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: const Color(0xFF121212),
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) => false;
}

// ── MODELS TAB ──
class _ModelsTab extends StatefulWidget {
  final VoidCallback onRefreshMetrics;
  const _ModelsTab({required this.onRefreshMetrics});
  @override
  State<_ModelsTab> createState() => _ModelsTabState();
}

class _ModelsTabState extends State<_ModelsTab> {
  final _service = FirestoreService();
  late Future<List<MlModel>> _future;

  final _nameCtrl = TextEditingController();
  final _accuracyCtrl = TextEditingController();
  final _f1Ctrl = TextEditingController();
  final _precisionCtrl = TextEditingController();
  final _recallCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  final _strengthsCtrl = TextEditingController();
  final _weaknessesCtrl = TextEditingController();
  final _useCasesCtrl = TextEditingController();

  final _datasetCtrl = TextEditingController();
  String? _selectedPaperId;

  String _category = 'Ensemble';
  bool _handlesImbalance = false;
  bool _interpretable = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _future = _service.getModels();
    });
  }

  void _showFormDialog({MlModel? existingModel}) {
    final bool isEdit = existingModel != null;
    
    if (isEdit) {
      _nameCtrl.text = existingModel.name;
      _accuracyCtrl.text = existingModel.accuracy.toString();
      _f1Ctrl.text = existingModel.f1Score.toString();
      _precisionCtrl.text = existingModel.precision.toString();
      _recallCtrl.text = existingModel.recall.toString();
      _descCtrl.text = existingModel.description;
      _category = existingModel.category;
      _handlesImbalance = existingModel.handlesImbalance;
      _interpretable = existingModel.interpretable;
      
      _strengthsCtrl.text = existingModel.strengths.join(', ');
      _weaknessesCtrl.text = existingModel.weaknesses.join(', ');
      _useCasesCtrl.text = existingModel.bestUseCases.join(', ');
      
      _datasetCtrl.text = existingModel.datasetUsed;
      _selectedPaperId = existingModel.paperId.isEmpty ? null : existingModel.paperId;
    } else {
      _nameCtrl.clear(); _accuracyCtrl.clear(); _f1Ctrl.clear();
      _precisionCtrl.clear(); _recallCtrl.clear(); _descCtrl.clear();
      _strengthsCtrl.clear(); _weaknessesCtrl.clear(); _useCasesCtrl.clear();
      _datasetCtrl.clear();
      _selectedPaperId = null;
      _category = 'Ensemble'; _handlesImbalance = false; _interpretable = false;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF161616),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.white.withOpacity(0.08))),
          title: Text(isEdit ? 'Edit Model' : 'Add Model', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  TextField(controller: _nameCtrl, style: const TextStyle(color: Colors.white), decoration: _FormInputDecoration.build(labelText: 'Model Name')),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: _accuracyCtrl, style: const TextStyle(color: Colors.white), decoration: _FormInputDecoration.build(labelText: 'Accuracy'), keyboardType: TextInputType.number)),
                      const SizedBox(width: 10),
                      Expanded(child: TextField(controller: _f1Ctrl, style: const TextStyle(color: Colors.white), decoration: _FormInputDecoration.build(labelText: 'F1-Score'), keyboardType: TextInputType.number)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: _precisionCtrl, style: const TextStyle(color: Colors.white), decoration: _FormInputDecoration.build(labelText: 'Precision'), keyboardType: TextInputType.number)),
                      const SizedBox(width: 10),
                      Expanded(child: TextField(controller: _recallCtrl, style: const TextStyle(color: Colors.white), decoration: _FormInputDecoration.build(labelText: 'Recall'), keyboardType: TextInputType.number)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(controller: _descCtrl, maxLines: 2, style: const TextStyle(color: Colors.white), decoration: _FormInputDecoration.build(labelText: 'Description')),
                  
                  const SizedBox(height: 14),
                  TextField(controller: _datasetCtrl, style: const TextStyle(color: Colors.white), decoration: _FormInputDecoration.build(labelText: 'Dataset Used')),
                  
                  const SizedBox(height: 14),

                  FutureBuilder<List<PaperModel>>(
                    future: _service.getPapers(),
                    builder: (context, snapshot) {

                      final papersList = snapshot.data ?? [];
                      
                      String? selectedValue;
                      if (papersList.any((p) => p.id == _selectedPaperId)) {
                        selectedValue = _selectedPaperId;
                      }

                      return DropdownButtonFormField<String>(
                        value: selectedValue,
                        isExpanded: true,
                        dropdownColor: const Color(0xFF1A1A1A),
                        decoration: _FormInputDecoration.build(labelText: 'Source Research Paper'),
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        hint: const Text('Select Research Paper', style: TextStyle(color: Colors.white30, fontSize: 13)),
                        items: papersList.map((p) {
                                final String labelText = '${p.authors.split('&').first.trim()} (${p.year}) - ${p.title}';
                                
                                return DropdownMenuItem<String>(
                                  value: p.id,
                                  child: Text(
                                    labelText,
                                    style: const TextStyle(fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                );
                              }).toList(),
                              onChanged: (v) => setDialogState(() => _selectedPaperId = v),
                            );
                          },
                        ),
                  
                  const SizedBox(height: 14),

                  DropdownButtonFormField<String>(
                    value: _category,
                    dropdownColor: const Color(0xFF1A1A1A),
                    decoration: _FormInputDecoration.build(labelText: 'Category'),
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    items: ['Ensemble', 'Traditional', 'Deep Learning'].map((cat) {
                      return DropdownMenuItem<String>(
                        value: cat,
                        child: Text(cat, style: const TextStyle(fontSize: 13)),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setDialogState(() => _category = v);
                      }
                    },
                  ),
                  const SizedBox(height: 14),

                  TextField(controller: _strengthsCtrl, maxLines: 2, style: const TextStyle(color: Colors.white), decoration: _FormInputDecoration.build(labelText: 'Strengths (Comma Separated)')),
                  const SizedBox(height: 14),
                  TextField(controller: _weaknessesCtrl, maxLines: 2, style: const TextStyle(color: Colors.white), decoration: _FormInputDecoration.build(labelText: 'Weaknesses (Comma Separated)')),
                  const SizedBox(height: 14),
                  TextField(controller: _useCasesCtrl, maxLines: 2, style: const TextStyle(color: Colors.white), decoration: _FormInputDecoration.build(labelText: 'Best Use Cases (Comma Separated)')),
                  
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: const Text('Handles Imbalance', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    activeColor: _AdminDashboardScreenState.blueAccent,
                    value: _handlesImbalance,
                    onChanged: (v) => setDialogState(() => _handlesImbalance = v),
                  ),
                  SwitchListTile(
                    title: const Text('Interpretable', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    activeColor: _AdminDashboardScreenState.blueAccent,
                    value: _interpretable,
                    onChanged: (v) => setDialogState(() => _interpretable = v),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.white38))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _AdminDashboardScreenState.blueAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: () async {
                if (_nameCtrl.text.isEmpty) return;

                List<String> parseCommaString(String input) {
                  if (input.trim().isEmpty) return [];
                  return input.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                }

                final modelObj = MlModel(
                  id: isEdit ? existingModel.id : '',
                  name: _nameCtrl.text,
                  paperId: _selectedPaperId ?? '',
                  datasetUsed: _datasetCtrl.text.trim().isEmpty ? 'Unified Bug Dataset' : _datasetCtrl.text.trim(),
                  accuracy: double.tryParse(_accuracyCtrl.text) ?? 0.0,
                  f1Score: double.tryParse(_f1Ctrl.text) ?? 0.0,
                  precision: double.tryParse(_precisionCtrl.text) ?? 0.0,
                  recall: double.tryParse(_recallCtrl.text) ?? 0.0,
                  description: _descCtrl.text,
                  category: _category,
                  handlesImbalance: _handlesImbalance,
                  interpretable: _interpretable,
                  strengths: parseCommaString(_strengthsCtrl.text),
                  weaknesses: parseCommaString(_weaknessesCtrl.text),
                  bestUseCases: parseCommaString(_useCasesCtrl.text),
                );

                if (isEdit) {
                  await _service.updateModel(existingModel.id, modelObj);
                } else {
                  await _service.addModel(modelObj);
                }
                
                if (mounted) {
                  Navigator.pop(context);
                  _refresh();
                  widget.onRefreshMetrics(); 
                }
              },
              child: Text(isEdit ? 'Save Changes' : 'Add Model', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MlModel>>(
      future: _future,
      builder: (_, snap) {
        final models = snap.data ?? [];
        
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
          itemCount: models.length + 1, 
          itemBuilder: (_, i) {
            if (i == 0) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.04), 
                    side: BorderSide(color: Colors.white.withOpacity(0.08)), 
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)
                  ),
                  icon: const Icon(Icons.add, color: Color(0xFFD4AF37)),
                  label: const Text('Add Model', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  onPressed: () => _showFormDialog(),
                ),
              );
            }

            final m = models[i - 1]; 
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.02),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                title: Text(m.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                subtitle: Text('Acc: ${(m.accuracy * 100).toStringAsFixed(0)}% · ${m.category}', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 20), onPressed: () => _showFormDialog(existingModel: m)),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                      onPressed: () => showDeleteConfirmationDialog(
                        context,
                        title: 'Delete Model',
                        message: 'Are you sure you want to delete "${m.name}"? This action cannot be undone.',
                        onConfirm: () async {
                          await _service.deleteModel(m.id);
                          _refresh();
                          widget.onRefreshMetrics();
                        }
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ── PAPERS TAB ──
class _PapersTab extends StatefulWidget {
  final VoidCallback onRefreshMetrics;
  const _PapersTab({required this.onRefreshMetrics});
  @override
  State<_PapersTab> createState() => _PapersTabState();
}

class _PapersTabState extends State<_PapersTab> {
  final _service = FirestoreService();
  late Future<List<PaperModel>> _future;
  
  final _titleCtrl = TextEditingController();
  final _authorsCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _findingsCtrl = TextEditingController();
  final _modelsEvaluatedCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _future = _service.getPapers();
    });
  }

  void _showFormDialog({PaperModel? existingPaper}) {
    final bool isEdit = existingPaper != null;

    if (isEdit) {
      _titleCtrl.text = existingPaper.title;
      _authorsCtrl.text = existingPaper.authors;
      _yearCtrl.text = existingPaper.year.toString();
      _findingsCtrl.text = existingPaper.keyFindings;
      _modelsEvaluatedCtrl.text = existingPaper.modelsEvaluated.join(', ');
    } else {
      _titleCtrl.clear(); 
      _authorsCtrl.clear(); 
      _yearCtrl.clear(); 
      _findingsCtrl.clear();
      _modelsEvaluatedCtrl.clear();
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF161616),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.white.withOpacity(0.08))),
        title: Text(isEdit ? 'Edit Paper' : 'Add Paper', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                TextField(controller: _titleCtrl, style: const TextStyle(color: Colors.white), decoration: _FormInputDecoration.build(labelText: 'Title')),
                const SizedBox(height: 14),
                TextField(controller: _authorsCtrl, style: const TextStyle(color: Colors.white), decoration: _FormInputDecoration.build(labelText: 'Authors')),
                const SizedBox(height: 14),
                TextField(controller: _yearCtrl, style: const TextStyle(color: Colors.white), keyboardType: TextInputType.number, decoration: _FormInputDecoration.build(labelText: 'Year')),
                const SizedBox(height: 14),
                TextField(controller: _findingsCtrl, style: const TextStyle(color: Colors.white), maxLines: 3, decoration: _FormInputDecoration.build(labelText: 'Key Findings')),
                
                const SizedBox(height: 14),
                TextField(
                  controller: _modelsEvaluatedCtrl, 
                  style: const TextStyle(color: Colors.white), 
                  maxLines: 2,
                  decoration: _FormInputDecoration.build(labelText: 'Models Evaluated (Comma Separated)'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.white38))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _AdminDashboardScreenState.blueAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () async {
              if (_titleCtrl.text.isEmpty) return;

              List<String> parseCommaString(String input) {
                if (input.trim().isEmpty) return [];
                return input.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
              }

              final paperObj = PaperModel(
                id: isEdit ? existingPaper.id : '',
                title: _titleCtrl.text,
                authors: _authorsCtrl.text,
                year: int.tryParse(_yearCtrl.text) ?? 2026,
                keyFindings: _findingsCtrl.text,
                modelsEvaluated: parseCommaString(_modelsEvaluatedCtrl.text),
              );

              if (isEdit) {
                await _service.updatePaper(existingPaper.id, paperObj);
              } else {
                await _service.addPaper(paperObj);
              }

              if (mounted) {
                Navigator.pop(context);
                _refresh();
                widget.onRefreshMetrics();
              }
            },
            child: Text(isEdit ? 'Save Changes' : 'Add Paper', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PaperModel>>(
      future: _future,
      builder: (_, snap) {
        final papers = snap.data ?? [];
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
          itemCount: papers.length + 1,
          itemBuilder: (_, i) {
            if (i == 0) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.04), side: BorderSide(color: Colors.white.withOpacity(0.08)), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                  icon: const Icon(Icons.add, color: AppTheme.success),
                  label: const Text('Add Paper', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  onPressed: () => _showFormDialog(),
                ),
              );
            }

            final p = papers[i - 1];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.02),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                title: Text(p.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                subtitle: Text('${p.authors} · ${p.year}', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 20), onPressed: () => _showFormDialog(existingPaper: p)),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                      onPressed: () => showDeleteConfirmationDialog(
                        context,
                        title: 'Delete Paper',
                        message: 'Are you sure you want to delete "${p.title}"? This action cannot be undone.',
                        onConfirm: () async {
                          await _service.deletePaper(p.id);
                          _refresh();
                          widget.onRefreshMetrics();
                        }
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ── GLOSSARY TAB ──
class _GlossaryTab extends StatefulWidget {
  final VoidCallback onRefreshMetrics;
  const _GlossaryTab({required this.onRefreshMetrics});
  @override
  State<_GlossaryTab> createState() => _GlossaryTabState();
}

class _GlossaryTabState extends State<_GlossaryTab> {
  final _service = FirestoreService();
  late Future<List<GlossaryTerm>> _future;
  final _termCtrl = TextEditingController();
  final _defCtrl = TextEditingController();
  final _catCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _future = _service.getGlossary();
    });
  }

  void _showFormDialog({GlossaryTerm? existingTerm}) {
    final bool isEdit = existingTerm != null;

    if (isEdit) {
      _termCtrl.text = existingTerm.term;
      _defCtrl.text = existingTerm.definition;
      _catCtrl.text = existingTerm.category;
    } else {
      _termCtrl.clear(); _defCtrl.clear(); _catCtrl.clear();
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF161616),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.white.withOpacity(0.08))),
        title: Text(isEdit ? 'Edit Term' : 'Add Term', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              TextField(controller: _termCtrl, style: const TextStyle(color: Colors.white), decoration: _FormInputDecoration.build(labelText: 'Term')),
              const SizedBox(height: 14),
              TextField(controller: _defCtrl, style: const TextStyle(color: Colors.white), maxLines: 3, decoration: _FormInputDecoration.build(labelText: 'Definition')),
              const SizedBox(height: 14),
              TextField(controller: _catCtrl, style: const TextStyle(color: Colors.white), decoration: _FormInputDecoration.build(labelText: 'Category')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.white38))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _AdminDashboardScreenState.blueAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () async {
              final termObj = GlossaryTerm(
                id: isEdit ? existingTerm.id : '',
                term: _termCtrl.text,
                definition: _defCtrl.text,
                category: _catCtrl.text,
              );

              if (isEdit) {
                await _service.updateGlossaryTerm(existingTerm.id, termObj);
              } else {
                await _service.addGlossaryTerm(termObj);
              }

              if (mounted) {
                Navigator.pop(context);
                _refresh();
                widget.onRefreshMetrics();
              }
            },
            child: Text(isEdit ? 'Save Changes' : 'Add Term', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<GlossaryTerm>>(
      future: _future,
      builder: (_, snap) {
        final terms = snap.data ?? [];
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
          itemCount: terms.length + 1,
          itemBuilder: (_, i) {
            if (i == 0) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.04), side: BorderSide(color: Colors.white.withOpacity(0.08)), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                  icon: const Icon(Icons.add, color: Color(0xFFD4AF37)),
                  label: const Text('Add Term', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  onPressed: () => _showFormDialog(),
                ),
              );
            }

            final t = terms[i - 1];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.02),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                title: Text(t.term, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                subtitle: Text(t.definition, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 20), onPressed: () => _showFormDialog(existingTerm: t)),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                      onPressed: () => showDeleteConfirmationDialog(
                        context,
                        title: 'Delete Term',
                        message: 'Are you sure you want to delete "${t.term}"? This action cannot be undone.',
                        onConfirm: () async {
                          await _service.deleteGlossaryTerm(t.id);
                          _refresh();
                          widget.onRefreshMetrics();
                        }
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ── USERS TAB ──
class _UsersTab extends StatefulWidget {
  final VoidCallback onRefreshMetrics;
  const _UsersTab({required this.onRefreshMetrics});
  @override
  State<_UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<_UsersTab> {
  final _service = FirestoreService();
  late Future<List<UserModel>> _future;

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _linkedinCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _future = _service.getUsers();
    });
  }

  void _showFormDialog({UserModel? existingUser}) {
    final bool isEdit = existingUser != null;

    if (isEdit) {
      _nameCtrl.text = existingUser.displayName;
      _emailCtrl.text = existingUser.email;
      _addressCtrl.text = existingUser.physicalAddress;
      _linkedinCtrl.text = existingUser.linkedinUrl;
    } else {
      _nameCtrl.clear(); _emailCtrl.clear(); _addressCtrl.clear(); _linkedinCtrl.clear();
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF161616),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.white.withOpacity(0.08))),
        title: Text(isEdit ? 'Edit User' : 'Add User', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                TextField(controller: _nameCtrl, style: const TextStyle(color: Colors.white), decoration: _FormInputDecoration.build(labelText: 'Name')),
                const SizedBox(height: 14),
                TextField(controller: _emailCtrl, style: const TextStyle(color: Colors.white), decoration: _FormInputDecoration.build(labelText: 'Email'), keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 14),
                TextField(controller: _addressCtrl, style: const TextStyle(color: Colors.white), maxLines: 2, decoration: _FormInputDecoration.build(labelText: 'Address')),
                const SizedBox(height: 14),
                TextField(controller: _linkedinCtrl, style: const TextStyle(color: Colors.white), decoration: _FormInputDecoration.build(labelText: 'LinkedIn')),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.white38))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _AdminDashboardScreenState.blueAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () async {
              if (_nameCtrl.text.isEmpty || _emailCtrl.text.isEmpty) return;
              
              final userObj = UserModel(
                uid: isEdit ? existingUser.uid : '',
                displayName: _nameCtrl.text,
                email: _emailCtrl.text,
                role: isEdit ? existingUser.role : 'Student',
                physicalAddress: _addressCtrl.text,
                linkedinUrl: _linkedinCtrl.text,

                phoneNumber: isEdit ? existingUser.phoneNumber : '',
                avatarIndex: isEdit ? existingUser.avatarIndex : -1,
                hasCompletedOnboarding: isEdit ? existingUser.hasCompletedOnboarding : false,
                experienceLevel: isEdit ? existingUser.experienceLevel : '',
                interests: isEdit ? existingUser.interests : const [],
                enableTips: isEdit ? existingUser.enableTips : true,
                bio: isEdit ? existingUser.bio : '',
                githubUsername: isEdit ? existingUser.githubUsername : '',
                techStack: isEdit ? existingUser.techStack : const [],
                createdAt: isEdit ? existingUser.createdAt : DateTime.now(),                
              );

              if (isEdit) {
                await _service.updateUser(existingUser.uid, userObj);
              } else {
                await _service.addUser(userObj);
              }

              if (mounted) {
                Navigator.pop(context);
                _refresh();
                widget.onRefreshMetrics();
              }
            },
            child: Text(isEdit ? 'Save Changes' : 'Add User', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<UserModel>>(
      future: _future,
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(_AdminDashboardScreenState.blueAccent)));
        }
        
        final users = snap.data ?? [];

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
          itemCount: users.isEmpty ? 2 : users.length + 1,
          itemBuilder: (_, i) {
            if (i == 0) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.04), side: BorderSide(color: Colors.white.withOpacity(0.08)), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                  icon: const Icon(Icons.person_add, color: _AdminDashboardScreenState.blueAccent),
                  label: const Text('Add User', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  onPressed: () => _showFormDialog(),
                ),
              );
            }

            if (users.isEmpty) {
              return Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Center(child: Text('No users found.', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 13))),
              );
            }

            final u = users[i - 1];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.02),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.05),
                  child: Text(
                    u.displayName.isNotEmpty ? u.displayName.substring(0, 1).toUpperCase() : 'U',
                    style: const TextStyle(color: _AdminDashboardScreenState.blueAccent, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(u.displayName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                subtitle: Text(u.email, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 20), onPressed: () => _showFormDialog(existingUser: u)),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                      onPressed: () => showDeleteConfirmationDialog(
                        context,
                        title: 'Delete User',
                        message: 'Are you sure you want to delete "${u.displayName}"? This action cannot be undone.',
                        onConfirm: () async {
                          await _service.deleteUser(u.uid);
                          _refresh();
                          widget.onRefreshMetrics();
                        }
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}