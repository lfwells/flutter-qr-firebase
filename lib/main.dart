import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:barcode_scan/barcode_scan.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';

import 'dart:async';
import 'dart:io' show Platform; //needed for firebase.configure() platform specific infos

//converted main into an async, so that we can set up the firebase connection first
//before running the app proper:
Future<void> main() async
{
  //connect to firebase
  final FirebaseApp app = await FirebaseApp.configure(
    name: 'FlutterQR',
    options: Platform.isIOS
        ? const FirebaseOptions(
            googleAppID: '1:222742060511:ios:cd7b863a4b3342ea',
            gcmSenderID: '222742060511',
            databaseURL: 'https://flutterqr-5af12.firebaseio.com',
          )
        : const FirebaseOptions(
            googleAppID: '1:222742060511:android:cd7b863a4b3342ea',
            apiKey: 'AIzaSyCjxvgsgOQDukPnv0FCgA1qXzuPedSSXu0',
            databaseURL: 'https://flutterqr-5af12.firebaseio.com',
          ),
  );

  //now just the usual main() stuff of running the app (widget)
  runApp(MyApp(app: app));
}

class MyApp extends StatelessWidget
{
  //firebase / realtime db: pass the app thru to teh widget as required
  //can be later accessed in the StatefulWidget using widget.app
  //currently just passed on thru to the MyHomePage class
  MyApp({this.app});
  final FirebaseApp app;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page', app: app),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, this.app}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  //firebase / realtime db: link to the app object. accessed using widget.app
  final FirebaseApp app;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  //realtime db handles
  DatabaseReference _messagesRef;
  StreamSubscription<Event> _messagesSubscription;

  String barcode = "";

  final TextEditingController textEditingController = new TextEditingController();
  String enteredText = "";


  Future _scan() async
  {
    String barcode = await BarcodeScanner.scan();
    setState(() => this.barcode = barcode);


    //this adds a new (unique) child item
    //_messagesRef.push().set(barcode);

    //this version updates the value of the item
    _messagesRef.set(barcode);
  }
  void _handleTextChange()
  {
    setState(() => this.enteredText = textEditingController.text);
  }

  @override
  void initState() {
    super.initState();

    // Start listening to changes
    textEditingController.addListener(_handleTextChange);

    // Realtime db stuff.
    //connect to the db
    final FirebaseDatabase database = FirebaseDatabase(app: widget.app);
    database.setPersistenceEnabled(true);
    database.setPersistenceCacheSizeBytes(10000000);

    //get a reference to the messages 'table'?
    _messagesRef = database.reference().child('message/latest');

    //subscribe to changes
    _messagesSubscription = _messagesRef.onChildChanged.listen((Event event) {
        print('Child added: ${event.snapshot.value}');
        //_setCurrentText(event.snapshot.value);

        setState(() => this.barcode = event.snapshot.value);

    }, onError: (Object o) {
        final DatabaseError error = o;
        print('Error: ${error.code} ${error.message}');
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is removed from the Widget tree
    // This also removes the _printLatestValue listener
    textEditingController.dispose();

    //need to clean up the realtime db subscriber
    _messagesSubscription.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
                onPressed: _scan,
                child:Text("Scan A Code")
            ),
            Text("Scanned text was: "+this.barcode),
            TextField(
              controller: textEditingController,
            ),
            QrImage(data: this.enteredText)
          ],
        ),
      ),
    );
  }
}
