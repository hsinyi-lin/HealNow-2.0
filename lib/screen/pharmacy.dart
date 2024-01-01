import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../services/opendata_service.dart';


class Place with ClusterItem {
  final String name;
  final String fullAddress;
  final String leaderName;
  final String gender;
  final String phone;
  final LatLng latLng;

  Place({
    required this.name, 
    required this.fullAddress, 
    required this.leaderName, 
    required this.gender, 
    required this.phone, 
    required this.latLng
  });

  @override
  LatLng get location => latLng;
}


class PharmacyPage extends StatefulWidget {
  const PharmacyPage({super.key});
  
  @override
  State<PharmacyPage> createState() => MapSampleState();
}

class MapSampleState extends State<PharmacyPage> {
  late ClusterManager _manager;
  double currentZoom = 12.0;

  final Completer<GoogleMapController> _controller = Completer();

  Set<Marker> markers = Set();

  final CameraPosition _cameraPosition =
      const CameraPosition(target: LatLng(25.0423168, 121.5255206), zoom: 12.0);

  Future<void> _fetchAndSetPharmacies() async {
    try {
      List<Map<String, dynamic>> pharmacyData = await OpenDataService().fetchPharmacies();
      print('adding markers...');
      List<Place> pharmacyPlaces = pharmacyData.map((pharmacy) {
        return Place(
          name: pharmacy['pharmacy_name'],
          fullAddress: pharmacy['full_address'],
          leaderName: pharmacy['leader_name'],
          gender: pharmacy['gender'],
          phone: pharmacy['phone'],
          latLng: LatLng(
            double.parse(pharmacy['latitude'].toString()),
            double.parse(pharmacy['longitude'].toString()),
          ),
        );
      }).toList();
      
      print('finish...');

      setState(() {
        _manager.setItems(pharmacyPlaces);
      });
    } catch (e) {
      print('Error fetching pharmacies: $e');
    }
  }

  @override
  void initState() {
    _manager = _initClusterManager();
    super.initState();
    _fetchAndSetPharmacies();
  }

  ClusterManager _initClusterManager() {
    return ClusterManager<Place>([], _updateMarkers, markerBuilder: _markerBuilder);
  }

  void _updateMarkers(Set<Marker> markers) {
    print('Updated ${markers.length} markers');
    setState(() {
      this.markers = markers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _cameraPosition,
            markers: markers,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              _manager.setMapId(controller.mapId);
            },
            onCameraMove: (CameraPosition position) {
              _manager.onCameraMove(position);
              currentZoom = position.zoom;
            },
            onCameraIdle: _manager.updateMap
        )
      );
  }

  // 處理點擊圓點
  Future<Marker> Function(Cluster<Place>) get _markerBuilder => (cluster) async {
    return Marker(
      markerId: MarkerId(cluster.getId()),
      position: cluster.location,
      onTap: () {
        if (cluster.isMultiple) {
          // 放大畫面如果Cluster數量大於1
          _zoomInOnCluster(cluster);
        } else {
          // 顯示dialog
          _showPharmacyDialog(cluster.items.first);
        }
      },
      icon: await _getMarkerBitmap(cluster.isMultiple ? 125 : 75,
          text: cluster.isMultiple ? cluster.count.toString() : null),
    );
  };

  // 放大畫面
  void _zoomInOnCluster(Cluster<Place> cluster) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(
      cluster.location,
      currentZoom + 2,
    ));
  }

  // 用於顯示dialog
  void _showPharmacyDialog(Place place) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            place.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 97, 97, 97), 
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                _buildDialogRow(Icons.location_on, place.fullAddress),
                _buildDialogRow(Icons.person, place.leaderName),
                _buildDialogRow(Icons.transgender, place.gender),
                _buildDialogRow(Icons.phone, place.phone),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'OK',
                style: TextStyle(color: Color.fromARGB(255, 61, 61, 61)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // dialog 細項處理
  Widget _buildDialogRow(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: <Widget>[
          Icon(icon, color: const Color.fromARGB(255, 168, 168, 168)), 
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(value, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  // 處理圓點顯示
  Future<BitmapDescriptor> _getMarkerBitmap(int size, {String? text}) async {
    if (kIsWeb) size = (size / 2).floor();

    final PictureRecorder pictureRecorder = PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint1 = Paint()..color = Color.fromARGB(255, 165, 207, 40);
    final Paint paint2 = Paint()..color = Colors.white;

    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.0, paint1);
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.2, paint2);
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.8, paint1);

    if (text != null) {
      TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
      painter.text = TextSpan(
        text: text,
        style: TextStyle(
            fontSize: size / 3,
            color: Colors.white,
            fontWeight: FontWeight.normal),
      );
      painter.layout();
      painter.paint(
        canvas,
        Offset(size / 2 - painter.width / 2, size / 2 - painter.height / 2),
      );
    }

    final img = await pictureRecorder.endRecording().toImage(size, size);
    final data = await img.toByteData(format: ImageByteFormat.png) as ByteData;

    return BitmapDescriptor.fromBytes(data.buffer.asUint8List());
  }
}
