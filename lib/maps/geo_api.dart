import 'dart:async';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class Place {
  final String title;
  final String type;
  final String address;
  final LatLng point;
  Place(this.title, this.type, this.address, this.point);
}

const _headers = {'User-Agent': 'ToolboxPro/1.0 (personal app)'};

String _pretty(String s) {
  if (s.isEmpty || s == 'yes') return '';
  final t = s.replaceAll('_', ' ');
  return t[0].toUpperCase() + t.substring(1);
}

Place _fromJson(Map<String, dynamic> e, LatLng p) {
  final full = (e['display_name'] as String?) ?? '';
  final parts = full.split(', ');
  var title = ((e['name'] as String?) ?? '').trim();
  if (title.isEmpty) title = parts.first;
  final addr = parts.length > 1 ? parts.skip(1).join(', ') : full;
  var kind = _pretty((e['type'] as String?) ?? '');
  if (kind.isEmpty) kind = _pretty((e['category'] as String?) ?? '');
  return Place(title, kind, addr, p);
}

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
        _fromJson(
          e as Map<String, dynamic>,
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

Future<Place?> reversePlace(LatLng p) async {
  final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
    'lat': '${p.latitude}',
    'lon': '${p.longitude}',
    'format': 'jsonv2',
    'zoom': '18',
  });
  try {
    final r = await http.get(uri, headers: _headers);
    if (r.statusCode != 200) return null;
    final m = jsonDecode(r.body) as Map<String, dynamic>;
    if (m['display_name'] == null) return null;
    return _fromJson(m, p);
  } catch (_) {
    return null;
  }
}

class LocService {
  StreamSubscription<Position>? _sub;

  Future<String?> start(void Function(LatLng) onPos) async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return 'Phone ka GPS (location) on karo';
    }
    var p = await Geolocator.checkPermission();
    if (p == LocationPermission.denied) {
      p = await Geolocator.requestPermission();
    }
    if (p == LocationPermission.denied ||
        p == LocationPermission.deniedForever) {
      return 'Location permission nahi mili';
    }
    _sub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((pos) => onPos(LatLng(pos.latitude, pos.longitude)));
    return null;
  }

  void stop() => _sub?.cancel();
}
