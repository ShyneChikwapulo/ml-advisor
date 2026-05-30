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

// ── Models Tab (FIX 3: Add Model + Edit Model) ─────────────────────────────
class _ModelsTab extends StatefulWidget {
  const _ModelsTab();
  @override
  State<_ModelsTab> createState() => _ModelsTabState();
}

class _ModelsTabState extends State<_ModelsTab> {
  final _service = FirestoreService();
  late Future<List<MlModel>> _future;

  // Controllers for Add/Edit forms
  final _nameCtrl = TextEditingController();
  final _accuracyCtrl = TextEditingController();
  final _f1Ctrl = TextEditingController();
  final _precisionCtrl = TextEditingController();
  final _recallCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
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

  void _showAddDialog() {
    _nameCtrl.clear();
    _accuracyCtrl.clear();
    _f1Ctrl.clear();
    _precisionCtrl.clear();
    _recallCtrl.clear();
    _descCtrl.clear();
    _category = 'Ensemble';
    _handlesImbalance = false;
    _interpretable = false;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add New Model'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: _accuracyCtrl, decoration: const InputDecoration(labelText: 'Accuracy'), keyboardType: TextInputType.number),
              TextField(controller: _f1Ctrl, decoration: const InputDecoration(labelText: 'F1-Score'), keyboardType: TextInputType.number),
              TextField(controller: _precisionCtrl, decoration: const InputDecoration(labelText: 'Precision'), keyboardType: TextInputType.number),
              TextField(controller: _recallCtrl, decoration: const InputDecoration(labelText: 'Recall'), keyboardType: TextInputType.number),
              TextField(controller: _descCtrl, decoration: const InputDecoration(labelText: 'Description')),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: const [
                  DropdownMenuItem(value: 'Ensemble', child: Text('Ensemble')),
                  DropdownMenuItem(value: 'Traditional', child: Text('Traditional')),
                  DropdownMenuItem(value: 'Deep Learning', child: Text('Deep Learning')),
                ],
                onChanged: (v) => setState(() => _category = v!),
              ),
              SwitchListTile(
                title: const Text('Handles Imbalance'),
                value: _handlesImbalance,
                onChanged: (v) => setState(() => _handlesImbalance = v),
              ),
              SwitchListTile(
                title: const Text('Interpretable'),
                value: _interpretable,
                onChanged: (v) => setState(() => _interpretable = v),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (_nameCtrl.text.isEmpty) return;
              final newModel = MlModel(
                id: '',
                name: _nameCtrl.text,
                accuracy: double.tryParse(_accuracyCtrl.text) ?? 0.0,
                f1Score: double.tryParse(_f1Ctrl.text) ?? 0.0,
                precision: double.tryParse(_precisionCtrl.text) ?? 0.0,
                recall: double.tryParse(_recallCtrl.text) ?? 0.0,
                description: _descCtrl.text,
                strengths: [],
                weaknesses: [],
                bestUseCases: [],
                category: _category,
                handlesImbalance: _handlesImbalance,
                interpretable: _interpretable,
              );
              await _service.addModel(newModel);
              if (mounted) {
                Navigator.pop(context);
                _refresh();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(MlModel model) {
    _nameCtrl.text = model.name;
    _accuracyCtrl.text = model.accuracy.toString();
    _f1Ctrl.text = model.f1Score.toString();
    _precisionCtrl.text = model.precision.toString();
    _recallCtrl.text = model.recall.toString();
    _descCtrl.text = model.description;
    _category = model.category;
    _handlesImbalance = model.handlesImbalance;
    _interpretable = model.interpretable;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Edit ${model.name}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: _accuracyCtrl, decoration: const InputDecoration(labelText: 'Accuracy'), keyboardType: TextInputType.number),
              TextField(controller: _f1Ctrl, decoration: const InputDecoration(labelText: 'F1-Score'), keyboardType: TextInputType.number),
              TextField(controller: _precisionCtrl, decoration: const InputDecoration(labelText: 'Precision'), keyboardType: TextInputType.number),
              TextField(controller: _recallCtrl, decoration: const InputDecoration(labelText: 'Recall'), keyboardType: TextInputType.number),
              TextField(controller: _descCtrl, decoration: const InputDecoration(labelText: 'Description')),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: const [
                  DropdownMenuItem(value: 'Ensemble', child: Text('Ensemble')),
                  DropdownMenuItem(value: 'Traditional', child: Text('Traditional')),
                  DropdownMenuItem(value: 'Deep Learning', child: Text('Deep Learning')),
                ],
                onChanged: (v) => setState(() => _category = v!),
              ),
              SwitchListTile(
                title: const Text('Handles Imbalance'),
                value: _handlesImbalance,
                onChanged: (v) => setState(() => _handlesImbalance = v),
              ),
              SwitchListTile(
                title: const Text('Interpretable'),
                value: _interpretable,
                onChanged: (v) => setState(() => _interpretable = v),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final updatedModel = MlModel(
                id: model.id,
                name: _nameCtrl.text,
                accuracy: double.tryParse(_accuracyCtrl.text) ?? model.accuracy,
                f1Score: double.tryParse(_f1Ctrl.text) ?? model.f1Score,
                precision: double.tryParse(_precisionCtrl.text) ?? model.precision,
                recall: double.tryParse(_recallCtrl.text) ?? model.recall,
                description: _descCtrl.text,
                strengths: model.strengths,
                weaknesses: model.weaknesses,
                bestUseCases: model.bestUseCases,
                category: _category,
                handlesImbalance: _handlesImbalance,
                interpretable: _interpretable,
              );
              await _service.updateModel(model.id, updatedModel);
              if (mounted) {
                Navigator.pop(context);
                _refresh();
              }
            },
            child: const Text('Save'),
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
            label: const Text('Add Model'),
            onPressed: _showAddDialog,
          ),
        ),
        Expanded(
          child: FutureBuilder<List<MlModel>>(
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
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showEditDialog(m),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await _service.deleteModel(m.id);
                              _refresh();
                            },
                          ),
                        ],
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

