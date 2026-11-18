import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RouteStep {
  final String text;
  final double meters;
  final LatLng at;
  RouteStep(this.text, this.meters, this.at);
}

class RouteInfo {
  final List<LatLng> points;
  final double meters;
  final double seconds;
  final List<RouteStep> steps;
  RouteInfo(this.points, this.meters, this.seconds, this.steps);
}

String fmtDist(double m) =>
    m < 1000 ? '${m.round()} m' : '${(m / 1000).toStringAsFixed(1)} km';

String fmtTime(double s) {
  final mins = (s / 60).round();
  if (mins < 60) return '$mins min';
  final m = mins % 60;
  return m == 0 ? '${mins ~/ 60} hr' : '${mins ~/ 60} hr $m min';
}

String _stepText(String type, String? mod, String road) {
  final on = road.isEmpty ? '' : ' on $road';
  if (type == 'depart') return 'Start$on';
  if (type == 'arrive') return 'You have arrived';
  if (type == 'roundabout' || type == 'rotary') {
    return 'Take the roundabout$on';
  }
  if (mod == 'uturn') return 'Make a U-turn$on';
  if (mod == 'straight' || type == 'continue') return 'Continue straight$on';
  if (type == 'fork') return 'Keep ${mod ?? 'ahead'}$on';
  return 'Turn ${mod ?? 'ahead'}$on';
}

LatLng _ll(List l) => LatLng((l[1] as num).toDouble(), (l[0] as num).toDouble());

Future<RouteInfo?> fetchRoute(LatLng a, LatLng b) async {
  final url = 'https://router.project-osrm.org/route/v1/driving/'
      '${a.longitude},${a.latitude};${b.longitude},${b.latitude}'
      '?overview=full&geometries=geojson&steps=true';
  try {
    final r = await http.get(
      Uri.parse(url),
      headers: {'User-Agent': 'ToolboxPro/1.0 (personal app)'},
    );
    if (r.statusCode != 200) return null;
    final m = jsonDecode(r.body) as Map<String, dynamic>;
    final routes = m['routes'] as List?;
    if (routes == null || routes.isEmpty) return null;
    final rt = routes[0] as Map<String, dynamic>;
    final coords = rt['geometry']['coordinates'] as List;
    final steps = <RouteStep>[];
    for (final leg in rt['legs'] as List) {
      for (final st in leg['steps'] as List) {
        final man = st['maneuver'] as Map<String, dynamic>;
        steps.add(RouteStep(
          _stepText(man['type'] as String, man['modifier'] as String?,
              (st['name'] as String?) ?? ''),
          (st['distance'] as num).toDouble(),
          _ll(man['location'] as List),
        ));
      }
    }
    return RouteInfo(
      [for (final c in coords) _ll(c as List)],
      (rt['distance'] as num).toDouble(),
      (rt['duration'] as num).toDouble(),
      steps,
    );
  } catch (_) {
    return null;
  }
}
