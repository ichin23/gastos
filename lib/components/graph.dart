import 'package:flutter/material.dart';
import 'package:gastosv2/models/gasto.dart';
import 'package:gastosv2/services/bancoProvider.dart';
import 'package:provider/provider.dart';

class GraphGastos extends StatefulWidget {
  GraphGastos({Key? key}) : super(key: key);

  @override
  _GraphGastosState createState() => _GraphGastosState();
}

class _GraphGastosState extends State<GraphGastos> {
  double porcSobreTotal(double gasto, double total) {
    return (100 * gasto) / total;
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var gastosProv = Provider.of<Banco>(context);
    var setimoDia = DateTime.now().subtract(Duration(days: 6));
    List<Gasto> gastoGraph = gastosProv.gastos
        .where((element) => element.data.isAfter(setimoDia))
        .toList();

    gastoGraph.sort((a, b) => a.data.compareTo(b.data));

    Map<String, dynamic> gastosDiarios = {};
    gastoGraph.forEach((e) {
      var gastodia = gastosDiarios[dia(e.data)];
      if (gastodia != null) {
        gastosDiarios[dia(e.data)] = gastodia + e.gasto;
      } else {
        gastosDiarios[dia(e.data)] = e.gasto;
      }
    });

    double total = 0;

    gastosDiarios.forEach((key, value) {
      total += value;
    });

    return Container(
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Color(0xff00A9B3),
            borderRadius: BorderRadius.all(Radius.circular(20))),
        height: 300,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ...gastosDiarios
                  .map((key, e) => MapEntry(
                        key,
                        GestureDetector(
                          onTap: () {
                            print(gastosDiarios);
                            print(porcSobreTotal(e.gasto, total));
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text("R\$${e.toStringAsFixed(2)}"),
                              Container(
                                  width: size.width / 8 - 20,
                                  height: ((size.height / 3.5) *
                                          porcSobreTotal(e, total)) /
                                      100,
                                  color: Color(0xffFF7518)),
                              Text(diaDaSemana(dataSimples(key).weekday))
                            ],
                          ),
                        ),
                      ))
                  .values
                  .toList()
            ]));
  }
}

DateTime dataSimples(String data) {
  var split = data.split("/");
  return DateTime(
      int.parse(split[2]), int.parse(split[1]), int.parse(split[0]));
}

String dia(DateTime dia) {
  return "${dia.day}/${dia.month}/${dia.year}";
}

String diaDaSemana(int day) {
  switch (day) {
    case 1:
      {
        return "S";
      }
    case 2:
      {
        return "T";
      }
    case 3:
      {
        return "Q";
      }
    case 4:
      {
        return "Q";
      }
    case 5:
      {
        return "S";
      }
    case 6:
      {
        return "S";
      }
    case 7:
      {
        return "D";
      }

    default:
      return "D";
  }
}
