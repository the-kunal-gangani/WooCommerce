import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:magna_data_ai_ecommerce/features/onboarding/onboarding_controller.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  void _onIntroEnd(BuildContext context) {
    final controller = Get.isRegistered<OnboardingController>()
        ? Get.find<OnboardingController>()
        : Get.put(OnboardingController());

    controller.completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    final pageDecoration = PageDecoration(
      titleTextStyle: theme.textTheme.headlineMedium!.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.textTheme.titleLarge?.color,
      ),
      bodyTextStyle: theme.textTheme.bodyMedium!.copyWith(
        color: Colors.grey[600],
        height: 1.5,
      ),
      bodyPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      pageColor: theme.scaffoldBackgroundColor,
      imagePadding: const EdgeInsets.only(top: 40),
      imageFlex: 2,
      bodyFlex: 1,
    );

    return Scaffold(
      body: SafeArea(
        child: IntroductionScreen(
          globalBackgroundColor: theme.scaffoldBackgroundColor,
          allowImplicitScrolling: true,
          autoScrollDuration: 3000,
          infiniteAutoScroll: false,
          pages: [
            PageViewModel(
              title: "Discover Smart Products",
              body: "Explore thousands of curated items tailored to your lifestyle with our intelligent recommendation engine.",
              image: _buildIllustration(
                context,
                icon: Icons.search_rounded,
                bgColor: primaryColor.withValues(alpha: 0.2),
                iconColor: primaryColor,
              ),
              decoration: pageDecoration,
            ),
            PageViewModel(
              title: "AI-Powered Recommendations",
              body: "Our AI assistant analyzes your preferences to bring you personalized deals and personalized product picks.",
              image: _buildIllustration(
                context,
                icon: Icons.auto_awesome_rounded,
                bgColor: Colors.amber.withValues(alpha: 0.15),
                iconColor: Colors.amber[800]!,
              ),
              decoration: pageDecoration,
            ),
            PageViewModel(
              title: "Seamless & Secure Checkout",
              body: "Enjoy lightning-fast payments with end-to-end encryption and flexible digital wallet support.",
              image: _buildIllustration(
                context,
                icon: Icons.shield_outlined,
                bgColor: Colors.green.withValues(alpha: 0.15),
                iconColor: Colors.green[700]!,
              ),
              decoration: pageDecoration,
            ),
            PageViewModel(
              title: "Fast Doorstep Delivery",
              body: "Track your package in real-time from the warehouse directly to your home with live notifications.",
              image: _buildIllustration(
                context,
                icon: Icons.local_shipping_outlined,
                bgColor: Colors.blue.withValues(alpha: 0.15),
                iconColor: Colors.blue[700]!,
              ),
              decoration: pageDecoration,
            ),
          ],

          // Navigation callbacks
          onDone: () => _onIntroEnd(context),
          onSkip: () => _onIntroEnd(context),
          showSkipButton: true,
          skipOrBackFlex: 0,
          nextFlex: 0,

          // Customizing Controls / Buttons
          skip: Text(
            "Skip",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          next: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          done: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Text(
              "Get Started",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          // Customizing Page Indicators (Dots)
          dotsDecorator: DotsDecorator(
            size: const Size(10.0, 10.0),
            color: Colors.grey.shade300,
            activeSize: const Size(22.0, 10.0),
            activeColor: primaryColor,
            activeShape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(25.0)),
            ),
          ),
        ),
      ),
    );
  }

  // Reusable Graphic Placeholder Widget
  Widget _buildIllustration(
    BuildContext context, {
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
  }) {
    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
      child: Icon(icon, size: 100, color: iconColor),
    );
  }
}
