import 'package:flutter/foundation.dart';

enum TodoImportance {
  Low,
  Middle,
  High,
}

class TodoEntryModel {
  int id;
  int section;
  String title;
  String note;
  TodoImportance importance;
  bool done;

  TodoEntryModel({
    @required this.id, 
    @required this.section, 
    @required this.title, 
    this.note = "",
    this.importance = TodoImportance.Low, 
    this.done = false
  });

  TodoEntryModel.fromMap(Map map) {
    id = map["id"];
    section = map["section"];
    title = map["title"];
    note = map["note"];
    importance = TodoImportance.values[map["importance"]];
    done = map["done"] == 1;
  }

  Map toMap() {
    return {
      "id": id,
      "section": section,
      "title": title,
      "note": note,
      "importance": importance.index,
      "done": done ? 1 : 0
    };
  }

  TodoEntryModel copyWith({int id, int section, String title, String note, TodoImportance importance, bool done}) {
    return new TodoEntryModel(
      id: id ?? this.id,
      section: section ?? this.section,
      title: title ?? this.title,
      note: note ?? this.note,
      importance: importance ?? this.importance,
      done: done ?? this.done
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodoEntryModel &&
      runtimeType == other.runtimeType &&
      id == other.id &&
      section == other.section &&
      title == other.title &&
      note == other.note &&
      importance == other.importance &&
      done == other.done;

  @override
  int get hashCode => id.hashCode ^ section.hashCode ^ title.hashCode ^ note.hashCode ^ importance.hashCode ^ done.hashCode;
}

class SectionModel {
  int id;
  String title;

  SectionModel({
    @required this.id, 
    @required this.title
  });

  SectionModel.fromMap(Map map) {
    id = map['id'];
    title = map['title'];
  }

  Map toMap() {
    return {
      'id': id,
      'title': title
    };
  }

  SectionModel copyWith({int id, String title}) {
    return new SectionModel(
      id: id ?? this.id,
      title: title ?? this.title
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodoEntryModel &&
      runtimeType == other.runtimeType &&
      id == other.id &&
      title == other.title;

  @override
  int get hashCode => id.hashCode ^ title.hashCode;
}
