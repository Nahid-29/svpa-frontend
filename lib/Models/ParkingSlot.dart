class ParkingSlot {
  final int id;
  final String type;
  final double price;
  bool isOccupied;

  ParkingSlot({
    required this.id,
    required this.type,
    required this.price,
    this.isOccupied = false,
  });
}

// Sample Data: Regions, Locations, and Slots
Map<String, Map<String, List<ParkingSlot>>> parkingData = {
  'Region 1': {
    'Location A': [
      ParkingSlot(id: 1, type: 'Car', price: 50),
      ParkingSlot(id: 2, type: 'Motorcycle', price: 20),
    ],
    'Location B': [
      ParkingSlot(id: 3, type: 'Car', price: 40),
      ParkingSlot(id: 4, type: 'Motorcycle', price: 15),
    ],
  },
  'Region 2': {
    'Location C': [
      ParkingSlot(id: 5, type: 'Car', price: 60),
      ParkingSlot(id: 6, type: 'Motorcycle', price: 25),
    ],
  },
};
