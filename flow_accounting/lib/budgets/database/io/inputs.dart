/*
 * Copyright © 2022 By Geeks Empire.
 *
 * Created by Elias Fazel
 * Last modified 3/22/22, 11:04 AM
 *
 * Licensed Under MIT License.
 * https://opensource.org/licenses/MIT
 */

import 'dart:core';

import 'package:flow_accounting/budgets/database/structures/tables_structure.dart';
import 'package:flow_accounting/profile/database/io/queries.dart';
import 'package:flow_accounting/resources/StringsResources.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class BudgetsDatabaseInputs {

  static const String databaseTableName = "all_budgets";

  static String budgetsDatabase() {

    return (UserInformation.UserId == StringsResources.unknownText()) ? "budgets_database.db" : "${UserInformation.UserId}_budgets_database.db";;
  }

  Future<void> insertBudgetData(BudgetsData budgetsData, String tableName,
      String usernameId, {bool isPrototype = false}) async {

    var databaseNameQuery = BudgetsDatabaseInputs.budgetsDatabase();
    var tableNameQuery = BudgetsDatabaseInputs.databaseTableName;

    final database = openDatabase(
      join(await getDatabasesPath(), databaseNameQuery),
      onCreate: (databaseInstance, version) {

        return databaseInstance.execute(
          'CREATE TABLE IF NOT EXISTS $tableNameQuery(id INTEGER PRIMARY KEY, '
              'budgetName TEXT, '
              'budgetDescription TEXT, '
              'budgetBalance TEXT, '
              'colorTag TEXT'
              ')',
        );
      },

      version: 1,
      readOnly: false
    );

    final databaseInstance = await database;

    await databaseInstance.insert(
      tableNameQuery,
      budgetsData.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    if (databaseInstance.isOpen && !isPrototype) {

      await databaseInstance.close();

    }
  }

  Future<void> updateBudgetData(BudgetsData budgetsData, String tableName, String usernameId) async {

    var databaseNameQuery = BudgetsDatabaseInputs.budgetsDatabase();
    var tableNameQuery = BudgetsDatabaseInputs.databaseTableName;

    final database = openDatabase(
      join(await getDatabasesPath(), databaseNameQuery),
    );

    final databaseInstance = await database;

    await databaseInstance.update(
      tableNameQuery,
      budgetsData.toMap(),
      where: 'id = ?',
      whereArgs: [budgetsData.id],
    );

    if (databaseInstance.isOpen) {

      await databaseInstance.close();

    }

  }

}