import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:redesign/modulos/login/forgot_password.dart';
import 'package:redesign/modulos/registration/registration_options.dart';
import 'package:redesign/modulos/user/institution.dart';
import 'package:redesign/modulos/user/user.dart';
import 'package:redesign/services/my_app.dart';
import 'package:redesign/styles/style.dart';
import 'package:redesign/widgets/standard_button.dart';

FirebaseUser mCurrentUser;
FirebaseAuth _auth = FirebaseAuth.instance;

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomPadding: true,
      body: Center(
        child: Container(
          color: Style.darkBackground,
          child: ListView(
            children: <Widget>[
              Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 50, bottom: 50),
                    child: Hero(
                      tag: "redesign-logo",
                      child: Image.asset(
                        'images/rede_logo.png',
                        fit: BoxFit.contain,
                        width: 200,
                      ),
                    ),
                  ),
                  _LoginPage(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginPage extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<_LoginPage> {
  bool showingLogin = false;

  Future<bool> _onWillPop() {
    return _onBack();
  }

  _onBack() {
    setState(() {
      showingLogin = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return showingLogin
        ? WillPopScope(child: _LoginForm(), onWillPop: _onWillPop)
        : Container(
            padding: EdgeInsets.all(12.0),
            child: Column(
              children: [
                Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: StandardButton("Entrar", showLogin,
                        Style.main.primaryColor, Style.lightGrey)),
                StandardButton("Cadastrar-se", openSignUpScreen,
                    Style.buttonDarkGrey, Style.lightGrey),
              ],
            ),
          );
  }

  showLogin() {
    setState(() {
      showingLogin = true;
    });
  }

  openSignUpScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegistrationOptions()),
    );
  }
}

class _LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  bool blocked = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  FocusNode focusPassword = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.0),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: TextField(
              style: TextStyle(
                  decorationColor: Style.lightGrey, color: Colors.white),
              cursorColor: Style.buttonBlue,
              decoration: InputDecoration(
                labelText: 'E-mail',
                labelStyle: TextStyle(color: Colors.white54),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white54),
                ),
              ),
              controller: emailController,
              textInputAction: TextInputAction.next,
              onSubmitted: (v) {
                FocusScope.of(context).requestFocus(focusPassword);
              },
            ),
          ),
          TextField(
            style: TextStyle(
                decorationColor: Style.lightGrey, color: Colors.white),
            cursorColor: Style.buttonBlue,
            decoration: InputDecoration(
              labelText: 'Senha',
              labelStyle: TextStyle(color: Colors.white54),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white54),
              ),
            ),
            obscureText: true,
            controller: passwordController,
            textInputAction: TextInputAction.send,
            focusNode: focusPassword,
            onSubmitted: (v) {
              login();
            },
          ),
          GestureDetector(
            child: Container(
              padding: EdgeInsets.only(top: 12, bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text("Esqueci a senha",
                      style: TextStyle(
                          color: Style.primaryColorLighter,
                          fontWeight: FontWeight.w300,
                          fontSize: 12.0),
                      textAlign: TextAlign.end),
                ],
              ),
            ),
            onTap: forgotPassword,
          ),
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: StandardButton(
                "Entrar", login, Style.main.primaryColor, Style.lightGrey),
          ),
        ],
      ),
    );
  }

  /// Tenta logar o usuário pelo email e senha do formulário
  login() async {
    FocusScope.of(context).requestFocus(new FocusNode());
    if (blocked) return;
    blocked = true;

    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      _showMessageError("Preencha todos os campos.");
      blocked = false;
      return;
    }

    _logging(true);
    await _auth
        .signInWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text)
        .then((result) => authSuccess(result.user))
        .catchError(findUserError);
  }

  void authSuccess(FirebaseUser user) {
    print("autenticado");
    MyApp.firebaseUser = user;
    Firestore.instance
        .collection(User.collectionName)
        .document(user.uid)
        .get()
        .then(findUser)
        .catchError(findUserError);
  }

  void findUser(DocumentSnapshot snapshot) {
    if (snapshot.data['tipo'] == UserType.institution.index) {
      MyApp.setUser(
          Institution.fromMap(snapshot.data, reference: snapshot.reference));
    } else {
      MyApp.setUser(User.fromMap(snapshot.data, reference: snapshot.reference));
    }

    if (!MyApp.active()) {
      _logging(false);
      inactiveUserError();
      return;
    }
    _logging(false);
    Navigator.pushReplacementNamed(context, '/');
    blocked = false;
  }

  void inactiveUserError() {
    _inactiveAccountError();
    blocked = false;
  }

  void findUserError(e) {
    print("Find user error");
    print(e);
    _logging(false);

    if (e.runtimeType == PlatformException) {
      print("Exceção plataforma");
      PlatformException exc = e;
      switch (exc.code) {
        case "ERROR_INVALID_EMAIL":
          _showMessageError("Erro. Email Inválido.");
          break;
        case "ERROR_USER_NOT_FOUND":
          _showMessageError("Erro. Email não cadastrado.");
          break;
        case "ERROR_WRONG_PASSWORD":
          _showMessageError("Erro. Senha Incorreta.");
          break;
        default:
          _showError();
          break;
      }
      print("Code: " + exc.code);
    } else {
      _showError();
    }
    blocked = false;
  }

  void forgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ForgotPassword()),
    );
  }

  Future<void> _inactiveAccountError() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Conta Inativa'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Sua conta ainda está inativa. Caso você participe de'
                    ' algum dos projetos do LabDIS ou tenha sido indicado, sua '
                    'conta será liberada assim que possível!'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

void _showError() {
  _showMessageError("Ocorreu um erro.");
}

void _showMessageError(String message) {
  _scaffoldKey.currentState.showSnackBar(SnackBar(
    backgroundColor: Colors.red,
    content: Row(
      children: <Widget>[
        Text(message),
      ],
    ),
    duration: Duration(seconds: 12),
  ));
}

void _logging(bool isLoading) {
  if (isLoading) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      backgroundColor: Style.primaryColor,
      content: Row(
        children: <Widget>[
          CircularProgressIndicator(),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text("Aguarde..."),
          ),
        ],
      ),
    ));
  } else {
    _scaffoldKey.currentState.hideCurrentSnackBar();
  }
}
