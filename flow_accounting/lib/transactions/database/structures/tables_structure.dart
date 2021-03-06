/*
 * Copyright © 2022 By Geeks Empire.
 *
 * Created by Elias Fazel
 * Last modified 1/13/22, 6:44 AM
 *
 * Licensed Under MIT License.
 * https://opensource.org/licenses/MIT
 */

import 'package:flow_accounting/resources/ColorsResources.dart';

class TransactionsData {

  static const TransactionType_Send = "-";
  static const TransactionType_Receive = "+";

  static const String TransactionBudgetName = "Unknown";

  final int id;

  final String transactionTitle;
  final String transactionDescription;

  final String sourceCardNumber;
  final String targetCardNumber;

  final String sourceBankName;
  final String targetBankName;

  final String sourceUsername;
  final String targetUsername;

  String amountMoney = "0";
  final String transactionType;

  /// Transaction Time In Millisecond
  final int transactionTimeMillisecond;
  final String transactionTime;
  final String transactionTimeYear;
  final String transactionTimeMonth;

  int colorTag = ColorsResources.dark.value;

  final String budgetName;

  TransactionsData({
    required this.id,

    required this.transactionTitle,
    required this.transactionDescription,

    required this.sourceCardNumber,
    required this.targetCardNumber,

    required this.sourceBankName,
    required this.targetBankName,

    required this.sourceUsername,
    required this.targetUsername,

    required this.amountMoney,
    required this.transactionType,

    required this.transactionTimeMillisecond,
    required this.transactionTime,
    required this.transactionTimeYear,
    required this.transactionTimeMonth,

    required this.colorTag,

    required this.budgetName,
  });

  // Convert a Dog into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,

      'transactionTitle': transactionTitle,
      'transactionDescription': transactionDescription,

      'sourceCardNumber': sourceCardNumber,
      'targetCardNumber': targetCardNumber,

      'sourceBankName': sourceBankName,
      'targetBankName': targetBankName,

      'sourceUsername': sourceUsername,
      'targetUsername': targetUsername,

      'amountMoney': amountMoney,
      'transactionType': transactionType,

      'transactionTimeMillisecond': transactionTimeMillisecond,
      'transactionTime': transactionTime,
      'transactionTimeYear': transactionTimeYear,
      'transactionTimeMonth': transactionTimeMonth,

      'colorTag': colorTag,

      'budgetName': budgetName,
    };
  }

  @override
  String toString() {
    return 'TransactionsData{id: $id, '

        'transactionTitle: $transactionTitle, '
        'transactionDescription: $transactionDescription, '

        'sourceCardNumber: $sourceCardNumber, '
        'targetCardNumber: $targetCardNumber'

        'sourceBankName: $sourceBankName,'
        'targetBankName: $targetBankName,'

        'sourceUsername: $sourceUsername,'
        'targetUsername: $targetUsername,'

        'amountMoney: $amountMoney,'
        'transactionType: $transactionType,'

        'transactionTimeMillisecond: $transactionTimeMillisecond,'
        'transactionTime: $transactionTime,'
        'transactionTimeYear: $transactionTimeYear,'
        'transactionTimeMonth: $transactionTimeMonth,'

        'colorTag: $colorTag,'

        'budgetName: $budgetName,'
        '}';
  }
}
