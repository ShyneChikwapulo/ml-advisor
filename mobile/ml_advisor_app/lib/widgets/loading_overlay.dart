import 'dart:ui';
import 'package:flutter/material.dart';
// 1. Add this import at the very top of loading_overlay.dart
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoadingOverlay extends StatelessWidget {
  final Widget child;       // The screen hidden underneath the blur
  final bool isLoading;     // True = show blur, False = hide blur
  final String? loadingText;// Optional message like "Loading Models..."

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.loadingText,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child, // Always display your main screen content first
        
        if (isLoading) ...[
          AbsorbPointer( // Blocks clicks so users can't mash buttons while loading
            child: Stack(
              children: [
                // 1. The Frosted Glass Blur Effect
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                    child: Container(
                      color: const Color(0xFF121212).withOpacity(0.65),
                    ),
                  ),
                ),
                
                // 2. The Central Loading Box
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF1565C0).withOpacity(0.25), // Your blue accent
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 40,
                          width: 40,
                          child: LoadingAnimationWidget.staggeredDotsWave(
                            color: const Color(0xFF1565C0), // Your blue accent color
                            size: 40,
                          ),
                        ),
                        if (loadingText != null) ...[
                          const SizedBox(height: 18),

                          Material(
                            color: Colors.transparent,
                            child: Text(
                                loadingText!.toUpperCase(),
                                style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white.withOpacity(0.9),
                                letterSpacing: 1.5,
                                ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}