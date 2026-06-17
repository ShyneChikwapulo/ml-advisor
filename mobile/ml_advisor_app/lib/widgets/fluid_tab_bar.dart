import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import '../utils/app_theme.dart';

class FluidTabBar extends StatefulWidget {
  final int currentTab; // ⚡ ADDED: Tracks active global tab map index
  final Function(int)? onTabChanged;

  // Pass it directly into your class constructor constructor
  const FluidTabBar({super.key, required this.currentTab, this.onTabChanged});

  @override
  _FluidTabBarState createState() => _FluidTabBarState();
}

class _FluidTabBarState extends State<FluidTabBar> with TickerProviderStateMixin {
  int selectedIndex = 0;
  int previousIndex = 0;

  late AnimationController _dentController;
  late Animation<double> _dentAnimation;
  late AnimationController _circleController;
  late Animation<double> _circleJumpAnimation;

  final List<IconData> icons = [
    Icons.home,
    Icons.psychology,
    Icons.lightbulb,
    Icons.chat,
    Icons.person,
  ];

  @override
  void initState() {
    super.initState();
    // Initialize our local index tracking with whatever value was passed down
    selectedIndex = widget.currentTab;

    _dentController = AnimationController(
      duration: const Duration(milliseconds: 650),
      vsync: this,
    );
    _dentAnimation = CurvedAnimation(
      parent: _dentController,
      curve: StifferCurve(),
    );

    _circleController = AnimationController(
      duration: const Duration(milliseconds: 450),
      vsync: this,
    );
    _circleJumpAnimation = CurvedAnimation(
      parent: _circleController,
      curve: Curves.easeOutQuad,
    );

    _dentController.value = 1.0;
  }


