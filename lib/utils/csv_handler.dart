import 'dart:io';
import 'package:csv/csv.dart';

class CSVHandler {
  final String path;

  CSVHandler(this.path);

  List<List<dynamic>> readCSV() {
    final file = File(path);
    if (!file.existsSync()) {
      file.createSync();
      return [];
    }
    final raw = file.readAsStringSync();
    return const CsvToListConverter().convert(raw);
  }

  void writeCSV(List<List<dynamic>> data) {
    final file = File(path);
    final csvData = const ListToCsvConverter().convert(data);
    file.writeAsStringSync(csvData);
  }
}
