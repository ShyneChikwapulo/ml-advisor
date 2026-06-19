import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

const Color _goldAccent = Color(0xFFD4AF37);
const Color _matteBlackCanvas = Color(0xFF121212);

class ContactSupportScreen extends StatefulWidget {
  final UserModel currentUser;

  const ContactSupportScreen({super.key, required this.currentUser});

  @override
  State<ContactSupportScreen> createState() => _ContactSupportScreenState();
}

class _ContactSupportScreenState extends State<ContactSupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSubmitting = false;

  final List<Map<String, String>> _devGroupMembers = [
    {
      'name': 'Shine Chikwapulo',
      'role': 'Lead Software Architect',
      'email': 'chikwapuloshine@gmail.com',
    },
    {
      'name': 'Henno Sisulu',
      'role': 'Front End Lead',
      'email': 'enagbonglydie@gmail.com',
    },
    {
      'name': 'Jayden Durrheim',
      'role': 'UI/UX Infrastructure Engineer',
      'email': 'ui_dev@university.edu',
    },
    {
      'name': 'Nonkazimulo dube',
      'role': 'UI/UX Infrastructure Engineer',
      'email': 'EDUV4817991@vossie.net',
    },
  ];

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await FirebaseFirestore.instance.collection('support_tickets').add({
        'uid': widget.currentUser.uid,
        'senderName': widget.currentUser.displayName,
        'senderEmail': widget.currentUser.email,
        'subject': _subjectController.text.trim(),
        'message': _messageController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'open',
      });

      if (mounted) {
        _subjectController.clear();
        _messageController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text('Support ticket submitted successfully.',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text('Error: $e'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _matteBlackCanvas,
      appBar: AppBar(
        title: const Text(
          'Contact Support',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionLabel('Team Members'),
            
            ..._devGroupMembers.map((member) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _buildGlassmorphicContainer(
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: _goldAccent.withOpacity(0.1),
                      child: const Icon(Icons.person_outline, color: _goldAccent, size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(member['name']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 2),
                          Text(member['role']!, style: TextStyle(color: _goldAccent.withOpacity(0.8), fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                          const SizedBox(height: 4),
                          Text(member['email']!, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )),
            
            const SizedBox(height: 20),
            _buildSectionLabel('Submit Feedback'),
            
            _buildGlassmorphicContainer(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Send feedback or report issues. Your message will be stored in our support database.',
                      style: TextStyle(color: Colors.white60, fontSize: 12, height: 1.4),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _subjectController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'Subject is required.' : null,
                      decoration: _buildInputDecoration(label: 'Subject', icon: Icons.topic_outlined),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _messageController,
                      maxLines: 4,
                      style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'Message is required.' : null,
                      decoration: _buildInputDecoration(label: 'Message'),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _goldAccent,
                          foregroundColor: _matteBlackCanvas,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        onPressed: _isSubmitting ? null : _submitFeedback,
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20, width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(_matteBlackCanvas)),
                              )
                            : const Text('Submit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Text(
        label,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white38, letterSpacing: 1.5),
      ),
    );
  }

  Widget _buildGlassmorphicContainer({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: child,
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({required String label, IconData? icon}) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white.withOpacity(0.01),
      labelText: label,
      prefixIcon: icon != null ? Icon(icon, size: 18, color: Colors.white38) : null,
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
      floatingLabelStyle: const TextStyle(color: _goldAccent, fontWeight: FontWeight.bold, fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.06)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _goldAccent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }
}