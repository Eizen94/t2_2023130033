import 'package:flutter/material.dart';
import 'task_data.dart';

class TaskScreen extends StatefulWidget {
  final int initialTaskIndex;

  const TaskScreen({Key? key, required this.initialTaskIndex}) : super(key: key);

  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        widget.initialTaskIndex * 100.0, // Approximate height of each task card
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Tasks'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(icon: Icon(Icons.add), onPressed: () => _addTask(context)),
          IconButton(icon: Icon(Icons.sort), onPressed: () {}),
        ],
      ),
      body: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.all(16),
        itemCount: TaskData.tasks.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: TaskCard(
              task: TaskData.tasks[index],
              isHighlighted: index == widget.initialTaskIndex,
              onEdit: () => _editTask(context, index),
              onDelete: () => _deleteTask(index),
            ),
          );
        },
      ),
    );
  }

  void _addTask(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => TaskEditDialog(
        task: Task(title: '', color: Colors.amber.shade300),
        onSave: (newTask) {
          setState(() {
            TaskData.tasks.add(newTask);
          });
        },
      ),
    );
  }

  void _editTask(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) => TaskEditDialog(
        task: TaskData.tasks[index],
        onSave: (editedTask) {
          setState(() {
            TaskData.tasks[index] = editedTask;
          });
        },
      ),
    );
  }

  void _deleteTask(int index) {
    setState(() {
      TaskData.tasks.removeAt(index);
    });
  }
}

class TaskCard extends StatelessWidget {
  final Task task;
  final bool isHighlighted;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskCard({
    Key? key,
    required this.task,
    required this.isHighlighted,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: task.color,
        borderRadius: BorderRadius.circular(16),
        border: isHighlighted ? Border.all(color: Colors.white, width: 2) : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: onEdit,
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ],
            ),
            if (task.time != null) SizedBox(height: 8),
            if (task.time != null) Text(task.time!),
            if (task.participants != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    Icon(Icons.people, size: 16),
                    SizedBox(width: 4),
                    Text('+${task.participants}'),
                  ],
                ),
              ),
            if (task.link != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    Icon(Icons.link, size: 16),
                    SizedBox(width: 4),
                    Text(task.link!),
                  ],
                ),
              ),
            if (task.tools != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: task.tools!.map((tool) => Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(tool, style: TextStyle(fontSize: 12)),
                  )).toList(),
                ),
              ),
            if (task.showCheckButtons)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.red,
                      radius: 16,
                      child: Icon(Icons.close, color: Colors.white, size: 16),
                    ),
                    SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: Colors.green,
                      radius: 16,
                      child: Icon(Icons.check, color: Colors.white, size: 16),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class TaskEditDialog extends StatefulWidget {
  final Task task;
  final Function(Task) onSave;

  const TaskEditDialog({Key? key, required this.task, required this.onSave}) : super(key: key);

  @override
  _TaskEditDialogState createState() => _TaskEditDialogState();
}

class _TaskEditDialogState extends State<TaskEditDialog> {
  late TextEditingController _titleController;
  late TextEditingController _timeController;
  late TextEditingController _participantsController;
  late TextEditingController _linkController;
  late TextEditingController _toolsController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _timeController = TextEditingController(text: widget.task.time);
    _participantsController = TextEditingController(text: widget.task.participants?.toString() ?? '');
    _linkController = TextEditingController(text: widget.task.link);
    _toolsController = TextEditingController(text: widget.task.tools?.join(', ') ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.task.title.isEmpty ? 'Add Task' : 'Edit Task'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _timeController,
              decoration: InputDecoration(labelText: 'Time'),
            ),
            TextField(
              controller: _participantsController,
              decoration: InputDecoration(labelText: 'Participants'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _linkController,
              decoration: InputDecoration(labelText: 'Link'),
            ),
            TextField(
              controller: _toolsController,
              decoration: InputDecoration(labelText: 'Tools (comma-separated)'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            widget.task.title = _titleController.text;
            widget.task.time = _timeController.text;
            widget.task.participants = int.tryParse(_participantsController.text);
            widget.task.link = _linkController.text;
            widget.task.tools = _toolsController.text.split(',').map((e) => e.trim()).toList();
            widget.onSave(widget.task);
            Navigator.pop(context);
          },
          child: Text('Save'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _timeController.dispose();
    _participantsController.dispose();
    _linkController.dispose();
    _toolsController.dispose();
    super.dispose();
  }
}