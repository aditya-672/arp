import 'package:flutter/material.dart';

class LocationPage extends StatelessWidget {
  const LocationPage({super.key, required this.lat, required this.lon});

  final double lat;
  final double lon;

  String get locationImage {
    return 'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lon&zoom=17&size=1000x1000&maptype=roadmap&markers=color:red%7Clabel:S%7C$lat,$lon&key=example';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Location'),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: Image.network(
          locationImage,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
