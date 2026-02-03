import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_1/DB/database_helper.dart';
import 'package:flutter_application_1/services/sync_service.dart';
import 'package:flutter_application_1/services/notification_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize notification service
  await NotificationService().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 224, 65, 25),
        ),
      ),
      home: const MyHomePage(title: 'PLANS / NOTES APP'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final dbHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> notes = [];

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  void loadNotes() async {
    final data = await dbHelper.getNotes();
    setState(() {
      notes = data;
    });
  }

  Future<void> syncNow() async {
    debugPrint('SYNC BUTTON PRESSED');
    await SyncService.pushSync();
    await SyncService.pullSync();
    loadNotes(); // refresh UI after sync
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(notes[index]['title']),
            subtitle: Text(notes[index]['content']),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// 🔄 SYNC BUTTON
          FloatingActionButton(
            heroTag: 'sync',
            onPressed: syncNow,
            child: const Icon(Icons.sync),
          ),
          const SizedBox(height: 12),

          /// ➕ ADD BUTTON
          FloatingActionButton(
            heroTag: 'add',
            onPressed: () {
              final titleController = TextEditingController();
              final contentController = TextEditingController();

              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) {
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                      left: 16,
                      right: 16,
                      top: 16,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: titleController,
                          decoration:
                              const InputDecoration(labelText: 'Title'),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: contentController,
                          decoration:
                              const InputDecoration(labelText: 'Content'),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () async {
                            await dbHelper.insertNote({
                              'title': titleController.text,
                              'content': contentController.text,
                              'synced': 0,
                            });
                            Navigator.pop(context);
                            loadNotes();
                          },
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
