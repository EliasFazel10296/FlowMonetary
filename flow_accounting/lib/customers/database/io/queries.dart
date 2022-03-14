/*
 * Copyright © 2022 By Geeks Empire.
 *
 * Created by Elias Fazel
 * Last modified 3/14/22, 6:13 AM
 *
 * Licensed Under MIT License.
 * https://opensource.org/licenses/MIT
 */

import 'package:flow_accounting/customers/database/io/inputs.dart';
import 'package:flow_accounting/customers/database/structures/table_structure.dart';
import 'package:flow_accounting/resources/StringsResources.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class CustomersDatabaseQueries {

  Future<List<CustomersData>> getAllCustomers(String tableName,
      String usernameId) async {

    final database = openDatabase(
      join(await getDatabasesPath(), CustomersDatabaseInputs.customersDatabase),
    );

    final databaseInstance = await database;

    var tableNameQuery = (usernameId == StringsResources.unknownText) ? CustomersDatabaseInputs.databaseTableName : "${usernameId}_${CustomersDatabaseInputs.specificDatabaseTableName}";

    final List<Map<String, dynamic>> maps = await databaseInstance.query(tableNameQuery);

    return List.generate(maps.length, (i) {
      return CustomersData(
        id: maps[i]['id'],

        customerName: maps[i]['customerName'],
        customerDescription: maps[i]['customerDescription'],

        customerCountry: maps[i]['customerCountry'],
        customerCity: maps[i]['customerCity'],
        customerStreetAddress: maps[i]['customerStreetAddress'],

        customerPhoneNumber: maps[i]['customerPhoneNumber'],
        customerEmailAddress: maps[i]['customerEmailAddress'],

        customerAge: maps[i]['customerAge'],
        customerBirthday: maps[i]['customerBirthday'],

        customerJob: maps[i]['customerJob'],

        customerMaritalStatus: maps[i]['customerMaritalStatus'],

        customerImagePath: maps[i]['customerImagePath'],

        colorTag: int.parse(maps[i]['colorTag'].toString()),
      );
    });

  }

  Future<int> queryDeleteCustomer(int id,
      String tableName, String usernameId) async {

    final database = openDatabase(
      join(await getDatabasesPath(), CustomersDatabaseInputs.customersDatabase),
    );

    final databaseInstance = await database;

    var tableNameQuery = (usernameId == StringsResources.unknownText) ? CustomersDatabaseInputs.databaseTableName : "${usernameId}_${CustomersDatabaseInputs.specificDatabaseTableName}";

    var queryResult = await databaseInstance.delete(
      tableNameQuery,
      where: 'id = ?',
      whereArgs: [id],
    );

    return queryResult;
  }

}