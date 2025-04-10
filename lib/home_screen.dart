import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:weather_app/constant.dart' as k;
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoaded = false;
  num temp = 0;
  num feelsLike = 0;
  num press = 0;
  num hum = 0;
  num cover = 0;
  num windSpeed = 0;
  num windDeg = 0;
  int visibility = 0;
  String cityname = '';
  String countryCode = '';
  String weatherDescription = '';
  String weatherMain = '';
  String weatherIcon = '';
  DateTime sunrise = DateTime.now();
  DateTime sunset = DateTime.now();
  DateTime currentTime = DateTime.now();
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
            Color.fromARGB(255, 33, 120, 71),
            Color.fromARGB(255, 62, 1, 66),
          ], begin: Alignment.bottomLeft, end: Alignment.topRight)),
          child: Visibility(
            visible: isLoaded,
            replacement: Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Search bar
                  Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    height: MediaQuery.of(context).size.height * 0.09,
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 236, 234, 234)
                          .withOpacity(0.3),
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    child: Center(
                      child: TextFormField(
                        onFieldSubmitted: (String s) {
                          setState(() {
                            cityname = s;
                            getCityWeather(s);
                            isLoaded = false;
                            controller.clear();
                          });
                        },
                        controller: controller,
                        cursorColor: Colors.white,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search city',
                          hintStyle:
                              TextStyle(fontSize: 15, color: Colors.white),
                          prefixIcon: Icon(Icons.search_rounded,
                              size: 25, color: Colors.white),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 30),

                  // Location and summary header
                  Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.pin_drop, color: Colors.red, size: 36),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    countryCode.isNotEmpty
                                        ? '$cityname, $countryCode'
                                        : cityname,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Visibility(
                                    visible: weatherMain.isNotEmpty,
                                    child: Text(
                                      weatherMain,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 15),

                        // Temperature summary
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${temp.toStringAsFixed(1)}',
                                  style: TextStyle(
                                    fontSize: 60,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  '°C',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                            _getWeatherIconWidget(),
                          ],
                        ),

                        SizedBox(height: 5),

                        // Weather description and feels like
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              weatherDescription,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Feels like: ${feelsLike.toStringAsFixed(1)}°C',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // Sunrise and sunset
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.orange.withOpacity(0.7),
                          Colors.deepOrange.withOpacity(0.7)
                        ],
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Icon(Icons.wb_sunny, color: Colors.white, size: 30),
                            SizedBox(height: 5),
                            Text(
                              'Sunrise',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 14),
                            ),
                            Text(
                              DateFormat('h:mm a').format(sunrise),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Container(
                          height: 50,
                          width: 1,
                          color: Colors.white30,
                        ),
                        Column(
                          children: [
                            Icon(Icons.nightlight_round,
                                color: Colors.white, size: 30),
                            SizedBox(height: 5),
                            Text(
                              'Sunset',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 14),
                            ),
                            Text(
                              DateFormat('h:mm a').format(sunset),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // Main weather parameters
                  _buildWeatherTile(
                    'Temperature',
                    '${temp.toStringAsFixed(1)}°C',
                    Icons.thermostat_outlined,
                    Colors.red.shade100,
                    Colors.red.shade700,
                    _getTempIndicator(temp.toInt()),
                  ),

                  _buildWeatherTile(
                    'Pressure',
                    '${press.toStringAsFixed(0)} hPa',
                    Icons.speed_outlined,
                    Colors.purple.shade100,
                    Colors.purple.shade700,
                    _getPressureIndicator(press.toInt()),
                  ),

                  _buildWeatherTile(
                    'Humidity',
                    '${hum.toInt()}%',
                    Icons.water_drop_outlined,
                    Colors.teal.shade100,
                    Colors.teal.shade700,
                    _getHumidityIndicator(hum.toInt()),
                  ),

                  _buildWeatherTile(
                    'Cloud Cover',
                    '${cover.toInt()}%',
                    Icons.cloud_outlined,
                    Colors.blue.shade100,
                    Colors.indigo.shade700,
                    _getCloudIndicator(cover.toInt()),
                  ),

                  // Additional data
                  _buildWeatherTile(
                    'Wind',
                    '${windSpeed.toStringAsFixed(1)} m/s',
                    Icons.air_outlined,
                    Colors.amber.shade100,
                    Colors.amber.shade800,
                    _getWindDirectionIcon(windDeg.toInt()),
                  ),

                  _buildWeatherTile(
                    'Visibility',
                    '${(visibility / 1000).toStringAsFixed(1)} km',
                    Icons.visibility_outlined,
                    Colors.grey.shade200,
                    Colors.grey.shade800,
                    _getVisibilityIndicator(visibility),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _getWeatherIconWidget() {
    IconData iconData;
    Color iconColor;

    // Map weather main conditions to icons
    switch (weatherMain.toLowerCase()) {
      case 'clear':
        iconData = Icons.wb_sunny_rounded;
        iconColor = Colors.amber;
        break;
      case 'clouds':
        iconData = Icons.cloud_rounded;
        iconColor = Colors.grey.shade300;
        break;
      case 'rain':
        iconData = Icons.water_drop;
        iconColor = Colors.blue.shade300;
        break;
      case 'drizzle':
        iconData = Icons.grain;
        iconColor = Colors.blue.shade200;
        break;
      case 'thunderstorm':
        iconData = Icons.flash_on;
        iconColor = Colors.yellow;
        break;
      case 'snow':
        iconData = Icons.ac_unit;
        iconColor = Colors.white;
        break;
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'fog':
        iconData = Icons.cloud;
        iconColor = Colors.grey.shade400;
        break;
      default:
        iconData = Icons.cloud;
        iconColor = Colors.grey.shade400;
    }

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white24,
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 50,
      ),
    );
  }

  Widget _buildWeatherTile(String label, String value, IconData icon,
      Color iconBgColor, Color textColor, Widget indicator) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.12,
      margin: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.grey.shade100],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: Offset(0, 3),
            blurRadius: 5,
            spreadRadius: 1,
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: textColor,
                size: 28,
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      SizedBox(width: 8),
                      indicator,
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            cityname = 'Location permissions denied';
            isLoaded = true;
          });
          return;
        }
      }

      var p = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );

      if (p != null) {
        print('Latitude: ${p.latitude}, Longitude: ${p.longitude}');
        getCurrentCityWeather(p);
      } else {
        print('Location data not available');
        setState(() {
          cityname = 'Location not available';
          isLoaded = true;
        });
      }
    } catch (e) {
      print('Error getting location: $e');
      setState(() {
        cityname = 'Error getting location';
        isLoaded = true;
      });
    }
  }

  getCityWeather(String cityname) async {
    try {
      var client = http.Client();
      var uri = '${k.domain}q=$cityname&appid=${k.apiKey}';
      var url = Uri.parse(uri);
      print(url);
      var response = await client.get(url);
      if (response.statusCode == 200) {
        var data = response.body;
        var decodeData = json.decode(data);
        print(data);
        updateUI(decodeData);
        setState(() {
          isLoaded = true;
        });
      } else {
        print('Error: ${response.statusCode}');
        setState(() {
          cityname = 'City not found';
          isLoaded = true;
        });
      }
    } catch (e) {
      print('Error fetching city weather: $e');
      setState(() {
        cityname = 'Error fetching data';
        isLoaded = true;
      });
    }
  }

  getCurrentCityWeather(Position position) async {
    try {
      var client = http.Client();
      var uri =
          '${k.domain}lat=${position.latitude}&lon=${position.longitude}&appid=${k.apiKey}';
      var url = Uri.parse(uri);
      print(url);
      var response = await client.get(url);
      if (response.statusCode == 200) {
        var data = response.body;
        var decodeData = json.decode(data);
        print(data);
        updateUI(decodeData);
        setState(() {
          isLoaded = true;
        });
      } else {
        print('Error: ${response.statusCode}');
        setState(() {
          cityname = 'Weather data not available';
          isLoaded = true;
        });
      }
    } catch (e) {
      print('Error getting weather: $e');
      setState(() {
        cityname = 'Error fetching weather';
        isLoaded = true;
      });
    }
  }

  updateUI(var decodedData) {
    setState(() {
      if (decodedData == null) {
        temp = 0;
        feelsLike = 0;
        press = 0;
        hum = 0;
        cover = 0;
        windSpeed = 0;
        windDeg = 0;
        visibility = 0;
        cityname = 'Not available';
        countryCode = '';
        weatherDescription = '';
        weatherMain = '';
        weatherIcon = '';
        sunrise = DateTime.now();
        sunset = DateTime.now();
        currentTime = DateTime.now();
      } else {
        // Main weather data
        temp = decodedData['main']['temp'] -
            273.15; // Convert from Kelvin to Celsius
        feelsLike = decodedData['main']['feels_like'] - 273.15;
        press = decodedData['main']['pressure'];
        hum = decodedData['main']['humidity'];
        cover = decodedData['clouds']['all'];

        // Wind data
        windSpeed = decodedData['wind']['speed'];
        windDeg = decodedData['wind']['deg'];

        // Visibility
        visibility = decodedData['visibility'];

        // Location data
        cityname = decodedData['name'];
        if (decodedData['sys'] != null &&
            decodedData['sys']['country'] != null) {
          countryCode = decodedData['sys']['country'];
        } else {
          countryCode = '';
        }

        // Time data
        int dtTimestamp = decodedData['dt'];
        currentTime = DateTime.fromMillisecondsSinceEpoch(dtTimestamp * 1000);

        if (decodedData['sys'] != null) {
          if (decodedData['sys']['sunrise'] != null) {
            int sunriseTimestamp = decodedData['sys']['sunrise'];
            sunrise =
                DateTime.fromMillisecondsSinceEpoch(sunriseTimestamp * 1000);
          } else {
            sunrise = DateTime.now();
          }

          if (decodedData['sys']['sunset'] != null) {
            int sunsetTimestamp = decodedData['sys']['sunset'];
            sunset =
                DateTime.fromMillisecondsSinceEpoch(sunsetTimestamp * 1000);
          } else {
            sunset = DateTime.now();
          }
        }

        // Weather description
        if (decodedData['weather'] != null &&
            decodedData['weather'].length > 0) {
          weatherDescription = decodedData['weather'][0]['description'];
          // Capitalize first letter of each word
          weatherDescription = weatherDescription
              .split(' ')
              .map((word) => word[0].toUpperCase() + word.substring(1))
              .join(' ');

          weatherMain = decodedData['weather'][0]['main'];
          weatherIcon = decodedData['weather'][0]['icon'];
        } else {
          weatherDescription = '';
          weatherMain = '';
          weatherIcon = '';
        }
      }
    });
  }

  Widget _getTempIndicator(int temperature) {
    Color color;
    IconData icon;

    if (temperature < 5) {
      color = Colors.blue;
      icon = Icons.ac_unit;
    } else if (temperature < 20) {
      color = Colors.green;
      icon = Icons.check_circle;
    } else if (temperature < 30) {
      color = Colors.orange;
      icon = Icons.info_outline;
    } else {
      color = Colors.red;
      icon = Icons.warning_amber_rounded;
    }

    return Icon(
      icon,
      color: color,
      size: 18,
    );
  }

  Widget _getPressureIndicator(int pressure) {
    Color color;
    IconData icon;

    if (pressure < 980) {
      color = Colors.red;
      icon = Icons.arrow_downward;
    } else if (pressure < 1010) {
      color = Colors.orange;
      icon = Icons.remove;
    } else if (pressure < 1030) {
      color = Colors.green;
      icon = Icons.check_circle;
    } else {
      color = Colors.blue;
      icon = Icons.arrow_upward;
    }

    return Icon(
      icon,
      color: color,
      size: 18,
    );
  }

  Widget _getHumidityIndicator(int humidity) {
    Color color;
    IconData icon;

    if (humidity < 30) {
      color = Colors.orange;
      icon = Icons.water_drop_outlined;
    } else if (humidity < 60) {
      color = Colors.green;
      icon = Icons.check_circle;
    } else if (humidity < 80) {
      color = Colors.blue;
      icon = Icons.water;
    } else {
      color = Colors.indigo;
      icon = Icons.water_damage;
    }

    return Icon(
      icon,
      color: color,
      size: 18,
    );
  }

  Widget _getCloudIndicator(int percentage) {
    Color color;
    IconData icon;

    if (percentage < 30) {
      color = Colors.green;
      icon = Icons.check_circle;
    } else if (percentage < 70) {
      color = Colors.orange;
      icon = Icons.info_outline;
    } else {
      color = Colors.red;
      icon = Icons.warning_amber_rounded;
    }

    return Icon(
      icon,
      color: color,
      size: 18,
    );
  }

  Widget _getWindDirectionIcon(int degree) {
    IconData icon = Icons.navigation;
    Color color = Colors.blue;

    return Transform.rotate(
      angle: (degree * 3.14159 / 180),
      child: Icon(
        icon,
        color: color,
        size: 18,
      ),
    );
  }

  Widget _getVisibilityIndicator(int meters) {
    Color color;
    IconData icon;

    if (meters < 1000) {
      color = Colors.red;
      icon = Icons.visibility_off;
    } else if (meters < 5000) {
      color = Colors.orange;
      icon = Icons.visibility_outlined;
    } else {
      color = Colors.green;
      icon = Icons.visibility;
    }

    return Icon(
      icon,
      color: color,
      size: 18,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
