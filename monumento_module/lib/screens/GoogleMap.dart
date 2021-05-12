import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapPage extends StatefulWidget {
  final String address;
  GoogleMapPage({this.address});

  @override
  _GoogleMapPageState createState() => _GoogleMapPageState();
}

class _GoogleMapPageState extends State<GoogleMapPage> {
  Completer<GoogleMapController> _completer = Completer();
  Future<void> animateTo(double lat, double lng) async {
    final c = await _completer.future;
    final p = CameraPosition(target: LatLng(lat, lng), zoom: 14.4746);
    setState(() {
      c.animateCamera(CameraUpdate.newCameraPosition(p));
    });
  }

  @override
  void initState() {
    super.initState();
  }

  Future<Object> _geocoder(String query) async {
    var addresses = await Geocoder.local.findAddressesFromQuery(query);
    var first = addresses.first;

    return first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: FutureBuilder(
            future: _geocoder(widget.address),
            builder: (context, snapshot) {
              _geocoder(widget.address);
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              return map(snapshot, _completer);
            }),
      ),
    );
  }
}

class map extends StatefulWidget {
  final snapshot;

  final Completer<GoogleMapController> _completer;
  map(this.snapshot, this._completer);

  @override
  _mapState createState() => _mapState();
}

class _mapState extends State<map> with AutomaticKeepAliveClientMixin {
  CameraPosition _intial =
      CameraPosition(target: LatLng(26.152973, 85.901413), zoom: 6.4746);
  @override
  bool get wantKeepAlive => true;

  Future<void> animateTo() async {
    final c = await widget._completer.future;

    final p = CameraPosition(
      target: LatLng(widget.snapshot.data.coordinates.latitude,
          widget.snapshot.data.coordinates.longitude),
      zoom: 18.4746,
      tilt: 40,
    );

    c.animateCamera(CameraUpdate.newCameraPosition(p));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: GoogleMap(
        zoomControlsEnabled: false,
        mapType: MapType.normal,
        myLocationEnabled: false,
        rotateGesturesEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          widget._completer.complete(controller);

          animateTo();
        },
        initialCameraPosition: _intial,
        markers: Set<Marker>.of([
          Marker(
              markerId: MarkerId("Home"),
              position: LatLng(widget.snapshot.data.coordinates.latitude,
                  widget.snapshot.data.coordinates.longitude),
              infoWindow: InfoWindow(
                  snippet: "Courstey : Bihar",
                  onTap: () {
                    debugPrint("hello");
                  }),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed))
        ]),
      ),
    );
  }
}
