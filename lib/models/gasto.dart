import 'dart:core';
import 'package:date_format/date_format.dart';

class Gasto {
  int id;
  double gasto;
  DateTime data;
  String nome;
  // var now = formatDate(
  //     DateTime.now(), [dd, '/', mm, '/', yyyy, '-', HH, ':', nn, ':', ss]);

  Gasto(
      {this.id = 0,
      required this.gasto,
      required this.data,
      required this.nome});
  Gasto.fromMap(Map<String, dynamic> valor)
      : this(
            id: valor['id'],
            gasto: double.parse(valor['gasto']),
            data: stringToDateTime(valor['data']),
            nome: valor['nome']);

  Future<String> dataFormatada() async {
    print(this.data);
    // print(formatDate(
    //     this.data, [dd, '/', mm, '/', yyyy, '-', hh, ':', nn, ':', ss]));
    return formatDate(
        this.data, [dd, '/', mm, '/', yyyy, '-', HH, ':', nn, ':', ss]);
  }

  Future<Map<String, Object>> toMap() async {
    print(dataFormatada());
    return {
      // 'id': this.id,
      'gasto': this.gasto.toString(),
      'data': await dataFormatada(),
      'nome': this.nome
    };
  }
}

DateTime stringToDateTime(String formatada) {
  formatada.split("-");
  var dat = formatada.split("-")[0];
  var hor = formatada.split("-")[1];
  // print(dat);
  // print(hor);
  var datList = dat.split("/");
  var horList = hor.split(":");

  // print(datList);
  // print(horList);

  return DateTime(
      int.parse(datList[2]),
      int.parse(datList[1]),
      int.parse(datList[0]),
      int.parse(horList[0]),
      int.parse(horList[1]),
      int.parse(horList[2]));
}
