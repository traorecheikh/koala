# 🔔 Notification & Achievement System - Flutter Integration Guide

## Vue d'ensemble

Ce guide complet détaille l'intégration du système de notifications push automatiques et du système de points/succès pour l'application Flutter Assistant Financier.

## 🎯 Fonctionnalités Implémentées

### 1. Système de Notifications Automatiques

#### Notifications de Bienvenue et Onboarding
- **Bienvenue utilisateur** : Notification envoyée lors de la création d'un nouveau compte
- **Étape salaire** : Rappel automatique pour ajouter le salaire (30 secondes après création)
- **Première transaction** : Encouragement à enregistrer la première transaction (2 minutes après création)

#### Notifications d'Actions
- **Compte créé** : Confirmation lors de l'ajout d'un nouveau compte
- **Salaire enregistré** : Félicitations avec émojis lors de l'ajout du salaire
- **Nouvelle transaction** : Notifications pour les transactions importantes (> 1000 XOF)
- **Dépense importante** : Alerte pour les dépenses > 5000 XOF
- **Succès débloqué** : Notification automatique lors du déblocage d'un succès

#### Notifications de Rappel et Engagement
- **Résumé hebdomadaire** : Statistiques de la semaine
- **Astuce budget du jour** : Conseils financiers quotidiens
- **Analyse des habitudes** : Détection de patterns de dépenses
- **Rappel de retour** : Pour les utilisateurs inactifs

### 2. Système de Succès et Points

#### Succès Disponibles
| Succès | Points | Description | Trigger |
|--------|--------|-------------|---------|
| **Bienvenue** | 25 pts | Premier compte utilisateur | Création utilisateur |
| **Premier appareil** | 10 pts | Enregistrement FCM | Device registration |
| **Salaire enregistré** | 50 pts | Premier salaire ajouté | Ajout salaire |
| **Premier compte** | 20 pts | Premier compte créé | Création compte |
| **Première transaction** | 15 pts | Première transaction | Première transaction |
| **Suivi des dépenses** | 30 pts | 10 transactions | 10e transaction |
| **Maître des transactions** | 75 pts | 50 transactions | 50e transaction |
| **Conscient du budget** | 40 pts | 20 tx catégorisées | 20e catégorisation |
| **Suivi des prêts** | 35 pts | Premier remboursement | Premier remboursement |
| **100 points atteints** | 25 pts | Palier 100 points | Auto à 100 pts |
| **500 points atteints** | 50 pts | Palier 500 points | Auto à 500 pts |
| **Première suggestion** | 5 pts | Premier conseil IA | Premier insight |
| **Collectionneur de conseils** | 25 pts | 10 suggestions reçues | 10e insight |

## 🚀 API Endpoints

### Notifications

#### 1. Enregistrer un Device FCM
```http
POST /api/notifications/register
Authorization: Bearer {jwt_token}
Content-Type: application/json

{
  "fcmToken": "string",
  "platform": "android|ios|web",
  "metadata": {
    "deviceModel": "string",
    "osVersion": "string"
  }
}
```

**Réponse :**
```json
{
  "ok": true,
  "data": {
    "device": {
      "id": "uuid",
      "fcmToken": "string"
    }
  }
}
```

#### 2. Lister les Devices
```http
GET /api/notifications
Authorization: Bearer {jwt_token}
```

#### 3. Envoyer une Notification Template
```http
POST /api/notifications/send/template
Authorization: Bearer {jwt_token}
Content-Type: application/json

{
  "userId": "uuid",
  "templateName": "achievement_unlocked",
  "params": {
    "userName": "string",
    "achievementTitle": "string",
    "points": 25
  }
}
```

### Points et Succès

#### 1. Récupérer Points Utilisateur
```http
GET /api/points
Authorization: Bearer {jwt_token}
```

**Réponse :**
```json
{
  "ok": true,
  "data": {
    "totalPoints": 125,
    "transactions": [
      {
        "id": "uuid",
        "change": 25,
        "reason": "achievement:welcome_user",
        "created_at": "2024-01-15T10:00:00Z"
      }
    ]
  }
}
```

#### 2. Lister Tous les Succès
```http
GET /api/achievements
Authorization: Bearer {jwt_token}
```

**Réponse :**
```json
{
  "ok": true,
  "data": {
    "available": [
      {
        "id": "uuid",
        "key": "welcome_user",
        "title": "Bienvenue",
        "description": "Bienvenue dans votre Assistant Financier!",
        "points": 25
      }
    ],
    "unlocked": [
      {
        "id": "uuid",
        "userId": "uuid",
        "achievementId": "uuid",
        "awardedAt": "2024-01-15T10:00:00Z",
        "achievement": {
          "key": "welcome_user",
          "title": "Bienvenue",
          "points": 25
        }
      }
    ]
  }
}
```

