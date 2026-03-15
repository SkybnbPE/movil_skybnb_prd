import 'package:flutter/material.dart';

class PropertyCard extends StatelessWidget {
  final String title;
  final String location;
  final VoidCallback onTap;

  const PropertyCard({
    super.key,
    required this.title,
    required this.location,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Container(
          width: 60,
          height: 60,
          color: Colors.grey[300],
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(location),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}