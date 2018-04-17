// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_entry.dart';

// **************************************************************************
// Generator: JsonSerializableGenerator
// **************************************************************************

TodoEntryModel _$TodoEntryModelFromJson(Map<String, dynamic> json) =>
    new TodoEntryModel(
        id: json['id'] as int,
        section: json['section'] as int,
        title: json['title'] as String,
        note: json['note'] as String,
        importance: json['importance'] == null
            ? null
            : TodoImportance.values.singleWhere(
                (x) => x.toString() == "TodoImportance.${json['importance']}"),
        done: json['done'] as bool);

abstract class _$TodoEntryModelSerializerMixin {
  int get id;
  int get section;
  String get title;
  String get note;
  TodoImportance get importance;
  bool get done;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'section': section,
        'title': title,
        'note': note,
        'importance':
            importance == null ? null : importance.toString().split('.')[1],
        'done': done
      };
}

SectionModel _$SectionModelFromJson(Map<String, dynamic> json) =>
    new SectionModel(id: json['id'] as int, title: json['title'] as String);

abstract class _$SectionModelSerializerMixin {
  int get id;
  String get title;
  Map<String, dynamic> toJson() => <String, dynamic>{'id': id, 'title': title};
}
