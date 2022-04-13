import 'package:flutter/material.dart';
import 'package:hello_me/utils.dart';
import 'auth_state.dart';
import 'package:provider/provider.dart';
import 'favoritesUtils.dart';


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
        child: Column(
          children: <Widget>[
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(top: 20),
              child: const Text(
                'Welcome to Startup Names Generator, please log in below',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 16),
              ),
            ),
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(10),
              child: TextFormField(
                decoration: const InputDecoration(
                  // border: OutlineInputBorder(),
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
                controller: passwordController,
              ),
            ),
            authUser.status == Status.Authenticating
            ? const CircularProgressIndicator(color: Colors.deepPurple)
            : Container(
                margin: const EdgeInsets.all(20),
                width: double.infinity, // <-- match_parent
                child: Consumer<AuthUser>(builder: (context1, authUser, child) {
                  return Consumer<UserFavorites>(builder: (context2, userFavorites, child) {
                  return ElevatedButton(
                      onPressed: () async {
                        // ScaffoldMessenger.of(context).showSnackBar(
                        //   const SnackBar(content: Text('Login is not implemented yet')),
                        // );
                        bool res = await authUser
                            .signIn(context1, emailController.text,
                            passwordController.text);
                        // Timer(Duration(seconds: 5), () {
                        //   print("Yeah, this line is printed after 3 seconds");
                        print ("@@@@@@@@@@@@@@@@@@@ res is $res");
                        if (!res){
                          print ("@@@@@@@@@@@@@@@@@@@ res is false");
                          await showSnackBar(context: context,
                              text: "There was an error logging into the app");
                        }
                          else{
                            Navigator.pop(context);
                            await userFavorites.updateFromCloud(authUser);
                            await userFavorites.updateToCloud(authUser);
                          }
                        // });
                      },
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all<
                            RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                            )),
                        // padding: MaterialStateProperty.all<Size>(const EdgeInsets.only(left: Size.infinite, right: 10))
                      ),
                      child: Text('Log in'));
                });
              }),
            )],
        ));
  }
}