import 'model/todo_entry.dart';

class DataManager {
  static final DataManager _instance = new DataManager._internal();
  
  DataManager._internal();
  factory DataManager() {
    return _instance;
  }

  var _todoList = <TodoEntryModel>[
    new TodoEntryModel(0, 0, "Make a sandwich", TodoImportance.Low, false),
    new TodoEntryModel(1, 1, "Make clean", TodoImportance.Low, false),
    new TodoEntryModel(2, 1, "Buy a new chair", TodoImportance.Low, true),
    new TodoEntryModel(1, 1, "Assemble the chair", TodoImportance.Middle, false),
    new TodoEntryModel(3, 2, "Rent a hall", TodoImportance.High, false),
    new TodoEntryModel(4, 3, "Complete the new feature", TodoImportance.Middle, false),
  ];

  var _sections = <int, String>{
    0: 'Default',
    1: 'Home',
    2: 'Birtday',
    3: 'Project',
  };

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
  void updateTodo(int id, TodoEntryModel newModel) => _todoList[id] = newModel;

  /// Delete todo entry by id
  void deleteTodo(int id) => _todoList.removeWhere((item) => item.id == id);

  /// Return next id of sections
  int getSectionNextId() {
    num maxId = 0;
    for (var key in _sections.keys) {
      if(key > maxId)
        maxId = key;
    }

    return maxId + 1;
  }

  /// Return all sections
  Map<int, String> getSections() => _sections;

  /// Return section by id
  String getSection(int id) => _sections[id];

  /// Update section title by id
  void updateSection(int id, String title) => _sections[id] = title;

  /// Add new section with specified  id and title
  void addSection(int id, String title) => _sections.addAll({id: title});
  
  /// Delete section by id
  void deleteSection(int id) {
    _todoList.removeWhere((item) => item.section == id);
    _sections.remove(id);
  }
}
