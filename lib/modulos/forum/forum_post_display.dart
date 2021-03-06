import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:redesign/modulos/forum/forum_comment.dart';
import 'package:redesign/modulos/forum/forum_comment_form.dart';
import 'package:redesign/modulos/forum/forum_comment_list_item.dart';
import 'package:redesign/modulos/forum/forum_post.dart';
import 'package:redesign/services/my_app.dart';
import 'package:redesign/styles/style.dart';
import 'package:redesign/widgets/async_data.dart';
import 'package:redesign/widgets/forum_base_screen_post.dart';
import 'package:redesign/widgets/standard_button.dart';
import 'package:url_launcher/url_launcher.dart';

import 'forum_post_form.dart';
import 'forum_topic.dart';

class ForumPostDisplay extends StatefulWidget {
  final ForumPost post;

  ForumPostDisplay(this.post);

  @override
  ForumPostDisplayState createState() => ForumPostDisplayState(post);
}

class ForumPostDisplayState extends State<ForumPostDisplay> {
  final ForumPost post;
  ForumTopic topic;

  ForumPostDisplayState(this.post);

  _deleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Excluir post'),
          content: Text('Deseja realmente excluir este post ?'),
          actions: <Widget>[
            FlatButton(
              child: Text('Não'),
              onPressed: () => Navigator.pop(context),
            ),
            FlatButton(
              child: Text('Sim'),
              onPressed: () {
                post.deletePost();
                Navigator.pop(context);
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ForumBaseScreen(
      title: post.title,
      actions: MyApp.userId() == post.createdBy || MyApp.isLabDis() == true
          ? <IconButton>[
              IconButton(
                  icon: Icon(Icons.delete, color: Colors.white),
                  onPressed: () => _deleteConfirmation()),
              IconButton(
                icon: Icon(
                  Icons.edit,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ForumPostForm(editPost: post),
                  ),
                ),
              )
            ]
          : null,
      body: Column(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Style.darkBackground)),
              color: Style.darkBackground,
            ),
            padding: EdgeInsets.only(top: 8, bottom: 8, left: 16, right: 10),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    CircleAvatarAsync(
                      post.createdBy,
                      radius: 26,
                      clickable: true,
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Flexible(
                            child: Container(
                              padding: EdgeInsets.only(left: 6),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    post.title,
                                    style: TextStyle(
                                      color: Style.primaryColorLighter,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 2,
                                    softWrap: false,
                                    overflow: TextOverflow.clip,
                                  ),
                                  NameTextAsync(
                                    post.createdBy,
                                    TextStyle(color: Colors.white),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
          _CommentsList(
              post.reference.collection(ForumComment.collectionName), post),
        ],
      ),
    );
  }
}

class _CommentsList extends StatefulWidget {
  final CollectionReference reference;
  final ForumPost post;

  _CommentsList(this.reference, this.post);

  @override
  _CommentsListState createState() => _CommentsListState(reference, post);
}

class _CommentsListState extends State<_CommentsList> {
  CollectionReference reference;
  final ForumPost post;

  _CommentsListState(this.reference, this.post);

  @override
  Widget build(BuildContext context) {
    return _buildBody(context);
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: reference.orderBy("data", descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();
        return _buildList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return Expanded(
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          ListView(
              children: <Widget>[
            Container(
                padding: EdgeInsets.only(left: 16, right: 16, bottom: 10),
                color: Style.darkBackground,
                child: Linkify(
                  onOpen: (link) async {
                    if (await canLaunch(link.url)) {
                      await launch(link.url);
                    } else {
                      throw 'Could not launch $link';
                    }
                  },
                  text: post.description,
                  style: TextStyle(color: Colors.white),
                  linkStyle: TextStyle(color: Colors.blue),
                  humanize: true,
                )),
          ]
                ..addAll(snapshot
                    .map((data) => CommentListItem(ForumComment.fromMap(
                        data.data,
                        reference: data.reference)))
                    .toList())
                // Padding extra no final da lista
                ..add(Container(
                  padding: EdgeInsets.only(bottom: 60.0),
                ))),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: StandardButton("Contribuir", addComment,
                Style.main.primaryColor, Colors.white),
          ),
        ],
      ),
    );
  }

  addComment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ForumCommentForm(
            post.reference.collection(ForumComment.collectionName)),
      ),
    );
  }
}
