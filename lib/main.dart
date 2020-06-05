import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'custom_info_widget.dart';

void main() => runApp(MyApp());


class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: "/",
      routes: {
        "/": (context) => HomePage(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  //initialize paint object which contain widget tree and marker location
  PointObject point = PointObject(
    child:  Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Object',style: TextStyle(fontSize:16,fontWeight: FontWeight.w600),),
            SizedBox(height: 8.0,),
            Text('Position',style: TextStyle(fontSize:16,fontWeight: FontWeight.w600),),
            SizedBox(height: 8.0,),
            Text('Altitude',style: TextStyle(fontSize:16,fontWeight: FontWeight.w600),),
            SizedBox(height: 8.0,),
            Text('Angle',style: TextStyle(fontSize:16,fontWeight: FontWeight.w600),),
            SizedBox(height: 8.0,),
            Text('Came',style: TextStyle(fontSize:16,fontWeight: FontWeight.w600),),
            SizedBox(height: 8.0,),
            Text('Left',style: TextStyle(fontSize:16,fontWeight: FontWeight.w600),),
            SizedBox(height: 8.0,),
            Text('Duration',style: TextStyle(fontSize:16,fontWeight: FontWeight.w600),),
          ],
        ),
        SizedBox(width: 15.0,),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('EASYTRAX STARLET FMB',style: TextStyle(fontSize:16),),
              SizedBox(height: 8.0,),
              Text('23.836065° 90.368442°',style: TextStyle(fontSize:16),),
              SizedBox(height: 8.0,),
              Text('Altitude',style: TextStyle(fontSize:16),),
              SizedBox(height: 8.0,),
              Text('Angle',style: TextStyle(fontSize:16,),),
              SizedBox(height: 8.0,),
              Text('Came',style: TextStyle(fontSize:16,),),
              SizedBox(height: 8.0,),
              Text('Left',style: TextStyle(fontSize:16,),),
              SizedBox(height: 8.0,),
              Text('Duration',style: TextStyle(fontSize:16,),),
            ],
          ),
        ),
      ],
    ),
    location: LatLng(47.6, 8.8796),
  );

  StreamSubscription _mapIdleSubscription;
  InfoWidgetRoute _infoWidgetRoute;
  GoogleMapController _mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.green,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: const LatLng(47.6, 8.6796),
            zoom: 10,
          ),
          /*circles: Set<Circle>()
            ..add(Circle(
              circleId: CircleId('hi2'),
              center: LatLng(47.6, 8.8796),
              radius: 50,
              strokeWidth: 10,
              strokeColor: Colors.black,
            )),*/
          markers: Set<Marker>()
            ..add(Marker(
              markerId: MarkerId(point.location.latitude.toString() +
                  point.location.longitude.toString()),
              position: point.location,
              onTap: () => _onTap(point),
            )),
          onMapCreated: (mapController) {
            _mapController = mapController;
          },

          /// This fakes the onMapIdle, as the googleMaps on Map Idle does not always work
          /// (see: https://github.com/flutter/flutter/issues/37682)
          /// When the Map Idles and a _infoWidgetRoute exists, it gets displayed.
          onCameraMove: (newPosition) {
            _mapIdleSubscription?.cancel();
            _mapIdleSubscription = Future.delayed(Duration(milliseconds: 50))
                .asStream()
                .listen((_) {
              if (_infoWidgetRoute != null) {
                Navigator.of(context, rootNavigator: true)
                    .push(_infoWidgetRoute)
                    .then<void>(
                      (newValue) {
                    _infoWidgetRoute = null;
                  },
                );
              }
            });
          },
        ),
      ),
    );
  }
  /// now my _onTap Method. First it creates the Info Widget Route and then
  /// animates the Camera twice:
  /// First to a place near the marker, then to the marker.
  /// This is done to ensure that onCameraMove is always called

  _onTap(PointObject point) async {
    final RenderBox renderBox = context.findRenderObject();
    Rect _itemRect = renderBox.localToGlobal(Offset.zero) & renderBox.size;

    _infoWidgetRoute = InfoWidgetRoute(
      child: point.child,
      buildContext: context,
      textStyle: const TextStyle(
        fontSize: 14,
        color: Colors.black,
      ),
      mapsWidgetSize: _itemRect,
      width: 320, //info width
      height: 238, //info height
    );

    await _mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            point.location.latitude,
            point.location.longitude,
          ),
          zoom: 15,
        ),
      ),
    );
    await _mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            point.location.latitude,
            point.location.longitude,
          ),
          zoom: 15,
        ),
      ),
    );
  }
}