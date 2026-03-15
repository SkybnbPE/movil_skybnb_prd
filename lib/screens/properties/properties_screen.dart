import 'package:flutter/material.dart';
import '../../models/property.dart';
import '../../services/google_sheets_service.dart';
import 'property_detail_screen.dart';

class PropertiesScreen extends StatefulWidget {
  final String ownerId;

  const PropertiesScreen({
    super.key,
    required this.ownerId,
  });

  @override
  State<PropertiesScreen> createState() => _PropertiesScreenState();
}

class _PropertiesScreenState extends State<PropertiesScreen> {
  List<Property> properties = [];
  Map<String, MonthlyStatement> monthlyStatements = {};
  List<String> availablePeriods = [];
  String? selectedPeriod;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);

    try {
      // Cargar propiedades del owner
      final props = await GoogleSheetsService.getPropertiesByOwner(widget.ownerId);

      // Para cada propiedad, obtener periodos disponibles
      if (props.isNotEmpty) {
        final periods = await GoogleSheetsService.getAvailablePeriods(props.first.propertyId);
        
        // Seleccionar el periodo más reciente por defecto
        final selected = periods.isNotEmpty ? periods.first : null;

        // Cargar statement del periodo seleccionado
        final statements = <String, MonthlyStatement>{};
        if (selected != null) {
          for (var prop in props) {
            final statement = await GoogleSheetsService.getMonthlyStatement(
              prop.propertyId,
              selected,
            );
            statements[prop.propertyId] = statement;
          }
        }

        setState(() {
          properties = props;
          availablePeriods = periods;
          selectedPeriod = selected;
          monthlyStatements = statements;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos: $e')),
        );
      }
    }
  }

  Future<void> _onPeriodChanged(String? newPeriod) async {
    if (newPeriod == null || newPeriod == selectedPeriod) return;

    setState(() {
      selectedPeriod = newPeriod;
      isLoading = true;
    });

    // Recargar statements del nuevo periodo
    final statements = <String, MonthlyStatement>{};
    for (var prop in properties) {
      final statement = await GoogleSheetsService.getMonthlyStatement(
        prop.propertyId,
        newPeriod,
      );
      statements[prop.propertyId] = statement;
    }

    setState(() {
      monthlyStatements = statements;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Mis propiedades',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Dropdown de selección de mes
                _buildPeriodSelector(),
                
                // Lista de propiedades
                Expanded(
                  child: properties.isEmpty
                      ? const Center(
                          child: Text(
                            'No tienes propiedades registradas',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: properties.length,
                          itemBuilder: (context, index) {
                            final property = properties[index];
                            final statement = monthlyStatements[property.propertyId];
                            return _buildPropertyCard(property, statement);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          const Text(
            'Periodo:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedPeriod,
                  isExpanded: true,
                  items: availablePeriods.map((period) {
                    // Formatear periodo (ej: "2026-01" -> "Enero 2026")
                    final formatted = _formatPeriod(period);
                    return DropdownMenuItem(
                      value: period,
                      child: Text(formatted),
                    );
                  }).toList(),
                  onChanged: _onPeriodChanged,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyCard(Property property, MonthlyStatement? statement) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () {
          if (statement != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PropertyDetailScreen(
                  property: property,
                  statement: statement,
                ),
              ),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE91E63),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Imagen de la propiedad
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    property.photoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.image,
                        color: Colors.white,
                        size: 40,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Información de la propiedad
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      property.airbnbListingName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.white70,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${property.city}, ${property.country}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (statement != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Ingreso neto: S/ ${statement.netToOwner.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPeriod(String period) {
    final parts = period.split('-');
    if (parts.length != 2) return period;

    final year = parts[0];
    final month = int.parse(parts[1]);

    const monthNames = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];

    return '${monthNames[month - 1]} $year';
  }
}