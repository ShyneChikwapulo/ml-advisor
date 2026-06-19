import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

const Color _blueAccent = Color(0xFF1565C0);
const Color _matteBlackCanvas = Color(0xFF121212);

class GetStartedWizard extends StatefulWidget {
  const GetStartedWizard({super.key});

  @override
  State<GetStartedWizard> createState() => _GetStartedWizardState();
}

class _GetStartedWizardState extends State<GetStartedWizard> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;

  int _selectedAvatarIndex = -1;
  String _selectedExperience = '';
  final List<String> _selectedInterests = [];
  bool _enableTips = true;
  
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _githubController = TextEditingController();
  final TextEditingController _linkedinController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final List<String> _selectedTechStack = [];

  final int _totalSteps = 5;

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _saveOnboardingData();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  Future<void> _saveOnboardingData() async {
    if (_selectedAvatarIndex == -1) {
      _showWarningSnackBar('Please choose an avatar.');
      _pageController.animateToPage(1, duration: const Duration(milliseconds: 400), curve: Curves.easeOutCubic);
      return;
    }
    if (_selectedExperience.isEmpty) {
      _showWarningSnackBar('Please select your experience level.');
      _pageController.animateToPage(2, duration: const Duration(milliseconds: 400), curve: Curves.easeOutCubic);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final String? uid = authProvider.user?.uid;

      if (uid != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'avatarIndex': _selectedAvatarIndex,
          'experienceLevel': _selectedExperience,
          'interests': _selectedInterests,
          'enableTips': _enableTips,
          'bio': _bioController.text.trim(),
          'githubUsername': _githubController.text.trim(),
          'linkedinUrl': _linkedinController.text.trim(),
          'phoneNumber': _phoneController.text.trim(),
          'physicalAddress': _addressController.text.trim(),
          'techStack': _selectedTechStack,
          'hasCompletedOnboarding': true,
          'createdAt': FieldValue.serverTimestamp(),
        });

        await authProvider.refreshUserSession();
      }
    } catch (e) {
      _showWarningSnackBar('Failed to save profile: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showWarningSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1C1C1E),
        content: Text(message, style: const TextStyle(color: _blueAccent, fontWeight: FontWeight.bold)),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _bioController.dispose();
    _githubController.dispose();
    _linkedinController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isWelcomeStep = _currentStep == 0;

    return Scaffold(
      backgroundColor: _matteBlackCanvas,
      body: Stack(
        children: [
          if (isWelcomeStep)
            Positioned.fill(
              child: Image.asset(
                'assets/images/OnBoarding.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(color: const Color(0xFF0A1118));
                },
              ),
            ),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _currentStep > 0
                          ? IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.white70),
                              onPressed: _isLoading ? null : _previousStep,
                            )
                          : const SizedBox(width: 48),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Text(
                          'STEP ${_currentStep + 1} OF $_totalSteps',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: _blueAccent, fontSize: 10, letterSpacing: 1.5),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 6),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (_currentStep + 1) / _totalSteps,
                      backgroundColor: Colors.white10,
                      valueColor: const AlwaysStoppedAnimation<Color>(_blueAccent),
                      minHeight: 2,
                    ),
                  ),
                ),

                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (page) => setState(() => _currentStep = page),
                    children: [
                      const _WelcomeStep(),
                      _AvatarStep(
                        selectedIndex: _selectedAvatarIndex,
                        onSelected: (idx) => setState(() => _selectedAvatarIndex = idx),
                      ),
                      _PreferencesStep(
                        selectedExperience: _selectedExperience,
                        selectedInterests: _selectedInterests,
                        enableTips: _enableTips,
                        onExperienceChanged: (val) => setState(() => _selectedExperience = val),
                        onInterestsChanged: (interest, isSelected) {
                          setState(() {
                            isSelected ? _selectedInterests.add(interest) : _selectedInterests.remove(interest);
                          });
                        },
                        onTipsToggle: (val) => setState(() => _enableTips = val),
                      ),
                      _DeveloperFieldsStep(
                        bioController: _bioController,
                        githubController: _githubController,
                        linkedinController: _linkedinController,
                        phoneController: _phoneController,
                        addressController: _addressController,
                        selectedTechStack: _selectedTechStack,
                        onTechStackChanged: (tech, isSelected) {
                          setState(() {
                            isSelected ? _selectedTechStack.add(tech) : _selectedTechStack.remove(tech);
                          });
                        },
                      ),
                      const _FeatureStep(),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _blueAccent,
                        foregroundColor: _matteBlackCanvas,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      onPressed: _isLoading ? null : _nextStep,
                      child: _isLoading
                          ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: _matteBlackCanvas, strokeWidth: 2.5))
                          : Text(
                                  _currentStep == 0 
                                      ? 'GET STARTED' 
                                      : _currentStep == _totalSteps - 1 
                                          ? 'COMPLETE SETUP' 
                                          : 'CONTINUE',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                                ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildFrostedGlassPanel({required Widget child, EdgeInsetsGeometry? padding}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(28),
    child: Container(
      padding: padding ?? const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.45),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 1.2),
      ),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: child,
      ),
    ),
  );
}

