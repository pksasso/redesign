import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:redesign/estilos/tema.dart';
import 'package:redesign/modulos/cadastro/registroOpcoes.dart';
import 'package:redesign/modulos/login/esqueci_senha.dart';
import 'package:redesign/modulos/usuario/instituicao.dart';
import 'package:redesign/modulos/usuario/usuario.dart';
import 'package:redesign/servicos/meu_app.dart';
import 'package:redesign/widgets/botao_padrao.dart';
import 'package:firebase_auth/firebase_auth.dart';

FirebaseUser mCurrentUser;
FirebaseAuth _auth = FirebaseAuth.instance;

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomPadding: false,
      body: Center(
        child: Container(
          color: Tema.darkBackground,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 50, bottom: 50),
                child: Image.asset(
                  'images/rede_logo.png',
                  fit: BoxFit.fitWidth,
                  width: 200,
                ),
              ),
              _LoginPage(),
            ],
          )
        )
      )
    );
  }
}

class _LoginPage extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<_LoginPage> {

  bool mostrandoLogin = false;

  @override
  Widget build(BuildContext context) {
    return mostrandoLogin ?
    _LoginForm() : Container(
        padding: EdgeInsets.all(15.0),
        child: Column(
          children: [
            Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: BotaoPadrao(
                    "Entrar", mostrarLogin, Tema.principal.primaryColor,
                    Tema.cinzaClaro)
            ),
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: BotaoPadrao("Cadastrar-se", cadastro, Tema.buttonDarkGrey,
                  Tema.cinzaClaro),
            ),
          ],
        )
    );
  }

  mostrarLogin() {
    setState(() {
      mostrandoLogin = true;
    });
  }

  cadastro() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegistroOpcoes()),
    );
  }
}

class _LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {

  TextEditingController emailController = TextEditingController();
  TextEditingController senhaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15.0),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: TextField(
              style: TextStyle(
                decorationColor: Tema.cinzaClaro,
                color: Colors.white
              ),
              cursorColor: Tema.buttonBlue,
              decoration: InputDecoration(
                labelText: 'E-mail',
                labelStyle: TextStyle(color: Colors.white54),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.white54
                  ),
                ),
              ),
              controller: emailController,
            )
          ),
          TextField(
            style: TextStyle(
                decorationColor: Tema.cinzaClaro,
                color: Colors.white
            ),
            cursorColor: Tema.buttonBlue,
            decoration: InputDecoration(
              labelText: 'Senha',
              labelStyle: TextStyle(color: Colors.white54),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                    color: Colors.white54
                ),
              ),
            ),
            obscureText: true,
            controller: senhaController,
          ),
          GestureDetector(
            child: Container(
              padding: EdgeInsets.only(top: 8, bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text("Esqueci a senha",
                      style: TextStyle(color: Tema.primaryColorLighter, fontWeight: FontWeight.w300, fontSize: 12.0),
                      textAlign: TextAlign.end),
                ],
              )
            ),
            onTap: esqueciSenha,
          ),
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: BotaoPadrao("Entrar", entrar,
                Tema.principal.primaryColor, Tema.cinzaClaro
            ),
          ),
        ],
      )
    );
  }

  /// Tenta logar o usuário pelo email e senha do formulário
  entrar() async{
    if(emailController.text == null || emailController.text == "" || senhaController.text == null || senhaController.text == ""){
      emailController.text = "george@hotmail.com";
      senhaController.text = "123456";
    }

    _logando(true);
    await _auth.signInWithEmailAndPassword(
        email: emailController.text, password: senhaController.text)
        .then(authSucesso)
        .catchError(erroEncontrarUsuario);
  }

  void authSucesso(FirebaseUser user){
    print("Auth sucesso");
    MeuApp.firebaseUser = user;
    Firestore.instance.collection(Usuario.collectionName).document(user.uid).get()
    .then(encontrouUsuario).catchError(erroEncontrarUsuario);
  }

  void encontrouUsuario(DocumentSnapshot snapshot){
    if(snapshot.data['tipo'] == TipoUsuario.instituicao.index){
      MeuApp.setUsuario(Instituicao.fromMap(snapshot.data, reference: snapshot.reference));
    } else {
      MeuApp.setUsuario(Usuario.fromMap(snapshot.data, reference: snapshot.reference));
    }

    if(!MeuApp.ativo()){
      _logando(false);
      erroUsuarioInativo();
      return;
    }
    _logando(false);
    Navigator.pushReplacementNamed(
        context,
        '/'
    );
  }

  void erroUsuarioInativo(){
    _errorContaInativa();
  }
  
  void erroEncontrarUsuario(e){
    _logando(false);
    _mostraErro();
  }

  void esqueciSenha(){
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EsqueciSenha()),
    );
  }

  Future<void> _errorContaInativa() async {
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

void _mostraErro(){
  _mostraErroMsg("Ocorreu um erro.");
}

void _mostraErroMsg(String mensagem){
  _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Row(
          children: <Widget>[
            Text(mensagem),
          ],
        ),
        duration: Duration(seconds: 4),
      ));
}

void _logando(bool isCarregando){
  if(isCarregando){
    _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          backgroundColor: Tema.primaryColor,
          content: Row(
            children: <Widget>[
              CircularProgressIndicator(),
              Text(" Aguarde..."),
            ],
          ),
        ));
  } else {
    _scaffoldKey.currentState.hideCurrentSnackBar();
  }
}
