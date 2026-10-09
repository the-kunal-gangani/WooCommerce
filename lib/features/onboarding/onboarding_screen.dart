import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magna_data_ai_ecommerce/core/routes/app_routes.dart';
import 'package:magna_data_ai_ecommerce/core/services/category_service.dart';
import 'package:magna_data_ai_ecommerce/core/services/location_service.dart';
import 'package:magna_data_ai_ecommerce/core/services/product_services.dart';
import 'package:magna_data_ai_ecommerce/core/services/recently_viewed_service.dart';
import 'package:magna_data_ai_ecommerce/features/home/home_controller.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late final PageController _pageController;

  late final AnimationController _contentController;

  int _currentPage = 0;

  final List<_OnboardingData> _pages = const [
    _OnboardingData(
      title: 'Discover Smarter Shopping',
      description: 'Explore products intelligently and discover what feels right for you.',
      label: 'DISCOVER',
    ),
    _OnboardingData(
      title: 'Recommendations That Think',
      description: 'Our AI understands your preferences and finds products worth your attention.',
      label: 'INTELLIGENCE',
    ),
    _OnboardingData(
      title: 'Safe. Simple. Seamless.',
      description: 'Enjoy a secure shopping experience from product discovery to checkout.',
      label: 'SECURITY',
    ),
    _OnboardingData(
      title: 'From Store to Your Door',
      description: 'Track your order and stay connected with every step of your delivery.',
      label: 'DELIVERY',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _skip() {
    _finishOnboarding();
  }

  void _finishOnboarding() {
    Get.lazyPut<HomeController>(
      () => HomeController(
        Get.find<ProductService>(),
        Get.find<CategoryService>(),
        Get.find<LocationService>(),
        Get.find<RecentlyViewedService>(),
      ),
    );

    Get.offAllNamed(AppRoutes.home);
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });

    _contentController
      ..reset()
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned.fill(child: _OnboardingBackground()),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _BrandMiniMark(),
                      GestureDetector(
                        onTap: _skip,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.72),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: const Color(0xFFE7EBF3)),
                          ),
                          child: const Text(
                            'Skip',
                            style: TextStyle(
                              color: Color(0xFF687386),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: _onPageChanged,
                    itemBuilder: (context, index) {
                      return AnimatedBuilder(
                        animation: _contentController,
                        builder: (context, child) {
                          final curved = CurvedAnimation(
                            parent: _contentController,
                            curve: Curves.easeOutCubic,
                          );
                          return Opacity(
                            opacity: curved.value,
                            child: Transform.translate(
                              offset: Offset(0, 20 * (1 - curved.value)),
                              child: child,
                            ),
                          );
                        },
                        child: _OnboardingPage(
                          pageIndex: index,
                          data: _pages[index],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Column(
                    children: [
                      _PageIndicator(
                        currentPage: _currentPage,
                        count: _pages.length,
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 56,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      Color(0xFF4F7CFF),
                                      Color(0xFF7657E8),
                                      Color(0xFF8B5CF6),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF4F7CFF)
                                          .withValues(alpha: 0.22),
                                      blurRadius: 20,
                                      offset: const Offset(0, 9),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(18),
                                    onTap: _nextPage,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          _currentPage == _pages.length - 1
                                              ? 'Get Started'
                                              : 'Continue',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        const Icon(
                                          Icons.arrow_forward_rounded,
                                          color: Colors.white,
                                          size: 19,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 13),
                      Text(
                        'MAGNADATA AI • AI COMMERCE',
                        style: TextStyle(
                          color: const Color(0xFF9AA4B5)
                              .withValues(alpha: 0.85),
                          fontSize: 8.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.pageIndex, required this.data});

  final int pageIndex;
  final _OnboardingData data;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Expanded(flex: 6, child: _OnboardingIllustration(page: pageIndex)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF3FF),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              data.label,
              style: const TextStyle(
                color: Color(0xFF5968D8),
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 28,
              height: 1.12,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.7,
            ),
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 330),
            child: Text(
              data.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF687386),
                fontSize: 14,
                height: 1.55,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _OnboardingBackground extends StatelessWidget {
  const _OnboardingBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _BackgroundPainter());
  }
}

class _BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final blueCenter = Offset(size.width * 0.15, size.height * 0.30);
    final violetCenter = Offset(size.width * 0.90, size.height * 0.65);
    final bluePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF4F7CFF).withValues(alpha: 0.055),
          const Color(0xFF4F7CFF).withValues(alpha: 0),
        ],
      ).createShader(Rect.fromCircle(center: blueCenter, radius: 230));
    canvas.drawCircle(blueCenter, 230, bluePaint);
    final violetPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF8B5CF6).withValues(alpha: 0.045),
          const Color(0xFF8B5CF6).withValues(alpha: 0),
        ],
      ).createShader(Rect.fromCircle(center: violetCenter, radius: 250));
    canvas.drawCircle(violetCenter, 250, violetPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class _BrandMiniMark extends StatelessWidget {
  const _BrandMiniMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 35,
      height: 35,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4F7CFF), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(11),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F7CFF).withValues(alpha: 0.18),
            blurRadius: 13,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const CustomPaint(painter: _BrandMarkPainter()),
    );
  }
}

