import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class Place {
  final String name;
  final LatLng point;
  Place(this.name, this.point);
}

const _headers = {'User-Agent': 'ToolboxPro/1.0 (personal app)'};

Future<List<Place>> searchPlaces(String q) async {
  final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
    'q': q,
    'format': 'jsonv2',
    'limit': '6',
  });
  try {
    final r = await http.get(uri, headers: _headers);
    if (r.statusCode != 200) return [];
    final list = jsonDecode(r.body) as List;
    return [
      for (final e in list)
        Place(
          e['display_name'] as String,
          LatLng(
            double.parse(e['lat'] as String),
            double.parse(e['lon'] as String),
          ),
        ),
    ];
  } catch (_) {
    return [];
  }
}

Future<String> addressOf(LatLng p) async {
  final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
    'lat': '${p.latitude}',
    'lon': '${p.longitude}',
    'format': 'jsonv2',
  });
  try {
    final r = await http.get(uri, headers: _headers);
    if (r.statusCode != 200) return 'Address nahi mila';
    final m = jsonDecode(r.body) as Map<String, dynamic>;
    return (m['display_name'] as String?) ?? 'Address nahi mila';
  } catch (_) {
    return 'Address nahi mila';
  }
}
