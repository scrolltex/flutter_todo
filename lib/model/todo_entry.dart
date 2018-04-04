enum TodoImportance {
  Low,
  Middle,
  High,
}

class TodoEntryModel {
  TodoEntryModel(this.title, this.importance, this.done);

  bool done;
  TodoImportance importance;
  String title;
}
