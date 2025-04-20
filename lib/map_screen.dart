import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Google Maps paketi
import 'package:geolocator/geolocator.dart'; // Geolocator paketi
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore paketi

class MapScreen extends StatefulWidget {
  final String category; // 👈 Yeni eklenen satır

  MapScreen({required this.category}); // 👈 Constructor'a ekledik

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  LatLng? _center;

  Set<Marker> _markers = {}; // Marker'ları tutacak set

  @override
  void initState() {
    super.initState();
    _getUserLocation(); // Kullanıcı konumunu almak için çağırıyoruz
  }

  // Kullanıcı konumunu al
  _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Konum servisi kapalı!');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Konum izni kalıcı olarak reddedildi!');
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    _center = LatLng(position.latitude, position.longitude);

    // Salonları Firestore'dan çekiyoruz
    _loadSalons();

    setState(() {}); // Kullanıcı konumu alındıktan sonra UI'yı güncelliyoruz
  }

  _loadSalons() async {
    var salonQuery =
        await FirebaseFirestore.instance.collection('salons').get();

    for (var salon in salonQuery.docs) {
      if (salon['category'] == widget.category) {
        double salonLat =
            salon['latitude']; // Burada GeoPoint yerine latitude alıyoruz
        double salonLng =
            salon['longitude']; // Burada GeoPoint yerine longitude alıyoruz

        _markers.add(
          Marker(
            markerId: MarkerId(salon.id),
            position: LatLng(salonLat, salonLng),
            infoWindow: InfoWindow(
              title: salon['name'],
              snippet: salon['address'],
            ),
          ),
        );
      }
    }

    setState(() {}); // Marker'ları ekledikten sonra UI'yı güncelliyoruz
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Güzellik Merkezleri")),
      body:
          _center == null
              ? Center(child: CircularProgressIndicator())
              : GoogleMap(
                onMapCreated: (GoogleMapController controller) {
                  mapController = controller;
                },
                initialCameraPosition: CameraPosition(
                  target: _center!,
                  zoom: 15,
                ),
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                markers: _markers,
              ),
    );
  }
}
