import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_me/profile_page.dart';
import 'package:hello_me/utils.dart';
import 'auth_state.dart';
import 'package:provider/provider.dart';
import 'favoritesUtils.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  _LoginFormState createState() => _LoginFormState();
}

// This class holds the data related to the Form.
class _LoginFormState extends State<LoginForm> {
  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildLogin(context, emailController, passwordController);
  }

  Widget buildLogin(BuildContext context, TextEditingController emailController,
      TextEditingController passwordController) {
    var authUser = context.watch<AuthUser>();
    return Form(
        child: Consumer<ConfirmButton>(
        builder: (context0, confirmButton, child) {
          return Column(
        children: <Widget>[
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.only(top: 20),
            child: const Text(
              'Welcome to Startup Names Generator, please log in below',
              style: TextStyle(
                  color: Colors.black, fontWeight: FontWeight.w500, fontSize: 16),
            ),
          ),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(10),
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
              controller: emailController,
            ),
          ),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(10),
            child: TextFormField(
              decoration: const InputDecoration(
                // border: OutlineInputBorder(),
                labelText: 'Password',
              ),
              obscureText: true,
              controller: passwordController,
            ),
          ),
          authUser.status == Status.Authenticating && !confirmButton.confirmPressed
              ?
          const CircularProgressIndicator(color: Colors.deepPurple)
              : Container(
            margin: const EdgeInsets.only(top: 20, right: 20, left: 20),
            width: double.infinity, // <-- match_parent
            child: Consumer<AuthUser>(builder: (context1, authUser, child) {
              return Consumer<UserFavorites>(
                  builder: (context2, userFavorites, child) {
                    return Consumer<UserProfilePic>(
                        builder: (context3, userProfilePic, child) {
                          return ElevatedButton(
                              onPressed: () async {
                                bool res = await authUser.signIn(context1,
                                    emailController.text, passwordController.text);
                                print("@@@@@@@@@@@@@@@@@@@ res is $res");
                                if (!res) {
                                  print("@@@@@@@@@@@@@@@@@@@ res is false");
                                  await showSnackBar(
                                      context: context,
                                      text:
                                      "There was an error logging into the app");
                                } else {
                                  Navigator.pop(context);
                                  await userFavorites.updateFromCloud(authUser);
                                  await userFavorites.updateToCloud(authUser);
                                  await userProfilePic.updatePicFromCloud(authUser);
                                }
                                // });
                              },
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                )),
                                // padding: MaterialStateProperty.all<Size>(const EdgeInsets.only(left: Size.infinite, right: 10))
                              ),
                              child: Text('Log in'));
                        });
                  });
            }),
          ),
          Container(
            margin: const EdgeInsets.only(right: 20, left: 20),
            width: double.infinity, // <-- match_parent
            child: Consumer<AuthUser>(builder: (context1, authUser, child) {
              return Consumer<UserFavorites>(
                  builder: (context2, userFavorites, child) {
                    return Consumer<UserProfilePic>(
                        builder: (context3, userProfilePic, child) {
                          return ElevatedButton(
                              onPressed: () {
                                showMaterialModalBottomSheet(
                                  expand: false,
                                  context: context,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) => ModalFit(
                                      passwordController: passwordController,
                                      emailController: emailController),
                                );
                              },
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                    )),
                                backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.lightBlue),
                              ),
                              child: Text('New user? Click to sign up'));
                        });
                  });
            }),
          )
        ],
      );
    }));
  }
}

class ModalFit extends StatefulWidget {
  final passwordController;
  final emailController;

  const ModalFit(
      {Key? key,
      required this.passwordController,
      required this.emailController})
      : super(key: key);

  @override
  _ModalFitState createState() =>
      _ModalFitState(passwordController, emailController);
}

class ConfirmButton extends ChangeNotifier {
  bool _confirmPressed;

  ConfirmButton() : _confirmPressed = false;

  bool get confirmPressed => _confirmPressed;

  void pressConfirm() {
    _confirmPressed = true;
    // print("@@@@@@@@@@@@@2222 _confirmPressed $_confirmPressed");
    notifyListeners();
  }

  void resetConfirm() {
    _confirmPressed = false;
    // print("@@@@@@@@@@@@@3333 _confirmPressed $_confirmPressed");
    notifyListeners();
  }
}

