import 'package:get/get.dart';

import '../models/note.dart';

class TuningController extends GetxController {
  Rx<Note> targetNote = Note(frequency: 440, name: 'A4').obs;
}
