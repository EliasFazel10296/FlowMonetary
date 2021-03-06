/*
 * Copyright © 2022 By Geeks Empire.
 *
 * Created by Elias Fazel
 * Last modified 3/22/22, 6:11 AM
 *
 * Licensed Under MIT License.
 * https://opensource.org/licenses/MIT
 */

import 'package:flow_accounting/profile/database/structures/tables_structure.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ProfilesDatabaseInputs {

  static const String databaseTableName = "all_profiles";

  static String profilesDatabase() {

    return "profiles_database.db";
  }

  Future<void> insertProfileData(ProfilesData profilesData) async {

    var tableNameQuery = ProfilesDatabaseInputs.databaseTableName;

    final database = openDatabase(
      join(await getDatabasesPath(), ProfilesDatabaseInputs.profilesDatabase()),
      onCreate: (databaseInstance, version) {

        return databaseInstance.execute(
          'CREATE TABLE IF NOT EXISTS $tableNameQuery(id INTEGER PRIMARY KEY, '
              'userId TEXT, '
              'userFullName TEXT, '
              'userImage TEXT, '
              'userEmailAddress TEXT, '
              'userPhoneNumber TEXT, '
              'userInstagram TEXT, '
              'userLocationAddress TEXT, '
              'userSignedIn TEXT'
              ')',
        );
      },

      version: 1,
      readOnly: false
    );

    final databaseInstance = await database;

    await databaseInstance.insert(
      tableNameQuery,
      profilesData.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    if (databaseInstance.isOpen) {

      await databaseInstance.close();

    }

  }

  Future<void> updateProfileData(ProfilesData profilesData) async {

    final database = openDatabase(
      join(await getDatabasesPath(), ProfilesDatabaseInputs.profilesDatabase()),
    );

    final databaseInstance = await database;

    var tableNameQuery = ProfilesDatabaseInputs.databaseTableName;

    await databaseInstance.update(
      tableNameQuery,
      profilesData.toMap(),
      where: 'id = ?',
      whereArgs: [profilesData.id],
    );

    if (databaseInstance.isOpen) {

      await databaseInstance.close();

    }

  }

}