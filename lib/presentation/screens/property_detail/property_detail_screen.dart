import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/models/property_entity.dart';
import '../../../domain/models/monthly_statement_result.dart';
import 'widgets/detail_widgets.dart';

/// StatelessWidget: todos los datos llegan como parámetros ya resueltos.
/// No hace llamadas a red ni maneja estado mutable.
class PropertyDetailScreen extends StatelessWidget {
  final PropertyEntity property;
  final MonthlyStatementResult statement;

  const PropertyDetailScreen({
    super.key,
    required this.property,
    required this.statement,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: const Text('Detalle',
            style: TextStyle(color: AppColors.textPrimary)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            PropertyHeader(property: property),
            const SizedBox(height: 16),
            ReservationBoxesSection(statement: statement),
            const SizedBox(height: 16),
            ReservationListSection(reservations: statement.reservations),
            const SizedBox(height: 16),
            FinancialSummarySection(statement: statement),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
