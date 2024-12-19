import 'package:b_bot/controllers/user_control/login.dart';
import 'package:b_bot/screens/settings_screens/contact_support.dart';
import 'package:b_bot/screens/settings_screens/edit_profile.dart';
import 'package:b_bot/screens/settings_screens/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:b_bot/widgets/widgets.dart';
import '../controllers/user_controller.dart';
import '../structures/structs.dart' as structs;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Constants
  static const double _profileImageRadius = 65.0;
  static const EdgeInsets _screenPadding = EdgeInsets.only(
    top: 80.0,
    left: 16.0,
    right: 16.0,
    bottom: 16.0,
  );

  // State variables
  final UserController _userManager = UserController();
  final structs.User? samsarUser = UserController().currentUser;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      _userManager.signOut();
      if (context.mounted) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const LoginScreen())
        );
      }
    } catch (e) {
      if (context.mounted) showSnackBar(context, "Error signing out");
    }
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _signOut(context);
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }


  Widget _buildProfileImage() {
    return CircleAvatar(
      radius: _profileImageRadius,
      backgroundImage: samsarUser?.profileImage.isNotEmpty == true
          ? NetworkImage(samsarUser!.profileImage)
          : const AssetImage('assets/icons/default_profile_pic_man.png')
      as ImageProvider,
    );
  }

  Widget _buildUserInfo(ThemeData theme) {
    return Column(
      children: [
        Text(
          "${samsarUser!.firstName} ${samsarUser!.middleName}${samsarUser!.middleName != "" ? " " : ""}${samsarUser!.lastName}",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(samsarUser!.email, style: theme.textTheme.titleMedium),
      ],
    );
  }

  Widget _buildMenuItems(ThemeData theme) {
    return Column(
      children: [
        settingScreenItem(
          context,
          icon: Icons.settings,
          itemName: "Settings",
          page: const SettingsPage(),
        ),
        ListTile(
          leading: Icon(Icons.person_rounded, color: theme.primaryColor),
          title: Text("Personal Account", style: theme.textTheme.titleSmall),
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const EditProfileScreen()))
                .then((_) => _userManager.reloadUser());
          },
        ),
        settingScreenItem(
          context,
          icon: Icons.support_agent,
          itemName: "Contact Support",
          page: const ContactSupportScreen(),
        ),
        ListTile(
          leading: Icon(Icons.exit_to_app, color: theme.primaryColor),
          title: Text("Logout", style: theme.textTheme.titleSmall),
          onTap: () => _handleLogout(context),
        ),
      ],
    );

  }

  @override
  Widget build(BuildContext context) {
    if (samsarUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final theme = Theme.of(context);

    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Padding(
              padding: _screenPadding,
              child: Column(
                children: [
                  _buildProfileImage(),
                  const SizedBox(height: 12),
                  _buildUserInfo(theme),
                  const SizedBox(height: 14),
                  Divider(color: theme.primaryColorLight),
                  const SizedBox(height: 14),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildMenuItems(theme),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}