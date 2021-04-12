import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'todo.dart';

const _uuid = Uuid();

void main() {
  runApp(
    ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: SafeArea(child: MyApp()),
        ),
      ),
    ),
  );
}

// ignore: top_level_function_literal_block
final todoListProvider = StateNotifierProvider<TodoList, List<Todo>>((ref) {
  return TodoList([
    Todo(id: _uuid.v4(), description: 'Hello, Todo!'),
  ]);
});

final filterTodoListProvider = Provider<List<Todo>>((ref) {
  final filter = ref.watch(todoListFilterProvider);
  final todos = ref.watch(todoListProvider);
  debugPrint('build filterTodoListProvider');
  switch (filter.state) {
    case TodoListFilter.active:
      return todos.where((element) => !element.completed).toList();
    case TodoListFilter.completed:
      return todos.where((element) => element.completed).toList();
    default:
      return todos;
  }
});

class MyApp extends HookWidget {
  @override
  Widget build(BuildContext context) {
    debugPrint('build MyApp');
    final textEditingController = useTextEditingController();
    final filterTodoList = useProvider(filterTodoListProvider);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: ListView(
        padding: EdgeInsets.all(18.0),
        children: [
          Text(
            'Todos',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 100.0,
              fontWeight: FontWeight.w100,
              fontFamily: 'Helvetica Neue',
              color: Color.fromARGB(38, 47, 47, 247),
            ),
          ),
          TextField(
            onSubmitted: (value) {
              if (value.isNotEmpty)
                context.read(todoListProvider.notifier).addTodo(value);
              textEditingController.clear();
            },
            decoration: InputDecoration(labelText: 'what do you want to do?'),
            controller: textEditingController,
          ),
          SizedBox(height: 18.0),
          ToolBar(),
          if (filterTodoList.isEmpty) Divider(height: 0),
          for (var i = 0; i < filterTodoList.length; i++) ...[
            const SizedBox(height: 6.0),
            Dismissible(
              key: ValueKey(filterTodoList[i].id),
              onDismissed: (_) {
                context
                    .read(todoListProvider.notifier)
                    .removeTodo(filterTodoList[i].id);
              },
              child: ProviderScope(
                overrides: [
                  _currentTodo.overrideWithValue(filterTodoList[i]),
                ],
                child: const TodoItem(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

enum TodoListFilter { all, active, completed }
final todoListFilterProvider = StateProvider((_) => TodoListFilter.all);

class ToolBar extends HookWidget {
  @override
  Widget build(BuildContext context) {
    debugPrint('build ToolBar');
    final todoListFilter = useProvider(todoListFilterProvider);

    Color? textColorFor(TodoListFilter value) {
      return value == todoListFilter.state
          ? Colors.purpleAccent
          : Colors.black26;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Tooltip(
          message: 'All todos',
          child: TextButton(
            onPressed: () => todoListFilter.state = TodoListFilter.all,
            child: Text(
              'All',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w300,
                color: textColorFor(TodoListFilter.all),
              ),
            ),
          ),
        ),
        Tooltip(
          message: 'Active todos',
          child: TextButton(
            onPressed: () => todoListFilter.state = TodoListFilter.active,
            child: Text(
              'Active',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w300,
                color: textColorFor(TodoListFilter.active),
              ),
            ),
          ),
        ),
        Tooltip(
          message: 'Completed todos',
          child: TextButton(
            onPressed: () => todoListFilter.state = TodoListFilter.completed,
            child: Text(
              'Completed',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w300,
                color: textColorFor(TodoListFilter.completed),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

final _currentTodo = ScopedProvider<Todo>(null);

class TodoItem extends HookWidget {
  const TodoItem({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    debugPrint('build TodoItem');
    final todo = useProvider(_currentTodo);
    final itemFocusNode = useFocusNode();
    useListenable(itemFocusNode);
    final isFocused = itemFocusNode.hasFocus;
    final textEditingController = useTextEditingController();
    final textFieldFocusNode = useFocusNode();
    return Material(
      elevation: 3.0,
      child: Focus(
        focusNode: itemFocusNode,
        onFocusChange: (focused) {
          debugPrint('${context.read(_currentTodo).description} $focused');
                    if (focused) {
            textEditingController.text = todo.description;
          } else {
            // Commit changes only when the textfield is unfocused, for performance
            context
                .read(todoListProvider.notifier)
                .editTodo(id: todo.id, desc: textEditingController.text);
          }
        },
        child: ListTile(
          onTap: () {
            debugPrint('onTap');
            itemFocusNode.requestFocus();
            textFieldFocusNode.requestFocus();
          },
          leading: Checkbox(
            onChanged: (bool? value) {
              context.read(todoListProvider.notifier).toggleTodo(todo.id);
            },
            value: todo.completed,
          ),
          title: isFocused
              ? TextField(
                  autofocus: true,
                  focusNode: textFieldFocusNode,
                  controller: textEditingController,
                )
              : Text(todo.description),
        ),
      ),
    );
  }
}
