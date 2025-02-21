Voici un **README.md** exhaustif pour ton projet **Piction.AI.ry**. Je l'ai structuré de manière claire pour inclure toutes les informations importantes sur ton projet, son installation, son utilisation, son architecture et ses dépendances.

---

# Piction.AI.ry 🎨🤖

Piction.AI.ry est une application Flutter qui modernise le célèbre jeu Pictionary en intégrant une intelligence artificielle pour générer des dessins basés sur des défis textuels. Ce projet est conçu pour être interactif et intuitif, permettant aux joueurs de proposer, dessiner et deviner des défis tout en profitant d'une expérience fluide sur mobile.

# Info de conception

 - Tout les screen on été fait seul pas de travail de groupe
 - pour les raison de test des joueurs sont ajouter automatiquement
 - rejoindre une aprtie apr qr code fonctionne (source tkt wesh)
 - les bulles éclate plus désolé
 - mais y un easter eag quand on en clique suffisament
 - Vivement que flutter coule
---

## 📌 Table des matières

- [Piction.AI.ry 🎨🤖](#pictionairy-)
- [Info de conception](#info-de-conception)
 	- [📌 Table des matières](#-table-des-matières)
 	- [📦 Installation](#-installation)
 	- [Documentation complète des fonctionalité](#documentation-complète-des-fonctionalité)
  		- [1. Prérequis](#1-prérequis)
  		- [2. Cloner le projet](#2-cloner-le-projet)
  		- [3. Installer les dépendances](#3-installer-les-dépendances)
 	- [🚀 Démarrage](#-démarrage)
  		- [1. Lancer l'application en mode développement](#1-lancer-lapplication-en-mode-développement)
  		- [2. Générer un build pour Android / iOS](#2-générer-un-build-pour-android--ios)
 	- [📜 Fonctionnalités](#-fonctionnalités)
 	- [🛠 Architecture](#-architecture)
  		- [📌 **Dossiers principaux :**](#-dossiers-principaux-)
 	- [📂 Structure du projet](#-structure-du-projet)
 	- [📡 API et Back-end](#-api-et-back-end)
  		- [📌 **Authentification**](#-authentification)
  		- [📌 **Gestion des sessions de jeu**](#-gestion-des-sessions-de-jeu)
  		- [📌 **Défis et Dessins**](#-défis-et-dessins)
 	- [📚 Dépendances](#-dépendances)
 	- [🚀 Déploiement](#-déploiement)
  		- [📌 Android](#-android)
  		- [📌 iOS](#-ios)
  		- [📌 Web](#-web)
 	- [🤝 Contribuer](#-contribuer)
 	- [📝 Licence](#-licence)

---

## 📦 Installation

## Documentation complète des fonctionalité

[https://gwilymm.github.io/pictionairy/](https://gwilymm.github.io/pictionairy/)

### 1. Prérequis

Assurez-vous d'avoir installé :

- [Flutter](https://flutter.dev/docs/get-started/install) (Version ≥ 3.27.0)
- [Dart](https://dart.dev/get-dart)
- Un émulateur ou un appareil physique (Android / iOS)
- (Optionnel) [Android Studio](https://developer.android.com/studio) ou [VS Code](https://code.visualstudio.com/)

### 2. Cloner le projet

```sh
git clone https://github.com/ton-repo/pictionairy.git
cd pictionairy
```

### 3. Installer les dépendances

```sh
flutter pub get
```

---

## 🚀 Démarrage

### 1. Lancer l'application en mode développement

```sh
flutter run
```

### 2. Générer un build pour Android / iOS

```sh
flutter build apk   # Android
flutter build ios   # iOS (nécessite Xcode)
```

---

## 📜 Fonctionnalités

✅ **Authentification** : Inscription et connexion sécurisées\
✅ **Création de sessions de jeu** : Un joueur peut créer une session et inviter des participants\
✅ **Rejoindre une partie** : Scanner un QR code pour rejoindre une session\
✅ **Soumission de défis** : Proposer des phrases à dessiner\
✅ **Génération d'images** : L'IA génère des images basées sur les défis\
✅ **Système d'équipe** : Répartition automatique des joueurs en équipes\
✅ **Interface fluide** : Animations et interactions modernes\
✅ **Stockage des défis** : Sauvegarde locale et synchronisation avec le serveur\
✅ **Publicité intégrée** : Monétisation avec Google AdMob

---

## 🛠 Architecture

L'application suit les principes **SOLID** et une architecture **MVVM** :

### 📌 **Dossiers principaux :**

- **📂 lib/controllers/** → Contient les `Controllers` pour gérer la logique métier
- **📂 lib/screens/** → Définit les écrans principaux (`HomeScreen`, `LoginScreen`, etc.)
- **📂 lib/services/** → Gère l'interaction avec l'API (`ApiService`)
- **📂 lib/utils/** → Définit les couleurs, thèmes et configurations globales
- **📂 lib/widgets/** → Contient des composants UI réutilisables (`ChallengeCard`, etc.)
- **📂 assets/** → Stocke les images et icônes utilisées dans l'application

---

## 📂 Structure du projet

```
pictionairy/
│── lib/
│   ├── controllers/
│   │   ├── challenge_form_controller.dart
│   │   ├── home_controller.dart
│   │   ├── join_game_controller.dart
│   │   ├── login_controller.dart
│   │   ├── start_game_controller.dart
│   ├── screens/
│   │   ├── challenge_create_screen.dart
│   │   ├── challenge_form_screen.dart
│   │   ├── home_screen.dart
│   │   ├── join_game_screen.dart
│   │   ├── login_screen.dart
│   │   ├── signup_screen.dart
│   │   ├── splash_screen.dart
│   │   ├── start_game_screen.dart
│   ├── services/
│   │   ├── api_service.dart
│   │   ├── user_service.dart
│   ├── utils/
│   │   ├── animated_bubble.dart
│   │   ├── colors.dart
│   │   ├── shared_preferences_util.dart
│   │   ├── theme.dart
│   ├── widgets/
│   │   ├── challenge_card.dart
│   ├── main.dart
│── pubspec.yaml
│── README.md
│── android/
│── ios/
│── web/
│── linux/
│── macos/
│── windows/
│── test/
│── assets/
```

---

## 📡 API et Back-end

L'application communique avec une **API REST** qui gère les sessions de jeu, les défis et les utilisateurs. Voici quelques routes principales utilisées :

### 📌 **Authentification**

- `POST /players` → Créer un joueur `{ name, password }`
- `POST /login` → Connexion `{ name, password }` → Retourne un `JWT`
- `GET /me` → Récupérer les infos de l'utilisateur connecté

### 📌 **Gestion des sessions de jeu**

- `POST /game_sessions` → Créer une session de jeu
- `POST /game_sessions/{id}/join` → Rejoindre une session avec `{ color: "red" | "blue" }`
- `GET /game_sessions/{id}/status` → Récupérer l'état du jeu

### 📌 **Défis et Dessins**

- `POST /game_sessions/{id}/challenges` → Envoyer un défi
- `GET /game_sessions/{id}/myChallenges` → Voir ses défis assignés
- `POST /game_sessions/{id}/challenges/{challengeId}/draw` → Envoyer un dessin
- `GET /game_sessions/{id}/myChallengesToGuess` → Voir les défis à deviner

L'intégration de l'**IA** se fait via `ApiService.generateImage()`, qui génère des dessins à partir du texte fourni.

---

## 📚 Dépendances

Voici les principales dépendances utilisées dans l'application :

| Package | Description |
|---------|------------|
| `provider` | Gestion d'état |
| `shared_preferences` | Stockage local des défis |
| `flutter_svg` | Gestion des SVG |
| `google_mobile_ads` | Publicités intégrées |
| `qr_flutter` | Génération de QR codes |
| `qr_code_dart_scan` | Scanner de QR codes |
| `fluttertoast` | Affichage de notifications |
| `http` | Gestion des requêtes API |
| `glass_kit` | Effet de verre pour UI moderne |

Pour voir toutes les dépendances :

```sh
flutter pub outdated
```

---

## 🚀 Déploiement

### 📌 Android

```sh
flutter build apk
flutter install
```

### 📌 iOS

```sh
flutter build ios
open ios/Runner.xcworkspace
```

### 📌 Web

```sh
flutter build web
```

---

## 🤝 Contribuer

1. **Fork** le projet 🍴
2. **Clone** le repo 🚀
3. Crée une nouvelle branche `feature/amélioration` 📌
4. Commit tes modifications 📝
5. Push la branche et ouvre une `Pull Request` 🚀

---

## 📝 Licence

📜 Ce projet est sous licence **MIT** – voir le fichier **LICENSE** pour plus de détails.

---

✨ **Bon jeu avec Piction.AI.ry !** 🎨🚀
