import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';

import 'redux/core.dart';
import 'pages/sections_page.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  final store = new Store<ReduxState>(stateReducer, initialState: new ReduxState.initialState()); 

  @override
  Widget build(BuildContext context) {
    return new StoreProvider(
      store: store,
      child: new MaterialApp(
        title: 'ToDo list',
        theme: new ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: new SectionsPage(),
      )
    );
  }
}
