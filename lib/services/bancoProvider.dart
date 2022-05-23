import 'package:flutter/cupertino.dart';
import 'package:gastosv2/models/gasto.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

class Banco extends ChangeNotifier {
  double total = 0;
  List<Gasto> gastos = [];
  bool loading = false;

  Future<Database> _getBanco() async {
    return openDatabase(join(await getDatabasesPath(), "gastos"), version: 1,
        onCreate: (db, version) {
      db.execute(
          "CREATE TABLE gastos(id INTEGER PRIMARY KEY AUTOINCREMENT, gasto TEXT, data TEXT, nome TEXT)");
    });
  }

  Future adiciona(Gasto gasto) async {
    print(gasto.toMap());
    try {
      Database db = await _getBanco();
      await db.insert("gastos", await gasto.toMap());
      getTudo();
    } catch (e) {
      print(e);
    }
  }

  void changeStatus() {
    loading = !loading;
    // notifyListeners();
  }

  Future<List<Gasto>?> getTudo() async {
    // loading = true;
    changeStatus();
    // notifyListeners();
    try {
      Database db = await _getBanco();
      List<Map<String, dynamic>> maps = await db.query('gastos');
      var listCompleta = List.generate(maps.length, (i) {
        return Gasto.fromMap(maps[i]);
      });
      gastos = listCompleta;
      double soma = 0;
      for (var gast in listCompleta) {
        soma += gast.gasto;

        // print(gast.data);
      }
      total = soma;
      changeStatus();
      // loading = false;
      notifyListeners();

      return listCompleta;
    } catch (e) {
      print(e);
    }
  }

  Future update(Gasto model) async {
    Database db = await _getBanco();
    print(await model.toMap());
    print(model.id);
    try {
      await db.update("gastos", await model.toMap(),
          where: "id=?", whereArgs: [model.id]).then((value) => print(value));
    } catch (e) {
      print(e);
    }
    getTudo();
  }

  Future delete(Gasto model) async {
    Database db = await _getBanco();

    await db.delete('gastos', where: "id=?", whereArgs: [model.id]);
    getTudo();
  }
}
