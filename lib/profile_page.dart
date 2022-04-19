import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapping_sheet/snapping_sheet.dart';
import 'auth_state.dart';

import 'cloud_firestore.dart';


class ProfileSheet extends ChangeNotifier {
  bool _toggleIsOpen = false;
  bool _dragIsUp = false;

  ProfileSheet();

  bool get toggleIsOpen => _toggleIsOpen;
  bool get dragIsUp => _dragIsUp;

  void updateToggle(bool val){
    _toggleIsOpen = val;
    notifyListeners();
  }
  void updateDrag(bool val){
    _dragIsUp = val;
    notifyListeners();
  }
}

class GrabbingWidget extends StatefulWidget {
  final SnappingSheetController snappingSheetController;

  const GrabbingWidget({Key? key,
    required this.snappingSheetController}) : super(key: key);

  @override
  State<GrabbingWidget> createState() => _GrabbingWidgetState(snappingSheetController);
}

class _GrabbingWidgetState extends State<GrabbingWidget> {
  final SnappingSheetController snappingSheetController;

  _GrabbingWidgetState(this.snappingSheetController);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthUser>(builder: (context, authUser, child) {
      return Consumer<ProfileSheet>(builder: (context, profileSheet, child) {
      return GestureDetector(
          onVerticalDragStart: (details) {
          setState(() {
            if (profileSheet.toggleIsOpen && profileSheet.dragIsUp || snappingSheetController.currentPosition > 0.5 * MediaQuery.of(context).size.height) {
              snappingSheetController.snapToPosition(
                SnappingPosition.factor(
                  positionFactor: 0.0,
                  snappingCurve: Curves.easeOutExpo,
                  snappingDuration: Duration(seconds: 2),
                  grabbingContentOffset: GrabbingContentOffset.top,),);
              profileSheet.updateToggle(false);
              profileSheet.updateDrag(false);
            } else{
            snappingSheetController.snapToPosition(
            SnappingPosition.factor(
            snappingCurve: Curves.easeOutExpo,
            snappingDuration: Duration(milliseconds: 1500),
            grabbingContentOffset: GrabbingContentOffset.bottom,
            positionFactor: 0.7,),);
            profileSheet.updateToggle(true);
            profileSheet.updateDrag(true);
            }
          });
        },
          onTap: () {
            setState(() {
              profileSheet.updateToggle(!profileSheet.toggleIsOpen);
              if (profileSheet.toggleIsOpen){
              snappingSheetController.snapToPosition(
                  SnappingPosition.factor(
                    grabbingContentOffset: GrabbingContentOffset.bottom,
                    snappingCurve: Curves.easeOutExpo,
                    snappingDuration: Duration(seconds: 1),
                    positionFactor: 0.3,
                  )
              );
              } else {
              snappingSheetController.snapToPosition(
                  SnappingPosition.factor(
                    positionFactor: 0.0,
                    snappingCurve: Curves.easeOutExpo,
                    snappingDuration: Duration(seconds: 1),
                    grabbingContentOffset: GrabbingContentOffset.top,
                  ));
              }
            });
          },
          child: Container(
            color: Color.fromARGB(255, 201, 201, 201),
            width: 100,
            height: 7,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    'Welcome back, ${authUser.user?.email}',
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Icon(
                    // <-- Icon
                      Icons.keyboard_arrow_up,
                      color: Colors.black),
                ),
              ],
            ),
          ));
    });
  });
  }
}


class UserProfilePic extends ChangeNotifier {
  String? _profilePicRef;

  UserProfilePic() : _profilePicRef = null;

  String? get profilePicRef => _profilePicRef;

  void simplePicUpdateNull(){
    _profilePicRef = null;
    notifyListeners();
  }

  Future<void> updatePicToCloud(AuthUser authUser, String photoURL) async {
    String email = authUser.user?.email ?? "";
    if (email != "") {
      if (authUser.isAuthenticated) {
        try {
          await FirebaseInit()
              .db()
              .collection('users')
              .doc(email)
              .update({'profilePic': photoURL});
          notifyListeners();
        } catch (e) {
          print("##### having a problem updatePhotoToCloud");
        }
      }
    }
  }

  Future<void> updatePicFromCloud(AuthUser authUser) async {
    String email = authUser.user?.email ?? "";
    if (email != "") {
      print("****** updateFromCloud 333 $email");
      if (authUser.isAuthenticated) {
        print("****** updateFromCloud 333 auth true");
        try {
          await FirebaseInit()
              .db()
              .collection('users')
              .doc(email)
              .get()
              .then((DocumentSnapshot ds) {
            if (!ds.exists) {
              _profilePicRef = null;
            } else {
              print("****** IN ELSE PIC");
              _profilePicRef = ds["profilePic"];
              notifyListeners();
            }
          });
        } catch (e) {
          print("****** having a problem updatePicFromCloud");
          _profilePicRef = null;
        }
      }
    }
  }
}
