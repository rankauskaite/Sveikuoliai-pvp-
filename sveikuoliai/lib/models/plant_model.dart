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
      "assets/stadijos/Dobiliukas/1.png",
      "assets/stadijos/Dobiliukas/2.png",
      "assets/stadijos/Dobiliukas/3.png",
      "assets/stadijos/Dobiliukas/4.png",
    ],
    "ramuneles": [
      "assets/stadijos/Ramunėlės/1.png",
      "assets/stadijos/Ramunėlės/2.png",
      "assets/stadijos/Ramunėlės/3.png",
      "assets/stadijos/Ramunėlės/4.png",
      "assets/stadijos/Ramunėlės/5.png",
      "assets/stadijos/Ramunėlės/6.png",
    ],
      "saulėgraža": [
        "assets/stadijos/Saulėgrąža/01.png",
        "assets/stadijos/Saulėgrąža/02.png",
        "assets/stadijos/Saulėgrąža/03.png",
        "assets/stadijos/Saulėgrąža/04.png",
        "assets/stadijos/Saulėgrąža/05.png",
        "assets/stadijos/Saulėgrąža/06.png",
        "assets/stadijos/Saulėgrąža/07.png",
        "assets/stadijos/Saulėgrąža/08.png",
        "assets/stadijos/Saulėgrąža/09.png",
        "assets/stadijos/Saulėgrąža/10.png",
        "assets/stadijos/Saulėgrąža/11.png",
        "assets/stadijos/Saulėgrąža/12.png",
    ],
      "gervuoge": [
        "assets/stadijos/Gervuogė/01.png",
        "assets/stadijos/Gervuogė/02.png",
        "assets/stadijos/Gervuogė/03.png",
        "assets/stadijos/Gervuogė/04.png",
        "assets/stadijos/Gervuogė/05.png",
        "assets/stadijos/Gervuogė/06.png",
        "assets/stadijos/Gervuogė/07.png",
        "assets/stadijos/Gervuogė/08.png",
        "assets/stadijos/Gervuogė/09.png",
        "assets/stadijos/Gervuogė/10.png",
        "assets/stadijos/Gervuogė/11.png",
        "assets/stadijos/Gervuogė/12.png",
        "assets/stadijos/Gervuogė/13.png",
        "assets/stadijos/Gervuogė/14.png",
        "assets/stadijos/Gervuogė/15.png",
        "assets/stadijos/Gervuogė/16.png",
        "assets/stadijos/Gervuogė/17.png",
        "assets/stadijos/Gervuogė/18.png",
        "assets/stadijos/Gervuogė/19.png",
        "assets/stadijos/Gervuogė/20.png",
        "assets/stadijos/Gervuogė/21.png",
        "assets/stadijos/Gervuogė/22.png",
        "assets/stadijos/Gervuogė/23.png",
        "assets/stadijos/Gervuogė/24.png",
      ],

      "orchideja": [
        "assets/stadijos/Orchidėja/02.png",
        "assets/stadijos/Orchidėja/03.png",
        "assets/stadijos/Orchidėja/04.png",
        "assets/stadijos/Orchidėja/05.png",
        "assets/stadijos/Orchidėja/06.png",
        "assets/stadijos/Orchidėja/07.png",
        "assets/stadijos/Orchidėja/08.png",
        "assets/stadijos/Orchidėja/09.png",
        "assets/stadijos/Orchidėja/10.png",
        "assets/stadijos/Orchidėja/11.png",
        "assets/stadijos/Orchidėja/12.png",
        "assets/stadijos/Orchidėja/13.png",
        "assets/stadijos/Orchidėja/14.png",
        "assets/stadijos/Orchidėja/15.png",
        "assets/stadijos/Orchidėja/16.png",
      ],
      "vyšnia": [
        "assets/stadijos/Vyšnia/01.png",
        "assets/stadijos/Vyšnia/02.png",
        "assets/stadijos/Vyšnia/03.png",
        "assets/stadijos/Vyšnia/04.png",
        "assets/stadijos/Vyšnia/05.png",
        "assets/stadijos/Vyšnia/06.png",
        "assets/stadijos/Vyšnia/07.png",
        "assets/stadijos/Vyšnia/08.png",
        "assets/stadijos/Vyšnia/09.png",
        "assets/stadijos/Vyšnia/10.png",
        "assets/stadijos/Vyšnia/11.png",
        "assets/stadijos/Vyšnia/12.png",
        "assets/stadijos/Vyšnia/13.png",
        "assets/stadijos/Vyšnia/14.png",
        "assets/stadijos/Vyšnia/15.png",
        "assets/stadijos/Vyšnia/16.png",
        "assets/stadijos/Vyšnia/17.png",
        "assets/stadijos/Vyšnia/18.png",
        "assets/stadijos/Vyšnia/19.png",
        "assets/stadijos/Vyšnia/20.png",
        "assets/stadijos/Vyšnia/21.png",
        "assets/stadijos/Vyšnia/22.png",
        "assets/stadijos/Vyšnia/23.png",
        "assets/stadijos/Vyšnia/24.png",
        "assets/stadijos/Vyšnia/25.png",
        "assets/stadijos/Vyšnia/26.png",
        "assets/stadijos/Vyšnia/27.png",
        "assets/stadijos/Vyšnia/28.png",
        "assets/stadijos/Vyšnia/29.png",
        "assets/stadijos/Vyšnia/30.png",
        "assets/stadijos/Vyšnia/31.png",
        "assets/stadijos/Vyšnia/32.png",
        "assets/stadijos/Vyšnia/33.png",
        "assets/stadijos/Vyšnia/34.png",
        "assets/stadijos/Vyšnia/35.png",
        "assets/stadijos/Vyšnia/36.png",
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
      points: 15,
      photoUrl: "assets/stadijos/Ramunėlės/6.png",
      duration: 15,
      stages: _getPlantStages("ramuneles"),
    ),
    PlantModel(
      id: "saulėgraža",
      name: "Saulėgraža",
      points: 45,
      photoUrl: "assets/stadijos/Saulėgrąža/12.png",
      duration: 45,
      stages: _getPlantStages("saulėgraža"),
    ),
    PlantModel(
      id: "",
      name: "Gervuogė",
      points: 24,
      photoUrl: "assets/stadijos/Gervuogė/24.png",
      duration: 90, // 3 men ? ar 92/92
      stages: _getPlantStages("gervuoge"),
    ),
    PlantModel(
      id: "orchideja",
      name: "Orchidėja",
      points: 66,
      photoUrl: "assets/stadijos/Orchidėja/16.png",
      duration: 66,
      stages: _getPlantStages("orchideja"),
    ),
    PlantModel(
      id: "vyšnia",
      name: "Vyšnia",
      points: 180,
      photoUrl: "assets/stadijos/Vyšnia/36.png",
      duration: 180,
      stages: _getPlantStages("vyšnia"),
    ),
  ];
}