class _BrandMarkPainter extends CustomPainter {
  const _BrandMarkPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, 6, paint);
    canvas.drawLine(center.translate(-11, 0), center.translate(-6, 0), paint);
    canvas.drawLine(center.translate(6, 0), center.translate(11, 0), paint);
    canvas.drawLine(center.translate(0, -11), center.translate(0, -6), paint);
    canvas.drawLine(center.translate(0, 6), center.translate(0, 11), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({required this.currentPage, required this.count});

  final int currentPage;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final active = index == currentPage;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 25 : 7,
          height: 7,
          decoration: BoxDecoration(
            gradient: active
                ? const LinearGradient(
                    colors: [Color(0xFF4F7CFF), Color(0xFF8B5CF6)],
                  )
                : null,
            color: active ? null : const Color(0xFFDCE2EC),
            borderRadius: BorderRadius.circular(20),
          ),
        );
      }),
    );
  }
}

class _OnboardingData {
  const _OnboardingData({
    required this.title,
    required this.description,
    required this.label,
  });

  final String title;
  final String description;
  final String label;
}

class _OnboardingIllustration extends StatefulWidget {
  const _OnboardingIllustration({this.page = 0});

  final int page;

  @override
  State<_OnboardingIllustration> createState() =>
      _OnboardingIllustrationState();
}

class _OnboardingIllustrationState extends State<_OnboardingIllustration>
    with TickerProviderStateMixin {
  late final AnimationController _motionController;
  late final AnimationController _pulseController;
  late final AnimationController _rotationController;

  @override
  void initState() {
    super.initState();

    _motionController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _motionController.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  double _float(double phase, double amount) {
    return math.sin((_motionController.value * math.pi * 2) + phase) * amount;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 380,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _motionController,
          _pulseController,
          _rotationController,
        ]),
        builder: (context, child) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _AtmospherePainter(pulse: _pulseController.value),
                ),
              ),
              Positioned.fill(
                child: CustomPaint(
                  painter: _ParticlePainter(progress: _motionController.value),
                ),
              ),
              _buildIllustration(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildIllustration() {
    switch (widget.page) {
      case 0:
        return _buildDiscoveryIllustration();
      case 1:
        return _buildIntelligenceIllustration();
      case 2:
        return _buildSecurityIllustration();
      case 3:
        return _buildDeliveryIllustration();
      default:
        return _buildDiscoveryIllustration();
    }
  }

  Widget _buildDiscoveryIllustration() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 8,
          top: 53 + _float(0.5, 7),
          child: const _SearchBubble(),
        ),
        Positioned(
          right: 15,
          top: 43 + _float(2.4, 6),
          child: const _FavoriteBubble(),
        ),
        Positioned(
          left: 4,
          bottom: 56 + _float(1.2, 7),
          child: const _AudioProductCard(),
        ),
        Positioned(
          right: 3,
          bottom: 48 + _float(3.0, 8),
          child: const _WatchProductCard(),
        ),
        Positioned(
          right: 55,
          top: 128 + _float(4.0, 5),
          child: const _MiniProductCard(),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 65 + _float(0, 4),
          child: const Center(child: _DiscoveryProductCard()),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 15,
          child: Center(
            child: _DiscoveryAiCore(
              pulse: _pulseController.value,
              rotation: _rotationController.value,
            ),
          ),
        ),
        Positioned(
          left: 94,
          top: 94 + _float(1.4, 5),
          child: const _GlowSparkle(size: 17, color: Color(0xFF4F7CFF)),
        ),
        Positioned(
          right: 91,
          bottom: 103 + _float(2.1, 6),
          child: const _GlowSparkle(size: 14, color: Color(0xFF8B5CF6)),
        ),
      ],
    );
  }

  Widget _buildIntelligenceIllustration() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 5,
          top: 76 + _float(0.7, 7),
          child: const _PreferenceCard(),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 72 + _float(0, 4),
          child: const Center(child: _RecommendationCard()),
        ),
        Positioned(
          right: 10,
          top: 53 + _float(2.1, 6),
          child: _NeuralBubble(pulse: _pulseController.value),
        ),
        Positioned(
          right: 2,
          bottom: 57 + _float(3.2, 8),
          child: const _MatchCard(),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 20,
          child: Center(
            child: _ThinkingAiCore(
              pulse: _pulseController.value,
              rotation: _rotationController.value,
            ),
          ),
        ),
        Positioned(
          left: 40,
          bottom: 105 + _float(1.5, 5),
          child: const _GlowSparkle(size: 15, color: Color(0xFF06B6D4)),
        ),
        Positioned(
          right: 78,
          top: 94 + _float(4.0, 5),
          child: const _GlowSparkle(size: 13, color: Color(0xFF8B5CF6)),
        ),
      ],
    );
  }

  Widget _buildSecurityIllustration() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: 70 + _float(0, 4),
          child: const Center(child: _SecurePaymentCard()),
        ),
        Positioned(
          left: 19,
          top: 53 + _float(1.2, 6),
          child: _SecurityShield(pulse: _pulseController.value),
        ),
        Positioned(
          right: 18,
          top: 57 + _float(2.5, 6),
          child: const _LockBubble(),
        ),
        Positioned(
          left: 9,
          bottom: 56 + _float(3.1, 7),
          child: const _VerifiedPaymentCard(),
        ),
        Positioned(
          right: 5,
          bottom: 48 + _float(1.5, 8),
          child: const _EncryptedBubble(),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 18,
          child: Center(
            child: _SecurityCore(
              pulse: _pulseController.value,
              rotation: _rotationController.value,
            ),
          ),
        ),
        Positioned(
          left: 94,
          top: 45 + _float(0.8, 5),
          child: const _GlowSparkle(size: 14, color: Color(0xFF4F7CFF)),
        ),
        Positioned(
          right: 87,
          bottom: 105 + _float(2.5, 5),
          child: const _GlowSparkle(size: 15, color: Color(0xFF06B6D4)),
        ),
      ],
    );
  }

  Widget _buildDeliveryIllustration() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: 68 + _float(0, 4),
          child: const Center(child: _DeliveryTrackingCard()),
        ),
        Positioned(
          left: 10,
          bottom: 60 + _float(1.2, 8),
          child: const _PackageCard(),
        ),
        Positioned(
          right: 8,
          bottom: 58 + _float(2.8, 7),
          child: const _DestinationCard(),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: _DeliveryRoutePainter(progress: _motionController.value),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 18,
          child: Center(
            child: _DeliveryCore(
              pulse: _pulseController.value,
              rotation: _rotationController.value,
            ),
          ),
        ),
        Positioned(
          left: 73,
          top: 48 + _float(1.0, 5),
          child: const _GlowSparkle(size: 14, color: Color(0xFF4F7CFF)),
        ),
        Positioned(
          right: 77,
          top: 104 + _float(3.0, 5),
          child: const _GlowSparkle(size: 15, color: Color(0xFF8B5CF6)),
        ),
      ],
    );
  }
}

