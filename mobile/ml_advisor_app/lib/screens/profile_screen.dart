import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider; 
import '../providers/auth_provider.dart';
import '../models/user_model.dart';
import '../utils/app_theme.dart';
import 'admin/admin_dashboard_screen.dart';
import 'contact_support_screen.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

const Color _goldAccent = Color(0xFFD4AF37);
const Color _blueAccent = Color(0xFF1565C0);
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
        isScrollControlled: true,
        showDragHandle: true,
        useSafeArea: true,
        backgroundColor: const Color(0xFF121212),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) {
          final double maxSheetHeight = MediaQuery.sizeOf(context).height * 0.85;
          return ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxSheetHeight),
            child: _EditProfileSheet(
              user: user,
              onSave: (name, bio, avatarIndex, github, linkedin, phone, address) => 
                  _updateProfileDatabase(user.uid, name, bio, avatarIndex, github, linkedin, phone, address),
            ),
          );
        },
      );
    }

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
          'phoneNumber': phone.trim(),
          'physicalAddress': address.trim(),
        });
        await context.read<AuthProvider>().refreshUserSession();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully.'))
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e'))
        );
      } finally {
        if (mounted) setState(() => _isUpdating = false);
      }
    }

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
                  'Change Password',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                content: isProcessing 
                  ? const SizedBox(
                      height: 140,
                      child: Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(_blueAccent))),
                    )
                  : Form(
                      key: dialogFormKey,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Enter your current password and choose a new one.',
                              style: TextStyle(color: Colors.white60, fontSize: 13, height: 1.4),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: currentPasswordController,
                              obscureText: true,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                              decoration: _buildDialogInputDecoration('Current Password'),
                              validator: (val) => (val == null || val.isEmpty) ? 'Current password required.' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: newPasswordController,
                              obscureText: true,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                              decoration: _buildDialogInputDecoration('New Password'),
                              validator: (val) {
                                if (val == null || val.isEmpty) return 'New password required.';
                                if (val.length < 6) return 'Password must be at least 6 characters.';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: confirmPasswordController,
                              obscureText: true,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                              decoration: _buildDialogInputDecoration('Confirm New Password'),
                              validator: (val) {
                                if (val != newPasswordController.text) return 'Passwords do not match.';
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
                    child: const Text('Cancel', style: TextStyle(color: Colors.white38, fontSize: 13)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _blueAccent,
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
                                content: Text('Password updated successfully.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            );
                          }
                        } catch (e) {
                          setDialogState(() => isProcessing = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.redAccent,
                              content: Text('Error: ${e.toString().split(']').last.trim()}'),
                            ),
                          );
                        }
                      }
                    },
                    child: const Text('Update Password', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
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
        floatingLabelStyle: const TextStyle(color: _blueAccent, fontSize: 13, fontWeight: FontWeight.bold),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.06)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _blueAccent, width: 1.5),
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
          body: Center(child: Text('No user profile found.', style: TextStyle(color: Colors.white))),
        );
      }

      final String formattedJoinDate = user.createdAt != null 
          ? "${user.createdAt!.day}/${user.createdAt!.month}/${user.createdAt!.year}"
          : "N/A";

      return Scaffold(
        backgroundColor: _matteBlackCanvas,
        appBar: AppBar(
          title: const Text(
            'Profile', 
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
        ),
        body: _isUpdating
            ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(_blueAccent)))
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 120.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── PROFILE HEADER ──────────────────────────────────────────
                    _buildGlassmorphicContainer(
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(color: _blueAccent.withOpacity(0.2), shape: BoxShape.circle),
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
                                  decoration: const BoxDecoration(color: _blueAccent, shape: BoxShape.circle),
                                  child: const Icon(Icons.edit_rounded, color: _matteBlackCanvas, size: 16),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 18),
                          Text(
                            user.displayName,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 22,
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

                   // ── ADMIN DASHBOARD ──
                    if (user.role.trim().toLowerCase() == 'admin') ...[
                      _buildSectionLabel('Admin Controls'),
                      _buildGlassmorphicContainer(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            _buildSettingsTile(
                              icon: Icons.admin_panel_settings_rounded,
                              title: 'Open Admin Dashboard',
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
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // ── PROFILE INFO ──
                    _buildSectionLabel('Profile Information'),
                    _buildGlassmorphicContainer(
                      child: Column(
                        children: [
                          _buildRowDetail('Phone', user.phoneNumber.isNotEmpty ? user.phoneNumber : 'Not set', Icons.phone_iphone_rounded),
                          const Divider(height: 28, color: Colors.white10),
                          _buildRowDetail('Email', user.email, Icons.alternate_email_rounded),
                          const Divider(height: 28, color: Colors.white10),
                          _buildRowDetail('Address', user.physicalAddress.isNotEmpty ? user.physicalAddress : 'Not set', Icons.location_on_rounded),
                          
                          if (user.githubUsername.isNotEmpty) ...[
                            const Divider(height: 28, color: Colors.white10),
                            _buildRowDetail('GitHub', user.githubUsername, Icons.code_rounded),
                          ],
                          
                          if (user.linkedinUrl.isNotEmpty) ...[
                            const Divider(height: 28, color: Colors.white10),
                            _buildRowDetail('LinkedIn', user.linkedinUrl, Icons.link_rounded),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── ACCOUNT DETAILS ──
                    _buildSectionLabel('Account Details'),
                    _buildGlassmorphicContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildRowDetail('Joined', formattedJoinDate, Icons.calendar_today_rounded),
                          
                          if (user.interests.isNotEmpty) ...[
                            const Divider(height: 28, color: Colors.white10),
                            const Text('Interests', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _blueAccent, letterSpacing: 1.5)),
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
                            const Text('Tech Stack', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _blueAccent, letterSpacing: 1.5)),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8, runSpacing: 6,
                              children: user.techStack.map((tool) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _blueAccent.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: _blueAccent.withOpacity(0.2))
                                ),
                                child: Text(tool, style: const TextStyle(fontSize: 12, color: _blueAccent, fontWeight: FontWeight.bold)),
                              )).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── SECURITY ──
                    _buildSectionLabel('Security'),
                    _buildGlassmorphicContainer(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          _buildSettingsTile(
                            icon: Icons.lock_reset_rounded,
                            title: 'Change Password',
                            onTap: () => _openChangePasswordDialog(user.email),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── SUPPORT & LOGOUT ──
                    _buildSectionLabel('Support & Account'),
                    _buildGlassmorphicContainer(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          _buildSettingsTile(
                            icon: Icons.help_outline_rounded,
                            title: 'Contact Support',
                            onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ContactSupportScreen(currentUser: user),
                                  ),
                                );
                              },
                          ),
                          const Divider(height: 1, color: Colors.white10),
                          _buildSettingsTile(
                            icon: Icons.logout_rounded,
                            title: 'Logout',
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

    Widget _buildRowDetail(String label, String value, IconData icon) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.white38),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 13)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
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
  }

InputDecoration _buildGlassInputDecoration({required String label, IconData? prefixIcon}) {
  return InputDecoration(
    filled: true,
    fillColor: Colors.white.withOpacity(0.01),
    labelText: label,
    prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 18, color: Colors.white38) : null,
    labelStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
    floatingLabelStyle: const TextStyle(color: _blueAccent, fontWeight: FontWeight.bold, fontSize: 13),
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.white.withOpacity(0.06)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: _blueAccent, width: 1.5),
    ),
  );
}

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
  
  PhoneNumber _currentParsedNumber = PhoneNumber(isoCode: 'ZA');

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
    _initializePhoneNumber();
  }

  void _initializePhoneNumber() async {
    if (widget.user.phoneNumber.isNotEmpty) {
      try {
        PhoneNumber parsed = await PhoneNumber.getRegionInfoFromPhoneNumber(widget.user.phoneNumber);
        if (mounted) {
          setState(() {
            _currentParsedNumber = parsed;
          });
        }
      } catch (_) {
        _currentParsedNumber = PhoneNumber(isoCode: 'ZA', phoneNumber: widget.user.phoneNumber);
      }
    }
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
      padding: EdgeInsets.fromLTRB(0, 0, 0, MediaQuery.of(context).viewInsets.bottom),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF121212).withOpacity(0.90),
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
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Edit Profile',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Update your profile information below.',
                        style: TextStyle(fontSize: 13, color: Colors.white60),
                      ),
                      const SizedBox(height: 28),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: _blueAccent.withOpacity(0.15), shape: BoxShape.circle),
                          child: CircleAvatar(
                            radius: 48,
                            backgroundColor: Colors.white10,
                            backgroundImage: AssetImage(_getAvatarPath(_selectedAvatar)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Choose Avatar',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white60, letterSpacing: 1.0),
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
                                  border: Border.all(color: isSelected ? _blueAccent : Colors.transparent, width: 2),
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
                        validator: (val) => (val == null || val.trim().isEmpty) ? 'Name is required.' : null,
                        decoration: _buildGlassInputDecoration(label: 'Full Name', prefixIcon: Icons.person_outline_rounded),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _bioController,
                        maxLines: 2,
                        maxLength: 120,
                        style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
                        decoration: _buildGlassInputDecoration(label: 'Bio (optional)'),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white.withOpacity(0.06)),
                        ),
                        child: InternationalPhoneNumberInput(
                          onInputChanged: (PhoneNumber number) {
                            _phoneController.text = number.phoneNumber ?? '';
                          },
                          textFieldController: TextEditingController(
                            text: _phoneController.text.isNotEmpty && _phoneController.text.contains(' ') 
                                ? _phoneController.text.split(' ').last 
                                : _phoneController.text
                          ),
                          initialValue: _currentParsedNumber,
                          selectorConfig: const SelectorConfig(
                            selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                            useEmoji: true,
                          ),
                          ignoreBlank: false,
                          autoValidateMode: AutovalidateMode.disabled,
                          selectorTextStyle: const TextStyle(color: Colors.white, fontSize: 13),
                          textStyle: const TextStyle(color: Colors.white, fontSize: 14),
                          cursorColor: _blueAccent,
                          formatInput: true,
                          keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: false),
                          inputDecoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFF1E1E1E),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            hintText: '+27 Phone Number',
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 13),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _addressController,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: _buildGlassInputDecoration(label: 'Address', prefixIcon: Icons.location_on_rounded),
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
                            backgroundColor: _blueAccent,
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
                          child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5, fontSize: 14)),
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