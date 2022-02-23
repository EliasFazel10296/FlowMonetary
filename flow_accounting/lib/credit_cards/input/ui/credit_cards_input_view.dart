/*
 * Copyright © 2022 By Geeks Empire.
 *
 * Created by Elias Fazel
 * Last modified 1/23/22, 4:13 AM
 *
 * Licensed Under MIT License.
 * https://opensource.org/licenses/MIT
 */

import 'dart:math';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:blur/blur.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flow_accounting/credit_cards/database/io/inputs.dart';
import 'package:flow_accounting/credit_cards/database/io/queries.dart';
import 'package:flow_accounting/credit_cards/database/structures/tables_structure.dart';
import 'package:flow_accounting/resources/ColorsResources.dart';
import 'package:flow_accounting/resources/StringsResources.dart';
import 'package:flow_accounting/transactions/output/ui/transactions_output_view.dart';
import 'package:flow_accounting/utils/colors/color_extractor.dart';
import 'package:flow_accounting/utils/colors/color_selector.dart';
import 'package:flow_accounting/utils/extensions/BankLogos.dart';
import 'package:flow_accounting/utils/navigations/navigations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fluttertoast/fluttertoast.dart';

TextEditingController creditCardBankNameController = TextEditingController();

TextEditingController creditCardNameHolderController = TextEditingController();

TextEditingController creditCardNumberController = TextEditingController();

TextEditingController creditCardYearController = TextEditingController();
TextEditingController creditCardMonthController = TextEditingController();

TextEditingController creditCardBalanceController = TextEditingController();

TextEditingController creditCardCvvController = TextEditingController();

int creditCardColorTag = ColorsResources.white.value;

ImageProvider? bankLogoImageProvider;

CachedNetworkImage? bankLogoImageView = CachedNetworkImage(
  imageUrl: generateBankLogoUrl(""),
  height: 51,
  width: 51,
  fit: BoxFit.contain,
);

Color dominantColorForFrontLayout = ColorsResources.dark;
Color dominantColorForBackLayout = ColorsResources.white;

class CreditCardsInputView extends StatefulWidget {

  CreditCardsData creditCardsData;

  CreditCardsInputView({Key? key, required this.creditCardsData}) : super(key: key);

  @override
  _CreditCardsInputViewState createState() => _CreditCardsInputViewState();
}
class _CreditCardsInputViewState extends State<CreditCardsInputView> with TickerProviderStateMixin {

  FocusNode focusNodeCvv = FocusNode();

  bool showCardsBack = false;

  AnimationController? animationController = null;

  bool creditCardDataUpdated = false;

  @override
  void initState() {

    creditCardBankNameController.text = widget.creditCardsData.bankName.isEmpty ? StringsResources.creditCardsBankName : widget.creditCardsData.bankName;
    creditCardNameHolderController.text = widget.creditCardsData.cardHolderName.isEmpty ? StringsResources.creditCardsNameHolder : widget.creditCardsData.cardHolderName;

    creditCardNumberController.text = widget.creditCardsData.cardNumber.isEmpty ? "0000000000000000" : widget.creditCardsData.cardNumber;

    creditCardYearController.text = widget.creditCardsData.cardExpiry.isEmpty ? "00" : widget.creditCardsData.cardExpiry.split("/")[0];
    creditCardMonthController.text = widget.creditCardsData.cardExpiry.isEmpty ? "00" : widget.creditCardsData.cardExpiry.split("/")[1];

    creditCardBalanceController.text = widget.creditCardsData.cardBalance.isEmpty ? "0" : widget.creditCardsData.cardBalance;

    creditCardCvvController.text = widget.creditCardsData.cvv.isEmpty ? "000" : widget.creditCardsData.cvv;

    creditCardColorTag = widget.creditCardsData.colorTag;

    bankLogoImageView = CachedNetworkImage(
      imageUrl: generateBankLogoUrl(widget.creditCardsData.bankName),
      height: 51,
      width: 51,
      imageBuilder: (context, imageProvider) {

        bankLogoImageProvider = imageProvider;

        extractBankDominantColor(bankLogoImageProvider);

        return Image(
          image: imageProvider,
        );
      },
    );

    super.initState();

    BackButtonInterceptor.add(aInterceptor);

    animationController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this
    );

