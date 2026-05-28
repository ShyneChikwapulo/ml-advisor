import 'package:flutter/material.dart';
import '../../models/ml_model.dart';
import '../../models/paper_model.dart';
import '../../models/glossary_model.dart';
import '../../services/firestore_service.dart';
import '../../utils/app_theme.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _service = FirestoreService();

  Map<String, int> _stats = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _loading = true);

    try {
      _stats = await _service.getAnalytics();
    } catch (_) {
      _stats = {'models': 8, 'papers': 3, 'glossary': 10, 'users': 0};
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Models'),
              Tab(text: 'Papers'),
              Tab(text: 'Glossary'),
            ],
          ),
        ),
        body: Column(
          children: [
            if (!_loading)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    _StatCard(
                      label: 'Models',
                      value: _stats['models'] ?? 0,
                      icon: Icons.psychology,
                      color: AppTheme.primary,
                    ),
                    _StatCard(
                      label: 'Papers',
                      value: _stats['papers'] ?? 0,
                      icon: Icons.article,
                      color: AppTheme.success,
                    ),
                    _StatCard(
                      label: 'Terms',
                      value: _stats['glossary'] ?? 0,
                      icon: Icons.menu_book,
                      color: AppTheme.warning,
                    ),
                    _StatCard(
                      label: 'Users',
                      value: _stats['users'] ?? 0,
                      icon: Icons.people,
                      color: AppTheme.secondary,
                    ),
                  ],
                ),
              ),
            const Expanded(
              child: TabBarView(
                children: [
                  _ModelsTab(),
                  _PapersTab(),
                  _GlossaryTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- STATS CARD ----------------

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 4),
              Text(
                '$value',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(label, style: const TextStyle(fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}
