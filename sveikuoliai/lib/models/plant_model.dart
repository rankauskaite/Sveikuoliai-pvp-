class PlantModel {
  String id;
  String name;
  int points;
  String photoUrl; // Galutinis vaizdas
  int duration; //  dienomis
  List<String> stages; // saugomos kode

  PlantModel({
    required this.id,
    required this.name,
    required this.points,
    required this.photoUrl,
    required this.duration,
    required this.stages,
  });

  // i json, nesuagojami stages
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'points': points,
      'photoUrl': photoUrl,
      'duration': duration,
    };
  }

  // is json be stages
  factory PlantModel.fromJson(String id, Map<String, dynamic> json) {
    return PlantModel(
      id: id,
      name: json['name'] ?? '',
      points: json['points'] ?? 0,
      photoUrl: json['photoUrl'] ?? '',
      duration: json['duration'] ?? 0,
      stages: _getPlantStages(id), // vidine funkcija pagal id
    );
  }

  /// nuoroda i masyva(lista?) paimt reikiama paveiksliuka
  String getStageImage(int progressPercentage) {
    if (stages.isEmpty) return photoUrl;
    int stageIndex = (progressPercentage / 100 * (stages.length - 1)).round();
    return stages[stageIndex.clamp(0, stages.length - 1)];
  }

  /// stadiju paveiklsiukai. imama pagal id
  static List<String> _getPlantStages(String id) {
    Map<String, List<String>> stagesMap = {
      "dobiliukas": [
        "assets/images/augalai/dobiliukas/1.png",
        "assets/images/augalai/dobiliukas/2.png",
        "assets/images/augalai/dobiliukas/3.png",
        "assets/images/augalai/dobiliukas/4.png",
      ],
      "ramuneles": [
        "assets/images/augalai/ramuneles/1.png",
        "assets/images/augalai/ramuneles/2.png",
        "assets/images/augalai/ramuneles/3.png",
        "assets/images/augalai/ramuneles/4.png",
        "assets/images/augalai/ramuneles/5.png",
        "assets/images/augalai/ramuneles/6.png",
      ],
      "zibuokle": [
        "assets/images/augalai/zibuokle/1.png",
        "assets/images/augalai/zibuokle/2.png",
        "assets/images/augalai/zibuokle/3.png",
        "assets/images/augalai/zibuokle/4.png",
        "assets/images/augalai/zibuokle/5.png",
        "assets/images/augalai/zibuokle/6.png",
        "assets/images/augalai/zibuokle/7.png",
        "assets/images/augalai/zibuokle/8.png",
      ],
      "saulegraza": [
        "assets/images/augalai/saulegraza/1.png",
        "assets/images/augalai/saulegraza/2.png",
        "assets/images/augalai/saulegraza/3.png",
        "assets/images/augalai/saulegraza/4.png",
        "assets/images/augalai/saulegraza/5.png",
        "assets/images/augalai/saulegraza/6.png",
        "assets/images/augalai/saulegraza/7.png",
        "assets/images/augalai/saulegraza/8.png",
        "assets/images/augalai/saulegraza/9.png",
        "assets/images/augalai/saulegraza/10.png",
        "assets/images/augalai/saulegraza/11.png",
        "assets/images/augalai/saulegraza/12.png",
      ],
      "gervuoge": [
        "assets/images/augalai/gervuoge/1.png",
        "assets/images/augalai/gervuoge/2.png",
        "assets/images/augalai/gervuoge/3.png",
        "assets/images/augalai/gervuoge/4.png",
        "assets/images/augalai/gervuoge/5.png",
        "assets/images/augalai/gervuoge/6.png",
        "assets/images/augalai/gervuoge/7.png",
        "assets/images/augalai/gervuoge/8.png",
        "assets/images/augalai/gervuoge/9.png",
        "assets/images/augalai/gervuoge/10.png",
        "assets/images/augalai/gervuoge/11.png",
        "assets/images/augalai/gervuoge/12.png",
        "assets/images/augalai/gervuoge/13.png",
        "assets/images/augalai/gervuoge/14.png",
        "assets/images/augalai/gervuoge/15.png",
        "assets/images/augalai/gervuoge/16.png",
        "assets/images/augalai/gervuoge/17.png",
        "assets/images/augalai/gervuoge/18.png",
        "assets/images/augalai/gervuoge/19.png",
        "assets/images/augalai/gervuoge/20.png",
        "assets/images/augalai/gervuoge/21.png",
        "assets/images/augalai/gervuoge/22.png",
        "assets/images/augalai/gervuoge/23.png",
        "assets/images/augalai/gervuoge/24.png",
      ],
      "orchideja": [
        "assets/images/augalai/orchideja/1.png",
        "assets/images/augalai/orchideja/2.png",
        "assets/images/augalai/orchideja/3.png",
        "assets/images/augalai/orchideja/4.png",
        "assets/images/augalai/orchideja/5.png",
        "assets/images/augalai/orchideja/6.png",
        "assets/images/augalai/orchideja/7.png",
        "assets/images/augalai/orchideja/8.png",
        "assets/images/augalai/orchideja/9.png",
        "assets/images/augalai/orchideja/10.png",
        "assets/images/augalai/orchideja/11.png",
        "assets/images/augalai/orchideja/12.png",
        "assets/images/augalai/orchideja/13.png",
        "assets/images/augalai/orchideja/14.png",
        "assets/images/augalai/orchideja/15.png",
        "assets/images/augalai/orchideja/16.png",
      ],
      "vysnia": [
        "assets/images/augalai/vysnia/1.png",
        "assets/images/augalai/vysnia/2.png",
        "assets/images/augalai/vysnia/3.png",
        "assets/images/augalai/vysnia/4.png",
        "assets/images/augalai/vysnia/5.png",
        "assets/images/augalai/vysnia/6.png",
        "assets/images/augalai/vysnia/7.png",
        "assets/images/augalai/vysnia/8.png",
        "assets/images/augalai/vysnia/9.png",
        "assets/images/augalai/vysnia/10.png",
        "assets/images/augalai/vysnia/11.png",
        "assets/images/augalai/vysnia/12.png",
        "assets/images/augalai/vysnia/13.png",
        "assets/images/augalai/vysnia/14.png",
        "assets/images/augalai/vysnia/15.png",
        "assets/images/augalai/vysnia/16.png",
        "assets/images/augalai/vysnia/17.png",
        "assets/images/augalai/vysnia/18.png",
        "assets/images/augalai/vysnia/19.png",
        "assets/images/augalai/vysnia/20.png",
        "assets/images/augalai/vysnia/21.png",
        "assets/images/augalai/vysnia/22.png",
        "assets/images/augalai/vysnia/23.png",
        "assets/images/augalai/vysnia/24.png",
        "assets/images/augalai/vysnia/25.png",
        "assets/images/augalai/vysnia/26.png",
        "assets/images/augalai/vysnia/27.png",
        "assets/images/augalai/vysnia/28.png",
        "assets/images/augalai/vysnia/29.png",
        "assets/images/augalai/vysnia/30.png",
        "assets/images/augalai/vysnia/31.png",
        "assets/images/augalai/vysnia/32.png",
        "assets/images/augalai/vysnia/33.png",
        "assets/images/augalai/vysnia/34.png",
        "assets/images/augalai/vysnia/35.png",
        "assets/images/augalai/vysnia/36.png",
      ],
    };
    return stagesMap[id] ?? [];
  }

  /// **Defaultiniai augalai**
  static List<PlantModel> defaultPlants = [
    PlantModel(
      id: "dobiliukas",
      name: "Dobiliukas",
      points: 7,
      photoUrl: "assets/images/augalai/dobiliukas/4.png",
      duration: 7,
      stages: _getPlantStages("dobiliukas"),
    ),
    PlantModel(
      id: "ramuneles",
      name: "Ramunėlės",
      points: 14,
      photoUrl: "assets/images/augalai/ramuneles/6.png",
      duration: 14,
      stages: _getPlantStages("ramuneles"),
    ),
    PlantModel(
      id: "saulegraza",
      name: "Saulėgrąža",
      points: 45,
      photoUrl: "assets/images/augalai/saulegraza/12.png",
      duration: 45,
      stages: _getPlantStages("saulegraza"),
    ),
    PlantModel(
      id: "gervuoge",
      name: "Gervuogė",
      points: 90,
      photoUrl: "assets/images/augalai/gervuoge/24.png",
      duration: 90, // 3 men ? ar 92/92
      stages: _getPlantStages("gervuoge"),
    ),
    PlantModel(
      id: "zibuokle",
      name: "Žibuoklė",
      points: 30,
      photoUrl: "assets/images/augalai/zibuokle/8.png",
      duration: 30,
      stages: _getPlantStages("zibuokle"),
    ),
    PlantModel(
      id: "orchideja",
      name: "Orchidėja",
      points: 60,
      photoUrl: "assets/images/augalai/orchideja/16.png",
      duration: 60,
      stages: _getPlantStages("orchideja"),
    ),
    PlantModel(
      id: "vysnia",
      name: "Vyšnia",
      points: 180,
      photoUrl: "assets/images/augalai/vysnia/36.png",
      duration: 180,
      stages: _getPlantStages("vysnia"),
    ),
  ];
}
