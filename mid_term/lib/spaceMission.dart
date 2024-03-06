import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'Model/launch_model.dart';

class SpaceMission extends StatefulWidget {
  const SpaceMission({Key? key}) : super(key: key);

  @override
  _SpaceMissionState createState() => _SpaceMissionState();
}

class _SpaceMissionState extends State<SpaceMission> {
  late Future<List<Launch>> futureLaunchList;
  bool isDescExpanded = false; 

  Future<List<Launch>> fetchLaunch() async {
    Uri urlObject = Uri.parse("https://api.spacexdata.com/v3/missions");
    final response = await http.get(urlObject);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Launch.fromJson(json)).toList();
    } else {
      throw Exception("Failed to get data");
    }
  }

  @override
  void initState() {
    super.initState();
    futureLaunchList = fetchLaunch();
  }

  void _showDescription() {
    setState(() {
      isDescExpanded = !isDescExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Space Mission'),
        backgroundColor: Color.fromARGB(255, 39, 148, 43),
      ),
      body: SafeArea(
        child: FutureBuilder<List<Launch>>(
          future: futureLaunchList,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text("Error fetching data: ${snapshot.error}");
            } else if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final data = snapshot.data![index];
                  return Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Card(
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data.missionName ?? '',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              data.description ?? '',
                              maxLines: isDescExpanded ? null : 1,
                              overflow: isDescExpanded ? null : TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 17,
                              )
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                    ),
                                  ),
                                  backgroundColor: MaterialStatePropertyAll<Color>(Color(0xFFdcdcdc)),
                                ),
                                onPressed: () {
                                  _showDescription();
                                },
                                child: isDescExpanded
                                  ? Row(mainAxisSize: MainAxisSize.min, children: [
                                    Text(
                                      "Less",
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_upward,
                                      color: Colors.blue,
                                    )
                                  ])
                                  : Row(mainAxisSize: MainAxisSize.min, children: [
                                    Text(
                                      "More",
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      )
                                    ),
                                    Icon(
                                      Icons.arrow_downward,
                                      color: Colors.blue,
                                    )
                                  ]),
                              ),
                            ),
                            Center(
                              child: Wrap(
                                children: data.payloadIds!.map((e) => Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                    child: Chip(
                                      label: Text(e),
                                      backgroundColor: Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0),
                                    ),
                                  ),
                                ).toList(),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );           
             }
          },
        ),
      ),
    );
  }
}



  
