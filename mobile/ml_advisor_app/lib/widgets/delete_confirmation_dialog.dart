import 'package:flutter/material.dart';

Future<void> showDeleteConfirmationDialog(
  BuildContext context, {
  required String title,
  required String message,
  required VoidCallback onConfirm,
}) {
  return showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFF1C1C1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
      ),
      content: Text(
        message,
        style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  );
}