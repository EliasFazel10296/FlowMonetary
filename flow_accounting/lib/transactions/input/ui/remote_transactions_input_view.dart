/*
 * Copyright © 2022 By Geeks Empire.
 *
 * Created by Elias Fazel
 * Last modified 4/4/22, 4:45 AM
 *
 * Licensed Under MIT License.
 * https://opensource.org/licenses/MIT
 */

import 'dart:io';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:blur/blur.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flow_accounting/budgets/database/io/inputs.dart';
import 'package:flow_accounting/budgets/database/io/queries.dart';
import 'package:flow_accounting/budgets/database/structures/tables_structure.dart';
import 'package:flow_accounting/credit_cards/database/io/inputs.dart';
import 'package:flow_accounting/credit_cards/database/io/queries.dart';
import 'package:flow_accounting/credit_cards/database/structures/tables_structure.dart';
import 'package:flow_accounting/creditors/database/io/inputs.dart';
import 'package:flow_accounting/creditors/database/io/queries.dart';
import 'package:flow_accounting/creditors/database/structures/tables_structure.dart';
import 'package:flow_accounting/customers/database/io/inputs.dart';
import 'package:flow_accounting/customers/database/io/queries.dart';
import 'package:flow_accounting/customers/database/structures/table_structure.dart';
import 'package:flow_accounting/debtors/database/io/inputs.dart';
import 'package:flow_accounting/debtors/database/io/queries.dart';
import 'package:flow_accounting/debtors/database/structures/tables_structure.dart';
import 'package:flow_accounting/home/interface/dashboard.dart';
import 'package:flow_accounting/profile/database/io/queries.dart';
import 'package:flow_accounting/profile/database/structures/tables_structure.dart';
import 'package:flow_accounting/resources/ColorsResources.dart';
import 'package:flow_accounting/resources/StringsResources.dart';
import 'package:flow_accounting/transactions/database/io/inputs.dart';
import 'package:flow_accounting/transactions/database/structures/tables_structure.dart';
import 'package:flow_accounting/utils/calendar/ui/calendar_view.dart';
import 'package:flow_accounting/utils/colors/color_selector.dart';
import 'package:flow_accounting/utils/extensions/bank_logos.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sqflite/sqflite.dart';

class RemoteTransactionsInputView extends StatefulWidget {
  const RemoteTransactionsInputView({Key? key}) : super(key: key);

  @override
  _RemoteTransactionsInputViewState createState() => _RemoteTransactionsInputViewState();
}
class _RemoteTransactionsInputViewState extends State<RemoteTransactionsInputView> {

  CalendarView calendarView = CalendarView();

  ColorSelectorView colorSelectorView = ColorSelectorView();

  TextEditingController controllerMoneyAmount = TextEditingController();

  TextEditingController controllerTransactionTitle = TextEditingController();
  TextEditingController controllerTransactionDescription = TextEditingController();

  TextEditingController controllerTransactionSourceName = TextEditingController();
  TextEditingController controllerTransactionSourceBank = TextEditingController();
  TextEditingController controllerTransactionSourceCard = TextEditingController();

  TextEditingController controllerTransactionTargetName = TextEditingController();
  TextEditingController controllerTransactionTargetBank = TextEditingController();
  TextEditingController controllerTransactionTargetCard = TextEditingController();

  TextEditingController controllerBudget = TextEditingController();

  String transactionType = TransactionsData.TransactionType_Send;

  String budgetName = TransactionsData.TransactionBudgetName;

  int timeNow = DateTime.now().millisecondsSinceEpoch;

  dynamic selectedDynamicData = 0;

  bool transactionDataUpdated = false;

  String? warningNoticeMoneyAmount;

  String? warningNoticeTitle;
  String? warningNoticeDescription;

  String? warningNoticeSourceName;
  String? warningNoticeSourceBank;
  String? warningNoticeSourceCard;

  String? warningNoticeTargetName;
  String? warningNoticeTargetBank;
  String? warningNoticeTargetCard;

  String? warningNoticeBudget;

  @override
  void initState() {
    super.initState();

    calendarView.inputDateTime = StringsResources.transactionTime();

    BackButtonInterceptor.add(aInterceptor);

  }

  @override
  void dispose() {

    BackButtonInterceptor.remove(aInterceptor);

    super.dispose();
  }

