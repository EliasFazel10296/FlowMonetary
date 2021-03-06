/*
 * Copyright © 2022 By Geeks Empire.
 *
 * Created by Elias Fazel
 * Last modified 3/2/22, 5:08 AM
 *
 * Licensed Under MIT License.
 * https://opensource.org/licenses/MIT
 */

import 'package:flow_accounting/resources/ColorsResources.dart';

class CustomersData {

  final int id;

  final String customerName;
  final String customerDescription;

  final String customerCountry;
  final String customerCity;
  final String customerStreetAddress;

  final String customerPhoneNumber;
  final String customerEmailAddress;

  final String customerAge;
  final String customerBirthday;

  final String customerJob;

  final String customerMaritalStatus;

  final String customerImagePath;

  String customerPurchases = "0";

  int colorTag = ColorsResources.dark.value;

  CustomersData({
    required this.id,

    required this.customerName,
    required this.customerDescription,

    required this.customerCountry,
    required this.customerCity,
    required this.customerStreetAddress,

    required this.customerPhoneNumber,
    required this.customerEmailAddress,

    required this.customerAge,
    required this.customerBirthday,

    required this.customerJob,

    required this.customerMaritalStatus,

    required this.customerImagePath,

    required this.customerPurchases,

    required this.colorTag,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,

      'customerName': customerName,
      'customerDescription': customerDescription,

      'customerCountry': customerCountry,
      'customerCity': customerCity,
      'customerStreetAddress': customerStreetAddress,

      'customerPhoneNumber': customerPhoneNumber,
      'customerEmailAddress': customerEmailAddress,

      'customerAge': customerAge,
      'customerBirthday': customerBirthday,

      'customerJob': customerJob,

      'customerMaritalStatus': customerMaritalStatus,

      'customerImagePath': customerImagePath,

      'customerPurchases': customerPurchases,

      'colorTag': colorTag,
    };
  }

  @override
  String toString() {
    return 'CustomersData{'
        'id: $id,'

        'customerName: $customerName,'
        'customerDescription: $customerDescription,'

        'customerCountry: $customerCountry,'
        'customerCity: $customerCity,'
        'customerStreetAddress: $customerStreetAddress,'

        'customerPhoneNumber: $customerPhoneNumber,'
        'customerEmailAddress: $customerEmailAddress,'

        'customerAge: $customerAge,'
        'customerBirthday: $customerBirthday,'

        'customerJob: $customerJob,'

        'customerImagePath: $customerImagePath,'

        'customerMaritalStatus: $customerMaritalStatus,'

        'customerPurchases: $customerPurchases,'

        'colorTag: $colorTag,'
        '}';
  }
}