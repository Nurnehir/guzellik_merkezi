import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'selectcity_screen.dart';
import 'randevu_al_page.dart';

class MapScreen extends StatefulWidget {
  final String category;
  final LatLng? cityCoordinates;
  final String? salonId;
  final Map<String, dynamic>? selectedSalon;
  const MapScreen({
    super.key,
    required this.category,
    this.cityCoordinates,
    this.salonId,
    this.selectedSalon,
  });

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  Set<Marker> _markers = {};
  LatLng? _center;
  Map<String, dynamic>? selectedSalon;

  @override
  void initState() {
    super.initState();
    _initializeCenter();
    _loadSalons();
  }

  _initializeCenter() async {
    if (widget.cityCoordinates == null ||
        widget.cityCoordinates!.latitude == 0 ||
        widget.cityCoordinates!.longitude == 0) {
      await _getUserLocation();
    } else {
      setState(() {
        _center = widget.cityCoordinates;
      });
    }
  }

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

  _loadSalons() async {
    var salonQuery =
        await FirebaseFirestore.instance.collection('salons').get();

    Set<Marker> newMarkers = {};

    for (var salon in salonQuery.docs) {
      if (salon['category'] == widget.category) {
        if (widget.selectedSalon != null &&
            salon['name'].toString().toLowerCase() ==
                widget.selectedSalon!['name'].toString().toLowerCase()) {
          await Future.delayed(const Duration(milliseconds: 500));
          mapController.animateCamera(
            CameraUpdate.newLatLngZoom(
              LatLng(salon['latitude'], salon['longitude']),
              17,
            ),
          );

          setState(() {
            selectedSalon = {
              'id': salon.id,
              'name': salon['name'],
              'address': salon['address'],
              'category': salon['category'],
              'service': widget.category,
            };
          });
        }

        double salonLat = salon['latitude'];
        double salonLng = salon['longitude'];

        final marker = Marker(
          markerId: MarkerId(salon.id),
          position: LatLng(salonLat, salonLng),
          infoWindow: InfoWindow(
            title: salon['name'],
            snippet: salon['address'],
          ),
          onTap: () {
            setState(() {
              selectedSalon = {
                'id': salon.id,
                'name': salon['name'],
                'address': salon['address'],
                'category': salon['category'],
                'service': widget.category,
              };
            });
          },
        );

        newMarkers.add(marker);

        // 🔍 Eğer bu marker 'Git' ile gelinen salonId’ye aitse, kamerayı oraya götür
        if (widget.salonId != null && salon.id == widget.salonId) {
          await Future.delayed(
            const Duration(milliseconds: 400),
          ); // Harita oluşturulmuş olsun
          mapController.animateCamera(
            CameraUpdate.newLatLngZoom(LatLng(salonLat, salonLng), 17),
          );

          // Bu salonu seçili olarak ayarla
          setState(() {
            selectedSalon = {
              'id': salon.id,
              'name': salon['name'],
              'address': salon['address'],
              'category': salon['category'],
              'service': widget.category,
            };
          });
        }
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed:
                                selectedSalon != null
                                    ? () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => RandevuAlPage(
                                                salonData: selectedSalon!,
                                                serviceName:
                                                    selectedSalon!['service'], // ✅ burada artık doğru hizmeti gönderiyorsun
                                              ),
                                        ),
                                      );
                                    }
                                    : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  selectedSalon != null
                                      ? Colors.blue
                                      : Colors.grey,
                            ),
                            child: Text("Randevu Al"),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
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
                  ),
                ],
              ),
    );
  }
}
