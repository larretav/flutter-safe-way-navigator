import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import 'package:provider/provider.dart';
import 'package:safe_way_navigator/providers/map_provider.dart';
import 'package:safe_way_navigator/services/place_service.dart';

class AddressAutocomplete extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final Function(String, LatLng) onPlaceSelected;
  final VoidCallback? onCleared;

  const AddressAutocomplete({
    super.key,
    required this.hintText,
    required this.controller,
    required this.onPlaceSelected,
    this.onCleared,
  });

  @override
  State<AddressAutocomplete> createState() => _AddressAutocompleteState();
}

class _AddressAutocompleteState extends State<AddressAutocomplete> {
  final PlaceService _placeService = PlaceService();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<List<String>> _fetchSuggestions(String query, LatLng latlng) async {
    if (query.isEmpty || query.length < 3) return [];
    final results = await _placeService.search(query, latlng);
    return results.map((p) => p.fullText).toList();
  }

  void _onSelected(String selected, LatLng latlng) async {
    // Buscar el placeId correspondiente al texto
    final results = await _placeService.search(selected, latlng);
    if (results.isNotEmpty) {
      final loc = await _placeService.getPlaceLatLng(results.first.placeId);
      if (loc != null) {
        widget.onPlaceSelected(selected, loc);
      }
    }
    widget.controller.text = selected;
  }

  void _clearField() {
    widget.controller.clear();
    widget.onCleared?.call();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final mapProvider = Provider.of<MapProvider>(context, listen: false);

    if (mapProvider.currentLocation == null) {
      return Container();
    }

    final latlng = LatLng(
        lat: mapProvider.currentLocation!.latitude,
        lng: mapProvider.currentLocation!.longitude);

    return FutureBuilder(
        future: _fetchSuggestions(widget.controller.text, latlng),
        builder: (context, asyncSnapshot) {
          return Autocomplete<String>(
            optionsBuilder: (TextEditingValue value) async {
              return _fetchSuggestions(value.text, latlng);
            },
            onSelected: (item) => _onSelected(item, latlng),
            fieldViewBuilder:
                (context, textEditingController, focusNode, onFieldSubmitted) {
              // Vincular el controller externo
              textEditingController.text = widget.controller.text;

              return TextField(
                controller: textEditingController,
                focusNode: focusNode,
                onChanged: (value) => setState(() {
                  widget.controller.text = value;
                }),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  border: InputBorder.none,
                  isDense: true,
                  suffixIconConstraints:
                      const BoxConstraints(minWidth: 20, minHeight: 20),
                  suffixIcon: widget.controller.text.isNotEmpty
                      ? IconButton(
                          iconSize: 16,
                          icon: const Icon(Icons.clear),
                          constraints: const BoxConstraints(),
                          style: IconButton.styleFrom(
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: _clearField,
                        )
                      : null,
                ),
              );
            },
            optionsViewBuilder: (context, onSelected, options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(12),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final option = options.elementAt(index);
                        return ListTile(
                          title: Text(option),
                          onTap: () => onSelected(option),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          );
        });
  }
}
