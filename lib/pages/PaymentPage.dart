import 'package:flutter/material.dart';

class PaymentPage extends StatefulWidget {
  final double amount;

  PaymentPage({required this.amount});

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
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
      appBar: AppBar(title: Text("Payment")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Total Amount: \$${widget.amount.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            Text("Select Payment Method:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            // Payment Method Dropdown
            DropdownButton<String>(
              hint: Text("Select Payment Method"),
              value: selectedPaymentMethod,
              items: paymentMethods.map((method) {
                return DropdownMenuItem(
                  value: method,
                  child: Text(method),
                );
              }).toList(),
              onChanged: (method) {
                setState(() {
                  selectedPaymentMethod = method;
                });
              },
            ),
            SizedBox(height: 20),
            // Submit Button
            ElevatedButton(
              onPressed: () {
                if (selectedPaymentMethod != null) {
                  // Call the corresponding payment gateway function
                  switch (selectedPaymentMethod) {
                    case 'Bkash':
                      processBkashPayment(widget.amount);
                      break;
                    case 'Rocket':
                      processRocketPayment(widget.amount);
                      break;
                    case 'Nagad':
                      processNagadPayment(widget.amount);
                      break;
                    case 'Visa':
                      processVisaPayment(widget.amount);
                      break;
                    default:
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Invalid payment method selected"),
                        ),
                      );
                      return;
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Please select a payment method"),
                    ),
                  );
                }
              },
              child: Text("Submit Payment"),
            ),
          ],
        ),
      ),
    );
  }

  // Placeholder for Bkash Payment Gateway Integration
  void processBkashPayment(double amount) {
    // Here you would integrate Bkash API
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Bkash Payment Successful!")),
    );
    Navigator.pop(context); // Simulate successful payment
  }

  // Placeholder for Rocket Payment Gateway Integration
  void processRocketPayment(double amount) {
    // Here you would integrate Rocket API
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Rocket Payment Successful!")),
    );
    Navigator.pop(context); // Simulate successful payment
  }

  // Placeholder for Nagad Payment Gateway Integration
  void processNagadPayment(double amount) {
    // Here you would integrate Nagad API
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Nagad Payment Successful!")),
    );
    Navigator.pop(context); // Simulate successful payment
  }

  // Placeholder for Visa Payment Gateway Integration
  void processVisaPayment(double amount) {
    // Here you would integrate Visa API
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Visa Payment Successful!")),
    );
    Navigator.pop(context); // Simulate successful payment
  }
}
