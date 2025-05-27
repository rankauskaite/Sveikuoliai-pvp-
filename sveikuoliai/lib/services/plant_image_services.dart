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
    int maxPoints = 90; // Maksimalus taškų skaičius
    int stage =
        ((points / maxPoints) * 24).floor(); // Proporcingas etapas iki 24
    if (stage < 1) stage = 1; // Minimalus etapas 1
    if (stage > 24) stage = 24; // Maksimalus etapas 24
    return 'assets/images/augalai/gervuoge/$stage.png';
  }

  static String getPlantImageorchideja(int points) {
    int maxPoints = 60; // Maksimalus taškų skaičius
    int stage =
        ((points / maxPoints) * 16).floor(); // Proporcingas etapas iki 16
    if (stage < 1) stage = 1; // Minimalus etapas 1
    if (stage > 16) stage = 16; // Maksimalus etapas 16
    return 'assets/images/augalai/orchideja/$stage.png';
  }

  static String getPlantImageramuneles(int points) {
    int maxPoints = 14; // Maksimalus taškų skaičius
    int stage = ((points / maxPoints) * 6).floor(); // Proporcingas etapas iki 6
    if (stage < 1) stage = 1; // Minimalus etapas 1
    if (stage > 6) stage = 6; // Maksimalus etapas 6
    return 'assets/images/augalai/ramuneles/$stage.png';
  }

  static String getPlantImagesaulegraza(int points) {
    int maxPoints = 45; // Maksimalus taškų skaičius
    int stage =
        ((points / maxPoints) * 12).floor(); // Proporcingas etapas iki 12
    if (stage < 1) stage = 1; // Minimalus etapas 1
    if (stage > 12) stage = 12; // Maksimalus etapas 12
    return 'assets/images/augalai/saulegraza/$stage.png';
  }

  static String getPlantImagevysnia(int points) {
    int maxPoints = 180; // Maksimalus taškų skaičius
    int stage =
        ((points / maxPoints) * 36).floor(); // Proporcingas etapas iki 36
    if (stage < 1) stage = 1; // Minimalus etapas 1
    if (stage > 36) stage = 36; // Maksimalus etapas 36
    return 'assets/images/augalai/vysnia/$stage.png';
  }

  static String getPlantImagezibuokle(int points) {
    int maxPoints = 30; // Maksimalus taškų skaičius
    int stage = ((points / maxPoints) * 8).floor(); // Proporcingas etapas iki 8
    if (stage < 1) stage = 1; // Minimalus etapas 1
    if (stage > 8) stage = 8; // Maksimalus etapas 8
    return 'assets/images/augalai/zibuokle/$stage.png';
  }
}

class DeadPlantImageService {
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
      return 'assets/images/augalai_vytimas/dobiliukas/1.png'; // Mažas daigelis
    } else if (points <= 4) {
      return 'assets/images/augalai_vytimas/dobiliukas/2.png'; // Augantis augaliukas
    } else if (points <= 6) {
      return 'assets/images/augalai_vytimas/dobiliukas/3.png'; // Bręstantis augalas
    } else {
      return 'assets/images/augalai_vytimas/dobiliukas/4.png'; // Pilnai užaugęs augalas
    }
  }

  static String getPlantImagegervuoge(int points) {
    int maxPoints = 90; // Maksimalus taškų skaičius
    int stage =
        ((points / maxPoints) * 24).floor(); // Proporcingas etapas iki 24
    if (stage < 1) stage = 1; // Minimalus etapas 1
    if (stage > 24) stage = 24; // Maksimalus etapas 24
    return 'assets/images/augalai_vytimas/gervuoge/$stage.png';
  }

  static String getPlantImageorchideja(int points) {
    int maxPoints = 60; // Maksimalus taškų skaičius
    int stage =
        ((points / maxPoints) * 16).floor(); // Proporcingas etapas iki 16
    if (stage < 1) stage = 1; // Minimalus etapas 1
    if (stage > 16) stage = 16; // Maksimalus etapas 16
    return 'assets/images/augalai_vytimas/orchideja/$stage.png';
  }

  static String getPlantImageramuneles(int points) {
    int maxPoints = 14; // Maksimalus taškų skaičius
    int stage = ((points / maxPoints) * 6).floor(); // Proporcingas etapas iki 6
    if (stage < 1) stage = 1; // Minimalus etapas 1
    if (stage > 6) stage = 6; // Maksimalus etapas 6
    return 'assets/images/augalai_vytimas/ramuneles/$stage.png';
  }

  static String getPlantImagesaulegraza(int points) {
    int maxPoints = 45; // Maksimalus taškų skaičius
    int stage =
        ((points / maxPoints) * 12).floor(); // Proporcingas etapas iki 12
    if (stage < 1) stage = 1; // Minimalus etapas 1
    if (stage > 12) stage = 12; // Maksimalus etapas 12
    return 'assets/images/augalai_vytimas/saulegraza/$stage.png';
  }

  static String getPlantImagevysnia(int points) {
    int maxPoints = 180; // Maksimalus taškų skaičius
    int stage =
        ((points / maxPoints) * 36).floor(); // Proporcingas etapas iki 36
    if (stage < 1) stage = 1; // Minimalus etapas 1
    if (stage > 36) stage = 36; // Maksimalus etapas 36
    return 'assets/images/augalai_vytimas/vysnia/$stage.png';
  }

  static String getPlantImagezibuokle(int points) {
    int maxPoints = 30; // Maksimalus taškų skaičius
    int stage = ((points / maxPoints) * 8).floor(); // Proporcingas etapas iki 8
    if (stage < 1) stage = 1; // Minimalus etapas 1
    if (stage > 8) stage = 8; // Maksimalus etapas 8
    return 'assets/images/augalai_vytimas/zibuokle/$stage.png';
  }
}
