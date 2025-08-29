import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:csv/csv.dart';

void main() async {
  const csvFilePath = 'assets/data.csv';

  // Read the CSV file
  final input = await File(csvFilePath).readAsString();
  final rows = const CsvToListConverter(
    shouldParseNumbers: false,
    fieldDelimiter: ',',
    eol: '\n',
  ).convert(input);

  // Get the header and find indices of columns to empty
  final headers = rows.first;
  final nameIndex = headers.indexOf('Name');
  final phoneIndex = headers.indexOf('Telephone number');
  final emailIndex = headers.indexOf('E-mail');

  // Empty the values in the specified columns for rows after the header
  final updatedRows = [
    headers, // Keep the header row intact
    ...rows.skip(1).map((row) {
      final updatedRow = List.of(row);
      if (updatedRow.length > nameIndex) updatedRow[nameIndex] = '';
      if (updatedRow.length > phoneIndex) updatedRow[phoneIndex] = '';
      if (updatedRow.length > emailIndex && updatedRow[emailIndex] is String) {
        final email = updatedRow[emailIndex] as String;
        updatedRow[emailIndex] = sha256
            .convert(utf8.encode(email.toLowerCase()))
            .toString();
      }
      return updatedRow;
    }),
  ];

  // Write the updated data back to the file
  final output = const ListToCsvConverter(
    fieldDelimiter: ',',
    eol: '\n',
  ).convert(updatedRows);
  await File(csvFilePath).writeAsString(output);

  print(
    "The content in the 'Name' and 'Telephone number' fields has been emptied "
    "and e-mail anonymized.",
  );
}
