
import 'parking_data.dart';  // Import the file where your data is defined

void main() {
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
}

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
