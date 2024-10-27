import 'package:cloud_firestore/cloud_firestore.dart';
import 'parking_data.dart';
void addParkingDataToFirestore() {
  final firestore = FirebaseFirestore.instance;

  parkingData.forEach((regionName, locations) async {
    // Add each region document
    var regionDocRef = firestore.collection('Regions').doc(regionName);
    await regionDocRef.set({'regionName': regionName});

    for (var location in locations) {
      // Add each location in the Locations subcollection
      var locationDocRef = regionDocRef.collection('Locations').doc(location.locationName.toString());
      await locationDocRef.set({

        'latitude': location.latitude,
        'longitude': location.longitude,
        'locationName': location.locationName,
      });

      for (var slot in location.parkingSlots) {
        // Add each parking slot in the ParkingSlots subcollection
        var slotDocRef = locationDocRef.collection('ParkingSlots').doc(slot.id.toString());
        await slotDocRef.set({
          'id': slot.id,
          'type': slot.type,
          'price': slot.price,
          'isOccupied': slot.isOccupied,
          'startTime': slot.startTime?.toIso8601String(),
          'endTime': slot.endTime?.toIso8601String(),
        });
      }
    }
  });
}