## 📱 Integration Flutter

### 1. Setup FCM

#### pubspec.yaml
```yaml
dependencies:
  firebase_messaging: ^14.7.10
  firebase_core: ^2.24.2
  flutter_local_notifications: ^16.3.2
```

#### Configuration Firebase
```dart
// main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Handler pour notifications en arrière-plan
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  runApp(MyApp());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Message reçu en arrière-plan: ${message.messageId}");
}
```

### 2. Service de Notifications

```dart
// services/notification_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

class NotificationService extends GetxService {
  late FirebaseMessaging _messaging;
  late FlutterLocalNotificationsPlugin _localNotifications;
  
  // État observable
  var isRegistered = false.obs;
  var fcmToken = ''.obs;
  
  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeFirebase();
    await _initializeLocalNotifications();
    await _registerDevice();
  }
  
  Future<void> _initializeFirebase() async {
    _messaging = FirebaseMessaging.instance;
    
    // Demander permissions
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Permissions accordées');
    }
    
    // Écouter messages en premier plan
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // Écouter clics sur notifications
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationClick);
  }
  
  Future<void> _initializeLocalNotifications() async {
    _localNotifications = FlutterLocalNotificationsPlugin();
    
    const AndroidInitializationSettings androidSettings = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings iosSettings = 
        DarwinInitializationSettings();
    
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _localNotifications.initialize(settings);
  }
  
  Future<void> _registerDevice() async {
    try {
      String? token = await _messaging.getToken();
      if (token != null) {
        fcmToken.value = token;
        
        // Appel API pour enregistrer
        final response = await ApiService.post('/api/notifications/register', {
          'fcmToken': token,
          'platform': GetPlatform.isAndroid ? 'android' : 'ios',
          'metadata': {
            'deviceModel': GetPlatform.deviceInfo,
            'appVersion': '1.0.0',
          }
        });
        
        if (response['ok']) {
          isRegistered.value = true;
          print('Device enregistré avec succès');
        }
      }
    } catch (e) {
      print('Erreur enregistrement device: $e');
    }
  }
  
  void _handleForegroundMessage(RemoteMessage message) {
    print('Message reçu en premier plan: ${message.notification?.title}');
    
    // Afficher notification locale
    _showLocalNotification(message);
    
    // Traiter selon le type
    _handleNotificationData(message.data);
  }
  
  void _handleNotificationClick(RemoteMessage message) {
    print('Notification cliquée: ${message.data}');
    _handleNotificationData(message.data);
  }
  
  void _handleNotificationData(Map<String, dynamic> data) {
    final type = data['type'];
    
    switch (type) {
      case 'achievement_unlocked':
        Get.toNamed('/achievements');
        break;
      case 'new_transaction':
        Get.toNamed('/transactions');
        break;
      case 'salary_received':
        Get.toNamed('/profile');
        break;
      case 'low_balance':
        Get.toNamed('/dashboard');
        break;
      case 'insight_ready':
        Get.toNamed('/insights');
        break;
      default:
        Get.toNamed('/dashboard');
    }
  }
  
  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'main_channel',
      'Notifications principales',
      description: 'Notifications de l\'Assistant Financier',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
    
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      message.notification?.title ?? 'Assistant Financier',
      message.notification?.body ?? '',
      details,
    );
  }
}
```

### 3. Service de Points et Succès

```dart
// services/achievement_service.dart
class AchievementService extends GetxService {
  var totalPoints = 0.obs;
  var availableAchievements = <Achievement>[].obs;
  var unlockedAchievements = <UserAchievement>[].obs;
  var pointTransactions = <PointTransaction>[].obs;
  
  @override
  Future<void> onInit() async {
    super.onInit();
    await loadAchievements();
    await loadPoints();
  }
  
  Future<void> loadAchievements() async {
    try {
      final response = await ApiService.get('/api/achievements');
      
      if (response['ok']) {
        final data = response['data'];
        
        availableAchievements.value = (data['available'] as List)
            .map((json) => Achievement.fromJson(json))
            .toList();
            
        unlockedAchievements.value = (data['unlocked'] as List)
            .map((json) => UserAchievement.fromJson(json))
            .toList();
      }
    } catch (e) {
      print('Erreur chargement succès: $e');
    }
  }
  
  Future<void> loadPoints() async {
    try {
      final response = await ApiService.get('/api/points');
      
      if (response['ok']) {
        final data = response['data'];
        totalPoints.value = data['totalPoints'] ?? 0;
        
        pointTransactions.value = (data['transactions'] as List)
            .map((json) => PointTransaction.fromJson(json))
            .toList();
      }
    } catch (e) {
      print('Erreur chargement points: $e');
    }
  }
  
  // Calculer niveau basé sur les points
  int get currentLevel => (totalPoints.value / 100).floor() + 1;
  
  // Points nécessaires pour niveau suivant
  int get pointsToNextLevel => (currentLevel * 100) - totalPoints.value;
  
  // Progression vers niveau suivant (0.0 à 1.0)
  double get levelProgress => 
      (totalPoints.value % 100) / 100.0;
  
  // Vérifier si succès est débloqué
  bool isAchievementUnlocked(String key) {
    return unlockedAchievements.any((ua) => ua.achievement.key == key);
  }
  
  // Afficher animation succès débloqué
  void showAchievementDialog(Achievement achievement) {
    Get.dialog(
      AchievementUnlockedDialog(achievement: achievement),
      barrierDismissible: false,
    );
  }
}
```

