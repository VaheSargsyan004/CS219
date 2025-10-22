import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(GradeCalculatorApp());
}

class GradeCalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Final Grade Calculator',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      debugShowCheckedModeBanner: false,
      home: GradeCalculatorScreen(),
    );
  }
}

class Homework {
  final int id;
  double grade;
  Homework(this.id, this.grade);

  Map<String, dynamic> toJson() => {
    'id': id,
    'grade': grade,
  };

  static Homework fromJson(Map<String, dynamic> json) => Homework(
    json['id'] as int,
    json['grade'] as double,
  );
}

class IncrementIntent extends Intent {
  const IncrementIntent(this.delta);
  final double delta;
}

class GradeCalculatorScreen extends StatefulWidget {
  @override
  _GradeCalculatorScreenState createState() => _GradeCalculatorScreenState();
}

class _GradeCalculatorScreenState extends State<GradeCalculatorScreen> {

  // Keys for SharedPreferences
  static const String _KEY_HOMEWORKS = 'homeworks';
  static const String _KEY_NEXT_HW_ID = 'nextHwId';
  static const String _KEY_MAX_HW = 'maxHw';
  static const String _KEY_M1 = 'midterm1';
  static const String _KEY_M2 = 'midterm2';
  static const String _KEY_P = 'participation';
  static const String _KEY_GP = 'groupPresentation';
  static const String _KEY_FP = 'finalProject';
  static const String _KEY_FG = 'finalGrade';

  // State
  List<Homework> homeworks = [];
  int _nextHomeworkId = 0;
  static const int MAX_HW_CAP = 8;
  int _maxHomeworks = 0;
  final Map<int, FocusNode> _homeworkFocusNodes = {};

  double midterm1 = 100;
  double midterm2 = 100;
  double participation = 100;
  double groupPresentation = 100;
  double finalProject = 100;
  double finalGrade = 100;