class _ThinkingAiCore extends StatelessWidget {
  const _ThinkingAiCore({required this.pulse, required this.rotation});

  final double pulse;
  final double rotation;

  @override
  Widget build(BuildContext context) {
    final scale = 1 + pulse * 0.07;

    return Transform.scale(
      scale: scale,
      child: SizedBox(
        width: 100,
        height: 76,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 76 + pulse * 9,
              height: 76 + pulse * 9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF8B5CF6)
                    .withValues(alpha: 0.05 + pulse * 0.035),
              ),
            ),
            Transform.rotate(
              angle: rotation * math.pi * 2,
              child: Container(
                width: 72,
                height: 38,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.28),
                    width: 1.1,
                  ),
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
            Transform.rotate(
              angle: -rotation * math.pi * 2,
              child: Container(
                width: 52,
                height: 68,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF4F7CFF).withValues(alpha: 0.18),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF8B5CF6),
                    Color(0xFF6D4AFF),
                    Color(0xFF4F7CFF),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.25),
                    blurRadius: 22,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: CustomPaint(
                painter: _ThinkingNetworkPainter(pulse: pulse),
              ),
            ),
            Positioned(
              top: 9,
              right: 9,
              child: Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Color(0xFF8BE9FF),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              left: 10,
              child: Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  color: Color(0xFF8B5CF6),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThinkingNetworkPainter extends CustomPainter {
  const _ThinkingNetworkPainter({required this.pulse});

  final double pulse;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final points = [
      center.translate(-9, -7),
      center.translate(0, -11),
      center.translate(10, -4),
      center.translate(7, 8),
      center.translate(-7, 10),
      center.translate(-12, 2),
    ];

    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.72)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    for (var i = 0; i < points.length; i++) {
      final next = points[(i + 1) % points.length];
      canvas.drawLine(points[i], next, linePaint);
      if (i.isEven) {
        canvas.drawLine(points[i], center, linePaint);
      }
    }

    for (var i = 0; i < points.length; i++) {
      canvas.drawCircle(
        points[i],
        2.2 + (i == 1 ? pulse * 0.7 : 0),
        Paint()..color = Colors.white,
      );
    }
    canvas.drawCircle(
      center,
      3.2 + pulse * 0.8,
      Paint()..color = const Color(0xFF8BE9FF),
    );
  }

  @override
  bool shouldRepaint(covariant _ThinkingNetworkPainter oldDelegate) {
    return oldDelegate.pulse != pulse;
  }
}

class _PreferenceCard extends StatelessWidget {
  const _PreferenceCard();

