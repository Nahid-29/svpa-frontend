import 'package:flutter/material.dart';
import '../map/models/parking_data.dart';

class PaymentPage_1 extends StatefulWidget {
  final double amount;
  final ParkingSlot selectedSlot; // Add selectedSlot as a parameter

  PaymentPage_1({required this.amount, required this.selectedSlot});

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage_1> {
  String? selectedPaymentMethod;

  List<String> paymentMethods = [
    'Bkash',
    'Rocket',
    'Nagad',
    'Visa',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Payment"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display total amount
            Text(
              "Total Amount: \$${widget.amount.toStringAsFixed(2)}",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Payment Method Section
            Text(
              "Select Payment Method:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 10),

            // Payment Method Dropdown
            DropdownButton<String>(
              hint: Text("Select Payment Method"),
              value: selectedPaymentMethod,
              items: paymentMethods.map((method) {
                return DropdownMenuItem(
                  value: method,
                  child: Text(
                    method,
                    style: TextStyle(fontSize: 16),
                  ),
                );
              }).toList(),
              onChanged: (method) {
                setState(() {
                  selectedPaymentMethod = method;
                });
              },
              isExpanded: true,
              underline: Divider(color: Colors.grey),
            ),
            SizedBox(height: 30),

            // Submit Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (selectedPaymentMethod != null) {
                    // Call the corresponding payment gateway function
                    _processPayment(widget.amount, selectedPaymentMethod!);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Please select a payment method"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                ),
                child: Text(
                  "Submit Payment",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Placeholder for Payment Gateway Integration based on selected method
  void _processPayment(double amount, String method) {
    switch (method) {
      case 'Bkash':
        _processBkashPayment(amount);
        break;
      case 'Rocket':
        _processRocketPayment(amount);
        break;
      case 'Nagad':
        _processNagadPayment(amount);
        break;
      case 'Visa':
        _processVisaPayment(amount);
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Invalid payment method selected"),
            backgroundColor: Colors.red,
          ),
        );
        return;
    }
  }

  void _processBkashPayment(double amount) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Bkash Payment Successful!")),
    );
    _occupySlot();
  }

  void _processRocketPayment(double amount) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Rocket Payment Successful!")),
    );
    _occupySlot();
  }

  void _processNagadPayment(double amount) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Nagad Payment Successful!")),
    );
    _occupySlot();
  }

  void _processVisaPayment(double amount) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Visa Payment Successful!")),
    );
    _occupySlot();
  }

  // Function to occupy the parking slot after successful payment
  void _occupySlot() {
    widget.selectedSlot.occupySlot(DateTime.now(), DateTime.now().add(Duration(hours: 2))); // Example: 2 hours parking
    Navigator.pop(context); // Simulate successful payment and return to the previous page
  }
}
