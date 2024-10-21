import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:svpa_frontend/map/screens/search.dart';
import 'package:svpa_frontend/map/screens/search_1.dart';
import 'package:svpa_frontend/map/services/geolocator_service.dart';
import 'package:geolocator/geolocator.dart';

class FindLocation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureProvider<Position?>(
      create: (context) => GeoLocatorService().getLocation(),
      initialData: null, // Until the location data is available, initialData is null
      child: MaterialApp(
        title: 'Find Parking Slot',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Search_1(), // Search will have access to the location data
      ),
    );
  }
}