// ── Papers Tab (FIX 4: Add Edit Dialog) ────────────────────────────────────
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

  void _refresh() {
    setState(() {
      _future = _service.getPapers();
    });
  }

  void _showAddDialog() {
    _titleCtrl.clear();
    _authorsCtrl.clear();
    _yearCtrl.clear();
    _findingsCtrl.clear();

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
                _refresh();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(PaperModel paper) {
    _titleCtrl.text = paper.title;
    _authorsCtrl.text = paper.authors;
    _yearCtrl.text = paper.year.toString();
    _findingsCtrl.text = paper.keyFindings;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Research Paper'),
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
              final updatedPaper = PaperModel(
                id: paper.id,
                title: _titleCtrl.text,
                authors: _authorsCtrl.text,
                year: int.tryParse(_yearCtrl.text) ?? paper.year,
                keyFindings: _findingsCtrl.text,
                modelsEvaluated: paper.modelsEvaluated,
              );
              await _service.updatePaper(paper.id, updatedPaper);
              if (mounted) {
                Navigator.pop(context);
                _refresh();
              }
            },
            child: const Text('Save'),
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
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showEditDialog(p),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await _service.deletePaper(p.id);
                              _refresh();
                            },
                          ),
                        ],
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

// ── Glossary Tab (FIX 5: Add Edit Dialog) ──────────────────────────────────
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

  void _refresh() {
    setState(() {
      _future = _service.getGlossary();
    });
  }

  void _showAddDialog() {
    _termCtrl.clear();
    _defCtrl.clear();
    _catCtrl.clear();

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
                _refresh();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(GlossaryTerm term) {
    _termCtrl.text = term.term;
    _defCtrl.text = term.definition;
    _catCtrl.text = term.category;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Glossary Term'),
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
              final updatedTerm = GlossaryTerm(
                id: term.id,
                term: _termCtrl.text,
                definition: _defCtrl.text,
                category: _catCtrl.text,
              );
              await _service.updateGlossaryTerm(term.id, updatedTerm);
              if (mounted) {
                Navigator.pop(context);
                _refresh();
              }
            },
            child: const Text('Save'),
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
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showEditDialog(t),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await _service.deleteGlossaryTerm(t.id);
                              _refresh();
                            },
                          ),
                        ],
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