import 'package:arp/LoginPage/locationpage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final _firebase = FirebaseAuth.instance.currentUser;
  var userdata = {};
  var _userLocationLat;
  var _userLocationLon;
  void getData() async {
    final docs = await FirebaseFirestore.instance
        .collection('users')
        .doc(_firebase!.uid)
        .get();
    final info = docs.data();
    userdata = info as Map<String, dynamic>;
  }

  void getLocation() async {
    Location location = new Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    locationData = await location.getLocation();

    _userLocationLat = locationData.latitude;
    _userLocationLon = locationData.longitude;
  }

  @override
  void initState() {
    super.initState();
    getData();
    getLocation();
  }

  @override
  Widget build(BuildContext context) {
    // getData();
    // getLocation();
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColorLight,
        actions: [
          IconButton.outlined(
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
              icon: const Icon(Icons.logout_sharp))
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.9),
      body: Column(
        children: [
          Container(
            height: 220,
            padding: const EdgeInsets.all(8),
            width: double.infinity,
            child: Card(
              color: Colors.black38,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.all(16),
                    color: Colors.black,
                    height: 180,
                    width: 300 / 3,
                    child: const FlutterLogo(),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 15,
                        ),
                        Text(
                          userdata['name'] ?? "",
                          textAlign: TextAlign.start,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          userdata['gender'] ?? "",
                          textAlign: TextAlign.start,
                          style: const TextStyle(
                            fontSize: 17,
                            color: Colors.grey,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 1),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Chip(
                                avatar: const Icon(
                                  Icons.email,
                                  size: 14,
                                ),
                                avatarBoxConstraints:
                                    const BoxConstraints(maxWidth: 10),
                                // labelPadding: EdgeInsets.only(left: 4),
                                padding:
                                    const EdgeInsets.only(right: -4, left: 4),
                                label: Text(
                                  userdata['email'] ?? "",
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              Chip(
                                avatar: const Icon(
                                  Icons.phone,
                                  size: 14,
                                ),
                                avatarBoxConstraints:
                                    const BoxConstraints(maxWidth: 10),
                                // labelPadding: EdgeInsets.only(left: 4),
                                padding:
                                    const EdgeInsets.only(right: -4, left: 4),
                                label: Text(
                                  userdata['phonenumber'] ?? "",
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.add_location),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LocationPage(
                    lat: _userLocationLat,
                    lon: _userLocationLon,
                  ),
                ),
              );
            },
            label: const Text('See My Location'),
          ),
        ],
      ),
    );
  }
}
