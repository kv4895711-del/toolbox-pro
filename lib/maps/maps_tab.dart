import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../app_state.dart';
import 'geo_api.dart';
import 'map_widgets.dart';

const osmUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
const satUrl =
    'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';

class MapsTab extends StatefulWidget {
  final bool active;
  const MapsTab({super.key, required this.active});

  @override
  State<MapsTab> createState() => _MapsTabState();
}

class _MapsTabState extends State<MapsTab> {
  final mc = MapController();
  final search = TextEditingController();
  StreamSubscription<Position>? sub;
  LatLng? me;
  LatLng? pin;
  String pinText = '';
  String note = '';
  List<Place> results = [];
  bool sat = false;
  bool ready = false;
  bool started = false;
  bool centered = false;

  @override
  void didUpdateWidget(MapsTab old) {
    super.didUpdateWidget(old);
    if (widget.active && !started) {
      started = true;
      startLocation();
    }
  }

  @override
  void dispose() {
    sub?.cancel();
    search.dispose();
    super.dispose();
  }

  Future<void> startLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      setState(() => note = 'Phone ka GPS (location) on karo');
      return;
    }
    var p = await Geolocator.checkPermission();
    if (p == LocationPermission.denied) {
      p = await Geolocator.requestPermission();
    }
    if (p == LocationPermission.denied ||
        p == LocationPermission.deniedForever) {
      setState(() => note = 'Location permission nahi mili');
      return;
    }
    sub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((pos) {
      if (!mounted) return;
      setState(() => me = LatLng(pos.latitude, pos.longitude));
      centerOnce();
    });
  }

  void centerOnce() {
    if (!centered && ready && me != null) {
      centered = true;
      mc.move(me!, 16);
    }
  }

  void goMe() {
    if (me != null && ready) mc.move(me!, 16.5);
  }

  Future<void> doSearch(String q) async {
    if (q.trim().isEmpty) return;
    final r = await searchPlaces(q.trim());
    if (!mounted) return;
    setState(() {
      results = r;
      note = r.isEmpty ? 'Kuch nahi mila' : '';
    });
  }

  void pick(Place p) {
    FocusScope.of(context).unfocus();
    setState(() {
      pin = p.point;
      pinText = p.name;
      results = [];
    });
    mc.move(p.point, 16);
  }

  Future<void> dropPin(LatLng ll) async {
    FocusScope.of(context).unfocus();
    setState(() {
      pin = ll;
      pinText = 'Address dhoondh raha hoon...';
      results = [];
    });
    final a = await addressOf(ll);
    if (mounted && pin == ll) setState(() => pinText = a);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    if (!started) return const SizedBox.shrink();
    final base = 100 + MediaQuery.of(context).padding.bottom;
    return Stack(
      children: [
        Positioned.fill(
          child: FlutterMap(
            mapController: mc,
            options: MapOptions(
              initialCenter: const LatLng(20.5937, 78.9629),
              initialZoom: 4.5,
              minZoom: 2,
              maxZoom: 19,
              onMapReady: () {
                ready = true;
                centerOnce();
              },
              onTap: (_, ll) => dropPin(ll),
            ),
            children: [
              TileLayer(
                key: ValueKey(sat),
                urlTemplate: sat ? satUrl : osmUrl,
                userAgentPackageName: 'com.example.toolbox_pro',
                maxNativeZoom: 19,
              ),
              MarkerLayer(
                markers: [
                  if (me != null)
                    Marker(
                      point: me!,
                      width: 22,
                      height: 22,
                      child: const MeDot(),
                    ),
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
          ),
        ),
        Positioned(
          top: 0,
          left: 16,
          right: 16,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                children: [
                  GlassCard(
                    blur: true,
                    radius: 22,
                    padding: const EdgeInsets.all(4),
                    child: CupertinoSearchTextField(
                      controller: search,
                      placeholder: 'Search place or address',
                      backgroundColor: const Color(0x00000000),
                      itemColor: s.subText,
                      style: TextStyle(color: s.text),
                      placeholderStyle: TextStyle(color: s.subText),
                      onSubmitted: doSearch,
                      onChanged: (v) {
                        if (v.isEmpty) setState(() => results = []);
                      },
                    ),
                  ),
                  if (note.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: InfoCard(text: note),
                    ),
                  if (results.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: ResultsCard(
                        names: [for (final r in results) r.name],
                        onPick: (i) => pick(results[i]),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          right: 16,
          bottom: base + 10 + (pin != null ? 90 : 0),
          child: Column(
            children: [
              MapBtn(
                icon: CupertinoIcons.layers_alt_fill,
                on: sat,
                onTap: () => setState(() => sat = !sat),
              ),
              const SizedBox(height: 12),
              MapBtn(icon: CupertinoIcons.location_fill, onTap: goMe),
            ],
          ),
        ),
        if (pin != null)
          Positioned(
            left: 16,
            right: 16,
            bottom: base + 10,
            child: InfoCard(
              text: pinText,
              onClose: () => setState(() => pin = null),
            ),
          ),
        Positioned(
          left: 12,
          bottom: base - 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            color: const Color(0xAAFFFFFF),
            child: Text(
              sat
                  ? '© Esri, Maxar, Earthstar Geographics'
                  : '© OpenStreetMap contributors',
              style: const TextStyle(fontSize: 10, color: Color(0xFF000000)),
            ),
          ),
        ),
      ],
    );
  }
}
