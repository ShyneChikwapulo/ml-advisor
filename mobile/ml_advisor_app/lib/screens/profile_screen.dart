import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// ✅ CLASH PROTECTION: Hiding the conflicting Firebase version of AuthProvider
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider; 
import '../providers/auth_provider.dart';
import '../models/user_model.dart';
import '../utils/app_theme.dart';
import 'admin/admin_dashboard_screen.dart';

// Unified Theme Tokens Shared across Components
const Color _goldAccent = Color(0xFFD4AF37);
const Color _matteBlackCanvas = Color(0xFF121212);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isUpdating = false;

  String _getAvatarPath(int index) {
    if (index < 0 || index > 10) return 'assets/images/avatars/avatar1.png';
    return 'assets/images/avatars/avatar${index + 1}.png';
  }

  Color _getRoleColor(String role) {
    switch (role.trim().toLowerCase()) {
      case 'admin': return Colors.redAccent;
      case 'developer': return Colors.blueAccent;
      default: return Colors.greenAccent;
    }
  }

  void _openEditProfileDialog(UserModel user) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true, // Keeps text fields responsive with the keyboard
        showDragHandle: true,     // Adds the native pill-shaped drag strip at the top
        useSafeArea: true,        // 🛡️ Guarantees it never slips under the status bar/notch
        backgroundColor: const Color(0xFF121212), // 💡 Swap with your exact app background color
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) {
          // Calculate 85% of the dynamic screen height to anchor the ceiling limit
          final double maxSheetHeight = MediaQuery.sizeOf(context).height * 0.85;

          return ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxSheetHeight),
            child: _EditProfileSheet(
              user: user,
              // ✅ PRESERVED: Your exact data payload pipelines
              onSave: (name, bio, avatarIndex, github, linkedin, phone, address) => 
                  _updateProfileDatabase(user.uid, name, bio, avatarIndex, github, linkedin, phone, address),
            ),
          );
        },
      );
    }

    // ✅ UPDATED: Added parameters to push Phone and Address directly into your Firestore pipeline
    Future<void> _updateProfileDatabase(
      String uid, String name, String bio, int avatarIdx, String github, String linkedin, String phone, String address
    ) async {
      setState(() => _isUpdating = true);
      try {
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'name': name.trim(),
          'bio': bio.trim(),
          'avatarIndex': avatarIdx,
          'githubUsername': github.trim(),
          'linkedinUrl': linkedin.trim(),
          'phoneNumber': phone.trim(),       // ✅ ADDED FIELD
          'physicalAddress': address.trim(), // ✅ ADDED FIELD
        });
        await context.read<AuthProvider>().refreshUserSession();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Telemetry profiles updated successfully.'))
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to broadcast updates: $e'))
        );
      } finally {
        if (mounted) setState(() => _isUpdating = false);
      }
    }

    // ── SECURE RE-AUTHENTICATION AND PASSWORD UPDATER ──
    void _openChangePasswordDialog(String email) {
      final currentPasswordController = TextEditingController();
      final newPasswordController = TextEditingController();
      final confirmPasswordController = TextEditingController();
      final dialogFormKey = GlobalKey<FormState>();
      bool isProcessing = false;

      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                backgroundColor: const Color(0xFF161616),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(color: Colors.white.withOpacity(0.08)),
                ),
                title: const Text(
                  'SECURITY IDENTIFICATION ACCESS',
                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                ),
                content: isProcessing 
                  ? const SizedBox(
                      height: 140,
                      child: Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(_goldAccent))),
                    )
                  : Form(
                      key: dialogFormKey,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'To change your password, Firebase requires authentication using your existing active keys.',
                              style: TextStyle(color: Colors.white60, fontSize: 12, height: 1.4),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: currentPasswordController,
                              obscureText: true,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                              decoration: _buildDialogInputDecoration('Current Password Verification'),
                              validator: (val) => (val == null || val.isEmpty) ? 'Current credentials required.' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: newPasswordController,
                              obscureText: true,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                              decoration: _buildDialogInputDecoration('New System Password'),
                              validator: (val) {
                                if (val == null || val.isEmpty) return 'New core key mapping required.';
                                if (val.length < 6) return 'Key must be at least 6 characters long.';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: confirmPasswordController,
                              obscureText: true,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                              decoration: _buildDialogInputDecoration('Confirm New System Password'),
                              validator: (val) {
                                if (val != newPasswordController.text) return 'Key tokens do not match structural mapping.';
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                actions: isProcessing ? [] : [
                  TextButton(
                    onPressed: () {
                      currentPasswordController.dispose();
                      newPasswordController.dispose();
                      confirmPasswordController.dispose();
                      Navigator.pop(context);
                    },
                    child: const Text('Abort Sequence', style: TextStyle(color: Colors.white38, fontSize: 13)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _goldAccent,
                      foregroundColor: _matteBlackCanvas,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      if (dialogFormKey.currentState!.validate()) {
                        setDialogState(() => isProcessing = true);
                        try {
                          User? firebaseUser = FirebaseAuth.instance.currentUser;
                          if (firebaseUser != null) {
                            AuthCredential credential = EmailAuthProvider.credential(
                              email: email.trim(),
                              password: currentPasswordController.text.trim(),
                            );
                            await firebaseUser.reauthenticateWithCredential(credential);
                            await firebaseUser.updatePassword(newPasswordController.text.trim());

                            currentPasswordController.dispose();
                            newPasswordController.dispose();
                            confirmPasswordController.dispose();
                            Navigator.pop(context);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Colors.green,
                                content: Text('Access credential update transaction successful.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            );
                          }
                        } catch (e) {
                          setDialogState(() => isProcessing = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.redAccent,
                              content: Text('Security rejected transaction: ${e.toString().split(']').last.trim()}'),
                            ),
                          );
                        }
                      }
                    },
                    child: const Text('Update Credentials', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ],
              );
            },
          );
        },
      );
    }

    InputDecoration _buildDialogInputDecoration(String label) {
      return InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.02),
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
        floatingLabelStyle: const TextStyle(color: _goldAccent, fontSize: 13, fontWeight: FontWeight.bold),
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

    @override
    Widget build(BuildContext context) {
      final authProvider = context.watch<AuthProvider>();
      final UserModel? user = authProvider.user;

      if (user == null) {
        return const Scaffold(
          backgroundColor: _matteBlackCanvas,
          body: Center(child: Text('No active profile mapping session detected.', style: TextStyle(color: Colors.white))),
        );
      }

      final String formattedJoinDate = user.createdAt != null 
          ? "${user.createdAt!.day}/${user.createdAt!.month}/${user.createdAt!.year}"
          : "N/A";

      return Scaffold(
        backgroundColor: _matteBlackCanvas,
        appBar: AppBar(
          title: const Text(
            'ENGINEER ECOSYSTEM PROFILE', 
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.5, color: Colors.white70)
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
        ),
        body: _isUpdating
            ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(_goldAccent)))
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 120.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── IDENTITY HEADER BLUR MATRIX CARD ──────────────────────
                    _buildGlassmorphicContainer(
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(color: _goldAccent.withOpacity(0.2), shape: BoxShape.circle),
                                child: CircleAvatar(
                                  radius: 54,
                                  backgroundColor: Colors.white10,
                                  backgroundImage: AssetImage(_getAvatarPath(user.avatarIndex)),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _openEditProfileDialog(user),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(color: _goldAccent, shape: BoxShape.circle),
                                  child: const Icon(Icons.edit_rounded, color: _matteBlackCanvas, size: 16),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 18),
                          Text(
                            user.displayName,
                            textAlign: TextAlign.center,
                            maxLines: 2, // ✅ Allows two lines max for complex corporate names
                            overflow: TextOverflow.ellipsis, // ✅ Truncates cleanly if they exceed two lines
                            style: const TextStyle(
                              fontSize: 22, // Slightly downscaled from 24 for optimal density
                              fontWeight: FontWeight.bold, 
                              color: Colors.white, 
                              letterSpacing: -0.5
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                            decoration: BoxDecoration(
                              color: _getRoleColor(user.role).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: _getRoleColor(user.role).withOpacity(0.3)),
                            ),
                            child: Text(
                              user.role.toUpperCase(),
                              style: TextStyle(color: _getRoleColor(user.role), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(user.email, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
                          if (user.bio.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Text(
                              '"${user.bio}"',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13, fontStyle: FontStyle.italic, height: 1.4),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── CARD 1: PROFILE INFO ───────────────────────────────────
                    _buildSectionLabel('PROFILE CORE INFO'),
                    _buildGlassmorphicContainer(
                      child: Column(
                        children: [
                          // ✅ UPDATED: Reading live variable instead of placeholder string
                          _buildRowDetail(
                            'Phone Number', 
                            user.phoneNumber.isNotEmpty ? user.phoneNumber : 'Not Provisioned', 
                            Icons.phone_iphone_rounded
                          ),
                          const Divider(height: 28, color: Colors.white10),
                          _buildRowDetail('Email Address', user.email, Icons.alternate_email_rounded),
                          const Divider(height: 28, color: Colors.white10),
                          // ✅ UPDATED: Reading live address configuration string variable
                          _buildRowDetail(
                            'Address', 
                            user.physicalAddress.isNotEmpty ? user.physicalAddress : 'Not Provisioned', 
                            Icons.location_on_rounded
                          ),
                          
                          if (user.githubUsername.isNotEmpty) ...[
                            const Divider(height: 28, color: Colors.white10),
                            _buildRowDetail('GitHub Profile', user.githubUsername, Icons.code_rounded),
                          ],
                          
                          if (user.linkedinUrl.isNotEmpty) ...[
                            const Divider(height: 28, color: Colors.white10),
                            _buildRowDetail('LinkedIn Link', user.linkedinUrl, Icons.link_rounded),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── CARD 2: ACCOUNT MATRIX ─────────────────────────────────
                    _buildSectionLabel('ACCOUNT ECOSYSTEM SPECS'),
                    _buildGlassmorphicContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildRowDetail('Registration Date', formattedJoinDate, Icons.calendar_today_rounded),
                          
                          if (user.interests.isNotEmpty) ...[
                            const Divider(height: 28, color: Colors.white10),
                            const Text('RESEARCH DOMAIN VECTORS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _goldAccent, letterSpacing: 1.5)),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8, runSpacing: 6,
                              children: user.interests.map((interest) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.04),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.white.withOpacity(0.06))
                                ),
                                child: Text(interest, style: const TextStyle(fontSize: 12, color: Colors.white70)),
                              )).toList(),
                            ),
                          ],

                          if (user.techStack.isNotEmpty) ...[
                            const Divider(height: 28, color: Colors.white10),
                            const Text('COMPILED ECOSYSTEM TOOLS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _goldAccent, letterSpacing: 1.5)),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8, runSpacing: 6,
                              children: user.techStack.map((tool) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _goldAccent.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: _goldAccent.withOpacity(0.2))
                                ),
                                child: Text(tool, style: const TextStyle(fontSize: 12, color: _goldAccent, fontWeight: FontWeight.bold)),
                              )).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── CARD 3: SECURITY CONTROLS ──────────────────────────────
                    _buildSectionLabel('SECURITY UTILITY GATEWAYS'),
                    _buildGlassmorphicContainer(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          if (user.role.trim().toLowerCase() == 'admin') ...[
                            _buildSettingsTile(
                              icon: Icons.admin_panel_settings_rounded,
                              title: 'Access Admin Dashboard Matrix',
                              iconColor: Colors.redAccent,
                              textColor: Colors.redAccent,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AdminDashboardScreen(),
                                  ),
                                );
                              },
                            ),
                            const Divider(height: 1, color: Colors.white10),
                          ],
                          _buildSettingsTile(
                            icon: Icons.security_rounded,
                            title: 'Two-Factor Authentication',
                            trailing: Text('[Configure Later]', style: TextStyle(color: _goldAccent.withOpacity(0.4), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                            onTap: () => _triggerStubNotification('MFA token registration terminal incoming.'),
                          ),
                          const Divider(height: 1, color: Colors.white10),
                          _buildSettingsTile(
                            icon: Icons.lock_reset_rounded,
                            title: 'Change Password',
                            onTap: () => _openChangePasswordDialog(user.email),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── CARD 4: SUPPORT & LOGOUT PANEL ─────────────────────────
                    _buildSectionLabel('NODE LIFECYCLE & CRADLE'),
                    _buildGlassmorphicContainer(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          _buildSettingsTile(
                            icon: Icons.help_outline_rounded,
                            title: 'Contact and Support Matrix',
                            trailing: const Text('[Adding Page Later]', style: TextStyle(color: Colors.white38, fontSize: 11, fontStyle: FontStyle.italic)),
                            onTap: () => _triggerStubNotification('Support matrix pipeline routing active soon.'),
                          ),
                          const Divider(height: 1, color: Colors.white10),
                          _buildSettingsTile(
                            icon: Icons.logout_rounded,
                            title: 'Terminate Active Node Session',
                            textColor: Colors.redAccent,
                            iconColor: Colors.redAccent,
                            onTap: () async => await authProvider.logout(),
                          ),
                        ],
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

    Widget _buildGlassmorphicContainer({required Widget child, EdgeInsetsGeometry? padding}) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: double.infinity,
          padding: padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.07)),
          ),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: child,
          ),
        ),
      );
    }

    Widget _buildRowDetail(String label, String balanceVal, IconData icon) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start, // ✅ Keeps icon aligned if text wraps
        children: [
          Icon(icon, size: 18, color: Colors.white38),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 13)),
          
          const SizedBox(width: 16), // ✅ Fixed separation boundary instead of Spacer
          
          Expanded(
            child: Text(
              balanceVal,
              textAlign: TextAlign.end, // ✅ Keeps data flush right
              overflow: TextOverflow.ellipsis, // ✅ Safely ends long text with "..." if out of room
              maxLines: 1, // ✅ Set to 2 if you want physical addresses to wrap downward instead
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
            ),
          ),
        ],
      );
    }

    Widget _buildSettingsTile({
      required IconData icon, 
      required String title, 
      required VoidCallback onTap,
      Color textColor = Colors.white,
      Color iconColor = Colors.white70,
      Widget? trailing,
    }) {
      return ListTile(
        leading: Icon(icon, color: iconColor, size: 20),
        title: Text(title, style: TextStyle(fontSize: 13, color: textColor)),
        trailing: trailing ?? (textColor == Colors.redAccent ? null : const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.white38)),
        onTap: onTap,
      );
    }

    void _triggerStubNotification(String detail) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.grey[900],
          content: Text(detail, style: const TextStyle(color: _goldAccent, fontWeight: FontWeight.bold)),
        ),
      );
    }
  }

