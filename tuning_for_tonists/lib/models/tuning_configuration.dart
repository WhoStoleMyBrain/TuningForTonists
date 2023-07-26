import "package:tuning_for_tonists/models/note.dart";

class TuningConfiguration {
  List<Note> _notes;
  String _configurationName;

  TuningConfiguration(this._notes, this._configurationName);

  set notes(List<Note> newNotes) {
    _notes = newNotes;
  }

  List<Note> get notes => _notes;

  set configurationName(String newConfigurationName) {
    _configurationName = newConfigurationName;
  }

  String get configurationName => _configurationName;

  factory TuningConfiguration.fromJson(Map<String, dynamic> json) {
    Iterable jsonNotes = json["notes"];
    return TuningConfiguration(jsonNotes.map((e) => Note.fromJson(e)).toList(),
        json["configurationName"]);
  }

  Map<String, dynamic> toJson() {
    return {
      "configurationName": _configurationName.toString(),
      "notes": _notes.map((e) => e.toJson()).toList(),
    };
  }
}