InputDecoration _buildGlassInputDecoration({required String label, IconData? prefixIcon}) {
  return InputDecoration(
    filled: true,
    fillColor: Colors.white.withOpacity(0.02),
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

// ── STEP 1: WELCOME ──
class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildFrostedGlassPanel(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.02),
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(24), 
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Image.asset(
                    'assets/images/Logo/Logo.png',
                    height: 64,
                    width: 64,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.psychology, size: 40, color: _blueAccent);
                    },
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Smart ML Modeling\nMade Simple.',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, height: 1.2, letterSpacing: -0.5),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your software engineering companion. Optimize development cycles by predicting bugs and model performance seamlessly.',
                  style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.65), height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ── STEP 2: AVATAR ──
class _AvatarStep extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _AvatarStep({required this.selectedIndex, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text('Choose Your Avatar', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 6),
          const Text('Select an avatar to represent your profile.', style: TextStyle(color: Colors.white38, fontSize: 13)),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              itemCount: 11,
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.0
              ),
              itemBuilder: (_, i) {
                final bool isSelected = selectedIndex == i;
                final String assetPath = 'assets/images/avatars/avatar${i + 1}.png';
                
                return InkWell(
                  onTap: () => onSelected(i),
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected ? _blueAccent.withOpacity(0.05) : Colors.white.withOpacity(0.02),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? _blueAccent : Colors.white.withOpacity(0.06), 
                        width: isSelected ? 2.0 : 1.0
                      ),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        assetPath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Center(child: Icon(Icons.person, color: isSelected ? _blueAccent : Colors.white24)),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── STEP 3: PREFERENCES ──
class _PreferencesStep extends StatelessWidget {
  final String selectedExperience;
  final List<String> selectedInterests;
  final bool enableTips;
  final ValueChanged<String> onExperienceChanged;
  final void Function(String, bool) onInterestsChanged;
  final ValueChanged<bool> onTipsToggle;

  const _PreferencesStep({
    required this.selectedExperience, required this.selectedInterests,
    required this.enableTips, required this.onExperienceChanged, required this.onInterestsChanged, required this.onTipsToggle
  });

  @override
  Widget build(BuildContext context) {
    final List<String> levels = ['Beginner', 'Intermediate', 'Advanced'];
    
    final List<String> targetInterests = [
      'Defect Prediction',
      'Static Code Analysis',
      'Cross-Project Prediction',
      'Change-Level Defect Tracking',
      'Deep Learning',
      'Feature Extraction',
      'Imbalanced Data',
      'Bug Localization',
      'Process Metrics',
      'Just-In-Time Prediction',
      'Repository Mining',
      'Pre-trained Models',
      'Precision-Recall',
      'Maintainability Index',
      'Code Smells',
      'Semantic Feature Learning'
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text('Your Preferences', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 24),
          const Text('EXPERIENCE LEVEL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _blueAccent, letterSpacing: 1.5)),
          const SizedBox(height: 12),
          Row(
            children: levels.map((lvl) {
              final bool isSelected = selectedExperience == lvl;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ChoiceChip(
                    label: Text(lvl),
                    selected: isSelected,
                    selectedColor: _blueAccent.withOpacity(0.15),
                    backgroundColor: const Color(0xFF1E1E1E),
                    checkmarkColor: _blueAccent,
                    side: BorderSide(color: isSelected ? _blueAccent : Colors.white.withOpacity(0.1)),
                    labelStyle: TextStyle(
                      color: isSelected ? _blueAccent : Colors.white.withOpacity(0.8),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, 
                      fontSize: 12
                    ),
                    onSelected: (selected) { if (selected) onExperienceChanged(lvl); },
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          const Text('AREAS OF INTEREST', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _blueAccent, letterSpacing: 1.5)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8, runSpacing: 6,
            children: targetInterests.map((interest) {
              final bool isSelected = selectedInterests.contains(interest);
              return FilterChip(
                label: Text(interest),
                selected: isSelected,
                selectedColor: _blueAccent.withOpacity(0.15),
                backgroundColor: const Color(0xFF1E1E1E),
                checkmarkColor: _blueAccent,
                side: BorderSide(color: isSelected ? _blueAccent.withOpacity(0.5) : Colors.white.withOpacity(0.1)),
                labelStyle: TextStyle(
                  color: isSelected ? _blueAccent : Colors.white.withOpacity(0.8),
                  fontSize: 11
                ),
                onSelected: (selected) => onInterestsChanged(interest, selected),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.02),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.06))
            ),
            child: SwitchListTile(
              title: const Text('Enable Tips', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
              subtitle: const Text('Show helpful tips throughout the app.', style: TextStyle(fontSize: 11, color: Colors.white38)),
              value: enableTips,
              activeColor: _blueAccent,
              onChanged: onTipsToggle,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ── STEP 4: DEVELOPER FIELDS ──
class _DeveloperFieldsStep extends StatelessWidget {
  final TextEditingController bioController;
  final TextEditingController githubController;
  final TextEditingController linkedinController;
  final TextEditingController phoneController;
  final TextEditingController addressController;
  final List<String> selectedTechStack;
  final void Function(String, bool) onTechStackChanged;

  const _DeveloperFieldsStep({
    required this.bioController, 
    required this.githubController, 
    required this.linkedinController,
    required this.phoneController, 
    required this.addressController,
    required this.selectedTechStack, 
    required this.onTechStackChanged,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> typicalTools = [
      'Python', 'Java', 'C#', 'JavaScript', 'Flutter', 'React', 'PyTorch', 'TensorFlow', 'SQL',
      'Dart', 'Scikit-Learn', 'Docker', 'FastAPI', 'Git', 'Firebase', 'PostgreSQL', 'GraphQL'
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text('Profile Details', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 6),
          const Text('Add optional information to your profile.', style: TextStyle(color: Colors.white38, fontSize: 13)),
          const SizedBox(height: 24),
          
          const Text('BIO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _blueAccent, letterSpacing: 1.5)),
          const SizedBox(height: 8),
          TextField(
            controller: bioController,
            maxLines: 2,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: _buildGlassInputDecoration(label: 'Tell us about yourself...'),
          ),
          const SizedBox(height: 20),

          const Text('PHONE NUMBER', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _blueAccent, letterSpacing: 1.5)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: InternationalPhoneNumberInput(
              onInputChanged: (PhoneNumber number) {
                phoneController.text = number.phoneNumber ?? '';
              },
              textFieldController: TextEditingController(
                text: phoneController.text.isNotEmpty && phoneController.text.contains(' ') 
                    ? phoneController.text.split(' ').last 
                    : phoneController.text
              ),
              selectorConfig: const SelectorConfig(
                selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                useEmoji: true,
              ),
              ignoreBlank: false,
              autoValidateMode: AutovalidateMode.disabled,
              selectorTextStyle: const TextStyle(color: Colors.white, fontSize: 13),
              textStyle: const TextStyle(color: Colors.white, fontSize: 13),
              cursorColor: _blueAccent,
              formatInput: true,
              keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: false),
              inputDecoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                border: InputBorder.none,
                hintText: '+27 712 345 678',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 13),
              ),
            ),
          ),
          const SizedBox(height: 20),

          const Text('ADDRESS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _blueAccent, letterSpacing: 1.5)),
          const SizedBox(height: 8),
          TextField(
            controller: addressController,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: _buildGlassInputDecoration(label: 'Your location', prefixIcon: Icons.location_on_rounded),
          ),
          const SizedBox(height: 20),

          const Text('SOCIAL LINKS (OPTIONAL)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _blueAccent, letterSpacing: 1.5)),
          const SizedBox(height: 8),
          TextField(
            controller: githubController,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: _buildGlassInputDecoration(label: 'GitHub Username', prefixIcon: Icons.code_rounded),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: linkedinController,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: _buildGlassInputDecoration(label: 'LinkedIn Profile URL', prefixIcon: Icons.link_rounded),
          ),
          const SizedBox(height: 24),

          const Text('TECH STACK', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _blueAccent, letterSpacing: 1.5)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8, runSpacing: 6,
            children: typicalTools.map((tool) {
              final bool isSelected = selectedTechStack.contains(tool);
              return FilterChip(
                label: Text(tool),
                selected: isSelected,
                selectedColor: _blueAccent.withOpacity(0.15),
                backgroundColor: const Color(0xFF1E1E1E),
                checkmarkColor: _blueAccent,
                side: BorderSide(color: isSelected ? _blueAccent.withOpacity(0.5) : Colors.white.withOpacity(0.1)),
                labelStyle: TextStyle(
                  color: isSelected ? _blueAccent : Colors.white.withOpacity(0.8),
                  fontSize: 11
                ),
                onSelected: (selected) => onTechStackChanged(tool, selected),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── STEP 5: FEATURES ──
class _FeatureStep extends StatelessWidget {
  const _FeatureStep();

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> features = [
      {'icon': Icons.search_rounded, 'title': 'Model Browsing', 'desc': 'Browse all available ML models for bug prediction.'},
      {'icon': Icons.balance_rounded, 'title': 'Side-by-Side Comparison', 'desc': 'Compare models side by side with metrics and charts.'},
      {'icon': Icons.auto_graph_rounded, 'title': 'Smart Recommendations', 'desc': 'Get personalized model recommendations based on your project needs.'},
      {'icon': Icons.forum_outlined, 'title': 'AI Chat', 'desc': 'Ask questions and get answers grounded in 26 research papers.'},
      {'icon': Icons.dashboard_customize_outlined, 'title': 'Dashboards', 'desc': 'View analytics and insights about bug prediction models.'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text('What You Get', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 6),
          const Text('Key features available in ML Advisor.', style: TextStyle(color: Colors.white38, fontSize: 13)),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: features.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (_, i) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.02),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.04)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: _blueAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                          child: Icon(features[i]['icon'], color: _blueAccent, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(features[i]['title'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                              const SizedBox(height: 4),
                              Text(features[i]['desc'], style: const TextStyle(fontSize: 11, color: Colors.white38, height: 1.4)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}