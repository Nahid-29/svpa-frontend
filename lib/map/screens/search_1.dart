import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../models/parking_data.dart'; // Import the file where your data is defined

// Function to check and update parking slot statuses
void checkParkingSlotStatus() {
  parkingData.forEach((region, locations) {
    for (var location in locations) {
      for (var slot in location.parkingSlots) {
        slot.updateOccupiedStatus(); // Update the occupation status
      }
    }
  });
}

// Function to create markers from the parkingData
Set<Marker> createParkingMarkers(
    Map<String, List<Location>> parkingData, Function(Location) onMarkerTap) {
  Set<Marker> parkingMarkers = {};

  parkingData.forEach((region, locations) {
    for (var location in locations) {
      // Update parking slot status before creating markers
      location.parkingSlots.forEach((slot) {
        slot.updateOccupiedStatus(); // Ensure the slot status is up-to-date
      });

      // Create a marker for the location
      parkingMarkers.add(
        Marker(
          markerId: MarkerId('location_${location.locationId}'),
          position: LatLng(location.latitude, location.longitude),
          infoWindow: InfoWindow(
            title: location.locationName,
            snippet: _getAvailableSlotsText(location),
            onTap: () {
              onMarkerTap(location); // Call the provided callback on tap
            },
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueBlue), // Customize marker icon color
        ),
      );
    }
  });

  return parkingMarkers;
}

// Helper function to create the available parking slots text
String _getAvailableSlotsText(Location location) {
  int availableSlots =
      location.parkingSlots.where((slot) => !slot.isOccupied).length;
  return '$availableSlots available slots';
}

class Search_1 extends StatefulWidget {
  @override
  _Search_1State createState() => _Search_1State();
}

class _Search_1State extends State<Search_1> {
  // Track if a marker has been tapped and store the relevant location
  Location? selectedLocation;
  bool isMapFullScreen = true;

  // Function to handle when a marker is tapped
  void _onMarkerTapped(Location location) {
    setState(() {
      selectedLocation = location;
      isMapFullScreen = false; // Shrink the map to show parking slots
    });
  }

  @override
  Widget build(BuildContext context) {
    // Changed to Provider<Position?> to allow null values
    final Position? currentPosition = Provider.of<Position?>(context);

    // Access the parkingData list
    parkingData.forEach((region, locations) {
      print("Region: $region");
      for (var location in locations) {
        print("Location: ${location.locationName}");
        for (var slot in location.parkingSlots) {
          print(
              "Slot ID: ${slot.id}, Type: ${slot.type}, Occupied: ${slot.isOccupied}");
        }
      }
    });

    // Example: Check and update parking slot statuses
    checkParkingSlotStatus();

    Set<Marker> parkingMarkers = createParkingMarkers(parkingData, _onMarkerTapped);

    return Scaffold(
      appBar: AppBar(
        title: Text('Parking Locations'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),  // Back symbol
          onPressed: () {
            Navigator.pop(context);  // Navigate back to the previous screen
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // You can add search functionality here
            },
          ),
        ],
      ),
      body: (currentPosition != null)
          ? Column(
        children: <Widget>[
          // Full-screen or half-screen map
          Container(
            height: isMapFullScreen
                ? MediaQuery.of(context).size.height
                : MediaQuery.of(context).size.height / 2,
            width: MediaQuery.of(context).size.width,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(currentPosition.latitude,
                    currentPosition.longitude),
                zoom: 14.0,
              ),
              zoomGesturesEnabled: true,
              markers: parkingMarkers, // Add the markers for the locations
              onMapCreated: (GoogleMapController controller) {},
              onTap: (_) {
                // When tapping on the map, reset to full screen (if needed)
                setState(() {
                  isMapFullScreen = true;
                  selectedLocation = null;
                });
              },
            ),
          ),
          // Display selected location and its slots
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
                            slot.isOccupied
                                ? 'Occupied'
                                : 'Available',
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
      )
          : Center(
        child: CircularProgressIndicator(),
      ), // Show loading indicator while fetching location
    );
  }
}