  @override
  Widget build(BuildContext context) {
    return _ProductPanel(
      width: 82,
      height: 92,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.tune_rounded, color: Color(0xFF4F7CFF), size: 23),
          const SizedBox(height: 7),
          _smallLine(42),
          const SizedBox(height: 5),
          _smallLine(29),
          const SizedBox(height: 5),
          _smallLine(35),
        ],
      ),
    );
  }

  Widget _smallLine(double width) {
    return Container(
      width: width,
      height: 4,
      decoration: BoxDecoration(
        color: const Color(0xFFE5EBFF),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 174,
      height: 202,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(27),
        border: Border.all(color: const Color(0xFFE8ECFF)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6D4AFF).withValues(alpha: 0.12),
            blurRadius: 35,
            offset: const Offset(0, 17),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6D4AFF), Color(0xFF4F7CFF)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'AI RECOMMENDS',
                  style: TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              const Icon(
                Icons.more_horiz_rounded,
                color: Color(0xFF9AA4B5),
                size: 17,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF1F4FF), Color(0xFFF7F1FF)],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Stack(
                children: [
                  const Center(child: _RecommendationProductVisual()),
                  Positioned(
                    top: 9,
                    left: 9,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '97% MATCH',
                        style: TextStyle(
                          color: Color(0xFF6D4AFF),
                          fontSize: 7,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              Expanded(
                child: Text(
                  'Perfect match',
                  style: TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF22C55E),
                size: 15,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecommendationProductVisual extends StatelessWidget {
  const _RecommendationProductVisual();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 82,
      height: 82,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.08),
            ),
          ),
          Container(
            width: 42,
            height: 49,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFF5B63E8)],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
          ),
          Positioned(
            top: 21,
            child: Container(
              width: 13,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NeuralBubble extends StatelessWidget {
  const _NeuralBubble({required this.pulse});

  final double pulse;

  @override
  Widget build(BuildContext context) {
    return _SmallFloatingPanel(
      width: 67,
      height: 62,
      child: CustomPaint(painter: _NeuralPainter(pulse: pulse)),
    );
  }
}

class _NeuralPainter extends CustomPainter {
  const _NeuralPainter({required this.pulse});

  final double pulse;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final nodes = [
      center.translate(-17, -10),
      center.translate(15, -15),
      center.translate(20, 14),
      center.translate(-14, 17),
      center,
    ];

    final linePaint = Paint()
      ..color = const Color(0xFF6D4AFF).withValues(alpha: 0.20)
      ..strokeWidth = 1.2;

    for (final node in nodes.take(4)) {
      canvas.drawLine(node, center, linePaint);
    }

    final colors = [
      const Color(0xFF4F7CFF),
      const Color(0xFF8B5CF6),
      const Color(0xFF06B6D4),
      const Color(0xFF4F7CFF),
      const Color(0xFF8B5CF6),
    ];

    for (var i = 0; i < nodes.length; i++) {
      canvas.drawCircle(
        nodes[i],
        i == 4 ? 5 + pulse * 1.5 : 3.2,
        Paint()..color = colors[i],
      );
    }
  }

  @override
  bool shouldRepaint(covariant _NeuralPainter oldDelegate) {
    return oldDelegate.pulse != pulse;
  }
}

class _MatchCard extends StatelessWidget {
  const _MatchCard();

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 0.06,
      child: _ProductPanel(
        width: 82,
        height: 87,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.thumb_up_alt_rounded,
              color: Color(0xFF8B5CF6),
              size: 23,
            ),
            const SizedBox(height: 6),
            const Text(
              '98%',
              style: TextStyle(
                color: Color(0xFF111827),
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Text(
              'MATCH',
              style: TextStyle(
                color: Color(0xFF8A94A6),
                fontSize: 7,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SecurePaymentCard extends StatelessWidget {
  const _SecurePaymentCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 178,
      height: 190,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFE4EAFE)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F7CFF).withValues(alpha: 0.11),
            blurRadius: 34,
            offset: const Offset(0, 17),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF4FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  color: Color(0xFF4F7CFF),
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'SECURE CHECKOUT',
                  style: TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              const Icon(
                Icons.verified_rounded,
                color: Color(0xFF22C55E),
                size: 17,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 78,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF4F7CFF), Color(0xFF6D4AFF)],
              ),
              borderRadius: BorderRadius.circular(17),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 13,
                  right: 14,
                  child: Container(
                    width: 22,
                    height: 17,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
                const Positioned(
                  left: 14,
                  bottom: 13,
                  child: Text(
                    '••••  4281',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 11),
          Row(
            children: [
              _securityLine(50),
              const SizedBox(width: 7),
              _securityLine(33),
              const Spacer(),
              const Text(
                'Encrypted',
                style: TextStyle(
                  color: Color(0xFF22A45A),
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _securityLine(double width) {
    return Container(
      width: width,
      height: 4,
      decoration: BoxDecoration(
        color: const Color(0xFFE5EAF5),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}

class _SecurityShield extends StatelessWidget {
  const _SecurityShield({required this.pulse});

  final double pulse;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 1 + pulse * 0.04,
      child: Container(
        width: 66,
        height: 76,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFDDE7FF)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4F7CFF).withValues(alpha: 0.10),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Center(
          child: Icon(Icons.shield_rounded, color: Color(0xFF4F7CFF), size: 35),
        ),
      ),
    );
  }
}

class _LockBubble extends StatelessWidget {
  const _LockBubble();

  @override
  Widget build(BuildContext context) {
    return _SmallFloatingPanel(
      width: 63,
      height: 60,
      child: const Center(
        child: Icon(Icons.lock_rounded, color: Color(0xFF6D4AFF), size: 25),
      ),
    );
  }
}

class _VerifiedPaymentCard extends StatelessWidget {
  const _VerifiedPaymentCard();

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.06,
      child: _ProductPanel(
        width: 84,
        height: 84,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.verified_rounded, color: Color(0xFF22C55E), size: 27),
            SizedBox(height: 5),
            Text(
              'VERIFIED',
              style: TextStyle(
                color: Color(0xFF111827),
                fontSize: 8,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EncryptedBubble extends StatelessWidget {
  const _EncryptedBubble();

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 0.07,
      child: _ProductPanel(
        width: 84,
        height: 84,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.security_rounded, color: Color(0xFF06B6D4), size: 25),
            SizedBox(height: 5),
            Text(
              'ENCRYPTED',
              style: TextStyle(
                color: Color(0xFF111827),
                fontSize: 7,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.7,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SecurityCore extends StatelessWidget {
  const _SecurityCore({required this.pulse, required this.rotation});

  final double pulse;
  final double rotation;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 1 + pulse * 0.06,
      child: SizedBox(
        width: 100,
        height: 74,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 76 + pulse * 8,
              height: 76 + pulse * 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF22C55E)
                    .withValues(alpha: 0.045 + pulse * 0.025),
              ),
            ),
            Transform.rotate(
              angle: rotation * math.pi * 2,
              child: Container(
                width: 69,
                height: 36,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF22C55E).withValues(alpha: 0.25),
                  ),
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
            Container(
              width: 47,
              height: 47,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF22C55E), Color(0xFF06B6D4)],
                ),
              ),
              child: const Icon(
                Icons.lock_rounded,
                color: Colors.white,
                size: 23,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeliveryTrackingCard extends StatelessWidget {
  const _DeliveryTrackingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 192,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFE7ECFF)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F7CFF).withValues(alpha: 0.11),
            blurRadius: 34,
            offset: const Offset(0, 17),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 31,
                height: 31,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF4FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.local_shipping_rounded,
                  color: Color(0xFF4F7CFF),
                  size: 17,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'ORDER TRACKING',
                  style: TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Color(0xFF22C55E),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF0F5FF), Color(0xFFF7F3FF)],
                ),
                borderRadius: BorderRadius.circular(17),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 17,
                    right: 17,
                    top: 38,
                    child: Container(
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4F7CFF), Color(0xFF8B5CF6)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const Positioned(
                    left: 13,
                    top: 31,
                    child: _RouteNode(
                      icon: Icons.storefront_rounded,
                      active: true,
                    ),
                  ),
                  const Positioned(
                    left: 69,
                    top: 31,
                    child: _RouteNode(
                      icon: Icons.local_shipping_rounded,
                      active: true,
                    ),
                  ),
                  const Positioned(
                    right: 12,
                    top: 31,
                    child: _RouteNode(icon: Icons.home_rounded, active: false),
                  ),
                  const Positioned(
                    left: 13,
                    bottom: 12,
                    child: Text(
                      'Shipped',
                      style: TextStyle(
                        color: Color(0xFF687386),
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Positioned(
                    right: 13,
                    bottom: 12,
                    child: Text(
                      'Arriving',
                      style: TextStyle(
                        color: Color(0xFF687386),
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteNode extends StatelessWidget {
  const _RouteNode({required this.icon, required this.active});

  final IconData icon;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF4F7CFF) : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: active ? const Color(0xFF4F7CFF) : const Color(0xFFDCE2EC),
        ),
      ),
      child: Icon(
        icon,
        size: 13,
        color: active ? Colors.white : const Color(0xFF9AA4B5),
      ),
    );
  }
}

class _PackageCard extends StatelessWidget {
  const _PackageCard();

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.06,
      child: _ProductPanel(
        width: 84,
        height: 88,
        child: CustomPaint(painter: _PackagePainter()),
      ),
    );
  }
}

class _DestinationCard extends StatelessWidget {
  const _DestinationCard();

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 0.06,
      child: _ProductPanel(
        width: 84,
        height: 88,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.location_on_rounded, color: Color(0xFF8B5CF6), size: 28),
            SizedBox(height: 5),
            Text(
              'DELIVERING',
              style: TextStyle(
                color: Color(0xFF111827),
                fontSize: 7,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.7,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PackagePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + 2);

    final box = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 42, height: 38),
      const Radius.circular(7),
    );

    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF6F8FFF), Color(0xFF5B63E8)],
      ).createShader(Rect.fromCenter(center: center, width: 42, height: 38));

    canvas.drawRRect(box, paint);

    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.72)
      ..strokeWidth = 2;

    canvas.drawLine(
      Offset(center.dx, center.dy - 19),
      Offset(center.dx, center.dy + 19),
      linePaint,
    );

    canvas.drawLine(
      Offset(center.dx - 20, center.dy - 4),
      Offset(center.dx + 20, center.dy - 4),
      linePaint,
    );

    canvas.drawCircle(
      center.translate(10, -10),
      3,
      Paint()..color = const Color(0xFF8BE9FF),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class _DeliveryRoutePainter extends CustomPainter {
  const _DeliveryRoutePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final start = Offset(78, 220);
    final end = Offset(size.width - 78, 220);

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(size.width / 2, 150, end.dx, end.dy);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0xFF4F7CFF).withValues(alpha: 0.16);

    canvas.drawPath(path, paint);

    final metrics = path.computeMetrics().first;
    final tangent = metrics.getTangentForOffset(metrics.length * progress);

    if (tangent != null) {
      canvas.drawCircle(
        tangent.position,
        3,
        Paint()..color = const Color(0xFF06B6D4),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DeliveryRoutePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _DeliveryCore extends StatelessWidget {
  const _DeliveryCore({required this.pulse, required this.rotation});

  final double pulse;
  final double rotation;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 1 + pulse * 0.06,
      child: SizedBox(
        width: 100,
        height: 74,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 74 + pulse * 8,
              height: 74 + pulse * 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF4F7CFF)
                    .withValues(alpha: 0.055 + pulse * 0.03),
              ),
            ),
            Transform.rotate(
              angle: rotation * math.pi * 2,
              child: Container(
                width: 69,
                height: 36,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.24),
                  ),
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
            Container(
              width: 47,
              height: 47,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF4F7CFF), Color(0xFF8B5CF6)],
                ),
              ),
              child: const Icon(
                Icons.local_shipping_rounded,
                color: Colors.white,
                size: 23,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// ============================================================================
// ATMOSPHERE
// ============================================================================

class _AtmospherePainter extends CustomPainter {
  const _AtmospherePainter({required this.pulse});

  final double pulse;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final blueRadius = 150 + (pulse * 10);
    final violetRadius = 135 + (pulse * 8);

    final bluePaint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              const Color(0xFF4F7CFF).withValues(alpha: 0.12),
              const Color(0xFF4F7CFF).withValues(alpha: 0),
            ],
          ).createShader(
            Rect.fromCircle(
              center: center.translate(-70, -35),
              radius: blueRadius,
            ),
          );

    canvas.drawCircle(center.translate(-70, -35), blueRadius, bluePaint);

    final violetPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              const Color(0xFF8B5CF6).withValues(alpha: 0.10),
              const Color(0xFF8B5CF6).withValues(alpha: 0),
            ],
          ).createShader(
            Rect.fromCircle(
              center: center.translate(75, 80),
              radius: violetRadius,
            ),
          );

    canvas.drawCircle(center.translate(75, 80), violetRadius, violetPaint);
  }

  @override
  bool shouldRepaint(covariant _AtmospherePainter oldDelegate) {
    return oldDelegate.pulse != pulse;
  }
}

