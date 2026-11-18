import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'map_glass.dart';
import 'route_api.dart';

const _esri = 'https://server.arcgisonline.com/ArcGIS/rest/services';
const osmUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
const satUrl = '$_esri/World_Imagery/MapServer/tile/{z}/{y}/{x}';
const placesUrl =
    '$_esri/Reference/World_Boundaries_and_Places/MapServer/tile/{z}/{y}/{x}';
const roadsUrl =
    '$_esri/Reference/World_Transportation/MapServer/tile/{z}/{y}/{x}';
const _agent = 'com.example.toolbox_pro';

class MapLayers extends StatelessWidget {
  final MapController mc;
  final bool sat;
  final LatLng? me;
  final LatLng? pin;
  final RouteInfo? route;
  final VoidCallback onReady;
  final void Function(LatLng) onTapMap;
  const MapLayers({
    super.key,
    required this.mc,
    required this.sat,
    required this.me,
    required this.pin,
    required this.route,
    required this.onReady,
    required this.onTapMap,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mc,
      options: MapOptions(
        initialCenter: const LatLng(20.5937, 78.9629),
        initialZoom: 4.5,
        minZoom: 2,
        maxZoom: 19,
        onMapReady: onReady,
        onTap: (_, ll) => onTapMap(ll),
      ),
      children: [
        TileLayer(
          key: ValueKey('base$sat'),
          urlTemplate: sat ? satUrl : osmUrl,
          userAgentPackageName: _agent,
          maxNativeZoom: sat ? 18 : 19,
        ),
        if (sat) ...[
          TileLayer(
            urlTemplate: roadsUrl,
            userAgentPackageName: _agent,
            maxNativeZoom: 18,
          ),
          TileLayer(
            urlTemplate: placesUrl,
            userAgentPackageName: _agent,
            maxNativeZoom: 18,
          ),
        ],
        if (route != null)
          PolylineLayer(
            polylines: [
              Polyline(
                points: route!.points,
                strokeWidth: 6,
                color: mapBlue,
                borderStrokeWidth: 2,
                borderColor: const Color(0xFFFFFFFF),
              ),
            ],
          ),
        MarkerLayer(
          markers: [
            if (me != null)
              Marker(point: me!, width: 22, height: 22, child: const MeDot()),
            if (pin != null)
              Marker(
                point: pin!,
                width: 40,
                height: 40,
                alignment: Alignment.topCenter,
                child: const Icon(
                  CupertinoIcons.map_pin,
                  size: 36,
                  color: Color(0xFFFF3B30),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
