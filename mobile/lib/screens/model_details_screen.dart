import 'package:flutter/material.dart'; 
 
class ModelDetailsScreen extends StatelessWidget { 
  final Map<String, dynamic> model; 
   
  const ModelDetailsScreen({super.key, required this.model}); 
 
  @override 
  Widget build(BuildContext context) { 
    return Scaffold( 
      appBar: AppBar(title: Text(model['name'])), 
      body: SingleChildScrollView( 
        padding: const EdgeInsets.all(16), 
        child: Column( 
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [ 
            // Metrics Card 
            Card( 
              child: Padding( 
                padding: const EdgeInsets.all(16), 
                child: Column( 
                  crossAxisAlignment: CrossAxisAlignment.start, 
                  children: [ 
                    const Text('Performance Metrics', 
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), 
                    const SizedBox(height: 12), 
                    Row( 
                      mainAxisAlignment: MainAxisAlignment.spaceAround, 
                      children: [ 
                        _MetricColumn('Accuracy', '${(model['accuracy'] * 100).toStringAsFixed(1)}%'), 
                        _MetricColumn('F1-Score', model['f1Score'].toStringAsFixed(2)), 
                        _MetricColumn('Precision', model['precision'].toStringAsFixed(2)), 
                        _MetricColumn('Recall', model['recall'].toStringAsFixed(2)), 
                      ], 
                    ), 
                  ], 
                ), 
              ), 
            ), 
            const SizedBox(height: 16), 
             
            // Description 
            Card( 
              child: Padding( 
                padding: const EdgeInsets.all(16), 
                child: Column( 
                  crossAxisAlignment: CrossAxisAlignment.start, 
                  children: [ 
                    const Text('Description', 
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), 
                    const SizedBox(height: 8), 
                    Text(model['description']), 
                  ], 
                ), 
              ), 
            ), 
            const SizedBox(height: 16), 
             
            // Strengths & Weaknesses 
            Row( 
              children: [ 
                Expanded( 
                  child: Card( 
                    child: Padding( 
                      padding: const EdgeInsets.all(12), 
                      child: Column( 
                        crossAxisAlignment: CrossAxisAlignment.start, 
                        children: [ 
                          const Text('    Strengths', 
                              style: TextStyle(fontWeight: FontWeight.bold)), 
                          const SizedBox(height: 8), 
                          ...(model['strengths'] as List).map((s) => Padding( 
                                padding: const EdgeInsets.symmetric(vertical: 2), 
                                child: Text('• $s', style: const TextStyle(fontSize: 13)), 
                              )), 
                        ], 
                      ), 
                    ), 
                  ), 
                ), 
                const SizedBox(width: 8), 
                Expanded( 
                  child: Card( 
                    child: Padding( 
                      padding: const EdgeInsets.all(12), 
                      child: Column( 
                        crossAxisAlignment: CrossAxisAlignment.start, 
                        children: [ 
                          const Text('    Weaknesses', 
                              style: TextStyle(fontWeight: FontWeight.bold)), 
                          const SizedBox(height: 8), 
                          ...(model['weaknesses'] as List).map((w) => Padding( 
                                padding: const EdgeInsets.symmetric(vertical: 2), 
                                child: Text('• $w', style: const TextStyle(fontSize: 13)), 
                              )), 
                        ], 
                      ), 
                    ), 
                  ), 
                ), 
              ], 
            ), 
            const SizedBox(height: 16), 
             
            // Save button 
            SizedBox( 
              width: double.infinity, 
              child: ElevatedButton.icon( 
                icon: const Icon(Icons.favorite_border), 
                label: const Text('Save to Favourites'), 
                onPressed: () { 
                  ScaffoldMessenger.of(context).showSnackBar( 
                    const SnackBar(content: Text('Saved to favourites!')), 
                  ); 
                }, 
                style: ElevatedButton.styleFrom( 
                  backgroundColor: Colors.red, 
                  foregroundColor: Colors.white, 
                  padding: const EdgeInsets.symmetric(vertical: 14), 
                ), 
              ), 
            ), 
          ], 
        ), 
      ), 
    ); 
  } 
} 
 
class _MetricColumn extends StatelessWidget { 
  final String label, value; 
  const _MetricColumn(this.label, this.value); 
 
  @override 
  Widget build(BuildContext context) { 
    return Column( 
      children: [ 
        Text(value, 
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)), 
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)), 
      ], 
    ); 
  } 
} 