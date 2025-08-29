import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: SelectionChecker());
  }
}

class SelectionChecker extends StatefulWidget {
  @override
  _SelectionCheckerState createState() => _SelectionCheckerState();
}

class _SelectionCheckerState extends State<SelectionChecker> {
  final TextEditingController _emailController = TextEditingController();
  Map<String, dynamic>? userData;
  List<List<String>> csvData = [];

  @override
  void initState() {
    super.initState();
    _loadCSV();
  }

  Future<void> _loadCSV() async {
    final rawData = await rootBundle.loadString('assets/data.csv');
    final List<List<String>> listData = const CsvToListConverter(
      shouldParseNumbers: false,
      fieldDelimiter: ',',
      eol: '\n',
    ).convert(rawData);
    setState(() {
      csvData = listData;
    });
  }

  void _findUser() {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;
    final emailHash = sha256
        .convert(utf8.encode(email.toLowerCase()))
        .toString();

    final headers = csvData.isNotEmpty ? csvData.first : <String>[];
    final userRow = csvData.firstWhere(
      (row) =>
          row.length > 1 && row[1].toString().trim().toLowerCase() == emailHash,
      orElse: () => [],
    );

    if (userRow.isNotEmpty) {
      setState(() {
        userData = Map.fromIterables(headers, userRow);
      });
    } else {
      setState(() {
        userData = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              spacing: 20,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Selection checker',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Image.asset('assets/logo_color.png', height: 300),
                Text('Check which activities and workshops that you selected.'),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Enter your email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    onSubmitted: (_) => _findUser(),
                  ),
                ),
                ElevatedButton(
                  onPressed: _findUser,
                  child: const Text('Check'),
                ),
                if (userData != null)
                  Column(
                    children: [
                      Text(
                        'Sunday 31/8',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Check the the e-mails you received about the social activity and dinner for the locations.',
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Social Activity:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(_cleanString(userData!['Social activity'])),
                      SizedBox(height: 10),
                      Text(
                        'Dinner Restaurant:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(_cleanString(userData!['DWS Restaurant'])),
                      SizedBox(height: 20),
                      Text(
                        'Monday 1/9',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('This is the conference day!'),
                      InkWell(
                        onTap: () {
                          launchUrl(
                            Uri.parse(
                              'https://www.flutterfriends.dev/schedule',
                            ),
                          );
                        },
                        child: Text(
                          'View the full schedule here.',
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      Text(
                        'Don\'t miss the amazing party at Slaktkyrkan afterwards!',
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Tuesday 2/9',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Check the schedule or the e-mail you received about the workshops for the locations.',
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Workshop 1:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _cleanString(
                          userData!['Workshop slot 1 (10:00-11:30, 2/9)'],
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Workshop 2:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _cleanString(
                          userData!['Workshop slot 2 (13:00-14:30, 2/9)'],
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Workshop 3:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _cleanString(
                          userData!['Workshop slot 3 (15:00-16:30, 2/9)'],
                        ),
                      ),
                    ],
                  )
                else if (_emailController.text.isNotEmpty) ...[
                  const Text(
                    'No data found for the entered email.\n'
                    'Remember that you might have signed up with another email.',
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _cleanString(String? input) {
  if (input == null || input.trim().isEmpty) return 'N/A';
  return input
      .replaceAll('(FULL, don\'t select) ', '')
      .replaceAll('[Workshop] ', '');
}
