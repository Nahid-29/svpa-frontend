import 'package:flutter/material.dart';
import 'paymentPage.dart';
import '../map/models/parking_data.dart';

class ParkingSlotSelectPage extends StatefulWidget {
  @override
  _ParkingSlotSelectPageState createState() => _ParkingSlotSelectPageState();
}

class _ParkingSlotSelectPageState extends State<ParkingSlotSelectPage> {
  String? selectedRegion;
  String? selectedLocation;
  ParkingSlot? selectedSlot;
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  // Function to check if the selected slot is available
  bool isSlotAvailable() {
    return selectedSlot != null && !selectedSlot!.isOccupied;
  }

  // Function to calculate the amount based on the selected slot and times
  double calculateAmount() {
    if (startTime != null && endTime != null && selectedSlot != null) {
      final double hours = (endTime!.hour + endTime!.minute / 60) -
          (startTime!.hour + startTime!.minute / 60);
      return hours * selectedSlot!.price;
    }
    return 0;
  }

  // Function to open time picker
  Future<void> selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          startTime = picked;
        } else {
          endTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Parking Slot"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Region Dropdown
            DropdownButton<String>(
              hint: Text("Select Region"),
              value: selectedRegion,
              items: parkingData.keys.map((region) {
                return DropdownMenuItem(
                  value: region,
                  child: Text(region),
                );
              }).toList(),
              onChanged: (region) {
                setState(() {
                  selectedRegion = region;
                  selectedLocation = null;
                  selectedSlot = null;
                });
              },
            ),

            // Location Dropdown
            if (selectedRegion != null)
              DropdownButton<String>(
                hint: Text("Select Location"),
                value: selectedLocation,
                items: parkingData[selectedRegion]!.map((location) {
                  return DropdownMenuItem(
                    value: location.locationName,
                    child: Text(location.locationName),
                  );
                }).toList(),
                onChanged: (location) {
                  setState(() {
                    selectedLocation = location;
                    selectedSlot = null;
                  });
                },
              ),

            // Slot Dropdown
            if (selectedLocation != null)
              DropdownButton<ParkingSlot>(
                hint: Text("Select Slot"),
                value: selectedSlot,
                items: parkingData[selectedRegion]!
                    .firstWhere((loc) => loc.locationName == selectedLocation)
                    .parkingSlots
                    .map((slot) {
                  return DropdownMenuItem(
                    value: slot,
                    child: Text(
                      "Slot ${slot.id} - ${slot.type} (\$${slot.price}/hour)",
                    ),
                  );
                }).toList(),
                onChanged: (slot) {
                  setState(() {
                    selectedSlot = slot;
                  });
                },
              ),

            SizedBox(height: 10),
            // Time Pickers
            Row(
              children: [
                Text("Start Time: "),
                ElevatedButton(
                  onPressed: () => selectTime(context, true),
                  child: Text(
                    startTime != null
                        ? startTime!.format(context)
                        : "Select Start Time",
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text("End Time: "),
                ElevatedButton(
                  onPressed: () => selectTime(context, false),
                  child: Text(
                    endTime != null
                        ? endTime!.format(context)
                        : "Select End Time",
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Check availability and calculate payment
            ElevatedButton(
              onPressed: () {
                if (isSlotAvailable()) {
                  final amount = calculateAmount();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentPage(amount: amount),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("The selected parking slot is occupied!"),
                    ),
                  );
                }
              },
              child: Text("Check Availability and Proceed"),
            ),
          ],
        ),
      ),
    );
  }
}
