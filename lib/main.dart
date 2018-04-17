import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux_persist/redux_persist.dart';
import 'package:redux_persist_flutter/redux_persist_flutter.dart';

import 'redux/core.dart';
import 'redux/reducers.dart';
import 'pages/sections_page.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  Persistor<ReduxState> persistor;
  Store<ReduxState> store;

  MyApp() {
    persistor = new Persistor<ReduxState>(
      storage: new FlutterStorage("todo"),
      decoder: ReduxState.fromJson,
    );

    store = new Store<ReduxState>(
      stateReducer, 
      initialState: new ReduxState.initialState(),
      middleware: [persistor.createMiddleware()],
    ); 

    persistor.load(store);
  }

  @override
  Widget build(BuildContext context) {
    return new StoreProvider(
      store: store,
      child: new MaterialApp(
        title: 'ToDo list',
        theme: new ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: new PersistorGate(
          persistor: persistor,
          builder: (context) => new SectionsPage(),
          loading: new Container(
            color: Colors.white,
            child: new Center(child: new CircularProgressIndicator())
          )
        )
      )
    );
  }
}
