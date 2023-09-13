import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:model_viewer_plus/model_viewer_plus.dart';

class Weather {
  final double temp;
  final String status;
  final sunrise;
  final sunset;

  const Weather({
    required this.temp,
    required this.status,
    required this.sunrise,
    required this.sunset,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    var t = json['list'][0]['main']['temp'] - 273.15;
    var s;
    switch (json['list'][0]['weather'][0]['main']) {
      case "Clear":
        {
          s = "Céu Limpo";
        }
        break;
      case "Clouds":
        {
          s = "Nublado";
        }
        break;
      case "Rain":
        {
          s = "Chuva";
        }
        break;

      default:
        {
          json['list'][0]['weather'][0]['main'];
        }
        break;
    }
    return Weather(
      temp: t,
      status: s,
      sunrise: DateFormat("HH:mm").format(
          DateTime.fromMillisecondsSinceEpoch(json['city']['sunrise'] * 1000)),
      sunset: DateFormat("HH:mm").format(
          DateTime.fromMillisecondsSinceEpoch(json['city']['sunset'] * 1000)),
    );
  }
}

class City {
  final String name;
  final int id;
  var weather;

  City(this.name, this.id) {
    get_weather();
  }

  void get_weather() async {
    final response = await http.get(Uri.parse(
        'http://api.openweathermap.org/data/2.5/forecast?id=$id&APPID=97f9f992f1fa553711ac1cc06e46524f'));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      weather = Weather.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load weather');
    }
  }
}

void main() {
  runApp(
    MaterialApp(
      title: 'Passing Data',
      home: CitiesScreen(cities: <City>[
        City("Lisboa", 2267056),
        City("Leiria", 2267094),
        City("Coimbra", 2740636),
        City("Porto", 2735941),
        City("Faro", 2268337)
      ]),
    ),
  );
}

class CitiesScreen extends StatefulWidget {
  const CitiesScreen({super.key, required this.cities});

  final List<City> cities;

  @override
  State<CitiesScreen> createState() => _CitiesScreenState();
}

class _CitiesScreenState extends State<CitiesScreen> {
  String datetime = "";

  @override
  void initState() {
    Timer mytimer = Timer.periodic(Duration(seconds: 1), (timer) {
      DateTime timenow = DateTime.now(); //get current date and time
      datetime = DateFormat("dd-MM-yyyy HH:mm:ss").format(timenow);
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meteorologia'),
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsetsDirectional.only(top: 30, bottom: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Cidades",
                    style: TextStyle(fontSize: 25),
                  ),
                  Text(
                    datetime,
                    style: const TextStyle(
                        fontSize: 20,),
                  )
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.cities.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      color: Colors.blue,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: ListTile(
                        title: Container(
                          margin: const EdgeInsetsDirectional.only(
                              top: 20, bottom: 20, start: 15),
                          child: Text(
                            widget.cities[index].name,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 25),
                          ),
                        ),
                        trailing: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${widget.cities[index].weather.temp.round().toString()}ºC',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 21),
                            ),
                            Text(
                              '${widget.cities[index].weather.status}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 18),
                            ),
                          ],
                        ),
                        onTap: () {
                          // Navigator.push(
                          //
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => const DetailScreen(),
                          //     // Pass the arguments as part of the RouteSettings. The
                          //     // DetailScreen reads the arguments from these settings.
                          //     settings: RouteSettings(
                          //       arguments: widget.cities[index],
                          //     ),
                          //   ),
                          // );

                          widget.cities[index].get_weather();
                          var weather = widget.cities[index].weather;
                          var model;
                          if (weather.status == "Céu Limpo") {
                            model = "3d_assets/sun.glb";
                          } else if (weather.status == "Chuva") {
                            model = "3d_assets/rain.glb";
                          } else {
                            model = "3d_assets/cloud.glb";
                          }

                          showDialog<String>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),

                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    margin: const EdgeInsetsDirectional.only(bottom: 10),
                                    child: Text(
                                      widget.cities[index].name,
                                      style: TextStyle(fontSize: 35),
                                    ),
                                  ),
                                  Text(
                                    '${weather.temp.round().toString()}º',
                                    style: TextStyle(color: Colors.lightBlue, fontSize: 35),
                                  ),
                                  Container(
                                    height: 250,
                                    margin: EdgeInsetsDirectional.symmetric(horizontal: 15),
                                    child: ModelViewer(
                                      src: model,
                                      autoRotate: true,
                                      disableZoom: true,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.only(bottom: 2, top: 5),
                                    child: Text(
                                      weather.status,
                                      style: TextStyle(color: Colors.grey, fontSize: 25),
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsetsDirectional.only(top: 20),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.wb_sunny_rounded),
                                        Text(
                                          weather.sunrise,
                                          style: TextStyle(color: Colors.lightBlue, fontSize: 28),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.nightlight_round),
                                      Text(
                                        weather.sunset,
                                        style: TextStyle(color: Colors.lightBlue, fontSize: 28),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              // actions: <Widget>[
                              //   TextButton(
                              //     onPressed: () => Navigator.pop(context, 'OK'),
                              //     child: const Text('OK'),
                              //   ),
                              // ],
                            ),
                          );

                        },
                      ),
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final city = ModalRoute.of(context)!.settings.arguments as City;

    city.get_weather();
    var weather = city.weather;
    var model;
    if (weather.status == "Céu Limpo") {
      model = "3d_assets/sun.glb";
    } else if (weather.status == "Chuva") {
      model = "3d_assets/rain.glb";
    } else {
      model = "3d_assets/cloud.glb";
    }

    return Scaffold(
        appBar: AppBar(
          title: Text("Cidades"),
        ),
        body: Center(
            child: Container(
                child: Column(
          children: [
            Container(
              margin: const EdgeInsetsDirectional.only(top: 40),
              child: Text(
                city.name,
                style: TextStyle(fontSize: 35),
              ),
            ),
            Text(
              '${weather.temp.round().toString()}º',
              style: TextStyle(color: Colors.lightBlue, fontSize: 35),
            ),
            Container(
              height: 250,
              margin: EdgeInsetsDirectional.symmetric(horizontal: 15),
              child: ModelViewer(
                src: model,
                autoRotate: true,
                disableZoom: true,
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.only(bottom: 2, top: 5),
              child: Text(
                weather.status,
                style: TextStyle(color: Colors.grey, fontSize: 25),
              ),
            ),
            Container(
              margin: const EdgeInsetsDirectional.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wb_sunny_rounded),
                  Text(
                    weather.sunrise,
                    style: TextStyle(color: Colors.lightBlue, fontSize: 28),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.nightlight_round),
                Text(
                  weather.sunset,
                  style: TextStyle(color: Colors.lightBlue, fontSize: 28),
                ),
              ],
            ),
          ],
        ))));
  }
}
