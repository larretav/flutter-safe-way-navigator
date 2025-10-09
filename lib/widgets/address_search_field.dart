import 'package:flutter/material.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart' ;
import 'package:safe_way_navigator/services/place_service.dart';

class AddressSearchField extends StatefulWidget {
  final String hintText;
  final Function(String, LatLng) onPlaceSelected;

  const AddressSearchField({
    super.key,
    required this.hintText,
    required this.onPlaceSelected,
  });

  @override
  State<AddressSearchField> createState() => _AddressSearchFieldState();
}

class _AddressSearchFieldState extends State<AddressSearchField> {
  final TextEditingController _controller = TextEditingController();
  final PlaceService _placeService = PlaceService();
  List<AutocompletePrediction> _suggestions = [];

  void _onChanged(String value) async {
    if (value.length < 3) {
      setState(() => _suggestions = []);
      return;
    }
    final results = await _placeService.search(value);
    setState(() => _suggestions = results);
  }

  void _selectPlace(AutocompletePrediction prediction) async {
    final location = await _placeService.getPlaceLatLng(prediction.placeId);
    if (location != null) {
      widget.onPlaceSelected(prediction.fullText, location);
      _controller.text = prediction.fullText;
      setState(() => _suggestions = []);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: widget.hintText,
            border: InputBorder.none,
            isDense: true
          ),
          onChanged: _onChanged,
          
        ),
        if (_suggestions.isNotEmpty)
          Container(
            color: Colors.white,
            child: Column(
              children: _suggestions
                  .map((p) => ListTile(
                        title: Text(p.fullText),
                        onTap: () => _selectPlace(p),
                      ))
                  .toList(),
            ),
          ),
      ],
    );
  }
}
