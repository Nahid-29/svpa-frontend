import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/parking_data.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  Location? selectedLocation;
  bool isMapFullScreen = true;
  GoogleMapController? mapController; // Add map controller

  // Fetch Regions and Locations from Firestore
  Future<Map<String, List<Location>>> fetchRegionsAndLocations() async {
    Map<String, List<Location>> regionsData = {};

    QuerySnapshot regionSnapshot =
    await FirebaseFirestore.instance.collection('Regions').get();

    for (var regionDoc in regionSnapshot.docs) {
      String regionName = regionDoc.id;
      List<Location> locations = [];

      QuerySnapshot locationSnapshot = await regionDoc.reference
          .collection('Locations')
          .get();

      for (var locationDoc in locationSnapshot.docs) {
        var locationData = locationDoc.data() as Map<String, dynamic>;

        // Parse parking slots if they exist in this location
        List<ParkingSlot> parkingSlots = [];
        QuerySnapshot slotSnapshot = await locationDoc.reference
            .collection('ParkingSlots')
            .get();

        for (var slotDoc in slotSnapshot.docs) {
          var slotData = slotDoc.data() as Map<String, dynamic>;
          parkingSlots.add(ParkingSlot(
            id: slotData['id'],
            type: slotData['type'],
            price: slotData['price'],
            isOccupied: slotData['isOccupied'],
          ));
        }

        locations.add(Location(

          latitude: locationData['latitude'],
          longitude: locationData['longitude'],
          locationName: locationData['locationName'],
          parkingSlots: parkingSlots,
        ));
      }
      regionsData[regionName] = locations;
    }

    return regionsData;
  }

  // Handle marker taps
  void _onMarkerTapped(Location location) {
    setState(() {
      selectedLocation = location;
      isMapFullScreen = false;
    });
    // Animate camera to the selected location
    mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(location.latitude, location.longitude),
        16.0, // Adjust zoom level as desired
      ),
    );
  }

  // Create markers dynamically
  Set<Marker> createParkingMarkers(Map<String, List<Location>> parkingData) {
    Set<Marker> parkingMarkers = {};

    parkingData.forEach((region, locations) {
      for (var location in locations) {
        parkingMarkers.add(
          Marker(
            markerId: MarkerId('location_${location.locationName}'),
            position: LatLng(location.latitude, location.longitude),
            infoWindow: InfoWindow(
              title: location.locationName,
              snippet: '${location.parkingSlots.where((slot) => !slot.isOccupied).length} available slots',
              onTap: () {
                _onMarkerTapped(location);
              },
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueBlue),
          ),
        );
      }
    });

    return parkingMarkers;
  }

  @override
  Widget build(BuildContext context) {
    final Position? currentPosition = Provider.of<Position?>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Parking Locations'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,

      ),
      body: currentPosition != null
          ? FutureBuilder<Map<String, List<Location>>>(
        future: fetchRegionsAndLocations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error loading locations."));
          }

          var parkingData = snapshot.data!;
          var parkingMarkers = createParkingMarkers(parkingData);

          return Column(
            children: <Widget>[
              Container(
                height: isMapFullScreen
                    ? MediaQuery.of(context).size.height
                    : MediaQuery.of(context).size.height / 2,
                width: MediaQuery.of(context).size.width,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      currentPosition.latitude,
                      currentPosition.longitude,
                    ),
                    zoom: 14.0,
                  ),
                  markers: parkingMarkers,
                  onMapCreated: (GoogleMapController controller) {
                    mapController = controller; // Initialize map controller
                  },
                  onTap: (_) {
                    setState(() {
                      isMapFullScreen = true;
                      selectedLocation = null;
                    });
                  },
                ),
              ),
              if (selectedLocation != null && !isMapFullScreen)
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            selectedLocation!.locationName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                        ),
                        ...selectedLocation!.parkingSlots.map((slot) {
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            elevation: 4,
                            child: ListTile(
                              title: Text(
                                'Slot ${slot.id} (${slot.type})',
                                style: TextStyle(fontSize: 16),
                              ),
                              subtitle: Text(
                                slot.isOccupied ? 'Occupied' : 'Available',
                                style: TextStyle(
                                  color: slot.isOccupied
                                      ? Colors.red
                                      : Colors.green,
                                ),
                              ),
                              trailing: Text(
                                'Price: \$${slot.price}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      )
          : Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