// ============================================================================
// PARTICLES
// ============================================================================

class _ParticlePainter extends CustomPainter {
  const _ParticlePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final particles = [
      const _ParticleData(0.12, 0.18, 2.0, 0.0, Color(0xFF4F7CFF)),
      const _ParticleData(0.87, 0.20, 1.6, 1.4, Color(0xFF8B5CF6)),
      const _ParticleData(0.08, 0.65, 1.4, 2.2, Color(0xFF06B6D4)),
      const _ParticleData(0.91, 0.67, 1.8, 3.0, Color(0xFF4F7CFF)),
      const _ParticleData(0.23, 0.86, 1.2, 4.0, Color(0xFF8B5CF6)),
      const _ParticleData(0.78, 0.87, 1.4, 5.1, Color(0xFF06B6D4)),
      const _ParticleData(0.17, 0.40, 1.1, 2.7, Color(0xFF4F7CFF)),
      const _ParticleData(0.84, 0.43, 1.2, 4.5, Color(0xFF8B5CF6)),
    ];

    for (final particle in particles) {
      final wave = math.sin(progress * math.pi * 2 + particle.phase);

      final opacity = 0.18 + ((wave + 1) / 2) * 0.45;

      final paint = Paint()..color = particle.color.withValues(alpha: opacity);

      final position = Offset(
        size.width * particle.x,
        size.height * particle.y + wave * 5,
      );

      canvas.drawCircle(position, particle.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _ParticleData {
  const _ParticleData(this.x, this.y, this.radius, this.phase, this.color);

  final double x;
  final double y;
  final double radius;
  final double phase;
  final Color color;
}

class _DiscoveryProductCard extends StatelessWidget {
  const _DiscoveryProductCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 168,
      height: 205,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(27),
        border: Border.all(color: const Color(0xFFE9EEFF), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F7CFF).withValues(alpha: 0.12),
            blurRadius: 38,
            spreadRadius: 2,
            offset: const Offset(0, 18),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // AI badge
              Container(
                width: 31,
                height: 31,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4F7CFF), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: CustomPaint(painter: _MiniAiMarkPainter()),
              ),

              const SizedBox(width: 8),

              const Expanded(
                child: Text(
                  'AI PICK',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 0.6,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
              ),

              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Color(0xFF22C55E),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),

          const SizedBox(height: 11),

          // Product visual
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFF0F5FF), Color(0xFFF8F2FF)],
                ),
                borderRadius: BorderRadius.circular(19),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.82),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '98% MATCH',
                        style: TextStyle(
                          fontSize: 7,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF4F7CFF),
                        ),
                      ),
                    ),
                  ),

                  const Center(child: _PremiumProductVisual()),

                  Positioned(
                    right: 9,
                    top: 9,
                    child: Container(
                      width: 27,
                      height: 27,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_border_rounded,
                        size: 14,
                        color: Color(0xFF687386),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 9),

          Row(
            children: [
              const Expanded(
                child: Text(
                  'Smart choice',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'For You',
                  style: TextStyle(
                    fontSize: 7,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF5968D8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// PREMIUM PRODUCT VISUAL
// ============================================================================

class _PremiumProductVisual extends StatelessWidget {
  const _PremiumProductVisual();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 82,
      height: 82,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF4F7CFF).withValues(alpha: 0.14),
                  const Color(0xFF8B5CF6).withValues(alpha: 0.02),
                ],
              ),
            ),
          ),

          // Product body
          Container(
            width: 43,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF6C8DFF), Color(0xFF5B63E8)],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4F7CFF).withValues(alpha: 0.24),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
          ),

          // Product highlight
          Positioned(
            top: 20,
            left: 28,
            child: Container(
              width: 12,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          // Product shine
          Positioned(
            right: 20,
            bottom: 21,
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFF9FEAFF).withValues(alpha: 0.8),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// AI CORE
// ============================================================================

class _DiscoveryAiCore extends StatelessWidget {
  const _DiscoveryAiCore({required this.pulse, required this.rotation});

  final double pulse;
  final double rotation;

  @override
  Widget build(BuildContext context) {
    final scale = 1 + pulse * 0.08;

    return Transform.scale(
      scale: scale,
      child: SizedBox(
        width: 96,
        height: 72,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Glow
            Container(
              width: 74 + pulse * 8,
              height: 74 + pulse * 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF4F7CFF)
                    .withValues(alpha: 0.055 + pulse * 0.035),
              ),
            ),

            // Orbit ring
            Transform.rotate(
              angle: rotation * math.pi * 2,
              child: Container(
                width: 69,
                height: 35,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF4F7CFF).withValues(alpha: 0.28),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),

            // Core
            Container(
              width: 47,
              height: 47,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF4F7CFF),
                    Color(0xFF7657E8),
                    Color(0xFF8B5CF6),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4F7CFF).withValues(alpha: 0.25),
                    blurRadius: 22,
                  ),
                ],
              ),
              child: CustomPaint(painter: _AiNetworkMarkPainter()),
            ),

            // Orbiting dot
            Positioned(
              top: 14,
              right: 12,
              child: Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Color(0xFF8BE9FF),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// SEARCH BUBBLE
// ============================================================================

class _SearchBubble extends StatelessWidget {
  const _SearchBubble();

  @override
  Widget build(BuildContext context) {
    return _SmallFloatingPanel(
      width: 62,
      height: 54,
      child: CustomPaint(painter: _SearchIllustrationPainter()),
    );
  }
}

// ============================================================================
// FAVORITE BUBBLE
// ============================================================================

class _FavoriteBubble extends StatelessWidget {
  const _FavoriteBubble();

  @override
  Widget build(BuildContext context) {
    return _SmallFloatingPanel(
      width: 56,
      height: 50,
      child: CustomPaint(painter: _FavoriteIllustrationPainter()),
    );
  }
}

// ============================================================================
// AUDIO PRODUCT
// ============================================================================

class _AudioProductCard extends StatelessWidget {
  const _AudioProductCard();

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.07,
      child: _ProductPanel(
        width: 82,
        height: 91,
        child: CustomPaint(painter: _HeadphonePainter()),
      ),
    );
  }
}

