import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:gastosv2/models/gasto.dart';
import 'package:gastosv2/services/bancoProvider.dart';
import 'package:provider/provider.dart';

class EditScreen extends StatefulWidget {
  EditScreen({Key? key, required this.gasto}) : super(key: key);
  Gasto gasto;

  @override
  _EditScreenState createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  TextEditingController valor = TextEditingController();
  TextEditingController nome = TextEditingController();

  String dataFormatada(DateTime data) {
    return formatDate(data, [dd, '/', mm, '/', yyyy]);
  }

  @override
  void initState() {
    setState(() {
      valor.text = widget.gasto.gasto.toString();
      nome.text = widget.gasto.nome;
    });
    print(widget.gasto.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    var banco = Provider.of<Banco>(context);

    DateTime data = widget.gasto.data;
    TimeOfDay hora = TimeOfDay(hour: data.hour, minute: data.minute);
    return Scaffold(
      appBar: AppBar(
        title: Text("Editando ${widget.gasto.nome}"),
      ),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(hora.hour.toString() + ":" + hora.minute.toString()),
                    TextButton(
                      child: Text(" Mudar Hora"),
                      onPressed: () async {
                        var novahora = await showTimePicker(
                            context: context, initialTime: hora);
                        if (novahora != null) {
                          setState(() {
                            hora = novahora;
                          });
                        }
                      },
                    ),
                  ],
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: valor,
                  keyboardType: TextInputType.numberWithOptions(),
                  validator: (value) {
                    if (value == null ||
                        value.trim() == "" ||
                        value.contains(RegExp(r'[A-Z][a-z]'))) {
                      return "Digite um valor válido";
                    }
                  },
                  decoration: InputDecoration(
                      prefixText: "R\$",
                      labelText: "Valor",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(),
                      )),
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: nome,
                  validator: (value) {
                    if (value == null || value.trim() == "") {
                      return "Digite um valor válido";
                    }
                  },
                  onFieldSubmitted: (value) {
                    if (formKey.currentState!.validate()) {
                      var gastoNovo = Gasto(
                          id: widget.gasto.id,
                          gasto: double.parse(valor.text.replaceAll(',', '.')),
                          nome: nome.text,
                          data: DateTime(data.year, data.month, data.day,
                              hora.hour, hora.minute));
                      banco.update(gastoNovo);
                      Navigator.pop(context);
                    }
                  },
                  decoration: InputDecoration(
                      labelText: "Nome",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(),
                      )),
                ),
                SizedBox(height: 15),
                TextButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        var gastoNovo = Gasto(
                            id: widget.gasto.id,
                            gasto:
                                double.parse(valor.text.replaceAll(',', '.')),
                            nome: nome.text,
                            data: DateTime(data.year, data.month, data.day,
                                hora.hour, hora.minute));
                        banco.update(gastoNovo);
                        Navigator.pop(context);
                      }
                    },
                    child: Text("Atualizar"))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
