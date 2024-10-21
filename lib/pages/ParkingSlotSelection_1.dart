import 'package:flutter/material.dart';
import '../map/models/parking_data.dart';
import 'PaymentPage_1.dart';

class ParkingSlotSelectPage_1 extends StatefulWidget {
  @override
  _ParkingSlotSelectPageState createState() => _ParkingSlotSelectPageState();
}

class _ParkingSlotSelectPageState extends State<ParkingSlotSelectPage_1> {
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
        title: Text("Select Parking Slot", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Region Dropdown
              Text("Region", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
              SizedBox(height: 10),
              DropdownButton<String>(
                hint: Text("Select Region"),
                value: selectedRegion,
                isExpanded: true,
                items: parkingData.keys.map((region) {
                  return DropdownMenuItem(
                    value: region,
                    child: Text(region, style: TextStyle(fontSize: 16)),
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

              SizedBox(height: 20),

              // Location Dropdown
              if (selectedRegion != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Location", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                    SizedBox(height: 10),
                    DropdownButton<String>(
                      hint: Text("Select Location"),
                      value: selectedLocation,
                      isExpanded: true,
                      items: parkingData[selectedRegion]!.map((location) {
                        return DropdownMenuItem(
                          value: location.locationName,
                          child: Text(location.locationName, style: TextStyle(fontSize: 16)),
                        );
                      }).toList(),
                      onChanged: (location) {
                        setState(() {
                          selectedLocation = location;
                          selectedSlot = null;
                        });
                      },
                    ),
                  ],
                ),

              SizedBox(height: 20),

              // Slot Dropdown
              if (selectedLocation != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Slot", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                    SizedBox(height: 10),
                    DropdownButton<ParkingSlot>(
                      hint: Text("Select Slot"),
                      value: selectedSlot,
                      isExpanded: true,
                      items: parkingData[selectedRegion]!
                          .firstWhere((loc) => loc.locationName == selectedLocation)
                          .parkingSlots
                          .map((slot) {
                        return DropdownMenuItem(
                          value: slot,
                          child: Text(
                            "Slot ${slot.id} - ${slot.type} (\$${slot.price}/hour)",
                            style: TextStyle(fontSize: 16),
                          ),
                        );
                      }).toList(),
                      onChanged: (slot) {
                        setState(() {
                          selectedSlot = slot;
                        });
                      },
                    ),
                  ],
                ),

              SizedBox(height: 20),

              // Time Pickers
              Text("Select Time", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
              SizedBox(height: 10),
              Row(
                children: [
                  Text("Start Time: ", style: TextStyle(fontSize: 16)),
                  ElevatedButton(
                    onPressed: () => selectTime(context, true),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                    child: Text(
                      startTime != null
                          ? startTime!.format(context)
                          : "Select Start Time",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text("End Time: ", style: TextStyle(fontSize: 16)),
                  ElevatedButton(
                    onPressed: () => selectTime(context, false),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                    child: Text(
                      endTime != null
                          ? endTime!.format(context)
                          : "Select End Time",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 30),

              // Check availability and calculate payment
              ElevatedButton(
                onPressed: () {
                  if (isSlotAvailable()) {
                    final amount = calculateAmount();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentPage_1(
                          amount: amount,
                          selectedSlot: selectedSlot!, // Pass selectedSlot to PaymentPage
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("The selected parking slot is occupied!"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                ),
                child: Text(
                  "Check Availability and Proceed",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