// ============================================================================
// WATCH PRODUCT
// ============================================================================

class _WatchProductCard extends StatelessWidget {
  const _WatchProductCard();

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 0.07,
      child: _ProductPanel(
        width: 82,
        height: 91,
        child: CustomPaint(painter: _WatchPainter()),
      ),
    );
  }
}

// ============================================================================
// MINI PRODUCT
// ============================================================================

class _MiniProductCard extends StatelessWidget {
  const _MiniProductCard();

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 0.05,
      child: _ProductPanel(
        width: 68,
        height: 72,
        child: CustomPaint(painter: _ShoePainter()),
      ),
    );
  }
}

// ============================================================================
// COMMON PRODUCT PANEL
// ============================================================================

class _ProductPanel extends StatelessWidget {
  const _ProductPanel({
    required this.width,
    required this.height,
    required this.child,
  });

  final double width;
  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xFFECEFFF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.045),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ============================================================================
// SMALL FLOATING PANEL
// ============================================================================

class _SmallFloatingPanel extends StatelessWidget {
  const _SmallFloatingPanel({
    required this.width,
    required this.height,
    required this.child,
  });

  final double width;
  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.045),
            blurRadius: 17,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SearchIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2 - 5, size.height / 2 - 3);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF4F7CFF);

    canvas.drawCircle(center, 10, paint);

    canvas.drawLine(
      Offset(center.dx + 7, center.dy + 7),
      Offset(center.dx + 15, center.dy + 15),
      paint,
    );

    final sparklePaint = Paint()..color = const Color(0xFF8B5CF6);

    canvas.drawCircle(Offset(size.width - 13, 12), 3, sparklePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

// ============================================================================
// FAVORITE ILLUSTRATION
// ============================================================================

class _FavoriteIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();

    final centerX = size.width / 2;
    final top = size.height / 2 - 9;

    path.moveTo(centerX, size.height - 13);

    path.cubicTo(
      centerX - 24,
      size.height - 28,
      centerX - 22,
      top - 8,
      centerX - 10,
      top - 8,
    );

    path.cubicTo(centerX - 4, top - 8, centerX, top - 2, centerX, top + 3);

    path.cubicTo(centerX, top - 2, centerX + 4, top - 8, centerX + 10, top - 8);

    path.cubicTo(
      centerX + 22,
      top - 8,
      centerX + 24,
      size.height - 28,
      centerX,
      size.height - 13,
    );

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFFFEEF6);

    canvas.drawPath(path, paint);

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.7
      ..color = const Color(0xFFEC4899);

    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

