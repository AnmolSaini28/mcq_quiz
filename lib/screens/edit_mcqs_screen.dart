import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditMCQFormScreen extends StatefulWidget {
  final String mcqId;

  const EditMCQFormScreen({super.key, required this.mcqId});

  @override
  _EditMCQFormScreenState createState() => _EditMCQFormScreenState();
}

class _EditMCQFormScreenState extends State<EditMCQFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _questionController;
  late List<TextEditingController> _optionControllers;
  int _correctAnswerIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController();
    _optionControllers = List.generate(4, (index) => TextEditingController());
    _loadMCQ();
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error loading MCQ')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateMCQ() async {
    if (_formKey.currentState?.validate() ?? false) {
      final mcq = {
        'question': _questionController.text,
        'options': _optionControllers.map((controller) => controller.text).toList(),
        'correctAnswerIndex': _correctAnswerIndex,
      };

      try {
        await FirebaseFirestore.instance.collection('mcqs').doc(widget.mcqId).update(mcq);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('MCQ updated successfully')));
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating MCQ: $e')));
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
        title: const Text('Edit MCQ', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _updateMCQ,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
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
