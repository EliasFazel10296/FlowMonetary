/*
 * Copyright © 2022 By Geeks Empire.
 *
 * Created by Elias Fazel
 * Last modified 4/4/22, 4:45 AM
 *
 * Licensed Under MIT License.
 * https://opensource.org/licenses/MIT
 */

import 'dart:ui';

import 'package:flow_accounting/resources/ColorsResources.dart';
import 'package:flow_accounting/resources/StringsResources.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'features_view.dart';

class SearchBarView extends StatefulWidget {

  List<FeaturesStructure> initialFeaturesStructure = [];

  SearchBarView({Key? key, required this.initialFeaturesStructure}) : super(key: key);

  ValueNotifier<List<FeaturesStructure>> searchableFeaturesList = ValueNotifier([]);
  ValueNotifier<bool> resetFeaturesList = ValueNotifier(false);

  @override
  State<SearchBarView> createState() => _SearchBarView();

}
class _SearchBarView extends State<SearchBarView> {

  TextEditingController textEditorControllerQuery = TextEditingController();

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

    return Padding(
      padding: const EdgeInsets.fromLTRB(13, 19, 13, 3),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 50,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(1, 1, 1, 1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(1, 1, 1, 1),
                          child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(13),
                                      topRight: Radius.circular(13),
                                      bottomLeft: Radius.circular(13),
                                      bottomRight: Radius.circular(13)
                                  ),
                                  border: Border(
                                      top: BorderSide(
                                        color: ColorsResources.applicationGeeksEmpire.withOpacity(0.7),
                                        width: 1,
                                      ),
                                      bottom: BorderSide(
                                        color: ColorsResources.applicationGeeksEmpire.withOpacity(0.7),
                                        width: 1,
                                      ),
                                      left: BorderSide(
                                        color: ColorsResources.applicationGeeksEmpire.withOpacity(0.7),
                                        width: 1,
                                      ),
                                      right: BorderSide(
                                        color: ColorsResources.applicationGeeksEmpire.withOpacity(0.7),
                                        width: 1,
                                      )
                                  ),
                                  color: ColorsResources.primaryColorLightest,
                                  boxShadow: [
                                    BoxShadow(
                                        color: ColorsResources.applicationGeeksEmpire.withOpacity(0.7),
                                        blurRadius: 73,
                                        spreadRadius: 7,
                                        offset: const Offset(-7.0, 0.0)
                                    )
                                  ]
                              ),
                              alignment: AlignmentDirectional.center,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(13),
                                child: Material(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                                  shadowColor: Colors.transparent,
                                  color: Colors.transparent,
                                  child: InkWell(
                                    splashColor: ColorsResources.applicationGeeksEmpire.withOpacity(0.5),
                                    splashFactory: InkRipple.splashFactory,
                                    onDoubleTap: () {

                                      Future.delayed(const Duration(milliseconds: 199), () {

                                        widget.resetFeaturesList.value = true;

                                      });

                                    },
                                    onTap: () {

                                      String searchQuery = textEditorControllerQuery.text;

                                      List<FeaturesStructure> foundAllFeaturesStructure = [];
                                      foundAllFeaturesStructure.clear();

                                      for (var element in widget.initialFeaturesStructure) {

                                        if (element.featuresTitle.contains(searchQuery) ||
                                            element.featuresDescription.contains(searchQuery)) {

                                          foundAllFeaturesStructure.add(element);

                                        }

                                      }

                                      widget.searchableFeaturesList.value.clear();

                                      Future.delayed(const Duration(milliseconds: 199), () {

                                        widget.searchableFeaturesList.value = foundAllFeaturesStructure;

                                      });

                                    },
                                    child: const SizedBox(
                                      height: 50,
                                      width: 50,
                                      child: Icon(Icons.search_sharp,
                                          size: 23.0,
                                          color: ColorsResources.applicationDarkGeeksEmpire
                                      ),
                                    ),
                                  )
                                )
                              )
                          )
                      )
                  ),
                  Expanded(
                      flex: 17,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(7, 1, 3, 1),
                        child: Container(
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(13),
                                  topRight: Radius.circular(13),
                                  bottomLeft: Radius.circular(13),
                                  bottomRight: Radius.circular(13)
                              ),
                              color: ColorsResources.primaryColorLightest,
                            ),
                            child: Directionality(
                              textDirection: TextDirection.rtl,
                              child: TypeAheadField<FeaturesStructure>(
                                  suggestionsCallback: (pattern) async {

                                    return await getAllFeatures();
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
                                                  suggestion.featuresTitle.toString(),
                                                  style: TextStyle(
                                                      color: ColorsResources.blueGray.withOpacity(0.79),
                                                      fontSize: 17
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                    );
                                  },
                                  onSuggestionSelected: (searchQuery) {

                                    List<FeaturesStructure> foundAllFeaturesStructure = [];
                                    foundAllFeaturesStructure.clear();

                                    for (var element in widget.initialFeaturesStructure) {

                                      if (element.featuresTitle.contains(searchQuery.featuresTitle) ||
                                          element.featuresDescription.contains(searchQuery.featuresTitle)) {

                                        foundAllFeaturesStructure.add(element);

                                      }

                                    }

                                    widget.searchableFeaturesList.value.clear();

                                    Future.delayed(const Duration(milliseconds: 199), () {

                                      widget.searchableFeaturesList.value = foundAllFeaturesStructure;

                                    });

                                  },
                                  errorBuilder: (context, suggestion) {

                                    return Padding(
                                        padding: EdgeInsets.fromLTRB(13, 7, 13, 7),
                                        child: Text(StringsResources.nothingText())
                                    );
                                  },
                                  suggestionsBoxDecoration: SuggestionsBoxDecoration(
                                      elevation: 7,
                                      color: ColorsResources.primaryColorLightest,
                                      shadowColor: ColorsResources.darkTransparent,
                                      borderRadius: BorderRadius.circular(17)
                                  ),
                                  textFieldConfiguration: TextFieldConfiguration(
                                    controller: textEditorControllerQuery,
                                    textInputAction: TextInputAction.search,
                                    cursorColor: ColorsResources.primaryColor,
                                    autocorrect: true,
                                    autofocus: false,
                                    textAlignVertical: TextAlignVertical.bottom,
                                    maxLines: 1,
                                    keyboardType: TextInputType.text,
                                    onSubmitted: (searchQuery) {

                                      List<FeaturesStructure> foundAllFeaturesStructure = [];
                                      foundAllFeaturesStructure.clear();

                                      for (var element in widget.initialFeaturesStructure) {

                                        if (element.featuresTitle.contains(searchQuery) ||
                                            element.featuresDescription.contains(searchQuery)) {

                                          foundAllFeaturesStructure.add(element);

                                        }

                                      }

                                      widget.searchableFeaturesList.value.clear();

                                      Future.delayed(const Duration(milliseconds: 199), () {

                                        widget.searchableFeaturesList.value = foundAllFeaturesStructure;

                                      });

                                    },

                                    decoration: InputDecoration(
                                      alignLabelWithHint: true,
                                      border: OutlineInputBorder(
                                          borderSide: BorderSide(color: ColorsResources.applicationGeeksEmpire, width: 1.0),
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(13),
                                              topRight: Radius.circular(13),
                                              bottomLeft: Radius.circular(13),
                                              bottomRight: Radius.circular(13)
                                          ),
                                          gapPadding: 5
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: ColorsResources.applicationGeeksEmpire, width: 1.0),
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(13),
                                              topRight: Radius.circular(13),
                                              bottomLeft: Radius.circular(13),
                                              bottomRight: Radius.circular(13)
                                          ),
                                          gapPadding: 5
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: ColorsResources.applicationGeeksEmpire, width: 1.0),
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(13),
                                              topRight: Radius.circular(13),
                                              bottomLeft: Radius.circular(13),
                                              bottomRight: Radius.circular(13)
                                          ),
                                          gapPadding: 5
                                      ),
                                      filled: false,
                                      fillColor: ColorsResources.lightTransparent,
                                      labelText: StringsResources.searchText(),
                                      labelStyle: const TextStyle(
                                          color: ColorsResources.dark,
                                          fontSize: 17.0
                                      ),
                                      hintText: StringsResources.searchFeaturesText(),
                                      hintStyle: const TextStyle(
                                          color: ColorsResources.darkTransparent,
                                          fontSize: 13.0
                                      ),
                                    ),
                                  )
                              )
                            )
                        ),
                      )
                  ),
                ],
              )
            )
          )
        ]
      ),
    );
  }

  Future<List<FeaturesStructure>> getAllFeatures() async {


    return widget.initialFeaturesStructure;
  }

}