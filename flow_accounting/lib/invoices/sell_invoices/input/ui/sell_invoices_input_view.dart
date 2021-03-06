/*
 * Copyright © 2022 By Geeks Empire.
 *
 * Created by Elias Fazel
 * Last modified 4/10/22, 4:12 AM
 *
 * Licensed Under MIT License.
 * https://opensource.org/licenses/MIT
 */

import 'dart:io';
import 'dart:typed_data';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:blur/blur.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flow_accounting/cheque/database/io/inputs.dart';
import 'package:flow_accounting/cheque/database/io/queries.dart';
import 'package:flow_accounting/cheque/database/structures/table_structure.dart';
import 'package:flow_accounting/cheque/input/ui/cheques_input_view.dart';
import 'package:flow_accounting/credit_cards/database/io/inputs.dart';
import 'package:flow_accounting/credit_cards/database/io/queries.dart';
import 'package:flow_accounting/credit_cards/database/structures/tables_structure.dart';
import 'package:flow_accounting/customers/database/io/inputs.dart';
import 'package:flow_accounting/customers/database/io/queries.dart';
import 'package:flow_accounting/customers/database/structures/table_structure.dart';
import 'package:flow_accounting/debtors/database/io/inputs.dart';
import 'package:flow_accounting/debtors/database/io/queries.dart';
import 'package:flow_accounting/debtors/database/structures/tables_structure.dart';
import 'package:flow_accounting/invoices/invoiced_products/database/io/inputs.dart';
import 'package:flow_accounting/invoices/invoiced_products/database/io/queries.dart';
import 'package:flow_accounting/invoices/invoiced_products/database/structures/tables_structure.dart';
import 'package:flow_accounting/invoices/sell_invoices/database/io/inputs.dart';
import 'package:flow_accounting/invoices/sell_invoices/database/structures/tables_structure.dart';
import 'package:flow_accounting/products/database/io/inputs.dart';
import 'package:flow_accounting/products/database/io/queries.dart';
import 'package:flow_accounting/products/database/structures/tables_structure.dart';
import 'package:flow_accounting/profile/database/io/queries.dart';
import 'package:flow_accounting/resources/ColorsResources.dart';
import 'package:flow_accounting/resources/StringsResources.dart';
import 'package:flow_accounting/utils/calendar/io/time_io.dart';
import 'package:flow_accounting/utils/calendar/ui/calendar_view.dart';
import 'package:flow_accounting/utils/colors/color_selector.dart';
import 'package:flow_accounting/utils/extensions/bank_logos.dart';
import 'package:flow_accounting/utils/io/file_io.dart';
import 'package:flow_accounting/utils/print/printing.dart';
import 'package:flow_accounting/utils/ui/percentage_money_switcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';

class SellInvoicesInputView extends StatefulWidget {

  SellInvoicesData? sellInvoicesData;

  SellInvoicesInputView({Key? key, this.sellInvoicesData}) : super(key: key);

  @override
  _SellInvoicesInputViewState createState() => _SellInvoicesInputViewState();
}
class _SellInvoicesInputViewState extends State<SellInvoicesInputView> {

  CalendarView calendarView = CalendarView(timeNeeded: false);

  CalendarView calendarChequeDueView = CalendarView(timeNeeded: false, inputDateTime: StringsResources.chequeDueDate());

  ColorSelectorView colorSelectorView = ColorSelectorView();

  PercentageMoneySwitcher percentageMoneySwitcher = PercentageMoneySwitcher(percentageEnable: true);

  TextEditingController controllerCompanyName = TextEditingController();

  TextEditingController controllerInvoiceNumber = TextEditingController();
  TextEditingController controllerInvoiceDescription = TextEditingController();

  TextEditingController controllerPreInvoice = TextEditingController();

  TextEditingController controllerProductId = TextEditingController();
  TextEditingController controllerProductName = TextEditingController();
  TextEditingController controllerProductQuantity = TextEditingController();
  TextEditingController controllerProductQuantityType = TextEditingController();

  TextEditingController controllerProductEachPrice = TextEditingController();
  TextEditingController controllerProductDiscount = TextEditingController();

  TextEditingController controllerInvoicePrice = TextEditingController();

  TextEditingController controllerDiscount = TextEditingController();

  TextEditingController controllerShippingExpenses = TextEditingController();

  TextEditingController controllerProductTax = TextEditingController();

  TextEditingController controllerPaidTo = TextEditingController();

  TextEditingController controllerSoldTo = TextEditingController();

  TextEditingController controllerInvoiceCash = TextEditingController();

  TextEditingController controllerCheques = TextEditingController();
  TextEditingController controllerChequeNumber = TextEditingController();
  TextEditingController controllerChequeMoneyAmount = TextEditingController();
  TextEditingController controllerChequeName = TextEditingController();

  List<ProductsData> selectedProductsData = [];

  ScreenshotController barcodeSnapshotController = ScreenshotController();

  Widget barcodeView = Opacity(
      opacity: 0.37,
      child: ClipRRect(
          borderRadius: BorderRadius.circular(19),
          child: ColoredBox(
              color: ColorsResources.lightestBlue.withOpacity(0.73),
              child: Padding(
                  padding: EdgeInsets.fromLTRB(7, 7, 7, 7),
                  child: Image(
                    image: AssetImage("qr_code_icon.png"),
                    fit: BoxFit.cover,
                    height: 131,
                    width: 131,
                  )
              )
          )
      )
  );

  int timeNow = DateTime.now().millisecondsSinceEpoch;

  String companyLogoUrl = "";

  String companyDigitalSignature = "";

  bool sellInvoicesDataUpdated = false;

  String? warningNoticeCompanyName;

  String? warningNoticeNumber;
  String? warningNoticeDescription;

  String? warningNoticeProductName;
  String? warningNoticeProductQuantity;
  String? warningNoticeProductQuantityType;

  String? warningProductPrice;
  String? warningProductEachPrice;
  String? warningProductDiscount;

  String? warningPaidTo;

  String? warningSoldTo;

  String? warningCash;

  String? warningChequeNumber;
  String? warningChequeMoneyAmount;
  String? warningChequeName;

  List<Widget> selectedProductWidget = [];

  List<Widget> relatedChequesWidget = [];

  Widget printingView = Container();

  Widget imageLogoPickerWidget = const Opacity(
    opacity: 0.7,
    child: Image(
      image: AssetImage("unknown_user.png"),
      fit: BoxFit.cover,
    ),
  );

  Widget imageSignaturePickerWidget = const Opacity(
    opacity: 0.3,
    child: Image(
      image: AssetImage("signature_icon.png"),
      fit: BoxFit.contain,
    ),
  );

  @override
  void dispose() {

    BackButtonInterceptor.remove(aInterceptor);

    super.dispose();
  }

