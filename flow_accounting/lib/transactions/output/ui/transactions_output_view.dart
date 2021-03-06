/*
 * Copyright © 2022 By Geeks Empire.
 *
 * Created by Elias Fazel
 * Last modified 4/10/22, 5:03 AM
 *
 * Licensed Under MIT License.
 * https://opensource.org/licenses/MIT
 */

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:blur/blur.dart';
import 'package:flow_accounting/home/interface/dashboard.dart';
import 'package:flow_accounting/profile/database/io/queries.dart';
import 'package:flow_accounting/resources/ColorsResources.dart';
import 'package:flow_accounting/resources/StringsResources.dart';
import 'package:flow_accounting/transactions/database/io/inputs.dart';
import 'package:flow_accounting/transactions/database/io/queries.dart';
import 'package:flow_accounting/transactions/database/structures/tables_structure.dart';
import 'package:flow_accounting/transactions/edit/ui/transactions_edit_view.dart';
import 'package:flow_accounting/utils/calendar/io/time_io.dart';
import 'package:flow_accounting/utils/calendar/ui/calendar_view.dart';
import 'package:flow_accounting/utils/colors/color_selector.dart';
import 'package:flow_accounting/utils/extensions/credit_card_number.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:marquee/marquee.dart';
import 'package:sqflite/sqflite.dart';

class TransactionsOutputView extends StatefulWidget {

  String? initialSearchQuery;

  TransactionsOutputView({Key? key, this.initialSearchQuery}) : super(key: key);

  @override
  _TransactionsOutputViewState createState() => _TransactionsOutputViewState();
}
class _TransactionsOutputViewState extends State<TransactionsOutputView> with TickerProviderStateMixin {

  TimeIO timeIO = TimeIO();
  
  ColorSelectorView colorSelectorView = ColorSelectorView();

  List<TransactionsData> allTransactions = [];
  List<Widget> allTransactionsItems = [];

  TextEditingController controllerTransactionTitle = TextEditingController();

  TextEditingController textEditorControllerQuery = TextEditingController();

  bool transactionDataUpdated = false;

