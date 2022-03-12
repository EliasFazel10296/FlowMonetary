/*
 * Copyright © 2022 By Geeks Empire.
 *
 * Created by Elias Fazel
 * Last modified 1/13/22, 6:44 AM
 *
 * Licensed Under MIT License.
 * https://opensource.org/licenses/MIT
 */

import 'package:flow_accounting/profile/input/ui/profile_input_view.dart';
import 'package:flow_accounting/resources/StringsResources.dart';
import 'package:flow_accounting/utils/navigations/navigations.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class TopBarView extends StatelessWidget {
  const TopBarView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Padding(padding: const EdgeInsets.fromLTRB(13, 0, 13, 0),
      child: SizedBox(
        width: double.infinity,
        height: 51,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(3, 1, 3, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                  flex: 3,
                  child: GestureDetector(
                    onTap: () {

                      Share.share(StringsResources.sharingText);

                    },
                    child:  const Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        height: 43,
                        width: 43,
                        child: Image(image: AssetImage("share_icon.png")),
                      ),
                    ),
                  )
              ),
              Expanded(
                  flex: 3,
                  child: GestureDetector(
                    onTap: () async {

                      await launch(StringsResources.instagramLink);

                    },
                    child:  const Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        height: 43,
                        width: 43,
                        child: Image(image: AssetImage("instagram_icon.png")),
                      ),
                    ),
                  )
              ),
              Expanded(
                  flex: 9,
                  child: Container(
                    color: Colors.transparent,
                  )
              ),
              Expanded(
                  flex: 3,
                  child: GestureDetector(
                    onTap: () {

                      NavigationProcess().goTo(context, ProfilesInputView());

                    },
                    child: const Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        height: 43,
                        width: 43,
                        child: Image(image: AssetImage("add_profile_icon.png")),
                      ),
                    ),
                  )
              ),
            ],
          ),
        ),
      )
    );
  }
}