// ── UTILITY DECORATION BUILDER FOR TEXT FIELDS ──────────────────────────────
InputDecoration _buildGlassInputDecoration({required String label, IconData? prefixIcon}) {
  return InputDecoration(
    filled: true,
    fillColor: Colors.white.withOpacity(0.01),
    labelText: label,
    prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 18, color: Colors.white38) : null,
    labelStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
    floatingLabelStyle: const TextStyle(color: _goldAccent, fontWeight: FontWeight.bold, fontSize: 13),
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.white.withOpacity(0.06)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: _goldAccent, width: 1.5),
    ),
  );
}

// ── STANDALONE GLASSMORPHIC RECONFIGURATION SHEET ───────────────────────────
class _EditProfileSheet extends StatefulWidget {
  final UserModel user;
  final Function(String name, String bio, int avatarIndex, String github, String linkedin, String phone, String address) onSave;

  const _EditProfileSheet({required this.user, required this.onSave});

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _githubController;
  late TextEditingController _linkedinController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late int _selectedAvatar;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.displayName);
    _bioController = TextEditingController(text: widget.user.bio);
    _githubController = TextEditingController(text: widget.user.githubUsername);
    _linkedinController = TextEditingController(text: widget.user.linkedinUrl);
    _phoneController = TextEditingController(text: widget.user.phoneNumber);
    _addressController = TextEditingController(text: widget.user.physicalAddress);
    _selectedAvatar = widget.user.avatarIndex;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _githubController.dispose();
    _linkedinController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  String _getAvatarPath(int index) => 'assets/images/avatars/avatar${index + 1}.png';

  @override
  Widget build(BuildContext context) {
    return Padding(
      // 🛡️ Handles defensive viewport padding when the virtual keyboard slides into frame
      padding: EdgeInsets.fromLTRB(0, 0, 0, MediaQuery.of(context).viewInsets.bottom),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF121212).withOpacity(0.90), // Matched base token layer
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.08), width: 1.5),
            ),
          ),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: SafeArea(
              top: false,
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  // Clean padding offset since native drag handle allocates its own top spacer
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 🗑️ REMOVED: Old hardcoded grey pill Container design block to fix double-handle glitch.
                      
                      const Text(
                        'SYSTEM PROFILE RECONFIGURATION',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _goldAccent, letterSpacing: 2.0),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Edit Node Identity',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.5),
                      ),
                      const SizedBox(height: 28),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: _goldAccent.withOpacity(0.15), shape: BoxShape.circle),
                          child: CircleAvatar(
                            radius: 48,
                            backgroundColor: Colors.white10,
                            backgroundImage: AssetImage(_getAvatarPath(_selectedAvatar)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'MATRIX IDENTITY REGISTRATION',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white38, letterSpacing: 1.5),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 64,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: 11,
                          itemBuilder: (context, index) {
                            final bool isSelected = _selectedAvatar == index;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedAvatar = index),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 6),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: isSelected ? _goldAccent : Colors.transparent, width: 2),
                                ),
                                child: CircleAvatar(radius: 26, backgroundImage: AssetImage(_getAvatarPath(index))),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        validator: (val) => (val == null || val.trim().isEmpty) ? 'Identity designation required.' : null,
                        decoration: _buildGlassInputDecoration(label: 'Display Designation Mapping', prefixIcon: Icons.person_outline_rounded),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _bioController,
                        maxLines: 2,
                        maxLength: 120,
                        style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
                        decoration: _buildGlassInputDecoration(label: 'Bio / Telemetry Objectives'),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: _buildGlassInputDecoration(label: 'Phone Number Mapping', prefixIcon: Icons.phone_iphone_rounded),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _addressController,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: _buildGlassInputDecoration(label: 'Physical Address Node Location', prefixIcon: Icons.location_on_rounded),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _githubController,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: _buildGlassInputDecoration(label: 'GitHub Username', prefixIcon: Icons.code_rounded),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _linkedinController,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: _buildGlassInputDecoration(label: 'LinkedIn Profile URL', prefixIcon: Icons.link_rounded),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _goldAccent,
                            foregroundColor: _matteBlackCanvas,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              widget.onSave(
                                _nameController.text,
                                _bioController.text,
                                _selectedAvatar,
                                _githubController.text,
                                _linkedinController.text,
                                _phoneController.text,   
                                _addressController.text, 
                              );
                              Navigator.pop(context);
                            }
                          },
                          child: const Text('COMMIT CHANGES', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0, fontSize: 13)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}