### 4. Models

```dart
// models/achievement.dart
class Achievement {
  final String id;
  final String key;
  final String title;
  final String description;
  final int points;
  final DateTime createdAt;
  
  Achievement({
    required this.id,
    required this.key,
    required this.title,
    required this.description,
    required this.points,
    required this.createdAt,
  });
  
  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
    id: json['id'],
    key: json['key'],
    title: json['title'],
    description: json['description'],
    points: json['points'] ?? 0,
    createdAt: DateTime.parse(json['created_at']),
  );
}

// models/user_achievement.dart
class UserAchievement {
  final String id;
  final String userId;
  final String achievementId;
  final DateTime awardedAt;
  final Achievement achievement;
  
  UserAchievement({
    required this.id,
    required this.userId,
    required this.achievementId,
    required this.awardedAt,
    required this.achievement,
  });
  
  factory UserAchievement.fromJson(Map<String, dynamic> json) => UserAchievement(
    id: json['id'],
    userId: json['userId'],
    achievementId: json['achievementId'],
    awardedAt: DateTime.parse(json['awardedAt']),
    achievement: Achievement.fromJson(json['achievement']),
  );
}

// models/point_transaction.dart
class PointTransaction {
  final String id;
  final String userId;
  final int change;
  final String reason;
  final DateTime createdAt;
  
  PointTransaction({
    required this.id,
    required this.userId,
    required this.change,
    required this.reason,
    required this.createdAt,
  });
  
  factory PointTransaction.fromJson(Map<String, dynamic> json) => PointTransaction(
    id: json['id'],
    userId: json['userId'],
    change: json['change'],
    reason: json['reason'] ?? '',
    createdAt: DateTime.parse(json['created_at']),
  );
}
```

### 5. Widgets UI

