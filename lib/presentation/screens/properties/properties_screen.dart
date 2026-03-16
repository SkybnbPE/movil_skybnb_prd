import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../application/providers/property_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../domain/models/property_entity.dart';
import '../../../domain/models/monthly_statement_result.dart';
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

  void _goToDetail(
      BuildContext context, PropertyEntity property, MonthlyStatementResult statement) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            PropertyDetailScreen(property: property, statement: statement),
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
          : Column(
              children: [
                if (provider.availablePeriods.isNotEmpty)
                  PeriodSelector(
                    periods: provider.availablePeriods,
                    selectedPeriod: provider.selectedPeriod,
                    onChanged: (p) {
                      if (p != null) provider.changePeriod(p);
                    },
                  ),
                Expanded(
                  child: provider.properties.isEmpty
                      ? const Center(
                          child: Text(
                            AppStrings.noProperties,
                            style:
                                TextStyle(color: AppColors.textSecondary),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: provider.properties.length,
                          itemBuilder: (context, index) {
                            final property = provider.properties[index];
                            final statement =
                                provider.statements[property.id];
                            return PropertyListCard(
                              property: property,
                              statement: statement,
                              onTap: statement != null
                                  ? () => _goToDetail(
                                      context, property, statement)
                                  : null,
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