  @override
  void initState() {

    if (widget.sellInvoicesData != null) {

      if ((widget.sellInvoicesData?.id)! != 0) {

        timeNow = (widget.sellInvoicesData?.id)!;

      }

      colorSelectorView.inputColor = Color(widget.sellInvoicesData!.colorTag);

    }

    calendarView.inputDateTime = widget.sellInvoicesData?.sellInvoiceDateText ?? StringsResources.invoicesDate();

    companyLogoUrl = widget.sellInvoicesData?.companyLogoUrl ?? "";

    companyDigitalSignature = widget.sellInvoicesData?.companyDigitalSignature ?? "";

    controllerCompanyName.text = widget.sellInvoicesData?.companyName ?? "";

    controllerInvoiceNumber.text = widget.sellInvoicesData?.sellInvoiceNumber == null ? "" : (widget.sellInvoicesData?.sellInvoiceNumber)!;
    controllerInvoiceDescription.text = widget.sellInvoicesData?.sellInvoiceDescription == null ? "" : (widget.sellInvoicesData?.sellInvoiceDescription)!;

    controllerPreInvoice.text = widget.sellInvoicesData?.sellPreInvoice == null ? SellInvoicesData.SellInvoice_Final : (widget.sellInvoicesData?.sellPreInvoice)!;

    controllerInvoicePrice.text = widget.sellInvoicesData?.soldProductPrice == null ? "" : (widget.sellInvoicesData?.soldProductPrice)!;

    controllerShippingExpenses.text = widget.sellInvoicesData?.productShippingExpenses == null ? "" : (widget.sellInvoicesData?.productShippingExpenses)!;

    controllerProductTax.text = widget.sellInvoicesData?.productTax.replaceAll("%", "") == null ? "" : (widget.sellInvoicesData?.productTax)!.replaceAll("%", "");

    controllerPaidTo.text = widget.sellInvoicesData?.paidTo == null ? "" : (widget.sellInvoicesData?.paidTo)!;

    controllerSoldTo.text = widget.sellInvoicesData?.soldTo == null ? "" : (widget.sellInvoicesData?.soldTo)!;

    controllerChequeNumber.text = widget.sellInvoicesData?.invoiceChequesNumbers ?? "";

    colorSelectorView.inputColor = Color(widget.sellInvoicesData?.colorTag ?? Colors.white.value);

    prepareAllImagesCheckpoint();

    super.initState();

    BackButtonInterceptor.add(aInterceptor);

    if (widget.sellInvoicesData != null) {

      printingView = Expanded(
          flex: 3,
          child: Tooltip(
            triggerMode: TooltipTriggerMode.longPress,
            message: StringsResources.printingHint(),
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
                    onTap: () async {

                      PrintingProcess().startSellInvoicePrint(widget.sellInvoicesData!);

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
                            const Align(
                                alignment: AlignmentDirectional.center,
                                child: SizedBox(
                                    width: 53,
                                    height: 53,
                                    child: Padding(
                                        padding: EdgeInsets.fromLTRB(9, 9, 9, 9),
                                        child: Image(
                                          image: AssetImage("print_icon.png"),
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
            ),
          )
      );

    }

  }

  bool aInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {

    Navigator.pop(context, sellInvoicesDataUpdated);

    return true;
  }

  @override
  Widget build(BuildContext context) {

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
                          StringsResources.featureSellInvoicesTitle(),
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
                          StringsResources.featureSellInvoicesDescription(),
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
                      Align(
                          alignment: AlignmentDirectional.center,
                          child: barcodeView
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: 73,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              flex: 13,
                              child: Padding(
                                  padding: const EdgeInsets.fromLTRB(13, 0, 13, 0),
                                  child: Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: TextField(
                                      controller: controllerCompanyName,
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
                                        errorText: warningNoticeCompanyName,
                                        filled: true,
                                        fillColor: ColorsResources.lightTransparent,
                                        labelText: StringsResources.profileUserFullName(),
                                        labelStyle: const TextStyle(
                                            color: ColorsResources.dark,
                                            fontSize: 17.0
                                        ),
                                        hintText: StringsResources.profileUserFullNameHint(),
                                        hintStyle: const TextStyle(
                                            color: ColorsResources.darkTransparent,
                                            fontSize: 13.0
                                        ),
                                      ),
                                    ),
                                  )
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 13, 0),
                                child: InkWell(
                                  onTap: () {

                                    invokeLogoImagePicker();

                                  },
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(51),
                                      child: imageLogoPickerWidget,
                                    ),
                                  ),
                                ),
                              ),
                            )
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
                                      controller: controllerInvoiceNumber,
                                      textAlign: TextAlign.center,
                                      textDirection: TextDirection.ltr,
                                      textAlignVertical: TextAlignVertical.bottom,
                                      maxLines: 1,
                                      cursorColor: ColorsResources.primaryColor,
                                      autocorrect: true,
                                      autofocus: false,
                                      keyboardType: TextInputType.number,
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
                                        errorText: warningNoticeNumber,
                                        filled: true,
                                        fillColor: ColorsResources.lightTransparent,
                                        labelText: StringsResources.invoiceNumber(),
                                        labelStyle: const TextStyle(
                                            color: ColorsResources.dark,
                                            fontSize: 17.0
                                        ),
                                        hintText: StringsResources.sellInvoiceNumberHint(),
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
                                      controller: controllerInvoiceDescription,
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
                                        labelText: StringsResources.invoiceDescription(),
                                        labelStyle: const TextStyle(
                                            color: ColorsResources.dark,
                                            fontSize: 13.0
                                        ),
                                        hintText: StringsResources.sellInvoiceDescriptionHint(),
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
                                              value: StringsResources.invoiceFinal(),
                                              items: <String> [
                                                StringsResources.invoiceFinal(),
                                                StringsResources.invoicePre()
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

                                                if (value.toString() == StringsResources.invoiceFinal()) {

                                                  controllerPreInvoice.text = SellInvoicesData.SellInvoice_Final;

                                                } else if (value.toString() == StringsResources.invoicePre()) {

                                                  controllerPreInvoice.text = SellInvoicesData.SellInvoice_Pre;

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
                                              StringsResources.invoiceType(),
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
                        height: 151,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                                flex: 3,
                                child: Padding(
                                    padding: const EdgeInsets.fromLTRB(9, 0, 3, 0),
                                    child: ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(23),
                                            bottomLeft: Radius.circular(23),
                                            topRight: Radius.circular(23),
                                            bottomRight: Radius.circular(23)
                                        ),
                                        child: Material(
                                            shadowColor: Colors.transparent,
                                            color: Colors.transparent,
                                            child: InkWell(
                                                splashColor: ColorsResources.blue.withOpacity(0.91),
                                                splashFactory: InkRipple.splashFactory,
                                                onTap: () async {

                                                  bool noError = true;

                                                  if (controllerProductName.text.isEmpty) {

                                                    setState(() {

                                                      warningNoticeProductName = StringsResources.errorText();

                                                    });

                                                    noError = false;

                                                  }

                                                  if (controllerProductQuantity.text.isEmpty) {

                                                    setState(() {

                                                      warningNoticeProductQuantity = StringsResources.errorText();

                                                    });

                                                    noError = false;

                                                  }

                                                  if (controllerProductQuantityType.text.isEmpty) {

                                                    setState(() {

                                                      warningNoticeProductQuantityType = StringsResources.errorText();

                                                    });

                                                    noError = false;

                                                  }

                                                  if (controllerProductEachPrice.text.isEmpty) {

                                                    setState(() {

                                                      warningProductEachPrice = StringsResources.errorText();

                                                    });

                                                    noError = false;

                                                  }

                                                  if (noError) {

                                                    ProductsData productData = ProductsData(
                                                        id: DateTime.now().millisecondsSinceEpoch,

                                                        productImageUrl: "",

                                                        productName: controllerProductName.text,
                                                        productDescription: "",

                                                        productCategory: "",

                                                        productBrand: "",
                                                        productBrandLogoUrl: "",

                                                        productPrice: controllerProductEachPrice.text,
                                                        productProfitPercent: "0%",

                                                        productTax: "0%",

                                                        productQuantity: int.parse(controllerProductQuantity.text),
                                                        productQuantityType: controllerProductQuantityType.text.isEmpty ? "" : controllerProductQuantityType.text,

                                                        extraBarcodeData: "",

                                                        colorTag: ColorsResources.white.value
                                                    );

                                                    bool productExist = false;

                                                    var productQueries = ProductsDatabaseQueries();

                                                    String databaseDirectory = await getDatabasesPath();

                                                    String productDatabasePath = "${databaseDirectory}/${ProductsDatabaseInputs.productsDatabase()}";

                                                    bool productsDatabaseExist = await databaseExists(productDatabasePath);

                                                    if (productsDatabaseExist) {

                                                      try {

                                                        var queriedProduct = await productQueries.querySpecificProductByName(controllerProductName.text, ProductsDatabaseInputs.databaseTableName, UserInformation.UserId);

                                                        if (queriedProduct != null) {

                                                          productData = queriedProduct;

                                                          productExist = true;

                                                          debugPrint("Invoice | Selected Product Exists");

                                                        } else {

                                                          productExist = false;

                                                        }

                                                      } on Exception {
                                                        debugPrint("Invoice | Selected Product Not Exists");

                                                        productExist = false;

                                                      }

                                                    }

                                                    debugPrint("Product Exist: ${productExist}");
                                                    if (!productExist) {
                                                      debugPrint("Invoice | New Product Added");

                                                      var databaseInputs = ProductsDatabaseInputs();

                                                      databaseInputs.insertProductData(productData, ProductsDatabaseInputs.databaseTableName, UserInformation.UserId);

                                                    }

                                                    /* Start - Calculate Invoice Price */
                                                    int completePrice = int.parse(controllerProductEachPrice.text.isEmpty ? "0" : controllerProductEachPrice.text.replaceAll(",", "")) * int.parse(controllerProductQuantity.text.isEmpty ? "0" : controllerProductQuantity.text);

                                                    int taxAmount = ((completePrice * int.parse(controllerProductTax.text.isEmpty ? "0" : controllerProductTax.text.replaceAll("%", ""))) / 100).round();

                                                    int discountPrice = 0;

                                                    if (percentageMoneySwitcher.percentageEnable) {

                                                      discountPrice = ((completePrice * int.parse(controllerProductDiscount.text.isEmpty ? "0" : controllerProductDiscount.text)) / 100).round();

                                                    } else {

                                                      discountPrice = int.parse(controllerDiscount.text);

                                                    }

                                                    int finalPrice = (completePrice + taxAmount) - discountPrice;

                                                    int previousInvoicePrice = int.parse(controllerInvoicePrice.text.isEmpty ? "0" : controllerInvoicePrice.text.replaceAll(",", ""));

                                                    controllerInvoicePrice.text = (previousInvoicePrice + finalPrice).toString();
                                                    /* End - Calculate Invoice Price */

                                                    productData.productQuantity = int.parse(controllerProductQuantity.text);

                                                    selectedProductsData.add(productData);

                                                    updateSelectedProductsList(selectedProductsData);

                                                    controllerProductName.text = "";
                                                    controllerProductQuantity.text = "";
                                                    controllerProductQuantityType.text = "";
                                                    controllerProductEachPrice.text = "";
                                                    controllerProductTax.text = "";
                                                    controllerProductDiscount.text = "";

                                                  }

                                                },
                                                child: Container(
                                                    color: ColorsResources.lightTransparent,
                                                    child: SizedBox(
                                                        width: double.infinity,
                                                        height: 151,
                                                        child: Align(
                                                            alignment: AlignmentDirectional.center,
                                                            child: Image(
                                                              image: AssetImage("quick_save.png"),
                                                              height: 37,
                                                              width: 37,
                                                              color: ColorsResources.primaryColor,
                                                            )
                                                        )
                                                    )
                                                )
                                            )
                                        )
                                    )
                                )
                            ),
                            Expanded(
                                flex: 19,
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: double.infinity,
                                      height: 73,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Expanded(
                                              flex: 5,
                                              child: Padding(
                                                  padding: const EdgeInsets.fromLTRB(3, 0, 3, 0),
                                                  child: Directionality(
                                                      textDirection: TextDirection.rtl,
                                                      child: TypeAheadField<String>(
                                                          suggestionsCallback: (pattern) async {

                                                            return await getQuantityTypes();
                                                          },
                                                          itemBuilder: (context, suggestion) {

                                                            return ListTile(
                                                                title: Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                  children: [
                                                                    Padding(
                                                                      padding: const EdgeInsets.fromLTRB(3, 0, 3, 0),
                                                                      child: Directionality(
                                                                        textDirection: TextDirection.rtl,
                                                                        child: Text(
                                                                          suggestion.toString(),
                                                                          style: const TextStyle(
                                                                              color: ColorsResources.darkTransparent,
                                                                              fontSize: 13
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                )
                                                            );
                                                          },
                                                          onSuggestionSelected: (suggestion) {

                                                            controllerProductQuantityType.text = suggestion.toString();

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
                                                            controller: controllerProductQuantityType,
                                                            autofocus: false,
                                                            textAlignVertical: TextAlignVertical.bottom,
                                                            maxLines: 1,
                                                            cursorColor: ColorsResources.primaryColor,
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
                                                              errorText: warningNoticeProductQuantityType,
                                                              filled: true,
                                                              fillColor: ColorsResources.lightTransparent,
                                                              labelText: StringsResources.productQuantityType(),
                                                              labelStyle: const TextStyle(
                                                                  color: ColorsResources.dark,
                                                                  fontSize: 17.0
                                                              ),
                                                              hintText: StringsResources.productQuantityTypeHint(),
                                                              hintStyle: const TextStyle(
                                                                  color: ColorsResources.darkTransparent,
                                                                  fontSize: 13.0
                                                              ),
                                                            ),
                                                          )
                                                      )
                                                  )
                                              )
                                          ),
                                          Expanded(
                                            flex: 5,
                                            child: Padding(
                                                padding: const EdgeInsets.fromLTRB(3, 0, 3, 0),
                                                child: Directionality(
                                                  textDirection: TextDirection.rtl,
                                                  child: TextField(
                                                    controller: controllerProductQuantity,
                                                    textAlign: TextAlign.center,
                                                    textDirection: TextDirection.rtl,
                                                    textAlignVertical: TextAlignVertical.bottom,
                                                    maxLines: 1,
                                                    cursorColor: ColorsResources.primaryColor,
                                                    autocorrect: true,
                                                    autofocus: false,
                                                    keyboardType: TextInputType.number,
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
                                                      errorText: warningNoticeProductQuantity,
                                                      filled: true,
                                                      fillColor: ColorsResources.lightTransparent,
                                                      labelText: StringsResources.quantity(),
                                                      labelStyle: const TextStyle(
                                                          color: ColorsResources.dark,
                                                          fontSize: 17.0
                                                      ),
                                                      hintText: StringsResources.sellQuantityHint(),
                                                      hintStyle: const TextStyle(
                                                          color: ColorsResources.darkTransparent,
                                                          fontSize: 13.0
                                                      ),
                                                    ),
                                                  ),
                                                )
                                            ),
                                          ),
                                          Expanded(
                                            flex: 13,
                                            child: Padding(
                                                padding: const EdgeInsets.fromLTRB(3, 0, 13, 0),
                                                child: Directionality(
                                                  textDirection: TextDirection.rtl,
                                                  child: TypeAheadField<ProductsData>(
                                                      suggestionsCallback: (pattern) async {

                                                        return await getAllProducts();
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
                                                                        suggestion.productName,
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
                                                                              child: Image.file(
                                                                                File(suggestion.productImageUrl),
                                                                                fit: BoxFit.cover,
                                                                              )
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

                                                        controllerProductId.text = suggestion.id.toString();
                                                        controllerProductName.text = suggestion.productName.toString();
                                                        controllerProductQuantityType.text = suggestion.productQuantityType.toString();
                                                        controllerProductTax.text = suggestion.productTax.toString();

                                                        String percentProfit = suggestion.productProfitPercent.replaceAll("%", "");
                                                        double profitMargin = (int.parse(suggestion.productPrice.replaceAll(",", "")) * int.parse(percentProfit)) / 100;

                                                        double sellingPriceWithProfit = int.parse(suggestion.productPrice.replaceAll(",", "")) + profitMargin;

                                                        String percentTax = suggestion.productTax.replaceAll("%", "");
                                                        double taxMargin = (sellingPriceWithProfit * int.parse(percentTax)) / 100;

                                                        int sellingPrice = (sellingPriceWithProfit + taxMargin).round();

                                                        controllerProductEachPrice.text = sellingPrice.toString();

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
                                                        controller: controllerProductName,
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
                                                          errorText: warningNoticeProductName,
                                                          filled: true,
                                                          fillColor: ColorsResources.lightTransparent,
                                                          labelText: StringsResources.invoiceProduct(),
                                                          labelStyle: const TextStyle(
                                                              color: ColorsResources.dark,
                                                              fontSize: 17.0
                                                          ),
                                                          hintText: StringsResources.sellInvoiceProductHint(),
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
                                      height: 3,
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
                                                padding: const EdgeInsets.fromLTRB(3, 0, 3, 0),
                                                child: Stack(
                                                  children: [
                                                    Directionality(
                                                        textDirection: TextDirection.rtl,
                                                        child: TextField(
                                                          controller: controllerProductDiscount,
                                                          textAlign: TextAlign.center,
                                                          textDirection: TextDirection.rtl,
                                                          textAlignVertical: TextAlignVertical.bottom,
                                                          maxLines: 1,
                                                          cursorColor: ColorsResources.primaryColor,
                                                          autocorrect: true,
                                                          autofocus: false,
                                                          keyboardType: TextInputType.number,
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
                                                            errorText: warningProductDiscount,
                                                            filled: true,
                                                            fillColor: ColorsResources.lightTransparent,
                                                            labelText: StringsResources.invoiceDiscount(),
                                                            labelStyle: const TextStyle(
                                                                color: ColorsResources.dark,
                                                                fontSize: 17.0
                                                            ),
                                                            hintText: StringsResources.buyInvoiceDiscountHint(),
                                                            hintStyle: const TextStyle(
                                                                color: ColorsResources.darkTransparent,
                                                                fontSize: 13.0
                                                            ),
                                                          ),
                                                        )
                                                    ),
                                                    percentageMoneySwitcher
                                                  ],
                                                )
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Padding(
                                                padding: const EdgeInsets.fromLTRB(3, 0, 3, 0),
                                                child: Directionality(
                                                  textDirection: TextDirection.rtl,
                                                  child: TextField(
                                                    controller: controllerProductTax,
                                                    textAlign: TextAlign.center,
                                                    textDirection: TextDirection.ltr,
                                                    textAlignVertical: TextAlignVertical.bottom,
                                                    maxLines: 1,
                                                    cursorColor: ColorsResources.primaryColor,
                                                    autocorrect: true,
                                                    autofocus: false,
                                                    keyboardType: TextInputType.number,
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
                                                      filled: true,
                                                      fillColor: ColorsResources.lightTransparent,
                                                      labelText: StringsResources.productProfitTax(),
                                                      labelStyle: const TextStyle(
                                                          color: ColorsResources.dark,
                                                          fontSize: 17.0
                                                      ),
                                                      hintText: StringsResources.productProfitTaxHint(),
                                                      hintStyle: const TextStyle(
                                                          color: ColorsResources.darkTransparent,
                                                          fontSize: 13.0
                                                      ),
                                                    ),
                                                  ),
                                                )
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Padding(
                                                padding: const EdgeInsets.fromLTRB(3, 0, 13, 0),
                                                child: Directionality(
                                                  textDirection: TextDirection.rtl,
                                                  child: TextField(
                                                    controller: controllerProductEachPrice,
                                                    textAlign: TextAlign.center,
                                                    textDirection: TextDirection.rtl,
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
                                                      errorText: warningProductEachPrice,
                                                      filled: true,
                                                      fillColor: ColorsResources.lightTransparent,
                                                      labelText: StringsResources.invoiceEachPrice(),
                                                      labelStyle: const TextStyle(
                                                          color: ColorsResources.dark,
                                                          fontSize: 17.0
                                                      ),
                                                      hintText: StringsResources.invoiceEachPriceHint(),
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
                                  ],
                                )
                            ),
                          ],
                        ),
                      ),
                      const Divider(
                        height: 3,
                        color: Colors.transparent,
                      ),
                      SizedBox(
                          width: double.infinity,
                          height: 57,
                          child: ListView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(13, 0, 13, 0),
                            scrollDirection: Axis.horizontal,
                            children: selectedProductWidget,
                          )
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
                                      controller: controllerShippingExpenses,
                                      textAlign: TextAlign.center,
                                      textDirection: TextDirection.rtl,
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
                                      onChanged: (shippingExpenses) {

                                        int completeShipping = int.parse(controllerShippingExpenses.text.isEmpty ? "0" : controllerShippingExpenses.text.replaceAll(",", ""));

                                        int previousInvoicePrice = int.parse(controllerInvoicePrice.text.isEmpty ? "0" : controllerInvoicePrice.text.replaceAll(",", ""));

                                        controllerInvoicePrice.text = (previousInvoicePrice + completeShipping).toString();

                                      },
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
                                        errorText: warningProductPrice,
                                        filled: true,
                                        fillColor: ColorsResources.lightTransparent,
                                        labelText: StringsResources.shippingExpenses(),
                                        labelStyle: const TextStyle(
                                            color: ColorsResources.dark,
                                            fontSize: 17.0
                                        ),
                                        hintText: StringsResources.shippingExpensesHint(),
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
                                  child: Stack(
                                    children: [
                                      Directionality(
                                        textDirection: TextDirection.rtl,
                                        child: TextField(
                                          controller: controllerDiscount,
                                          textAlign: TextAlign.center,
                                          textDirection: TextDirection.rtl,
                                          textAlignVertical: TextAlignVertical.bottom,
                                          maxLines: 1,
                                          cursorColor: ColorsResources.primaryColor,
                                          autocorrect: true,
                                          autofocus: false,
                                          keyboardType: TextInputType.number,
                                          textInputAction: TextInputAction.next,
                                          onChanged: (fullDiscount) {

                                            int previousInvoicePrice = int.parse(controllerInvoicePrice.text.isEmpty ? "0" : controllerInvoicePrice.text.replaceAll(",", ""));

                                            int completeDiscount = 0;

                                            if (percentageMoneySwitcher.percentageEnable) {

                                              String completeDiscountPercent = controllerDiscount.text.isEmpty ? "0%" : controllerDiscount.text;

                                              completeDiscount = ((previousInvoicePrice * int.parse(completeDiscountPercent.replaceAll("%", ""))) / 100).round();

                                            } else {

                                              completeDiscount = int.parse(controllerDiscount.text.isEmpty ? "0" : controllerDiscount.text);

                                            }

                                            controllerInvoicePrice.text = (previousInvoicePrice - completeDiscount).toString();

                                          },
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
                                            errorText: warningProductDiscount,
                                            filled: true,
                                            fillColor: ColorsResources.lightTransparent,
                                            labelText: StringsResources.fullDiscount(),
                                            labelStyle: const TextStyle(
                                                color: ColorsResources.dark,
                                                fontSize: 17.0
                                            ),
                                            hintText: StringsResources.fullDiscountHint(),
                                            hintStyle: const TextStyle(
                                                color: ColorsResources.darkTransparent,
                                                fontSize: 13.0
                                            ),
                                          ),
                                        ),
                                      ),
                                      percentageMoneySwitcher
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
                                    child: TextField(
                                      controller: controllerInvoicePrice,
                                      textAlign: TextAlign.center,
                                      textDirection: TextDirection.rtl,
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
                                        errorText: warningProductPrice,
                                        filled: true,
                                        fillColor: ColorsResources.lightTransparent,
                                        labelText: StringsResources.invoicePrice(),
                                        labelStyle: const TextStyle(
                                            color: ColorsResources.dark,
                                            fontSize: 17.0
                                        ),
                                        hintText: StringsResources.invoicePriceHint(),
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
                                    child: TypeAheadField<CreditCardsData>(
                                        suggestionsCallback: (pattern) async {

                                          return await getAllCreditCards();
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
                                                          suggestion.cardNumber,
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
                                                                generateBankLogoUrl(suggestion.bankName),
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

                                          controllerPaidTo.text = suggestion.cardNumber;

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
                                          controller: controllerPaidTo,
                                          autofocus: false,
                                          maxLines: 1,
                                          textAlign: TextAlign.center,
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
                                            errorText: warningPaidTo,
                                            filled: true,
                                            fillColor: ColorsResources.lightTransparent,
                                            labelText: StringsResources.sellInvoicePaidBy(),
                                            labelStyle: const TextStyle(
                                                color: ColorsResources.dark,
                                                fontSize: 17.0
                                            ),
                                            hintText: StringsResources.sellInvoicePaidByHint(),
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
                                    child: TypeAheadField<dynamic>(
                                        suggestionsCallback: (pattern) async {

                                          return await getAllDebtorsAndCustomers();
                                        },
                                        itemBuilder: (context, suggestion) {

                                          String suggestedName = "";
                                          int colorTag = Colors.white.value;
                                          String imagePath = "";

                                          if (suggestion is DebtorsData) {

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

                                          if (suggestion is DebtorsData) {

                                            controllerSoldTo.text = suggestion.debtorsName;

                                          } else if (suggestion is CustomersData) {

                                            controllerSoldTo.text = suggestion.customerName;

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
                                          controller: controllerSoldTo,
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
                                            errorText: warningSoldTo,
                                            filled: true,
                                            fillColor: ColorsResources.lightTransparent,
                                            labelText: StringsResources.sellInvoiceSoldTo(),
                                            labelStyle: const TextStyle(
                                                color: ColorsResources.dark,
                                                fontSize: 17.0
                                            ),
                                            hintText: StringsResources.sellInvoiceSoldToHint(),
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
                                    child: TextField(
                                      controller: controllerInvoiceCash,
                                      textAlign: TextAlign.center,
                                      textDirection: TextDirection.rtl,
                                      textAlignVertical: TextAlignVertical.bottom,
                                      maxLines: 1,
                                      cursorColor: ColorsResources.primaryColor,
                                      autocorrect: true,
                                      autofocus: false,
                                      keyboardType: TextInputType.number,
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
                                        errorText: warningCash,
                                        filled: true,
                                        fillColor: ColorsResources.lightTransparent,
                                        labelText: StringsResources.invoiceCash(),
                                        labelStyle: const TextStyle(
                                            color: ColorsResources.dark,
                                            fontSize: 17.0
                                        ),
                                        hintText: StringsResources.invoiceCashHint(),
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
                        height: 151,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                                flex: 3,
                                child: Padding(
                                    padding: const EdgeInsets.fromLTRB(9, 0, 3, 0),
                                    child: ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(23),
                                            bottomLeft: Radius.circular(23),
                                            topRight: Radius.circular(23),
                                            bottomRight: Radius.circular(23)
                                        ),
                                        child: Material(
                                            shadowColor: Colors.transparent,
                                            color: Colors.transparent,
                                            child: InkWell(
                                                splashColor: ColorsResources.blue.withOpacity(0.91),
                                                splashFactory: InkRipple.splashFactory,
                                                onTap: () async {

                                                  bool noError = true;

                                                  if (controllerChequeNumber.text.isEmpty) {

                                                    setState(() {

                                                      warningChequeNumber = StringsResources.errorText();

                                                    });

                                                    noError = false;

                                                  }

                                                  if (controllerChequeMoneyAmount.text.isEmpty) {

                                                    setState(() {

                                                      warningChequeMoneyAmount = StringsResources.errorText();

                                                    });

                                                    noError = false;

                                                  }

                                                  if (controllerChequeName.text.isEmpty) {

                                                    setState(() {

                                                      warningChequeName = StringsResources.errorText();

                                                    });

                                                    noError = false;

                                                  }

                                                  if (noError) {

                                                    controllerCheques.text += "${controllerChequeNumber.text},";

                                                    insertRelatedCheques(controllerChequeNumber.text);

                                                  }

                                                },
                                                child: Container(
                                                    color: ColorsResources.lightTransparent,
                                                    child: SizedBox(
                                                        width: double.infinity,
                                                        height: 151,
                                                        child: Align(
                                                            alignment: AlignmentDirectional.center,
                                                            child: Image(
                                                              image: AssetImage("quick_save.png"),
                                                              height: 37,
                                                              width: 37,
                                                              color: ColorsResources.primaryColor,
                                                            )
                                                        )
                                                    )
                                                )
                                            )
                                        )
                                    )
                                )
                            ),
                            Expanded(
                                flex: 19,
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: double.infinity,
                                      height: 73,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: Padding(
                                                padding: const EdgeInsets.fromLTRB(3, 0, 2, 0),
                                                child: Directionality(
                                                  textDirection: TextDirection.rtl,
                                                  child: TypeAheadField<dynamic>(
                                                      suggestionsCallback: (pattern) async {

                                                        return await getAllDebtorsAndCustomers();
                                                      },
                                                      itemBuilder: (context, suggestion) {

                                                        String suggestedName = "";
                                                        int colorTag = Colors.white.value;
                                                        String imagePath = "";

                                                        if (suggestion is DebtorsData) {

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

                                                        if (suggestion is DebtorsData) {

                                                          controllerSoldTo.text = suggestion.debtorsName;

                                                        } else if (suggestion is CustomersData) {

                                                          controllerSoldTo.text = suggestion.customerName;

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
                                                        controller: controllerChequeName,
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
                                                          errorText: warningChequeName,
                                                          filled: true,
                                                          fillColor: ColorsResources.lightTransparent,
                                                          labelText: StringsResources.chequeTargetName(),
                                                          labelStyle: const TextStyle(
                                                              color: ColorsResources.dark,
                                                              fontSize: 17.0
                                                          ),
                                                          hintText: StringsResources.chequeTargetName(),
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
                                                padding: const EdgeInsets.fromLTRB(3, 0, 13, 0),
                                                child: Directionality(
                                                  textDirection: TextDirection.rtl,
                                                  child: TextField(
                                                    controller: controllerChequeNumber,
                                                    textAlign: TextAlign.center,
                                                    textDirection: TextDirection.rtl,
                                                    textAlignVertical: TextAlignVertical.bottom,
                                                    maxLines: 1,
                                                    cursorColor: ColorsResources.primaryColor,
                                                    autocorrect: true,
                                                    autofocus: false,
                                                    keyboardType: TextInputType.number,
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
                                                      errorText: warningChequeNumber,
                                                      filled: true,
                                                      fillColor: ColorsResources.lightTransparent,
                                                      labelText: StringsResources.chequeNumber(),
                                                      labelStyle: const TextStyle(
                                                          color: ColorsResources.dark,
                                                          fontSize: 17.0
                                                      ),
                                                      hintText: StringsResources.chequeNumber(),
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
                                      height: 3,
                                      color: Colors.transparent,
                                    ),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 73,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Expanded(
                                            flex: 7,
                                            child: Padding(
                                                padding: const EdgeInsets.fromLTRB(3, 5, 3, 5),
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
                                                  child: calendarChequeDueView,
                                                )
                                            ),
                                          ),
                                          Expanded(
                                            flex: 11,
                                            child: Padding(
                                                padding: const EdgeInsets.fromLTRB(3, 0, 13, 0),
                                                child: Directionality(
                                                  textDirection: TextDirection.rtl,
                                                  child: TextField(
                                                    controller: controllerChequeMoneyAmount,
                                                    textAlign: TextAlign.center,
                                                    textDirection: TextDirection.rtl,
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
                                                      errorText: warningChequeMoneyAmount,
                                                      filled: true,
                                                      fillColor: ColorsResources.lightTransparent,
                                                      labelText: StringsResources.chequeAmountHint(),
                                                      labelStyle: const TextStyle(
                                                          color: ColorsResources.dark,
                                                          fontSize: 17.0
                                                      ),
                                                      hintText: StringsResources.chequeAmountHint(),
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
                                  ],
                                )
                            ),
                          ],
                        ),
                      ),
                      const Divider(
                        height: 3,
                        color: Colors.transparent,
                      ),
                      SizedBox(
                          width: double.infinity,
                          height: 57,
                          child: ListView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(13, 0, 13, 0),
                            scrollDirection: Axis.horizontal,
                            children: relatedChequesWidget,
                          )
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
                                      StringsResources.digitalSignatureHint(),
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
                        height: 179,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                                flex: 1,
                                child: Padding(
                                    padding: EdgeInsets.fromLTRB(13, 0, 13, 0),
                                    child: InkWell(
                                        onTap: () {

                                          invokeSignatureImagePicker();

                                        },
                                        child: AspectRatio(
                                            aspectRatio: 1,
                                            child: ClipRRect(
                                                borderRadius: BorderRadius.circular(19),
                                                child: Container(
                                                    decoration: BoxDecoration(
                                                        gradient: LinearGradient(
                                                          colors: [
                                                            ColorsResources.lightestBlue,
                                                            ColorsResources.white.withOpacity(0.3)
                                                          ],
                                                          transform: const GradientRotation(45),
                                                        )
                                                    ),
                                                    child: Padding(
                                                        padding: EdgeInsets.all(7),
                                                        child: imageSignaturePickerWidget
                                                    )
                                                )
                                            )
                                        )
                                    )
                                )
                            ),
                          ],
                        ),
                      ),
                      const Divider(
                        height: 17,
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

                        Navigator.pop(context, sellInvoicesDataUpdated);

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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        printingView,
                        Expanded(
                          flex: 1,
                          child: ColoredBox(color: Colors.transparent),
                        ),
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

                                  if (controllerCompanyName.text.isEmpty) {

                                    setState(() {

                                      warningNoticeCompanyName = StringsResources.errorText();

                                    });

                                    noError = false;

                                  }

                                  if (controllerInvoiceDescription.text.isEmpty) {

                                    setState(() {

                                      warningNoticeDescription = StringsResources.errorText();

                                    });

                                    noError = false;

                                  }

                                  if (controllerInvoicePrice.text.isEmpty) {

                                    setState(() {

                                      warningProductPrice = StringsResources.errorText();

                                    });

                                    noError = false;

                                  }

                                  if (controllerSoldTo.text.isEmpty) {

                                    setState(() {

                                      warningPaidTo = StringsResources.errorText();

                                    });

                                    noError = false;

                                  }

                                  if (controllerSoldTo.text.isEmpty) {

                                    setState(() {

                                      warningSoldTo = StringsResources.errorText();

                                    });

                                    noError = false;

                                  }

                                  if (controllerInvoiceCash.text.isEmpty) {

                                    setState(() {

                                      warningCash = StringsResources.errorText();

                                    });

                                    noError = false;

                                  }

                                  if (noError) {

                                    if (widget.sellInvoicesData != null) {

                                      if ((widget.sellInvoicesData?.id)! != 0) {

                                        timeNow = (widget.sellInvoicesData?.id)!;

                                      }

                                    }

                                    var databaseInputs = SellInvoicesDatabaseInputs();

                                    SellInvoicesData sellInvoicesData = SellInvoicesData(
                                        id: timeNow,

                                        companyName: controllerCompanyName.text.isEmpty ? UserInformation.UserId : controllerCompanyName.text,
                                        companyLogoUrl: companyLogoUrl,

                                        sellInvoiceNumber: controllerInvoiceNumber.text.isEmpty ? timeNow.toString() : controllerInvoiceNumber.text,

                                        sellInvoiceDescription: controllerInvoiceDescription.text,

                                        sellInvoiceDateText: calendarView.inputDateTime ?? "",
                                        sellInvoiceDateMillisecond: calendarView.pickedDateTime.millisecondsSinceEpoch,

                                        soldProductPrice: controllerInvoicePrice.text.isEmpty ? "0" : controllerInvoicePrice.text,
                                        soldProductPriceDiscount: controllerProductDiscount.text.isEmpty ? "0" : controllerProductDiscount.text,

                                        invoiceDiscount: controllerDiscount.text.isEmpty ? "0%" : controllerDiscount.text,

                                        productShippingExpenses: controllerShippingExpenses.text.isEmpty ? "0" : controllerShippingExpenses.text,

                                        productTax: controllerProductTax.text.isEmpty ? "0%" : "${controllerProductTax.text}%",

                                        paidTo: controllerPaidTo.text,

                                        soldTo: controllerSoldTo.text,

                                        sellPreInvoice: controllerPreInvoice.text,

                                        companyDigitalSignature: companyDigitalSignature,

                                        invoicePaidCash: controllerInvoiceCash.text.isEmpty ? "0" : controllerInvoiceCash.text,
                                        invoiceChequesNumbers: cleanUpCsvDatabase(controllerCheques.text),

                                        colorTag: colorSelectorView.selectedColor.value,

                                        invoiceReturned: ""
                                    );

                                    if (widget.sellInvoicesData != null) {

                                      if ((widget.sellInvoicesData?.id)! != 0) {

                                        databaseInputs.updateInvoiceData(sellInvoicesData, SellInvoicesDatabaseInputs.databaseTableName, UserInformation.UserId);

                                        updateInvoicedProducts();

                                      }

                                    } else {

                                      databaseInputs.insertSellInvoiceData(sellInvoicesData, SellInvoicesDatabaseInputs.databaseTableName, UserInformation.UserId);

                                      insertInvoicedProducts();

                                      updateCustomerPurchases(sellInvoicesData);

                                      generateBarcode(sellInvoicesData.id);

                                    }

                                    updateProductQuantity();

                                    Fluttertoast.showToast(
                                        msg: StringsResources.updatedText(),
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.CENTER,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: ColorsResources.lightTransparent,
                                        textColor: ColorsResources.dark,
                                        fontSize: 16.0
                                    );

                                    sellInvoicesDataUpdated = true;

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
                                                    child: ColoredBox(color: Colors.transparent)
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
                                                    child: ColoredBox(color: Colors.transparent)
                                                ),
                                              ],
                                            )
                                        )
                                      ],
                                    )
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<List<ProductsData>> getAllProducts() async {

    List<ProductsData> allProducts = [];

    String databaseDirectory = await getDatabasesPath();

    String productDatabasePath = "${databaseDirectory}/${ProductsDatabaseInputs.productsDatabase()}";

    bool productsDatabaseExist = await databaseExists(productDatabasePath);

    if (productsDatabaseExist) {

      ProductsDatabaseQueries productsDatabaseQueries = ProductsDatabaseQueries();

      allProducts = await productsDatabaseQueries.getAllProducts(ProductsDatabaseInputs.databaseTableName, UserInformation.UserId);

    }

    return allProducts;
  }

  /*
   * Start - Invoiced Products
   */
  void updateSelectedProductsList(List<ProductsData> inputSelectedProduct) async {

    selectedProductWidget.clear();

    int index = 0;

    for(var aProduct in inputSelectedProduct) {
      debugPrint("Product Added To Invoice -> ${aProduct.productName}");

      selectedProductWidget.add(selectedProductItemView(aProduct, InvoicedProductsData.Product_Purchased, inputSelectedProduct[index].productQuantity, index));

      index++;

    }

    setState(() {
      debugPrint("Invoices Products Updated");

      selectedProductWidget;

    });

  }

  void prepareSelectedProducts() async {

    selectedProductWidget.clear();

    selectedProductsData.clear();

    if (widget.sellInvoicesData != null) {

      String databaseDirectory = await getDatabasesPath();

      String invoicedProductDatabasePath = "${databaseDirectory}/${InvoicedProductsDatabaseInputs.invoicedProductsDatabase(timeNow)}";

      bool invoicedProductsDatabaseExist = await databaseExists(invoicedProductDatabasePath);

      if (invoicedProductsDatabaseExist) {
        debugPrint("Invoiced Products Database Exists");

        InvoicedProductsQueries invoicedProductsQueries = InvoicedProductsQueries();

        List<InvoicedProductsData> allInvoicedProducts = await invoicedProductsQueries.getAllInvoicedProducts(InvoicedProductsDatabaseInputs.invoicedProductsDatabase(timeNow), InvoicedProductsDatabaseInputs.databaseTableName);

        ProductsDatabaseQueries productsDatabaseQueries = ProductsDatabaseQueries();

        int index = 0;

        allInvoicedProducts.forEach((element) async {

          var aProduct = await productsDatabaseQueries.querySpecificProductById(element.invoiceProductId.toString(), ProductsDatabaseInputs.databaseTableName, UserInformation.UserId);

          selectedProductWidget.add(selectedProductItemView(
              aProduct,
              element.invoiceProductStatus,
              element.invoiceProductQuantity,
              index
          ));

          selectedProductsData.add(aProduct);

          index++;

        });

        setState(() {
          debugPrint("Invoices Products Retrieved");

          selectedProductWidget;

        });

      }

    }

  }

  Widget selectedProductItemView(ProductsData productsData, String invoicedProductStatus, int productNumber,
      int index) {

    Color productItemStatusColor = ColorsResources.lightTransparent;

    if (invoicedProductStatus == InvoicedProductsData.Product_Purchased) {

      productItemStatusColor = ColorsResources.blueGreen;

    } else if (invoicedProductStatus == InvoicedProductsData.Product_Returned) {

      productItemStatusColor = ColorsResources.red;

    }

    return Container(
        width: 173,
        height: 37,
        margin: EdgeInsets.fromLTRB(0, 0, 5, 0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(51),
            color: productItemStatusColor.withOpacity(0.13)
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
                flex: 2,
                child: InkWell(
                    onTap: () async {

                      if (widget.sellInvoicesData == null) {

                        selectedProductsData.remove(productsData);

                        updateSelectedProductsList(selectedProductsData);

                      } else {

                        String databaseDirectory = await getDatabasesPath();

                        String invoicedProductDatabasePath = "${databaseDirectory}/${InvoicedProductsDatabaseInputs.invoicedProductsDatabase(timeNow)}";

                        bool invoicedProductsDatabaseExist = await databaseExists(invoicedProductDatabasePath);

                        if (invoicedProductsDatabaseExist) {

                          InvoicedProductsQueries invoicedProductsQueries = InvoicedProductsQueries();

                          InvoicedProductsData invoicedProductsData = await invoicedProductsQueries.queryInvoicedProductById(
                              productsData.id.toString(),
                              InvoicedProductsDatabaseInputs.invoicedProductsDatabase(timeNow),
                              InvoicedProductsDatabaseInputs.databaseTableName
                          );

                          if (invoicedProductsData.invoiceProductStatus == InvoicedProductsData.Product_Returned) { // Product Returned

                            invoicedProductsData.invoiceProductStatus = InvoicedProductsData.Product_Purchased;

                            /* Start - Calculate Invoice Price */
                            int previousInvoicePrice = int.parse(controllerInvoicePrice.text.replaceAll(",", ""));

                            controllerInvoicePrice.text = (previousInvoicePrice + int.parse(productsData.productPrice.replaceAll(",", ""))).toString();
                            /* End - Calculate Invoice Price */

                          } else if (invoicedProductsData.invoiceProductStatus == InvoicedProductsData.Product_Purchased) { // Product Purchased

                            invoicedProductsData.invoiceProductStatus = InvoicedProductsData.Product_Returned;

                            /* Start - Calculate Invoice Price */
                            int previousInvoicePrice = int.parse(controllerInvoicePrice.text.replaceAll(",", ""));

                            controllerInvoicePrice.text = (previousInvoicePrice - int.parse(productsData.productPrice.replaceAll(",", ""))).toString();
                            /* End - Calculate Invoice Price */

                          }

                          InvoicedProductsDatabaseInputs invoicedProductsDatabaseInputs = InvoicedProductsDatabaseInputs();

                          invoicedProductsDatabaseInputs.updateInvoicedData(
                              invoicedProductsData,
                              InvoicedProductsDatabaseInputs.invoicedProductsDatabase(timeNow),
                              InvoicedProductsDatabaseInputs.databaseTableName
                          );

                          prepareSelectedProducts();

                        }

                      }

                    },
                    child: Padding(
                        padding: EdgeInsets.fromLTRB(3, 0, 3, 0),
                        child: Align(
                            alignment: AlignmentDirectional.center,
                            child: Icon(
                              Icons.delete_rounded,
                              size: 19,
                              color: ColorsResources.darkTransparent,
                            )
                        )
                    )
                )
            ),
            Expanded(
              flex: 11,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(7, 0, 7, 0),
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      "${productsData.productName} ${productsData.productQuantityType} ${productsData.productQuantity}",
                      style: TextStyle(
                          color: ColorsResources.darkTransparent,
                          fontSize: 13,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  )
                )
              ),
            ),
            Expanded(
                flex: 5,
                child: Padding(
                    padding: EdgeInsets.fromLTRB(3, 0, 7, 0),
                    child: AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: productItemStatusColor.withOpacity(0.5)
                            ),
                            child: Padding(
                                padding: EdgeInsets.all(1),
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(51),
                                    child: Image.file(
                                      File(productsData.productImageUrl),
                                      fit: BoxFit.cover,
                                    )
                                )
                            )
                        )
                    )
                )
            ),
          ],
        )
    );
  }

  void updateProductQuantity() async {

    if (selectedProductsData.isNotEmpty) {

      String databaseDirectory = await getDatabasesPath();

      String productDatabasePath = "${databaseDirectory}/${ProductsDatabaseInputs.productsDatabase()}";

      bool productsDatabaseExist = await databaseExists(productDatabasePath);

      if (productsDatabaseExist) {

        ProductsDatabaseQueries productsDatabaseQueries = ProductsDatabaseQueries();

        for (var aProduct in selectedProductsData) {

          ProductsData currentProductData = await productsDatabaseQueries.querySpecificProductById(aProduct.id.toString(), ProductsDatabaseInputs.databaseTableName, UserInformation.UserId);

          currentProductData.productQuantity = currentProductData.productQuantity + aProduct.productQuantity;

          ProductsDatabaseInputs productsDatabaseInputs = ProductsDatabaseInputs();

          productsDatabaseInputs.updateProductData(currentProductData, ProductsDatabaseInputs.productsDatabase(), UserInformation.UserId);

        }

      }

    }

  }

  void insertInvoicedProducts() async {

    selectedProductsData.forEach((productData) {

      InvoicedProductsDatabaseInputs invoicesProductsDatabaseInputs = InvoicedProductsDatabaseInputs();

      invoicesProductsDatabaseInputs.insertInvoicedProductData(
          InvoicedProductsData(
              id: DateTime.now().millisecondsSinceEpoch,
              invoiceProductId: productData.id,
              invoiceProductName: productData.productName,
              invoiceProductQuantity: productData.productQuantity,
              invoiceProductQuantityType: productData.productQuantityType,
              invoiceProductPrice: productData.productPrice,
              invoiceProductStatus: InvoicedProductsData.Product_Purchased
          ),
          InvoicedProductsDatabaseInputs.invoicedProductsDatabase(timeNow),
          InvoicedProductsDatabaseInputs.databaseTableName
      );

    });

  }

  void updateInvoicedProducts() async {

    InvoicedProductsQueries invoicedProductsQueries = InvoicedProductsQueries();

    List<InvoicedProductsData> allInvoicedProducts = await invoicedProductsQueries.getAllInvoicedProducts(InvoicedProductsDatabaseInputs.invoicedProductsDatabase(timeNow), InvoicedProductsDatabaseInputs.databaseTableName);

    selectedProductsData.forEach((productData) {

      InvoicedProductsDatabaseInputs invoicesProductsDatabaseInputs = InvoicedProductsDatabaseInputs();

      InvoicedProductsData? alreadyPurchasedProduct = allInvoicedProducts.singleWhere((element) => (element.invoiceProductId == productData.id), orElse: null);

      if (alreadyPurchasedProduct != null) {

        invoicesProductsDatabaseInputs.updateInvoicedData(
            InvoicedProductsData(
                id: alreadyPurchasedProduct.id,
                invoiceProductId: alreadyPurchasedProduct.invoiceProductId,
                invoiceProductName: alreadyPurchasedProduct.invoiceProductName,
                invoiceProductQuantity: productData.productQuantity,
                invoiceProductQuantityType: productData.productQuantityType,
                invoiceProductPrice: productData.productPrice,
                invoiceProductStatus: InvoicedProductsData.Product_Purchased
            ),
            InvoicedProductsDatabaseInputs.invoicedProductsDatabase(timeNow),
            InvoicedProductsDatabaseInputs.databaseTableName
        );

      } else {


        invoicesProductsDatabaseInputs.insertInvoicedProductData(
            InvoicedProductsData(
                id: DateTime.now().millisecondsSinceEpoch,
                invoiceProductId: productData.id,
                invoiceProductName: productData.productName,
                invoiceProductQuantity: productData.productQuantity,
                invoiceProductQuantityType: productData.productQuantityType,
                invoiceProductPrice: productData.productPrice,
                invoiceProductStatus: InvoicedProductsData.Product_Purchased
            ),
            InvoicedProductsDatabaseInputs.invoicedProductsDatabase(timeNow),
            InvoicedProductsDatabaseInputs.databaseTableName
        );


      }

    });

  }
  /*
   * End - Invoiced Products
   */

  /*
   * Start - Related Cheques
   */
  void insertRelatedCheques(String chequeNumber) async {

    if (controllerCheques.text.isNotEmpty) {

      ChequesDatabaseInputs chequesDatabaseInputs = ChequesDatabaseInputs();

      ChequesDatabaseQueries chequesDatabaseQueries = ChequesDatabaseQueries();

      ChequesData? aChequeData = null;

      String databaseDirectory = await getDatabasesPath();

      String chequeDatabasePath = "${databaseDirectory}/${ChequesDatabaseInputs.chequesDatabase()}";

      bool chequesDatabaseExist = await databaseExists(chequeDatabasePath);

      if (chequesDatabaseExist) {

        aChequeData = await chequesDatabaseQueries.querySpecificChequesByNumber(chequeNumber, ChequesDatabaseInputs.databaseTableName, UserInformation.UserId);

      }

      if (aChequeData == null) {

        controllerInvoiceNumber.text = controllerInvoiceNumber.text.isEmpty ? timeNow.toString() : controllerInvoiceNumber.text;

        await chequesDatabaseInputs.insertChequeData(ChequesData(id: DateTime.now().millisecondsSinceEpoch,
            chequeTitle: controllerInvoiceNumber.text,
            chequeDescription: "",
            chequeNumber: controllerChequeNumber.text,
            chequeMoneyAmount: controllerChequeMoneyAmount.text,
            chequeTransactionType: "",
            chequeSourceBankName: "",
            chequeSourceBankBranch: "",
            chequeTargetBankName: "",
            chequeIssueDate: TimeIO().humanReadableFarsi(DateTime.now()),
            chequeDueDate: TimeIO().humanReadableFarsi(calendarChequeDueView.pickedDateTime),
            chequeIssueMillisecond: DateTime.now().millisecondsSinceEpoch.toString(),
            chequeDueMillisecond: calendarChequeDueView.pickedDateTime.millisecondsSinceEpoch.toString(),
            chequeSourceId: "",
            chequeSourceName: "",
            chequeSourceAccountNumber: "",
            chequeTargetId: "",
            chequeTargetName: controllerChequeName.text,
            chequeTargetAccountNumber: "",
            chequeDoneConfirmation: ChequesData.ChequesConfirmation_NOT,
            chequeRelevantCreditCard: "",
            chequeRelevantBudget: "",
            chequeCategory: "",
            chequeExtraDocument: "",
            colorTag: colorSelectorView.selectedColor.value),
            ChequesDatabaseInputs.databaseTableName, UserInformation.UserId);

        prepareRelatedCheques();

        controllerChequeNumber.text = "";
        controllerChequeName.text = "";
        controllerChequeMoneyAmount.text = "";

        debugPrint("Cheque Related to Invoice ${controllerInvoiceNumber.text} Added");
      }

    }

  }

  void prepareRelatedCheques() async {

    relatedChequesWidget.clear();

    List<ChequesData> allRelatedCheques = [];

    ChequesDatabaseQueries chequesDatabaseQueries = ChequesDatabaseQueries();

    List<String> chequesNumbers = cleanUpCsvDatabase(controllerChequeNumber.text).split(",");

    chequesNumbers.forEach((element) async {

      ChequesData? chequesData = await chequesDatabaseQueries.querySpecificChequesByNumber(element, ChequesDatabaseInputs.databaseTableName, UserInformation.UserId);

      if (chequesData != null) {

        allRelatedCheques.add(chequesData);

      }

    });

    allRelatedCheques.forEach((relatedChequeData) {

      relatedChequesWidget.add(relatedChequesItemView(relatedChequeData));

    });

    setState(() {

      relatedChequesWidget;

    });

  }

  Widget relatedChequesItemView(ChequesData chequesData) {

    return Container(
        width: 173,
        height: 37,
        margin: EdgeInsets.fromLTRB(0, 0, 5, 0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(51),
            color: ColorsResources.lightGreen.withOpacity(0.13)
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
                flex: 2,
                child: InkWell(
                    onTap: () async {

                      controllerChequeNumber.text.replaceAll("${chequesData.chequeNumber},", "");

                      ChequesDatabaseQueries chequesDatabaseQueries = ChequesDatabaseQueries();

                      await chequesDatabaseQueries.queryDeleteCheque(chequesData.id, ChequesDatabaseInputs.databaseTableName, UserInformation.UserId);

                      prepareRelatedCheques();

                    },
                    child: Padding(
                        padding: EdgeInsets.fromLTRB(3, 0, 3, 0),
                        child: Align(
                            alignment: AlignmentDirectional.center,
                            child: Icon(
                              Icons.delete_rounded,
                              size: 19,
                              color: ColorsResources.darkTransparent,
                            )
                        )
                    )
                )
            ),
            Expanded(
              flex: 15,
              child: InkWell(
                onTap: () async {

                  bool chequeDataUpdated = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChequesInputView(chequesData: chequesData)),
                  );

                  debugPrint("Cheque Data Update => ${chequeDataUpdated}");
                  if (chequeDataUpdated) {

                    prepareRelatedCheques();

                  }

                },
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(7, 0, 7, 0),
                    child: Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: Directionality(
                          textDirection: TextDirection.rtl,
                          child: Text(
                            "${chequesData.chequeMoneyAmount} - ${chequesData.chequeNumber}",
                            style: TextStyle(
                                color: ColorsResources.darkTransparent,
                                fontSize: 13,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        )
                    )
                ),
              )
            ),
          ],
        )
    );
  }
  /*
   * End - Related Cheques
   */

  /*
   * Start - Customer Purchases
   */
  void updateCustomerPurchases(SellInvoicesData sellInvoicesData) async {

    String databaseDirectory = await getDatabasesPath();

    String customerDatabasePath = "${databaseDirectory}/${CustomersDatabaseInputs.customersDatabase()}";

    bool customerDatabaseExist = await databaseExists(customerDatabasePath);

    if (customerDatabaseExist) {

      CustomersDatabaseQueries customersDatabaseQueries = CustomersDatabaseQueries();

      List<CustomersData> retrievedCustomers = await customersDatabaseQueries.getAllCustomers(CustomersDatabaseInputs.databaseTableName, UserInformation.UserId);

      if (retrievedCustomers.isNotEmpty) {

        for (int i = 0; i < retrievedCustomers.length; i++) {

          if (retrievedCustomers[i].customerName == sellInvoicesData.soldTo) {

            CustomersData customersData = retrievedCustomers[i];

            customersData.customerPurchases = (int.parse(customersData.customerPurchases.replaceAll(",", ""))
                + (int.parse(sellInvoicesData.soldProductPrice.replaceAll(",", "")))).toString();

            CustomersDatabaseInputs customersDatabaseInputs = CustomersDatabaseInputs();

            customersDatabaseInputs.updateCustomerData(customersData, CustomersDatabaseInputs.databaseTableName, UserInformation.UserId);

            break;

          }

        }

      }

    }

  }
  /*
   * End - Customer Purchases
   */

  Future<List<CreditCardsData>> getAllCreditCards() async {

    List<CreditCardsData> allCreditCards = [];

    String databaseDirectory = await getDatabasesPath();

    String creditCardDatabasePath = "${databaseDirectory}/${CreditCardsDatabaseInputs.creditCardDatabase()}";

    bool creditCardDatabaseExist = await databaseExists(creditCardDatabasePath);

    if (creditCardDatabaseExist) {

      CreditCardsDatabaseQueries databaseQueries = CreditCardsDatabaseQueries();

      List<CreditCardsData> listOfAllCreditCards = await databaseQueries.getAllCreditCards(CreditCardsDatabaseInputs.databaseTableName, UserInformation.UserId);

      setState(() {

        allCreditCards = listOfAllCreditCards;

      });

    }

    return allCreditCards;
  }

  Future<List<dynamic>> getAllDebtorsAndCustomers() async {

    String databaseDirectory = await getDatabasesPath();

    List<dynamic> listOfNames = [];

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

  void invokeLogoImagePicker() async {

    final ImagePicker imagePicker = ImagePicker();

    final XFile? selectedImage = await imagePicker.pickImage(source: ImageSource.gallery);

    if (selectedImage != null) {

      String fileName = "${UserInformation.UserId}_LOGO.PNG";

      companyLogoUrl = await getFilePath(fileName);

      var imageFileByte = await selectedImage.readAsBytes();

      savePickedImageFile(companyLogoUrl, imageFileByte);

      setState(() {

        imageLogoPickerWidget = Image.file(
          File(selectedImage.path),
          fit: BoxFit.cover,
        );

      });

    }

    debugPrint("Picked Image Path: $companyLogoUrl");

  }

  void invokeSignatureImagePicker() async {

    final ImagePicker imagePicker = ImagePicker();

    final XFile? selectedImage = await imagePicker.pickImage(source: ImageSource.gallery);

    if (selectedImage != null) {

      String fileName = "${UserInformation.UserId}_SIGNATURE.PNG";

      companyDigitalSignature = await getFilePath(fileName);

      var imageFileByte = await selectedImage.readAsBytes();

      savePickedImageFile(companyDigitalSignature, imageFileByte);

      setState(() {

        imageSignaturePickerWidget = Image.file(
          File(selectedImage.path),
          fit: BoxFit.contain,
        );

      });

    }

    debugPrint("Picked Image Path: $companyDigitalSignature");

  }

  Future<String> getFilePath(String fileName) async {

    Directory appDocumentsDirectory = await getApplicationSupportDirectory();

    String appDocumentsPath = appDocumentsDirectory.path;

    String filePath = '$appDocumentsPath/$fileName';

    return filePath;
  }

  void savePickedImageFile(String imageFilePath, Uint8List imageBytes) async {

    File file = File(imageFilePath);

    file.writeAsBytes(imageBytes);

  }

  void prepareAllImagesCheckpoint() async {

    if (widget.sellInvoicesData != null) {

      /* Start - Company Logo */
      imageLogoPickerWidget = Image.file(
        File(widget.sellInvoicesData!.companyLogoUrl),
        fit: BoxFit.cover,
      );
      /* End - Company Logo */

      /* Start - Barcode Image */
      bool barcodeFileCheckpoint = await fileExist("SellInvoices_${widget.sellInvoicesData!.id}.PNG");

      Widget barcodeGenerator = Screenshot(
        controller: barcodeSnapshotController,
        child: SfBarcodeGenerator(
          value: "SellInvoices_${widget.sellInvoicesData!.id.toString()}",
          symbology: QRCode(),
          barColor: ColorsResources.primaryColor,
        ),
      );

      barcodeView = ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: ColoredBox(
              color: ColorsResources.lightestBlue.withOpacity(0.91),
              child: Padding(
                  padding: EdgeInsets.fromLTRB(9, 9, 9, 9),
                  child:  SizedBox(
                      height: 131,
                      width: 131,
                      child: InkWell(
                          onTap: () async {

                            if (barcodeFileCheckpoint) {

                              Directory appDocumentsDirectory = await getApplicationSupportDirectory();

                              String appDocumentsPath = appDocumentsDirectory.path;

                              String filePath = '$appDocumentsPath/SellInvoices_${widget.sellInvoicesData!.id}.PNG';

                              Share.shareFiles([filePath],
                                  text: "${widget.sellInvoicesData!.sellInvoiceDescription}");

                            }

                          },
                          child: barcodeGenerator
                      )
                  )
              )
          )
      );

      Future.delayed(Duration(milliseconds: 333), () {

        if (!barcodeFileCheckpoint) {

          barcodeSnapshotController.capture().then((Uint8List? imageBytes) {
            debugPrint("Barcode Captured");

            if (imageBytes != null) {

              createFileOfBytes("Product_${widget.sellInvoicesData!.id}", "PNG", imageBytes);

            }

          });

        }

      });
      /* End - Barcode Image */

    }

    /* Start - Signature */
    bool signatureCheckpoint = await fileExist("${UserInformation.UserId}_SIGNATURE.PNG");

    if (signatureCheckpoint) {

      Directory appDocumentsDirectory = await getApplicationSupportDirectory();

      String appDocumentsPath = appDocumentsDirectory.path;

      String filePath = '$appDocumentsPath/${UserInformation.UserId}_SIGNATURE.PNG';

      imageSignaturePickerWidget = Image.file(
        File(filePath),
        fit: BoxFit.contain,
      );

    }
    /* End - Signature */

    setState(() {

      barcodeView;

      imageLogoPickerWidget;

      imageSignaturePickerWidget;

    });

    Future.delayed(Duration(milliseconds: 357), () {

      prepareSelectedProducts();

    });

  }

  Future<List<String>> getQuantityTypes() async {

    return StringsResources.quantityTypesList();
  }

  List<String> removeEmptyElementCsv(List<String> inputList) {

    List<String> cleanCsvList = [];

    inputList.forEach((element) {

      if (element.isNotEmpty) {

        cleanCsvList.add(element);

      }

    });

    return cleanCsvList;
  }

  String cleanUpCsvDatabase(String inputCsvData) {

    String clearCsvDatabase = "";

    if (inputCsvData.isNotEmpty) {

      List<String> csvData = removeEmptyElementCsv(inputCsvData.split(","));

      csvData.forEach((element) {

        clearCsvDatabase += "${element},";

      });

    }

    return clearCsvDatabase;
  }

  void generateBarcode(int databaseId) async {

    /* Start - Barcode Image */
    bool barcodeFileCheckpoint = await fileExist("SellInvoices_${databaseId}.PNG");

    Widget barcodeGenerator = Screenshot(
      controller: barcodeSnapshotController,
      child: SfBarcodeGenerator(
        value: "SellInvoices_${databaseId.toString()}",
        symbology: EAN8(),
        barColor: ColorsResources.primaryColor,
      ),
    );

    barcodeView = ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: ColoredBox(
            color: ColorsResources.lightestBlue.withOpacity(0.91),
            child: Padding(
                padding: EdgeInsets.fromLTRB(9, 9, 9, 9),
                child:  SizedBox(
                    height: 131,
                    width: 131,
                    child: InkWell(
                        onTap: () async {

                          if (barcodeFileCheckpoint) {

                            Directory appDocumentsDirectory = await getApplicationSupportDirectory();

                            String appDocumentsPath = appDocumentsDirectory.path;

                            String filePath = '$appDocumentsPath/SellInvoices_${databaseId}.PNG';

                            Share.shareFiles([filePath],
                                text: "${widget.sellInvoicesData!.sellInvoiceDescription}");

                          }

                        },
                        child: barcodeGenerator
                    )
                )
            )
        )
    );

    Future.delayed(Duration(milliseconds: 333), () {

      if (!barcodeFileCheckpoint) {

        barcodeSnapshotController.capture().then((Uint8List? imageBytes) {
          debugPrint("Barcode Captured");

          if (imageBytes != null) {

            createFileOfBytes("Product_${databaseId}", "PNG", imageBytes);

          }

        });

      }

    });
    /* End - Barcode Image */

    setState(() {

      barcodeView;

    });

  }

}