```dart
// widgets/achievement_card.dart
class AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final bool isUnlocked;
  
  const AchievementCard({
    Key? key,
    required this.achievement,
    required this.isUnlocked,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isUnlocked ? 4 : 1,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isUnlocked 
              ? Colors.green 
              : Colors.grey.shade300,
          child: Icon(
            isUnlocked ? Icons.check : Icons.lock,
            color: isUnlocked ? Colors.white : Colors.grey,
          ),
        ),
        title: Text(
          achievement.title,
          style: TextStyle(
            fontWeight: isUnlocked ? FontWeight.bold : FontWeight.normal,
            color: isUnlocked ? Colors.black : Colors.grey,
          ),
        ),
        subtitle: Text(
          achievement.description,
          style: TextStyle(
            color: isUnlocked ? Colors.black87 : Colors.grey,
          ),
        ),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isUnlocked ? Colors.green : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${achievement.points} pts',
            style: TextStyle(
              color: isUnlocked ? Colors.white : Colors.grey.shade700,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

// widgets/points_display.dart
class PointsDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetX<AchievementService>(
      builder: (service) => Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade400, Colors.purple.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Niveau ${service.currentLevel}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${service.totalPoints} points',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: Text(
                    '${service.currentLevel}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Niveau suivant',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    Text(
                      '${service.pointsToNextLevel} pts restants',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                LinearProgressIndicator(
                  value: service.levelProgress,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// dialogs/achievement_unlocked_dialog.dart
class AchievementUnlockedDialog extends StatelessWidget {
  final Achievement achievement;
  
  const AchievementUnlockedDialog({
    Key? key,
    required this.achievement,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animation de confettis ou icône animée
            Icon(
              Icons.emoji_events,
              size: 64,
              color: Colors.amber,
            ),
            SizedBox(height: 16),
            Text(
              'Succès débloqué !',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 8),
            Text(
              achievement.title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              achievement.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '+${achievement.points} points',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Génial !'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 6. Pages UI

```dart
// pages/achievements_page.dart
class AchievementsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Succès'),
        backgroundColor: Colors.green,
      ),
      body: GetX<AchievementService>(
        builder: (service) => Column(
          children: [
            // Points display en haut
            Padding(
              padding: EdgeInsets.all(16),
              child: PointsDisplay(),
            ),
            
            // Tabs pour séparer débloqués/tous
            DefaultTabController(
              length: 2,
              child: Expanded(
                child: Column(
                  children: [
                    TabBar(
                      labelColor: Colors.green,
                      tabs: [
                        Tab(text: 'Débloqués (${service.unlockedAchievements.length})'),
                        Tab(text: 'Tous (${service.availableAchievements.length})'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          // Succès débloqués
                          ListView.builder(
                            padding: EdgeInsets.all(16),
                            itemCount: service.unlockedAchievements.length,
                            itemBuilder: (context, index) {
                              final userAchievement = service.unlockedAchievements[index];
                              return AchievementCard(
                                achievement: userAchievement.achievement,
                                isUnlocked: true,
                              );
                            },
                          ),
                          
                          // Tous les succès
                          ListView.builder(
                            padding: EdgeInsets.all(16),
                            itemCount: service.availableAchievements.length,
                            itemBuilder: (context, index) {
                              final achievement = service.availableAchievements[index];
                              final isUnlocked = service.isAchievementUnlocked(achievement.key);
                              
                              return AchievementCard(
                                achievement: achievement,
                                isUnlocked: isUnlocked,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 🔧 Configuration

### 1. Initialisation dans main.dart

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Enregistrer services
  Get.put(NotificationService());
  Get.put(AchievementService());
  
  runApp(MyApp());
}
```

### 2. Routes GetX

```dart
// routes/app_routes.dart
class AppRoutes {
  static const dashboard = '/dashboard';
  static const achievements = '/achievements';
  static const transactions = '/transactions';
  static const profile = '/profile';
  static const insights = '/insights';
}

// routes/app_pages.dart
class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.achievements,
      page: () => AchievementsPage(),
    ),
    // ... autres routes
  ];
}
```

## 🎨 Personnalisation UI

### Thème Notifications
```dart
// Couleurs cohérentes
class NotificationColors {
  static const success = Colors.green;
  static const warning = Colors.orange;
  static const error = Colors.red;
  static const info = Colors.blue;
  static const achievement = Colors.amber;
}

// Sons personnalisés
class NotificationSounds {
  static const achievement = 'achievement_unlock.mp3';
  static const points = 'points_earned.mp3';
  static const reminder = 'gentle_reminder.mp3';
}
```

## 🔍 Tests et Debug

### Test Notifications
```dart
// Bouton de test dans development
ElevatedButton(
  onPressed: () async {
    await ApiService.post('/api/notifications/send/template', {
      'userId': currentUserId,
      'templateName': 'achievement_unlocked',
      'params': {
        'userName': 'Test User',
        'achievementTitle': 'Test Achievement',
        'points': 25,
      }
    });
  },
  child: Text('Test Notification'),
)
```

### Debug FCM
```dart
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  print('DEBUG - Message reçu:');
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Data: ${message.data}');
});
```

## 📊 Analytics et Métriques

### Tracking Events
```dart
// Track ouverture notifications
void trackNotificationOpened(String type) {
  analytics.logEvent(name: 'notification_opened', parameters: {
    'notification_type': type,
    'timestamp': DateTime.now().toIso8601String(),
  });
}

// Track succès débloqués
void trackAchievementUnlocked(String achievementKey, int points) {
  analytics.logEvent(name: 'achievement_unlocked', parameters: {
    'achievement_key': achievementKey,
    'points_earned': points,
  });
}
```

## 🚨 Bonnes Pratiques

### 1. Gestion Permissions
- Demander permissions au bon moment (pas au démarrage)
- Expliquer pourquoi les notifications sont utiles
- Fallback gracieux si permissions refusées

### 2. Performance
- Cache local des succès et points
- Lazy loading des historiques
- Optimisation images et animations

### 3. UX
- Notifications contextuelle et utiles
- Pas de spam (limite fréquence)
- Permettre désactivation par type

### 4. Sécurité
- Validation côté client ET serveur
- Pas d'informations sensibles dans payload
- Chiffrement des tokens

## 🎯 Roadmap Future

### Phase 2
- [ ] Notifications programmées (rappels récurrents)
- [ ] Notifications basées sur localisation
- [ ] Succès sociaux (partage, défis)
- [ ] Niveaux VIP avec avantages

### Phase 3
- [ ] Notifications intelligentes (ML)
- [ ] Succès dynamiques selon comportement
- [ ] Système de badges et collections
- [ ] Récompenses tangibles (cashback, réductions)

---

Ce guide fournit tout le nécessaire pour intégrer parfaitement le système de notifications et succès dans l'application Flutter. Chaque composant est modulaire et peut être adapté selon les besoins spécifiques du projet.