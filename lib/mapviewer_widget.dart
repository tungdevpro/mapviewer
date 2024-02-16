import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';

class MapViewer extends StatefulWidget {
  final List? latlng;
  final List? currentLocation;
  final double zoom;
  final List? items;
  final String? address;
  final bool hasPicker;
  final Widget? centerIcon;

  const MapViewer({
    Key? key,
    this.latlng,
    this.zoom = 7.0,
    this.items,
    this.currentLocation,
    this.address,
    this.hasPicker = false,
    this.centerIcon,
  }) : super(key: key);

  @override
  _MapViewerState createState() => _MapViewerState();
}

class _MapViewerState extends State<MapViewer> {
  late LatLng centerLocation;
  MapController? mapController;
  ValueNotifier<LatLng?>? valueNotifier;
  late LatLng _latlng;
  double baseRadius = 20;

  List addMaps = [
    {
      'image': 'assets/hoang_sa.png',
      'title': 'Quần đảo\n Hoàng Sa(Việt Nam)',
      'width': 142.0,
      'height': 40.0,
      'location': const LatLng(16.4871075, 111.6165039)
    },
    {
      'image': 'assets/truong_sa.png',
      'title': 'Quần đảo\n Trường Sa(Việt Nam)',
      'width': 142.0,
      'height': 40.0,
      'location': const LatLng(10.7233028, 115.8177107)
    },
  ];

  @override
  void initState() {
    valueNotifier = ValueNotifier(null);
    mapController = MapController();
    centerLocation = const LatLng(16.4871075, 111.6165039);
    _latlng = (widget.latlng != null) ? LatLng(widget.latlng![0] ?? 0, widget.latlng![1] ?? 0) : const LatLng(0, 0);

    super.initState();
  }

  @override
  void didUpdateWidget(covariant MapViewer oldWidget) {
    _latlng =
        (widget.latlng != null) ? LatLng(double.tryParse(widget.latlng![0].toString()) ?? 0, double.tryParse(widget.latlng![1].toString()) ?? 0) : LatLng(0, 0);
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    late LatLng current;
    num? distance;
    if (widget.currentLocation != null) {
      current = LatLng(double.tryParse(widget.currentLocation![0])!, double.tryParse(widget.currentLocation![1])!);
      centerLocation = current;
    }
    if (widget.latlng != null && widget.currentLocation == null) {
      centerLocation = _latlng;
    }

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: centerLocation,
            initialZoom: widget.zoom,
            maxZoom: (widget.zoom + 1),
            minZoom: (widget.zoom - 1),
            onTap: (tapPosition, point) {
              if (widget.hasPicker) {
                setState(() {
                  _latlng = LatLng(point.latitude, point.longitude);
                });
                valueNotifier!.value = LatLng(point.latitude, point.longitude);
              }
            },
          ),
          mapController: mapController,
          children: [
            TileLayer(
                urlTemplate: "https://server.arcgisonline.com/arcgis/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}", subdomains: ['a', 'b', 'c']),
            TileLayer(
              urlTemplate: "https://tiles.arcgis.com/tiles/hkW6eGvd2CYWvCNM/arcgis/rest/services/Labels/MapServer/tile/{z}/{y}/{x}",
              subdomains: const ['a', 'b', 'c'],
              // backgroundColor: Colors.transparent,
            ),
            MarkerLayer(
              markers: [
                if (widget.latlng != null)
                  Marker(
                    point: LatLng(widget.latlng![0], widget.latlng![1]),
                    child: const Icon(
                      Icons.control_point_outlined,
                      color: Colors.red,
                    ),
                  ),
                if (widget.currentLocation != null)
                  Marker(
                    point: (widget.currentLocation != null ? current : null)!,
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white)),
                        child: const Icon(Icons.streetview, size: 30, color: Color(0xff41459B)),
                      ),
                    ),
                  ),
                ...addMaps.map<Marker>((e) {
                  return Marker(
                      width: e['width'],
                      height: e['height'],
                      point: e['location'],
                      child: Image.asset(e['image'], width: e['width'], package: 'mapviewer', height: e['height']));
                })
              ],
            ),
            if (widget.latlng != null && distance != null)
              CircleLayer(circles: [
                CircleMarker(
                  point: _latlng,
                  color: distance < baseRadius ? Colors.blue.withOpacity(0.3) : Colors.red.withOpacity(0.3),
                  borderStrokeWidth: 3.0,
                  borderColor: distance < baseRadius ? Colors.blue : Colors.red,
                  useRadiusInMeter: true,
                  radius: baseRadius,
                )
              ])
          ],
        ),
        if (widget.hasPicker)
          Align(
            alignment: Alignment.topRight,
            child: SafeArea(
              child: Container(
                margin: const EdgeInsets.only(top: 10, right: 15),
                decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(50)),
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
          ),
        if (widget.hasPicker)
          SafeArea(
            child: ValueListenableBuilder<LatLng?>(
                valueListenable: valueNotifier!,
                builder: (_, value, child) {
                  if (value != null) {
                    return Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: SizedBox(
                          width: double.infinity,
                          height: 45,
                          child: TextButton(
                            child: const Text('Xác nhận'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          )),
                    );
                  }
                  return const SizedBox.shrink();
                }),
          )
      ],
    );
  }
}
