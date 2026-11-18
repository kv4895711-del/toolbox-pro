import 'package:flutter/cupertino.dart';
import 'geo_api.dart';
import 'map_glass.dart';
import 'route_api.dart';

class PlaceCard extends StatelessWidget {
  final Place place;
  final VoidCallback onDirections;
  final VoidCallback onClose;
  const PlaceCard({
    super.key,
    required this.place,
    required this.onDirections,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final p = MapPal.of(context);
    return MapGlass(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  place.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: p.text,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onClose,
                child: Icon(CupertinoIcons.xmark_circle_fill, color: p.sub),
              ),
            ],
          ),
          if (place.type.isNotEmpty)
            Text(
              place.type,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: p.sub,
              ),
            ),
          const SizedBox(height: 4),
          Text(
            place.address,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13, color: p.sub),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onDirections,
            child: Container(
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: mapBlue,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(CupertinoIcons.arrow_turn_up_right,
                      size: 20, color: Color(0xFFFFFFFF)),
                  SizedBox(width: 8),
                  Text(
                    'Directions',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RouteCard extends StatefulWidget {
  final RouteInfo route;
  final String dest;
  final VoidCallback onClose;
  const RouteCard({
    super.key,
    required this.route,
    required this.dest,
    required this.onClose,
  });

  @override
  State<RouteCard> createState() => _RouteCardState();
}

class _RouteCardState extends State<RouteCard> {
  bool open = false;

  @override
  Widget build(BuildContext context) {
    final p = MapPal.of(context);
    final r = widget.route;
    return MapGlass(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                fmtTime(r.seconds),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: p.text,
                ),
              ),
              const SizedBox(width: 10),
              Text(fmtDist(r.meters),
                  style: TextStyle(fontSize: 16, color: p.sub)),
              const Spacer(),
              GestureDetector(
                onTap: widget.onClose,
                child: Icon(CupertinoIcons.xmark_circle_fill, color: p.sub),
              ),
            ],
          ),
          Text(
            'To ${widget.dest}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13, color: p.sub),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => setState(() => open = !open),
            child: Text(
              open ? 'Hide steps' : 'Show steps',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: mapBlue,
              ),
            ),
          ),
          if (open)
            SizedBox(
              height: 200,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  for (final st in r.steps)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Icon(CupertinoIcons.arrow_turn_up_right,
                              size: 16, color: p.sub),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              st.text,
                              style: TextStyle(fontSize: 14, color: p.text),
                            ),
                          ),
                          Text(fmtDist(st.meters),
                              style: TextStyle(fontSize: 13, color: p.sub)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
