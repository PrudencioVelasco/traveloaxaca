import 'package:google_maps_flutter/google_maps_flutter.dart';

class Config {
  final String appName = 'Travel Oaxaca';
  final String mapAPIKey = 'AIzaSyDybQ1uOBgcVqsgMfj13EMiRlhB9Wv6LoY';
  final String countryName = 'Bangladesh';
  final String splashIcon = 'assets/images/splash.png';
  final String supportEmail = 'prudencio.vepa@gmail.com';
  final String privacyPolicyUrl =
      'https://www.freeprivacypolicy.com/pri************';
  final String ourWebsiteUrl = 'https://codecanyon.net/user/mrblab24/portfolio';
  final String iOSAppId = '000000000';

  final String specialState1 = 'Sylhet';
  final String specialState2 = 'Chittagong';

  //Intro images
  final String introImage1 = 'assets/images/travel6.png';
  final String introImage2 = 'assets/images/travel1.png';
  final String introImage3 = 'assets/images/travel5.png';

  final double latitud_inicial = 17.0669;
  final double longitud_inicial = -96.7203;
  // your country lattidtue & logitude
  final CameraPosition initialCameraPosition = CameraPosition(
    target: LatLng(17.0669, -96.7203),
    zoom: 10,
  );

  //Language Setup

  final List<String> languages = ['English', 'Spanish'];

  //google maps marker icons
  final String hotelIcon = 'assets/images/hotel.png';
  final String restaurantIcon = 'assets/images/restaurant.png';
  final String hotelPinIcon = 'assets/images/hotel_pin.png';
  final String restaurantPinIcon = 'assets/images/restaurant_pin.png';
  final String drivingMarkerIcon = 'assets/images/driving_pin.png';
  final String placeMarkerIcon = 'assets/images/lugar.png';
  final String destinationMarkerIcon =
      'assets/images/destination_map_marker.png';
}
