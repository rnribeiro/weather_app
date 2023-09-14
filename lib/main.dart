// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:model_viewer_plus/model_viewer_plus.dart';

class Weather {
  final double temp;
  final String status;
  final String sunrise;
  final String sunset;

  const Weather({
    required this.temp,
    required this.status,
    required this.sunrise,
    required this.sunset,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    var t = json['list'][0]['main']['temp'] - 273.15;
    String s;
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
          s = json['list'][0]['weather'][0]['main'];
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

  City(this.name, this.id);

  Future<Weather> get_weather() async {
    final response = await http.get(Uri.parse(
        'http://api.openweathermap.org/data/2.5/forecast?id=$id&APPID=97f9f992f1fa553711ac1cc06e46524f'));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return Weather.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw jsonDecode(response.body)['message'];
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

class CitiesScreen extends StatelessWidget {
  const CitiesScreen({super.key, required this.cities});

  final List<City> cities;

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
                  StreamBuilder(
                    stream: Stream.periodic(const Duration(seconds: 1)),
                    builder: (context, snapshot) {
                      return Text(
                          DateFormat('dd-MM-yyyy HH:mm:ss')
                              .format(DateTime.now()),
                          style: const TextStyle(
                            fontSize: 20,
                          ));
                    },
                  )
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: cities.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    color: Colors.blue,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: FutureBuilder<Weather>(
                      future: cities[index].get_weather(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          // Display a loading indicator while data is being fetched.
                          return ListTile(
                            title: Text(
                              cities[index].name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                              ),
                            ),
                            trailing: const CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 4),
                          );
                        } else if (snapshot.hasError) {
                          // Handle the error case.
                          return ListTile(
                            title: Text(
                              cities[index].name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                              ),
                            ),
                            trailing: Text(
                              snapshot.error.toString().split(".")[0],
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          );
                        } else {
                          // Data has been successfully fetched.
                          final weather = snapshot.data!;
                          return ListTile(
                            title: Container(
                              margin: const EdgeInsetsDirectional.only(
                                top: 20,
                                bottom: 20,
                                start: 15,
                              ),
                              child: Text(
                                cities[index].name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 25,
                                ),
                              ),
                            ),
                            trailing: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${weather.temp.round().toString()}ºC',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 21,
                                  ),
                                ),
                                Text(
                                  weather.status,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              String model;
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
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18)),

                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        margin:
                                            const EdgeInsetsDirectional.only(
                                                bottom: 10),
                                        child: Text(
                                          cities[index].name,
                                          style: const TextStyle(fontSize: 35),
                                        ),
                                      ),
                                      Text(
                                        '${weather.temp.round().toString()}º',
                                        style: const TextStyle(
                                            color: Colors.lightBlue,
                                            fontSize: 35),
                                      ),
                                      Container(
                                        height: 250,
                                        margin: const EdgeInsetsDirectional
                                            .symmetric(horizontal: 15),
                                        child: ModelViewer(
                                          src: model,
                                          autoRotate: true,
                                          disableZoom: true,
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsetsDirectional.only(
                                                bottom: 2, top: 5),
                                        child: Text(
                                          weather.status,
                                          style: const TextStyle(
                                              color: Colors.grey, fontSize: 25),
                                        ),
                                      ),
                                      Container(
                                        margin:
                                            const EdgeInsetsDirectional.only(
                                                top: 20),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.wb_sunny_rounded),
                                            Text(
                                              weather.sunrise,
                                              style: const TextStyle(
                                                  color: Colors.lightBlue,
                                                  fontSize: 28),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.nightlight_round),
                                          Text(
                                            weather.sunset,
                                            style: const TextStyle(
                                                color: Colors.lightBlue,
                                                fontSize: 28),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  // actions: <Widget>[
                                  //   TextButton(
                                  //
                                  //     onPressed: () => Navigator.pop(context, 'OK'),
                                  //     child:
                                  //     const Text(
                                  //       'Fechar',
                                  //       style: TextStyle(
                                  //           color: Colors.grey,
                                  //           fontSize: 18
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ],
                                ),
                              );
                            },
                          );
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
