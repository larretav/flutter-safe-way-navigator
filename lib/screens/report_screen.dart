import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safe_way_navigator/providers/map_provider.dart';
import 'package:safe_way_navigator/enum/report-severity.enum.dart';
import 'package:widgets_easier/widgets_easier.dart';



typedef MenuEntry = DropdownMenuEntry<String>;
const List<String> incidentTypes = [
  "Accidente",
  "Embotellamiento",
  "Inundación",
  "Obra/Construcción",
  "Bache"
];

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _incidentType;
  String? _location = "Blvd. Francisco Agraz, Tepeca, 81248 Los Mochis, Sin.";
  ReportSeverity severity = ReportSeverity.mild;
  final TextEditingController _descriptionController = TextEditingController();

  static final List<MenuEntry> incidentMenuEntries = UnmodifiableListView(
    incidentTypes.map((String name) => MenuEntry(value: name, label: name)),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text("Reportar incidente"),
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 16),

              // Ubicación
              const Text("Ubicación",
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              const CurrentAddress(),
              const SizedBox(height: 16),

              // Tipo de incidente
              const Text("Tipo de incidente",
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Expanded(
                child: DropdownMenu<String>(
                  expandedInsets: EdgeInsets.zero,
                  initialSelection: incidentTypes.first,
                  onSelected: (value) {
                    setState(() {
                      _incidentType = value!;
                    });
                  },
                  dropdownMenuEntries: incidentMenuEntries,
                  inputDecorationTheme: const InputDecorationTheme(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    ),
                  ),
                  menuStyle: const MenuStyle(
                    // alignment: AlignmentDirectional.topStart,
                    backgroundColor: WidgetStatePropertyAll(Colors.white),
                    maximumSize: WidgetStatePropertyAll(
                      Size(double.infinity, 300), // ✅ fuerza ancho completo
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              // Gravedad (leve, moderado, grave)
              const Text("Gravedad",
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),

              SegmentedButton(
                segments: const <ButtonSegment<ReportSeverity>>[
                  ButtonSegment(
                    value: ReportSeverity.mild,
                    label: Text('Leve'),
                  ),
                  ButtonSegment(
                    value: ReportSeverity.moderate,
                    label: Text('Moderado'),
                  ),
                  ButtonSegment(
                    value: ReportSeverity.severe,
                    label: Text('Grave'),
                  ),
                ],
                style: SegmentedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                ),
                selected: <ReportSeverity>{severity},
                onSelectionChanged: (newSelection) {
                  setState(() {
                    severity = newSelection.first;
                  });
                },
              ),

              const SizedBox(height: 16),

              // Descripción breve
              const Text("Descripción breve (opcional)",
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "Agrega más detalles...",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12.0))),
                ),
              ),

              const SizedBox(height: 16),

              // Botón subir/tomar foto (simulado)
              const UploadEvidence(),
              const SizedBox(height: 24),

              // Botón enviar
              FilledButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // TODO: enviar reporte a Provider o BD
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Incidente reportado con éxito ✅")));
                    Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.check),
                label: const Text("Enviar reporte"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UploadEvidence extends StatelessWidget {
  const UploadEvidence({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: implementar subir foto
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Subir/Tomar foto")));
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        alignment: Alignment.center,
        decoration: ShapeDecoration(
            shape: DashedBorder(borderRadius: BorderRadius.circular(10))),
        child: const Text("Subir/Tomar foto",
            style: TextStyle(color: Colors.black54)),
      ),
    );
  }
}

class CurrentAddress extends StatelessWidget {
  const CurrentAddress({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.only(top: 8.0, left: 12.0, right: 4.0, bottom: 8.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: Consumer<MapProvider>(
                builder: (context, map, _) =>  Text( map.currentAddress ?? "Obteniendo dirección...", style: const TextStyle(fontWeight: FontWeight.w600))),
          ),
          IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.location_pin))
        ],
      ),
    );
  }
}
