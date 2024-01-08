import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


// 此類別實現 ClusterItem 以支持地圖上的群聚功能(使用 mixin)
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

  // 覆寫 ClusterItem 的 location getter，提供地點的經緯度
  @override
  LatLng get location => latLng;
}