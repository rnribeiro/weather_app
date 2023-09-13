import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:model_viewer_plus/model_viewer_plus.dart';

class Weather {
  final double temp;
  final String status;

  const Weather({
    required this.temp,
    required this.status,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    var t = json['list'][0]['main']['temp'] - 273.15;
    var s;
    switch (json['list'][0]['weather'][0]['main']) {
      case "Clear":
        {
          s = "Sol";
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
        City("Leira", 2267094),
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
      //mytimer.cancel() //to terminate this timer
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
                    style: TextStyle(color: Colors.black, fontSize: 25),
                  ),
                  Text(
                    datetime,
                    style: const TextStyle(color: Colors.black, fontSize: 20),
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
                        // When a user taps the ListTile, navigate to the DetailScreen.
                        // Notice that you're not only creating a DetailScreen, you're
                        // also passing the current todo through to it.
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DetailScreen(),
                              // Pass the arguments as part of the RouteSettings. The
                              // DetailScreen reads the arguments from these settings.
                              settings: RouteSettings(
                                arguments: widget.cities[index],
                              ),
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
    if (weather.status == "Sol") {
      model = "3d_assets/sun.glb";
    } else if (weather.status == "Chuva") {
      model = "3d_assets/rain.glb";
    } else {
      model = "3d_assets/cloud.glb";
    }

    return Scaffold(
        appBar: AppBar(
          title: Text("Back"),
        ),
        body: Center(
            child: Container(
                child: Column(
          children: [
            Text('${weather.temp.round().toString()}ºC'),
            Expanded(
              child: ModelViewer(
                src: model,
                autoRotate: true,
                disableZoom: true,
              ),
            )
          ],
        ))));
  }
}
