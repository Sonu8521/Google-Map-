import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class GoogleMapPage extends StatefulWidget {
  @override
  _GoogleMapPageState createState() => _GoogleMapPageState();
}

class _GoogleMapPageState extends State<GoogleMapPage> {
  late GoogleMapController _controller;
  Set<Marker> _markers = Set<Marker>();

  // San Francisco coordinates
  static final LatLng _center = const LatLng(37.7749, -122.4194);
  LatLng _lastMapPosition = _center;

  // Declaring future variable
  late Future<void> _future;

  TextEditingController _searchController = TextEditingController();
  String _searchAddress = '';

  @override
  void initState() {
    super.initState();
    _future = _initializeMap();
  }

  Future<void> _initializeMap() async {
    // Perform any asynchronous initialization tasks here
    // For example, fetching data or initializing other state

    // Set initial marker when the map is created
    _markers.add(
      Marker(
        markerId: MarkerId("1"),
        position: _center,
        infoWindow: InfoWindow(
          title: 'San Francisco',
          snippet: 'Welcome to San Francisco!',
        ),
        icon: BitmapDescriptor.defaultMarker,
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
  }

  void _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Maps Example',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
        backgroundColor: Colors.green,
      ),
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return Column(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                color: Colors.grey[200],
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search city...',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () {
                        _searchPlace();
                      },
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _center,
                    zoom: 11.0,
                  ),
                  markers: _markers,
                  onCameraMove: _onCameraMove,
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToTheLake,
        label: Text('Go to Lake'),
        icon: Icon(Icons.directions_boat),
      ),
    );
  }

  // Function to move the camera to a specific location
  void _goToTheLake() async {
    final GoogleMapController controller = await _controller;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: LatLng(37.76999, -122.44696),
        zoom: 14.0,
        bearing: 45.0,
        tilt: 45.0,
      ),
    ));
  }

  // Function to search for a place by name
  void _searchPlace() async {
    String? address = _searchController.text;
    if (address == null || address.isEmpty) return;

    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        Location location = locations.first;
        LatLng searchedLatLng = LatLng(location.latitude, location.longitude);
        _moveToLocation(searchedLatLng);
      }
    } catch (e) {
      print('Error searching for place: $e');
    }
  }

  // Helper function to move the map camera to a specific location
  void _moveToLocation(LatLng latLng) async {
    final GoogleMapController controller = await _controller;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: latLng,
        zoom: 12.0,
      ),
    ));
  }
}
