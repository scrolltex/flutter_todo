import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:redux/redux.dart';
import 'package:redux_persist/redux_persist.dart';

import '../model/todo_entry.dart';
import 'actions.dart';

@immutable
class ReduxState {
  final List<TodoEntryModel> todos;
  final List<SectionModel> sections;

  final bool hasEntryBeenDeleted;
  final SectionModel lastRemovedSection;
  final List<TodoEntryModel> lastRemovedTodos;

  const ReduxState({
    @required this.todos,
    @required this.sections,
    this.hasEntryBeenDeleted = false,
    this.lastRemovedSection,
    this.lastRemovedTodos
  });

  ReduxState.initialState()
      : todos = <TodoEntryModel>[],
        sections = <SectionModel>[],
        hasEntryBeenDeleted = false,
        lastRemovedSection = null,
        lastRemovedTodos = null;

  ReduxState copyWith({
    List<TodoEntryModel> todos, 
    List<SectionModel> sections,
    bool hasEntryBeenDeleted,
    SectionModel lastRemovedSection,
    List<TodoEntryModel> lastRemovedTodos
  }) => new ReduxState(
      todos: todos ?? this.todos,
      sections: sections ?? this.sections,
      hasEntryBeenDeleted: hasEntryBeenDeleted ?? this.hasEntryBeenDeleted,
      lastRemovedSection: lastRemovedSection ?? this.lastRemovedSection,
      lastRemovedTodos: lastRemovedTodos ?? this.lastRemovedTodos,
  );

  static ReduxState fromJson(dynamic jsonObj) {
    // Parsing sections
    var loadedSectionsList = new List<SectionModel>();
    var loadedSections = json.decode(jsonObj['sections']);
    for (var item in loadedSections) {
      loadedSectionsList.add(new SectionModel.fromJson(item));
    }

    // Parsing todos
    var loadedTodosList = new List<TodoEntryModel>();
    var loadedTodos = json.decode(jsonObj['todos']);
    for (var item in loadedTodos) {
      loadedTodosList.add(new TodoEntryModel.fromJson(item));
    }

    // Return state
    return new ReduxState(
      todos: loadedTodosList,
      sections: loadedSectionsList
    );
  }

  Map toJson() => {
    'todos': json.encode(todos),
    'sections': json.encode(sections)
  };
}
