class ParkingSlot {
  final int id;             // Unique slot ID
  final String type;        // Type of vehicle (Car, Motorcycle, etc.)
  final double price;       // Price for parking
  bool isOccupied;          // Occupation status of the parking slot
  DateTime? startTime;      // Start time of the occupied state
  DateTime? endTime;        // End time of the occupied state

  ParkingSlot({
    required this.id,
    required this.type,
    required this.price,
    this.isOccupied = false,
    this.startTime,
    this.endTime,
  });

  // Method to check if the parking slot is still occupied
  void updateOccupiedStatus() {
    if (isOccupied && endTime != null && DateTime.now().isAfter(endTime!)) {
      isOccupied = false;
      startTime = null;
      endTime = null;
    }
  }

  // Method to occupy a parking slot
  void occupySlot(DateTime start, DateTime end) {
    startTime = start;
    endTime = end;
    isOccupied = true;
  }

  // Method to release a parking slot manually (if needed)
  void releaseSlot() {
    isOccupied = false;
    startTime = null;
    endTime = null;
  }
}

class Location {
  final int locationId;     // Unique location ID
  final double latitude;    // Latitude of the location
  final double longitude;   // Longitude of the location
  final String locationName; // Location name (Mirpur, Gulshan, etc.)
  final List<ParkingSlot> parkingSlots; // List of parking slots at this location

  Location({
    required this.locationId,
    required this.latitude,
    required this.longitude,
    required this.locationName,
    required this.parkingSlots,
  });
}

class Region {
  final String regionName;  // Region name (e.g., Savar, Mirpur, Banani, etc.)
  final List<Location> locations;  // List of locations in the region

  Region({
    required this.regionName,
    required this.locations,
  });
}

// Sample Data: Regions, Locations, and Slots
Map<String, List<Location>> parkingData = {
  'Savar': [
    Location(
      locationId: 1,
      latitude: 23.8286,
      longitude: 90.2792,
      locationName: 'Savar Location A',
      parkingSlots: [
        ParkingSlot(
          id: 1,
          type: 'Car',
          price: 50,
          isOccupied: true,
          startTime: DateTime.now().subtract(Duration(hours: 1)), // started 1 hour ago
          endTime: DateTime.now().add(Duration(hours: 1)),        // ends 1 hour later
        ),
        ParkingSlot(id: 2, type: 'Motorcycle', price: 20),
      ],
    ),
    Location(
      locationId: 2,
      latitude: 23.8295,
      longitude: 90.2801,
      locationName: 'Savar Location B',
      parkingSlots: [
        ParkingSlot(id: 3, type: 'Car', price: 40),
        ParkingSlot(id: 4, type: 'Motorcycle', price: 15),
      ],
    ),
  ],
  'Mirpur': [
    Location(
      locationId: 3,
      latitude: 23.8040,
      longitude: 90.3671,
      locationName: 'Mirpur Location A',
      parkingSlots: [
        ParkingSlot(
          id: 5,
          type: 'Car',
          price: 60,
          isOccupied: true,
          startTime: DateTime.now().subtract(Duration(hours: 3)),  // started 3 hours ago
          endTime: DateTime.now().subtract(Duration(minutes: 30)), // ended 30 mins ago
        ), // This slot will be automatically marked as not occupied
        ParkingSlot(id: 6, type: 'Motorcycle', price: 25),
      ],
    ),
  ],
  'Banani': [
    Location(
      locationId: 4,
      latitude: 23.7880,
      longitude: 90.4020,
      locationName: 'Banani Location A',
      parkingSlots: [
        ParkingSlot(id: 7, type: 'Car', price: 70),
        ParkingSlot(id: 8, type: 'Motorcycle', price: 30),
      ],
    ),
  ],
  'Bashundhara': [
    Location(
      locationId: 5,
      latitude: 23.8151,
      longitude: 90.4280,
      locationName: 'Bashundhara Location A',
      parkingSlots: [
        ParkingSlot(id: 9, type: 'Car', price: 80),
        ParkingSlot(id: 10, type: 'Motorcycle', price: 35),
      ],
    ),
  ],
  'Gulshan': [
    Location(
      locationId: 6,
      latitude: 23.7808,
      longitude: 90.4193,
      locationName: 'Gulshan Location A',
      parkingSlots: [
        ParkingSlot(id: 11, type: 'Car', price: 100),
        ParkingSlot(id: 12, type: 'Motorcycle', price: 50),
      ],
    ),
  ],
  // Additional regions and locations can be added similarly
};

// Function to check and update parking slot statuses
void checkParkingSlotStatus() {
  parkingData.forEach((region, locations) {
    for (var location in locations) {
      for (var slot in location.parkingSlots) {
        slot.updateOccupiedStatus(); // Check and update each slot's status
      }
    }
  });
}




void main() {
  // Initial status check
  checkParkingSlotStatus();

  // Example: Printing the status of parking slots after updating their occupation status
  parkingData.forEach((region, locations) {
    print("Region: $region");
    for (var location in locations) {
      print("Location: ${location.locationName}");
      for (var slot in location.parkingSlots) {
        print("Slot ID: ${slot.id}, Type: ${slot.type}, Occupied: ${slot.isOccupied}");
      }
    }
  });
}
