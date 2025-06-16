import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SearchLocationBar extends StatefulWidget {
  final void Function(double lat, double lon, String displayName) onLocationSelected;

  const SearchLocationBar({super.key, required this.onLocationSelected});

  @override
  State<SearchLocationBar> createState() => _SearchLocationBarState();
}

class _SearchLocationBarState extends State<SearchLocationBar> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _suggestions = [];
  bool _isSearching = false;

  Future<void> _fetchSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }
    final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=5');
    final response = await http.get(url, headers: {'User-Agent': 'pavisense-app'});
    if (response.statusCode == 200) {
      final List results = json.decode(response.body);
      setState(() {
        _suggestions = results.cast<Map<String, dynamic>>();
      });
    } else {
      setState(() => _suggestions = []);
    }
  }

  Future<void> _searchAndGoToLocation(String query) async {
    setState(() => _isSearching = true);
    try {
      final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=1');
      final response = await http.get(url, headers: {'User-Agent': 'pavisense-app'});
      if (response.statusCode == 200) {
        final List results = json.decode(response.body);
        if (results.isNotEmpty) {
          final loc = results.first;
          widget.onLocationSelected(
            double.parse(loc['lat']),
            double.parse(loc['lon']),
            loc['display_name'] ?? '',
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Localização não encontrada.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao buscar localização: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao buscar localização: $e')),
      );
    } finally {
      setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(12),
          child: TextField(
            controller: _controller,
            onChanged: _fetchSuggestions,
            onSubmitted: _searchAndGoToLocation,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Buscar endereço ou local...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _isSearching
                  ? const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : (_controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _controller.clear();
                            setState(() => _suggestions = []);
                            FocusScope.of(context).unfocus();
                          },
                        )
                      : null),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
        if (_suggestions.isNotEmpty)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final suggestion = _suggestions[index];
                final displayName = suggestion['display_name'] ?? '';
                return ListTile(
                  title: Text(displayName, maxLines: 2, overflow: TextOverflow.ellipsis),
                  onTap: () {
                    final lat = double.parse(suggestion['lat']);
                    final lon = double.parse(suggestion['lon']);
                    widget.onLocationSelected(lat, lon, displayName);
                    _controller.text = displayName;
                    setState(() => _suggestions = []);
                    FocusScope.of(context).unfocus();
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}