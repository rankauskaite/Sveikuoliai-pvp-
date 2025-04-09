class PlantImageService {
  static String getPlantImage(String plantType, int points) {
    switch (plantType) {
      case 'dobiliukas':
        return getPlantImagedobiliukas(points);
      case 'gervuoge':
        return getPlantImagegervuoge(points);
      case 'orchideja':
        return getPlantImageorchideja(points);
      case 'ramuneles':
        return getPlantImageramuneles(points);
      case 'saulegraza':
        return getPlantImagesaulegraza(points);
      case 'vysnia':
        return getPlantImagevysnia(points);
      case 'zibuokle':
        return getPlantImagezibuokle(points);
      default:
        return 'Error: Unknown plant type';
    }
  }

  static String getPlantImagedobiliukas(int points) {
    if (points <= 2) {
      return 'assets/images/augalai/dobiliukas/1.png'; // Mažas daigelis
    } else if (points <= 4) {
      return 'assets/images/augalai/dobiliukas/2.png'; // Augantis augaliukas
    } else if (points <= 6) {
      return 'assets/images/augalai/dobiliukas/3.png'; // Bręstantis augalas
    } else {
      return 'assets/images/augalai/dobiliukas/4.png'; // Pilnai užaugęs augalas
    }
  }

  static String getPlantImagegervuoge(int points) {
    int stage = (points / 3.913).floor() + 1;
    if (stage > 24) stage = 24;
    return 'assets/images/augalai/gervuoge/$stage.png';
  }

  static String getPlantImageorchideja(int points) {
    int stage = (points / 4).floor() + 1;
    if (stage > 16) stage = 16;
    return 'assets/images/augalai/orchideja/$stage.png';
  }

  static String getPlantImageramuneles(int points) {
    int stage = (points / 3).floor() + 1;
    if (stage > 6) stage = 6;
    return 'assets/images/augalai/ramuneles/$stage.png';
  }

  static String getPlantImagesaulegraza(int points) {
    int stage = (points / 4).floor() + 1;
    if (stage > 12) stage = 12;
    return 'assets/images/augalai/saulegraza/$stage.png';
  }

  static String getPlantImagevysnia(int points) {
    int stage = (points / 5).floor() + 1;
    if (stage > 36) stage = 36;
    return 'assets/images/augalai/vysnia/$stage.png';
  }

  static String getPlantImagezibuokle(int points) {
    int stage = (points / 4).floor() + 1;
    if (stage > 8) stage = 8;
    return 'assets/images/augalai/zibuokle/$stage.png';
  }
}
