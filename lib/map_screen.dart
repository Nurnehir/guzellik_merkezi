import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'selectcity_screen.dart';

class MapScreen extends StatefulWidget {
  final String category;
  final LatLng cityCoordinates;

  MapScreen({required this.category, required this.cityCoordinates});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  Set<Marker> _markers = {};
  LatLng? _center;

  @override
  void initState() {
    super.initState();
    _initializeCenter(); // ilk koordinat kararını burada ver
    _loadSalons();
  }

  // İlk koordinat kontrolü
  _initializeCenter() async {
    if (widget.cityCoordinates.latitude == 0 &&
        widget.cityCoordinates.longitude == 0) {
      await _getUserLocation(); // anlık konum al
    } else {
      setState(() {
        _center = widget.cityCoordinates;
      });
    }
  }

  // Kullanıcı konumunu alma
  _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _center = LatLng(position.latitude, position.longitude);
    });
  }

  // Firestore'dan salonları yükle
  _loadSalons() async {
    var salonQuery =
        await FirebaseFirestore.instance.collection('salons').get();

    Set<Marker> newMarkers = {};

    for (var salon in salonQuery.docs) {
      if (salon['category'] == widget.category) {
        double salonLat = salon['latitude'];
        double salonLng = salon['longitude'];

        newMarkers.add(
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

    setState(() {
      _markers = newMarkers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.category)),
      body:
          _center == null
              ? Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Expanded(
                    flex: 3,
                    child: GoogleMap(
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
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        final selectedCityLatLng = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SelectCityScreen(),
                          ),
                        );

                        if (selectedCityLatLng != null) {
                          mapController.animateCamera(
                            CameraUpdate.newLatLng(selectedCityLatLng),
                          );
                          setState(() {
                            _center = selectedCityLatLng;
                          });
                        }
                      },
                      child: Text("Konum Seç"),
                    ),
                  ),
                ],
              ),
    );
  }
}
