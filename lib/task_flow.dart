import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:convert';
import 'task_screen.dart';
import 'note_screen.dart';
import 'profile_screen.dart';
import 'task_data.dart';

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

class TaskFlowScreen extends StatefulWidget {
  const TaskFlowScreen({Key? key}) : super(key: key);

  @override
  _TaskFlowScreenState createState() => _TaskFlowScreenState();
}

class _TaskFlowScreenState extends State<TaskFlowScreen> {
  int _currentTaskIndex = 0;
  Note? _firstNote;
  final ImagePicker _picker = ImagePicker();
  CameraController? _cameraController;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadFirstNote();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    if (kIsWeb) {
      // Web platform
      setState(() {
        _isCameraInitialized = false;
      });
      return;
    }

    if (Platform.isAndroid || Platform.isIOS) {
      // Mobile platforms
      setState(() {
        _isCameraInitialized = true;
      });
      return;
    }

    // Desktop platforms
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _isCameraInitialized = false;
        });
        return;
      }

      _cameraController = CameraController(cameras[0], ResolutionPreset.medium);
      await _cameraController!.initialize();
      if (!mounted) return;
      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      print('Error initializing camera: $e');
      setState(() {
        _isCameraInitialized = false;
      });
    }
  }

  Future<void> _loadFirstNote() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = prefs.getStringList('notes') ?? [];
    if (notesJson.isNotEmpty) {
      setState(() {
        _firstNote = Note.fromJson(json.decode(notesJson.first));
      });
    }
  }

  void _nextTask() {
    setState(() {
      _currentTaskIndex = (_currentTaskIndex + 1) % TaskData.tasks.length;
    });
  }

  void _previousTask() {
    setState(() {
      _currentTaskIndex = (_currentTaskIndex - 1 + TaskData.tasks.length) % TaskData.tasks.length;
    });
  }

  Future<void> _openCamera() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Camera functionality is not available on web.')),
      );
      return;
    }

    if (Platform.isAndroid || Platform.isIOS) {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        _handleCapturedImage(photo.path);
      }
    } else if (_isCameraInitialized && _cameraController != null) {
      final directory = await getApplicationDocumentsDirectory();
      final String fileName = path.join(directory.path, '${DateTime.now()}.png');
      
      try {
        XFile file = await _cameraController!.takePicture();
        await file.saveTo(fileName);
        _handleCapturedImage(fileName);
      } catch (e) {
        print('Error taking picture: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error taking picture. Please try again.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Camera is not available on this device.')),
      );
    }
  }

  void _handleCapturedImage(String imagePath) {
    print('Photo taken: $imagePath');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Photo taken and saved to: $imagePath')),
    );
    // You can add more functionality here, like displaying the image or uploading it
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            _buildTitle(),
            const SizedBox(height: 16),
            _buildTaskNavigation(),
            const SizedBox(height: 16),
            _buildCurrentTask(),
            const SizedBox(height: 16),
            _buildTasksAndNotes(context),
            const SizedBox(height: 16),
            _buildQuickActions(),
            const SizedBox(height: 16),
            _buildReminder(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Task Flow',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen())),
          child: CircleAvatar(
            backgroundColor: Colors.purple,
            child: Icon(Icons.person, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return const Text(
      'Daily Work\nPriorities',
      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
    );
  }

  Widget _buildTaskNavigation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: _previousTask,
        ),
        Text(
          'Tasks',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        IconButton(
          icon: Icon(Icons.arrow_forward_ios, color: Colors.white),
          onPressed: _nextTask,
        ),
      ],
    );
  }

  Widget _buildCurrentTask() {
    final task = TaskData.tasks[_currentTaskIndex];
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: task.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            task.title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(task.time ?? ''),
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
        ],
      ),
    );
  }

  Widget _buildTasksAndNotes(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AspectRatio(
            aspectRatio: 1,
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TaskScreen(initialTaskIndex: _currentTaskIndex)),
              ),
              child: _buildCard('Tasks', Colors.amber, 'View all tasks', null, null),
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: AspectRatio(
            aspectRatio: 1,
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => NoteScreen()),
              ).then((_) => _loadFirstNote()),
              child: _buildNoteCard(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(String title, Color color, String subtitle, IconData? icon, String? iconText) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(subtitle, style: TextStyle(fontSize: 14)),
            if (icon != null && iconText != null)
              Row(
                children: [
                  Icon(icon, size: 14),
                  SizedBox(width: 4),
                  Text(iconText, style: TextStyle(fontSize: 12)),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteCard() {
    if (_firstNote == null) {
      return _buildCard('Notes', Colors.green, 'Create new notes', null, null);
    }
    return Container(
      decoration: BoxDecoration(
        color: _firstNote!.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Notes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Expanded(
              child: Text(
                _firstNote!.title,
                style: TextStyle(fontSize: 16),
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_firstNote!.date),
                Row(
                  children: [
                    Icon(Icons.people, size: 16),
                    SizedBox(width: 4),
                    Text('${_firstNote!.participants}'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(child: _buildActionButton(Icons.mail, Colors.red, _launchEmail)),
        SizedBox(width: 16),
        Expanded(child: _buildActionButton(Icons.camera_alt, Colors.green, _openCamera)),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(child: Icon(icon, color: Colors.white, size: 30)),
      ),
    );
  }

  Widget _buildReminder() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Reminders', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('You have 3 new notifications', style: TextStyle(color: Colors.white70)),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('View All', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Icon(Icons.arrow_forward, color: Colors.white),
            ],
          ),
        ],
      ),
    );
  }

  void _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'klausi_lanthaler@outlook.com',
      query: encodeQueryParameters(<String, String>{
        'subject': 'Contact from Task Flow App',
      }),
    );

    if (await canLaunch(emailLaunchUri.toString())) {
      await launch(emailLaunchUri.toString());
    } else {
      throw 'Could not launch $emailLaunchUri';
    }
  }

  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
}