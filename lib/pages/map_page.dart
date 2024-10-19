import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:google_place/google_place.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Maps with APIs',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MapPage(),
    );
  }
}

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController mapController;
  LatLng _initialPosition = const LatLng(40.7128, -74.0060); // Default: New York
  late GooglePlace googlePlace;
  List<SearchResult> _searchResults = [];
  Marker? _destinationMarker;
  Polyline? _routePolyline;

  final TextEditingController _searchController = TextEditingController(); // Text controller for search field

  @override
  void initState() {
    super.initState();
    googlePlace = GooglePlace("AIzaSyC22ln0ljAcGxKiCT2pnjD7OdP0FrHsTic");
    _getUserLocation();
  }

  // Get user's current location
  Future<void> _getUserLocation() async {
    // Position position = await Geolocator.getCurrentPosition();
    // setState(() {
    //   _initialPosition = LatLng(position.latitude, position.longitude);
    // });

    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    // Request location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    // Get the user's current location
    Position position = await Geolocator.getCurrentPosition();

    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
      mapController.animateCamera(
        CameraUpdate.newLatLng(_initialPosition),
      );
    });
  }

  // Fetch directions from the Google Directions API
  Future<void> _getDirections(LatLng destination) async {
    final String apiKey = 'YOUR_DIRECTIONS_API_KEY'; // Replace with your Directions API key
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${_initialPosition.latitude},${_initialPosition.longitude}&destination=${destination.latitude},${destination.longitude}&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final points = data['routes'][0]['overview_polyline']['points'];
      setState(() {
        _routePolyline = Polyline(
          polylineId: PolylineId('route'),
          points: _convertToLatLng(_decodePolyline(points)),
          color: Colors.blue,
          width: 5,
        );
        _destinationMarker = Marker(
          markerId: MarkerId('destination'),
          position: destination,
          infoWindow: const InfoWindow(title: 'Destination'),
        );
      });
    } else {
      throw Exception('Failed to load directions');
    }
  }

  // Decode the polyline from the directions API response
  List<LatLng> _decodePolyline(String polyline) {
    List<LatLng> coordinates = [];
    int index = 0, len = polyline.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      coordinates.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return coordinates;
  }

  // Search places using the Places API
  Future<void> _searchPlaces(String query) async {
    var result = await googlePlace.search.getTextSearch(query);
    setState(() {
      _searchResults = result?.results ?? [];
    });
  }

  // Convert list of points to LatLng
  List<LatLng> _convertToLatLng(List<LatLng> points) {
    return points.map((e) => LatLng(e.latitude, e.longitude)).toList();
  }

  // Open Google Maps for turn-by-turn navigation
  Future<void> _openGoogleMapsForNavigation(LatLng destination) async {
    final String googleMapsUrl =
        "https://www.google.com/maps/dir/?api=1&destination=${destination.latitude},${destination.longitude}&travelmode=driving";
    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      throw 'Could not open Google Maps.';
    }
  }

  // Create the map
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Maps Example'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.navigation),
            onPressed: () {
              if (_destinationMarker != null) {
                _openGoogleMapsForNavigation(_destinationMarker!.position);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController, // Capture user input
              decoration: InputDecoration(
                labelText: 'Search for a place',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    String query = _searchController.text;
                    if (query.isNotEmpty) {
                      _searchPlaces(query); // Search using the input query
                    }
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: 12.0,
              ),
              markers: _destinationMarker != null ? {_destinationMarker!} : {},
              polylines: _routePolyline != null ? {_routePolyline!} : {},
              myLocationEnabled: true,
              mapType: MapType.normal,
              myLocationButtonEnabled: true,
            ),
          ),
          if (_searchResults.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final place = _searchResults[index];
                  return ListTile(
                    title: Text(place.name ?? 'Unknown place'),
                    subtitle: Text(place.formattedAddress ?? ''),
                    onTap: () {
                      LatLng destination = LatLng(
                          place.geometry?.location?.lat ?? 0.0,
                          place.geometry?.location?.lng ?? 0.0);
                      _getDirections(destination);
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    mapController.dispose();
    _searchController.dispose(); // Dispose of the controller
    super.dispose();
  }
}
