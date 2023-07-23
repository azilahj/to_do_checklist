import 'package:flutter/material.dart';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Test",
      theme: ThemeData(primarySwatch: Colors.teal),
      home: TestPage(),
    );
  }
}

class TestPage extends StatefulWidget {
  const TestPage({Key? key}) : super(key: key);

  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  List<String> _tasks = [];
  List<bool> _taskStatus = [];
  int _currentPage = 0;
  final PageController _pageController = PageController();

  void _addTask(String task) {
    setState(() {
      _tasks.add(task);
      _taskStatus.add(false);
    });
  }

  void _removeTask(int index) {
    setState(() {
      _tasks.removeAt(index);
      _taskStatus.removeAt(index);
    });
  }

  void _toggleTask(int index) {
    setState(() {
      _taskStatus[index] = !_taskStatus[index];
    });
  }

  Widget _buildTaskItem(int index) {
    String task = _tasks[index];
    bool isLongText = task.length > 30;

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 4.0,
            offset: const Offset(0, 4.0),
          ),
        ],
      ),
      child: Card(
        color: _taskStatus[index] ? Colors.teal[100] : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Checkbox(
                  value: _taskStatus[index],
                  onChanged: (bool? newValue) {
                    _toggleTask(index);
                  },
                ),
                Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _removeTask(index),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 8.0),
              child: Text(
                task,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: TextStyle(
                  decoration: _taskStatus[index]
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
            ),
            if (isLongText) Spacer(),
            if (isLongText)
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return _buildCustomAlertDialog(task);
                        },
                      );
                    },
                    icon: const Icon(Icons.remove_red_eye),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAlertDialog(String task) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        constraints: const BoxConstraints(maxWidth: 0.3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "View Task",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  task,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Close"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridPage(int pageIndex) {
    int startIndex = pageIndex * 9;
    int endIndex = (pageIndex + 1) * 9;
    List<Widget> pageItems = [];

    for (int i = startIndex; i < endIndex && i < _tasks.length; i++) {
      pageItems.add(_buildTaskItem(i));
    }

    return GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: 8.0,
      mainAxisSpacing: 8.0,
      children: pageItems,
    );
  }

  Widget _buildPageNavigator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        (_tasks.length / 9).ceil(),
        (index) {
          return GestureDetector(
            onTap: () {
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            },
            child: Container(
              margin: const EdgeInsets.all(4.0),
              width: 8.0,
              height: 8.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index == _currentPage ? Colors.teal : Colors.grey,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do Checklist'),
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (int page) {
          setState(() {
            _currentPage = page;
          });
        },
        itemCount: (_tasks.length / 9).ceil(),
        itemBuilder: (context, index) => _buildGridPage(index),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              String newTask = "";
              return AlertDialog(
                title: const Text("Add a Task"),
                content: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 0.3),
                  child: TextField(
                    onChanged: (value) {
                      newTask = value;
                    },
                    maxLines: null,
                    decoration: const InputDecoration(
                      hintText: "Enter your task...",
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    child: const Text("Cancel"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  ElevatedButton(
                    child: const Text("Add"),
                    onPressed: () {
                      _addTask(newTask);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _buildPageNavigator(),
      ),
    );
  }
}