  // Text controllers
  final TextEditingController _homeworkController = TextEditingController();
  final TextEditingController _midterm1Controller = TextEditingController();
  final TextEditingController _midterm2Controller = TextEditingController();
  final TextEditingController _participationController = TextEditingController();
  final TextEditingController _groupPresentationController = TextEditingController();
  final TextEditingController _finalProjectController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }


  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      // Load simple doubles and integers
      midterm1 = prefs.getDouble(_KEY_M1) ?? 100;
      midterm2 = prefs.getDouble(_KEY_M2) ?? 100;
      participation = prefs.getDouble(_KEY_P) ?? 100;
      groupPresentation = prefs.getDouble(_KEY_GP) ?? 100;
      finalProject = prefs.getDouble(_KEY_FP) ?? 100;
      finalGrade = prefs.getDouble(_KEY_FG) ?? 100;
      _nextHomeworkId = prefs.getInt(_KEY_NEXT_HW_ID) ?? 0;
      _maxHomeworks = prefs.getInt(_KEY_MAX_HW) ?? 0;

      final List<String>? homeworkStrings = prefs.getStringList(_KEY_HOMEWORKS);
      if (homeworkStrings != null) {
        homeworks = homeworkStrings
            .map((str) => Homework.fromJson(jsonDecode(str)))
            .toList();

        for (var hw in homeworks) {
          _homeworkFocusNodes[hw.id] = FocusNode();
        }
      } else {

      }

      _midterm1Controller.text = midterm1.toStringAsFixed(0);
      _midterm2Controller.text = midterm2.toStringAsFixed(0);
      _participationController.text = participation.toStringAsFixed(0);
      _groupPresentationController.text = groupPresentation.toStringAsFixed(0);
      _finalProjectController.text = finalProject.toStringAsFixed(0);
    });
    _calculateFinalGrade(rebuildUI: false);
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();

    final List<String> homeworkStrings = homeworks
        .map((hw) => jsonEncode(hw.toJson()))
        .toList();

    await prefs.setStringList(_KEY_HOMEWORKS, homeworkStrings);
    await prefs.setInt(_KEY_NEXT_HW_ID, _nextHomeworkId);
    await prefs.setInt(_KEY_MAX_HW, _maxHomeworks);


    await prefs.setDouble(_KEY_M1, midterm1);
    await prefs.setDouble(_KEY_M2, midterm2);
    await prefs.setDouble(_KEY_P, participation);
    await prefs.setDouble(_KEY_GP, groupPresentation);
    await prefs.setDouble(_KEY_FP, finalProject);
    await prefs.setDouble(_KEY_FG, finalGrade);
  }


  @override
  void dispose() {
    _homeworkFocusNodes.forEach((id, node) => node.dispose());
    _homeworkController.dispose();
    _midterm1Controller.dispose();
    _midterm2Controller.dispose();
    _participationController.dispose();
    _groupPresentationController.dispose();
    _finalProjectController.dispose();
    super.dispose();
  }

  void _calculateFinalGrade({bool rebuildUI = true}) {

    double totalHwGrade = 0;
    for (var hw in homeworks) {
      totalHwGrade += hw.grade;
    }

    double hwAverage = totalHwGrade / MAX_HW_CAP;

    double newFinalGrade = (hwAverage * 0.20) +
        (midterm1 * 0.10) +
        (midterm2 * 0.20) +
        (participation * 0.10) +
        (groupPresentation * 0.10) +
        (finalProject * 0.30);

    if (rebuildUI) {
      setState(() {
        finalGrade = newFinalGrade;
      });
    } else {
      finalGrade = newFinalGrade;
    }
    _saveData();
  }

  void _addHomework() {
    if (_homeworkController.text.isEmpty) return;

    if (_maxHomeworks >= MAX_HW_CAP) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot add more than $MAX_HW_CAP homeworks.')),
      );
      return;
    }

    double? grade = double.tryParse(_homeworkController.text);
    if (grade != null && grade >= 0 && grade <= 100) {
      setState(() {
        int newId = _nextHomeworkId++;
        homeworks.add(Homework(newId, grade));
        _homeworkFocusNodes[newId] = FocusNode();

        _maxHomeworks++;
      });
      _homeworkController.clear();
      _saveData(); // Save new homework list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Enter a valid grade (0-100)')),
      );
    }
  }

  void _resetHomeworks() {
    setState(() {
      homeworks = [];
      _nextHomeworkId = 0;
      _maxHomeworks = 0;
      _homeworkFocusNodes.forEach((id, node) => node.dispose());
      _homeworkFocusNodes.clear();

      midterm1 = 100;
      midterm2 = 100;
      participation = 100;
      groupPresentation = 100;
      finalProject = 100;
      finalGrade = 100;

      _homeworkController.clear();
      _midterm1Controller.text = '100';
      _midterm2Controller.text = '100';
      _participationController.text = '100';
      _groupPresentationController.text = '100';
      _finalProjectController.text = '100';
    });
    _saveData();
  }

  void _adjustGradeForHomework(Homework hw, double delta, FocusNode focusNode) {
    if (!focusNode.hasFocus) {
      focusNode.requestFocus();
      return;
    }

    setState(() {
      double newValue = hw.grade + delta;
      hw.grade = newValue.clamp(0.0, 100.0);
    });
    _saveData();
  }

  void _adjustGrade(TextEditingController controller, Function(double) onChanged, double delta) {
    double? currentValue = double.tryParse(controller.text);
    if (currentValue != null) {
      double newValue = currentValue + delta;
      newValue = newValue.clamp(0.0, 100.0);

      controller.text = newValue.toStringAsFixed(0);
      onChanged(newValue);
    }
    _saveData(); // Save adjusted non-homework grade
  }

  // Widget to build focusable TextFields for Midterms
  Widget _buildGradeInput(String label, TextEditingController controller, Function(double) onChanged) {
    final Map<Type, Action<Intent>> inputActions = <Type, Action<Intent>>{
      IncrementIntent: CallbackAction<IncrementIntent>(
        onInvoke: (IncrementIntent intent) {
          _adjustGrade(controller, onChanged, intent.delta);
          return null;
        },
      ),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Actions(
        actions: inputActions,
        child: Focus(
          autofocus: false,
          descendantsAreFocusable: true,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: '$label (0-100) (Use Up/Down Keys)',
              border: const OutlineInputBorder(),
            ),
            onChanged: (value) {
              double? val = double.tryParse(value);
              if (value.isEmpty) return;

              if (val != null && val >= 0 && val <= 100) {
                onChanged(val);
                _saveData(); // Save grade on change
              }
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map<LogicalKeySet, Intent> shortcuts = <LogicalKeySet, Intent>{
      LogicalKeySet(LogicalKeyboardKey.arrowUp): const IncrementIntent(1.0),
      LogicalKeySet(LogicalKeyboardKey.arrowDown): const IncrementIntent(-1.0),
    };

    final Map<Type, Action<Intent>> actions = <Type, Action<Intent>>{
      IncrementIntent: CallbackAction<IncrementIntent>(
        onInvoke: (IncrementIntent intent) {
          return null;
        },
      ),
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Final Grade Calculator')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Actions(
                actions: actions,
                child: Shortcuts(
                  shortcuts: shortcuts,
                  child: ListView(
                    children: [

                      // HOMEWORK UI
                      Card(
                        elevation: 4,
                        margin: const EdgeInsets.only(bottom: 20),
                        child: ExpansionTile(
                          initiallyExpanded: true,
                          title: Text(
                            'Homeworks (${_maxHomeworks} / $MAX_HW_CAP Added Homeworks)',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          subtitle: const Text('Tap to expand/collapse list.'),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _homeworkController,
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                            labelText: 'Grade to Add (0-100)',
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      ElevatedButton.icon(
                                        onPressed: _addHomework,
                                        icon: const Icon(Icons.add),
                                        label: const Text('Add Homework'),
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 20),
                                  const Text('Tap grade value to enable Up/Down key adjustments:', style: TextStyle(fontStyle: FontStyle.italic)),

                                  // List of Homeworks
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: homeworks.length,
                                    itemBuilder: (context, index) {
                                      final hw = homeworks[index];
                                      final FocusNode hwFocusNode = _homeworkFocusNodes.putIfAbsent(
                                          hw.id, () => FocusNode()
                                      );

                                      final Map<Type, Action<Intent>> hwActions = <Type, Action<Intent>>{
                                        IncrementIntent: CallbackAction<IncrementIntent>(
                                          onInvoke: (IncrementIntent intent) {
                                            _adjustGradeForHomework(hw, intent.delta, hwFocusNode);
                                            return null;
                                          },
                                        ),
                                      };

                                      return Actions(
                                        actions: hwActions,
                                        child: ListTile(
                                          key: ValueKey(hw.id),
                                          title: Row(
                                            children: [
                                              Text('Homework ${index + 1} (ID ${hw.id}): '),

                                              FocusableActionDetector(
                                                focusNode: hwFocusNode,
                                                onFocusChange: (bool hasFocus) {
                                                  if (mounted) setState(() {});
                                                },
                                                child: GestureDetector(
                                                  onTap: () => hwFocusNode.requestFocus(),
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: hwFocusNode.hasFocus ? Colors.deepPurple : Colors.transparent,
                                                            width: 2
                                                        ),
                                                        borderRadius: BorderRadius.circular(4)
                                                    ),
                                                    child: Text(
                                                      hw.grade.toStringAsFixed(0),
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        color: hwFocusNode.hasFocus ? Colors.deepPurple : Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          trailing: IconButton(
                                            icon: const Icon(Icons.close, color: Colors.red),
                                            onPressed: () {
                                              if (hwFocusNode.hasFocus) {
                                                hwFocusNode.unfocus();
                                              }
                                              hwFocusNode.dispose();
                                              _homeworkFocusNodes.remove(hw.id);

                                              setState(() {
                                                homeworks.removeWhere((h) => h.id == hw.id);
                                                _maxHomeworks = max(0, _maxHomeworks - 1); // Decrease assigned slots
                                              });
                                              _saveData();
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // END HOMEWORK UI COMPONENT

                      // Other inputs
                      _buildGradeInput('Midterm 1', _midterm1Controller, (val) {
                        midterm1 = val;
                      }),
                      _buildGradeInput('Midterm 2', _midterm2Controller, (val) {
                        midterm2 = val;
                      }),
                      _buildGradeInput('Participation', _participationController, (val) {
                        participation = val;
                      }),
                      _buildGradeInput('Group Presentation', _groupPresentationController, (val) {
                        groupPresentation = val;
                      }),
                      _buildGradeInput('Final Project', _finalProjectController, (val) {
                        finalProject = val;
                      }),
                      const SizedBox(height: 30),
                      Center(
                        child: Text(
                          'Final Grade: ${finalGrade.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // CALCULATE button
            ElevatedButton(
              onPressed: () => _calculateFinalGrade(rebuildUI: true),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 50),
                child: Text('CALCULATE', style: TextStyle(fontSize: 18)),
              ),
            ),

            // Reset button
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _resetHomeworks,
              icon: const Icon(Icons.refresh),
              label: const Text('RESET ALL GRADES', style: TextStyle(fontSize: 14)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}