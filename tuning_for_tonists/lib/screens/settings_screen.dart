import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:tuning_for_tonists/constants/app_colors.dart';
import 'package:tuning_for_tonists/constants/calculation_type.dart';
import 'package:tuning_for_tonists/constants/routes.dart';
import 'package:tuning_for_tonists/controllers/fft_controller.dart';
import 'package:tuning_for_tonists/controllers/wave_data_controller.dart';
import '../view_controllers/settings_controller.dart';
import '../widgets/app_drawer.dart';

class SettingsScreen extends GetView<SettingsController> {
  SettingsScreen({super.key});

  final FftController fftController = Get.find();
  // final WaveDataController waveDataController = Get.find();

  void navigateToTuningsPage() {
    Get.toNamed(Routes.allTunings);
  }

  List<Widget> getSettingsRows() {
    List<Widget> allWidgets = [];

    Widget errorUnits = getErrorUnitsRow();
    Widget temperament = getTemperamentRow();
    Widget notesNaming = getNotesNamingRow();
    Widget tunerPrecision = getTunerPrecisionRow();
    Widget tuningMethod = getTuningMethodRow();
    Widget tunerSensibility = getTunerSensibilityRow();
    Widget recodingLevelPreset = getRecordingLevelPresetRow();
    Widget spectrumDisplay = getSpectrumDisplayRow();
    Widget fftSize = getFftSizeRow();
    Widget frequencyScale = getFrequencyScaleRow();
    Widget amplitudeRange = getAmplitudeRangeRow();
    Widget display = getDisplayRow();

    allWidgets.addAll([
      errorUnits,
      temperament,
      notesNaming,
      tunerPrecision,
      tuningMethod,
      tunerSensibility,
      recodingLevelPreset
    ]);
    allWidgets.add(const Divider(
      color: AppColors.onBackgroundColor,
      thickness: 3,
    ));
    allWidgets.addAll(
        [spectrumDisplay, fftSize, frequencyScale, amplitudeRange, display]);
    return allWidgets;
  }

  Row getDisplayRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Display'),
        DropdownButton(
          // value: 'A',
          items: const [
            DropdownMenuItem(value: 'default', child: Text('Default'))
          ],
          onChanged: (value) {},
        ),
      ],
    );
  }

  Row getAmplitudeRangeRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Amplitude Range'),
        DropdownButton(
          // value: 'A',
          items: const [
            DropdownMenuItem(value: 'default', child: Text('Default'))
          ],
          onChanged: (value) {},
        ),
      ],
    );
  }

  Row getFrequencyScaleRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Frequency scale'),
        DropdownButton(
          // value: 'A',
          items: const [
            DropdownMenuItem(value: 'default', child: Text('Default'))
          ],
          onChanged: (value) {},
        ),
      ],
    );
  }

  Row getFftSizeRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('FFT size'),
        SizedBox(
          width: 200,
          child: TextField(
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onSubmitted: (value) {
                fftController.setFftLength(int.parse(value));
              }),
        ),
      ],
    );
  }

  Row getSpectrumDisplayRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Spectrum Display'),
        DropdownButton(
          // value: 'A',
          items: const [
            DropdownMenuItem(value: 'default', child: Text('Default'))
          ],
          onChanged: (value) {},
        ),
      ],
    );
  }

  Row getRecordingLevelPresetRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Recording level preset'),
        DropdownButton(
          // value: 'A',
          items: const [
            DropdownMenuItem(value: 'default', child: Text('Default'))
          ],
          onChanged: (value) {},
        ),
      ],
    );
  }

  Row getTunerSensibilityRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Tuner sensibility'),
        DropdownButton(
          // value: 'A',
          items: const [
            DropdownMenuItem(value: 'standard', child: Text('Standard'))
          ],
          onChanged: (value) {},
        ),
      ],
    );
  }

  Row getTuningMethodRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Tuning Method'),
        DropdownButton(
          // value: 'A',
          items: const [
            DropdownMenuItem(value: 'noice', child: Text('Noise reduction'))
          ],
          onChanged: (value) {},
        ),
      ],
    );
  }

  Row getTunerPrecisionRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Tuner precision'),
        DropdownButton(
          // value: 'A',
          items: const [
            DropdownMenuItem(value: '2cent', child: Text('2 cent'))
          ],
          onChanged: (value) {},
        ),
      ],
    );
  }

  Row getNotesNamingRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Notes Naming'),
        DropdownButton(
          // value: 'A',
          items: const [
            DropdownMenuItem(value: 'english', child: Text('English'))
          ],
          onChanged: (value) {},
        ),
      ],
    );
  }

  Row getTemperamentRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Temperament'),
        DropdownButton(
          value: 'equal',
          items: const [DropdownMenuItem(value: 'equal', child: Text('Equal'))],
          onChanged: (value) {},
        ),
      ],
    );
  }

  Row getErrorUnitsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Error units'),
        DropdownButton(
          // value: 'A',
          items: const [DropdownMenuItem(value: 'a', child: Text('A'))],
          onChanged: (value) {},
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // TuningConfigurationsController tuningConfigurationsController = Get.find();

    return Scaffold(
      key: controller.scaffoldKey,
      appBar: AppBar(
          title: const Text('Settings'),
          leading: IconButton(
            icon: const Icon(Icons.menu_sharp),
            onPressed: () => controller.openDrawer(),
          )),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 48,
              ),
              ElevatedButton(
                  onPressed: () => navigateToTuningsPage(),
                  child: const Text('Set currently used tuning')),
              GetBuilder<WaveDataController>(
                builder: (waveDataController) => DropdownButton(
                  value: waveDataController.calculationType.value,
                  items: CalculationType.values
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e.name),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      waveDataController.setCalculationType(value);
                    }
                  },
                ),
              ),
              ...getSettingsRows(),
            ],
          ),
        ),
      ),
      drawer: const AppDrawer(),
    );
  }
}
