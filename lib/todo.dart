import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class Todo {
  Todo({required this.id, required this.description, this.completed = false});

  final String id;
  final String description;
  final bool completed;

  @override
  String toString() {
    return 'Todo(id: $id, description: $description, completed: $completed)';
  }
}

class TodoList extends StateNotifier<List<Todo>> {
  TodoList([List<Todo>? initTodos]) : super(initTodos ?? []);

  void addTodo(String description) {
    state = [
      ...state,
      Todo(
        id: _uuid.v4(),
        description: description,
      ),
    ];
  }

  void toggleTodo(String id) {
    state = [
      for (final todo in state)
        if (todo.id == id)
          Todo(
            id: todo.id,
            description: todo.description,
            completed: !todo.completed,
          )
        else
          todo,
    ];
  }

  void removeTodo(String id) {
    state = state.where((element) => element.id != id).toList();
  }

  void editTodo({required String id, required String desc}) {
    state = [
      for (final todo in state)
        if (todo.id == id)
          Todo(
            id: todo.id,
            completed: todo.completed,
            description: desc,
          )
        else
          todo,
    ];
  }
}
