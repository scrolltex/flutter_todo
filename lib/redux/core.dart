import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../model/todo_entry.dart';

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
    // Parsing todos
    var loadedTodos = (json.decode(jsonObj['todos']) as List)
      .map((item) => new TodoEntryModel.fromJson(item as Map<String, dynamic>))
      .toList();

    // Parsing sections
    var loadedSections = (json.decode(jsonObj['sections']) as List)
      .map((item) => new SectionModel.fromJson(item as Map<String, dynamic>))
      .toList();

    // Return state
    return new ReduxState(
      todos: loadedTodos,
      sections: loadedSections
    );
  }

  Map toJson() => {
    'todos': json.encode(todos),
    'sections': json.encode(sections)
  };
}
