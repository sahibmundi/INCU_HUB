import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'INCUBATION HUB',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SensorDataDisplay(),
    );
  }
}

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  _initDb() async {
    String path = join(await getDatabasesPath(), 'sensor_data.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE SensorData(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        time TEXT,
        water_level REAL,
        temperature REAL
      )
    ''');
  }

  Future<void> insertData(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert('SensorData', data);
  }

  Future<List<Map<String, dynamic>>> getSensorData() async {
    final db = await database;
    return await db.query('SensorData');
  }
}

class SensorDataDisplay extends StatefulWidget {
  @override
  _SensorDataDisplayState createState() => _SensorDataDisplayState();
}

class _SensorDataDisplayState extends State<SensorDataDisplay> {
  String ultrasonicDistance = 'Loading...';
  String temperatureValue = 'Loading...';
  Timer? timer;

  List<UltrasonicData> ultrasonicData = [];
  List<TemperatureData> temperatureData = [];

  final DateTime startDate = DateTime(2024, 12, 24);

  final DBHelper dbHelper = DBHelper();

 @override
void initState() {
  super.initState();
  loadHistoricalData();
  fetchSensorData();
  timer = Timer.periodic(Duration(seconds: 1), (Timer t) => fetchSensorData());
}

// In the SensorDataDisplay class

Future<void> loadHistoricalData() async {
  final data = await dbHelper.getSensorData();
  setState(() {
    ultrasonicData = data.map((row) {
      return UltrasonicData(
        DateTime.parse(row['time']),
        row['water_level'],
      );
    }).toList();

    temperatureData = data.map((row) {
      return TemperatureData(
        DateTime.parse(row['time']),
        row['temperature'],
      );
    }).toList();
  });
}

Future<void> fetchSensorData() async {
  final apiUrl =
      'https://api.thingspeak.com/channels/2793525/feeds.json?api_key=C61NVOBSM8P1KRU3&results=1';

  try {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        ultrasonicDistance = data['feeds'][0]['field2'] ?? 'N/A';
        ultrasonicDistance = ultrasonicDistance + ' %'; // Add % symbol for water level

        temperatureValue = data['feeds'][0]['field1'] ?? '0.0';
        

        ultrasonicData.add(UltrasonicData(
          DateTime.now(),
          double.tryParse(ultrasonicDistance.replaceAll('%', '')) ?? 0.0,
        ));

        temperatureData.add(TemperatureData(
          DateTime.now(),
          double.tryParse(temperatureValue) ?? 0.0,
        ));

        // Save to database
        dbHelper.insertData({
          'time': DateTime.now().toIso8601String(),
          'water_level': double.tryParse(ultrasonicDistance.replaceAll('%', '')) ?? 0.0,
          'temperature': double.tryParse(temperatureValue) ?? 0.0,
        });
      });
    } else {
      setState(() {
        ultrasonicDistance = 'Error fetching data';
        temperatureValue = 'Error fetching data';
      });
    }
  } catch (e) {
    setState(() {
      ultrasonicDistance = 'Error fetching data';
      temperatureValue = 'Error fetching data';
    });
  }
}


  int getDaysCount() {
    final currentDate = DateTime.now();
    final difference = currentDate.difference(startDate).inDays;
    return difference + 1; 
  }

  String formatTimestamp(String timestamp) {
    try {
      DateTime dateTime = DateTime.parse(timestamp);
      return DateFormat('dd-MM HH:mm').format(dateTime);
    } catch (e) {
      return timestamp; 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('INCUBATION HUB', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(221, 5, 5, 5),
        actions: [
          IconButton(
            icon: Icon(Icons.check_circle, color: const Color.fromARGB(255, 19, 204, 218)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SavedDataScreen(dbHelper)),
              );
            },
          ),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 56, 55, 55),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCircularSensorContainer(
                    title: 'TEMPERATURE',
                    value: temperatureValue + '°C',
                    icon: Icons.thermostat,
                  ),
                  _buildCircularSensorContainer(
                    title: 'WATER LEVEL',
                    value: ultrasonicDistance,
                    icon: Icons.water_drop,
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.all(5.0),
              padding: EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 1.6,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'DAY: ${getDaysCount()}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    getDaysCount() < 21
                        ? 'HATCHING UNDER PROGRESS'
                        : 'HATCHING COMPLETED',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: getDaysCount() < 21 ? Colors.red : Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 25),
            _buildChartSection(
              title: 'WATER LEVEL',
              dataSource: ultrasonicData,
              color: const Color.fromARGB(255, 175, 27, 16),
            ),
            _buildChartSection(
              title: 'TEMPERATURE',
              dataSource: temperatureData,
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularSensorContainer({
    required String title,
    required String value,
    required IconData icon,
  }) {
    Color statusColor = value == 'ON' ? Colors.green : (value == 'OFF' ? Colors.red : Colors.white);

    return Container(
      margin: EdgeInsets.all(8.0),
      padding: EdgeInsets.all(16.0),
      height: 170,
      width: 150,
      decoration: BoxDecoration(
        color: Color(0xFF2E2E2E),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 0.6,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 8.0,
            offset: Offset(4, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.blueAccent, size: 40),
          SizedBox(height: 8.0),
          Text(
            title,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection({
    required String title,
    required List dataSource,
    required Color color,
  }) {
    return Container(
      height: 260,
      width:370,
      margin: EdgeInsets.symmetric(vertical: 20.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
          width: 1.6,
        ),
      ),
      child: SfCartesianChart(
        primaryXAxis: DateTimeCategoryAxis(
          labelStyle: TextStyle(color: Colors.white),
        ),
        primaryYAxis: NumericAxis(
          labelStyle: TextStyle(color: Colors.white),
        ),
        title: ChartTitle(
          text: title,
          textStyle: TextStyle(fontSize: 12, color: Colors.white),
        ),
        series: <CartesianSeries>[
          LineSeries<dynamic, DateTime>(
            dataSource: dataSource,
            xValueMapper: (dynamic data, _) => data.time,
            yValueMapper: (dynamic data, _) => data.value,
            color: color,
          ),
        ],
      ),
    );
  }
}

class SavedDataScreen extends StatelessWidget {
  final DBHelper dbHelper;

  SavedDataScreen(this.dbHelper);

  String formatTimestamp(String timestamp) {
    try {
      DateTime dateTime = DateTime.parse(timestamp);
      return DateFormat('dd-MM HH:mm').format(dateTime);
    } catch (e) {
      return timestamp;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SAVED DATA'),
        backgroundColor: const Color.fromARGB(221, 216, 211, 211)
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: dbHelper.getSensorData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading data'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data available'));
          } else {
            List<Map<String, dynamic>> data = snapshot.data!;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  columns: const <DataColumn>[
                    DataColumn(label: Text('Timestamp')),
                    DataColumn(label: Text('Water Level')),
                    DataColumn(label: Text('Temperature')),
                  ],
                  rows: data.map((row) {
                    return DataRow(
                      cells: [
                        DataCell(Text(formatTimestamp(row['time']))),
                        DataCell(Text(row['water_level'].toString())),
                        DataCell(Text(row['temperature'].toString())),
                      ],
                    );
                  }).toList(),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

class UltrasonicData {
  final DateTime time;
  final double value;

  UltrasonicData(this.time, this.value);
}

class TemperatureData {
  final DateTime time;
  final double value;

  TemperatureData(this.time, this.value);
}
