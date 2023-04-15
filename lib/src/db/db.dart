import 'package:flutter/material.dart';
import 'package:flutter_google_map_address/src/model/location_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DB {
  Future<Database> getDb() async {
    WidgetsFlutterBinding.ensureInitialized();
    final database = openDatabase(join(await getDatabasesPath(), 'addresss.db'),
        onCreate: (db, version) {
      db.execute(
          'CREATE TABLE address(title TEXT,name  TEXT, street TEXT,state TEXT,country TEXT, postal_code TEXT, city TEXT,locality Text)');
    }, onUpgrade: (db, oldVersion, newVersion) {}, version: 1);
    return database;
  }

  Future<void> insertAddr(Address address) async {
    //bool res= false;
    getDb().then((db) {
      var ad = {
        "title": address.title,
        "name": address.name,
        "street": address.street,
        "state": address.adminArea,
        "country": address.country,
        "postal_code": address.postalCode,
        "city": address.subAdminArea,
        "Locality": address.locality,
      };
      db.insert('address', ad, conflictAlgorithm: ConflictAlgorithm.replace).then((value)  {
        //print(value);
          //return true;
      }).catchError((err){
      //  print(err);
          //return false;
      });
    }).catchError((err){
      //print(err);
      //return false;

    });

  }

  Future<List<Address>> getAdresses() async {
    List<Address> addresses = [];
    Database db = await getDb();
    List<Map<String, dynamic>> data = await db.query("address");
    for (var e in data) {
     // print(e.values.first.toString());
      Address equip = Address.fromJsonDB(e);
      addresses.add(equip);
    }
    return addresses;
  }
}
