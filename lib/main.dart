import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:gastosv2/services/bancoProvider.dart';
import 'package:provider/provider.dart';

import 'components/graph.dart';
import 'models/gasto.dart';
import 'screens/editScreen.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => Banco(),
      child: MaterialApp(
        title: 'Gastos',
        theme: ThemeData(
          primaryColor: Color(0xffFF7518),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String dataFormatada(DateTime data) {
    return formatDate(data, [dd, '/', mm, '/', yyyy]);
  }

  late ScrollController _controller;

  late Future<List<Gasto>?> futureGetTudo;

  Future futureFun(BuildContext context) async {
    try {
      futureGetTudo = Provider.of<Banco>(context, listen: false).getTudo();
    } catch (e) {
      print(e);
    }
  }

  bool fim = false;

  _scrollListener() {
    if (_controller.offset >= _controller.position.maxScrollExtent &&
        !_controller.position.outOfRange) {
      setState(() {
        fim = true;
      });
    } else {
      setState(() {
        fim = false;
      });
    }
  }

  bool maiorQueTela = false;
  _positionListener() {
    if (_controller.position.pixels > MediaQuery.of(context).size.height) {
      maiorQueTela = true;
    } else {
      maiorQueTela = false;
    }
  }

  @override
  void initState() {
    _controller = ScrollController();
    _controller.addListener(_scrollListener);
    _controller.addListener(_positionListener);
    futureFun(context);
    super.initState();
  }

  Future showModalTile(BuildContext context, Banco provider, Gasto gasto) {
    return showModalBottomSheet(
        context: context,
        builder: (context) => Container(
            height: MediaQuery.of(context).size.height / 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.edit, size: 25, color: Colors.blue),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => EditScreen(
                                  gasto: gasto,
                                )));
                      },
                      child: Text(
                        "Editar",
                        style: TextStyle(fontSize: 35, color: Colors.blue),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.delete, size: 25, color: Colors.red),
                    TextButton(
                      onPressed: () async {
                        await provider.delete(gasto);
                        Navigator.pop(context);
                        futureFun(context);
                      },
                      child: Text(
                        "Excluir",
                        style: TextStyle(fontSize: 35, color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
            )));
  }

  @override
  Widget build(BuildContext context) {
    var banco = Provider.of<Banco>(context);
    var gastos = banco.gastos;
    gastos.sort((a, b) => b.data.compareTo(a.data));
    return Scaffold(
      backgroundColor: Color(0xfff6f6f6),
      appBar: AppBar(
        title: Text("Você gastou: R\$${banco.total.toStringAsFixed(2)}"),
      ),
      body: SafeArea(
        child: Center(
          child: banco.loading
              ? CircularProgressIndicator()
              : banco.gastos.length > 0
                  ? NotificationListener<ScrollNotification>(
                      onNotification: (scrollNot) {
                        if (scrollNot.metrics.pixels >
                            MediaQuery.of(context).size.width) {
                          maiorQueTela = true;
                        }
                        return true;
                      },
                      child:
                          CustomScrollView(controller: _controller, slivers: [
                        SliverList(
                            delegate: SliverChildListDelegate([
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            // children: [Text("Gráfico")],
                          ),
                          GraphGastos()
                        ])),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                              (context, i) => ListTile(
                                    onTap: () {
                                      print(gastos[i].id);
                                    },
                                    leading: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(gastos[i].data.day.toString() +
                                            "/" +
                                            gastos[i].data.month.toString() +
                                            "/" +
                                            gastos[i].data.year.toString()),
                                        Text(gastos[i].data.hour.toString() +
                                            ":" +
                                            gastos[i].data.minute.toString())
                                      ],
                                    ),
                                    title: Text(gastos[i].nome),
                                    subtitle: Text(
                                        gastos[i].gasto.toStringAsFixed(2)),
                                    trailing: IconButton(
                                        onPressed: () {
                                          showModalTile(
                                              context, banco, gastos[i]);
                                        },
                                        icon: Icon(Icons.more_vert)),
                                  ),
                              childCount: gastos.length),
                        )
                      ]),
                    )
                  : Text("Nada Encontrado"),
        ),
      ),
      floatingActionButton: fim && !maiorQueTela
          ? null
          : Builder(
              builder: (context) => FloatingActionButton(
                onPressed: () {
                  // print(_contr>MediaQuery.of(context).size.height);
                  Scaffold.of(context).showBottomSheet((context) {
                    final formKey = GlobalKey<FormState>();

                    DateTime data = DateTime.now();
                    TimeOfDay hora = TimeOfDay.now();
                    TextEditingController valor = TextEditingController();
                    TextEditingController nome = TextEditingController();
                    return StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        return Form(
                          key: formKey,
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.6,
                            padding: EdgeInsets.all(20),
                            margin: EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(dataFormatada(data)),
                                    TextButton(
                                        child: Text("Mudar Data"),
                                        onPressed: () async {
                                          var novadata = await showDatePicker(
                                              context: context,
                                              initialDate: data,
                                              firstDate: DateTime(2000),
                                              lastDate: DateTime.now());
                                          if (novadata != null) {
                                            setState(() {
                                              data = novadata;
                                            });
                                          }

                                          print(data.toString());
                                        }),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(hora.hour.toString() +
                                        ":" +
                                        hora.minute.toString()),
                                    TextButton(
                                      child: Text(" Mudar Hora"),
                                      onPressed: () async {
                                        var novahora = await showTimePicker(
                                            context: context,
                                            initialTime: hora);
                                        if (novahora != null) {
                                          setState(() {
                                            hora = novahora;
                                          });
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                TextFormField(
                                  controller: valor,
                                  keyboardType:
                                      TextInputType.numberWithOptions(),
                                  validator: (value) {
                                    if (value == null ||
                                        value.trim() == "" ||
                                        value.contains(RegExp(r'[A-Z][a-z]'))) {
                                      return "Digite um valor válido";
                                    }
                                  },
                                  onChanged: (value) {
                                    print(
                                        value.contains(RegExp(r'[A-Z][a-z]')));
                                    // print(double.parse(value.replaceAll(',', '.'))+double.parse(value.replaceAll(',', '.')));
                                  },
                                  decoration: InputDecoration(
                                      prefixText: "R\$",
                                      labelText: "Valor",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: BorderSide(),
                                      )),
                                ),
                                SizedBox(height: 20),
                                TextFormField(
                                  validator: (value) {
                                    if (value == null || value.trim() == "") {
                                      return "Digite um valor válido";
                                    }
                                  },
                                  controller: nome,
                                  onFieldSubmitted: (value) {
                                    if (formKey.currentState!.validate()) {
                                      print(DateTime(data.year, data.month,
                                          data.day, hora.hour, hora.minute));
                                      var gasto = Gasto(
                                          gasto: double.parse(
                                              valor.text.replaceAll(',', '.')),
                                          nome: nome.text,
                                          data: DateTime(
                                              data.year,
                                              data.month,
                                              data.day,
                                              hora.hour,
                                              hora.minute));
                                      banco.adiciona(gasto);
                                      Navigator.pop(context);
                                      futureFun(context);
                                    }
                                  },
                                  decoration: InputDecoration(
                                      labelText: "Nome",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: BorderSide(),
                                      )),
                                ),
                                TextButton(
                                  child: Text("Salvar"),
                                  onPressed: () {
                                    if (formKey.currentState!.validate()) {
                                      print(DateTime(data.year, data.month,
                                          data.day, hora.hour, hora.minute));

                                      var gasto = Gasto(
                                          gasto: double.parse(
                                              valor.text.replaceAll(',', '.')),
                                          nome: nome.text,
                                          data: DateTime(
                                              data.year,
                                              data.month,
                                              data.day,
                                              hora.hour,
                                              hora.minute));
                                      banco.adiciona(gasto);
                                      Navigator.pop(context);
                                      futureFun(context);
                                    }
                                  },
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  });
                },
                child: Icon(Icons.add),
                backgroundColor: Color(0xffFF4747),
              ),
            ),
    );
  }
}
