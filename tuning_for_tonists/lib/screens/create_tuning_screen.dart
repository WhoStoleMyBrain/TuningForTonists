import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuning_for_tonists/constants/preference_names.dart';
import 'package:tuning_for_tonists/controllers/tuning_configurations_controller.dart';

import 'package:tuning_for_tonists/models/note.dart';
import 'package:tuning_for_tonists/models/tuning_configuration.dart';

class CreateTuningScreen extends StatefulWidget {
  const CreateTuningScreen({super.key});

  @override
  State<CreateTuningScreen> createState() => _CreateTuningScreenState();
}

class _CreateTuningScreenState extends State<CreateTuningScreen> {
  TuningConfiguration newTuningConfiguration = TuningConfiguration([], '_');
  late TextEditingController _textEditingController;
  late TextEditingController _noteNameController;
  late TextEditingController _noteFrequencyController;
  Note newNote = Note(frequency: 0.0, name: '');

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(
      text: newTuningConfiguration.configurationName,
    );
    _noteNameController = TextEditingController(
      text: newNote.name,
    );
    _noteFrequencyController = TextEditingController(
      text: newNote.frequency.toString(),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _textEditingController.dispose();
    _noteNameController.dispose();
    _noteFrequencyController.dispose();
  }

  Widget getTextInputWidget() {
    return TextFormField(
      controller: _textEditingController,
      decoration: const InputDecoration(labelText: 'Name of the tuning'),
      keyboardType: TextInputType.text,
      inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
      onSaved: (value) {
        newTuningConfiguration.configurationName = value!;
        setState(() {});
      },
      onEditingComplete: () {
        newTuningConfiguration.configurationName = _textEditingController.text;
        setState(() {});
      },
      maxLines: 1,
    );
  }

  List<Widget> getCurrentNotesDisplay() {
    return newTuningConfiguration.notes
        .map((e) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Text(
                      'String ${newTuningConfiguration.notes.indexOf(e).toString()}:'),
                  Text('Name: ${e.name}'),
                  Expanded(child: Text('Frequency: ${e.frequency} Hz')),
                  Transform.rotate(
                    angle: 45 * pi / 180,
                    child: IconButton(
                      onPressed: () {
                        newTuningConfiguration.notes
                            .removeWhere((element) => element == e);
                        setState(() {});
                      },
                      icon: const Icon(Icons.add_circle_outline),
                      color: Colors.red,
                    ),
                  )
                ],
              ),
            ))
        .toList();
  }

  Widget getButtonAddString() {
    return ElevatedButton(
      onPressed: () {
        _noteFrequencyController.text = '';
        _noteNameController.text = '';
        newNote = Note(name: '', frequency: 0);
        Get.defaultDialog(
          title: 'Add new String',
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Get.back();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                if (_noteNameController.text.isEmpty ||
                    _noteNameController.text == '0' ||
                    _noteFrequencyController.text.isEmpty) {
                  return;
                }
                newNote.name = _noteNameController.text;
                newNote.frequency = double.parse(_noteFrequencyController.text);
                newTuningConfiguration.notes.add(newNote);
                setState(() {});
                Get.back();
              },
            ),
          ],
          content: Column(
            children: [
              TextFormField(
                controller: _noteFrequencyController,
                decoration: const InputDecoration(labelText: 'Frequency'),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                onChanged: (value) {
                  newNote.frequency = double.tryParse(value) ?? 0;
                },
              ),
              TextFormField(
                controller: _noteNameController,
                decoration: const InputDecoration(labelText: 'Name'),
                keyboardType: TextInputType.text,
                inputFormatters: [
                  FilteringTextInputFormatter.singleLineFormatter
                ],
                onChanged: (value) {
                  newNote.name = value;
                },
                maxLines: 1,
              ),
            ],
          ),
        );
      },
      child: const Text('Add another String'),
    );
  }

  Widget getSaveConfigurationButton() {
    return ElevatedButton(
      onPressed: () async {
        TuningConfigurationsController tuningConfigurationsController =
            Get.find();
        final prefs = await SharedPreferences.getInstance();
        var data = prefs.getString(PreferenceNames.customTunings);
        data ??= '[]';
        // data = '[]';
        Iterable jsonData = jsonDecode(data);
        List<TuningConfiguration> newConfigurations = [];
        // List<TuningConfiguration> oldConfigurations =
        //     tuningConfigurationsController
        //         .customTuningConfigurations!['Custom Configurations']!;
        List<TuningConfiguration> oldConfigurations =
            List<TuningConfiguration>.from(
                jsonData.map((e) => TuningConfiguration.fromJson(e)));
        int indexOfExistingConfiguration = oldConfigurations.indexWhere(
            (element) => (element.configurationName ==
                newTuningConfiguration.configurationName));
        // print(oldConfigurations);
        if (indexOfExistingConfiguration == -1) {
          // print('index was -1');

          newConfigurations = oldConfigurations..add(newTuningConfiguration);
        } else {
          // print('index is: $indexOfExistingConfiguration');
          oldConfigurations[indexOfExistingConfiguration] =
              newTuningConfiguration;
          newConfigurations = oldConfigurations;
        }
        var encodedString = jsonEncode(newConfigurations);
        prefs.setString(PreferenceNames.customTunings, encodedString);

        tuningConfigurationsController.customTuningConfigurations = {
          'Custom Configurations': newConfigurations
        };
      },
      child: const Text('Save configuration'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Get.back();
          },
          child: const Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  getButtonAddString(),
                  getSaveConfigurationButton(),
                ],
              ),
              getTextInputWidget(),
              ...getCurrentNotesDisplay(),
            ],
          ),
        ),
      ),
      // floatingActionButton:
    );
  }
}
