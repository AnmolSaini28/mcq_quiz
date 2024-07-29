import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MCQFormScreen extends StatefulWidget {
  final String? mcqId;

  const MCQFormScreen({super.key, this.mcqId});

  @override
  _MCQFormScreenState createState() => _MCQFormScreenState();
}

class _MCQFormScreenState extends State<MCQFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _questionController;
  late List<TextEditingController> _optionControllers;
  int _correctAnswerIndex = 0;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController();
    _optionControllers = List.generate(4, (index) => TextEditingController());

    if (widget.mcqId != null) {
      _loadMCQ();
    }
  }

  Future<void> _loadMCQ() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('mcqs').doc(widget.mcqId).get();
      final data = doc.data();
      if (data != null) {
        setState(() {
          _questionController.text = data['question'];
          _optionControllers.asMap().forEach((index, controller) {
            controller.text = data['options'][index];
          });
          _correctAnswerIndex = data['correctAnswerIndex'];
        });
      }
    } catch (e) {
      // Handle any errors
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error loading MCQ')));
    }
  }

  Future<void> _saveMCQ() async {
    if (_formKey.currentState?.validate() ?? false) {
      final mcq = {
        'question': _questionController.text,
        'options': _optionControllers.map((controller) => controller.text).toList(),
        'correctAnswerIndex': _correctAnswerIndex,
      };

      try {
        if (widget.mcqId == null) {
          await FirebaseFirestore.instance.collection('mcqs').add(mcq);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('MCQ added successfully')));
          print('MCQ added: $mcq');
        } else {
          await FirebaseFirestore.instance.collection('mcqs').doc(widget.mcqId).update(mcq);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('MCQ updated successfully')));
          print('MCQ updated: $mcq');
        }
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving MCQ: $e')));
        print('Error saving MCQ: $e');
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
        title: Text(widget.mcqId == null ? 'Add MCQ' : 'Edit MCQ', style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w700),),
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
