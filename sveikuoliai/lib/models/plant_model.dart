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
        "https://example.com/dobiliukas_stage1.png",
        "https://example.com/dobiliukas_stage2.png",
        "https://example.com/dobiliukas_stage3.png",
        "https://example.com/dobiliukas_stage4.png",
      ],
      "ramunele": [
        "https://example.com/ramunele_stage1.png",
        "https://example.com/ramunele_stage2.png",
        "https://example.com/ramunele_stage3.png",
        "https://example.com/ramunele_stage4.png",
        "https://example.com/ramunele_stage5.png",
        "https://example.com/ramunele_stage6.png",
      ],
      "saulėgraža": [
        "https://example.com/saulėgraža_stage1.png",
        "https://example.com/saulėgraža_stage2.png",
        "https://example.com/saulėgraža_stage3.png",
        "https://example.com/saulėgraža_stage4.png",
        "https://example.com/saulėgraža_stage5.png",
        "https://example.com/saulėgraža_stage6.png",
        "https://example.com/saulėgraža_stage7.png",
        "https://example.com/saulėgraža_stage8.png",
        "https://example.com/saulėgraža_stage9.png",
        "https://example.com/saulėgraža_stage10.png",
        "https://example.com/saulėgraža_stage11.png",
        "https://example.com/saulėgraža_stage12.png",
      ],
      "zibuokle": [
        "https://example.com/zibuokle_stage1.png",
        "https://example.com/zibuokle_stage2.png",
        "https://example.com/zibuokle_stage3.png",
        "https://example.com/zibuokle_stage4.png",
        "https://example.com/zibuokle_stage5.png",
        "https://example.com/zibuokle_stage6.png",
        "https://example.com/zibuokle_stage7.png",
        "https://example.com/zibuokle_stage8.png",
      ],
      "orchideja": [
        "https://example.com/orchideja_stage1.png",
        "https://example.com/orchideja_stage2.png",
        "https://example.com/orchideja_stage3.png",
        "https://example.com/orchideja_stage4.png",
        "https://example.com/orchideja_stage5.png",
        "https://example.com/orchideja_stage6.png",
        "https://example.com/orchideja_stage7.png",
        "https://example.com/orchideja_stage8.png",
        "https://example.com/orchideja_stage9.png",
        "https://example.com/orchideja_stage10.png",
        "https://example.com/orchideja_stage11.png",
        "https://example.com/orchideja_stage12.png",
        "https://example.com/orchideja_stage13.png",
        "https://example.com/orchideja_stage14.png",
        "https://example.com/orchideja_stage15.png",
        "https://example.com/orchideja_stage16.png",
      ],
      "vyšnia": List.generate(36, (index) => "https://example.com/vyšnia_stage${index + 1}.png"),
    };

    return stagesMap[id] ?? [];
  }

  /// **Defaultiniai augalai**
  static List<PlantModel> defaultPlants = [
    PlantModel(
      id: "dobiliukas",
      name: "Dobiliukas",
      points: 7,
      photoUrl: "https://example.com/dobiliukas_final.png",
      duration: 7,
      stages: _getPlantStages("dobiliukas"),
    ),
    PlantModel(
      id: "ramunele",
      name: "Ramunėlė",
      points: 15,
      photoUrl: "https://example.com/ramunele_final.png",
      duration: 15,
      stages: _getPlantStages("ramunele"),
    ),
    PlantModel(
      id: "saulėgraža",
      name: "Saulėgraža",
      points: 45,
      photoUrl: "https://example.com/saulėgraža_final.png",
      duration: 45,
      stages: _getPlantStages("saulėgraža"),
    ),
    PlantModel(
      id: "zibuokle",
      name: "Žibuoklė",
      points: 21,
      photoUrl: "https://example.com/zibuokle_final.png",
      duration: 21,
      stages: _getPlantStages("zibuokle"),
    ),
    PlantModel(
      id: "orchideja",
      name: "Orchidėja",
      points: 66,
      photoUrl: "https://example.com/orchideja_final.png",
      duration: 66,
      stages: _getPlantStages("orchideja"),
    ),
    PlantModel(
      id: "vyšnia",
      name: "Vyšnia",
      points: 180,
      photoUrl: "https://example.com/vyšnia_final.png",
      duration: 180,
      stages: _getPlantStages("vyšnia"),
    ),
  ];
}
