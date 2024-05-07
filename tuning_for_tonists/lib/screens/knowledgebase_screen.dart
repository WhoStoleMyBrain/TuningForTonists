import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuning_for_tonists/constants/app_colors.dart';
import 'package:tuning_for_tonists/view_controllers/knowledgebase_controller.dart';
import 'package:tuning_for_tonists/widgets/app_drawer.dart';

class KnowledgebaseScreen extends StatefulWidget {
  const KnowledgebaseScreen({super.key});

  @override
  State<KnowledgebaseScreen> createState() => _KnowledgebaseScreenState();
}

class _KnowledgebaseScreenState extends State<KnowledgebaseScreen> {
  final KnowledgebaseController knowledgebaseController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: knowledgebaseController.scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => knowledgebaseController.openDrawer(),
          icon: const Icon(
            Icons.menu_sharp,
            color: AppColors.onPrimaryColor,
          ),
        ),
        title: const Text('Knowledgebase'),
      ),
      body: const Center(child: Text('Body')),
      drawer: const AppDrawer(),
    );
  }
}
