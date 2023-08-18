import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: MyHomePage(title: 'Flutter Firebase Manual Connection'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late FirebaseFirestore firebaseFirestore;

  @override
  void initState() {
    super.initState();
    firebaseFirestore = FirebaseFirestore.instance;
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //   getValue();
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder(
        future: firebaseFirestore
            .collection('basketball')
            .doc('1_ban_vs_nep')
            .get(),
        builder: (cntxt, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          } else if (snapshot.hasError == true) {
            return const Center(child: Text('Error..'));
          } else if (snapshot.hasData == true) {
            var matchInfo = snapshot.data!.data();
            return Column(
              children: <Widget>[
                const SizedBox(height: 50),
                Text(matchInfo!['match_name'],
                    style: Theme.of(context).textTheme.displaySmall),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Text(matchInfo['score_team_a'].toString()),
                        Text(matchInfo['team_a']),
                      ],
                    ),
                    const Text('vs'),
                    Column(
                      children: <Widget>[
                        Text(matchInfo['score_team_b'].toString()),
                        Text(matchInfo['team_b']),
                      ],
                    ),
                  ],
                ),
              ],
            );
          } else {
            return const Center(child: Text('sgsg'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await firebaseFirestore
              .collection('basketball')
              .doc('1_ban_vs_nep')
              .update({
            'team_b': 'Nepal',
            'score_team_b': 30,
          });
          if (mounted) {
            setState(() {});
          }
        },
        child: const Text('Updata'),
      ),
    );
  }

  // Future<void> getValue() async {
  //   log('-*******');
  //   CollectionReference collectionReference =
  //       firebaseFirestore.collection('basketball');
  //   DocumentReference documentReferences =
  //       collectionReference.doc('1_ban_vs_nep');
  //   DocumentSnapshot info = await documentReferences.get();
  //   log(info.data().toString());
  //   log(info.get('match_name'));
  //   log(info.get('team_a'));
  //   log(info.get('score_team_a').toString());
  //   log(info.get('team_b'));
  //   log(info.get('score_team_b').toString());
  // }
}
