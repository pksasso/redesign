import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:redesign/modulos/chat/chat_lista.dart';
import 'package:redesign/modulos/forum/forum_tema_lista.dart';
import 'package:redesign/modulos/material/material_lista.dart';
import 'package:redesign/modulos/rede/rede_tela.dart';
import 'package:redesign/modulos/eventos/eventos_lista.dart';
import 'package:redesign/modulos/usuario/perfil_form.dart';
import 'package:redesign/servicos/meu_app.dart';

class DrawerScreen extends StatelessWidget  {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        DrawerHeader(
          child: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  onTap: () => MeuApp.irProprioPerfil(context),
                  child: Container(
                    width: 80.0,
                    height: 80.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          //TODO Imagem do usuário if tem imagem. Else, placeholder.
                          image: AssetImage("images/perfil_placeholder.png"),
                      )
                    ),
                  ),
                ),
                Container(
                  width:160.0 ,
                  margin: EdgeInsets.all(10.0),
                  child: Column (
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(MeuApp.usuario.nome,
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.normal, fontSize: 25.0),
                      ),
                      Text(MeuApp.usuario.ocupacao,
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.normal, fontSize: 17.0),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget> [
                            RoundIconButton(
                              icon: Icon(Icons.edit),
                              iconColor: Colors.white,
                              circleColor: Color(0xff00838f),
                              size: 40.0,
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => PerfilForm())
                                );
                              },
                            ),
                            RoundIconButton(
                              icon: Icon(Icons.chat_bubble),
                              iconColor: Colors.white,
                              circleColor: Color(0xff00838f),
                              size: 40.0,
                              onPressed:  () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => ChatLista())
                                );
                              }
                            ),
                            RoundIconButton(
                              icon: Icon(Icons.exit_to_app),
                              iconColor: Colors.white,
                              circleColor: Color(0xff00838f),
                              size: 40.0,
                              onPressed: () => logout(context),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          decoration: BoxDecoration(
              color: Colors.black
          ),
        ),
        ListaDrawer(
          icon: Icons.explore,
          iconColor: Color(0xff00838f),
          text: 'Mapa',
          onPressed: () {}
        ),
        ListaDrawer(
          icon: Icons.people,
          iconColor: Color(0xff00838f),
          text: 'Rede',
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RedeTela())
            );
          }
        ),
        ListaDrawer(
          icon: Icons.forum,
          iconColor: Color(0xff00838f),
          text: 'Fórum',
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ForumTemaLista())
            );
          }
        ),
        ListaDrawer(
          icon: Icons.library_books,
          iconColor: Color(0xff00838f),
          text: 'Materiais',
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MaterialLista())
              );
            }
        ),
        ListaDrawer(
          icon: Icons.event,
          iconColor: Color(0xff00838f),
          text: 'Eventos',
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EventosTela())
            );
          }
        ),
      ],
    ),
    );
  }

  logout(BuildContext context) {
    FirebaseAuth _auth = FirebaseAuth.instance;
    _auth.signOut();
    Navigator.popUntil(context, ModalRoute.withName(Navigator.defaultRouteName));
    MeuApp.firebaseUser = null;
    MeuApp.usuario = null;
  }
}

class RoundIconButton extends StatelessWidget {
  final Icon icon;
  final Color iconColor;
  final Color circleColor;
  final double size;
  final VoidCallback onPressed;

  RoundIconButton({
    this.icon,
    this.iconColor,
    this.circleColor,
    this.size,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: circleColor,
      ),
      child: IconButton(
        alignment: Alignment.center,
        icon: icon,
        color: iconColor,
        onPressed: onPressed,
      ),
    );
  }
}

class ListaDrawer extends StatelessWidget{
  final IconData icon;
  final Color iconColor;
  final String text;
  final VoidCallback onPressed;

  ListaDrawer({
    this.icon,
    this.iconColor,
    this.text,
    this.onPressed,
});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon,
          color: iconColor,),
      title: Text(text,
        style: TextStyle(
          color: Colors.black45),
      ),
      onTap: onPressed,
    );
  }
}