  bool aInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {

    UpdatedData.UpdatedDataType = UpdatedData.LatestTransactions;

    Navigator.pop(context, transactionDataUpdated);

    return true;
  }

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: MaterialApp (
        debugShowCheckedModeBanner: false,
        title: StringsResources.applicationName(),
        color: ColorsResources.black,
        theme: ThemeData(
          fontFamily: 'Sans',
          pageTransitionsTheme: const PageTransitionsTheme(builders: {
            TargetPlatform.android: ZoomPageTransitionsBuilder(),
            TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
          }),
        ),
        home: Scaffold(
          backgroundColor: ColorsResources.black,
          body: Padding(
            padding: const EdgeInsets.fromLTRB(/*left*/1.1, /*top*/3, /*right*/1.1, /*bottom*/3),
            child: Container (
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(17), topRight: Radius.circular(17), bottomLeft: Radius.circular(17), bottomRight: Radius.circular(17)),
                gradient: LinearGradient(
                    colors: [
                      ColorsResources.white,
                      ColorsResources.primaryColorLighter,
                    ],
                    begin: FractionalOffset(0.0, 0.0),
                    end: FractionalOffset(1.0, 0.0),
                    stops: [0.0, 1.0],
                    transform: GradientRotation(45),
                    tileMode: TileMode.clamp),
              ),
              child: Stack ( /*** Page Content ***/
                children: [
                  const Opacity(
                    opacity: 0.07,
                    child: Image(
                      image: AssetImage("input_background_pattern.png"),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  ListView(
                      padding: const EdgeInsets.fromLTRB(0, 7, 0, 93),
                      scrollDirection: Axis.vertical,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(13, 13, 13, 0),
                          child:  Text(
                            StringsResources.featureTransactionsTitle(),
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontSize: 23,
                              color: ColorsResources.dark,
                              shadows: [
                                Shadow(
                                  blurRadius: 13,
                                  color: Colors.black.withOpacity(0.3),
                                  offset: const Offset(3, 3),
                                )
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(13, 13, 13, 19),
                          child: Text(
                            StringsResources.featureTransactionsDescription(),
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontSize: 15,
                              color: ColorsResources.blueGreen,
                              shadows: [
                                Shadow(
                                  blurRadius: 7,
                                  color: Colors.black.withOpacity(0.3),
                                  offset: const Offset(1.3, 1.3),
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          height: 73,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Padding(
                                    padding: const EdgeInsets.fromLTRB(13, 0, 13, 0),
                                    child: Directionality(
                                      textDirection: TextDirection.rtl,
                                      child: TextField(
                                        controller: controllerTransactionTitle,
                                        textAlign: TextAlign.right,
                                        textDirection: TextDirection.ltr,
                                        textAlignVertical: TextAlignVertical.bottom,
                                        maxLines: 1,
                                        cursorColor: ColorsResources.primaryColor,
                                        autocorrect: true,
                                        autofocus: false,
                                        keyboardType: TextInputType.text,
                                        textInputAction: TextInputAction.next,
                                        decoration: InputDecoration(
                                          alignLabelWithHint: true,
                                          border: const OutlineInputBorder(
                                              borderSide: BorderSide(color: Colors.blueGrey, width: 1.0),
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(13),
                                                  topRight: Radius.circular(13),
                                                  bottomLeft: Radius.circular(13),
                                                  bottomRight: Radius.circular(13)
                                              ),
                                              gapPadding: 5
                                          ),
                                          enabledBorder: const OutlineInputBorder(
                                              borderSide: BorderSide(color: Colors.blueGrey, width: 1.0),
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(13),
                                                  topRight: Radius.circular(13),
                                                  bottomLeft: Radius.circular(13),
                                                  bottomRight: Radius.circular(13)
                                              ),
                                              gapPadding: 5
                                          ),
                                          focusedBorder: const OutlineInputBorder(
                                              borderSide: BorderSide(color: Colors.lightBlueAccent, width: 1.0),
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(13),
                                                  topRight: Radius.circular(13),
                                                  bottomLeft: Radius.circular(13),
                                                  bottomRight: Radius.circular(13)
                                              ),
                                              gapPadding: 5
                                          ),
                                          errorBorder: const OutlineInputBorder(
                                              borderSide: BorderSide(color: Colors.red, width: 1.0),
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(13),
                                                  topRight: Radius.circular(13),
                                                  bottomLeft: Radius.circular(13),
                                                  bottomRight: Radius.circular(13)
                                              ),
                                              gapPadding: 5
                                          ),
                                          errorText: warningNoticeTitle,
                                          filled: true,
                                          fillColor: ColorsResources.lightTransparent,
                                          labelText: StringsResources.titleText(),
                                          labelStyle: const TextStyle(
                                              color: ColorsResources.dark,
                                              fontSize: 17.0
                                          ),
                                          hintText: StringsResources.titleText(),
                                          hintStyle: const TextStyle(
                                              color: ColorsResources.darkTransparent,
                                              fontSize: 13.0
                                          ),
                                        ),
                                      ),
                                    )
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(
                          height: 13,
                          color: Colors.transparent,
                        ),
                        SizedBox(
                          width: double.infinity,
                          height: 133,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Padding(
                                    padding: const EdgeInsets.fromLTRB(13, 0, 13, 0),
                                    child: Directionality(
                                      textDirection: TextDirection.rtl,
                                      child: TextField(
                                        controller: controllerTransactionDescription,
                                        textAlign: TextAlign.right,
                                        textDirection: TextDirection.ltr,
                                        textAlignVertical: TextAlignVertical.top,
                                        maxLines: 5,
                                        cursorColor: ColorsResources.primaryColor,
                                        autocorrect: true,
                                        autofocus: false,
                                        keyboardType: TextInputType.text,
                                        textInputAction: TextInputAction.next,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: ColorsResources.applicationDarkGeeksEmpire
                                        ),
                                        decoration: InputDecoration(
                                          alignLabelWithHint: true,
                                          border: const OutlineInputBorder(
                                              borderSide: BorderSide(color: Colors.blueGrey, width: 1.0),
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(13),
                                                  topRight: Radius.circular(13),
                                                  bottomLeft: Radius.circular(13),
                                                  bottomRight: Radius.circular(13)
                                              ),
                                              gapPadding: 5
                                          ),
                                          enabledBorder: const OutlineInputBorder(
                                              borderSide: BorderSide(color: Colors.blueGrey, width: 1.0),
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(13),
                                                  topRight: Radius.circular(13),
                                                  bottomLeft: Radius.circular(13),
                                                  bottomRight: Radius.circular(13)
                                              ),
                                              gapPadding: 5
                                          ),
                                          focusedBorder: const OutlineInputBorder(
                                              borderSide: BorderSide(color: Colors.lightBlueAccent, width: 1.0),
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(13),
                                                  topRight: Radius.circular(13),
                                                  bottomLeft: Radius.circular(13),
                                                  bottomRight: Radius.circular(13)
                                              ),
                                              gapPadding: 5
                                          ),
                                          errorBorder: const OutlineInputBorder(
                                              borderSide: BorderSide(color: Colors.red, width: 1.0),
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(13),
                                                  topRight: Radius.circular(13),
                                                  bottomLeft: Radius.circular(13),
                                                  bottomRight: Radius.circular(13)
                                              ),
                                              gapPadding: 5
                                          ),
                                          errorText: warningNoticeDescription,
                                          filled: true,
                                          fillColor: ColorsResources.lightTransparent,
                                          labelText: StringsResources.descriptionText(),
                                          labelStyle: const TextStyle(
                                              color: ColorsResources.dark,
                                              fontSize: 13.0
                                          ),
                                          hintText: StringsResources.descriptionText(),
                                          hintStyle: const TextStyle(
                                              color: ColorsResources.darkTransparent,
                                              fontSize: 13.0
                                          ),
                                        ),
                                      ),
                                    )
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(
                          height: 13,
                          color: Colors.transparent,
                        ),
                        SizedBox(
                          width: double.infinity,
                          height: 73,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Padding(
                                    padding: const EdgeInsets.fromLTRB(13, 0, 13, 0),
                                    child: Directionality(
                                      textDirection: TextDirection.rtl,
                                      child: TextField(
                                        controller: controllerMoneyAmount,
                                        textAlign: TextAlign.center,
                                        textDirection: TextDirection.ltr,
                                        textAlignVertical: TextAlignVertical.bottom,
                                        maxLines: 1,
                                        cursorColor: ColorsResources.primaryColor,
                                        autocorrect: true,
                                        autofocus: false,
                                        keyboardType: TextInputType.number,
                                        textInputAction: TextInputAction.next,
                                        inputFormatters: [
                                          CurrencyTextInputFormatter(decimalDigits: 0, symbol: "")
                                        ],
                                        decoration: InputDecoration(
                                          alignLabelWithHint: true,
                                          border: const OutlineInputBorder(
                                              borderSide: BorderSide(color: Colors.blueGrey, width: 1.0),
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(13),
                                                  topRight: Radius.circular(13),
                                                  bottomLeft: Radius.circular(13),
                                                  bottomRight: Radius.circular(13)
                                              ),
                                              gapPadding: 5
                                          ),
                                          enabledBorder: const OutlineInputBorder(
                                              borderSide: BorderSide(color: Colors.blueGrey, width: 1.0),
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(13),
                                                  topRight: Radius.circular(13),
                                                  bottomLeft: Radius.circular(13),
                                                  bottomRight: Radius.circular(13)
                                              ),
                                              gapPadding: 5
                                          ),
                                          focusedBorder: const OutlineInputBorder(
                                              borderSide: BorderSide(color: Colors.lightBlueAccent, width: 1.0),
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(13),
                                                  topRight: Radius.circular(13),
                                                  bottomLeft: Radius.circular(13),
                                                  bottomRight: Radius.circular(13)
                                              ),
                                              gapPadding: 5
                                          ),
                                          errorBorder: const OutlineInputBorder(
                                              borderSide: BorderSide(color: Colors.red, width: 1.0),
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(13),
                                                  topRight: Radius.circular(13),
                                                  bottomLeft: Radius.circular(13),
                                                  bottomRight: Radius.circular(13)
                                              ),
                                              gapPadding: 5
                                          ),
                                          errorText: warningNoticeMoneyAmount,
                                          filled: true,
                                          fillColor: ColorsResources.lightTransparent,
                                          labelText: StringsResources.transactionAmount(),
                                          labelStyle: const TextStyle(
                                              color: ColorsResources.dark,
                                              fontSize: 17.0
                                          ),
                                          hintText: StringsResources.transactionAmountHint(),
                                          hintStyle: const TextStyle(
                                              color: ColorsResources.darkTransparent,
                                              fontSize: 13.0
                                          ),
                                        ),
                                      ),
                                    )
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(
                          height: 13,
                          color: Colors.transparent,
                        ),
                        SizedBox(
                          width: double.infinity,
                          height: 91,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(13, 0, 0, 0),
                                  child: Align(
                                    alignment: AlignmentDirectional.topCenter,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(13),
                                            topRight: Radius.circular(13),
                                            bottomLeft: Radius.circular(13),
                                            bottomRight: Radius.circular(13)
                                        ),
                                        border: Border(
                                            top: BorderSide(
                                              color: ColorsResources.darkTransparent,
                                              width: 1,
                                            ),
                                            bottom: BorderSide(
                                              color: ColorsResources.darkTransparent,
                                              width: 1,
                                            ),
                                            left: BorderSide(
                                              color: ColorsResources.darkTransparent,
                                              width: 1,
                                            ),
                                            right: BorderSide(
                                              color: ColorsResources.darkTransparent,
                                              width: 1,
                                            )
                                        ),
                                        color: ColorsResources.lightTransparent,
                                      ),
                                      child: SizedBox(
                                        height: 62,
                                        width: double.infinity,
                                        child: calendarView,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Padding(
                                    padding: const EdgeInsets.fromLTRB(7, 0, 13, 0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Align(
                                            alignment: AlignmentDirectional.topCenter,
                                            child: Directionality(
                                              textDirection: TextDirection.rtl,
                                              child: DropdownButtonFormField(
                                                isDense: true,
                                                elevation: 7,
                                                focusColor: ColorsResources.applicationDarkGeeksEmpire,
                                                dropdownColor: ColorsResources.light,
                                                decoration: InputDecoration(
                                                    border: OutlineInputBorder(
                                                      borderSide: const BorderSide(
                                                          color: ColorsResources.applicationDarkGeeksEmpire,
                                                          width: 1
                                                      ),
                                                      borderRadius: BorderRadius.circular(13),
                                                    ),
                                                    enabledBorder: OutlineInputBorder(
                                                      borderSide: const BorderSide(
                                                          color: ColorsResources.applicationDarkGeeksEmpire,
                                                          width: 1
                                                      ),
                                                      borderRadius: BorderRadius.circular(13),
                                                    ),
                                                    focusedBorder: OutlineInputBorder(
                                                      borderSide: const BorderSide(
                                                          color: ColorsResources.applicationDarkGeeksEmpire,
                                                          width: 1
                                                      ),
                                                      borderRadius: BorderRadius.circular(13),
                                                    ),
                                                    errorBorder: OutlineInputBorder(
                                                      borderSide: const BorderSide(
                                                          color: ColorsResources.applicationDarkGeeksEmpire,
                                                          width: 1
                                                      ),
                                                      borderRadius: BorderRadius.circular(13),
                                                    ),
                                                    filled: true,
                                                    fillColor: ColorsResources.lightTransparent,
                                                    focusColor: ColorsResources.dark
                                                ),
                                                value: StringsResources.transactionTypeSend(),
                                                items: <String> [
                                                  StringsResources.transactionTypeSend(),
                                                  StringsResources.transactionTypeReceive()
                                                ].map<DropdownMenuItem<String>>((String value) {

                                                  return DropdownMenuItem<String>(
                                                    value: value,
                                                    child: SizedBox(
                                                      height: 27,
                                                      child: Padding(
                                                        padding: const EdgeInsets.fromLTRB(0, 0, 11, 0),
                                                        child: Align(
                                                          alignment:
                                                          AlignmentDirectional.center,
                                                          child: Text(
                                                            value,
                                                            style: const TextStyle(
                                                              color: ColorsResources.darkTransparent,
                                                              fontSize: 15,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                                onChanged: (value) {

                                                  if (value.toString() == StringsResources.transactionTypeReceive()) {

                                                    transactionType = TransactionsData.TransactionType_Receive;

                                                  } else if (value.toString() == StringsResources.transactionTypeSend()) {

                                                    transactionType = TransactionsData.TransactionType_Send;

                                                  }

                                                },
                                              ),
                                            )
                                        ),
                                        Padding(
                                            padding: EdgeInsets.fromLTRB(0, 5, 7, 0),
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Text(
                                                StringsResources.transactionTypeHint(),
                                                textAlign: TextAlign.right,
                                                style: TextStyle(
                                                    color: ColorsResources.applicationGeeksEmpire,
                                                    fontSize: 12
                                                ),
                                              ),
                                            )
                                        ),
                                      ],
                                    )
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(
                          height: 13,
                          color: Colors.transparent,
                        ),
                        SizedBox(
                          width: double.infinity,
                          height: 73,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Padding(
                                    padding: const EdgeInsets.fromLTRB(13, 0, 13, 0),
                                    child: Directionality(
                                      textDirection: TextDirection.rtl,
                                      child: TypeAheadField<dynamic>(
                                          suggestionsCallback: (pattern) async {

                                            return await getAllNames();
                                          },
                                          itemBuilder: (context, suggestion) {

                                            String suggestedName = "";
                                            int colorTag = Colors.white.value;
                                            String imagePath = "";

                                            if (suggestion is CreditorsData) {

                                              suggestedName = suggestion.creditorsName.toString();
                                              colorTag = suggestion.colorTag;
                                              imagePath = "";

                                            } else if (suggestion is DebtorsData) {

                                              suggestedName = suggestion.debtorsName.toString();
                                              colorTag = suggestion.colorTag;
                                              imagePath = "";

                                            } else if (suggestion is CustomersData) {

                                              suggestedName = suggestion.customerName.toString();
                                              colorTag = suggestion.colorTag;
                                              imagePath = suggestion.customerImagePath;

                                            }

                                            return ListTile(
                                                title: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    Expanded(
                                                        flex: 11,
                                                        child:  Padding(
                                                          padding: const EdgeInsets.fromLTRB(7, 0, 7, 0),
                                                          child: Directionality(
                                                            textDirection: TextDirection.rtl,
                                                            child: Text(
                                                              suggestedName,
                                                              style: const TextStyle(
                                                                  color: ColorsResources.darkTransparent,
                                                                  fontSize: 15
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                    ),
                                                    Expanded(
                                                        flex: 5,
                                                        child: AspectRatio(
                                                          aspectRatio: 1,
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                                shape: BoxShape.circle,
                                                                color: Color(colorTag)
                                                            ),
                                                            child: Padding(
                                                              padding: const EdgeInsets.fromLTRB(3, 3, 3, 3),
                                                              child: ClipRRect(
                                                                borderRadius: BorderRadius.circular(51),
                                                                child: Image.file(
                                                                  File(imagePath),
                                                                  fit: BoxFit.cover,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                    ),
                                                  ],
                                                )
                                            );
                                          },
                                          onSuggestionSelected: (suggestion) {

                                            selectedDynamicData = suggestion;

                                            if (suggestion is CreditorsData) {

                                              controllerTransactionTargetName.text = suggestion.creditorsName.toString();

                                            } else if (suggestion is DebtorsData) {

                                              controllerTransactionTargetName.text = suggestion.debtorsName.toString();

                                            } else if (suggestion is CustomersData) {

                                              controllerTransactionTargetName.text = suggestion.customerName.toString();

                                            }

                                          },
                                          errorBuilder: (context, suggestion) {

                                            return Padding(
                                                padding: EdgeInsets.fromLTRB(13, 7, 13, 7),
                                                child: Text(StringsResources.nothingText())
                                            );
                                          },
                                          suggestionsBoxDecoration: SuggestionsBoxDecoration(
                                              elevation: 7,
                                              color: ColorsResources.light,
                                              shadowColor: ColorsResources.darkTransparent,
                                              borderRadius: BorderRadius.circular(17)
                                          ),
                                          textFieldConfiguration: TextFieldConfiguration(
                                            controller: controllerTransactionTargetName,
                                            autofocus: false,
                                            maxLines: 1,
                                            cursorColor: ColorsResources.primaryColor,
                                            keyboardType: TextInputType.name,
                                            textInputAction: TextInputAction.next,
                                            decoration: InputDecoration(
                                              alignLabelWithHint: true,
                                              border: const OutlineInputBorder(
                                                  borderSide: BorderSide(color: Colors.blueGrey, width: 1.0),
                                                  borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(13),
                                                      topRight: Radius.circular(13),
                                                      bottomLeft: Radius.circular(13),
                                                      bottomRight: Radius.circular(13)
                                                  ),
                                                  gapPadding: 5
                                              ),
                                              enabledBorder: const OutlineInputBorder(
                                                  borderSide: BorderSide(color: Colors.blueGrey, width: 1.0),
                                                  borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(13),
                                                      topRight: Radius.circular(13),
                                                      bottomLeft: Radius.circular(13),
                                                      bottomRight: Radius.circular(13)
                                                  ),
                                                  gapPadding: 5
                                              ),
                                              focusedBorder: const OutlineInputBorder(
                                                  borderSide: BorderSide(color: Colors.lightBlueAccent, width: 1.0),
                                                  borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(13),
                                                      topRight: Radius.circular(13),
                                                      bottomLeft: Radius.circular(13),
                                                      bottomRight: Radius.circular(13)
                                                  ),
                                                  gapPadding: 5
                                              ),
                                              errorBorder: const OutlineInputBorder(
                                                  borderSide: BorderSide(color: Colors.red, width: 1.0),
                                                  borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(13),
                                                      topRight: Radius.circular(13),
                                                      bottomLeft: Radius.circular(13),
                                                      bottomRight: Radius.circular(13)
                                                  ),
                                                  gapPadding: 5
                                              ),
                                              errorText: warningNoticeTargetName,
                                              filled: true,
                                              fillColor: ColorsResources.lightTransparent,
                                              labelText: StringsResources.transactionTargetName(),
                                              labelStyle: const TextStyle(
                                                  color: ColorsResources.dark,
                                                  fontSize: 17.0
                                              ),
                                              hintText: StringsResources.transactionTargetNameHint(),
                                              hintStyle: const TextStyle(
                                                  color: ColorsResources.darkTransparent,
                                                  fontSize: 13.0
                                              ),
                                            ),
                                          )
                                      ),
                                    )
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Padding(
                                    padding: const EdgeInsets.fromLTRB(13, 0, 13, 0),
                                    child: Directionality(
                                      textDirection: TextDirection.rtl,
                                      child: TypeAheadField<dynamic>(
                                          suggestionsCallback: (pattern) async {

                                            return await getAllNames();
                                          },
                                          itemBuilder: (context, suggestion) {

                                            String suggestedName = "";
                                            int colorTag = Colors.white.value;
                                            String imagePath = "";

                                            if (suggestion is CreditorsData) {

                                              suggestedName = suggestion.creditorsName.toString();
                                              colorTag = suggestion.colorTag;
                                              imagePath = "";

                                            } else if (suggestion is DebtorsData) {

                                              suggestedName = suggestion.debtorsName.toString();
                                              colorTag = suggestion.colorTag;
                                              imagePath = "";

                                            } else if (suggestion is CustomersData) {

                                              suggestedName = suggestion.customerName.toString();
                                              colorTag = suggestion.colorTag;
                                              imagePath = suggestion.customerImagePath;

                                            }

                                            return ListTile(
                                                title: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    Expanded(
                                                        flex: 11,
                                                        child:  Padding(
                                                          padding: const EdgeInsets.fromLTRB(7, 0, 7, 0),
                                                          child: Directionality(
                                                            textDirection: TextDirection.rtl,
                                                            child: Text(
                                                              suggestedName,
                                                              style: const TextStyle(
                                                                  color: ColorsResources.darkTransparent,
                                                                  fontSize: 15
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                    ),
                                                    Expanded(
                                                        flex: 5,
                                                        child: AspectRatio(
                                                          aspectRatio: 1,
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                                shape: BoxShape.circle,
                                                                color: Color(colorTag)
                                                            ),
                                                            child: Padding(
                                                              padding: const EdgeInsets.fromLTRB(3, 3, 3, 3),
                                                              child: ClipRRect(
                                                                borderRadius: BorderRadius.circular(51),
                                                                child: Image.file(
                                                                  File(imagePath),
                                                                  fit: BoxFit.cover,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                    ),
                                                  ],
                                                )
                                            );
                                          },
                                          onSuggestionSelected: (suggestion) {

                                            selectedDynamicData = suggestion;

                                            if (suggestion is CreditorsData) {

                                              controllerTransactionTargetName.text = suggestion.creditorsName.toString();

                                            } else if (suggestion is DebtorsData) {

                                              controllerTransactionTargetName.text = suggestion.debtorsName.toString();

                                            } else if (suggestion is CustomersData) {

                                              controllerTransactionTargetName.text = suggestion.customerName.toString();

                                            }

                                          },
                                          errorBuilder: (context, suggestion) {

                                            return Padding(
                                                padding: EdgeInsets.fromLTRB(13, 7, 13, 7),
                                                child: Text(StringsResources.nothingText())
                                            );
                                          },
                                          suggestionsBoxDecoration: SuggestionsBoxDecoration(
                                              elevation: 7,
                                              color: ColorsResources.light,
                                              shadowColor: ColorsResources.darkTransparent,
                                              borderRadius: BorderRadius.circular(17)
                                          ),
                                          textFieldConfiguration: TextFieldConfiguration(
                                            controller: controllerTransactionSourceName,
                                            autofocus: false,
                                            maxLines: 1,
                                            cursorColor: ColorsResources.primaryColor,
                                            keyboardType: TextInputType.name,
                                            textInputAction: TextInputAction.next,
                                            decoration: InputDecoration(
                                              alignLabelWithHint: true,
                                              border: const OutlineInputBorder(
                                                  borderSide: BorderSide(color: Colors.blueGrey, width: 1.0),
                                                  borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(13),
                                                      topRight: Radius.circular(13),
                                                      bottomLeft: Radius.circular(13),
                                                      bottomRight: Radius.circular(13)
                                                  ),
                                                  gapPadding: 5
                                              ),
                                              enabledBorder: const OutlineInputBorder(
                                                  borderSide: BorderSide(color: Colors.blueGrey, width: 1.0),
                                                  borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(13),
                                                      topRight: Radius.circular(13),
                                                      bottomLeft: Radius.circular(13),
                                                      bottomRight: Radius.circular(13)
                                                  ),
                                                  gapPadding: 5
                                              ),
                                              focusedBorder: const OutlineInputBorder(
                                                  borderSide: BorderSide(color: Colors.lightBlueAccent, width: 1.0),
                                                  borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(13),
                                                      topRight: Radius.circular(13),
                                                      bottomLeft: Radius.circular(13),
                                                      bottomRight: Radius.circular(13)
                                                  ),
                                                  gapPadding: 5
                                              ),
                                              errorBorder: const OutlineInputBorder(
                                                  borderSide: BorderSide(color: Colors.red, width: 1.0),
                                                  borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(13),
                                                      topRight: Radius.circular(13),
                                                      bottomLeft: Radius.circular(13),
                                                      bottomRight: Radius.circular(13)
                                                  ),
                                                  gapPadding: 5
                                              ),
                                              errorText: warningNoticeSourceName,
                                              filled: true,
                                              fillColor: ColorsResources.lightTransparent,
                                              labelText: StringsResources.transactionSourceName(),
                                              labelStyle: const TextStyle(
                                                  color: ColorsResources.dark,
                                                  fontSize: 17.0
                                              ),
                                              hintText: StringsResources.transactionSourceNameHint(),
                                              hintStyle: const TextStyle(
                                                  color: ColorsResources.darkTransparent,
                                                  fontSize: 13.0
                                              ),
                                            ),
                                          )
                                      ),
                                    )
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(
                          height: 13,
                          color: Colors.transparent,
                        ),
                        SizedBox(
                          width: double.infinity,
                          height: 73,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Padding(
                                    padding: const EdgeInsets.fromLTRB(13, 0, 13, 0),
                                    child: Directionality(
                                      textDirection: TextDirection.rtl,
                                      child: TypeAheadField<String>(
                                          suggestionsCallback: (pattern) async {

                                            return await getBanksNames();
                                          },
                                          itemBuilder: (context, suggestion) {

                                            return ListTile(
                                                title: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    Expanded(
                                                      flex: 11,
                                                      child: Padding(
                                                        padding: const EdgeInsets.fromLTRB(7, 0, 7, 0),
                                                        child: Directionality(
                                                          textDirection: TextDirection.rtl,
                                                          child: Text(
                                                            suggestion,
                                                            style: const TextStyle(
                                                                color: ColorsResources.darkTransparent,
                                                                fontSize: 15
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                        flex: 5,
                                                        child:  AspectRatio(
                                                          aspectRatio: 1,
                                                          child: Container(
                                                            decoration: const BoxDecoration(
                                                                shape: BoxShape.circle,
                                                                color: ColorsResources.light
                                                            ),
                                                            child: Padding(
                                                              padding: const EdgeInsets.fromLTRB(3, 3, 3, 3),
                                                              child: ClipRRect(
                                                                borderRadius: BorderRadius.circular(51),
                                                                child: Image.network(
                                                                  generateBankLogoUrl(suggestion),
                                                                  fit: BoxFit.cover,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                    ),
                                                  ],
                                                )
                                            );
                                          },
                                          onSuggestionSelected: (suggestion) {

                                            controllerTransactionTargetBank.text = suggestion.toString();

                                          },
                                          errorBuilder: (context, suggestion) {

                                            return Padding(
                                                padding: EdgeInsets.fromLTRB(13, 7, 13, 7),
                                                child: Text(StringsResources.nothingText())
                                            );
                                          },
                                          suggestionsBoxDecoration: SuggestionsBoxDecoration(
                                              elevation: 7,
                                              color: ColorsResources.light,
                                              shadowColor: ColorsResources.darkTransparent,
                                              borderRadius: BorderRadius.circular(17)
                                          ),
                                          textFieldConfiguration: TextFieldConfiguration(
                                            controller: controllerTransactionTargetBank,
                                            autofocus: false,
                                            maxLines: 1,
                                            cursorColor: ColorsResources.primaryColor,
                                            keyboardType: TextInputType.name,
                                            textInputAction: TextInputAction.next,
                                            decoration: InputDecoration(
                                              alignLabelWithHint: true,
                                              border: const OutlineInputBorder(
                                                  borderSide: BorderSide(color: Colors.blueGrey, width: 1.0),
                                                  borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(13),
                                                      topRight: const Radius.circular(13),
                                                      bottomLeft: const Radius.circular(13),
                                                      bottomRight: Radius.circular(13)
                                                  ),
                                                  gapPadding: 5
                                              ),
                                              enabledBorder: const OutlineInputBorder(
                                                  borderSide: BorderSide(color: Colors.blueGrey, width: 1.0),
                                                  borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(13),
                                                      topRight: const Radius.circular(13),
                                                      bottomLeft: const Radius.circular(13),
                                                      bottomRight: const Radius.circular(13)
                                                  ),
                                                  gapPadding: 5
                                              ),
                                              focusedBorder: const OutlineInputBorder(
                                                  borderSide: BorderSide(color: Colors.lightBlueAccent, width: 1.0),
                                                  borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(13),
                                                      topRight: const Radius.circular(13),
                                                      bottomLeft: const Radius.circular(13),
                                                      bottomRight: Radius.circular(13)
                                                  ),
                                                  gapPadding: 5
                                              ),
                                              errorBorder: const OutlineInputBorder(
                                                  borderSide: BorderSide(color: Colors.red, width: 1.0),
                                                  borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(13),
                                                      topRight: Radius.circular(13),
                                                      bottomLeft: const Radius.circular(13),
                                                      bottomRight: Radius.circular(13)
                                                  ),
                                                  gapPadding: 5
                                              ),
                                              errorText: warningNoticeTargetBank,
                                              filled: true,
                                              fillColor: ColorsResources.lightTransparent,
                                              labelText: StringsResources.transactionTargetBank(),
                                              labelStyle: const TextStyle(
                                                  color: ColorsResources.dark,
                                                  fontSize: 17.0
                                              ),
                                              hintText: StringsResources.transactionTargetBankHint(),
                                              hintStyle: const TextStyle(
                                                  color: ColorsResources.darkTransparent,
                                                  fontSize: 13.0
                                              ),
                                            ),
                                          )
                                      ),
                                    )
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Padding(
                                    padding: const EdgeInsets.fromLTRB(13, 0, 13, 0),
                                    child: Directionality(
                                      textDirection: TextDirection.rtl,
                                      child: TypeAheadField<String>(
                                          suggestionsCallback: (pattern) async {

                                            return await getBanksNames();
                                          },
                                          itemBuilder: (context, suggestion) {

                                            return ListTile(
                                                title: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    Expanded(
                                                      flex: 11,
                                                      child: Padding(
                                                        padding: const EdgeInsets.fromLTRB(7, 0, 7, 0),
                                                        child: Directionality(
                                                          textDirection: TextDirection.rtl,
                                                          child: Text(
                                                            suggestion,
                                                            style: const TextStyle(
                                                                color: ColorsResources.darkTransparent,
                                                                fontSize: 15
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                        flex: 5,
                                                        child:  AspectRatio(
                                                          aspectRatio: 1,
                                                          child: Container(
                                                            decoration: const BoxDecoration(
                                                                shape: BoxShape.circle,
                                                                color: ColorsResources.light
                                                            ),
                                                            child: Padding(
                                                              padding: const EdgeInsets.fromLTRB(3, 3, 3, 3),
                                                              child: ClipRRect(
                                                                borderRadius: BorderRadius.circular(51),
                                                                child: Image.network(
                                                                  generateBankLogoUrl(suggestion),
                                                                  fit: BoxFit.cover,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                    ),
                                                  ],
                                                )
                                            );
                                          },
                                          onSuggestionSelected: (suggestion) {

                                            controllerTransactionSourceBank.text = suggestion.toString();

                                          },
                                          errorBuilder: (context, suggestion) {

                                            return Padding(
                                                padding: EdgeInsets.fromLTRB(13, 7, 13, 7),
                                                child: Text(StringsResources.nothingText())
                                            );
                                          },
                                          suggestionsBoxDecoration: SuggestionsBoxDecoration(
                                              elevation: 7,
                                              color: ColorsResources.light,
                                              shadowColor: ColorsResources.darkTransparent,
                                              borderRadius: BorderRadius.circular(17)
                                          ),
                                          textFieldConfiguration: TextFieldConfiguration(
                                            controller: controllerTransactionSourceBank,
                                            autofocus: false,
                                            maxLines: 1,
                                            cursorColor: ColorsResources.primaryColor,
                                            keyboardType: TextInputType.name,
                                            textInputAction: TextInputAction.next,
                                            decoration: InputDecoration(
                                              alignLabelWithHint: true,
                                              border: const OutlineInputBorder(
                                                  borderSide: BorderSide(color: Colors.blueGrey, width: 1.0),
                                                  borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(13),
                                                      topRight: Radius.circular(13),
                                                      bottomLeft: Radius.circular(13),
                                                      bottomRight: Radius.circular(13)
                                                  ),
                                                  gapPadding: 5
                                              ),
                                              enabledBorder: const OutlineInputBorder(
                                                  borderSide: BorderSide(color: Colors.blueGrey, width: 1.0),
                                                  borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(13),
                                                      topRight: Radius.circular(13),
                                                      bottomLeft: Radius.circular(13),
                                                      bottomRight: Radius.circular(13)
                                                  ),
                                                  gapPadding: 5
                                              ),
                                              focusedBorder: const OutlineInputBorder(
                                                  borderSide: BorderSide(color: Colors.lightBlueAccent, width: 1.0),
                                                  borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(13),
                                                      topRight: Radius.circular(13),
                                                      bottomLeft: Radius.circular(13),
                                                      bottomRight: Radius.circular(13)
                                                  ),
                                                  gapPadding: 5
                                              ),
                                              errorBorder: const OutlineInputBorder(
                                                  borderSide: BorderSide(color: Colors.red, width: 1.0),
                                                  borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(13),
                                                      topRight: Radius.circular(13),
                                                      bottomLeft: Radius.circular(13),
                                                      bottomRight: Radius.circular(13)
                                                  ),
                                                  gapPadding: 5
                                              ),
                                              errorText: warningNoticeSourceBank,
                                              filled: true,
                                              fillColor: ColorsResources.lightTransparent,
                                              labelText: StringsResources.transactionSourceBank(),
                                              labelStyle: const TextStyle(
                                                  color: ColorsResources.dark,
                                                  fontSize: 17.0
                                              ),
                                              hintText: StringsResources.transactionSourceBankHint(),
                                              hintStyle: const TextStyle(
                                                  color: ColorsResources.darkTransparent,
                                                  fontSize: 13.0
                                              ),
                                            ),
                                          )
                                      ),
                                    )
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(
                          height: 13,
                          color: Colors.transparent,
                        ),
                        SizedBox(
                          width: double.infinity,
                          height: 73,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Padding(
                                    padding: const EdgeInsets.fromLTRB(13, 0, 13, 0),
                                    child: Directionality(
                                      textDirection: TextDirection.rtl,
                                      child: TypeAheadField<CreditCardsData>(
                                          suggestionsCallback: (pattern) async {

                                            return await getCreditCards();
                                          },
                                          itemBuilder: (context, suggestion) {

                                            return ListTile(title: Directionality(
                                              textDirection: TextDirection.rtl,
                                              child: Text(
                                                suggestion.cardNumber,
                                                style: const TextStyle(
                                                    color: ColorsResources.darkTransparent,
                                                    fontSize: 15
                                                ),
                                              ),
                                            ));
                                          },
                                          onSuggestionSelected: (suggestion) {

                                            controllerTransactionSourceCard.text = suggestion.cardNumber.toString();

                                          },
                                          errorBuilder: (context, suggestion) {

                                            return Padding(
                                                padding: EdgeInsets.fromLTRB(13, 7, 13, 7),
                                                child: Text(StringsResources.nothingText())
                                            );
                                          },
                                          suggestionsBoxDecoration: SuggestionsBoxDecoration(
                                              elevation: 7,
                                              color: ColorsResources.light,
                                              shadowColor: ColorsResources.darkTransparent,
                                              borderRadius: BorderRadius.circular(17)
                                          ),
                                          textFieldConfiguration: TextFieldConfiguration(
                                            controller: controllerTransactionSourceCard,
                                            autofocus: false,
                                            maxLines: 1,
                                            textAlign: TextAlign.center,
                                            cursorColor: ColorsResources.primaryColor,
                                            keyboardType: TextInputType.number,
                                            textInputAction: TextInputAction.next,
                                            inputFormatters: [
                                              LengthLimitingTextInputFormatter(16)
                                            ],
                                            decoration: InputDecoration(
                                              alignLabelWithHint: true,
                                              border: const OutlineInputBorder(
                                                  borderSide: BorderSide(color: Colors.blueGrey, width: 1.0),
                                                  borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(13),
                                                      topRight: Radius.circular(13),
                                                      bottomLeft: Radius.circular(13),
                                                      bottomRight: Radius.circular(13)
                                                  ),
                                                  gapPadding: 5
                                              ),
                                              enabledBorder: const OutlineInputBorder(
                                                  borderSide: BorderSide(color: Colors.blueGrey, width: 1.0),
                                                  borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(13),
                                                      topRight: Radius.circular(13),
                                                      bottomLeft: Radius.circular(13),
                                                      bottomRight: Radius.circular(13)
                                                  ),
                                                  gapPadding: 5
                                              ),
                                              focusedBorder: const OutlineInputBorder(
                                                  borderSide: BorderSide(color: Colors.lightBlueAccent, width: 1.0),
                                                  borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(13),
                                                      topRight: Radius.circular(13),
                                                      bottomLeft: Radius.circular(13),
                                                      bottomRight: Radius.circular(13)
                                                  ),
                                                  gapPadding: 5
                                              ),
                                              errorBorder: const OutlineInputBorder(
                                                  borderSide: BorderSide(color: Colors.red, width: 1.0),
                                                  borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(13),
                                                      topRight: Radius.circular(13),
                                                      bottomLeft: Radius.circular(13),
                                                      bottomRight: Radius.circular(13)
                                                  ),
                                                  gapPadding: 5
                                              ),
                                              errorText: warningNoticeSourceCard,
                                              filled: true,
                                              fillColor: ColorsResources.lightTransparent,
                                              labelText: StringsResources.transactionSourceCard(),
                                              labelStyle: const TextStyle(
                                                  color: ColorsResources.dark,
                                                  fontSize: 17.0
                                              ),
                                              hintText: StringsResources.transactionSourceCardHint(),
                                              hintStyle: const TextStyle(
                                                  color: ColorsResources.darkTransparent,
                                                  fontSize: 13.0
                                              ),
                                            ),
                                          )
                                      ),
                                    )
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(
                          height: 7,
                          color: Colors.transparent,
                        ),
                        SizedBox(
                          width: double.infinity,
                          height: 73,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Padding(
                                    padding: const EdgeInsets.fromLTRB(13, 0, 13, 0),
                                    child: Directionality(
                                      textDirection: TextDirection.rtl,
                                      child: TypeAheadField<CreditCardsData>(
                                          suggestionsCallback: (pattern) async {

                                            return await getCreditCards();
                                          },
                                          itemBuilder: (context, suggestion) {

                                            return ListTile(title: Directionality(
                                              textDirection: TextDirection.rtl,
                                              child: Text(
                                                suggestion.cardNumber,
                                                style: const TextStyle(
                                                    color: ColorsResources.darkTransparent,
                                                    fontSize: 15
                                                ),
                                              ),
                                            ));
                                          },
                                          onSuggestionSelected: (suggestion) {

                                            controllerTransactionTargetCard.text = suggestion.cardNumber.toString();

                                          },
                                          errorBuilder: (context, suggestion) {

                                            return Padding(
                                                padding: EdgeInsets.fromLTRB(13, 7, 13, 7),
                                                child: Text(StringsResources.nothingText())
                                            );
                                          },
                                          suggestionsBoxDecoration: SuggestionsBoxDecoration(
                                              elevation: 7,
                                              color: ColorsResources.light,
                                              shadowColor: ColorsResources.darkTransparent,
                                              borderRadius: BorderRadius.circular(17)
                                          ),
                                          textFieldConfiguration: TextFieldConfiguration(
                                            controller: controllerTransactionTargetCard,
                                            autofocus: false,
                                            maxLines: 1,
                                            textAlign: TextAlign.center,
                                            cursorColor: ColorsResources.primaryColor,
                                            keyboardType: TextInputType.number,
                                            textInputAction: TextInputAction.next,
                                            inputFormatters: [
                                              LengthLimitingTextInputFormatter(16)
                                            ],
                                            decoration: InputDecoration(
                                              alignLabelWithHint: true,
                                              border: const OutlineInputBorder(
                                                  borderSide: BorderSide(color: Colors.blueGrey, width: 1.0),
                                                  borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(13),
                                                      topRight: Radius.circular(13),
                                                      bottomLeft: Radius.circular(13),
                                                      bottomRight: Radius.circular(13)
                                                  ),
                                                  gapPadding: 5
                                              ),
                                              enabledBorder: const OutlineInputBorder(
                                                  borderSide: BorderSide(color: Colors.blueGrey, width: 1.0),
                                                  borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(13),
                                                      topRight: Radius.circular(13),
                                                      bottomLeft: Radius.circular(13),
                                                      bottomRight: Radius.circular(13)
                                                  ),
                                                  gapPadding: 5
                                              ),
                                              focusedBorder: const OutlineInputBorder(
                                                  borderSide: BorderSide(color: Colors.lightBlueAccent, width: 1.0),
                                                  borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(13),
                                                      topRight: Radius.circular(13),
                                                      bottomLeft: Radius.circular(13),
                                                      bottomRight: Radius.circular(13)
                                                  ),
                                                  gapPadding: 5
                                              ),
                                              errorBorder: const OutlineInputBorder(
                                                  borderSide: BorderSide(color: Colors.red, width: 1.0),
                                                  borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(13),
                                                      topRight: Radius.circular(13),
                                                      bottomLeft: Radius.circular(13),
                                                      bottomRight: Radius.circular(13)
                                                  ),
                                                  gapPadding: 5
                                              ),
                                              errorText: warningNoticeTargetCard,
                                              filled: true,
                                              fillColor: ColorsResources.lightTransparent,
                                              labelText: StringsResources.transactionTargetCard(),
                                              labelStyle: const TextStyle(
                                                  color: ColorsResources.dark,
                                                  fontSize: 17.0
                                              ),
                                              hintText: StringsResources.transactionTargetCardHint(),
                                              hintStyle: const TextStyle(
                                                  color: ColorsResources.darkTransparent,
                                                  fontSize: 13.0
                                              ),
                                            ),
                                          )
                                      ),
                                    )
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(
                          height: 13,
                          color: Colors.transparent,
                        ),
                        SizedBox(
                          width: double.infinity,
                          height: 73,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Padding(
                                    padding: const EdgeInsets.fromLTRB(13, 0, 13, 0),
                                    child: Directionality(
                                      textDirection: TextDirection.rtl,
                                      child: TypeAheadField<BudgetsData>(
                                          suggestionsCallback: (pattern) async {

                                            return await getBudgetNames();
                                          },
                                          itemBuilder: (context, suggestion) {

                                            return ListTile(title: Directionality(
                                                textDirection: TextDirection.rtl,
                                                child: SizedBox(
                                                  height: 51,
                                                  width: double.infinity,
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                          flex: 3,
                                                          child: Padding(
                                                            padding: const EdgeInsets.fromLTRB(7, 7, 7, 7),
                                                            child: Container(
                                                              decoration: BoxDecoration(
                                                                  shape: BoxShape.circle,
                                                                  color: Color(suggestion.colorTag)
                                                              ),
                                                              child: const Padding(
                                                                padding: EdgeInsets.fromLTRB(1.7, 1.7, 1.7, 1.7),
                                                                child: Image(
                                                                  image: AssetImage("coins_icon.png"),
                                                                  height: 51,
                                                                  width: 51,
                                                                  color: ColorsResources.white,
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                      ),
                                                      Expanded(
                                                        flex: 11,
                                                        child: Padding(
                                                          padding: const EdgeInsets.fromLTRB(7, 0, 7, 0),
                                                          child: Text(
                                                            suggestion.budgetName,
                                                            style: const TextStyle(
                                                                color: ColorsResources.darkTransparent,
                                                                fontSize: 15
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                            ));
                                          },
                                          onSuggestionSelected: (suggestion) {

                                            controllerBudget.text = suggestion.budgetName.toString();
                                            budgetName = suggestion.budgetName.toString();

                                          },
                                          errorBuilder: (context, suggestion) {

                                            return Padding(
                                                padding: EdgeInsets.fromLTRB(13, 7, 13, 7),
                                                child: Text(StringsResources.nothingText())
                                            );
                                          },
                                          suggestionsBoxDecoration: SuggestionsBoxDecoration(
                                              elevation: 7,
                                              color: ColorsResources.light,
                                              shadowColor: ColorsResources.darkTransparent,
                                              borderRadius: BorderRadius.circular(17)
                                          ),
                                          textFieldConfiguration: TextFieldConfiguration(
                                            controller: controllerBudget,
                                            autofocus: false,
                                            maxLines: 1,
                                            cursorColor: ColorsResources.primaryColor,
                                            keyboardType: TextInputType.text,
                                            textInputAction: TextInputAction.done,
                                            decoration: InputDecoration(
                                              alignLabelWithHint: true,
                                              border: const OutlineInputBorder(
                                                  borderSide: const BorderSide(color: Colors.blueGrey, width: 1.0),
                                                  borderRadius: BorderRadius.only(
                                                      topLeft: const Radius.circular(13),
                                                      topRight: const Radius.circular(13),
                                                      bottomLeft: const Radius.circular(13),
                                                      bottomRight: const Radius.circular(13)
                                                  ),
                                                  gapPadding: 5
                                              ),
                                              enabledBorder: const OutlineInputBorder(
                                                  borderSide: const BorderSide(color: Colors.blueGrey, width: 1.0),
                                                  borderRadius: BorderRadius.only(
                                                      topLeft: const Radius.circular(13),
                                                      topRight: const Radius.circular(13),
                                                      bottomLeft: const Radius.circular(13),
                                                      bottomRight: const Radius.circular(13)
                                                  ),
                                                  gapPadding: 5
                                              ),
                                              focusedBorder: const OutlineInputBorder(
                                                  borderSide: BorderSide(color: Colors.lightBlueAccent, width: 1.0),
                                                  borderRadius: BorderRadius.only(
                                                      topLeft: const Radius.circular(13),
                                                      topRight: const Radius.circular(13),
                                                      bottomLeft: const Radius.circular(13),
                                                      bottomRight: const Radius.circular(13)
                                                  ),
                                                  gapPadding: 5
                                              ),
                                              errorBorder: const OutlineInputBorder(
                                                  borderSide: BorderSide(color: Colors.red, width: 1.0),
                                                  borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(13),
                                                      topRight: const Radius.circular(13),
                                                      bottomLeft: const Radius.circular(13),
                                                      bottomRight: Radius.circular(13)
                                                  ),
                                                  gapPadding: 5
                                              ),
                                              errorText: warningNoticeBudget,
                                              filled: true,
                                              fillColor: ColorsResources.lightTransparent,
                                              labelText: StringsResources.transactionBudgetName(),
                                              labelStyle: const TextStyle(
                                                  color: ColorsResources.dark,
                                                  fontSize: 17.0
                                              ),
                                              hintText: StringsResources.transactionBudgetNameHint(),
                                              hintStyle: const TextStyle(
                                                  color: ColorsResources.darkTransparent,
                                                  fontSize: 13.0
                                              ),
                                            ),
                                          )
                                      ),
                                    )
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(
                          height: 13,
                          color: Colors.transparent,
                        ),
                        SizedBox(
                          width: double.infinity,
                          height: 37,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Padding(
                                    padding: EdgeInsets.fromLTRB(13, 0, 13, 0),
                                    child: Directionality(
                                      textDirection: TextDirection.rtl,
                                      child: Text(
                                        StringsResources.colorSelectorHint(),
                                        style: TextStyle(
                                            fontSize: 15
                                        ),
                                      ),
                                    )
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          height: 103,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(13, 0, 13, 0),
                                  child: colorSelectorView,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ]
                  ),
                  Positioned(
                      top: 19,
                      left: 13,
                      child:  InkWell(
                        onTap: () {

                          UpdatedData.UpdatedDataType = UpdatedData.LatestTransactions;

                          Navigator.pop(context, transactionDataUpdated);

                        },
                        child: Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                    color: ColorsResources.blueGrayLight.withOpacity(0.7),
                                    blurRadius: 7,
                                    spreadRadius: 0.1,
                                    offset: const Offset(0.0, 3.7)
                                )
                              ]
                          ),
                          child: const Image(
                            image: AssetImage("go_previous_icon.png"),
                            fit: BoxFit.scaleDown,
                            width: 41,
                            height: 41,
                          ),
                        ),
                      )
                  ),
                  Positioned(
                      bottom: 19,
                      left: 59,
                      right: 59,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                              flex: 13,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(51.0),
                                child: Material(
                                  shadowColor: Colors.transparent,
                                  color: Colors.transparent,
                                  child: InkWell(
                                    splashColor: ColorsResources.applicationGeeksEmpire.withOpacity(0.5),
                                    splashFactory: InkRipple.splashFactory,
                                    onTap: () {

                                      bool noError = true;

                                      if (controllerTransactionSourceCard.text.length < 16) {

                                        setState(() {

                                          warningNoticeSourceCard = StringsResources.errorText();

                                        });

                                        noError = false;

                                      }

                                      if (controllerTransactionTargetCard.text.length < 16) {

                                        setState(() {

                                          warningNoticeTargetCard = StringsResources.errorText();

                                        });

                                        noError = false;

                                      }

                                      if (controllerMoneyAmount.text.isEmpty) {

                                        setState(() {

                                          warningNoticeMoneyAmount = StringsResources.errorText();

                                        });

                                        noError = false;

                                      }

                                      if (controllerTransactionTitle.text.isEmpty) {

                                        setState(() {

                                          warningNoticeTitle = StringsResources.errorText();

                                        });

                                        noError = false;

                                      }

                                      if (controllerTransactionDescription.text.isEmpty) {

                                        setState(() {

                                          warningNoticeDescription = StringsResources.errorText();

                                        });

                                        noError = false;

                                      }

                                      if (controllerTransactionSourceName.text.isEmpty) {

                                        setState(() {

                                          warningNoticeSourceName = StringsResources.errorText();

                                        });

                                        noError = false;

                                      }

                                      if (controllerTransactionSourceBank.text.isEmpty) {

                                        setState(() {

                                          warningNoticeSourceBank = StringsResources.errorText();

                                        });

                                        noError = false;

                                      }

                                      if (controllerTransactionTargetName.text.isEmpty) {

                                        setState(() {

                                          warningNoticeTargetName = StringsResources.errorText();

                                        });

                                        noError = false;

                                      }

                                      if (controllerTransactionTargetBank.text.isEmpty) {

                                        setState(() {

                                          warningNoticeTargetBank = StringsResources.errorText();

                                        });

                                        noError = false;

                                      }

                                      if (controllerBudget.text.isEmpty) {

                                        setState(() {

                                          warningNoticeBudget = StringsResources.errorText();

                                        });

                                        noError = false;

                                      }

                                      if (noError) {

                                        var databaseInputs = TransactionsDatabaseInputs();

                                        TransactionsData transactionData = TransactionsData(
                                          id: timeNow,

                                          transactionTitle: controllerTransactionTitle.text,
                                          transactionDescription: controllerTransactionDescription.text,

                                          amountMoney: controllerMoneyAmount.text,
                                          transactionType: transactionType,

                                          transactionTimeMillisecond: calendarView.pickedDateTime.millisecondsSinceEpoch,
                                          transactionTime: calendarView.inputDateTime ?? "",
                                          transactionTimeYear: calendarView.pickedDataTimeYear,
                                          transactionTimeMonth: calendarView.pickedDataTimeMonth,

                                          sourceUsername: controllerTransactionSourceName.text,
                                          sourceBankName: controllerTransactionSourceBank.text,
                                          sourceCardNumber: controllerTransactionSourceCard.text,

                                          targetUsername: controllerTransactionTargetName.text,
                                          targetBankName: controllerTransactionTargetBank.text,
                                          targetCardNumber: controllerTransactionTargetCard.text,

                                          colorTag: colorSelectorView.selectedColor.value,

                                          budgetName: budgetName,
                                        );

                                        databaseInputs.insertTransactionData(transactionData, TransactionsDatabaseInputs.databaseTableName, UserInformation.UserId);

                                        processDebtorsCreditors(transactionData, selectedDynamicData);

                                        Fluttertoast.showToast(
                                            msg: StringsResources.updatedText(),
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.CENTER,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor: ColorsResources.lightTransparent,
                                            textColor: ColorsResources.dark,
                                            fontSize: 16.0
                                        );

                                        processCreditCardsBalance(transactionData);

                                        processBudgetBalance(transactionData);

                                        transactionDataUpdated = true;

                                      }

                                    },
                                    child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(51),
                                              topRight: Radius.circular(51),
                                              bottomLeft: Radius.circular(51),
                                              bottomRight: Radius.circular(51)
                                          ),
                                          border: const Border(
                                              top: BorderSide(
                                                color: ColorsResources.primaryColorLight,
                                                width: 1,
                                              ),
                                              bottom: BorderSide(
                                                color: ColorsResources.primaryColorLight,
                                                width: 1,
                                              ),
                                              left: BorderSide(
                                                color: ColorsResources.primaryColorLight,
                                                width: 1,
                                              ),
                                              right: BorderSide(
                                                color: ColorsResources.primaryColorLight,
                                                width: 1,
                                              )
                                          ),
                                          gradient: LinearGradient(
                                              colors: [
                                                ColorsResources.primaryColor.withOpacity(0.3),
                                                ColorsResources.primaryColorLight.withOpacity(0.3),
                                              ],
                                              begin: const FractionalOffset(0.0, 0.0),
                                              end: const FractionalOffset(1.0, 0.0),
                                              stops: const [0.0, 1.0],
                                              transform: const GradientRotation(45),
                                              tileMode: TileMode.clamp
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: ColorsResources.dark.withOpacity(0.179),
                                              blurRadius: 13.0,
                                              spreadRadius: 0.3,
                                              offset: const Offset(3.0, 3.0),
                                            ),
                                          ],
                                        ),
                                        child: Stack(
                                          children: [
                                            Blur(
                                              blur: 3.0,
                                              borderRadius: BorderRadius.circular(51),
                                              alignment: AlignmentDirectional.center,
                                              blurColor: Colors.blue,
                                              colorOpacity: 0.0,
                                              child: const SizedBox(
                                                width: double.infinity,
                                                height: 53,
                                              ),
                                            ),
                                            SizedBox(
                                                width: double.infinity,
                                                height: 53,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    Expanded(
                                                      flex: 3,
                                                      child: ColoredBox(color: Colors.transparent),
                                                    ),
                                                    Expanded(
                                                      flex: 3,
                                                      child: Align(
                                                        alignment: AlignmentDirectional.center,
                                                        child: Image(
                                                          image: AssetImage("submit_icon.png"),
                                                          height: 37,
                                                          width: 37,
                                                          color: ColorsResources.light,
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                        flex: 5,
                                                        child: Align(
                                                          alignment: AlignmentDirectional.center,
                                                          child: Text(
                                                            StringsResources.submitText(),
                                                            textAlign: TextAlign.center,
                                                            style: TextStyle(
                                                                fontSize: 19,
                                                                color: ColorsResources.darkTransparent,
                                                                shadows: [
                                                                  Shadow(
                                                                      color: ColorsResources.primaryColorDark,
                                                                      blurRadius: 7.0,
                                                                      offset: Offset(1, 1)
                                                                  )
                                                                ]
                                                            ),
                                                          ),
                                                        )
                                                    ),
                                                    Expanded(
                                                      flex: 3,
                                                      child: ColoredBox(color: Colors.transparent),
                                                    ),
                                                  ],
                                                )
                                            )
                                          ],
                                        )
                                    ),
                                  ),
                                ),
                              )
                          ),
                          Expanded(
                            flex: 1,
                            child: ColoredBox(color: Colors.transparent),
                          ),
                          Expanded(
                              flex: 3,
                              child: Tooltip(
                                  triggerMode: TooltipTriggerMode.longPress,
                                  message: StringsResources.quickSaveHint(),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(51),
                                    gradient: const LinearGradient(
                                      colors: [
                                        ColorsResources.black,
                                        ColorsResources.primaryColorDark
                                      ],
                                      transform: const GradientRotation(45),
                                    ),
                                  ),
                                  height: 31,
                                  padding: const EdgeInsets.fromLTRB(13, 3, 13, 3),
                                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 7),
                                  preferBelow: false,
                                  textStyle: const TextStyle(
                                    color: ColorsResources.light,
                                    fontSize: 13,
                                  ),
                                  showDuration: const Duration(seconds: 3),
                                  waitDuration: const Duration(seconds: 5),
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(51.0),
                                      child: Material(
                                        shadowColor: Colors.transparent,
                                        color: Colors.transparent,
                                        child: InkWell(
                                          splashColor: ColorsResources.applicationGeeksEmpire.withOpacity(0.5),
                                          splashFactory: InkRipple.splashFactory,
                                          onTap: () {

                                            bool noError = true;

                                            if (controllerTransactionSourceCard.text.length < 16) {

                                              setState(() {

                                                warningNoticeSourceCard = StringsResources.errorText();

                                              });

                                              noError = false;

                                            }

                                            if (controllerTransactionTargetCard.text.length < 16) {

                                              setState(() {

                                                warningNoticeTargetCard = StringsResources.errorText();

                                              });

                                              noError = false;

                                            }

                                            if (controllerMoneyAmount.text.isEmpty) {

                                              setState(() {

                                                warningNoticeMoneyAmount = StringsResources.errorText();

                                              });

                                              noError = false;

                                            }

                                            if (controllerTransactionTitle.text.isEmpty) {

                                              setState(() {

                                                warningNoticeTitle = StringsResources.errorText();

                                              });

                                              noError = false;

                                            }

                                            if (controllerTransactionDescription.text.isEmpty) {

                                              setState(() {

                                                warningNoticeDescription = StringsResources.errorText();

                                              });

                                              noError = false;

                                            }

                                            if (controllerTransactionSourceName.text.isEmpty) {

                                              setState(() {

                                                warningNoticeSourceName = StringsResources.errorText();

                                              });

                                              noError = false;

                                            }

                                            if (controllerTransactionSourceBank.text.isEmpty) {

                                              setState(() {

                                                warningNoticeSourceBank = StringsResources.errorText();

                                              });

                                              noError = false;

                                            }

                                            if (controllerTransactionTargetName.text.isEmpty) {

                                              setState(() {

                                                warningNoticeTargetName = StringsResources.errorText();

                                              });

                                              noError = false;

                                            }

                                            if (controllerTransactionTargetBank.text.isEmpty) {

                                              setState(() {

                                                warningNoticeTargetBank = StringsResources.errorText();

                                              });

                                              noError = false;

                                            }

                                            if (controllerBudget.text.isEmpty) {

                                              setState(() {

                                                warningNoticeBudget = StringsResources.errorText();

                                              });

                                              noError = false;

                                            }

                                            if (noError) {

                                              var databaseInputs = TransactionsDatabaseInputs();

                                              TransactionsData transactionData = TransactionsData(
                                                id: DateTime.now().millisecondsSinceEpoch,

                                                transactionTitle: controllerTransactionTitle.text,
                                                transactionDescription: controllerTransactionDescription.text,

                                                amountMoney: controllerMoneyAmount.text,
                                                transactionType: transactionType,

                                                transactionTimeMillisecond: calendarView.pickedDateTime.millisecondsSinceEpoch,
                                                transactionTime: calendarView.inputDateTime ?? "",
                                                transactionTimeYear: calendarView.pickedDataTimeYear,
                                                transactionTimeMonth: calendarView.pickedDataTimeMonth,

                                                sourceUsername: controllerTransactionSourceName.text,
                                                sourceBankName: controllerTransactionSourceBank.text,
                                                sourceCardNumber: controllerTransactionSourceCard.text,

                                                targetUsername: controllerTransactionTargetName.text,
                                                targetBankName: controllerTransactionTargetBank.text,
                                                targetCardNumber: controllerTransactionTargetCard.text,

                                                colorTag: colorSelectorView.selectedColor.value,

                                                budgetName: budgetName,
                                              );

                                              databaseInputs.insertTransactionData(transactionData, TransactionsDatabaseInputs.databaseTableName, UserInformation.UserId);

                                              processDebtorsCreditors(transactionData, selectedDynamicData);

                                              Fluttertoast.showToast(
                                                  msg: StringsResources.updatedText(),
                                                  toastLength: Toast.LENGTH_SHORT,
                                                  gravity: ToastGravity.CENTER,
                                                  timeInSecForIosWeb: 1,
                                                  backgroundColor: ColorsResources.lightTransparent,
                                                  textColor: ColorsResources.dark,
                                                  fontSize: 16.0
                                              );

                                              processCreditCardsBalance(transactionData);

                                              processBudgetBalance(transactionData);

                                              transactionDataUpdated = true;

                                            }

                                          },
                                          child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius: const BorderRadius.only(
                                                    topLeft: Radius.circular(51),
                                                    topRight: Radius.circular(51),
                                                    bottomLeft: Radius.circular(51),
                                                    bottomRight: Radius.circular(51)
                                                ),
                                                border: const Border(
                                                    top: BorderSide(
                                                      color: ColorsResources.primaryColorLight,
                                                      width: 1,
                                                    ),
                                                    bottom: BorderSide(
                                                      color: ColorsResources.primaryColorLight,
                                                      width: 1,
                                                    ),
                                                    left: BorderSide(
                                                      color: ColorsResources.primaryColorLight,
                                                      width: 1,
                                                    ),
                                                    right: BorderSide(
                                                      color: ColorsResources.primaryColorLight,
                                                      width: 1,
                                                    )
                                                ),
                                                gradient: LinearGradient(
                                                    colors: [
                                                      ColorsResources.primaryColor.withOpacity(0.3),
                                                      ColorsResources.primaryColorLight.withOpacity(0.3),
                                                    ],
                                                    begin: const FractionalOffset(0.0, 0.0),
                                                    end: const FractionalOffset(1.0, 0.0),
                                                    stops: const [0.0, 1.0],
                                                    transform: const GradientRotation(45),
                                                    tileMode: TileMode.clamp
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: ColorsResources.dark.withOpacity(0.179),
                                                    blurRadius: 13.0,
                                                    spreadRadius: 0.3,
                                                    offset: const Offset(3.0, 3.0),
                                                  ),
                                                ],
                                              ),
                                              child: Stack(
                                                children: [
                                                  Blur(
                                                    blur: 3.0,
                                                    borderRadius: BorderRadius.circular(51),
                                                    alignment: AlignmentDirectional.center,
                                                    blurColor: Colors.blue,
                                                    colorOpacity: 0.0,
                                                    child: const SizedBox(
                                                      width: 53,
                                                      height: 53,
                                                    ),
                                                  ),
                                                  Align(
                                                      alignment: AlignmentDirectional.center,
                                                      child: const SizedBox(
                                                          width: 53,
                                                          height: 53,
                                                          child: Align(
                                                              alignment: AlignmentDirectional.center,
                                                              child: Image(
                                                                image: AssetImage("quick_save.png"),
                                                                color: ColorsResources.lightestOrange,
                                                              )
                                                          )
                                                      )
                                                  )
                                                ],
                                              )
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                              )
                          )
                        ],
                      )
                  )
                ],
              ),
            ),
          ),
        ),
      )
    );
  }

  Future<List<dynamic>> getAllNames() async {

    String databaseDirectory = await getDatabasesPath();

    List<dynamic> listOfNames = [];

    if (UserInformation.UserId != StringsResources.unknownText()) {

      ProfileDatabaseQueries profileDatabaseQueries = ProfileDatabaseQueries();

      ProfilesData profilesData = (await profileDatabaseQueries.querySignedInUser())!;

      listOfNames.add(CustomersData(
          id: profilesData.id,
          customerName: StringsResources.mySelfText(),
          customerDescription: profilesData.userFullName,
          customerCountry: "",
          customerCity: "",
          customerStreetAddress: "",
          customerPhoneNumber: profilesData.userPhoneNumber,
          customerEmailAddress: profilesData.userEmailAddress,
          customerAge: "",
          customerBirthday: "",
          customerJob: "",
          customerMaritalStatus: "",
          customerImagePath: profilesData.userImage,
          customerPurchases: "0",
          colorTag: Colors.white.value));

    }

    // Creditors
    String creditorDatabasePath = "${databaseDirectory}/${CreditorsDatabaseInputs.creditorsDatabase()}";

    bool creditorDatabaseExist = await databaseExists(creditorDatabasePath);

    if (creditorDatabaseExist) {

      CreditorsDatabaseQueries creditorsDatabaseQueries = CreditorsDatabaseQueries();

      var retrievedCreditors = await creditorsDatabaseQueries.getAllCreditors(CreditorsDatabaseInputs.databaseTableName, UserInformation.UserId);

      if (retrievedCreditors.isNotEmpty) {

        listOfNames.addAll(retrievedCreditors);

      }

    }

    // Debtors
    String debtorDatabasePath = "${databaseDirectory}/${DebtorsDatabaseInputs.debtorsDatabase()}";

    bool debtorDatabaseExist = await databaseExists(debtorDatabasePath);

    if (debtorDatabaseExist) {

      DebtorsDatabaseQueries debtorsDatabaseQueries = DebtorsDatabaseQueries();

      var retrievedDebtors = await debtorsDatabaseQueries.getAllDebtors(DebtorsDatabaseInputs.databaseTableName, UserInformation.UserId);

      if (retrievedDebtors.isNotEmpty) {

        listOfNames.addAll(retrievedDebtors);

      }

    }

    // Customers
    String customerDatabasePath = "${databaseDirectory}/${CustomersDatabaseInputs.customersDatabase()}";

    bool customerDatabaseExist = await databaseExists(customerDatabasePath);

    if (customerDatabaseExist) {

      CustomersDatabaseQueries customersDatabaseQueries = CustomersDatabaseQueries();

      var retrievedCustomers = await customersDatabaseQueries.getAllCustomers(CustomersDatabaseInputs.databaseTableName, UserInformation.UserId);

      if (retrievedCustomers.isNotEmpty) {

        listOfNames.addAll(retrievedCustomers);

      }

    }

    return listOfNames;
  }

  Future<List<String>> getBanksNames() async {

    return StringsResources.listOfBanksIran();
  }

  Future<List<BudgetsData>> getBudgetNames() async {

    List<BudgetsData> listOfBudgets = [];

    String databaseDirectory = await getDatabasesPath();

    String budgetDatabasePath = "${databaseDirectory}/${BudgetsDatabaseInputs.budgetsDatabase()}";

    bool budgetDatabaseExist = await databaseExists(budgetDatabasePath);

    if (budgetDatabaseExist) {

      BudgetsDatabaseQueries budgetsDatabaseQueries = BudgetsDatabaseQueries();

      var retrievedBudgets = await budgetsDatabaseQueries.getAllBudgets(BudgetsDatabaseInputs.databaseTableName, UserInformation.UserId);

      if (retrievedBudgets.isNotEmpty) {

        listOfBudgets.addAll(retrievedBudgets);

      }

    }

    return listOfBudgets;
  }

  Future<List<CreditCardsData>> getCreditCards() async {

    List<CreditCardsData> listOfCreditCards = [];

    String databaseDirectory = await getDatabasesPath();

    String creditCardDatabasePath = "${databaseDirectory}/${CreditCardsDatabaseInputs.creditCardDatabase()}";

    bool creditCardDatabaseExist = await databaseExists(creditCardDatabasePath);

    if (creditCardDatabaseExist) {

      CreditCardsDatabaseQueries creditCardsDatabaseQueries = CreditCardsDatabaseQueries();

      var retrievedCreditCards = await creditCardsDatabaseQueries.getAllCreditCards(CreditCardsDatabaseInputs.databaseTableName, UserInformation.UserId);

      if (retrievedCreditCards.isNotEmpty) {

        listOfCreditCards.addAll(retrievedCreditCards);

      }

    }

    return listOfCreditCards;
  }

  Future processCreditCardsBalance(TransactionsData transactionsData) async {

    if (transactionsData.transactionType == TransactionsData.TransactionType_Send) {

      String databaseDirectory = await getDatabasesPath();

      String creditCardDatabasePath = "${databaseDirectory}/${CreditCardsDatabaseInputs.creditCardDatabase()}";

      bool creditCardDatabaseExist = await databaseExists(creditCardDatabasePath);

      if (creditCardDatabaseExist) {

        var creditCardsDatabaseQueries = CreditCardsDatabaseQueries();

        var sourceCreditCardData = await creditCardsDatabaseQueries.extractTransactionsQuery(
            await creditCardsDatabaseQueries.querySpecificCreditCardByCardNumber(controllerTransactionSourceCard.text, CreditCardsDatabaseInputs.databaseTableName, UserInformation.UserId)
        );

        var newCardBalance = (int.parse(sourceCreditCardData.cardBalance) - int.parse(transactionsData.amountMoney)).toString();

        var creditCardsDatabaseInputs = CreditCardsDatabaseInputs();

        creditCardsDatabaseInputs.updateCreditCardsData(
            CreditCardsData(
                id: sourceCreditCardData.id,
                cardNumber: sourceCreditCardData.cardNumber,
                cardExpiry: sourceCreditCardData.cardExpiry,
                cardHolderName: sourceCreditCardData.cardHolderName,
                cvv: sourceCreditCardData.cvv,
                bankName: sourceCreditCardData.bankName,
                cardBalance: newCardBalance,
                cardAccountNumber: sourceCreditCardData.cardAccountNumber,
                colorTag: sourceCreditCardData.colorTag
            ),
            CreditCardsDatabaseInputs.databaseTableName, UserInformation.UserId
        );

      }

    } else if (transactionsData.transactionType == TransactionsData.TransactionType_Receive) {

      String databaseDirectory = await getDatabasesPath();

      String creditCardDatabasePath = "${databaseDirectory}/${CreditCardsDatabaseInputs.creditCardDatabase()}";

      bool creditCardDatabaseExist = await databaseExists(creditCardDatabasePath);

      if (creditCardDatabaseExist) {

        var creditCardsDatabaseQueries = CreditCardsDatabaseQueries();

        var sourceCreditCardData = await creditCardsDatabaseQueries.extractTransactionsQuery(
            await creditCardsDatabaseQueries.querySpecificCreditCardByCardNumber(controllerTransactionTargetCard.text, CreditCardsDatabaseInputs.databaseTableName, UserInformation.UserId)
        );

        var newCardBalance = (int.parse(sourceCreditCardData.cardBalance) + int.parse(transactionsData.amountMoney)).toString();

        var creditCardsDatabaseInputs = CreditCardsDatabaseInputs();

        creditCardsDatabaseInputs.updateCreditCardsData(
            CreditCardsData(
                id: sourceCreditCardData.id,
                cardNumber: sourceCreditCardData.cardNumber,
                cardExpiry: sourceCreditCardData.cardExpiry,
                cardHolderName: sourceCreditCardData.cardHolderName,
                cvv: sourceCreditCardData.cvv,
                bankName: sourceCreditCardData.bankName,
                cardBalance: newCardBalance,
                cardAccountNumber: sourceCreditCardData.cardAccountNumber,
                colorTag: sourceCreditCardData.colorTag
            ),
            CreditCardsDatabaseInputs.databaseTableName, UserInformation.UserId
        );

      }

    }

  }

  Future processBudgetBalance(TransactionsData transactionsData) async {

    if (transactionsData.transactionType == TransactionsData.TransactionType_Send) {

      String databaseDirectory = await getDatabasesPath();

      String budgetDatabasePath = "${databaseDirectory}/${BudgetsDatabaseInputs.budgetsDatabase()}";

      bool budgetDatabaseExist = await databaseExists(budgetDatabasePath);

      if (budgetDatabaseExist) {

        var budgetsDatabaseQueries = BudgetsDatabaseQueries();

        var budgetData = await budgetsDatabaseQueries.extractBudgetsQuery(
            await budgetsDatabaseQueries.querySpecificBudgetsByName(controllerTransactionSourceCard.text, CreditCardsDatabaseInputs.databaseTableName, UserInformation.UserId)
        );

        var newBudgetBalance = (int.parse(budgetData.budgetBalance) - int.parse(transactionsData.amountMoney)).toString();

        var budgetsDatabaseInputs = BudgetsDatabaseInputs();

        budgetsDatabaseInputs.updateBudgetData(
            BudgetsData(
                id: budgetData.id,
                budgetName: budgetData.budgetName,
                budgetDescription: budgetData.budgetDescription,
                budgetBalance: newBudgetBalance,
                colorTag: budgetData.colorTag
            ),
            CreditCardsDatabaseInputs.databaseTableName, UserInformation.UserId
        );

      }

    } else if (transactionsData.transactionType == TransactionsData.TransactionType_Receive) {

      String databaseDirectory = await getDatabasesPath();

      String budgetDatabasePath = "${databaseDirectory}/${BudgetsDatabaseInputs.budgetsDatabase()}";

      bool budgetDatabaseExist = await databaseExists(budgetDatabasePath);

      if (budgetDatabaseExist) {

        var budgetsDatabaseQueries = BudgetsDatabaseQueries();

        var budgetData = await budgetsDatabaseQueries.extractBudgetsQuery(
            await budgetsDatabaseQueries.querySpecificBudgetsByName(controllerTransactionSourceCard.text, CreditCardsDatabaseInputs.databaseTableName, UserInformation.UserId)
        );

        var newBudgetBalance = (int.parse(budgetData.budgetBalance) + int.parse(transactionsData.amountMoney)).toString();

        var budgetsDatabaseInputs = BudgetsDatabaseInputs();

        budgetsDatabaseInputs.updateBudgetData(
            BudgetsData(
                id: budgetData.id,
                budgetName: budgetData.budgetName,
                budgetDescription: budgetData.budgetDescription,
                budgetBalance: newBudgetBalance,
                colorTag: budgetData.colorTag
            ),
            CreditCardsDatabaseInputs.databaseTableName, UserInformation.UserId
        );

      }

    }

  }

  void processDebtorsCreditors(TransactionsData transactionsData, dynamic dynamicData) async {

    String databaseDirectory = await getDatabasesPath();

    if (transactionsData.transactionType == TransactionsData.TransactionType_Send) {

      if (dynamicData is CreditorsData) {

        String creditorsDatabasePath = "${databaseDirectory}/${CreditorsDatabaseInputs.creditorsDatabase()}";

        bool creditorsDatabaseExist = await databaseExists(creditorsDatabasePath);

        if (creditorsDatabaseExist) {

          var databaseQuery = CreditorsDatabaseQueries();

          CreditorsData creditorsData = await databaseQuery.querySpecificCreditorById(dynamicData.id, CreditorsDatabaseInputs.databaseTableName, UserInformation.UserId);

          creditorsData.creditorsPaidCredit = (int.parse(creditorsData.creditorsPaidCredit) + int.parse(transactionsData.amountMoney)).toString();

          creditorsData.creditorsRemainingCredit = (int.parse(creditorsData.creditorsRemainingCredit) - int.parse(transactionsData.amountMoney)).toString();

          var databaseInput = CreditorsDatabaseInputs();

          databaseInput.updateCreditorData(creditorsData, CreditorsDatabaseInputs.databaseTableName, UserInformation.UserId);

        }

      } else if (dynamicData is DebtorsData) {

        String debtorsDatabasePath = "${databaseDirectory}/${DebtorsDatabaseInputs.debtorsDatabase()}";

        bool debtorsDatabaseExist = await databaseExists(debtorsDatabasePath);

        if (debtorsDatabaseExist) {

          String creditorsDatabasePath = "${databaseDirectory}/${CreditorsDatabaseInputs.creditorsDatabase()}";

          bool creditorsDatabaseExist = await databaseExists(creditorsDatabasePath);

          if (creditorsDatabaseExist) {

            var databaseQuery = DebtorsDatabaseQueries();

            DebtorsData debtorsData = await databaseQuery.querySpecificDebtorById(dynamicData.id, DebtorsDatabaseInputs.databaseTableName, UserInformation.UserId);

            debtorsData.debtorsPaidDebt = (int.parse(debtorsData.debtorsPaidDebt) + int.parse(transactionsData.amountMoney)).toString();

            debtorsData.debtorsRemainingDebt = (int.parse(debtorsData.debtorsRemainingDebt) - int.parse(transactionsData.amountMoney)).toString();

            var databaseInput = DebtorsDatabaseInputs();

            databaseInput.updateDebtorData(debtorsData, CreditorsDatabaseInputs.databaseTableName, UserInformation.UserId);

          }

        }

      }

    } else if (transactionsData.transactionType == TransactionsData.TransactionType_Receive) {

      if (dynamicData is CreditorsData) {

        String creditorsDatabasePath = "${databaseDirectory}/${CreditorsDatabaseInputs.creditorsDatabase()}";

        bool creditorsDatabaseExist = await databaseExists(creditorsDatabasePath);

        if (creditorsDatabaseExist) {

          var databaseQuery = CreditorsDatabaseQueries();

          CreditorsData creditorsData = await databaseQuery.querySpecificCreditorById(dynamicData.id, CreditorsDatabaseInputs.databaseTableName, UserInformation.UserId);

          creditorsData.creditorsPaidCredit = (int.parse(creditorsData.creditorsPaidCredit) - int.parse(transactionsData.amountMoney)).toString();

          creditorsData.creditorsRemainingCredit = (int.parse(creditorsData.creditorsRemainingCredit) + int.parse(transactionsData.amountMoney)).toString();

          var databaseInput = CreditorsDatabaseInputs();

          databaseInput.updateCreditorData(creditorsData, CreditorsDatabaseInputs.databaseTableName, UserInformation.UserId);

        }

      } else if (dynamicData is DebtorsData) {

        String debtorsDatabasePath = "${databaseDirectory}/${DebtorsDatabaseInputs.debtorsDatabase()}";

        bool debtorsDatabaseExist = await databaseExists(debtorsDatabasePath);

        if (debtorsDatabaseExist) {

          String creditorsDatabasePath = "${databaseDirectory}/${CreditorsDatabaseInputs.creditorsDatabase()}";

          bool creditorsDatabaseExist = await databaseExists(creditorsDatabasePath);

          if (creditorsDatabaseExist) {

            var databaseQuery = DebtorsDatabaseQueries();

            DebtorsData debtorsData = await databaseQuery.querySpecificDebtorById(dynamicData.id, DebtorsDatabaseInputs.databaseTableName, UserInformation.UserId);

            debtorsData.debtorsPaidDebt = (int.parse(debtorsData.debtorsPaidDebt) - int.parse(transactionsData.amountMoney)).toString();

            debtorsData.debtorsRemainingDebt = (int.parse(debtorsData.debtorsRemainingDebt) + int.parse(transactionsData.amountMoney)).toString();

            var databaseInput = DebtorsDatabaseInputs();

            databaseInput.updateDebtorData(debtorsData, CreditorsDatabaseInputs.databaseTableName, UserInformation.UserId);

          }

        }

      }

    }

  }

}