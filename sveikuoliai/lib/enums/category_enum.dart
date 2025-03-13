enum CategoryType {
  sveikata,
  finansai,
  skaitymas,
  fizine_sveikata,
  issilavinimas,
  hobis,
  karjera,
  emocine_sveikata,
  produktyvumas,
  grozis,
  bekategorijos
}

// 
extension CategoryTypeExtension on CategoryType {
  static const Map<CategoryType, String> displayNames = {
    CategoryType.sveikata: "Sveikata",
    CategoryType.finansai: "Finansai",
    CategoryType.skaitymas: "Skaitymas",
    CategoryType.fizine_sveikata: "Fizinė sveikata",
    CategoryType.issilavinimas: "Išsilavinimas",
    CategoryType.hobis: "Hobis",
    CategoryType.karjera: "Karjera",
    CategoryType.emocine_sveikata: "Emocinė sveikata",
    CategoryType.produktyvumas: "Produktyvumas",
    CategoryType.grozis: "Grožis",
    CategoryType.bekategorijos: "Be kategorijos",
  };

  String toDisplayName() {
    return displayNames[this] ?? "Nežinoma";
  }

  String toJson() => name; 

  // 
  static CategoryType fromJson(String category) {
    return CategoryType.values.firstWhere(
      (e) => e.name == category,
      orElse: () => CategoryType.bekategorijos, // Jei neranda, naudoja default
    );
  }
}
