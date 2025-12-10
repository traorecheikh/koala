# Analytics Page - Revenus & Épargne

## Changements Effectués

### Nouveaux Modèles
1. **Job** (`lib/app/data/models/job.dart`)
   - Nom du job
   - Montant payé
   - Fréquence (hebdomadaire, bi-hebdomadaire, mensuel)
   - Date de paiement
   - Calcul automatique du revenu mensuel

2. **SavingsGoal** (`lib/app/data/models/savings_goal.dart`)
   - Objectif d'épargne mensuel
   - Suivi du progrès en pourcentage

### Controller Restructuré
Le `AnalyticsController` a été complètement refait :
- ❌ Supprimé : ML predictions, moyenne quotidienne, prédictions
- ✅ Ajouté : Gestion des emplois multiples
- ✅ Ajouté : Navigation mensuelle (précédent/suivant/actuel)
- ✅ Ajouté : Calcul automatique des revenus mensuels
- ✅ Ajouté : Suivi des objectifs d'épargne

### Vue Simplifiée
La page Analytics a été complètement redessinée :
- **Navigation mensuelle** : Naviguez entre les mois pour voir l'historique
- **Résumé mensuel** :
  - Solde net (revenus - dépenses)
  - Total des revenus (emplois + transactions)
  - Total des dépenses
- **Objectif d'épargne** :
  - Définir un montant cible mensuel
  - Voir le pourcentage atteint
  - Progression visuelle
- **Gestion des emplois** :
  - Ajouter plusieurs emplois
  - Voir le revenu mensuel calculé automatiquement
  - Supprimer des emplois
- **Dépenses par catégorie** :
  - Top 5 des catégories de dépenses
  - Barres de progression simples (pas de graphiques lourds)

## Fonctionnalités

### Ajouter un Emploi
1. Cliquez sur le bouton `+` en haut à droite
2. Entrez le nom du job
3. Entrez le montant payé
4. Sélectionnez la fréquence
5. Le revenu mensuel est calculé automatiquement

### Définir un Objectif d'Épargne
1. Cliquez sur l'icône crayon dans la carte "Objectif d'épargne"
2. Entrez le montant cible pour le mois
3. La progression s'affiche automatiquement

### Navigation Mensuelle
- Boutons gauche/droite pour naviguer entre les mois
- Cliquez sur le nom du mois pour revenir au mois actuel
- Chaque mois a son propre objectif d'épargne

## Base de Données
Trois nouvelles boîtes Hive :
- `jobBox` : Stocke les emplois
- `savingsGoalBox` : Stocke les objectifs mensuels
- `transactionBox` : (existant) Utilisé pour les dépenses

## Améliorations de Performance
- ❌ Pas de graphiques (évite les lags)
- ❌ Pas de ML/prédictions (calculs lourds supprimés)
- ✅ Cache des valeurs calculées
- ✅ Mise à jour uniquement quand nécessaire
- ✅ Interface simple et rapide

## Notes Importantes
- Les revenus des emplois sont ajoutés automatiquement au total mensuel
- Supprimer un emploi le marque comme inactif (données conservées)
- Chaque mois peut avoir un objectif d'épargne différent
- Les calculs sont basés sur le mois sélectionné, pas sur la semaine actuelle

