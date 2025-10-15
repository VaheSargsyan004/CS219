import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

void main() => runApp(const HomeworkApp());

class Homework {
  final String id, subject, title;
  final DateTime dueDate;
  final bool completed;
  Homework({
    required this.id,
    required this.subject,
    required this.title,
    required this.dueDate,
    this.completed = false,
  });
  Homework copyWith({bool? completed}) =>
      Homework(id: id, subject: subject, title: title, dueDate: dueDate, completed: completed ?? this.completed);
}

// --- Bloc ---
abstract class HomeworkEvent {}
class AddHomework extends HomeworkEvent {
  final Homework hw;
  AddHomework(this.hw);
}
class ToggleHomework extends HomeworkEvent {
  final String id;
  ToggleHomework(this.id);
}

class HomeworkState {
  final List<Homework> list;
  const HomeworkState(this.list);
}

class HomeworkBloc extends Bloc<HomeworkEvent, HomeworkState> {
  HomeworkBloc() : super(const HomeworkState([])) {
    on<AddHomework>((e, emit) => emit(HomeworkState([...state.list, e.hw])));
    on<ToggleHomework>((e, emit) => emit(
        HomeworkState(state.list.map((h) => h.id == e.id ? h.copyWith(completed: !h.completed) : h).toList())));
  }
}

// --- Utils ---
String formatDate(DateTime d) =>
    "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
String newId() => DateTime.now().millisecondsSinceEpoch.toString();

// --- App ---
class HomeworkApp extends StatelessWidget {
  const HomeworkApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, __) => const HomeworkListPage()),
      GoRoute(path: '/add', builder: (_, __) => const AddHomeworkPage()),
    ]);
    return BlocProvider(
      create: (_) => HomeworkBloc(),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: router,
        title: 'Homework Tracker',
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      ),
    );
  }
}

// --- Page 1 ---
class HomeworkListPage extends StatelessWidget {
  const HomeworkListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Homework Tracker')),
      body: BlocBuilder<HomeworkBloc, HomeworkState>(
        builder: (context, state) {
          if (state.list.isEmpty) {
            return const Center(child: Text('No homework yet. Tap + to add.'));
          }
          final sorted = [...state.list]..sort((a, b) => a.dueDate.compareTo(b.dueDate));
          return ListView(
            children: sorted
                .map((hw) => Card(
              child: ListTile(
                title: Text(
                  hw.title,
                  style: TextStyle(
                    decoration:
                    hw.completed ? TextDecoration.lineThrough : null,
                  ),
                ),
                subtitle: Text('${hw.subject} • Due: ${formatDate(hw.dueDate)}'),
                trailing: Checkbox(
                  value: hw.completed,
                  onChanged: (_) =>
                      context.read<HomeworkBloc>().add(ToggleHomework(hw.id)),
                ),
              ),
            ))
                .toList(),
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

// --- Page 2 ---
class AddHomeworkPage extends StatefulWidget {
  const AddHomeworkPage({super.key});
  @override
  State<AddHomeworkPage> createState() => _AddHomeworkPageState();
}

class _AddHomeworkPageState extends State<AddHomeworkPage> {
  final _form = GlobalKey<FormState>();
  final _subject = TextEditingController();
  final _title = TextEditingController();
  DateTime? _due;

  @override
  void dispose() {
    _subject.dispose();
    _title.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) setState(() => _due = picked);
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    if (_due == null) {
      _snack('Pick a due date');
      return;
    }
    final today = DateTime.now();
    if (_due!.isBefore(DateTime(today.year, today.month, today.day))) {
      _snack('Cannot save overdue homework!');
      return;
    }

    final hw = Homework(
      id: newId(),
      subject: _subject.text.trim(),
      title: _title.text.trim(),
      dueDate: _due!,
    );
    context.read<HomeworkBloc>().add(AddHomework(hw));
    context.pop();
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Homework')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: Column(
            children: [
              TextFormField(
                controller: _subject,
                decoration: const InputDecoration(labelText: 'Subject'),
                validator: (v) => v == null || v.isEmpty ? 'Enter subject' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _title,
                decoration: const InputDecoration(labelText: 'Homework Title'),
                validator: (v) => v == null || v.isEmpty ? 'Enter title' : null,
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: _pickDate,
                child: Text(_due == null ? 'Pick Due Date' : 'Due: ${formatDate(_due!)}'),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text('Save Homework'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