  @override
  void initState() {

    if (widget.initialSearchQuery != null) {

      textEditorControllerQuery.text = widget.initialSearchQuery!;

      searchTransactionsInitially(context, widget.initialSearchQuery!);

    } else {

      retrieveAllTransactions(context);

    }

    super.initState();

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

    colorSelectorView.selectedColorNotifier.addListener(() {

      filterByColorTag(context, allTransactions, colorSelectorView.selectedColorNotifier.value);

    });

    List<Widget> allListContentWidgets = [];
    allListContentWidgets.add(Padding(
      padding: const EdgeInsets.fromLTRB(13, 0, 13, 0),
      child: colorSelectorView,
    ));
    allListContentWidgets.addAll(allTransactionsItems);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      color: ColorsResources.black,
      theme: ThemeData(
        fontFamily: 'Sans',
        pageTransitionsTheme: const PageTransitionsTheme(builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        }),
      ),
      home: Scaffold(
          backgroundColor: ColorsResources.black,
          body: Padding(
            padding: const EdgeInsets.fromLTRB(1.1, 3, 1.1, 3),
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(17),
                    topRight: Radius.circular(17),
                    bottomLeft: Radius.circular(17),
                    bottomRight: Radius.circular(17)
                ),
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
              child: Stack(
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
                    padding: const EdgeInsets.fromLTRB(0, 73, 0, 79),
                    physics: const BouncingScrollPhysics(),
                    children: allListContentWidgets,
                  ),
                  Positioned(
                      top: 19,
                      left: 13,
                      child: InkWell(
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
                      top: 19,
                      right: 13,
                      child: SizedBox(
                        height: 43,
                        width: 321,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const Expanded(
                              flex: 11,
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(3, 0, 0, 0),
                              ),
                            ),
                            Expanded(
                              flex: 11,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 3, 0),
                                child: Stack(
                                  children: [
                                    SizedBox(
                                      height: 43,
                                      width: double.infinity,
                                      child: Blur(
                                        blur: 5,
                                        borderRadius: BorderRadius.circular(51),
                                        blurColor: Colors.white.withOpacity(0.3),
                                        child: Container(
                                          decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                  colors: [
                                                    ColorsResources.white.withOpacity(0.3),
                                                    ColorsResources.primaryColorLighter.withOpacity(0.3),
                                                  ],
                                                  begin: const FractionalOffset(0.0, 0.0),
                                                  end: const FractionalOffset(1.0, 0.0),
                                                  stops: const [0.0, 1.0],
                                                  transform: const GradientRotation(45),
                                                  tileMode: TileMode.clamp
                                              )
                                          ),
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {

                                        sortTransactionsByTime(context, allTransactions);

                                      },
                                      child: SizedBox(
                                        height: 43,
                                        width: double.infinity,
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            StringsResources.sortTimeNew(),
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: ColorsResources.applicationGeeksEmpire,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Stack(
                                children: [
                                  SizedBox(
                                    height: 43,
                                    width: 43,
                                    child: Blur(
                                      blur: 3,
                                      borderRadius: BorderRadius.circular(51),
                                      blurColor: Colors.white.withOpacity(0.3),
                                      child: Container(
                                        decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                                colors: [
                                                  ColorsResources.white.withOpacity(0.3),
                                                  ColorsResources.primaryColorLighter.withOpacity(0.3),
                                                ],
                                                begin: const FractionalOffset(0.0, 0.0),
                                                end: const FractionalOffset(1.0, 0.0),
                                                stops: const [0.0, 1.0],
                                                transform: const GradientRotation(45),
                                                tileMode: TileMode.clamp
                                            )
                                        ),
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.center,
                                    child: InkWell(
                                      onTap: () {

                                        retrieveAllTransactions(context);

                                      },
                                      child: const Icon(
                                          Icons.refresh_rounded,
                                          size: 31.0,
                                          color: ColorsResources.primaryColorDark
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                  ),
                  Positioned(
                    bottom: 19,
                    left: 11,
                    right: 11,
                    child: Align(
                        alignment: Alignment.center,
                        child: Transform.scale(
                          scale: 1.1,
                          child: SizedBox(
                            height: 73,
                            width: 219,
                            child: Stack(
                              children: [
                                const Image(
                                  image: AssetImage("search_shape.png"),
                                  height: 73,
                                  width: 213,
                                  color: ColorsResources.primaryColorDark,
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: InkWell(
                                    onTap: () {

                                      String searchQuery = textEditorControllerQuery.text;

                                      if (searchQuery.isEmpty) {

                                        setupAdvanceSearch();

                                      } else {

                                        searchTransactions(context, allTransactions, searchQuery);

                                      }

                                    },
                                    onLongPress: () {

                                      setupAdvanceSearch();

                                    },
                                    child: const SizedBox(
                                      height: 23,
                                      width: 57,
                                      child: Image(
                                        image: AssetImage("advanced_search_icon.png"),
                                        color: ColorsResources.black,
                                      )
                                    )
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: SizedBox(
                                      width: 153,
                                      height: 47,
                                      child: Directionality(
                                        textDirection: TextDirection.rtl,
                                        child: TextField(
                                          controller: textEditorControllerQuery,
                                          textAlign: TextAlign.right,
                                          textDirection: TextDirection.rtl,
                                          textAlignVertical: TextAlignVertical.bottom,
                                          maxLines: 1,
                                          cursorColor: ColorsResources.primaryColor,
                                          autocorrect: true,
                                          autofocus: false,
                                          keyboardType: TextInputType.text,
                                          textInputAction: TextInputAction.search,
                                          onSubmitted: (searchQuery) {

                                            searchTransactions(context, allTransactions, searchQuery);

                                          },
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                                borderSide: BorderSide(color: Colors.transparent, width: 1.0),
                                                borderRadius: BorderRadius.only(
                                                    topLeft: Radius.circular(51),
                                                    topRight: Radius.circular(51),
                                                    bottomLeft: Radius.circular(51),
                                                    bottomRight: Radius.circular(51)
                                                ),
                                                gapPadding: 5
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(color: Colors.transparent, width: 1.0),
                                                borderRadius: BorderRadius.only(
                                                    topLeft: Radius.circular(51),
                                                    topRight: Radius.circular(51),
                                                    bottomLeft: Radius.circular(51),
                                                    bottomRight: Radius.circular(51)
                                                ),
                                                gapPadding: 5
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(color: Colors.transparent, width: 1.0),
                                                borderRadius: BorderRadius.only(
                                                    topLeft: Radius.circular(51),
                                                    topRight: Radius.circular(51),
                                                    bottomLeft: Radius.circular(51),
                                                    bottomRight: Radius.circular(51)
                                                ),
                                                gapPadding: 5
                                            ),
                                            hintText: StringsResources.searchHintText(),
                                            hintStyle: TextStyle(
                                                color: ColorsResources.darkTransparent,
                                                fontSize: 13.0
                                            ),
                                            labelText: StringsResources.searchText(),
                                            labelStyle: TextStyle(
                                                color: ColorsResources.dark,
                                                fontSize: 15.0
                                            ),
                                          ),
                                        ),
                                      )
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                    ),
                  )
                ],
              ),
            ),
          )
      ),
    );
  }

  Widget outputItem(BuildContext context, TransactionsData transactionsData) {

    String transactionTypeMark = TransactionsData.TransactionType_Send;
    Color transactionTypeColor = ColorsResources.dark;

    String transactionCardNumber = transactionsData.sourceCardNumber;

    String transactionName = transactionsData.sourceUsername;
    String transactionBank = transactionsData.sourceBankName;

    Color transactionColorTag = Color(transactionsData.colorTag);

    switch (transactionsData.transactionType) {
      case TransactionsData.TransactionType_Send: {

        transactionTypeMark = TransactionsData.TransactionType_Send;
        transactionTypeColor = Colors.red;

        transactionName = transactionsData.targetUsername;

        break;
      }
      case TransactionsData.TransactionType_Receive: {

        transactionTypeMark = TransactionsData.TransactionType_Receive;
        transactionTypeColor = Colors.green;

        transactionName = transactionsData.sourceUsername;

        break;
      }
    }

    if (transactionsData.transactionDescription.isNotEmpty) {

      controllerTransactionTitle.text = transactionsData.transactionDescription;

    } else {

      controllerTransactionTitle.text = transactionsData.transactionTitle;

    }

    return Slidable(
      closeOnScroll: true,
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            flex: 1,
            onPressed: (BuildContext context) {

              deleteTransaction(context, transactionsData);

            },
            backgroundColor: Colors.transparent,
            foregroundColor: ColorsResources.gameGeeksEmpire,
            icon: Icons.delete_rounded,
            label: StringsResources.deleteText(),
            autoClose: true,
          ),
          SlidableAction(
            flex: 1,
            onPressed: (BuildContext context) {

              editTransaction(context, transactionsData);

            },
            backgroundColor: Colors.transparent,
            foregroundColor: ColorsResources.applicationGeeksEmpire,
            icon: Icons.edit_rounded,
            label: StringsResources.editText(),
            autoClose: true,
          ),
        ],
      ),
      child: Padding(
        padding: const  EdgeInsets.fromLTRB(13, 7, 13, 13),
        child: PhysicalModel(
          color: ColorsResources.light,
          elevation: 7,
          shadowColor: transactionColorTag.withOpacity(0.7),
          shape: BoxShape.rectangle,
          borderRadius: const BorderRadius.all(Radius.circular(17)),
          child: InkWell(
            onTap: () {

              editTransaction(context, transactionsData);

            },
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(17),
                    topRight: Radius.circular(17),
                    bottomLeft: Radius.circular(17),
                    bottomRight: Radius.circular(17)
                ),
                gradient: LinearGradient(
                    colors: [
                      ColorsResources.white,
                      ColorsResources.light,
                    ],
                    begin: FractionalOffset(0.0, 0.0),
                    end: FractionalOffset(1.0, 0.0),
                    stops: [0.0, 1.0],
                    transform: GradientRotation(45),
                    tileMode: TileMode.clamp
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    height: 99,
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          flex: 19,
                          child: Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                              child: Stack(
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      SizedBox(
                                        height: 59,
                                        width: double.infinity,
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(27,
                                              11, 13, 0),
                                          child: Align(
                                              alignment: Alignment.center,
                                              child: Marquee(
                                                text: transactionsData.amountMoney,
                                                style: const TextStyle(
                                                  color: ColorsResources.dark,
                                                  fontSize: 31,
                                                  fontFamily: "Numbers",
                                                ),
                                                scrollAxis: Axis.horizontal,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                blankSpace: 293.0,
                                                velocity: 37.0,
                                                fadingEdgeStartFraction: 0.13,
                                                fadingEdgeEndFraction: 0.13,
                                                startAfter: const Duration(milliseconds: 777),
                                                numberOfRounds: 3,
                                                pauseAfterRound: const Duration(milliseconds: 500),
                                                showFadingOnlyWhenScrolling: true,
                                                startPadding: 13.0,
                                                accelerationDuration: const Duration(milliseconds: 500),
                                                accelerationCurve: Curves.linear,
                                                decelerationDuration: const Duration(milliseconds: 500),
                                                decelerationCurve: Curves.easeOut,
                                              )
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                          height: 39,
                                          width: double.infinity,
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(13, 11, 13, 0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Expanded(
                                                  flex: 1,
                                                  child: Directionality(
                                                    textDirection: TextDirection.rtl,
                                                    child: Align(
                                                      alignment: Alignment.centerRight,
                                                      child: Text(
                                                        transactionName,
                                                        style: TextStyle(
                                                          color: ColorsResources.dark.withOpacity(0.579),
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Directionality(
                                                    textDirection: TextDirection.rtl,
                                                    child: Align(
                                                      alignment: Alignment.centerRight,
                                                      child: Text(
                                                        transactionBank,
                                                        style: TextStyle(
                                                          color: ColorsResources.dark.withOpacity(0.579),
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          )
                                      )
                                    ],
                                  ),
                                  Positioned(
                                    left: 0,
                                    top: 0,
                                    child: RotatedBox(
                                      quarterTurns: 3,
                                      child: SizedBox(
                                        height: 27,
                                        width: 79,
                                        child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: const BorderRadius.only(
                                                  topLeft: Radius.circular(0),
                                                  topRight: Radius.circular(17),
                                                  bottomLeft: Radius.circular(17),
                                                  bottomRight: Radius.circular(0)
                                              ),
                                              gradient: LinearGradient(
                                                  colors: [
                                                    ColorsResources.light,
                                                    transactionColorTag.withOpacity(0.7),
                                                  ],
                                                  begin: const FractionalOffset(0.0, 0.0),
                                                  end: const FractionalOffset(1.0, 0.0),
                                                  stops: const [0.0, 1.0],
                                                  transform: const GradientRotation(-45),
                                                  tileMode: TileMode.clamp
                                              ),
                                            ),
                                            child: Align(
                                              alignment: Alignment.center,
                                              child: Text(
                                                transactionsData.budgetName,
                                                textAlign: TextAlign.center,
                                                maxLines: 1,
                                                style: const TextStyle(
                                                  color: ColorsResources.dark,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            )
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              )
                          ),
                        ),
                        Expanded(
                            flex: 5,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(0, 7, 7, 0),
                              child: Align(
                                alignment: Alignment.center,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: transactionTypeColor.withOpacity(0.3),
                                  ),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      transactionTypeMark,
                                      style: TextStyle(
                                          color: transactionTypeColor,
                                          fontSize: 65
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(7, 9, 7, 9),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: TextField(
                          controller: controllerTransactionTitle,
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.ltr,
                          textAlignVertical: TextAlignVertical.center,
                          maxLines: 1,
                          cursorColor: ColorsResources.primaryColor,
                          style: const TextStyle(
                            fontSize: 13,
                            color: ColorsResources.applicationDarkGeeksEmpire
                          ),
                          decoration: InputDecoration(
                            alignLabelWithHint: true,
                            enabled: false,
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blueGrey, width: 1.0),
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(13),
                                    topRight: Radius.circular(13),
                                    bottomLeft: Radius.circular(13),
                                    bottomRight: Radius.circular(13)
                                ),
                                gapPadding: 5
                            ),
                            disabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: ColorsResources.white, width: 1.0),
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(13),
                                    topRight: Radius.circular(13),
                                    bottomLeft: Radius.circular(13),
                                    bottomRight: Radius.circular(13)
                                ),
                                gapPadding: 5
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: ColorsResources.white, width: 1.0),
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(13),
                                    topRight: Radius.circular(13),
                                    bottomLeft: Radius.circular(13),
                                    bottomRight: Radius.circular(13)
                                ),
                                gapPadding: 5
                            ),
                            errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: ColorsResources.white, width: 1.0),
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(13),
                                    topRight: Radius.circular(13),
                                    bottomLeft: Radius.circular(13),
                                    bottomRight: Radius.circular(13)
                                ),
                                gapPadding: 5
                            ),
                            filled: true,
                            fillColor: ColorsResources.lightTransparent,
                            labelText: StringsResources.descriptionText(),
                            labelStyle: TextStyle(
                              color: ColorsResources.dark,
                              fontSize: 13.0,
                              fontWeight: FontWeight.bold
                            ),
                            hintText: StringsResources.descriptionText(),
                            hintStyle: TextStyle(
                              color: ColorsResources.dark,
                              fontSize: 13.0,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 51,
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          flex: 13,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(11, 0, 11, 0),
                            child: Container(
                              color: Colors.transparent,
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  prepareCreditCard(transactionCardNumber),
                                  style: const TextStyle(
                                      color: ColorsResources.dark,
                                      fontSize: 17
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 7,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 11, 0),
                            child: Container(
                              color: Colors.transparent,
                              child: Align(
                                alignment: Alignment.center,
                                child: Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: Text(
                                    transactionsData.transactionTime,
                                    style: TextStyle(
                                        color: ColorsResources.dark.withOpacity(0.59),
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      )
    );

  }

  void deleteTransaction(BuildContext context, TransactionsData transactionsData) async {

    String databaseDirectory = await getDatabasesPath();

    String transactionDatabasePath = "${databaseDirectory}/${TransactionsDatabaseInputs.transactionsDatabase()}";

    bool transactionDatabaseExist = await databaseExists(transactionDatabasePath);

    if (transactionDatabaseExist) {

      var databaseQueries = TransactionsDatabaseQueries();

      databaseQueries.queryDeleteTransaction(transactionsData.id, TransactionsDatabaseInputs.databaseTableName, UserInformation.UserId);

      retrieveAllTransactions(context);

      transactionDataUpdated = true;

    }

  }

  void editTransaction(BuildContext context, TransactionsData transactionsData) async {

    bool transactionDataUpdated = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TransactionsEditView(transactionsData: transactionsData)),
    );

    debugPrint("Transaction Data Update => ${transactionDataUpdated}");
    if (transactionDataUpdated) {

      transactionDataUpdated = true;

      retrieveAllTransactions(context);

    }

  }

  void retrieveAllTransactions(BuildContext context) async {

    if (allTransactionsItems.isNotEmpty) {

      allTransactionsItems.clear();

    }

    List<Widget> preparedAllTransactionsItem = [];

    String databaseDirectory = await getDatabasesPath();

    String transactionDatabasePath = "${databaseDirectory}/${TransactionsDatabaseInputs.transactionsDatabase()}";

    bool transactionDatabaseExist = await databaseExists(transactionDatabasePath);

    if (transactionDatabaseExist) {

      var databaseQueries = TransactionsDatabaseQueries();

      allTransactions = await databaseQueries.getAllTransactions(TransactionsDatabaseInputs.databaseTableName, UserInformation.UserId);

      for (var element in allTransactions) {

        preparedAllTransactionsItem.add(outputItem(context, element));

      }

      setState(() {

        allTransactionsItems = preparedAllTransactionsItem;

      });

    }

  }

  void sortTransactionsByTime(BuildContext context,
      List<TransactionsData> inputTransactionsList) {

    if (allTransactionsItems.isNotEmpty) {

      allTransactionsItems.clear();

    }

    inputTransactionsList.sort((a, b) => (a.transactionTime).compareTo(b.transactionTime));

    List<Widget> preparedAllTransactionsItem = [];

    for (var element in inputTransactionsList) {

      preparedAllTransactionsItem.add(outputItem(context, element));

    }

    setState(() {

      allTransactionsItems = preparedAllTransactionsItem;

    });

  }

  void filterByColorTag(BuildContext context,
      List<TransactionsData> inputTransactionsList, Color colorQuery) {

    List<TransactionsData> searchResult = [];

    for (var element in inputTransactionsList) {

      if (element.colorTag == colorQuery.value) {

        searchResult.add(element);

      }

      List<Widget> preparedAllTransactionsItem = [];

      for (var element in searchResult) {

        preparedAllTransactionsItem.add(outputItem(context, element));

      }

      setState(() {

        allTransactionsItems = preparedAllTransactionsItem;

      });

    }

  }

  void searchTransactions(BuildContext context,
      List<TransactionsData> inputTransactionsList, String searchQuery) {

    List<TransactionsData> searchResult = [];

    for (var element in inputTransactionsList) {

      if (element.transactionTitle.contains(searchQuery) ||
          element.transactionDescription.contains(searchQuery) ||
          element.transactionTime.contains(searchQuery) ||
          element.sourceUsername.contains(searchQuery) ||
          element.sourceBankName.contains(searchQuery) ||
          element.sourceCardNumber.contains(searchQuery) ||
          element.targetUsername.contains(searchQuery) ||
          element.targetBankName.contains(searchQuery) ||
          element.targetCardNumber.contains(searchQuery) ||
          element.budgetName.contains(searchQuery)) {

        searchResult.add(element);

      }

    }

    List<Widget> preparedAllTransactionsItem = [];

    for (var element in searchResult) {

      preparedAllTransactionsItem.add(outputItem(context, element));

    }

    setState(() {

      allTransactionsItems = preparedAllTransactionsItem;

    });

  }

  void searchTransactionsInitially(BuildContext context, String searchQuery) async {

    List<TransactionsData> searchResult = [];

    String databaseDirectory = await getDatabasesPath();

    String transactionDatabasePath = "${databaseDirectory}/${TransactionsDatabaseInputs.transactionsDatabase()}";

    bool transactionDatabaseExist = await databaseExists(transactionDatabasePath);

    if (transactionDatabaseExist) {

      var databaseQueries = TransactionsDatabaseQueries();

      allTransactions = await databaseQueries.getAllTransactions(TransactionsDatabaseInputs.databaseTableName, UserInformation.UserId);

      for (var element in allTransactions) {

        if (element.transactionTime.contains(searchQuery) ||
            element.sourceUsername.contains(searchQuery) ||
            element.sourceBankName.contains(searchQuery) ||
            element.sourceCardNumber.contains(searchQuery) ||
            element.targetUsername.contains(searchQuery) ||
            element.targetBankName.contains(searchQuery) ||
            element.targetCardNumber.contains(searchQuery) ||
            element.budgetName.contains(searchQuery)) {

          searchResult.add(element);

        }

      }

      List<Widget> preparedAllTransactionsItem = [];

      for (var element in searchResult) {

        preparedAllTransactionsItem.add(outputItem(context, element));

      }

      setState(() {

        allTransactionsItems = preparedAllTransactionsItem;

      });

    }

  }

  /*
   * Advanced Search
   */
  void startAdvancedSearch(
      String amountMoneyFirst, String amountMoneyLast,
      String timeFirst, String timeLast,
      String targetName) async {
    debugPrint("All Picked Parameters -> First Money: ${amountMoneyFirst} - Last Money: ${amountMoneyLast}");
    debugPrint("All Picked Parameters -> First Time: ${timeFirst} - Last Time: ${timeLast}");
    debugPrint("All Picked Parameters -> Target Username: ${targetName}");

    String databaseDirectory = await getDatabasesPath();

    String transactionDatabasePath = "${databaseDirectory}/${TransactionsDatabaseInputs.transactionsDatabase()}";

    bool transactionDatabaseExist = await databaseExists(transactionDatabasePath);

    if (transactionDatabaseExist) {

      TransactionsDatabaseQueries transactionsDatabaseQueries = TransactionsDatabaseQueries();

      List<TransactionsData> filteredTransactionsData = await transactionsDatabaseQueries.queryTransactionByTargetTimeMoney(amountMoneyFirst, amountMoneyLast, timeFirst, timeLast, targetName,
          TransactionsDatabaseInputs.databaseTableName, UserInformation.UserId);

      List<Widget> preparedAllTransactionsItem = [];

      filteredTransactionsData.forEach((element) {

        preparedAllTransactionsItem.add(outputItem(context, element));

      });

      setState(() {

        allTransactionsItems = preparedAllTransactionsItem;

      });

    }

  }

  void startPartialAdvancedSearchByName(String targetName) async {
    debugPrint("All Picked Parameters -> Target Username: ${targetName}");

    String databaseDirectory = await getDatabasesPath();

    String transactionDatabasePath = "${databaseDirectory}/${TransactionsDatabaseInputs.transactionsDatabase()}";

    bool transactionDatabaseExist = await databaseExists(transactionDatabasePath);

    if (transactionDatabaseExist) {

      TransactionsDatabaseQueries transactionsDatabaseQueries = TransactionsDatabaseQueries();

      List<TransactionsData> filteredTransactionsData = await transactionsDatabaseQueries.queryTransactionByTarget(targetName,
          TransactionsDatabaseInputs.databaseTableName, UserInformation.UserId);

      List<Widget> preparedAllTransactionsItem = [];

      filteredTransactionsData.forEach((element) {

        preparedAllTransactionsItem.add(outputItem(context, element));

      });

      setState(() {

        allTransactionsItems = preparedAllTransactionsItem;

      });

    }

  }

  void startPartialAdvancedSearchByBank(String bankName) async {
    debugPrint("All Picked Parameters -> Bank: ${bankName}");

    String databaseDirectory = await getDatabasesPath();

    String transactionDatabasePath = "${databaseDirectory}/${TransactionsDatabaseInputs.transactionsDatabase()}";

    bool transactionDatabaseExist = await databaseExists(transactionDatabasePath);

    if (transactionDatabaseExist) {

      TransactionsDatabaseQueries transactionsDatabaseQueries = TransactionsDatabaseQueries();

      List<TransactionsData> filteredTransactionsData = await transactionsDatabaseQueries.queryTransactionByBank(bankName,
          TransactionsDatabaseInputs.databaseTableName, UserInformation.UserId);

      List<Widget> preparedAllTransactionsItem = [];

      filteredTransactionsData.forEach((element) {

        preparedAllTransactionsItem.add(outputItem(context, element));

      });

      setState(() {

        allTransactionsItems = preparedAllTransactionsItem;

      });

    }

  }

  void startPartialAdvancedSearchByMoneyAmount(
      String amountMoneyFirst, String amountMoneyLast) async {
    debugPrint("All Picked Parameters -> First Money: ${amountMoneyFirst} - Last Money: ${amountMoneyLast}");

    String databaseDirectory = await getDatabasesPath();

    String transactionDatabasePath = "${databaseDirectory}/${TransactionsDatabaseInputs.transactionsDatabase()}";

    bool transactionDatabaseExist = await databaseExists(transactionDatabasePath);

    if (transactionDatabaseExist) {

      TransactionsDatabaseQueries transactionsDatabaseQueries = TransactionsDatabaseQueries();

      List<TransactionsData> filteredTransactionsData = await transactionsDatabaseQueries.queryTransactionByMoney(amountMoneyFirst, amountMoneyLast,
          TransactionsDatabaseInputs.databaseTableName, UserInformation.UserId);

      List<Widget> preparedAllTransactionsItem = [];

      filteredTransactionsData.forEach((element) {

        preparedAllTransactionsItem.add(outputItem(context, element));

      });

      setState(() {

        allTransactionsItems = preparedAllTransactionsItem;

      });

    }

  }

  void startPartialAdvancedSearchByTimePeriod(
      String timeFirst, String timeLast) async {
    debugPrint("All Picked Parameters -> First Time: ${timeFirst} - Last Time: ${timeLast}");

    String databaseDirectory = await getDatabasesPath();

    String transactionDatabasePath = "${databaseDirectory}/${TransactionsDatabaseInputs.transactionsDatabase()}";

    bool transactionDatabaseExist = await databaseExists(transactionDatabasePath);

    if (transactionDatabaseExist) {

      TransactionsDatabaseQueries transactionsDatabaseQueries = TransactionsDatabaseQueries();

      List<TransactionsData> filteredTransactionsData = await transactionsDatabaseQueries.queryTransactionByTime(timeFirst, timeLast,
          TransactionsDatabaseInputs.databaseTableName, UserInformation.UserId);

      List<Widget> preparedAllTransactionsItem = [];

      filteredTransactionsData.forEach((element) {

        preparedAllTransactionsItem.add(outputItem(context, element));

      });

      setState(() {

        allTransactionsItems = preparedAllTransactionsItem;

      });

    }

  }

  void setupAdvanceSearch() {

    if (allTransactions.isNotEmpty) {

      AnimationController animationController = BottomSheet.createAnimationController(this);
      animationController.duration = const Duration(milliseconds: 159);
      animationController.reverseDuration = const Duration(milliseconds: 159);

      List<String> allTargetsUsername = [];

      List<String> allBanks = [];

      List<String> allMoneyAmount = [];

      allTransactions.forEach((element) {

        allTargetsUsername.add(element.targetUsername);
        allTargetsUsername.add(element.sourceUsername);

        allBanks.add(element.sourceBankName);
        allBanks.add(element.targetBankName);

        allMoneyAmount.add(element.amountMoney);

      });

      allTargetsUsername.sort();

      allMoneyAmount.sort();

      int timeFirst = allTransactions.first.transactionTimeMillisecond;
      int timeLast = allTransactions.last.transactionTimeMillisecond;

      CalendarView calendarViewFirst = CalendarView(darkTheme: true);
      calendarViewFirst.inputDateTime = timeIO.humanReadableFarsi(DateTime.fromMillisecondsSinceEpoch(timeFirst));
      calendarViewFirst.pickedDateTime = DateTime.fromMillisecondsSinceEpoch(timeFirst);

      CalendarView calendarViewLast = CalendarView(darkTheme: true);
      calendarViewLast.inputDateTime = timeIO.humanReadableFarsi(DateTime.fromMillisecondsSinceEpoch(timeLast));
      calendarViewLast.pickedDateTime = DateTime.fromMillisecondsSinceEpoch(timeLast);

      /* Start - Picked Data */
      String pickedTargetUsername = allTargetsUsername.first;

      String pickedBank = allBanks.first;

      String pickedMoneyAmountFirst = allMoneyAmount.first;
      String pickedMoneyAmountLast = allMoneyAmount.last;
      /* End - Picked Data */

      showModalBottomSheet(
        context: context,
        enableDrag: true,
        isDismissible: true,
        shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.all(Radius.circular(19))
        ),
        elevation: 0,
        transitionAnimationController: animationController,
        barrierColor: ColorsResources.applicationDarkGeeksEmpire.withOpacity(0.51),
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {

          return Container(
              height: 357,
              width: double.infinity,
              margin: EdgeInsets.fromLTRB(13, 0, 13, 19),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(19),
                gradient: LinearGradient(
                    colors: [
                      ColorsResources.blueGray,
                      ColorsResources.black,
                    ],
                    begin: FractionalOffset(0.0, 0.0),
                    end: FractionalOffset(1.0, 0.0),
                    stops: [0.0, 1.0],
                    transform: GradientRotation(45),
                    tileMode: TileMode.clamp
                ),
              ),
              child: ListView(
                padding: EdgeInsets.fromLTRB(13, 0, 13, 0),
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.vertical,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 119,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          flex: 1,
                          child:  Padding(
                              padding: const EdgeInsets.fromLTRB(13, 19, 3, 0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Expanded(
                                          flex: 3,
                                          child: Padding(
                                              padding: EdgeInsets.fromLTRB(0, 5, 7, 0),
                                              child: Align(
                                                  alignment: AlignmentDirectional.centerStart,
                                                  child: Material(
                                                      shadowColor: Colors.transparent,
                                                      color: Colors.transparent,
                                                      child: InkWell(
                                                          splashColor: ColorsResources.applicationGeeksEmpire.withOpacity(0.3),
                                                          splashFactory: InkRipple.splashFactory,
                                                          onTap: () {

                                                            startPartialAdvancedSearchByBank(pickedBank);

                                                            Future.delayed(Duration(milliseconds: 379), () {

                                                              Navigator.pop(context);

                                                            });

                                                          },
                                                          child: Image(
                                                            image: AssetImage("go_icon.png"),
                                                            height: 31,
                                                            width: 31,
                                                            color: ColorsResources.light,
                                                          )
                                                      )
                                                  )
                                              )
                                          )
                                      ),
                                      Expanded(
                                          flex: 7,
                                          child: Padding(
                                              padding: EdgeInsets.fromLTRB(0, 5, 7, 0),
                                              child: Align(
                                                alignment: Alignment.centerRight,
                                                child: Text(
                                                  StringsResources.bankText(),
                                                  textAlign: TextAlign.right,
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                      color: ColorsResources.lightestBlue,
                                                      fontSize: 15
                                                  ),
                                                ),
                                              )
                                          )
                                      )
                                    ],
                                  ),
                                  Align(
                                      alignment: AlignmentDirectional.topCenter,
                                      child: Directionality(
                                        textDirection: TextDirection.rtl,
                                        child: DropdownButtonFormField<String>(
                                          isDense: true,
                                          elevation: 7,
                                          focusColor: ColorsResources.applicationDarkGeeksEmpire,
                                          dropdownColor: ColorsResources.dark,
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
                                            fillColor: ColorsResources.light.withOpacity(0.1),
                                            focusColor: ColorsResources.dark,
                                          ),
                                          value: allBanks.first,
                                          items: allBanks.toSet().toList().map<DropdownMenuItem<String>>((String value) {

                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: SizedBox(
                                                height: 31,
                                                child: Padding(
                                                  padding: const EdgeInsets.fromLTRB(0, 0, 11, 0),
                                                  child: Align(
                                                    alignment: AlignmentDirectional.center,
                                                    child: Text(
                                                      value,
                                                      maxLines: 1,
                                                      style: TextStyle(
                                                        color: ColorsResources.light.withOpacity(0.79),
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (value) {

                                            pickedBank = value ?? allBanks.first;

                                          },
                                        ),
                                      )
                                  ),
                                ],
                              )
                          )
                        ),
                        Expanded(
                          flex: 1,
                          child: Padding(
                              padding: const EdgeInsets.fromLTRB(13, 19, 13, 0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Expanded(
                                          flex: 3,
                                          child: Padding(
                                              padding: EdgeInsets.fromLTRB(0, 5, 7, 0),
                                              child: Align(
                                                  alignment: AlignmentDirectional.centerStart,
                                                  child: Material(
                                                      shadowColor: Colors.transparent,
                                                      color: Colors.transparent,
                                                      child: InkWell(
                                                          splashColor: ColorsResources.applicationGeeksEmpire.withOpacity(0.3),
                                                          splashFactory: InkRipple.splashFactory,
                                                          onTap: () {

                                                            startPartialAdvancedSearchByName(pickedTargetUsername);

                                                            Future.delayed(Duration(milliseconds: 379), () {

                                                              Navigator.pop(context);

                                                            });

                                                          },
                                                          child: Image(
                                                            image: AssetImage("go_icon.png"),
                                                            height: 31,
                                                            width: 31,
                                                            color: ColorsResources.light,
                                                          )
                                                      )
                                                  )
                                              )
                                          )
                                      ),
                                      Expanded(
                                          flex: 7,
                                          child: Padding(
                                              padding: EdgeInsets.fromLTRB(0, 5, 7, 0),
                                              child: Align(
                                                alignment: Alignment.centerRight,
                                                child: Text(
                                                  StringsResources.transactionTargetName(),
                                                  textAlign: TextAlign.right,
                                                  style: TextStyle(
                                                      color: ColorsResources.lightestBlue,
                                                      fontSize: 15
                                                  ),
                                                ),
                                              )
                                          )
                                      )
                                    ],
                                  ),
                                  Align(
                                      alignment: AlignmentDirectional.topCenter,
                                      child: Directionality(
                                        textDirection: TextDirection.rtl,
                                        child: DropdownButtonFormField<String>(
                                          isDense: true,
                                          elevation: 7,
                                          focusColor: ColorsResources.applicationDarkGeeksEmpire,
                                          dropdownColor: ColorsResources.dark,
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
                                              fillColor: ColorsResources.light.withOpacity(0.1),
                                              focusColor: ColorsResources.dark
                                          ),
                                          value: allTargetsUsername.first,
                                          items: allTargetsUsername.toSet().toList().map<DropdownMenuItem<String>>((String value) {

                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: SizedBox(
                                                height: 31,
                                                child: Padding(
                                                  padding: const EdgeInsets.fromLTRB(0, 0, 11, 0),
                                                  child: Align(
                                                    alignment:
                                                    AlignmentDirectional.center,
                                                    child: Text(
                                                      value,
                                                      maxLines: 1,
                                                      style: TextStyle(
                                                        color: ColorsResources.light.withOpacity(0.79),
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (value) {

                                            pickedTargetUsername = value ?? allTargetsUsername.first;

                                          },
                                        ),
                                      )
                                  ),
                                ],
                              )
                          )
                        )
                      ],
                    )
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 119,
                    child: Padding(
                        padding: const EdgeInsets.fromLTRB(13, 19, 13, 0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                    flex: 3,
                                    child: Padding(
                                        padding: EdgeInsets.fromLTRB(0, 5, 7, 0),
                                        child: Align(
                                            alignment: AlignmentDirectional.centerStart,
                                            child: Material(
                                                shadowColor: Colors.transparent,
                                                color: Colors.transparent,
                                                child: InkWell(
                                                    splashColor: ColorsResources.applicationGeeksEmpire.withOpacity(0.3),
                                                    splashFactory: InkRipple.splashFactory,
                                                    onTap: () {

                                                      startPartialAdvancedSearchByMoneyAmount(pickedMoneyAmountFirst, pickedMoneyAmountLast);

                                                      Future.delayed(Duration(milliseconds: 379), () {

                                                        Navigator.pop(context);

                                                      });

                                                    },
                                                    child: Image(
                                                      image: AssetImage("go_icon.png"),
                                                      height: 31,
                                                      width: 31,
                                                      color: ColorsResources.light,
                                                    )
                                                )
                                            )
                                        )
                                    )
                                ),
                                Expanded(
                                    flex: 7,
                                    child: Padding(
                                        padding: EdgeInsets.fromLTRB(0, 5, 7, 0),
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            StringsResources.transactionAmountHint(),
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                                color: ColorsResources.lightestBlue,
                                                fontSize: 15
                                            ),
                                          ),
                                        )
                                    )
                                )
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  flex: 7,
                                  child: Align(
                                      alignment: AlignmentDirectional.topCenter,
                                      child: Directionality(
                                        textDirection: TextDirection.rtl,
                                        child: DropdownButtonFormField<String>(
                                          isDense: true,
                                          elevation: 7,
                                          focusColor: ColorsResources.applicationDarkGeeksEmpire,
                                          dropdownColor: ColorsResources.dark,
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
                                              fillColor: ColorsResources.light.withOpacity(0.1),
                                              focusColor: ColorsResources.dark
                                          ),
                                          value: allMoneyAmount.last,
                                          items: allMoneyAmount.toSet().toList().map<DropdownMenuItem<String>>((String value) {

                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: SizedBox(
                                                height: 31,
                                                child: Padding(
                                                  padding: const EdgeInsets.fromLTRB(0, 0, 11, 0),
                                                  child: Align(
                                                    alignment:
                                                    AlignmentDirectional.center,
                                                    child: Text(
                                                      value,
                                                      maxLines: 1,
                                                      style: TextStyle(
                                                        color: ColorsResources.light.withOpacity(0.79),
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (value) {

                                            pickedMoneyAmountFirst = value ?? allMoneyAmount.first;

                                          },
                                        ),
                                      )
                                  ),
                                ),
                                Expanded(
                                    flex: 1,
                                    child: Align(
                                        alignment: AlignmentDirectional.center,
                                        child: Text(
                                          StringsResources.toText(),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: ColorsResources.light
                                          ),
                                        )
                                    )
                                ),
                                Expanded(
                                  flex: 7,
                                  child: Align(
                                      alignment: AlignmentDirectional.topCenter,
                                      child: Directionality(
                                        textDirection: TextDirection.rtl,
                                        child: DropdownButtonFormField<String>(
                                          isDense: true,
                                          elevation: 7,
                                          focusColor: ColorsResources.applicationDarkGeeksEmpire,
                                          dropdownColor: ColorsResources.dark,
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
                                              fillColor: ColorsResources.light.withOpacity(0.1),
                                              focusColor: ColorsResources.dark
                                          ),
                                          value: allMoneyAmount.first,
                                          items: allMoneyAmount.toSet().toList().map<DropdownMenuItem<String>>((String value) {

                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: SizedBox(
                                                height: 31,
                                                child: Padding(
                                                  padding: const EdgeInsets.fromLTRB(0, 0, 11, 0),
                                                  child: Align(
                                                    alignment:
                                                    AlignmentDirectional.center,
                                                    child: Text(
                                                      value,
                                                      maxLines: 1,
                                                      style: TextStyle(
                                                        color: ColorsResources.light.withOpacity(0.79),
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (value) {

                                            pickedMoneyAmountLast = value ?? allMoneyAmount.last;

                                          },
                                        ),
                                      )
                                  ),
                                ),
                              ],
                            )
                          ],
                        )
                    ),
                  ),
                  SizedBox(
                      height: 157,
                      width: double.infinity,
                      child: Padding(
                          padding: const EdgeInsets.fromLTRB(13, 13, 13, 19),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                      flex: 3,
                                      child: Padding(
                                          padding: EdgeInsets.fromLTRB(0, 5, 7, 0),
                                          child: Align(
                                              alignment: AlignmentDirectional.centerStart,
                                              child: Material(
                                                  shadowColor: Colors.transparent,
                                                  color: Colors.transparent,
                                                  child: InkWell(
                                                      splashColor: ColorsResources.applicationGeeksEmpire.withOpacity(0.3),
                                                      splashFactory: InkRipple.splashFactory,
                                                      onTap: () {

                                                        startPartialAdvancedSearchByTimePeriod(calendarViewFirst.pickedDateTime.microsecondsSinceEpoch.toString(), calendarViewLast.pickedDateTime.microsecondsSinceEpoch.toString());

                                                        Future.delayed(Duration(milliseconds: 379), () {

                                                          Navigator.pop(context);

                                                        });

                                                      },
                                                      child: Image(
                                                        image: AssetImage("go_icon.png"),
                                                        height: 31,
                                                        width: 31,
                                                        color: ColorsResources.light,
                                                      )
                                                  )
                                              )
                                          )
                                      )
                                  ),
                                  Expanded(
                                      flex: 7,
                                      child: Padding(
                                          padding: EdgeInsets.fromLTRB(0, 5, 7, 0),
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              StringsResources.transactionPeriod(),
                                              textAlign: TextAlign.right,
                                              style: TextStyle(
                                                  color: ColorsResources.lightestBlue,
                                                  fontSize: 15
                                              ),
                                            ),
                                          )
                                      )
                                  )
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                      flex: 7,
                                      child: calendarViewLast
                                  ),
                                  Expanded(
                                      flex: 1,
                                      child: Align(
                                          alignment: AlignmentDirectional.center,
                                          child: Text(
                                            StringsResources.toText(),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: ColorsResources.light
                                            ),
                                          )
                                      )
                                  ),
                                  Expanded(
                                      flex: 7,
                                      child: calendarViewFirst
                                  )
                                ],
                              )
                            ],
                          )
                      )
                  ),
                  SizedBox(
                      height: 79,
                      width: double.infinity,
                      child: Padding(
                          padding: EdgeInsets.fromLTRB(13, 13, 13, 19),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(51.0),
                            child: Material(
                              shadowColor: Colors.transparent,
                              color: Colors.transparent,
                              child: InkWell(
                                splashColor: ColorsResources.applicationGeeksEmpire.withOpacity(0.3),
                                splashFactory: InkRipple.splashFactory,
                                onTap: () {

                                  startAdvancedSearch(
                                      pickedMoneyAmountFirst,
                                      pickedMoneyAmountLast,
                                      calendarViewFirst.pickedDateTime.microsecondsSinceEpoch.toString(),
                                      calendarViewLast.pickedDateTime.microsecondsSinceEpoch.toString(),
                                      pickedTargetUsername
                                  );

                                  Future.delayed(Duration(milliseconds: 379), () {

                                    Navigator.pop(context);

                                  });

                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      border: Border(
                                          top: BorderSide(
                                            color: ColorsResources.lightBlue.withOpacity(0.3),
                                            width: 1,
                                          ),
                                          bottom: BorderSide(
                                            color: ColorsResources.lightBlue.withOpacity(0.3),
                                            width: 1,
                                          ),
                                          left: BorderSide(
                                            color: ColorsResources.lightBlue.withOpacity(0.3),
                                            width: 1,
                                          ),
                                          right: BorderSide(
                                            color: ColorsResources.lightBlue.withOpacity(0.3),
                                            width: 1,
                                          )
                                      ),
                                      borderRadius: BorderRadius.circular(51),
                                      color: ColorsResources.applicationGeeksEmpire.withOpacity(0.1)
                                  ),
                                  child: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        StringsResources.applyAdvancedSearch(),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 17,
                                            color: ColorsResources.light,
                                            shadows: [
                                              Shadow(
                                                  color: ColorsResources.light,
                                                  blurRadius: 7,
                                                  offset: Offset(0, 0)
                                              )
                                            ]
                                        ),
                                      )
                                  )
                                ),
                              ),
                            ),
                          )
                      )
                  )
                ],
              )
          );
        }
      );

    }

  }

}