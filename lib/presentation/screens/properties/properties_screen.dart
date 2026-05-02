import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../application/providers/property_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../domain/models/property_entity.dart';
import '../../../core/service_locator.dart';
import '../property_detail/property_detail_screen.dart';
import 'widgets/properties_widgets.dart';

/// StatefulWidget: dispara la carga de datos al entrar y observa el Provider.
class PropertiesScreen extends StatefulWidget {
  final String userId;
  const PropertiesScreen({super.key, required this.userId});

  @override
  State<PropertiesScreen> createState() => _PropertiesScreenState();
}

class _PropertiesScreenState extends State<PropertiesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PropertyProvider>().loadData(widget.userId);
    });
  }

  void _goToDetail(BuildContext context, PropertyEntity property) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => ServiceLocator.createPropertyDetailProvider(),
          child: PropertyDetailScreen(property: property),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PropertyProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(AppStrings.myProperties,
            style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        automaticallyImplyLeading: false,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.properties.isEmpty
              ? const Center(
                  child: Text(
                    AppStrings.noProperties,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => provider.loadData(widget.userId),
                  color: AppColors.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.properties.length,
                    itemBuilder: (context, index) {
                      final property = provider.properties[index];
                      return PropertyListCard(
                        property: property,
                        onTap: () => _goToDetail(context, property),
                      );
                    },
                  ),
                ),
    );
  }
}
