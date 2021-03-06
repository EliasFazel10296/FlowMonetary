/*
 * Copyright © 2022 By Geeks Empire.
 *
 * Created by Elias Fazel
 * Last modified 1/13/22, 6:47 AM
 *
 * Licensed Under MIT License.
 * https://opensource.org/licenses/MIT
 */

import 'package:flow_accounting/resources/ColorsResources.dart';

class CreditCardsData {

  final int id;

  final String cardNumber;
  ///YY/MM
  final String cardExpiry;
  final String cardHolderName;
  final String cvv;
  final String bankName;
  String cardBalance = "0";

  final String cardAccountNumber;

  int colorTag = ColorsResources.dark.value;

  CreditCardsData({
    required this.id,

    required this.cardNumber,
    required this.cardExpiry,
    required this.cardHolderName,
    required this.cvv,
    required this.bankName,
    required this.cardBalance,

    required this.cardAccountNumber,

    required this.colorTag,
  });

  // Convert a Dog into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,

      'cardNumber': cardNumber,
      'cardExpiry': cardExpiry,
      'cardHolderName': cardHolderName,
      'cvv': cvv,
      'bankName': bankName,
      'cardBalance': cardBalance,

      'cardAccountNumber': cardAccountNumber,

      'colorTag': colorTag,
    };
  }

  @override
  String toString() {
    return 'CreditCardsData{id: $id, '

        'cardNumber: $cardNumber, '
        'cardExpiry: $cardExpiry'
        'cardHolderName: $cardHolderName,'
        'cvv: $cvv,'
        'bankName: $bankName,'
        'cardBalance: $cardBalance,'

        'cardAccountNumber: $cardAccountNumber,'

        'colorTag: $colorTag,'
        '}';
  }
}
