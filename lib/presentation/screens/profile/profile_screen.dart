import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:skybnb/application/providers/auth_provider.dart';
import 'package:skybnb/core/constants/app_colors.dart';
import 'package:skybnb/core/constants/app_strings.dart';
import 'package:skybnb/domain/models/user/user_entity.dart';
import 'package:skybnb/presentation/shared/section_card.dart';

/// StatefulWidget: dispara carga del perfil al montar via initState.
/// El estado del usuario lo gestiona AuthProvider.
class ProfileScreen extends StatefulWidget {
  final String userId;
  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().loadProfile(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.profile,
            style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.currentUser == null
              ? const Center(child: Text(AppStrings.profileLoadError))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _ProfileAvatar(user: provider.currentUser!),
                      const SizedBox(height: 20),
                      Text(
                        provider.currentUser!.fullName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      const _VerifiedBadge(),
                      const SizedBox(height: 40),
                      _ContactInfoCard(user: provider.currentUser!),
                    ],
                  ),
                ),
    );
  }
}

// ─── Profile Avatar (Stateless) ──────────────────────────────────────────────

class _ProfileAvatar extends StatelessWidget {
  final UserEntity user;
  const _ProfileAvatar({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary, width: 3),
        color: AppColors.primaryLight,
      ),
      child: ClipOval(
        child: user.profilePictureUrl != null &&
                user.profilePictureUrl!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: user.profilePictureUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (_, __, ___) => _InitialsText(user.initials),
              )
            : _InitialsText(user.initials),
      ),
    );
  }
}

class _InitialsText extends StatelessWidget {
  final String initials;
  const _InitialsText(this.initials);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

// ─── Verified Badge (Stateless) ───────────────────────────────────────────────

class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified, color: AppColors.primary, size: 18),
          SizedBox(width: 6),
          Text(
            AppStrings.verifiedOwner,
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Contact Info Card (Stateless) ───────────────────────────────────────────

class _ContactInfoCard extends StatelessWidget {
  final UserEntity user;
  const _ContactInfoCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _ContactItem(
              icon: Icons.email_outlined,
              label: AppStrings.email,
              value: user.email),
          Divider(height: 1, color: Colors.grey.shade200),
          _ContactItem(
              icon: Icons.phone_outlined,
              label: AppStrings.phone,
              value: user.phone),
        ],
      ),
    );
  }
}

class _ContactItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ContactItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    )),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
