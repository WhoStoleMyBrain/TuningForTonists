import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuning_for_tonists/constants/routes.dart';
import 'package:tuning_for_tonists/controllers/tuning_configurations_controller.dart';
import 'package:tuning_for_tonists/controllers/tuning_controller.dart';

class AllTuningsScreen extends StatefulWidget {
  const AllTuningsScreen({super.key});

  @override
  State<AllTuningsScreen> createState() => _AllTuningsScreenState();
}

class _AllTuningsScreenState extends State<AllTuningsScreen> {
  TuningConfigurationsController tuningConfigurationsController = Get.find();
  TuningController tuningController = Get.find();

  Widget getDivider() {
    return const Divider(
      height: 3,
      color: Colors.black,
    );
  }

  TextStyle getTextStyle() {
    return const TextStyle(
      fontSize: 18,
    );
  }

  TextStyle getSelectedTextStyle() {
    return const TextStyle(
      fontSize: 18,
      backgroundColor: Colors.green,
    );
  }

  Widget getSizedBox(double height) {
    return SizedBox(
      height: height,
    );
  }

  List<Widget> displayTuningConfigurations() {
    List<Widget> returnWidgets = [];
    for (var element
        in tuningConfigurationsController.getTuningConfigurations().entries) {
      returnWidgets.add(Text(
        element.key,
        style: getTextStyle(),
      ));
      returnWidgets.add(getDivider());
      returnWidgets.add(getSizedBox(16));
      for (var e in element.value) {
        returnWidgets.add(GestureDetector(
          onTap: () {
            tuningController.setTuningConfiguration(e);
            setState(() {});
          },
          child: Container(
            color: tuningController.tuningConfiguration == e
                ? Colors.green
                : Colors.white,
            width: double.infinity,
            child: Text(
              e.configurationName,
              textAlign: TextAlign.center,
              style: getTextStyle(),
            ),
          ),
        ));
        returnWidgets.add(getSizedBox(24));
      }
    }
    return returnWidgets;
  }

  void navigateToTuningCreationPage() {
    Get.toNamed(Routes.createCustomTuning);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: const Icon(Icons.arrow_back),
        ),
        title: const Text('All available tunings'),
      ),
      body: SingleChildScrollView(
        // child: SliverGrid,
        child: Center(
          child: Obx(
            () => Column(
              children: [
                ...displayTuningConfigurations(),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          navigateToTuningCreationPage();
          // print('Press detected');
        },
      ),
    );
  }
}
