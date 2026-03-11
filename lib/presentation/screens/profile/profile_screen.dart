import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/firebase/auth_service.dart';
import '../../localization/app_localizations_ext.dart';
import '../../theme/responsive_scale.dart';

const Color _cream = Color(0xFFFFF7E5);
const Color _header = Color(0xFFFFDC91);
const Color _text = Color(0xFF111111);
const Color _navy = Color(0xFF31487A);
const Color _frame = Color(0xFFE18299);
const Color _shape = Color(0xFFF5C9D4);

const double _titleSize = 28;
const double _nameSize = 24;
const double _emailSize = 14;
const double _itemFontSize = 17;
const double _itemHeight = 64;
const double _iconBoxSize = 48;
const double _iconBoxRadius = 16;
const double _iconSize = 23;
const double _chevronSize = 24;

class ProfileScreen extends StatefulWidget {
  final String displayName;
  final String? email;

  const ProfileScreen({super.key, required this.displayName, this.email});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;

  void _handleBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  Future<void> _confirmDeleteAccount() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.accountDeleteAccount),
        content: Text(context.l10n.deleteAccountConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.l10n.actionDelete),
          ),
        ],
      ),
    );

    if (result != true) {
      return;
    }

    try {
      await AuthService().deleteCurrentUser();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.deleteAccountSuccess)),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.errorWithDetails(error.toString())),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final showBack = context.canPop();
    final scale = AppScale.of(context);
    double s(double value) => value * scale;
    double sc(double value, double min, double max) =>
        (value * scale).clamp(min, max).toDouble();

    return Scaffold(
      backgroundColor: _cream,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            SizedBox(height: MediaQuery.paddingOf(context).top),
            Container(
              width: double.infinity,
              height: s(54),
              color: _header,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (showBack)
                    Positioned(
                      left: s(6),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back, color: _text, size: s(24)),
                        onPressed: _handleBack,
                      ),
                    ),
                  Text(
                    l10n.accountTitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inriaSerif(
                      fontSize: s(_titleSize),
                      fontWeight: FontWeight.w700,
                      color: _text,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  s(20),
                  s(18),
                  s(20),
                  s(18) + MediaQuery.paddingOf(context).bottom,
                ),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () => context.push('/edit-profile'),
                      borderRadius: BorderRadius.circular(s(80)),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: s(8),
                          vertical: s(2),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: s(108),
                              height: s(108),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const RadialGradient(
                                  colors: [
                                    Color(0xFFE5E5E5),
                                    Color(0xFFBDBDBD),
                                  ],
                                  center: Alignment(-0.2, -0.2),
                                  radius: 0.85,
                                ),
                                border: Border.all(
                                  color: _frame,
                                  width: sc(3, 2.4, 3.6),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.12),
                                    blurRadius: s(7),
                                    offset: Offset(0, s(3)),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.person,
                                  size: s(50),
                                  color: const Color(0xFFF2F2F2),
                                ),
                              ),
                            ),
                            SizedBox(height: s(10)),
                            Text(
                              widget.displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inriaSerif(
                                fontSize: s(_nameSize),
                                fontWeight: FontWeight.w700,
                                color: _text,
                                height: 1.0,
                              ),
                            ),
                            if ((widget.email ?? '').isNotEmpty) ...[
                              SizedBox(height: s(3)),
                              Text(
                                widget.email!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inriaSerif(
                                  fontSize: s(_emailSize),
                                  fontWeight: FontWeight.w400,
                                  color: _text,
                                  height: 1.1,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: s(18)),
                    _AccountPillTile(
                      icon: Icons.edit_outlined,
                      label: l10n.settingsEditProfile,
                      trailing: Icon(
                        Icons.chevron_right,
                        color: _navy,
                        size: s(_chevronSize),
                      ),
                      onTap: () => context.push('/edit-profile'),
                    ),
                    SizedBox(height: s(10)),
                    _AccountPillTile(
                      icon: Icons.notifications_none,
                      label: l10n.accountNotifications,
                      trailing: _NotificationSwitch(
                        value: _notificationsEnabled,
                        onChanged: (value) {
                          setState(() => _notificationsEnabled = value);
                        },
                      ),
                    ),
                    SizedBox(height: s(10)),
                    _AccountPillTile(
                      icon: Icons.group_outlined,
                      label: l10n.accountDependents,
                      trailing: Icon(
                        Icons.chevron_right,
                        color: _navy,
                        size: s(_chevronSize),
                      ),
                      onTap: () => context.push('/dependents'),
                    ),
                    SizedBox(height: s(10)),
                    _AccountPillTile(
                      icon: Icons.settings_outlined,
                      label: l10n.accountSettingsPrivacy,
                      trailing: Icon(
                        Icons.chevron_right,
                        color: _navy,
                        size: s(_chevronSize),
                      ),
                      onTap: () => context.push('/settings'),
                    ),
                    SizedBox(height: s(10)),
                    _AccountPillTile(
                      icon: Icons.person_pin_circle_outlined,
                      label: l10n.accountBookedAttraction,
                      trailing: Icon(
                        Icons.chevron_right,
                        color: _navy,
                        size: s(_chevronSize),
                      ),
                      onTap: () => context.push('/bookings'),
                    ),
                    FutureBuilder<bool>(
                      future: AuthService().isAdmin(),
                      builder: (context, snapshot) {
                        final isAdmin = snapshot.data == true;
                        if (!isAdmin) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: EdgeInsets.only(top: s(10)),
                          child: _AccountPillTile(
                            icon: Icons.admin_panel_settings_outlined,
                            label: l10n.profileAdminDashboard,
                            trailing: Icon(
                              Icons.chevron_right,
                              color: _navy,
                              size: s(_chevronSize),
                            ),
                            onTap: () => context.push('/admin'),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: s(10)),
                    _AccountPillTile(
                      icon: Icons.delete_outline,
                      label: l10n.accountDeleteAccount,
                      trailing: Icon(
                        Icons.chevron_right,
                        color: _navy,
                        size: s(_chevronSize),
                      ),
                      onTap: _confirmDeleteAccount,
                    ),
                    SizedBox(height: s(10)),
                    _AccountPillTile(
                      icon: Icons.logout,
                      label: l10n.logout,
                      trailing: Icon(
                        Icons.chevron_right,
                        color: _navy,
                        size: s(_chevronSize),
                      ),
                      onTap: () async {
                        await AuthService().signOut();
                        if (context.mounted) {
                          // Router redirect handles sign-out.
                        }
                      },
                    ),
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

class _AccountPillTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _AccountPillTile({
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppScale.of(context);
    double s(double value) => value * scale;
    double sc(double value, double min, double max) =>
        (value * scale).clamp(min, max).toDouble();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(s(24)),
      child: Container(
        height: s(_itemHeight),
        padding: EdgeInsets.symmetric(horizontal: s(10)),
        decoration: BoxDecoration(
          color: _cream,
          borderRadius: BorderRadius.circular(s(24)),
          border: Border.all(color: _frame, width: sc(2.4, 2.0, 2.8)),
        ),
        child: Row(
          children: [
            Container(
              width: s(_iconBoxSize),
              height: s(_iconBoxSize),
              decoration: BoxDecoration(
                color: _shape,
                borderRadius: BorderRadius.circular(s(_iconBoxRadius)),
                border: Border.all(color: _frame, width: sc(2.2, 1.8, 2.6)),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: s(_iconSize), color: _navy),
            ),
            SizedBox(width: s(14)),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inriaSerif(
                  fontSize: s(_itemFontSize),
                  fontWeight: FontWeight.w600,
                  color: _text,
                  height: 1.0,
                ),
              ),
            ),
            SizedBox(width: s(8)),
            SizedBox(
              width: s(44),
              child: Align(
                alignment: Alignment.centerRight,
                child: trailing ?? const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotificationSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final scale = AppScale.of(context);
    return Transform.scale(
      scale: 0.8 * scale,
      child: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: Colors.white,
        inactiveThumbColor: Colors.white,
        activeTrackColor: const Color(0xFFE18299),
        inactiveTrackColor: const Color(0xFFF5C9D4),
        trackOutlineColor: WidgetStateProperty.all(const Color(0xFFE18299)),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
