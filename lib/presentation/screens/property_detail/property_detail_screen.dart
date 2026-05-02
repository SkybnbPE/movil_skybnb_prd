import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/models/property_entity.dart';
import '../../../application/providers/property_detail_provider.dart';
import 'widgets/detail_widgets.dart';

class PropertyDetailScreen extends StatefulWidget {
  final PropertyEntity property;

  const PropertyDetailScreen({
    super.key,
    required this.property,
  });

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PropertyDetailProvider>().loadData(widget.property);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PropertyDetailProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: const Text('Detalle',
            style: TextStyle(color: AppColors.textPrimary)),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => provider.loadData(widget.property),
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(), // Necesario para que el refresh funcione en pantallas cortas
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PropertyHeader(property: widget.property),
                    const SizedBox(height: 16),
                    PropertySummarySection(
                      totalIncome: provider.totalIncome,
                      totalReservations: provider.totalReservations,
                    ),
                    const SizedBox(height: 16),
                    ReservationPaginatedListSection(
                      reservations: provider.visibleReservations,
                      canLoadMore: provider.canLoadMore,
                      onLoadMore: provider.loadMore,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }
}
