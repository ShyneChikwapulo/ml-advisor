import 'package:flutter/material.dart';
import 'model_details_screen.dart'; 

class ModelLibraryScreen extends StatelessWidget {
  final List<Map<String, String>> models = [
    {'name': 'Random Forest', 'description': 'Ensemble method, good for imbalanced data'},
    {'name': 'XGBoost', 'description': 'Gradient boosting, high accuracy'},
    {'name': 'SVM', 'description': 'Good for small datasets'},
    {'name': 'Logistic Regression', 'description': 'Simple and interpretable'},
    {'name': 'LSTM', 'description': 'Deep learning, best accuracy'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Model Library'),
        backgroundColor: Colors.blue,
      ),
      body: ListView.builder(
        itemCount: models.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(8),
            child: ListTile(
              title: Text(models[index]['name']!),
              subtitle: Text(models[index]['description']!),
              trailing: Icon(Icons.chevron_right),

              // ✅ FIXED: onTap is now inside ListTile
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ModelDetailsScreen(
                      model: models[index],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}