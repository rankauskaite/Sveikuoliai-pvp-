import 'package:cloud_firestore/cloud_firestore.dart';

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
      "assets/images/dobiliukas/1.png",
      "assets/images/dobiliukas/2.png",
      "assets/images/dobiliukas/3.png",
      "assets/images/dobiliukas/4.png",
    ],
    "ramuneles": [
      "assets/images/ramuneles/1.png",
      "assets/images/ramuneles/2.png",
      "assets/images/ramuneles/3.png",
      "assets/images/ramuneles/4.png",
      "assets/images/ramuneles/5.png",
      "assets/images/ramuneles/6.png",
    ],
      "zibuokle": [
        "assets/images/zibuokle/1.png",
        "assets/images/zibuokle/2.png",
        "assets/images/zibuokle/3.png",
        "assets/images/zibuokle/4.png",
        "assets/images/zibuokle/5.png",
        "assets/images/zibuokle/6.png",
        "assets/images/zibuokle/7.png",
        "assets/images/zibuokle/8.png",
    ],
      "saulegraza": [
        "assets/images/saulegraza/1.png",
        "assets/images/saulegraza/2.png",
        "assets/images/saulegraza/3.png",
        "assets/images/saulegraza/4.png",
        "assets/images/saulegraza/5.png",
        "assets/images/saulegraza/6.png",
        "assets/images/saulegraza/7.png",
        "assets/images/saulegraza/8.png",
        "assets/images/saulegraza/9.png",
        "assets/images/saulegraza/10.png",
        "assets/images/saulegraza/11.png",
        "assets/images/saulegraza/12.png",
    ],
      "gervuoge": [
        "assets/images/gervuoge/1.png",
        "assets/images/gervuoge/2.png",
        "assets/images/gervuoge/3.png",
        "assets/images/gervuoge/4.png",
        "assets/images/gervuoge/5.png",
        "assets/images/gervuoge/6.png",
        "assets/images/gervuoge/7.png",
        "assets/images/gervuoge/8.png",
        "assets/images/gervuoge/9.png",
        "assets/images/gervuoge/10.png",
        "assets/images/gervuoge/11.png",
        "assets/images/gervuoge/12.png",
        "assets/images/gervuoge/13.png",
        "assets/images/gervuoge/14.png",
        "assets/images/gervuoge/15.png",
        "assets/images/gervuoge/16.png",
        "assets/images/gervuoge/17.png",
        "assets/images/gervuoge/18.png",
        "assets/images/gervuoge/19.png",
        "assets/images/gervuoge/20.png",
        "assets/images/gervuoge/21.png",
        "assets/images/gervuoge/22.png",
        "assets/images/gervuoge/23.png",
        "assets/images/gervuoge/24.png",
      ],

      "orchideja": [
        "assets/images/orchideja/2.png",
        "assets/images/orchideja/3.png",
        "assets/images/orchideja/4.png",
        "assets/images/orchideja/5.png",
        "assets/images/orchideja/6.png",
        "assets/images/orchideja/7.png",
        "assets/images/orchideja/8.png",
        "assets/images/orchideja/9.png",
        "assets/images/orchideja/10.png",
        "assets/images/orchideja/11.png",
        "assets/images/orchideja/12.png",
        "assets/images/orchideja/13.png",
        "assets/images/orchideja/14.png",
        "assets/images/orchideja/15.png",
        "assets/images/orchideja/16.png",
      ],
      "vysnia": [
        "assets/images/vysnia/1.png",
        "assets/images/vysnia/2.png",
        "assets/images/vysnia/3.png",
        "assets/images/vysnia/4.png",
        "assets/images/vysnia/5.png",
        "assets/images/vysnia/6.png",
        "assets/images/vysnia/7.png",
        "assets/images/vysnia/8.png",
        "assets/images/vysnia/9.png",
        "assets/images/vysnia/10.png",
        "assets/images/vysnia/11.png",
        "assets/images/vysnia/12.png",
        "assets/images/vysnia/13.png",
        "assets/images/vysnia/14.png",
        "assets/images/vysnia/15.png",
        "assets/images/vysnia/16.png",
        "assets/images/vysnia/17.png",
        "assets/images/vysnia/18.png",
        "assets/images/vysnia/19.png",
        "assets/images/vysnia/20.png",
        "assets/images/vysnia/21.png",
        "assets/images/vysnia/22.png",
        "assets/images/vysnia/23.png",
        "assets/images/vysnia/24.png",
        "assets/images/vysnia/25.png",
        "assets/images/vysnia/26.png",
        "assets/images/vysnia/27.png",
        "assets/images/vysnia/28.png",
        "assets/images/vysnia/29.png",
        "assets/images/vysnia/30.png",
        "assets/images/vysnia/31.png",
        "assets/images/vysnia/32.png",
        "assets/images/vysnia/33.png",
        "assets/images/vysnia/34.png",
        "assets/images/vysnia/35.png",
        "assets/images/vysnia/36.png",
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
      photoUrl: "assets/stadijos/Dobiliukas/4.png",
      duration: 7,
      stages: _getPlantStages("dobiliukas"),
    ),
    PlantModel(
      id: "ramuneles",
      name: "Ramunėlės",
      points: 14,
      photoUrl: "assets/images/ramuneles/6.png",
      duration: 14,
      stages: _getPlantStages("ramuneles"),
    ),
    PlantModel(
      id: "saulegraza",
      name: "Saulėgrąža",
      points: 45,
      photoUrl: "assets/images/saulegraza/12.png",
      duration: 45,
      stages: _getPlantStages("saulegraza"),
    ),
    PlantModel(
      id: "gervuoge",
      name: "Gervuogė",
      points: 90,
      photoUrl: "assets/images/gervuoge/24.png",
      duration: 90, // 3 men ? ar 92/92
      stages: _getPlantStages("gervuoge"),
      ),
    PlantModel(
      id: "zibuokle",
      name: "Žibuoklė",
      points: 30,
      photoUrl: "assets/images/zibuokle/8.png",
      duration: 30,
      stages: _getPlantStages("zibuokle"),
    ),
    PlantModel(
      id: "orchideja",
      name: "Orchidėja",
      points: 60,
      photoUrl: "assets/images/orchideja/16.png",
      duration: 60,
      stages: _getPlantStages("orchideja"),
    ),
    PlantModel(
      id: "vysnia",
      name: "Vyšnia",
      points: 180,
      photoUrl: "assets/images/vysnia/36.png",
      duration: 180,
      stages: _getPlantStages("vysnia"),
    ),
  ];
}
