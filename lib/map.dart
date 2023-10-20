import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'main.dart';

const LatLng currentLocation = LatLng(25.0280277 ,121.5010426);

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController _mapController;
  Map<String, Marker> _markers = {};

  // Sample data for markers
  final List<Map<String, dynamic>> markerData = [
      {
        "id":"1",
        "gender": "男",
        "pharmacy_name": "活力健康藥妝藥局",
        "phone": "23392625",
        "leader_name": "蕭聖鈞",
        "street": "中華路二段315巷1號",
        "city": "臺北市",
        "town": "中正區",
        "full_address": "臺北市中正區中華路二段315巷1號",
        "latitude": 25.0280277,
        "longitude": 121.5060826
    },
    {
      "id":"2",
      "gender": "女",
      "pharmacy_name": "建祥武昌藥局",
      "phone": "2381-5229",
      "leader_name": "黃盟婷",
      "street": "武昌街1段29號1樓",
      "city": "臺北市",
      "town": "中正區",
      "full_address": "臺北市中正區武昌街1段29號1樓",
      "latitude": 25.1485078,
      "longitude": 121.7631554
    },
    {
      "id":"3",
      "gender": "男",
      "pharmacy_name": "保德中華藥局",
      "phone": "02-23027720",
      "leader_name": "蕭宇凱",
      "street": "中華路二段159號",
      "city": "臺北市",
      "town": "中正區",
      "full_address": "臺北市中正區中華路二段159號",
      "latitude": 25.0309765,
      "longitude": 121.5042361
    },
    {
      "id":"4",
      "gender": "男",
      "pharmacy_name": "71恩典藥局",
      "phone": "23223371",
      "leader_name": "洪增陽",
      "street": "信義路二段71號",
      "city": "臺北市",
      "town": "中正區",
      "full_address": "臺北市中正區信義路二段71號",
      "latitude": 25.03468,
      "longitude": 121.526427
    },
    {
      "id":"5",
      "gender": "男",
      "pharmacy_name": "豐仁藥局",
      "phone": "02-23033908",
      "leader_name": "黃敬堯",
      "street": "寧波西街161號",
      "city": "臺北市",
      "town": "中正區",
      "full_address": "臺北市中正區寧波西街161號",
      "latitude": 25.0273874,
      "longitude": 121.5109243
    },
    // Add more locations here
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("藥局地圖"), 
        // Set your header title here
      ),
      drawer: AppDrawer(),
      body: GoogleMap(
        initialCameraPosition:
            const CameraPosition(target: currentLocation, zoom: 14),
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
          _addMarkers();
        },
        markers: _markers.values.toSet(),
      ),
    );
  }

   void _addMarkers() async {

    // Create a custom icon for the current location marker
    var customIcon = await BitmapDescriptor.fromAssetImage(
          const ImageConfiguration(), 'assets/images/user.png');

    // Add the current location marker
    _markers["0"] = Marker(
      markerId: MarkerId("0".toString()), // Use a string as the marker ID
      position: currentLocation,
      icon: customIcon,
    );

    for (var data in markerData) {
      var markerIcon = await BitmapDescriptor.fromAssetImage(
          const ImageConfiguration(), 'assets/images/drugstore.png');

      var marker = Marker(
        markerId: MarkerId(data["id"].toString()),
        position: LatLng(data["latitude"], data["longitude"]),
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

    
    setState(() {});
  }

  void _showCustomInfoWindow(BuildContext context, Map<String, dynamic> data) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        content: IntrinsicWidth(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data["pharmacy_name"],
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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