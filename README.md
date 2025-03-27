# 🌱 GIJA - Tikslų ir įpročių sekimo aplikacija

## 📖 Aprašymas
Ši aplikacija padeda vartotojams **stebėti ir pasiekti savo tikslus**, skatindama juos auginti virtualią gėlytę. Kuo daugiau tikslų įvykdoma – tuo gražiau gėlė žydi!  
🚀 **Pagrindinės funkcijos:**
- 🏆 Tikslų kūrimas ir sekimas  
- ⏰ Priminimai apie įpročius  
- 🌸 Gėlytės augimo mechanika  
- 📖 Virtualus dienoraštis  
- 💎 Premium funkcijos su prenumerata  

---

## 📥 **Kaip paleisti projektą?**  
### 1️⃣ **Reikalingos programos**  
Prieš paleidžiant projektą, įsitikink, kad turi:  
- [Flutter](https://flutter.dev/docs/get-started/install)  
- [Android Studio](https://developer.android.com/studio) (su SDK)  
- [VS Code](https://code.visualstudio.com/)

### 2️⃣ **Projekto atsisiuntimas**
Klonuok šį „GitHub“ repozitoriją:  
```sh
git clone https://github.com/tavo-vardas/tavo-repozitorija.git
cd tavo-repozitorija
```

## 📥 **Flutter projekto diegimo INSTRUKCIJOS** 
### 1️⃣ **Įdiekite Flutter**
Atsisiųskite ir įdiekite Flutter: [Flutter](https://flutter.dev/docs/get-started/install)
- Pasirinkite paketą pagal savo operacinę sistemą.
- Pasirinkti, kad kuriamos telefoninės aplikacijos.
- Pasirinkti "Download and install".
- Sekti visas jų pateiktas instrukcijas.
Patikrinkite, ar Flutter įdiegtas teisingai:
```sh
flutter --version
```
Jei įdiegta sėkmingai, turėtų parodyti kokia versija įdiegta.
Pirmą kartą paleidus komandą, jos rezulato gavimas užtrunka ilgiau, nebijoti palaukti.
Rezultatas:
```sh
...> flutter --version
Flutter 3.29.0 • channel stable • https://github.com/flutter/flutter.git
Framework • revision 35c388afb5 (2 weeks ago) • 2025-02-10 12:48:41 -0800
Engine • revision f73bfc4522
Tools • Dart 3.7.0 • DevTools 2.42.2
```

### 2️⃣ **Įdiekite „Android Studio“ ir „Android SDK“**
Kad galėtumėte kurti Android programas, reikia „Android Studio“ ir „Android SDK“:
- Atsisiųskite ir įdiekite Android Studio: [Android Studio](https://developer.android.com/studio)
- Atidarykite Android Studio ir įdiekite Android SDK.
Patikrinkite, ar viskas įdiegta teisingai:
```sh
flutter doctor
```

### 3️⃣ **Įgalinkite emuliatorius**
📱Android emuliatorius
- Atidarykite „Android Studio“ ir eikite į Device Manager.
- Sukurkite naują įrenginį (Create Virtual Device).
- Pasirinkite emuliatorių ir jį paleiskite.
- Taip pat galite paleisti per terminalą:
  ```sh
  emulator -avd <emuliatoriaus_pavadinimas>
  ```

📱iOS emuliatorius (tik macOS)
- Įsitikinkite, kad turite įdiegtą Xcode: [Xcode](https://developer.apple.com/xcode)
- Įdiekite „CocoaPods“, jei jo dar neturite:
  ```sh
  sudo gem install cocoapods
  ```
- Įjunkite iOS emuliatorių terminale:
  ```sh
  open -a Simulator
  ```
- Patikrinkite, ar viskas teisingai įdiegta:
  ```sh
  flutter doctor
  ```

### 4️⃣ **Įdiekite VS Code ir plėtinius**
- Atsisiųskite VS Code: [VS Code](https://code.visualstudio.com/)
- Įdiekite „Flutter“ ir „Dart“ plėtinius per VS Code Extensions skiltį.

### 5️⃣ **Atsisiųskite projektą iš GitHub**
Norėdami atsisiųsti projektą, vykdykite šias komandas:
```sh
git clone <projekto_github_nuoroda>
cd <projekto_katalogas>
```
Taip pat galima atsisiųsti naudojantis Github Desktop programėle.
‼️LABAI SVARBU‼️
Projekto pakeitimus atlikti ant savo šakos ("branch").
Prieš koreguojant projektą atnaujinti, kad gauti naujausią projekto versiją su pakeitimais.
Atlikus darbą sukurti suliejimo prašymą, kurį turi patvirtinti kitas žmogus.

### 6️⃣ **Atsisiųskite projektą iš GitHub**
Atsisiųskite priklausomybes:
```sh
flutter pub get
```
Paleiskite aplikaciją emuliatoriuje arba prijungtame įrenginyje:
```sh
flutter run
```
Jei turite kelis įrenginius, peržiūrėkite jų sąrašą ir pasirinkite konkretų įrenginį:
```sh
flutter devices
flutter run -d <device_id>
```
