import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:magna_data_ai_ecommerce/core/routes/app_routes.dart';
import 'package:magna_data_ai_ecommerce/core/services/auth_service.dart';
import 'package:magna_data_ai_ecommerce/core/services/push_notification_service.dart';
import 'package:magna_data_ai_ecommerce/features/main/main_shell_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  static const background = Color(0xFFF7F9FC);
  static const navy = Color(0xFF111827);
  static const muted = Color(0xFF687386);
  static const primary = Color(0xFF2563EB);
  static const violet = Color(0xFF6D4AFF);
  static const border = Color(0xFFE7EBF1);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final pushService = Get.find<PushNotificationService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProfileScreen.background,
      body: Stack(
        children: [
          _buildAmbientBackground(),
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildHeader()),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildQuickActions(),
                      const SizedBox(height: 28),
                      _buildSectionHeading(
                        title: 'Your account',
                        subtitle: 'Everything you need to manage your account',
                      ),
                      const SizedBox(height: 14),
                      _buildAccountSection(),
                      const SizedBox(height: 26),
                      _buildSectionHeading(
                        title: 'Preferences',
                        subtitle: 'Make your shopping experience yours',
                      ),
                      const SizedBox(height: 14),
                      _buildPreferencesSection(),
                      const SizedBox(height: 26),
                      _buildSectionHeading(
                        title: 'Need a hand?',
                        subtitle: 'We are here whenever you need us',
                      ),
                      const SizedBox(height: 14),
                      _buildSupportSection(),
                      const SizedBox(height: 24),
                      _buildLogoutButton(),
                      const SizedBox(height: 18),
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
            top: -110,
            right: -100,
            child: Container(
              width: 270,
              height: 270,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    ProfileScreen.primary.withValues(alpha: 0.09),
                    ProfileScreen.primary.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 340,
            left: -150,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    ProfileScreen.violet.withValues(alpha: 0.055),
                    ProfileScreen.violet.withValues(alpha: 0),
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
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                        color: ProfileScreen.navy,
                        fontSize: 27,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.7,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Manage your account and preferences',
                      style: TextStyle(
                        color: ProfileScreen.muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          _buildProfileCard(),
        ],
      ),
    );
  }

  // Widget _buildHeaderButton({
  //   required IconData icon,
  //   required VoidCallback onTap,
  // }) {
  //   return Material(
  //     color: Colors.white,
  //     borderRadius: BorderRadius.circular(15),
  //     child: InkWell(
  //       onTap: onTap,
  //       borderRadius: BorderRadius.circular(15),
  //       child: Container(
  //         width: 46,
  //         height: 46,
  //         decoration: BoxDecoration(
  //           borderRadius: BorderRadius.circular(15),
  //           border: Border.all(color: ProfileScreen.border),
  //           boxShadow: [
  //             BoxShadow(
  //               color: ProfileScreen.navy.withValues(alpha: 0.04),
  //               blurRadius: 14,
  //               offset: const Offset(0, 5),
  //             ),
  //           ],
  //         ),
  //         child: Icon(icon, color: ProfileScreen.navy, size: 21),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildProfileCard() {
    return Obx(() {
      final user = Get.find<AuthService>().user.value;
      final name = (user?.fullName ?? '').trim();
      final email = (user?.email ?? '').trim();
      final phone = (user?.phone ?? '').trim();

      final displayName = name.isNotEmpty
          ? name
          : email.isNotEmpty
          ? email.split('@').first
          : 'Your Account';

      final initial = displayName.isNotEmpty
          ? displayName[0].toUpperCase()
          : 'U';

      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: ProfileScreen.border),
          boxShadow: [
            BoxShadow(
              color: ProfileScreen.navy.withValues(alpha: 0.045),
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 66,
              height: 66,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [ProfileScreen.primary, ProfileScreen.violet],
                ),
                boxShadow: [
                  BoxShadow(
                    color: ProfileScreen.primary.withValues(alpha: 0.19),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome back!',
                    style: TextStyle(
                      color: ProfileScreen.muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: ProfileScreen.navy,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email.isNotEmpty
                        ? email
                        : phone.isNotEmpty
                        ? phone
                        : 'Manage your shopping experience',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: ProfileScreen.muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: const Color(0xFFF1F5FF),
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () => Get.toNamed(AppRoutes.editProfile),
                borderRadius: BorderRadius.circular(12),
                child: const SizedBox(
                  width: 38,
                  height: 38,
                  child: Icon(
                    Icons.edit_outlined,
                    color: ProfileScreen.primary,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSectionHeading({
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: ProfileScreen.navy,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: ProfileScreen.muted,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildQuickAction(
            icon: Icons.shopping_bag_outlined,
            title: 'Orders',
            subtitle: 'Track your orders',
            onTap: () => Get.toNamed(AppRoutes.orders),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickAction(
            icon: Icons.favorite_border_rounded,
            title: 'Wishlist',
            subtitle: 'Your saved items',
            onTap: () => Get.find<MainShellController>().goTo(2),
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
      borderRadius: BorderRadius.circular(19),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(19),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(19),
            border: Border.all(color: ProfileScreen.border),
            boxShadow: [
              BoxShadow(
                color: ProfileScreen.navy.withValues(alpha: 0.035),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ProfileScreen.primary.withValues(alpha: 0.12),
                      ProfileScreen.violet.withValues(alpha: 0.09),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: ProfileScreen.primary, size: 21),
              ),
              const SizedBox(height: 13),
              Text(
                title,
                style: const TextStyle(
                  color: ProfileScreen.navy,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: ProfileScreen.muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
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
      icon: Icons.person_outline_rounded,
      children: [
        _buildMenuItem(
          icon: Icons.person_outline_rounded,
          title: 'Personal information',
          subtitle: 'Name, email and phone',
          onTap: () => Get.toNamed(AppRoutes.editProfile),
        ),
        _buildDivider(),
        _buildMenuItem(
          icon: Icons.location_on_outlined,
          title: 'My addresses',
          subtitle: 'Manage delivery addresses',
          onTap: () => Get.toNamed(AppRoutes.myAddresses),
        ),
        _buildDivider(),
        _buildMenuItem(
          icon: Icons.credit_card_outlined,
          title: 'Payment methods',
          subtitle: 'Manage your payment options',
          onTap: () => Get.toNamed(AppRoutes.paymentMethods),
        ),
      ],
    );
  }

  Widget _buildPreferencesSection() {
    return _buildSection(
      icon: Icons.tune_rounded,
      children: [
        Obx(() {
          final enabled = pushService.notificationsEnabled.value;

          return _buildMenuItem(
            icon: Icons.notifications_active_outlined,
            title: 'Notifications',
            subtitle: enabled
                ? 'Offers, orders and updates'
                : 'Notifications are turned off',
            trailing: Transform.scale(
              scale: 0.9,
              child: Switch(
                value: enabled,
                onChanged: (value) async {
                  await pushService.setNotificationsEnabled(value);
                },
                activeTrackColor: ProfileScreen.primary,
                inactiveTrackColor: const Color(0xFFE5EAF1),
                activeThumbColor: Colors.white,
                inactiveThumbColor: Colors.white,
                trackOutlineColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return ProfileScreen.primary;
                  }
                  return const Color(0xFFD5DCE7);
                }),
                trackOutlineWidth: const WidgetStatePropertyAll(1),
              ),
            ),
            onTap: () {
              Get.toNamed(AppRoutes.notifications);
            },
          );
        }),
        _buildDivider(),
        _buildMenuItem(
          icon: Icons.language_rounded,
          title: 'Language',
          subtitle: 'English',
          onTap: () =>
              _showComingSoon('Language', 'Language selection coming soon'),
        ),
        _buildDivider(),
        _buildMenuItem(
          icon: Icons.palette_outlined,
          title: 'Appearance',
          subtitle: 'Light mode',
          onTap: () =>
              _showComingSoon('Appearance', 'Theme settings coming soon'),
        ),
      ],
    );
  }

  Widget _buildSupportSection() {
    return _buildSection(
      icon: Icons.support_agent_rounded,
      children: [
        _buildMenuItem(
          icon: Icons.help_outline_rounded,
          title: 'Help center',
          subtitle: 'Answers to common questions',
          onTap: () =>
              _showComingSoon('Help Center', 'Help center coming soon'),
        ),
        _buildDivider(),
        _buildMenuItem(
          icon: Icons.chat_bubble_outline_rounded,
          title: 'Contact support',
          subtitle: 'We are here to help',
          onTap: () => _showComingSoon('Support', 'Support chat coming soon'),
        ),
        _buildDivider(),
        _buildMenuItem(
          icon: Icons.info_outline_rounded,
          title: 'About Magna Data Store',
          subtitle: 'Learn more about the app',
          onTap: () => _showComingSoon('About', 'Magna Data Store'),
        ),
      ],
    );
  }

  Widget _buildSection({
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: ProfileScreen.border),
        boxShadow: [
          BoxShadow(
            color: ProfileScreen.navy.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 6),
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
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ProfileScreen.primary.withValues(alpha: 0.12),
                        ProfileScreen.violet.withValues(alpha: 0.09),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(icon, color: ProfileScreen.primary, size: 19),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Manage your options',
                    style: TextStyle(
                      color: ProfileScreen.navy,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
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
                width: 39,
                height: 39,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F9FC),
                  borderRadius: BorderRadius.circular(12),
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
                        color: ProfileScreen.navy,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: ProfileScreen.muted,
                        fontSize: 10,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
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
      padding: EdgeInsets.only(left: 67),
      child: Divider(height: 1, thickness: 0.7, color: ProfileScreen.border),
    );
  }

  Widget _buildLogoutButton() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: _confirmLogout,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          height: 53,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: const Color(0xFFF2CDD5)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, color: Color(0xFFE11D48), size: 19),
              SizedBox(width: 9),
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

  void _confirmLogout() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(21)),
        title: const Text(
          'Sign out?',
          style: TextStyle(
            color: ProfileScreen.navy,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: const Text(
          'Are you sure you want to sign out of your account?',
          style: TextStyle(color: ProfileScreen.muted, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: ProfileScreen.muted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await Get.find<AuthService>().logout();
              Get.offAllNamed(AppRoutes.login);
            },
            child: const Text(
              'Sign out',
              style: TextStyle(
                color: Color(0xFFE11D48),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersion() {
    return const Center(
      child: Text(
        'Magna Data Store  •  Version 1.0.0',
        style: TextStyle(
          color: Color(0xFF9AA4B2),
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _showComingSoon(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 14,
      backgroundColor: Colors.white,
      colorText: ProfileScreen.navy,
    );
  }
}
