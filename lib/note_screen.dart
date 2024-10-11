import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Note {
  String title;
  String content;
  Color color;
  String date;
  int participants;

  Note({
    required this.title,
    required this.content,
    required this.color,
    required this.date,
    required this.participants,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'content': content,
    'color': color.value,
    'date': date,
    'participants': participants,
  };

  factory Note.fromJson(Map<String, dynamic> json) => Note(
    title: json['title'],
    content: json['content'],
    color: Color(json['color']),
    date: json['date'],
    participants: json['participants'],
  );
}

class NoteScreen extends StatefulWidget {
  const NoteScreen({Key? key}) : super(key: key);

  @override
  _NoteScreenState createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  List<Note> notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = prefs.getStringList('notes') ?? [];
    setState(() {
      notes = notesJson.map((noteJson) => Note.fromJson(json.decode(noteJson))).toList();
    });
    if (notes.isEmpty) {
      _addInitialNotes();
    }
  }

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = notes.map((note) => json.encode(note.toJson())).toList();
    await prefs.setStringList('notes', notesJson);
  }

  void _addInitialNotes() {
    notes = [
      Note(title: 'Design System Components', content: '', color: Colors.purple, date: 'May 21', participants: 3),
      Note(title: 'Interaction Design Principles', content: '', color: Colors.green, date: 'May 21', participants: 2),
      Note(title: 'Onboarding Experience Enhancements', content: '', color: Colors.amber, date: 'May 21', participants: 4),
      Note(title: 'Responsive Design Strategies', content: '', color: Colors.red, date: 'May 21', participants: 2),
      Note(title: 'Information Architecture', content: '', color: Colors.green.shade700, date: 'May 21', participants: 1),
      Note(title: 'Typography and Readability', content: '', color: Colors.teal, date: 'May 21', participants: 1),
      Note(title: 'Usability Testing Feedback', content: '', color: Colors.blue, date: 'May 21', participants: 4),
    ];
    _saveNotes();
  }

  void _editNote(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditScreen(
          note: notes[index],
          onSave: (editedNote) {
            setState(() {
              notes[index] = editedNote;
              _saveNotes();
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Notes'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(icon: Icon(Icons.add), onPressed: () {}),
          IconButton(icon: Icon(Icons.search), onPressed: () {}),
        ],
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        padding: EdgeInsets.all(16),
        itemCount: notes.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _editNote(index),
            child: NoteCard(note: notes[index]),
          );
        },
      ),
    );
  }
}

class NoteCard extends StatelessWidget {
  final Note note;

  const NoteCard({Key? key, required this.note}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: note.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                note.title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(note.date),
                Row(
                  children: [
                    Icon(Icons.people, size: 16),
                    SizedBox(width: 4),
                    Text('${note.participants}'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class NoteEditScreen extends StatefulWidget {
  final Note note;
  final Function(Note) onSave;

  const NoteEditScreen({Key? key, required this.note, required this.onSave}) : super(key: key);

  @override
  _NoteEditScreenState createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends State<NoteEditScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Edit Note'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              widget.note.title = _titleController.text;
              widget.note.content = _contentController.text;
              widget.onSave(widget.note);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(color: Colors.white70),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _contentController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Content',
                  labelStyle: TextStyle(color: Colors.white70),
                  alignLabelWithHint: true,
                ),
                maxLines: null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}