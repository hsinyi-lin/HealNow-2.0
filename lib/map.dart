import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'main.dart';
import 'data/dbhelper.dart';

const LatLng currentLocation = LatLng(25.0423168, 121.5255206);

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController _mapController;
  final Map<String, Marker> _markers = {};
  late DatabaseHelper _databaseHelper; // Declare a database helper instance

  @override
  void initState() {
    super.initState();
    _databaseHelper =
        DatabaseHelper(createDatabaseConnection()); // 初始化 _databaseHelper
  }

  Future<List<Map<String, dynamic>>?> fetchDataFromPostgreSQL() async {
    await _databaseHelper.openConnection();
    final data = await _databaseHelper.fetchPharmacyData();
    await _databaseHelper.closeConnection();
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "藥局地圖",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold, // 設置字體加粗
          ),
        ),
        // Set your header title here
      ),
      drawer: const AppDrawer(),
      body: GoogleMap(
        initialCameraPosition:
            const CameraPosition(target: currentLocation, zoom: 15),
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
          _addMarkers();
        },
        markers: _markers.values.toSet(),
      ),
    );
  }

  void _addMarkers() async {
    final markerData = await fetchDataFromPostgreSQL();
    print(markerData);

    if (markerData != null) {
      for (var data in markerData) {
        var markerIcon = await BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(), 'assets/images/drugstore.png');
        // print(data);

        var latitude = double.parse(data["latitude"].toString());
        var longitude = double.parse(data["longitude"].toString());

        var marker = Marker(
          markerId: MarkerId(data["id"].toString()),
          position: LatLng(latitude, longitude),
          infoWindow: InfoWindow(
            title: data["pharmacy_name"],
            onTap: () {
              _showCustomInfoWindow(context, data);
            },
          ),
          icon: markerIcon,
        );

        _markers[data["id"].toString()] = marker;
      }
    }

    setState(() {});
  }

  void _showCustomInfoWindow(BuildContext context, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          content: IntrinsicWidth(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data["pharmacy_name"],
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('業者: ${data["leader_name"]}'),
                Text('電話: ${data["phone"]}'),
                Text('地址: ${data["full_address"]}'),
              ],
            ),
          ),
        );
      },
    );
  }
}
