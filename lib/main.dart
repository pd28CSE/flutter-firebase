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
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      addMatchInfo();
      getValue();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: withStreamBuilder(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await firebaseFirestore
              .collection('basketball')
              .doc('1_ban_vs_nep')
              .update({
            'team_b': 'Nepal',
            'score_team_b': 30,
          });
          // if (mounted) {
          //   setState(() {});
          // }
          // await addNewMatchWithCustomDocumentName();
          // await addNewMatchWithAutoDocumentName();
        },
        child: const Icon(Icons.update_sharp),
      ),
    );
  }

  StreamBuilder<DocumentSnapshot<Map<String, dynamic>>> withStreamBuilder(
      BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: firebaseFirestore
          .collection('basketball')
          .doc('1_ban_vs_nep')
          .snapshots(),
      builder: (cntxt,
          AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator.adaptive());
        } else if (snapshot.hasError == true) {
          return Center(child: Text(snapshot.error.toString()));
        } else if (snapshot.hasData == true && snapshot.data!.exists == false) {
          return const Center(child: Text("Document does not exist"));
        } else if (snapshot.data != null) {
          Map<String, dynamic>? matchInfo = snapshot.data!.data();
          log(matchInfo.toString());
          return Column(
            children: <Widget>[
              const SizedBox(height: 50),
              Text(matchInfo?['match_name'] ?? '',
                  style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Text(matchInfo?['score_team_a'].toString() ?? ''),
                      Text(matchInfo?['team_a'] ?? ''),
                    ],
                  ),
                  const Text('vs'),
                  Column(
                    children: <Widget>[
                      Text(matchInfo?['score_team_b'].toString() ?? ''),
                      Text(matchInfo?['team_b'] ?? ''),
                    ],
                  ),
                ],
              ),
            ],
          );
        } else {
          return const Center(child: Text('Other Info...'));
        }
      },
    );
  }

  FutureBuilder<DocumentSnapshot<Map<String, dynamic>>> withFutureBuilder(
      BuildContext context) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future:
          firebaseFirestore.collection('basketball').doc('1_ban_vs_nep').get(),
      builder: (cntxt,
          AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator.adaptive());
        } else if (snapshot.hasError == true) {
          return Center(child: Text(snapshot.error.toString()));
        } else if (snapshot.hasData == true && !snapshot.data!.exists) {
          return const Center(child: Text("Document does not exist"));
        } else if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic>? matchInfo = snapshot.data?.data();
          return Column(
            children: <Widget>[
              const SizedBox(height: 50),
              Text(matchInfo?['match_name'] ?? '',
                  style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Text(matchInfo?['score_team_a'].toString() ?? ''),
                      Text(matchInfo?['team_a'] ?? ''),
                    ],
                  ),
                  const Text('vs'),
                  Column(
                    children: <Widget>[
                      Text(matchInfo?['score_team_b'].toString() ?? ''),
                      Text(matchInfo?['team_b'] ?? ''),
                    ],
                  ),
                ],
              ),
            ],
          );
        } else {
          return const Center(child: Text('Other Info...'));
        }
      },
    );
  }

  Future<void> addNewMatchWithCustomDocumentName({String? documentName}) async {
    //? Add new document in the collection "basketball"
    final DocumentReference documentReference = firebaseFirestore
        .collection('basketball')
        .doc(documentName ?? 'custom_document_name');

    //?   add new data in that document.
    await documentReference.set(
      {
        'full_name': 'Partho Debnath',
        'city': 'Mirpur',
        'document_type': 'Custom DocumentName.'
      },
    );

    //? read that document data
    final DocumentSnapshot<Object?> documentSnapshot =
        await documentReference.get();
    if (documentSnapshot.data() != null) {
      Map<String, dynamic> data =
          documentSnapshot.data() as Map<String, dynamic>;
      log(data.toString());
    }

    //? update that document data if the field already exists otherwise create a new field.
    //? if that document does not exist then throw an error.
    // documentReference.update({
    //   'full_name': 'Debnath Partho',
    // }).catchError((val) {
    //   log(val.toString());
    // });

    //? delete that document if exists otherwise nothing to do.
    // await documentReference.delete();
  }

  Future<void> addNewMatchWithAutoDocumentName() async {
    //? in the collection "basketball" and auto generated  document
    await firebaseFirestore.collection('basketball').add(
      {
        'full_name': 'Partho Debnath',
        'city': 'Mirpur',
        'document_type': 'Auto Generated Document Name.'
      },
    );

    //? get all the documents from the "basketball" collection
    QuerySnapshot<Map<String, dynamic>> data =
        await firebaseFirestore.collection('basketball').get();

    //? get total number of documents from the "basketball" collection
    int lengthOfDoc = data.docs.length;
    for (int i = 0; i < lengthOfDoc; i++) {
      log(data.docs[i].get('full_name'));
      Map<String, dynamic> info = data.docs[i].data();
      String documentName = data.docs[i].id;
      log('$i: $documentName: $info');
      //   //? delete add documents from the "basketball" collection
      // await firebaseFirestore
      //     .collection('basketball')
      //     .doc(documentName)
      //     .delete();
    }

    // final DocumentReference documentReference =
    //     firebaseFirestore.collection('basketball').doc('CCn9rW90cWZw0iMD2Ef6');
    // DocumentSnapshot<Object?> documentSnapshot = await documentReference.get();
    // if (documentSnapshot.data() != null) {
    //   Map<String, dynamic> data =
    //       documentSnapshot.data() as Map<String, dynamic>;
    //   log(data.toString());
    // }

    //? update that document data if the field already exists otherwise create a new field.
    //? if that document does not exist then throw an error.
    // documentReference.update({
    //   'full_name': 'Debnath  Partho',
    // }).catchError((val) {
    //   log(val.toString());
    // });

    //? delete that document if exists otherwise nothing to do.
    // await documentReference.delete();
  }

  Future<void> addMatchInfo() async {
    CollectionReference collectionReference =
        firebaseFirestore.collection('basketball');
    await collectionReference.doc('1_ban_vs_nep').set(
      {
        'match_name': 'Bang vs Nepal',
        'team_a': 'Bangladesh',
        'score_team_a': 1,
        'team_b': 'Nepal',
        'score_team_b': 10,
      },
    );
  }

  Future<void> getValue() async {
    CollectionReference collectionReference =
        firebaseFirestore.collection('basketball');
    DocumentReference documentReferences =
        collectionReference.doc('1_ban_vs_nep');
    DocumentSnapshot info = await documentReferences.get();
    log(info.data().toString());
    log(info.get('match_name'));
    log(info.get('team_a'));
    log(info.get('score_team_a').toString());
    log(info.get('team_b'));
    log(info.get('score_team_b').toString());
  }
}
