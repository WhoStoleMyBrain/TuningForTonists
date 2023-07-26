class Note {
  double frequency;
  String name;
  bool tuned;

  Note({required this.frequency, required this.name, this.tuned = false});

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
        frequency: double.tryParse(json["frequency"])!, name: json["name"]);
  }

  Map<String, dynamic> toJson() {
    return {
      "frequency": frequency.toString(),
      "name": name.toString(),
    };
  }
}