    focusNodeCvv.addListener(() {

      focusNodeCvv.hasFocus ?
        animationController?.forward() : animationController?.reverse();

    });

  }

  @override
  void dispose() {

    BackButtonInterceptor.remove(aInterceptor);

    super.dispose();
  }

  bool aInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {

    Navigator.pop(context, creditCardDataUpdated);

    return true;
  }

  @override
  Widget build(BuildContext context) {

    ColorSelectorView colorSelectorView = ColorSelectorView();
    colorSelectorView.inputColor = (widget.creditCardsData.colorTag == Colors.transparent.value) ? ColorsResources.primaryColor : Color(widget.creditCardsData.colorTag);

    return MaterialApp (
      debugShowCheckedModeBanner: false,
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
                          StringsResources.featureCreditCardTitle,
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
                          StringsResources.featureCreditCardDescription,
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
                      Slidable(
                        closeOnScroll: true,
                        endActionPane: ActionPane(
                          motion: const DrawerMotion(),
                          children: [
                            SlidableAction(
                              flex: 3,
                              onPressed: (BuildContext context) {

                                deleteCreditCards(context, widget.creditCardsData);

                              },
                              backgroundColor: Colors.transparent,
                              foregroundColor: ColorsResources.gameGeeksEmpire,
                              icon: Icons.delete_rounded,
                              label: StringsResources.deleteText,
                              autoClose: true,
                            ),
                            SlidableAction(
                              flex: 7,
                              onPressed: (BuildContext context) {

                                NavigationProcess().goTo(context, TransactionsOutputView(initialSearchQuery: widget.creditCardsData.cardNumber));

                              },
                              backgroundColor: Colors.transparent,
                              foregroundColor: ColorsResources.applicationGeeksEmpire,
                              icon: Icons.money_rounded,
                              label: StringsResources.transactionAll,
                              autoClose: true,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 13, 0, 33),
                          child: creditCardWidgetItem(),
                        ),
                      ),
                      const Divider(
                        height: 19,
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

                                          return ListTile(title: Directionality(
                                            textDirection: TextDirection.rtl,
                                            child: Text(
                                              suggestion,
                                              style: const TextStyle(
                                                  color: ColorsResources.darkTransparent,
                                                  fontSize: 15
                                              ),
                                            ),
                                          ));
                                        },
                                        onSuggestionSelected: (suggestion) {

                                          setState(() {

                                            bankLogoImageView = CachedNetworkImage(
                                              imageUrl: generateBankLogoUrl(suggestion.toString()),
                                              imageBuilder: (context, imageProvider) {

                                                bankLogoImageProvider = imageProvider;

                                                extractBankDominantColor(bankLogoImageProvider);

                                                return Image(
                                                  image: imageProvider,
                                                );
                                              },
                                            );

                                          });

                                          creditCardBankNameController.text = suggestion.toString();

                                        },
                                        suggestionsBoxDecoration: SuggestionsBoxDecoration(
                                            elevation: 7,
                                            color: ColorsResources.light,
                                            shadowColor: ColorsResources.darkTransparent,
                                            borderRadius: BorderRadius.circular(17)
                                        ),
                                        textFieldConfiguration: TextFieldConfiguration(
                                          controller: creditCardBankNameController,
                                          autofocus: false,
                                          maxLines: 1,
                                          cursorColor: ColorsResources.primaryColor,
                                          decoration: const InputDecoration(
                                            alignLabelWithHint: true,
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
                                            enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(color: Colors.blueGrey, width: 1.0),
                                                borderRadius: BorderRadius.only(
                                                    topLeft: Radius.circular(13),
                                                    topRight: Radius.circular(13),
                                                    bottomLeft: Radius.circular(13),
                                                    bottomRight: Radius.circular(13)
                                                ),
                                                gapPadding: 5
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(color: Colors.lightBlueAccent, width: 1.0),
                                                borderRadius: BorderRadius.only(
                                                    topLeft: Radius.circular(13),
                                                    topRight: Radius.circular(13),
                                                    bottomLeft: Radius.circular(13),
                                                    bottomRight: Radius.circular(13)
                                                ),
                                                gapPadding: 5
                                            ),
                                            errorBorder: OutlineInputBorder(
                                                borderSide: BorderSide(color: Colors.red, width: 1.0),
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
                                            labelText: StringsResources.creditCardsBankName,
                                            labelStyle: TextStyle(
                                                color: ColorsResources.dark,
                                                fontSize: 17.0
                                            ),
                                            hintText: StringsResources.creditCardsBankNameHint,
                                            hintStyle: TextStyle(
                                                color: ColorsResources.darkTransparent,
                                                fontSize: 17.0
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
                                    child: TextField(
                                      controller: creditCardNameHolderController,
                                      textAlign: TextAlign.center,
                                      textDirection: TextDirection.ltr,
                                      textAlignVertical: TextAlignVertical.bottom,
                                      maxLines: 1,
                                      cursorColor: ColorsResources.primaryColor,
                                      autocorrect: true,
                                      autofocus: false,
                                      keyboardType: TextInputType.name,
                                      decoration: const InputDecoration(
                                        alignLabelWithHint: true,
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
                                        enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.blueGrey, width: 1.0),
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(13),
                                                topRight: Radius.circular(13),
                                                bottomLeft: Radius.circular(13),
                                                bottomRight: Radius.circular(13)
                                            ),
                                            gapPadding: 5
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.lightBlueAccent, width: 1.0),
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(13),
                                                topRight: Radius.circular(13),
                                                bottomLeft: Radius.circular(13),
                                                bottomRight: Radius.circular(13)
                                            ),
                                            gapPadding: 5
                                        ),
                                        errorBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.red, width: 1.0),
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
                                        labelText: StringsResources.creditCardsNameHolder,
                                        labelStyle: TextStyle(
                                            color: ColorsResources.dark,
                                            fontSize: 17.0
                                        ),
                                        hintText: StringsResources.creditCardsNameHolderHint,
                                        hintStyle: TextStyle(
                                            color: ColorsResources.darkTransparent,
                                            fontSize: 17.0
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
                                      controller: creditCardNumberController,
                                      textAlign: TextAlign.center,
                                      textDirection: TextDirection.rtl,
                                      textAlignVertical: TextAlignVertical.bottom,
                                      maxLines: 1,
                                      cursorColor: ColorsResources.primaryColor,
                                      autocorrect: true,
                                      autofocus: false,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        LengthLimitingTextInputFormatter(16)
                                      ],
                                      decoration: const InputDecoration(
                                        alignLabelWithHint: true,
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
                                        enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.blueGrey, width: 1.0),
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(13),
                                                topRight: Radius.circular(13),
                                                bottomLeft: Radius.circular(13),
                                                bottomRight: Radius.circular(13)
                                            ),
                                            gapPadding: 5
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.lightBlueAccent, width: 1.0),
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(13),
                                                topRight: Radius.circular(13),
                                                bottomLeft: Radius.circular(13),
                                                bottomRight: Radius.circular(13)
                                            ),
                                            gapPadding: 5
                                        ),
                                        errorBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.red, width: 1.0),
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
                                        labelText: StringsResources.transactionTargetCard,
                                        labelStyle: TextStyle(
                                            color: ColorsResources.dark,
                                            fontSize: 17.0
                                        ),
                                        hintText: StringsResources.transactionTargetCardHint,
                                        hintStyle: TextStyle(
                                            color: ColorsResources.darkTransparent,
                                            fontSize: 17.0
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
                                      focusNode: focusNodeCvv,
                                      controller: creditCardCvvController,
                                      textAlign: TextAlign.center,
                                      textDirection: TextDirection.ltr,
                                      textAlignVertical: TextAlignVertical.bottom,
                                      maxLines: 1,
                                      cursorColor: ColorsResources.primaryColor,
                                      autocorrect: true,
                                      autofocus: false,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        LengthLimitingTextInputFormatter(4)
                                      ],
                                      decoration: const InputDecoration(
                                        alignLabelWithHint: true,
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
                                        enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.blueGrey, width: 1.0),
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(13),
                                                topRight: Radius.circular(13),
                                                bottomLeft: Radius.circular(13),
                                                bottomRight: Radius.circular(13)
                                            ),
                                            gapPadding: 5
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.lightBlueAccent, width: 1.0),
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(13),
                                                topRight: Radius.circular(13),
                                                bottomLeft: Radius.circular(13),
                                                bottomRight: Radius.circular(13)
                                            ),
                                            gapPadding: 5
                                        ),
                                        errorBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.red, width: 1.0),
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
                                        labelText: StringsResources.creditCardCvv,
                                        labelStyle: TextStyle(
                                            color: ColorsResources.dark,
                                            fontSize: 17.0
                                        ),
                                        hintText: StringsResources.creditCardCvvHint,
                                        hintStyle: TextStyle(
                                            color: ColorsResources.darkTransparent,
                                            fontSize: 17.0
                                        ),
                                      ),
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
                                    child: TextField(
                                      controller: creditCardYearController,
                                      textAlign: TextAlign.center,
                                      textDirection: TextDirection.ltr,
                                      textAlignVertical: TextAlignVertical.bottom,
                                      maxLines: 1,
                                      cursorColor: ColorsResources.primaryColor,
                                      autocorrect: true,
                                      autofocus: false,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        LengthLimitingTextInputFormatter(2)
                                      ],
                                      decoration: const InputDecoration(
                                        alignLabelWithHint: true,
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
                                        enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.blueGrey, width: 1.0),
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(13),
                                                topRight: Radius.circular(13),
                                                bottomLeft: Radius.circular(13),
                                                bottomRight: Radius.circular(13)
                                            ),
                                            gapPadding: 5
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.lightBlueAccent, width: 1.0),
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(13),
                                                topRight: Radius.circular(13),
                                                bottomLeft: Radius.circular(13),
                                                bottomRight: Radius.circular(13)
                                            ),
                                            gapPadding: 5
                                        ),
                                        errorBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.red, width: 1.0),
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
                                        labelText: StringsResources.creditCardExpiryYear,
                                        labelStyle: TextStyle(
                                            color: ColorsResources.dark,
                                            fontSize: 17.0
                                        ),
                                        hintText: StringsResources.creditCardExpiryYearHint,
                                        hintStyle: TextStyle(
                                            color: ColorsResources.darkTransparent,
                                            fontSize: 17.0
                                        ),
                                      ),
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
                                    child: TextField(
                                      controller: creditCardMonthController,
                                      textAlign: TextAlign.center,
                                      textDirection: TextDirection.ltr,
                                      textAlignVertical: TextAlignVertical.bottom,
                                      maxLines: 1,
                                      cursorColor: ColorsResources.primaryColor,
                                      autocorrect: true,
                                      autofocus: false,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        LengthLimitingTextInputFormatter(2)
                                      ],
                                      decoration: const InputDecoration(
                                        alignLabelWithHint: true,
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
                                        enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.blueGrey, width: 1.0),
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(13),
                                                topRight: Radius.circular(13),
                                                bottomLeft: Radius.circular(13),
                                                bottomRight: Radius.circular(13)
                                            ),
                                            gapPadding: 5
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.lightBlueAccent, width: 1.0),
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(13),
                                                topRight: Radius.circular(13),
                                                bottomLeft: Radius.circular(13),
                                                bottomRight: Radius.circular(13)
                                            ),
                                            gapPadding: 5
                                        ),
                                        errorBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.red, width: 1.0),
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
                                        labelText: StringsResources.creditCardExpiryMonth,
                                        labelStyle: TextStyle(
                                            color: ColorsResources.dark,
                                            fontSize: 17.0
                                        ),
                                        hintText: StringsResources.creditCardExpiryMonthHint,
                                        hintStyle: TextStyle(
                                            color: ColorsResources.darkTransparent,
                                            fontSize: 17.0
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
                                      controller: creditCardBalanceController,
                                      textAlign: TextAlign.center,
                                      textDirection: TextDirection.ltr,
                                      textAlignVertical: TextAlignVertical.bottom,
                                      maxLines: 1,
                                      cursorColor: ColorsResources.primaryColor,
                                      autocorrect: true,
                                      autofocus: false,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        alignLabelWithHint: true,
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
                                        enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.blueGrey, width: 1.0),
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(13),
                                                topRight: Radius.circular(13),
                                                bottomLeft: Radius.circular(13),
                                                bottomRight: Radius.circular(13)
                                            ),
                                            gapPadding: 5
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.lightBlueAccent, width: 1.0),
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(13),
                                                topRight: Radius.circular(13),
                                                bottomLeft: Radius.circular(13),
                                                bottomRight: Radius.circular(13)
                                            ),
                                            gapPadding: 5
                                        ),
                                        errorBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.red, width: 1.0),
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
                                        labelText: StringsResources.creditCardBalance,
                                        labelStyle: TextStyle(
                                            color: ColorsResources.dark,
                                            fontSize: 17.0
                                        ),
                                        hintText: StringsResources.creditCardBalanceHint,
                                        hintStyle: TextStyle(
                                            color: ColorsResources.darkTransparent,
                                            fontSize: 17.0
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
                        height: 37,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: const [
                            Expanded(
                              flex: 1,
                              child: Padding(
                                  padding: EdgeInsets.fromLTRB(13, 0, 13, 0),
                                  child: Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: Text(
                                      StringsResources.colorSelectorHint,
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

                        Navigator.pop(context, creditCardDataUpdated);

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
                  left: 71,
                  right: 71,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(51.0),
                    child: Material(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(51)),
                      shadowColor: Colors.transparent,
                      color: Colors.transparent,
                      child: InkWell(
                        splashColor: ColorsResources.applicationGeeksEmpire.withOpacity(0.5),
                        splashFactory: InkRipple.splashFactory,
                        onTap: () {

                          int timeNow = DateTime.now().millisecondsSinceEpoch;

                          int id = widget.creditCardsData.id == 0 ? timeNow : widget.creditCardsData.id;

                          CreditCardsData creditCardsData = CreditCardsData(
                              id: id,
                              cardNumber: creditCardNumberController.text,
                              cardExpiry: "${creditCardYearController.text}/${creditCardMonthController.text}",
                              cardHolderName: creditCardNameHolderController.text,
                              cvv: creditCardCvvController.text,
                              bankName: creditCardBankNameController.text,
                              cardBalance: creditCardBalanceController.text,
                              colorTag: colorSelectorView.selectedColor.value
                          );

                          CreditCardsDatabaseInputs databaseInputs = CreditCardsDatabaseInputs();

                          if (widget.creditCardsData.id == 0) {

                            databaseInputs.insertCreditCardsData(creditCardsData, CreditCardsDatabaseInputs.databaseTableName);

                          } else {

                            databaseInputs.updateCreditCardsData(creditCardsData, CreditCardsDatabaseInputs.databaseTableName);

                          }

                          Fluttertoast.showToast(
                              msg: StringsResources.updatedText,
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 1,
                              backgroundColor: ColorsResources.lightTransparent,
                              textColor: ColorsResources.dark,
                              fontSize: 16.0
                          );

                          creditCardDataUpdated = true;

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
                                const SizedBox(
                                    width: double.infinity,
                                    height: 53,
                                    child: Align(
                                      alignment: AlignmentDirectional.center,
                                      child: Text(
                                        StringsResources.submitText,
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
                                )
                              ],
                            )
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget creditCardWidgetItem() {

    Animation<double>? moveToBack = TweenSequence<double>([
      TweenSequenceItem<double>(tween: Tween<double>(begin: 0.0, end: pi / 2).chain(CurveTween(curve: Curves.easeInBack)), weight: 50.0),
      TweenSequenceItem<double>(tween: ConstantTween<double>(pi / 2), weight: 50.0)
    ]).animate(animationController!);

    Animation<double>? moveToFront = TweenSequence<double>([
      TweenSequenceItem<double>(tween: ConstantTween<double>(pi / 2), weight: 50.0,),
      TweenSequenceItem<double>(tween: Tween<double>(begin: -pi / 2, end: 0.0).chain(CurveTween(curve: Curves.easeOutBack)), weight: 50.0,),
    ],).animate(animationController!);

    return Padding(
      padding: const EdgeInsets.fromLTRB(19, 0, 19, 0),
      child: SizedBox(
          height: 233,
          width: 391,
          child: GestureDetector(
            onTap: () {

              if (showCardsBack) {
                animationController?.reverse();
              } else {
                animationController?.forward();
              }

              showCardsBack = !showCardsBack;

            },
            child: Container(
              color: Colors.transparent,
              alignment: AlignmentDirectional.center,
              child: Stack(
                children: [
                  AwesomeCard(
                    animation: moveToBack,
                    child: CreditCardFrontLayout(creditCardsData: widget.creditCardsData),
                  ),
                  AwesomeCard(
                    animation: moveToFront,
                    child: CreditCardBackLayout(creditCardsData: widget.creditCardsData),
                  ),
                ],
              ),
            ),
          )
      ),
    );

  }

  Future<List<String>> getBanksNames() async {

    return StringsResources.listOfBanksIran;
  }

  void extractBankDominantColor(ImageProvider? bankLogoImageProvider) async {

    if (bankLogoImageProvider != null) {

      Future<Color?> bankDominantColor = imageDominantColor(bankLogoImageProvider);

      bankDominantColor.then((extractedColor) {

        if (extractedColor != null) {

          setState(() {

            dominantColorForFrontLayout = extractedColor;
            dominantColorForBackLayout = extractedColor;

          });

        }

      });

    }

  }

  void deleteCreditCards(BuildContext context, CreditCardsData creditCardsData) async {

    CreditCardsDatabaseQueries creditCardsDatabaseQueries = CreditCardsDatabaseQueries();

    creditCardsDatabaseQueries.queryDeleteCreditCard(creditCardsData.id, CreditCardsDatabaseInputs.databaseTableName);

    Navigator.pop(context);

  }

}

class AwesomeCard extends StatelessWidget {

  final Animation<double>? animation;

  final Widget child;

  const AwesomeCard({Key? key, required this.animation, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation!,
      builder: (BuildContext context, Widget? child) {
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(animation!.value),
          alignment: Alignment.center,
          child: this.child,
        );
      },
    );
  }
}

class CreditCardFrontLayout extends StatefulWidget {

  CreditCardsData creditCardsData;

  CreditCardFrontLayout({Key? key, required this.creditCardsData}) :super(key: key);

  @override
  State<CreditCardFrontLayout> createState() => _CreditCardFrontLayout();

}
class _CreditCardFrontLayout extends State<CreditCardFrontLayout> {

  bool frontLayoutDecorated = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return frontCardLayout(widget.creditCardsData.cardNumber,
        widget.creditCardsData.cardExpiry,
        widget.creditCardsData.cardHolderName,
        widget.creditCardsData.cvv);
  }

  Widget frontCardLayout(String cardNumber, String cardExpiry, String cardHolderName, String cvv) {

    return Container(
      height: 279,
      width: double.infinity,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: dominantColorForFrontLayout.withOpacity(0.37),
            blurRadius: 13.0,
            spreadRadius: 0.3,
            offset: const Offset(3.9, 3.9),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13.0),
        child: Stack(
          children: <Widget> [
            Container(
              width: double.maxFinite,
              height: double.maxFinite,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(17), topRight: Radius.circular(17), bottomLeft: Radius.circular(17), bottomRight: Radius.circular(17)),
                gradient: LinearGradient(
                    colors: [
                      ColorsResources.light,
                      ColorsResources.white,
                    ],
                    begin: FractionalOffset(0.0, 0.0),
                    end: FractionalOffset(1.0, 0.0),
                    stops: [0.0, 1.0],
                    transform: GradientRotation(45),
                    tileMode: TileMode.clamp),
              ),
            ),
            Image(
              image: AssetImage(generateBackgroundPattern()),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            Column(
              children: [
                Container(
                  color: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(7, 11, 11, 0),
                    child: SizedBox(
                      height: 59,
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                              flex: 3,
                              child: Align(
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(7, 0, 7, 0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Color(creditCardColorTag),
                                        shape: BoxShape.circle
                                    ),
                                    child: const SizedBox(
                                      height: 37,
                                      width: 37,
                                    ),
                                  ),
                                ),
                              )
                          ),
                          Expanded(
                              flex: 13,
                              child: Padding(
                                  padding: const EdgeInsets.fromLTRB(0, 0, 17, 0),
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: TextField(
                                      controller: creditCardBankNameController,
                                      textAlign: TextAlign.right,
                                      enabled: false,
                                      decoration: const InputDecoration(
                                          disabledBorder: InputBorder.none
                                      ),
                                      style: TextStyle(
                                        fontSize: 21,
                                        color: ColorsResources.dark,
                                        shadows: [
                                          Shadow(
                                            color: ColorsResources.dark.withOpacity(0.37),
                                            blurRadius: 7,
                                            offset: const Offset(1.9, 1.9),
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                              )
                          ),
                          Expanded(
                              flex: 4,
                              child: SizedBox(
                                height: 51,
                                width: 51,
                                child: Container(
                                  decoration: const BoxDecoration(
                                      color: ColorsResources.white,
                                      shape: BoxShape.circle
                                  ),
                                  child: Align(
                                    alignment: AlignmentDirectional.center,
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(7, 7, 7, 7),
                                      child: bankLogoImageView,
                                    ),
                                  ),
                                ),
                              )
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  color: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(7, 33, 7, 0),
                    child: SizedBox(
                      height: 71,
                      width: double.infinity,
                      child: TextFormField(
                        controller: creditCardNumberController,
                        textAlign: TextAlign.center,
                        enabled: false,
                        decoration: const InputDecoration(
                            disabledBorder: InputBorder.none
                        ),
                        style: TextStyle(
                          fontSize: 24,
                          fontFamily: "Numbers",
                          color: ColorsResources.dark,
                          shadows: [
                            Shadow(
                              color: ColorsResources.dark.withOpacity(0.37),
                              blurRadius: 7,
                              offset: const Offset(1.9, 1.9),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  color: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(11, 1, 11, 1),
                    child: SizedBox(
                      height: 57,
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                              flex: 19,
                              child: Padding(
                                  padding: const EdgeInsets.fromLTRB(11, 0, 0, 0),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextFormField(
                                      controller: creditCardNameHolderController,
                                      textAlign: TextAlign.left,
                                      enabled: false,
                                      decoration: const InputDecoration(
                                        disabledBorder: InputBorder.none
                                      ),
                                      style: TextStyle(
                                        fontSize: 21,
                                        color: ColorsResources.dark,
                                        shadows: [
                                          Shadow(
                                            color: ColorsResources.dark.withOpacity(0.37),
                                            blurRadius: 7,
                                            offset: const Offset(1.9, 1.9),
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                              )
                          ),
                          Expanded(
                              flex: 3,
                              child: Padding(
                                  padding: const EdgeInsets.fromLTRB(7, 0, 0, 0),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: TextField(
                                      controller: creditCardYearController,
                                      textAlign: TextAlign.center,
                                      enabled: false,
                                      decoration: const InputDecoration(
                                          disabledBorder: InputBorder.none
                                      ),
                                      style: TextStyle(
                                        fontSize: 19,
                                        color: ColorsResources.dark,
                                        shadows: [
                                          Shadow(
                                            color: ColorsResources.dark.withOpacity(0.37),
                                            blurRadius: 7,
                                            offset: const Offset(1.9, 1.9),
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                              )
                          ),
                          Expanded(
                              flex: 1,
                              child: Padding(
                                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      "/",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 23,
                                        color: ColorsResources.dark,
                                        shadows: [
                                          Shadow(
                                            color: ColorsResources.dark.withOpacity(0.37),
                                            blurRadius: 7,
                                            offset: const Offset(1.9, 1.9),
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                              )
                          ),
                          Expanded(
                              flex: 3,
                              child: Padding(
                                  padding: const EdgeInsets.fromLTRB(0, 0, 7, 0),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: TextField(
                                      controller: creditCardMonthController,
                                      textAlign: TextAlign.center,
                                      enabled: false,
                                      decoration: const InputDecoration(
                                          disabledBorder: InputBorder.none
                                      ),
                                      style: TextStyle(
                                        fontSize: 19,
                                        color: ColorsResources.dark,
                                        shadows: [
                                          Shadow(
                                            color: ColorsResources.dark.withOpacity(0.37),
                                            blurRadius: 7,
                                            offset: const Offset(1.9, 1.9),
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                              )
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

}

class CreditCardBackLayout extends StatefulWidget {

  CreditCardsData creditCardsData;

  CreditCardBackLayout({Key? key, required this.creditCardsData}) :super(key: key);

  @override
  State<CreditCardBackLayout> createState() => _CreditCardBackLayout();

}
class _CreditCardBackLayout extends State<CreditCardBackLayout> {


  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return backCardLayout(widget.creditCardsData.cvv);
  }

  Widget backCardLayout(String cvv) {

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: dominantColorForBackLayout.withOpacity(0.5),
            blurRadius: 13.0,
            spreadRadius: 0.3,
            offset: const Offset(3.9, 3.9),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13.0),
        child: Stack(
          children: <Widget> [
            Container(
              width: double.maxFinite,
              height: double.maxFinite,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(17), topRight: Radius.circular(17), bottomLeft: Radius.circular(17), bottomRight: Radius.circular(17)),
                gradient: LinearGradient(
                    colors: [
                      ColorsResources.light,
                      dominantColorForBackLayout,
                    ],
                    begin: const FractionalOffset(0.0, 0.0),
                    end: const FractionalOffset(1.0, 0.0),
                    stops: const [0.0, 1.0],
                    transform: const GradientRotation(45),
                    tileMode: TileMode.clamp),
              ),
            ),
            Image(
              image: AssetImage(generateBackgroundPattern()),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            Column(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(0, 19, 0, 0),
                  child: SizedBox(
                    height: 59,
                    width: double.infinity,
                    child: ColoredBox(
                      color: ColorsResources.dark,
                    ),
                  ),
                ),
                Container(
                  color: Colors.transparent,
                  child: const Padding(
                    padding: EdgeInsets.fromLTRB(7, 0, 11, 0),
                    child: SizedBox(
                      height: 51,
                      width: double.infinity,
                    ),
                  ),
                ),
                Container(
                  color: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                    child: SizedBox(
                      height: 55,
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                              flex: 17,
                              child: Container(
                                color: ColorsResources.dark,
                                child: CachedNetworkImage(
                                  imageUrl: "https://myhousestore.ir/wp-content/uploads/2022/02/GraphitTexture.jpg",
                                  fit: BoxFit.cover,
                                  color: Color(creditCardColorTag),
                                  colorBlendMode: BlendMode.overlay,
                                ),
                              )
                          ),
                          Expanded(
                              flex: 7,
                              child: Padding(
                                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: TextField(
                                      controller: creditCardCvvController,
                                      textAlign: TextAlign.center,
                                      enabled: false,
                                      decoration: const InputDecoration(
                                          disabledBorder: InputBorder.none
                                      ),
                                      style: TextStyle(
                                        fontSize: 23,
                                        color: ColorsResources.dark,
                                        shadows: [
                                          Shadow(
                                            color: ColorsResources.dark.withOpacity(0.37),
                                            blurRadius: 7,
                                            offset: const Offset(1.9, 1.9),
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                              )
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

}

String generateBackgroundPattern() {

  List listOfPattern = [];
  listOfPattern.add("pattern_card_background_one.png"); 
  listOfPattern.add("pattern_card_background_two.png");
  listOfPattern.add("pattern_card_background_three.png");
  listOfPattern.add("pattern_card_background_four.png");
  listOfPattern.add("pattern_card_background_five.png");

  return listOfPattern[Random().nextInt(listOfPattern.length)];
}