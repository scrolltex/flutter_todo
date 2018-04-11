import 'model/todo_entry.dart';

class DataManager {
  static final DataManager _instance = new DataManager._internal();
  
  DataManager._internal();
  factory DataManager() {
    return _instance;
  }

  var _todoList = <TodoEntryModel>[
    new TodoEntryModel(0, 0, title: "Make a sandwich"),
    new TodoEntryModel(1, 1, title: "Make clean"),
    new TodoEntryModel(2, 1, title: "Buy a new chair", done: true),
    new TodoEntryModel(1, 1, title: "Assemble the chair", importance: TodoImportance.Middle),
    new TodoEntryModel(3, 2, title: "Rent a hall", importance: TodoImportance.High),
    new TodoEntryModel(4, 3, title: "Complete the new feature", importance: TodoImportance.Middle),
  ];

  var _sections = <SectionModel>[
    new SectionModel(0, 'Default'),
    new SectionModel(1, 'Home'),
    new SectionModel(2, 'Birtday'),
    new SectionModel(3, 'Project')
  ];

  /// Return next id of todos
  num getTodoNextId() {
    num maxId = 0;
    for (var entry in _todoList) {
      if(entry.id > maxId)
        maxId = entry.id;
    }

    return maxId + 1;
  }

  /// Return all todos for specified section 
  Iterable<TodoEntryModel> getTodo(int section) => _todoList.where((item) => item.section == section);

  /// Add new todo entry
  void addTodo(TodoEntryModel model) => _todoList.add(model);

  /// Update
  void updateTodo(TodoEntryModel oldModel, TodoEntryModel newModel) {
    _todoList[_todoList.indexWhere((model) => model.id == oldModel.id)] = newModel;
  }

  /// Delete todo entry by id
  void deleteTodo(int id) => _todoList.removeWhere((item) => item.id == id);

  /// Return next id of sections
  int getSectionNextId() {
    num maxId = 0;
    for (var entry in _sections) {
      if(entry.id > maxId)
        maxId = entry.id;
    }

    return maxId + 1;
  }

  /// Return all sections
  Iterable<SectionModel> getSections() => _sections;

  /// Return section by id
  SectionModel getSection(int id) => _sections.singleWhere((model) => model.id == id);

  /// Update section title by id
  void updateSection(SectionModel oldModel, SectionModel newModel) {
     _sections[_sections.indexWhere((model) => model.id == oldModel.id)] = newModel;
  } 

  /// Add new section with specified  id and title
  void addSection(SectionModel model) {
     _sections.add(model);
  }
  
  /// Delete section by id
  void deleteSection(SectionModel model) {
    _todoList.removeWhere((item) => item.section == model.id);
    _sections.remove(model);
  }
}
