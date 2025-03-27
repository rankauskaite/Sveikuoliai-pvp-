import 'package:cloud_firestore/cloud_firestore.dart';

class PlantModel {
  String id;
  String name;
  int points;
  String photoUrl; // Final plant image (when fully grown)
  int duration; // in days
  List<String> stages; // Growth stage images

  PlantModel({
    required this.id,
    required this.name,
    required this.points,
    required this.photoUrl,
    required this.duration,
    required this.stages,
  });

  // to json
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'points': points,
      'photoUrl': photoUrl,
      'duration': duration,
      'stages': stages,
    };
  }

  // is json
  factory PlantModel.fromJson(String id, Map<String, dynamic> json) {
    return PlantModel(
      id: id,
      name: json['name'] ?? '',
      points: json['points'] ?? 0,
      photoUrl: json['photoUrl'] ?? '',
      duration: json['duration'] ?? 0,
      stages: List<String>.from(json['stages'] ?? []),
    );
  }

  /// reiks pakoreguot bet cia prototipas
  String getStageImage(int progressPercentage) {
    if (stages.isEmpty) return photoUrl; // If no stages, return final image
    int stageIndex = (progressPercentage / 100 * stages.length).floor();
    return stages[stageIndex.clamp(0, stages.length - 1)];
  }

  static List<PlantModel> defaultPlants = [
    PlantModel(
      id: "dobiliukas",
      name: "Dobiliukas",
      points: 7, // Based on duration
      photoUrl: "https://example.com/dobiliukas.png",
      duration: 7,
      stages: [
        "https://example.com/dobiliukas_stage1.png",
        "https://example.com/dobiliukas_stage2.png",
        "https://example.com/dobiliukas_stage3.png",
        "https://example.com/dobiliukas_stage4.png",
      ],
    ),
    PlantModel(
      id: "ramuneles",
      name: "Ramunėlės",
      points: 14,
      photoUrl: "https://example.com/ramunele.png",
      duration: 14,
      stages: [
        "https://example.com/ramunele_stage1.png",
        "https://example.com/ramunele_stage2.png",
        "https://example.com/ramunele_stage3.png",
        "https://example.com/ramunele_stage4.png",
        "https://example.com/ramunele_stage5.png",
        "https://example.com/ramunele_stage6.png",
      ],
    ),
    PlantModel(
      id: "saulegraza",
      name: "Saulėgrąža",
      points: 45,
      photoUrl: "https://example.com/saulėgraža.png",
      duration: 45,
      stages: [
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
    ),
    PlantModel(
      id: "zibuokle",
      name: "Žibuoklė",
      points: 30,
      photoUrl: "https://example.com/saulėgraža.png",
      duration: 30,
      stages: [
        "https://example.com/saulėgraža_stage1.png",
        "https://example.com/saulėgraža_stage2.png",
        "https://example.com/saulėgraža_stage3.png",
        "https://example.com/saulėgraža_stage4.png",
        "https://example.com/saulėgraža_stage5.png",
        "https://example.com/saulėgraža_stage6.png",
        "https://example.com/saulėgraža_stage7.png",
        "https://example.com/saulėgraža_stage8.png",
      ],
    ),
    PlantModel(
      id: "orchideja",
      name: "Orchidėja",
      points: 60,
      photoUrl: "https://example.com/saulėgraža.png",
      duration: 60,
      stages: [
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
        "https://example.com/saulėgraža_stage13.png",
        "https://example.com/saulėgraža_stage14.png",
        "https://example.com/saulėgraža_stage15.png",
        "https://example.com/saulėgraža_stage16.png",
      ],
    ),
    PlantModel(
      id: "vysnia",
      name: "Vyšnia",
      points: 180, //
      photoUrl: "https://example.com/vyšnia.png",
      duration: 180,
      stages: [
        "https://example.com/vyšnia_stage1.png",
        "https://example.com/vyšnia_stage2.png",
        "https://example.com/vyšnia_stage3.png",
        "https://example.com/vyšnia_stage4.png",
        "https://example.com/vyšnia_stage5.png",
        "https://example.com/vyšnia_stage6.png",
        "https://example.com/vyšnia_stage7.png",
        "https://example.com/vyšnia_stage8.png",
        "https://example.com/vyšnia_stage9.png",
        "https://example.com/vyšnia_stage10.png",
        "https://example.com/vyšnia_stage11.png",
        "https://example.com/vyšnia_stage12.png",
        "https://example.com/vyšnia_stage13.png",
        "https://example.com/vyšnia_stage14.png",
        "https://example.com/vyšnia_stage15.png",
        "https://example.com/vyšnia_stage16.png",
        "https://example.com/vyšnia_stage17.png",
        "https://example.com/vyšnia_stage18.png",
        "https://example.com/vyšnia_stage19.png",
        "https://example.com/vyšnia_stage20.png",
        "https://example.com/vyšnia_stage21.png",
        "https://example.com/vyšnia_stage22.png",
        "https://example.com/vyšnia_stage23.png",
        "https://example.com/vyšnia_stage24.png",
        "https://example.com/vyšnia_stage25.png",
        "https://example.com/vyšnia_stage26.png",
        "https://example.com/vyšnia_stage27.png",
        "https://example.com/vyšnia_stage28.png",
        "https://example.com/vyšnia_stage29.png",
        "https://example.com/vyšnia_stage30.png",
        "https://example.com/vyšnia_stage31.png",
        "https://example.com/vyšnia_stage32.png",
        "https://example.com/vyšnia_stage33.png",
        "https://example.com/vyšnia_stage34.png",
        "https://example.com/vyšnia_stage35.png",
        "https://example.com/vyšnia_stage36.png",
      ],
    ),
  ];
}
