import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'geo_api.dart';
import 'map_cards.dart';
import 'map_glass.dart';
import 'map_layers.dart';
import 'map_widgets.dart';
import 'route_api.dart';

class MapsTab extends StatefulWidget {
  final bool active;
  const MapsTab({super.key, required this.active});

  @override
  State<MapsTab> createState() => _MapsTabState();
}

class _MapsTabState extends State<MapsTab> {
  final mc = MapController();
  final search = TextEditingController();
  final loc = LocService();
  LatLng? me;
  LatLng? pin;
  Place? place;
  RouteInfo? route;
  List<Place> results = [];
  String note = '';
  bool sat = false;
  bool ready = false;
  bool started = false;
  bool centered = false;

  @override
  void didUpdateWidget(MapsTab old) {
    super.didUpdateWidget(old);
    if (widget.active && !started) {
      started = true;
      startLoc();
    }
  }

  @override
  void dispose() {
    loc.stop();
    search.dispose();
    super.dispose();
  }

  Future<void> startLoc() async {
    final err = await loc.start((ll) {
      if (!mounted) return;
      setState(() => me = ll);
      centerOnce();
    });
    if (err != null && mounted) setState(() => note = err);
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
      place = p;
      route = null;
      results = [];
      note = '';
    });
    mc.move(p.point, 16);
  }

  Future<void> dropPin(LatLng ll) async {
    FocusScope.of(context).unfocus();
    setState(() {
      pin = ll;
      place = Place('Dropped pin', '', 'Address dhoondh raha hoon...', ll);
      route = null;
      results = [];
      note = '';
    });
    final pl = await reversePlace(ll);
    if (!mounted || pin != ll) return;
    setState(() {
      place = pl ?? Place('Dropped pin', '', 'Address nahi mila', ll);
    });
  }

  Future<void> getRoute() async {
    final to = pin;
    if (to == null) return;
    if (me == null) {
      setState(() => note = 'Apni location abhi nahi mili, GPS on karo');
      return;
    }
    setState(() => note = 'Route dhoondh raha hoon...');
    final r = await fetchRoute(me!, to);
    if (!mounted) return;
    if (r == null) {
      setState(() => note = 'Route nahi mila, thodi der baad try karo');
      return;
    }
    setState(() {
      route = r;
      note = '';
    });
    if (ready) {
      mc.fitCamera(CameraFit.coordinates(
        coordinates: r.points,
        padding: const EdgeInsets.fromLTRB(50, 170, 50, 320),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!started) return const SizedBox.shrink();
    final bp = MediaQuery.of(context).padding;
    final base = 100 + bp.bottom;
    return Stack(
      children: [
        Positioned.fill(
          child: MapLayers(
            mc: mc,
            sat: sat,
            me: me,
            pin: pin,
            route: route,
            onReady: () {
              ready = true;
              centerOnce();
            },
            onTapMap: dropPin,
          ),
        ),
        const Positioned(left: 0, right: 0, bottom: 0, child: BottomScrim()),
        Positioned(
          right: 16,
          top: bp.top + 80,
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
        if (route != null)
          Positioned(
            left: 16,
            right: 16,
            bottom: base + 8,
            child: RouteCard(
              route: route!,
              dest: place?.title ?? '',
              onClose: () => setState(() => route = null),
            ),
          )
        else if (place != null)
          Positioned(
            left: 16,
            right: 16,
            bottom: base + 8,
            child: PlaceCard(
              place: place!,
              onDirections: getRoute,
              onClose: () => setState(() {
                pin = null;
                place = null;
              }),
            ),
          ),
        Positioned(left: 12, bottom: base - 10, child: MapCredit(sat: sat)),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: MapSearchOverlay(
            controller: search,
            note: note,
            results: results,
            onSubmit: doSearch,
            onCleared: () => setState(() => results = []),
            onPick: pick,
          ),
        ),
      ],
    );
  }
}
