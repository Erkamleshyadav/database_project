import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBhelper {
  ///singleton
  DBhelper._();
  static final DBhelper getInstance = DBhelper._();

  static final String TABLE_NOTE = "note";
  static final String COLUMN_NOTE_SNO = "s_no";
  static final String COLUMN_NOTE_TITLE = "title";
  static final String COLUMN_NOTE_DESC = "desc";

  Database? myDB;

  Future<Database> getDB() async {
    myDB ??= await openDB();
    return myDB!;
    // if (myDB != null) {
    //   return myDB!;
    // } else {
    //   myDB = await openDB();
    //   return myDB!;
    // }
  }

  Future<Database> openDB() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String dbpath = join(appDir.path, "note.db");
    return await openDatabase(dbpath, onCreate: (db, version) async {
      await db.execute(
          "create table $TABLE_NOTE ($COLUMN_NOTE_SNO integer primary key autoincrement,$COLUMN_NOTE_TITLE text,$COLUMN_NOTE_DESC text)");
    }, version: 1);
  }

// insertion
  Future<bool> addNote({required String mTitle, required String mDesc}) async {
    var db = await getDB();
    int rowaffected = await db.insert(
        TABLE_NOTE, {COLUMN_NOTE_TITLE: mTitle, COLUMN_NOTE_DESC: mDesc});
    return rowaffected > 0;
  }

  // getAll note
  Future<List<Map<String, dynamic>>> getAllNote() async {
    var db = await getDB();
    List<Map<String, dynamic>> mData = await db.query(TABLE_NOTE);
    return mData;
  }

//update method
  Future<bool> updateNote(
      {required String mtitle, required String mdesc, required int sno}) async {
    var db = await getDB();
    int rowaffected = await db.update(
        TABLE_NOTE,
        {
          COLUMN_NOTE_TITLE: mtitle,
          COLUMN_NOTE_DESC: mdesc,
        },
        where: "$COLUMN_NOTE_SNO=$sno");
    return rowaffected > 0;
  }

//delete mehtod
  Future<bool> deleteNote({required int sno}) async {
    var db = await getDB();
    int rowaffected = await db
        .delete(TABLE_NOTE, where: "$COLUMN_NOTE_SNO=?", whereArgs: ['$sno']);
    return rowaffected > 0;
  }
}