class _ModalFitState extends State<ModalFit> {
  final passwordConfirmController = TextEditingController();
  final passwordController;
  final emailController;


  _ModalFitState(this.passwordController, this.emailController);

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    passwordConfirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
            child:  Consumer<AuthUser>(
        builder: (context1, authUser, child)
    {
      return SafeArea(
          top: false,
          child: authUser.status == Status.Authenticating ?
              Container(
          //   width: 100,
          height: 400,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(10),
                  child: const CircularProgressIndicator(color: Colors.deepPurple))
              : Form(
              key: _formKey,
              child: Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery
                        .of(context)
                        .viewInsets
                        .bottom),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(20),
                      // margin: const EdgeInsets.only(top: 20),
                      child: const Text(
                        'Please confirm your password below:',
                        style: TextStyle(
                            color: Colors.black,
                            // fontWeight: FontWeight.w500,
                            fontSize: 16),
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.only(
                          right: 20, left: 20, bottom: 20),
                      child: Theme(
                        data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.fromSwatch(
                              primarySwatch: primaryBlack,
                            )),
                        child: Consumer<ConfirmButton>(
                            builder: (context0, confirmButton, child) {
                              return Consumer<UserFavorites>(builder:
                                  (context2, userFavorites, child) {
                                return Consumer<UserProfilePic>(builder:
                                    (context3, userProfilePic, child) {
                                  return TextFormField(
                                    decoration: const InputDecoration(
                                      // border: OutlineInputBorder(),
                                      labelText: 'Password',
                                      labelStyle:
                                      TextStyle(color: Colors.black),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide:
                                        BorderSide(color: Colors.black),
                                      ),
                                      fillColor: Colors.black,
                                    ),
                                    obscureText: true,
                                    controller: passwordConfirmController,
                                    validator: (value) {
                                      if (confirmButton.confirmPressed &&
                                          value ==
                                              passwordController.text) {
                                        authUser
                                            .signUp(emailController.text,
                                            passwordController.text)
                                            .then((value) {
                                          if (value == null) {
                                            print(
                                                "~~~~~~~~~~~~~~~~~ VALUE IS NULL");
                                            Navigator.pop(context);
                                            showSnackBar(
                                                context: context,
                                                text:
                                                "There was an error logging into the app");
                                          } else {
                                            Navigator.pop(context);
                                            print("~~~~~~~~~~~~~~~~~ POP");
                                            Navigator.pop(context);
                                            print("~~~~~~~~~~~~~~~~~ POP2");
                                            userFavorites
                                                .updateFromCloud(authUser)
                                                .then((value) {
                                              print(
                                                  "~~~~~~~~~~~~~~~~~ SUCCESS updateFromCloud");
                                              userFavorites
                                                  .updateToCloud(authUser);
                                            }).then((value) {
                                              print(
                                                  "~~~~~~~~~~~~~~~~~ SUCCESS updateToCloud");
                                            }).then((value)
                                            {userProfilePic.simplePicUpdateNull();});
                                            confirmButton.resetConfirm();
                                          }
                                          return null;
                                        });
                                      } else {
                                        setState(() {
                                          confirmButton.resetConfirm();
                                        });
                                        return 'Passwords must match';
                                      }
                                    },
                                  );
                                });
                              });
                              // });
                            }),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                          right: 20, left: 20, bottom: 20),
                      child: Consumer<ConfirmButton>(
                          builder: (context0, confirmButton, child) {
                            return Consumer<AuthUser>(
                                builder: (context1, authUser, child) {
                                  return Consumer<UserFavorites>(
                                      builder: (context2, userFavorites,
                                          child) {
                                        return Consumer<UserProfilePic>(builder:
                                            (context3, userProfilePic, child) {
                                          return TextButton(
                                              onPressed: () {
                                                confirmButton.pressConfirm();
                                                _formKey.currentState!
                                                    .validate();
                                              },
                                              style: TextButton.styleFrom(
                                                  primary: Colors.white,
                                                  backgroundColor: Colors
                                                      .lightBlue,
                                                  fixedSize: Size.fromWidth(
                                                      80)),
                                              child: Text('Confirm'));
                                        });
                                      });
                                });
                          }),
                    )
                  ],
                ),
              )));
    }),
    );
  }
}
