enum TodoImportance {
  Low,
  Middle,
  High,
}

class TodoEntryModel {
  TodoEntryModel(this.id, this.section, this.title, this.note, this.importance, this.done);

  int id;
  int section;
  String title;
  String note;
  TodoImportance importance;
  bool done;
}

class SectionModel {
  SectionModel(this.id, this.title);

  int id;
  String title;
}