  // ⚡ ADDED: This intercepts external index shifts (like from the drawer)
  @override
  void didUpdateWidget(covariant FluidTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentTab != oldWidget.currentTab) {
      _triggerExternalTabShift(widget.currentTab);
    }
  }

  // ⚡ ADDED: Handles triggering the fluid wave safely from external updates
  void _triggerExternalTabShift(int targetIndex) {
    if (targetIndex == selectedIndex) return;

    setState(() {
      previousIndex = selectedIndex;
      selectedIndex = targetIndex;
    });

    _circleController.forward(from: 0);
    _dentController.reset();
    
    Future.delayed(const Duration(milliseconds: 220), () {
      if (mounted) _dentController.forward();
    });
  }

  void _onTabTapped(int index) {
    if (index == selectedIndex) return;
    widget.onTabChanged?.call(index);

    setState(() {
      previousIndex = selectedIndex;
      selectedIndex = index;
    });

    _circleController.forward(from: 0);
    
    _dentController.reset();
    Future.delayed(const Duration(milliseconds: 220), () {
      if (mounted) _dentController.forward();
    });

    widget.onTabChanged?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    const double baselineY = 25.0;
    const double visibleBarHeight = 65.0;
    final double totalHeight = baselineY + visibleBarHeight + bottomPadding;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double tabWidth = width / icons.length;

        return SizedBox(
          height: totalHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // --- OPTIMIZED GLASSMORPHISM VIA REPAINT BOUNDARY ---
              RepaintBoundary( // ⚡ ISO-LAYER SHIELD: Prevents full-screen layout thrashing
                child: AnimatedBuilder(
                  animation: Listenable.merge([_dentAnimation, _circleJumpAnimation]),
                  builder: (context, child) {
                    return Stack(
                      children: [
                        // 1. Live blur background restricted perfectly to our fluid cutout path
                        ClipPath(
                          clipper: FluidTabClipper(
                            tabCount: icons.length,
                            selectedIndex: selectedIndex,
                            dentProgress: _dentAnimation.value,
                            tabWidth: tabWidth,
                            baselineY: baselineY,
                          ),
                          child: BackdropFilter(
                            filter: ui.ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0), // Dropped slightly from 16 to maximize framerate
                            child: SizedBox(
                              width: width,
                              height: totalHeight,
                            ),
                          ),
                        ),
                        // 2. Custom Painter handling Shadows, Frosted Fills, and Borders
                        CustomPaint(
                          size: Size(width, totalHeight),
                          painter: FluidTabPainter(
                            tabCount: icons.length,
                            selectedIndex: selectedIndex,
                            previousIndex: previousIndex,
                            dentProgress: _dentAnimation.value,
                            circleProgress: _circleJumpAnimation.value,
                            tabWidth: tabWidth,
                            baselineY: baselineY,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Icons & Labels container stays outside the RepaintBoundary...

              // Icons & Labels
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: totalHeight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(icons.length, (index) {
                    final isSelected = selectedIndex == index;
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _onTabTapped(index),
                      child: SizedBox(
                        width: tabWidth,
                        height: totalHeight,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              top: baselineY + (visibleBarHeight / 2) - 22,
                              left: 0,
                              right: 0,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 350),
                                curve: Curves.easeOutBack,
                                transform: Matrix4.translationValues(
                                  0,
                                  isSelected ? -18 : 0, 
                                  0,
                                ),
                                child: Icon(
                                  icons[index],
                                  size: 26,
                                  color: isSelected ? Colors.white : AppTheme.textPrimary.withOpacity(0.8),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: bottomPadding + 6,
                              left: 0,
                              right: 0,
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 200),
                                opacity: isSelected ? 0.0 : 1.0,
                                child: Text(
                                  _getLabel(index),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary.withOpacity(0.7),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getLabel(int index) {
    switch (index) {
      case 0: return 'Home';
      case 1: return 'Models';
      case 2: return 'Recommend';
      case 3: return 'Chat';
      case 4: return 'Profile';
      default: return '';
    }
  }

  @override
  void dispose() {
    _dentController.dispose();
    _circleController.dispose();
    super.dispose();
  }
}

// --- Dynamic Clipping Path Engine ---
class FluidTabClipper extends CustomClipper<Path> {
  final int tabCount;
  final int selectedIndex;
  final double dentProgress;
  final double tabWidth;
  final double baselineY;

  FluidTabClipper({
    required this.tabCount,
    required this.selectedIndex,
    required this.dentProgress,
    required this.tabWidth,
    required this.baselineY,
  });

  @override
  Path getClip(Size size) {
    final double dentWidth = tabWidth * 1.2;
    final double maxDentDepth = 30.0;
    
    double oscillation = math.sin(dentProgress * math.pi * 2) * 0.3;
    double currentDentWidth = dentWidth * (1 + (oscillation * (1 - dentProgress)) - (0.3 * (1 - dentProgress)));
    double currentDentDepth = maxDentDepth * dentProgress;

    final path = Path();
    path.moveTo(0, baselineY);

    for (int i = 0; i < tabCount; i++) {
      double centerX = (i * tabWidth) + (tabWidth / 2);
      
      if (i == selectedIndex) {
        double startX = centerX - currentDentWidth / 2;
        double endX = centerX + currentDentWidth / 2;

        path.lineTo(startX, baselineY);
        path.cubicTo(
          centerX - currentDentWidth * 0.14, baselineY,
          centerX - currentDentWidth * 0.26, baselineY + currentDentDepth,
          centerX, baselineY + currentDentDepth,
        );
        path.cubicTo(
          centerX + currentDentWidth * 0.26, baselineY + currentDentDepth,
          centerX + currentDentWidth * 0.14, baselineY,
          endX, baselineY,
        );
      } else {
        path.lineTo(centerX + tabWidth / 2, baselineY);
      }
    }

    path.lineTo(size.width, baselineY);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(FluidTabClipper oldClipper) {
    return oldClipper.dentProgress != dentProgress ||
           oldClipper.selectedIndex != selectedIndex ||
           oldClipper.tabWidth != tabWidth;
  }
}

// --- Animation & Painting Engine ---
class StifferCurve extends Curve {
  @override
  double transform(double t) {
    return -math.pow(math.e, -t * 8) * math.cos(t * 6) + 1;
  }
}

class FluidTabPainter extends CustomPainter {
  final int tabCount;
  final int selectedIndex;
  final int previousIndex;
  final double dentProgress;
  final double circleProgress;
  final double tabWidth;
  final double baselineY;

  FluidTabPainter({
    required this.tabCount,
    required this.selectedIndex,
    required this.previousIndex,
    required this.dentProgress,
    required this.circleProgress,
    required this.tabWidth,
    required this.baselineY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double dentWidth = tabWidth * 1.2;
    final double maxDentDepth = 30.0;
    
    double oscillation = math.sin(dentProgress * math.pi * 2) * 0.3;
    double currentDentWidth = dentWidth * (1 + (oscillation * (1 - dentProgress)) - (0.3 * (1 - dentProgress)));
    double currentDentDepth = maxDentDepth * dentProgress;

    final path = Path();
    path.moveTo(0, baselineY);

    for (int i = 0; i < tabCount; i++) {
      double centerX = (i * tabWidth) + (tabWidth / 2);
      
      if (i == selectedIndex) {
        double startX = centerX - currentDentWidth / 2;
        double endX = centerX + currentDentWidth / 2;

        path.lineTo(startX, baselineY);
        path.cubicTo(
          centerX - currentDentWidth * 0.14, baselineY,
          centerX - currentDentWidth * 0.26, baselineY + currentDentDepth,
          centerX, baselineY + currentDentDepth,
        );
        path.cubicTo(
          centerX + currentDentWidth * 0.26, baselineY + currentDentDepth,
          centerX + currentDentWidth * 0.14, baselineY,
          endX, baselineY,
        );
      } else {
        path.lineTo(centerX + tabWidth / 2, baselineY);
      }
    }

    path.lineTo(size.width, baselineY);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    // 1. Translucent ambient drop shadow
    canvas.drawShadow(
      path,
      Colors.black.withOpacity(0.06),
      8.0,
      false,
    );

    // 2. Frosted Glass Tint Fill Layer
    final frostedPaint = Paint()
      ..color = Colors.white.withOpacity(0.35) // Semi-translucent white frost mask
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, frostedPaint);

    // 3. Crisp Glass Highlights & Border Strokes
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withOpacity(0.55), // Glowing top rim highlight
            Colors.white.withOpacity(0.10), // Fades out neatly along the baseline
          ],
        ).createShader(Rect.fromLTWH(0, baselineY, size.width, size.height - baselineY));
    canvas.drawPath(path, borderPaint);

    _drawBouncingBall(canvas, size, maxDentDepth);
  }

  void _drawBouncingBall(Canvas canvas, Size size, double dentDepth) {
    final startX = (previousIndex * tabWidth) + (tabWidth / 2);
    final endX = (selectedIndex * tabWidth) + (tabWidth / 2);
    
    final currentX = ui.lerpDouble(startX, endX, circleProgress)!;

    final jumpHeight = 35.0; 
    final flattenedSine = math.sin(circleProgress * math.pi) * (1 - circleProgress * 0.2);
    
    final restingY = baselineY + dentDepth - 22; 
    final currentY = ui.lerpDouble(restingY, restingY, circleProgress)! - (flattenedSine * jumpHeight);

    final Rect ballRect = Rect.fromCircle(center: Offset(currentX, currentY), radius: 24);
    
    // Gradient matching your active theme branding accent beautifully
    final Gradient ballGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppTheme.accent, 
        AppTheme.primary,
      ],
    );

    final ballPaint = Paint()
      ..shader = ballGradient.createShader(ballRect)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(currentX, currentY), 24, ballPaint);
  }

  @override
  bool shouldRepaint(FluidTabPainter oldDelegate) {
    return oldDelegate.dentProgress != dentProgress ||
           oldDelegate.circleProgress != circleProgress ||
           oldDelegate.selectedIndex != selectedIndex;
  }
}