// ============================================================================
// HEADPHONES
// ============================================================================

class _HeadphonePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF6366F1);

    final arcRect = Rect.fromCenter(
      center: center.translate(0, 2),
      width: 42,
      height: 43,
    );

    canvas.drawArc(arcRect, math.pi, math.pi, false, paint);

    final leftCup = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center.translate(-20, 10), width: 12, height: 22),
      const Radius.circular(6),
    );

    final rightCup = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center.translate(20, 10), width: 12, height: 22),
      const Radius.circular(6),
    );

    final cupPaint = Paint()..color = const Color(0xFF7C7FEA);

    canvas.drawRRect(leftCup, cupPaint);
    canvas.drawRRect(rightCup, cupPaint);

    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.45);

    canvas.drawCircle(center.translate(-20, 8), 2.5, highlightPaint);

    canvas.drawCircle(center.translate(20, 8), 2.5, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

// ============================================================================
// WATCH
// ============================================================================

class _WatchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final strapPaint = Paint()..color = const Color(0xFF263A72);

    final strap = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 21, height: 65),
      const Radius.circular(10),
    );

    canvas.drawRRect(strap, strapPaint);

    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF6F8FFF), Color(0xFF5861DD)],
      ).createShader(Rect.fromCenter(center: center, width: 43, height: 45));

    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 43, height: 45),
      const Radius.circular(13),
    );

    canvas.drawRRect(body, bodyPaint);

    final screen = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 31, height: 33),
      const Radius.circular(9),
    );

    canvas.drawRRect(screen, Paint()..color = const Color(0xFF111C3D));

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0xFF8BE9FF);

    canvas.drawCircle(center, 8, ringPaint);

    canvas.drawLine(center, center.translate(0, -5), ringPaint);

    canvas.drawLine(center, center.translate(4, 2), ringPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

// ============================================================================
// SHOE
// ============================================================================

class _ShoePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();

    path.moveTo(12, 38);
    path.cubicTo(18, 35, 22, 26, 27, 23);

    path.cubicTo(31, 20, 35, 25, 39, 29);

    path.cubicTo(44, 34, 53, 35, 58, 40);

    path.cubicTo(63, 45, 57, 50, 48, 50);

    path.lineTo(17, 50);

    path.cubicTo(8, 50, 6, 43, 12, 38);

    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF8B5CF6), Color(0xFF5F6BE7)],
      ).createShader(Rect.fromLTWH(5, 20, 58, 32));

    canvas.drawPath(path, paint);

    final solePaint = Paint()..color = const Color(0xFFE9ECFF);

    final sole = Path()
      ..moveTo(9, 44)
      ..quadraticBezierTo(32, 49, 59, 43)
      ..lineTo(61, 49)
      ..quadraticBezierTo(34, 57, 9, 50)
      ..close();

    canvas.drawPath(sole, solePaint);

    final lacePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(const Offset(29, 30), const Offset(40, 34), lacePaint);

    canvas.drawLine(const Offset(27, 34), const Offset(39, 38), lacePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

// ============================================================================
// AI MARK
// ============================================================================

class _MiniAiMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);

    canvas.drawCircle(center, 5, paint);

    canvas.drawLine(center.translate(-10, 0), center.translate(-5, 0), paint);

    canvas.drawLine(center.translate(5, 0), center.translate(10, 0), paint);

    canvas.drawLine(center.translate(0, -10), center.translate(0, -5), paint);

    canvas.drawLine(center.translate(0, 5), center.translate(0, 10), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

// ============================================================================
// AI NETWORK MARK
// ============================================================================

class _AiNetworkMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;

    final points = [
      center.translate(-9, -4),
      center.translate(0, -10),
      center.translate(9, -2),
      center.translate(5, 9),
      center.translate(-6, 8),
    ];

    for (var i = 0; i < points.length; i++) {
      canvas.drawLine(points[i], points[(i + 1) % points.length], paint);
    }

    for (final point in points) {
      canvas.drawCircle(point, 2.2, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

// ============================================================================
// SPARKLE
// ============================================================================

class _GlowSparkle extends StatelessWidget {
  const _GlowSparkle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _SparklePainter(color: color),
    );
  }
}

class _SparklePainter extends CustomPainter {
  const _SparklePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final path = Path();

    path.moveTo(center.dx, 0);
    path.quadraticBezierTo(center.dx + 2, center.dy - 2, size.width, center.dy);
    path.quadraticBezierTo(
      center.dx + 2,
      center.dy + 2,
      center.dx,
      size.height,
    );
    path.quadraticBezierTo(center.dx - 2, center.dy + 2, 0, center.dy);
    path.quadraticBezierTo(center.dx - 2, center.dy - 2, center.dx, 0);

    canvas.drawPath(path, Paint()..color = color.withValues(alpha: 0.72));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
