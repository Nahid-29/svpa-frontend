import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../models/parking_data.dart';  // Import the file where your data is defined


// Function to check and update parking slot statuses
void checkParkingSlotStatus() {
  parkingData.forEach((region, locations) {
    for (var location in locations) {
      for (var slot in location.parkingSlots) {
        slot.updateOccupiedStatus();  // Update the occupation status
      }
    }
  });
}

// Function to create markers from the parkingData
Set<Marker> createParkingMarkers(Map<String, List<Location>> parkingData) {
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
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue), // Customize marker icon color
        ),
      );
    }
  });

  return parkingMarkers;
}

// Helper function to create the available parking slots text
String _getAvailableSlotsText(Location location) {
  int availableSlots = location.parkingSlots.where((slot) => !slot.isOccupied).length;
  return '$availableSlots available slots';
}

class Search_1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Changed to Provider<Position?> to allow null values
    final Position? currentPosition = Provider.of<Position?>(context);

    // Hardcoded parking locations (latitude, longitude)
    final List<LatLng> parkingLocations = [
      LatLng(23.8457, 90.2589),  // Slot 1: ~100 meters
      LatLng(23.8461, 90.2575),  // Slot 2: ~120 meters
      LatLng(23.8452, 90.2594),  // Slot 3: ~130 meters
      LatLng(23.8445, 90.2582),  // Slot 4: ~150 meters
      LatLng(23.8450, 90.2569),  // Slot 5: ~160 meters
      LatLng(23.8448, 90.2601),  // Slot 6: ~170 meters
      LatLng(23.8463, 90.2590),  // Slot 7: ~180 meters
      LatLng(23.8454, 90.2572),  // Slot 8: ~200 meters
      LatLng(23.8465, 90.2557),  // Slot 9: ~210 meters
      LatLng(23.8442, 90.2570),  // Slot 10: ~220 meters
      LatLng(23.8439, 90.2592),  // Slot 11: ~230 meters
      LatLng(23.8467, 90.2605),  // Slot 12: ~240 meters
      LatLng(23.8443, 90.2551),  // Slot 13: ~250 meters
      LatLng(23.8458, 90.2613),  // Slot 14: ~270 meters
      LatLng(23.8440, 90.2618),  // Slot 15: ~290 meters

      // Random suitable parking locations within a 5-km radius, spaced at appropriate distances:
      LatLng(23.8460, 90.2610),  // Slot 16: ~350 meters
      LatLng(23.8472, 90.2599),  // Slot 17: ~400 meters
      LatLng(23.8447, 90.2645),  // Slot 18: ~500 meters
      LatLng(23.8430, 90.2594),  // Slot 19: ~600 meters
      LatLng(23.8500, 90.2550),  // Slot 20: ~700 meters
      LatLng(23.8475, 90.2551),  // Slot 21: ~800 meters
      LatLng(23.8525, 90.2605),  // Slot 22: ~1 km
      LatLng(23.8550, 90.2617),  // Slot 23: ~1.2 km
      LatLng(23.8600, 90.2570),  // Slot 24: ~1.5 km
      LatLng(23.8700, 90.2500),  // Slot 25: ~2 km
      LatLng(23.8750, 90.2550),  // Slot 26: ~2.2 km
      LatLng(23.8850, 90.2650),  // Slot 27: ~2.5 km
      LatLng(23.8888, 90.2555),  // Slot 28: ~3 km
      LatLng(23.8900, 90.2490),  // Slot 29: ~3.5 km
      LatLng(23.8950, 90.2400),  // Slot 30: ~4 km
      LatLng(23.9000, 90.2300),  // Slot 31: ~4.5 km
      LatLng(23.9050, 90.2200),  // Slot 32: ~5 km
    ];

    // Access the parkingData list
    parkingData.forEach((region, locations) {
      print("Region: $region");
      for (var location in locations) {
        print("Location: ${location.locationName}");
        for (var slot in location.parkingSlots) {
          print("Slot ID: ${slot.id}, Type: ${slot.type}, Occupied: ${slot.isOccupied}");
        }
      }
    });

    // Example: Check and update parking slot statuses
    checkParkingSlotStatus();

    // Create a list of markers for the hardcoded parking locations
    // final Set<Marker> parkingMarkers = parkingLocations.map((location) {
    //   return Marker(
    //     markerId: MarkerId(location.toString()),
    //     position: location,
    //     infoWindow: InfoWindow(
    //       title: 'Parking Location',
    //       snippet: 'Available for parking',
    //     ),
    //     icon: BitmapDescriptor.defaultMarker,
    //   );
    // }).toSet();

    Set<Marker> parkingMarkers = createParkingMarkers(parkingData);

    return Scaffold(
      body: (currentPosition != null)
          ? Column(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height / 2,
            width: MediaQuery.of(context).size.width,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(currentPosition.latitude, currentPosition.longitude),
                zoom: 14.0,
              ),
              zoomGesturesEnabled: true,
              markers: parkingMarkers, // Add the markers for the hardcoded locations
            ),
          ),
        ],
      )
          : Center(child: CircularProgressIndicator()), // Show loading indicator while fetching location
    );
  }
}