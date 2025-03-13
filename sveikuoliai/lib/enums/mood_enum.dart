enum MoodType {
  laiminga,
  liudna,
  pavargusi,
  pikta,
  motyvuota,
  sunerimusi,
  isitempusi,
  dekinga,
  vienisa,
  rami,
  nusivylusi,
  neutrali //default reikšmė (jei nepasirinkta)
}

// ui rodymui
extension MoodTypeExtension on MoodType {
  static const Map<MoodType, String> displayNames = {
    MoodType.laiminga: "Laiminga",
    MoodType.liudna: "Liūdna",
    MoodType.pavargusi: "Pavargusi",
    MoodType.pikta: "Pikta",
    MoodType.motyvuota: "Motyvuota",
    MoodType.sunerimusi: "Suserimusi",
    MoodType.isitempusi: "Įsitempusi",
    MoodType.dekinga: "Dėkinga",
    MoodType.vienisa: "Vieniša",
    MoodType.rami: "Rami",
    MoodType.nusivylusi: "Nusivylusi",
    MoodType.neutrali: "Neutrali",
  };

  // ui tusciam
  String toDisplayName() {
    return displayNames[this] ?? "Nežinoma";
  }

  // Firebase saugo mažosiomis be lietuviškų raidžių
  String toJson() => name; 

  // 
  static MoodType fromJson(String mood) {
    return MoodType.values.firstWhere(
      (e) => e.name == mood,
      orElse: () => MoodType.neutrali, // Jei neranda, grąžina default reikšmę
    );
  }
}
