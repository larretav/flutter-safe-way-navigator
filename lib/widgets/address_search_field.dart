import 'package:flutter/material.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import 'package:safe_way_navigator/services/place_service.dart';

class AddressAutocomplete extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final Function(String, LatLng) onPlaceSelected;

  const AddressAutocomplete({
    super.key,
    required this.hintText,
    required this.controller,
    required this.onPlaceSelected,
  });

  @override
  State<AddressAutocomplete> createState() => _AddressAutocompleteState();
}

class _AddressAutocompleteState extends State<AddressAutocomplete> {
  final PlaceService _placeService = PlaceService();

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) async {
        if (textEditingValue.text.isEmpty)
          return const Iterable<String>.empty();

        final results = await _placeService.search(textEditingValue.text);
        return results.map((p) => p.fullText);
      },
      onSelected: (String selected) async {
        // Buscar el placeId correspondiente al texto
        final results = await _placeService.search(selected);
        if (results.isNotEmpty) {
          final loc = await _placeService.getPlaceLatLng(results.first.placeId);
          if (loc != null) {
            widget.onPlaceSelected(selected, loc);
          }
        }
        widget.controller.text = selected;
      },
      fieldViewBuilder:
          (context, textEditingController, focusNode, onFieldSubmitted) {
        // Vincular el controller externo
        textEditingController.text = widget.controller.text;

        return TextField(
          controller: textEditingController,
          focusNode: focusNode,
          onChanged: (value) => widget.controller.text = value,
          decoration: InputDecoration(
            hintText: widget.hintText,
            border: InputBorder.none,
            isDense: true,
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
  }
}
