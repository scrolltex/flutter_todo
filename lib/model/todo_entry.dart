import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'todo_entry.g.dart';

enum TodoImportance {
  Low,
  Middle,
  High,
}

@JsonSerializable()
class TodoEntryModel extends Object with _$TodoEntryModelSerializerMixin {
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

  factory TodoEntryModel.fromJson(Map<String, dynamic> json) => _$TodoEntryModelFromJson(json);
}

@JsonSerializable()
class SectionModel extends Object with _$SectionModelSerializerMixin {
  int id;
  String title;

  SectionModel({
    @required this.id, 
    @required this.title
  });

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

  factory SectionModel.fromJson(Map<String, dynamic> json) => _$SectionModelFromJson(json);
}
