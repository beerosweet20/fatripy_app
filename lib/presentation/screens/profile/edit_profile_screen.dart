import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/firebase/auth_service.dart';
import '../../localization/app_localizations_ext.dart';
import '../../state/auth_providers.dart';
import '../../theme/responsive_scale.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _initialized = false;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() => _saving = true);
    try {
      await AuthService().updateProfile(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
      );
      if (mounted) {
        ref.invalidate(authStateProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.editProfileSuccess)),
        );
        Navigator.of(context).pop();
      }
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      final message = error.code == 'requires-recent-login'
          ? context.l10n.editProfileReauth
          : context.l10n.errorWithDetails(error.message ?? error.code);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.errorWithDetails(error.toString())),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scale = AppScale.of(context);
    final user = ref.watch(currentUserProvider);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final requiredMessage = isArabic
        ? 'هذا الحقل مطلوب'
        : 'This field is required';
    final invalidEmailMessage = isArabic
        ? 'صيغة البريد الإلكتروني غير صحيحة'
        : 'Invalid email format';

    if (!_initialized && user != null) {
      _nameController.text = user.displayName ?? '';
      _emailController.text = user.email ?? '';
      _initialized = true;
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.editProfileTitle)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(scale * 20),
          children: [
            TextFormField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(labelText: l10n.editProfileName),
              validator: (value) {
                if ((value ?? '').trim().isEmpty) {
                  return requiredMessage;
                }
                return null;
              },
            ),
            SizedBox(height: scale * 16),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _saving ? null : _save(),
              decoration: InputDecoration(
                labelText: l10n.editProfileEmail,
                helperText: l10n.editProfileEmailHint,
              ),
              validator: (value) {
                final text = (value ?? '').trim();
                if (text.isEmpty) {
                  return requiredMessage;
                }
                final valid = RegExp(
                  r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
                ).hasMatch(text);
                if (!valid) {
                  return invalidEmailMessage;
                }
                return null;
              },
            ),
            SizedBox(height: scale * 24),
            SizedBox(
              height: scale * 48,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const CircularProgressIndicator()
                    : Text(l10n.actionSave),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
