import "package:tuning_for_tonists/models/note.dart";

class TuningConfiguration {
  List<Note> notes;
  String configurationName;

  TuningConfiguration(this.notes, this.configurationName);

  factory TuningConfiguration.fromJson(Map<String, dynamic> json) {
    Iterable jsonNotes = json["notes"];
    return TuningConfiguration(
      jsonNotes.map((e) => Note.fromJson(e)).toList(),
      json["configurationName"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "configurationName": configurationName.toString(),
      "notes": notes.map((e) => e.toJson()).toList(),
    };
  }
}
