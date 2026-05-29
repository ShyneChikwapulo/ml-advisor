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
    } finally {
      setState(() => _loading = false);
    }
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
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: Colors.white,
          ),
        ),
        body: Column(
          children: [
            // Stats row
            if (!_loading)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    _StatCard('Models', _stats['models'] ?? 0, Icons.psychology, AppTheme.primary),
                    _StatCard('Papers', _stats['papers'] ?? 0, Icons.article, AppTheme.success),
                    _StatCard('Terms', _stats['glossary'] ?? 0, Icons.menu_book, AppTheme.warning),
                    _StatCard('Users', _stats['users'] ?? 0, Icons.people, AppTheme.secondary),
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

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  const _StatCard(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) => Expanded(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            child: Column(
              children: [
                Icon(icon, color: color, size: 20),
                Text('$value',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold, color: color)),
                Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
              ],
            ),
          ),
        ),
      );
}

// ── Models Tab ──────────────────────────────────────────────────────────────
class _ModelsTab extends StatefulWidget {
  const _ModelsTab();
  @override
  State<_ModelsTab> createState() => _ModelsTabState();
}

class _ModelsTabState extends State<_ModelsTab> {
  final _service = FirestoreService();
  late Future<List<MlModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getModels();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MlModel>>(
      future: _future,
      builder: (_, snap) {
        final models = snap.data ?? [];
        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: models.length,
          itemBuilder: (_, i) {
            final m = models[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 6),
              child: ListTile(
                title: Text(m.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Acc: ${(m.accuracy * 100).toStringAsFixed(0)}% · ${m.category}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await _service.deleteModel(m.id);
                    setState(() => _future = _service.getModels());
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ── Papers Tab ──────────────────────────────────────────────────────────────
class _PapersTab extends StatefulWidget {
  const _PapersTab();
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

  @override
  void initState() {
    super.initState();
    _future = _service.getPapers();
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Research Paper'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
              TextField(controller: _authorsCtrl, decoration: const InputDecoration(labelText: 'Authors')),
              TextField(controller: _yearCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Year')),
              TextField(controller: _findingsCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Key Findings')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await _service.addPaper(PaperModel(
                id: '',
                title: _titleCtrl.text,
                authors: _authorsCtrl.text,
                year: int.tryParse(_yearCtrl.text) ?? 2024,
                keyFindings: _findingsCtrl.text,
                modelsEvaluated: [],
              ));
              if (mounted) {
                Navigator.pop(context);
                setState(() => _future = _service.getPapers());
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add Paper'),
            onPressed: _showAddDialog,
          ),
        ),
        Expanded(
          child: FutureBuilder<List<PaperModel>>(
            future: _future,
            builder: (_, snap) {
              final papers = snap.data ?? [];
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: papers.length,
                itemBuilder: (_, i) {
                  final p = papers[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 6),
                    child: ListTile(
                      title: Text(p.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: Text('${p.authors} · ${p.year}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await _service.deletePaper(p.id);
                          setState(() => _future = _service.getPapers());
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Glossary Tab ─────────────────────────────────────────────────────────────
class _GlossaryTab extends StatefulWidget {
  const _GlossaryTab();
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
    _future = _service.getGlossary();
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Glossary Term'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _termCtrl, decoration: const InputDecoration(labelText: 'Term')),
            TextField(controller: _defCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Definition')),
            TextField(controller: _catCtrl, decoration: const InputDecoration(labelText: 'Category')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await _service.addGlossaryTerm(GlossaryTerm(
                id: '',
                term: _termCtrl.text,
                definition: _defCtrl.text,
                category: _catCtrl.text,
              ));
              if (mounted) {
                Navigator.pop(context);
                setState(() => _future = _service.getGlossary());
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add Term'),
            onPressed: _showAddDialog,
          ),
        ),
        Expanded(
          child: FutureBuilder<List<GlossaryTerm>>(
            future: _future,
            builder: (_, snap) {
              final terms = snap.data ?? [];
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: terms.length,
                itemBuilder: (_, i) {
                  final t = terms[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 6),
                    child: ListTile(
                      title: Text(t.term, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(t.definition, maxLines: 2, overflow: TextOverflow.ellipsis),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await _service.deleteGlossaryTerm(t.id);
                          setState(() => _future = _service.getGlossary());
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}