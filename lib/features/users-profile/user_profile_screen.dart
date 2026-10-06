import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:magna_data_ai_ecommerce/core/routes/app_routes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const background = Color(0xFFF7F9FC);
  static const navy = Color(0xFF111827);
  static const muted = Color(0xFF687386);
  static const primary = Color(0xFF2563EB);
  static const violet = Color(0xFF6D4AFF);
  static const border = Color(0xFFE5EAF1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          _buildAmbientBackground(),
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildHeader()),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildQuickActions(),
                      const SizedBox(height: 20),
                      _buildAccountSection(),
                      const SizedBox(height: 20),
                      _buildPreferencesSection(),
                      const SizedBox(height: 20),
                      _buildSupportSection(),
                      const SizedBox(height: 20),
                      _buildLogoutButton(),
                      const SizedBox(height: 10),
                      _buildVersion(),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmbientBackground() {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    primary.withValues(alpha: 0.10),
                    primary.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 250,
            left: -130,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    violet.withValues(alpha: 0.07),
                    violet.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Profile',
                      style: TextStyle(
                        color: navy,
                        fontSize: 27,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.7,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Manage your account and preferences',
                      style: TextStyle(
                        color: muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              _buildHeaderButton(
                icon: Icons.settings_outlined,
                onTap: () {
                  Get.snackbar(
                    'Settings',
                    'Settings screen coming soon',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildProfileCard(),
        ],
      ),
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: border),
            boxShadow: [
              BoxShadow(
                color: navy.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Icon(Icons.settings_outlined, color: navy, size: 21),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: navy.withValues(alpha: 0.055),
            blurRadius: 24,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [primary, violet],
              ),
              boxShadow: [
                BoxShadow(
                  color: primary.withValues(alpha: 0.20),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'U',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back!',
                  style: TextStyle(
                    color: muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Your Account',
                  style: TextStyle(
                    color: navy,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Manage your shopping experience',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: const Color(0xFFF1F5FF),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () {
                Get.snackbar(
                  'Edit Profile',
                  'Profile editing coming soon',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: const SizedBox(
                width: 38,
                height: 38,
                child: Icon(Icons.edit_outlined, color: primary, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildQuickAction(
            icon: Icons.shopping_bag_outlined,
            title: 'Orders',
            subtitle: 'Track orders',
            onTap: () {
              Get.snackbar(
                'Orders',
                'Orders screen coming soon',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickAction(
            icon: Icons.favorite_border_rounded,
            title: 'Wishlist',
            subtitle: 'Saved items',
            onTap: () {
              Get.toNamed(AppRoutes.favourites);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: border),
            boxShadow: [
              BoxShadow(
                color: navy.withValues(alpha: 0.035),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5FF),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: primary, size: 21),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: navy,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: muted,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountSection() {
    return _buildSection(
      title: 'Account',
      icon: Icons.person_outline_rounded,
      children: [
        _buildMenuItem(
          icon: Icons.person_outline_rounded,
          title: 'Personal information',
          subtitle: 'Name, email and phone',
          onTap: () {
            Get.snackbar(
              'Personal Information',
              'Profile details screen coming soon',
              snackPosition: SnackPosition.BOTTOM,
            );
          },
        ),
        _buildDivider(),
        _buildMenuItem(
          icon: Icons.location_on_outlined,
          title: 'My addresses',
          subtitle: 'Manage delivery addresses',
          onTap: () {
            Get.snackbar(
              'Addresses',
              'Address management coming soon',
              snackPosition: SnackPosition.BOTTOM,
            );
          },
        ),
        _buildDivider(),
        _buildMenuItem(
          icon: Icons.credit_card_outlined,
          title: 'Payment methods',
          subtitle: 'Manage your payment options',
          onTap: () {
            Get.snackbar(
              'Payment Methods',
              'Payment management coming soon',
              snackPosition: SnackPosition.BOTTOM,
            );
          },
        ),
      ],
    );
  }

  Widget _buildPreferencesSection() {
    return _buildSection(
      title: 'Preferences',
      icon: Icons.tune_rounded,
      children: [
        _buildMenuItem(
          icon: Icons.notifications_none_rounded,
          title: 'Notifications',
          subtitle: 'Offers, orders and updates',
          trailing: _buildToggle(),
          onTap: () {},
        ),
        _buildDivider(),
        _buildMenuItem(
          icon: Icons.language_rounded,
          title: 'Language',
          subtitle: 'English',
          onTap: () {
            Get.snackbar(
              'Language',
              'Language selection coming soon',
              snackPosition: SnackPosition.BOTTOM,
            );
          },
        ),
        _buildDivider(),
        _buildMenuItem(
          icon: Icons.dark_mode_outlined,
          title: 'Appearance',
          subtitle: 'Light mode',
          onTap: () {
            Get.snackbar(
              'Appearance',
              'Theme settings coming soon',
              snackPosition: SnackPosition.BOTTOM,
            );
          },
        ),
      ],
    );
  }

  Widget _buildSupportSection() {
    return _buildSection(
      title: 'Support',
      icon: Icons.support_agent_rounded,
      children: [
        _buildMenuItem(
          icon: Icons.help_outline_rounded,
          title: 'Help center',
          subtitle: 'Get answers to common questions',
          onTap: () {
            Get.snackbar(
              'Help Center',
              'Help center coming soon',
              snackPosition: SnackPosition.BOTTOM,
            );
          },
        ),
        _buildDivider(),
        _buildMenuItem(
          icon: Icons.chat_bubble_outline_rounded,
          title: 'Contact support',
          subtitle: 'We are here to help',
          onTap: () {
            Get.snackbar(
              'Support',
              'Support chat coming soon',
              snackPosition: SnackPosition.BOTTOM,
            );
          },
        ),
        _buildDivider(),
        _buildMenuItem(
          icon: Icons.info_outline_rounded,
          title: 'About Magna Data Store',
          subtitle: 'Learn more about the app',
          onTap: () {
            Get.snackbar(
              'About',
              'Magna Data Store',
              snackPosition: SnackPosition.BOTTOM,
            );
          },
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: navy.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 15, 16, 12),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        primary.withValues(alpha: 0.11),
                        violet.withValues(alpha: 0.09),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: primary, size: 18),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    color: navy,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFD),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: const Color(0xFF536176), size: 19),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: navy,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: muted,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              trailing ??
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF9AA4B2),
                    size: 21,
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.only(left: 66),
      child: Divider(height: 1, thickness: 0.7, color: border),
    );
  }

  Widget _buildToggle() {
    return Container(
      width: 42,
      height: 24,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          width: 18,
          height: 18,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: () {
          Get.dialog(
            AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'Sign out?',
                style: TextStyle(color: navy, fontWeight: FontWeight.w800),
              ),
              content: const Text(
                'Are you sure you want to sign out of your account?',
                style: TextStyle(color: muted, height: 1.4),
              ),
              actions: [
                TextButton(onPressed: Get.back, child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
                    Get.back();

                    Get.snackbar(
                      'Signed out',
                      'You have been signed out successfully',
                      snackPosition: SnackPosition.BOTTOM,
                    );

                    // Connect your real logout controller here.
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFF1F2),
                    foregroundColor: const Color(0xFFE11D48),
                    elevation: 0,
                  ),
                  child: const Text('Sign out'),
                ),
              ],
            ),
          );
        },
        borderRadius: BorderRadius.circular(17),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: const Color(0xFFF2CDD5)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, color: Color(0xFFE11D48), size: 19),
              SizedBox(width: 8),
              Text(
                'Sign out',
                style: TextStyle(
                  color: Color(0xFFE11D48),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVersion() {
    return const Center(
      child: Text(
        'Magna Data Store • Version 1.0.0',
        style: TextStyle(
          color: Color(0xFF9AA4B2),
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
