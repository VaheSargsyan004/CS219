import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(const MyHomeworkApp());
}

class HomeworkItem {
  final String uid;
  final String subject;
  final String description;
  final DateTime deadline;
  final bool done;

  HomeworkItem({
    required this.uid,
    required this.subject,
    required this.description,
    required this.deadline,
    this.done = false,
  });

  HomeworkItem copyWith({
    String? uid,
    String? subject,
    String? description,
    DateTime? deadline,
    bool? done,
  }) {
    return HomeworkItem(
      uid: uid ?? this.uid,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      done: done ?? this.done,
    );
  }
}

abstract class HomeworkEvent {}

class AddHomeworkItem extends HomeworkEvent {
  final HomeworkItem item;
  AddHomeworkItem(this.item);
}

class ToggleHomeworkItem extends HomeworkEvent {
  final String uid;
  ToggleHomeworkItem(this.uid);
}

class HomeworkState {
  final List<HomeworkItem> items;
  const HomeworkState(this.items);
}

class HomeworkBloc extends Bloc<HomeworkEvent, HomeworkState> {
  HomeworkBloc() : super(const HomeworkState([])) {
    on<AddHomeworkItem>((event, emit) {
      final updatedList = List<HomeworkItem>.from(state.items)..add(event.item);
      emit(HomeworkState(updatedList));
    });

    on<ToggleHomeworkItem>((event, emit) {
      final updatedList = state.items
          .map((hw) => hw.uid == event.uid ? hw.copyWith(done: !hw.done) : hw)
          .toList();
      emit(HomeworkState(updatedList));
    });
  }
}

String formatDate(DateTime date) {
  return "${date.year.toString().padLeft(4,'0')}-${date.month.toString().padLeft(2,'0')}-${date.day.toString().padLeft(2,'0')}";
}

String generateId() => DateTime.now().toIso8601String();

class MyHomeworkApp extends StatelessWidget {
  const MyHomeworkApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (context, state) => const HomeworkListScreen()),
        GoRoute(path: '/add', builder: (context, state) => const AddHomeworkScreen()),
      ],
    );

    return BlocProvider(
      create: (_) => HomeworkBloc(),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: router,
        title: 'Homework Tracker',
        theme: ThemeData(primarySwatch: Colors.blue),
      ),
    );
  }
}

class HomeworkListScreen extends StatelessWidget {
  const HomeworkListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Homework Tracker')),
      body: BlocBuilder<HomeworkBloc, HomeworkState>(
        builder: (context, state) {
          if (state.items.isEmpty) {
            return const Center(child: Text('No homework added. Click + to add.'));
          }

          final sortedItems = List<HomeworkItem>.from(state.items)
            ..sort((a, b) => a.deadline.compareTo(b.deadline));

          return ListView.builder(
            itemCount: sortedItems.length,
            itemBuilder: (context, index) {
              final hw = sortedItems[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                child: ListTile(
                  title: Text(
                    hw.description,
                    style: TextStyle(
                      decoration: hw.done ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  subtitle: Text('${hw.subject} • Due: ${formatDate(hw.deadline)}'),
                  trailing: Checkbox(
                    value: hw.done,
                    onChanged: (_) {
                      context.read<HomeworkBloc>().add(ToggleHomeworkItem(hw.uid));
                    },
                  ),
                  onTap: () => context.read<HomeworkBloc>().add(ToggleHomeworkItem(hw.uid)),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddHomeworkScreen extends StatefulWidget {
  const AddHomeworkScreen({super.key});

  @override
  State<AddHomeworkScreen> createState() => _AddHomeworkScreenState();
}

class _AddHomeworkScreenState extends State<AddHomeworkScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _saveHomework() {
    if (!_formKey.currentState!.validate()) return;

    final hw = HomeworkItem(
      uid: generateId(),
      subject: _subjectController.text.trim(),
      description: _descriptionController.text.trim(),
      deadline: _selectedDate ?? DateTime.now(),
    );

    context.read<HomeworkBloc>().add(AddHomeworkItem(hw));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Homework')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Please enter subject' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Homework Description',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Enter homework description' : null,
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _pickDate,
                child: Text(_selectedDate == null
                    ? 'Select Due Date'
                    : 'Due: ${formatDate(_selectedDate!)}'),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _saveHomework,
                icon: const Icon(Icons.save),
                label: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}