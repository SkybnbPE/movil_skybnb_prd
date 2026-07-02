import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:skybnb/core/constants/app_colors.dart';
import 'package:skybnb/domain/models/property_entity.dart';
import 'package:skybnb/presentation/shared/section_card.dart';

class PropertyHeader extends StatelessWidget {
  final PropertyEntity property;
  const PropertyHeader({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Row(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: property.coverImage != null
                  ? CachedNetworkImage(
                      imageUrl: property.coverImage!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const Center(
                          child: CircularProgressIndicator(strokeWidth: 2)),
                      errorWidget: (_, __, ___) =>
                          const Icon(Icons.image, size: 40, color: Colors.white),
                    )
                  : const Icon(Icons.image, size: 40, color: Colors.white),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  property.name,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        size: 15, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        property.location.cityCountry,
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
