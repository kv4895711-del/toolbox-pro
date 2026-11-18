import 'package:flutter/cupertino.dart';
import 'geo_api.dart';
import 'map_glass.dart';

class InfoCard extends StatelessWidget {
  final String text;
  const InfoCard({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final p = MapPal.of(context);
    return MapGlass(
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14, color: p.text),
            ),
          ),
        ],
      ),
    );
  }
}

class ResultsCard extends StatelessWidget {
  final List<Place> items;
  final ValueChanged<Place> onPick;
  const ResultsCard({super.key, required this.items, required this.onPick});

  @override
  Widget build(BuildContext context) {
    final p = MapPal.of(context);
    return MapGlass(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          for (final it in items)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onPick(it),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                child: Row(
                  children: [
                    Icon(CupertinoIcons.location_solid,
                        size: 18, color: p.sub),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            it.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: p.text,
                            ),
                          ),
                          Text(
                            it.address,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12.5, color: p.sub),
                          ),
                        ],
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

class MapSearchOverlay extends StatelessWidget {
  final TextEditingController controller;
  final String note;
  final List<Place> results;
  final ValueChanged<String> onSubmit;
  final VoidCallback onCleared;
  final ValueChanged<Place> onPick;
  const MapSearchOverlay({
    super.key,
    required this.controller,
    required this.note,
    required this.results,
    required this.onSubmit,
    required this.onCleared,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final p = MapPal.of(context);
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Column(
          children: [
            MapGlass(
              padding: const EdgeInsets.all(4),
              child: CupertinoSearchTextField(
                controller: controller,
                placeholder: 'Search place or address',
                backgroundColor: const Color(0x00000000),
                itemColor: p.sub,
                style: TextStyle(color: p.text),
                placeholderStyle: TextStyle(color: p.sub),
                onSubmitted: onSubmit,
                onChanged: (v) {
                  if (v.isEmpty) onCleared();
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
                child: ResultsCard(items: results, onPick: onPick),
              ),
          ],
        ),
      ),
    );
  }
}
