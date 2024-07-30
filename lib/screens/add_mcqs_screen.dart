import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddMCQFormScreen extends StatefulWidget {
  const AddMCQFormScreen({super.key});

  @override
  _AddMCQFormScreenState createState() => _AddMCQFormScreenState();
}

class _AddMCQFormScreenState extends State<AddMCQFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _questionController;
  late List<TextEditingController> _optionControllers;
  int _correctAnswerIndex = 0;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController();
    _optionControllers = List.generate(4, (index) => TextEditingController());
  }

  Future<void> _saveMCQ() async {
    if (_formKey.currentState?.validate() ?? false) {
      final mcq = {
        'question': _questionController.text,
        'options': _optionControllers.map((controller) => controller.text).toList(),
        'correctAnswerIndex': _correctAnswerIndex,
      };

      try {
        await FirebaseFirestore.instance.collection('mcqs').add(mcq);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('MCQ added successfully')));
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving MCQ: $e')));
      }
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        foregroundColor: Colors.black,
        backgroundColor: Colors.blue,
        elevation: 5,
        title: const Text('Add MCQ', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveMCQ,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _questionController,
                decoration: const InputDecoration(labelText: 'Question (LaTeX Supported)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a question';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text('Options'),
              ..._optionControllers.asMap().entries.map((entry) {
                int index = entry.key;
                TextEditingController controller = entry.value;
                return ListTile(
                  leading: Radio<int>(
                    value: index,
                    groupValue: _correctAnswerIndex,
                    onChanged: (value) {
                      setState(() {
                        _correctAnswerIndex = value!;
                      });
                    },
                  ),
                  title: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(labelText: 'Option ${index + 1}'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter option ${index + 1}';
                      }
                      return null;
                    },
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
