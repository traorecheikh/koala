RULE 1 DO NOT COMMENT CODES UNLESS ITS DOCUMENTATION COMMENTS

# 1 — Résumé exécutif

Application mobile personnelle « Assistant Financier » (Flutter + GetX, Hive offline) qui ingère et catégorise les transactions, suit salaire & solde, gère prêts et récurrences, fournit des **suggestions d’épargne pilotées par IA**, et reste **privée & chiffrée**. Backend Node.js + Fastify + PostgreSQL (déployable sur Azure free). Conçue pour un unique utilisateur sénégalais (24 ans) mais extensible.

# 2 — Objectifs produit (OKR / métriques)

* O1 (Usage) : Permettre à l’utilisateur d’atteindre ≥15% d’épargne mensuelle en 3 mois via recommandations.
* O2 (Qualité) : Auto-catégorisation ≥90% après 2 semaines d’usage (corrections).
* O3 (Privacité) : 100% des données sensibles chiffrées au repos par défaut.
* Métriques :

  * Taux d’adoption des suggestions IA (nombre de suggestions appliquées / proposées).
  * Précision du classifieur (F1 score) sur données corrigées.
  * Temps moyen pour enregistrer une transaction < 10s.
  * Disponibilité backend (si self-hosted) > 99%.

# 3 — Parties prenantes

* Toi : Product owner & utilisateur unique.
* Développeur(s) : Flutter mobile, Backend Node/Fastify, DBA PostgreSQL.
* IA Agent : modèle local / service d’inference (optionnel payant).
* Hôte : Azure (free tier) / PostgreSQL gratuit.

# 4 — Périmètre (MVP vs futur)

MVP (livraison initiale):

* Onboarding (PIN/biométrie), saisir salaire+solde initial.
* Saisie manuelle + import CSV + parsing SMS/copy-paste.
* Catégorisation hybride (règles + classifieur léger on-device).
* Recurring engine (BRT, bus, cantine).
* IA insights (3 actions/mois) en local ou sur ton serveur.
* Stockage offline-first via Hive, sync optionnel vers PostgreSQL.
* Chiffrement local des données.
* UI mobile moderne, accessible.

Roadmap (post-MVP):

* OCR de justificatifs, capture automatique SMS (Android), LLM plus gros pour explications détaillées, multi-utilisateurs, partages/exports automatiques.

# 5 — Personas & scénarios d’usage

Persona principal : "Toi" — 24 ans, vit au Sénégal, reçoit salaire mensuel, utilise mobile-money (Orange/Wave), prend BRT/bus, veut économiser et suivre prêts.

Scénarios clés :

* Onboarding : saisir salaire, solde initial, date de paie.
* Enregistrement dépense : ajouter dépense BRT et annoter avec photo justificatif.
* Création prêt : saisir montant prêt, échéances, puis lier remboursements.
* Recevoir suggestion IA : demander "Comment économiser 15%?" → obtenir plan en 3 étapes.
* Offline-first : enregistrer transactions hors-ligne, syncer ensuite.

# 6 — User stories (prioritaires, format "En tant que...")

1. En tant qu’utilisateur, je peux saisir une seule fois mon salaire et mon solde initial lors de l’inscription.

   * AC: Le salaire est utilisé pour tous les calculs de budget; modifiable via paramètres; toute modification déclenche confirmation et recalcul.
2. En tant qu’utilisateur, je peux créer, annoter et éditer toute transaction (dépense, revenu, prêt, remboursement) et joindre une photo justificatif.

   * AC: Edits mis à jour localement et poussés au serveur; linked\_loan\_id fonctionne et met à jour remaining\_balance.
3. En tant qu’utilisateur, je peux définir des dépenses récurrentes (BRT,bus,cantine) qui se créent automatiquement.

   * AC: next\_run mis à jour, notifications opt-in 24h avant.
4. En tant qu’utilisateur, je peux demander des suggestions d’économie à l’IA en français et recevoir 1-3 actions actionnables avec estimation XOF.

   * AC: Suggestions fournissent estimation et bouton "Appliquer règle".
5. En tant qu’utilisateur, toutes mes données sensibles restent chiffrées sur l’appareil et ne sont synchronisées qu’avec mon serveur Azure si j’accepte.

   * AC: Hive box encryptée AES-256; sync opt-in.
6. En tant qu’utilisateur, l’app calcule et affiche immédiatement mon `current_balance` après chaque transaction.

   * AC: Mise à jour optimiste; rollback si sync serveur signale erreur.

# 7 — Exigences fonctionnelles (détaillées)

F1 — Onboarding

* Collecter : nom, téléphone, PIN, option biométrie, salaire (XOF), solde initial (cash + mobile-money), date paie.
* Valider format téléphone, salaire >0.
* Stocker user row in DB and Hive.

F2 — Authentification

* Auth locale par PIN + biométrie.
* Possibilité token JWT pour sync serveur.

F3 — Gestion comptes & soldes

* Multi-comptes (cash, Orange Money, Wave...). Chaque compte possède balance.
* current\_balance = sum(account balances) + opening\_balance adjustments.
* API transactions ajuste account.balance et user.current\_balance via triggers.

F4 — Transactions

* CRUD complet.
* Types: expense, income, transfer, loan, repayment.
* Champs obligatoires/optionnels (voir OpenAPI).
* Affects\_balance boolean.

F5 — Règles & catégorisation

* Règles user-defined (merchant regex, montant ranges).
* Classifieur léger on-device mis à jour par corrections utilisateur.
* Priority: rules > classifier > fallback LLM.

F6 — Recurrences

* Création, édition, pause, suppression.
* Engine qui exécute next\_run (client or server cron) et crée transactions.

F7 — IA Insights

* Endpoint `POST /ai/insight` → input: salary, current\_balance, last\_n\_tx, loans.
* Output: suggestions list (title, saving\_estimate\_XOF, steps, priority).
* Option "Appliquer règle" -> create rule + auto-tag transactions.

F8 — Import/Export

* Import CSV/JSON; mapping colonne.
* Export JSON/CSV chiffrés.

F9 — Offline & Sync

* Hive as source-of-truth; sync queue; conflict resolution: client-wins or timestamp-based merge.
* `GET /sync/pending`, `POST /sync/ack`.

F10 — Logs & Telemetry

* Local logs, opt-in error reporting (encrypted).

# 8 — Exigences non-fonctionnelles

* Performance mobile: UI 60fps, list pagination, lazy-loading.
* Latence API acceptable (<300ms typical).
* Disponibilité backend: >= 99% (subject to Azure free limitations).
* Sécurité: TLS, chiffrement AES-256 au repos, JWT secrets dans Azure KeyVault (ou variables d'env).
* Scalabilité: single-user first; stateless server.
* Localisation: FR par défaut, XOF currency.

# 9 — Critères d’acceptation (par feature)

Donne pour chaque epic un test d'acceptation concret (à exécuter en QA):

* Onboarding AC: après création, `GET /user` retourne salary et opening\_balance; Hive boxes contiennent user.
* Transaction AC: créer dépense affectant balance décrémente `users.current_balance` et `accounts.balance` (voir view v\_user\_balance\_check).
* Recurrence AC: créer récurrence mensuelle → en date next\_run, une transaction est créée.
* IA AC: envoyer InsightRequest avec salary & txs → recevoir ≤3 suggestions en français; "Appliquer règle" crée une règle et applique aux tx existantes.
* Security AC: Hive boxes chiffrées et ouverture nécessite PIN/biométrie.

# 10 — Architecture & design technique (haute-niveau)

* Client mobile: Flutter (GetX), Hive (encrypted boxes), local ML model (LightGBM or small TF Lite) + optional llama.cpp integration if device supports.
* Backend: Node.js + Fastify, Postgres (Azure or hosted). JWT auth for sync. OpenAPI spec as contract.
* AI infra: on-device inference preferred (privacy), else host LLM on personal server or use paid API (option future).
* Data flows: mobile -> local store -> sync queue -> server -> postgres triggers update balances.

# 11 — Data model (tables clés) — résumé synthétique

(voir migration fournie précédemment; résumé)

* users (id, name, phone, salary, pay\_day, opening\_balance, current\_balance, currency)
* accounts (id, user\_id, provider, name, balance, details)
* transactions (id, account\_id, user\_id, amount, currency, timestamp, merchant, description, category, tags\[], type, linked\_loan\_id, annotation, receipt\_url, imported, affects\_balance)
* loans (id, user\_id, principal, interest\_rate, start\_date, term\_months, monthly\_due, remaining\_balance)
* recurring, rules, insights

# 12 — API & contrats (résumé)

* Auth: `POST /auth/login` (pin/device) -> JWT
* User: `GET/PUT /user`
* Accounts: `GET/POST /accounts`
* Transactions: `GET /POST /PATCH /DELETE`, `POST /transactions/import`
* Loans: `GET/POST /PATCH`
* Rules: `GET/POST`
* AI: `POST /ai/insight`
* Sync: `GET /sync/pending`, `POST /sync/ack`

(OpenAPI YAML complet fourni plus tôt — utiliser comme spec de génération de stubs.)

# 13 — Spécification IA & ML (exécutable par agent)

## Objectif IA

* Catégorisation automatique des transactions.
* Suggestions d’épargne personnalisées.
* Détection d’anomalies.

## Données d’entrée

* Transactions structurées (dernier 90 jours), corrections labels (category), user salary, pay\_day, loans.

## Pipeline catégorisation (hybride)

1. **Rule engine**: regex & merchant mappings (appliqué en priorité).
2. **Classifieur léger on-device**:

   * Model type: LightGBM / XGBoost small or TF Lite NN (< 1–5 MB).
   * Features: normalized merchant text tokens, amount, time-of-day, account provider, previous category.
   * Training: online incremental training chaque semaine sur device à partir des corrections (save model in Hive).
   * Evaluation metric: F1 macro on labelled dataset; target F1 ≥ 0.9.
3. **LLM fallback** (local small LLM via llama.cpp):

   * Only for ambiguous cases; prompt-driven classification that returns category + confidence.
   * Use small system prompt in FR (templates below).

## Pipeline insights

* Aggregation: sum per category, trend 30/90/180j, ratio dépense/salaire.
* Heuristics + LLM generate suggestions:

  * Rule-based first (économies évidentes).
  * LLM crafts natural language plan (3 steps max), estimation monthly saving in XOF.
* Constraints: never send PII to external APIs without explicit opt-in.

## Prompt templates (FR)

System prompt (FR):

```
Tu es un assistant financier personnel pour un utilisateur au Sénégal. Reçois des données JSON (salaire, solde, dépenses agrégées) et fournis au maximum 3 suggestions actionnables pour économiser de l'argent. Pour chaque suggestion, renvoie: titre, estimation_économie_mensuelle (XOF), priorité (haute,moyenne,basse), étapes concrètes (2-4). Répond uniquement en JSON.
```

User payload example:

```json
{
  "salaire": 200000,
  "current_balance": 50000,
  "top_categories": [
    {"category":"Repas hors domicile","avg_month":40000},
    {"category":"Transport","avg_month":15000}
  ],
  "goal_pct": 15
}
```

Expected response (JSON):

```json
{
  "suggestions":[
    {
      "title":"Réduire repas hors domicile 2→1 par semaine",
      "estimated_monthly_saving":12000,
      "priority":"moyenne",
      "steps":["Préparer 3 repas maison/semaine","Remplacer 1 repas par snack économique"]
    }
  ]
}
```

## Données d’entraînement

* Besoin initial : 200–1000 transactions labellées pour entraînement local acceptable.
* Format CSV/JSON: id, merchant, amount, timestamp, category\_label (if known), account\_provider, tags.

## Interfaces IA pour un agent

* Endpoint local `POST /ai/insight` (voir OpenAPI).
* Local ML model stored in Hive as files + metadata (versioning).

# 14 — UX / UI — livrables pour dev & designer

* Wireframes textuels (fournis). Demander export Figma si besoin.
* Design system tokens (colors, typography, spacings) fournis plus haut.
* Composants Flutter réutilisables (CardTransaction, HeroBalance, QuickActionButton, BottomSheetEditor).
* Motion spec : durations & easings listées.

# 15 — Sécurité & conformité

* Chiffrement Hive AES-256; key derived from PIN + secure enclave (biometrics).
* TLS 1.2+ for all API.
* JWT secret stored in Azure KeyVault / variables d’environnement.
* Consent screen requirement & opt-in for server sync/backups.
* Minimiser partage PII; anonymisation/encryption if logs transmitted.

# 16 — Déploiement (Azure — étapes concrètes)

Préconditions : compte Azure free, base PostgreSQL accessible (ou Azure Database for PostgreSQL free), GitHub repo.

1. Backend:

   * Pack as Node app or Docker container.
   * Provision Azure App Service (Linux) — plan gratuit (considérer limitations).
   * Set env vars: DATABASE\_URL (sslmode=require), JWT\_SECRET, NODE\_ENV=production.
   * Set up KeyVault for secrets (optional).
   * Configure SSL (HTTPS forced).
2. DB:

   * Exécuter migration `001_init.sql` via psql/CI.
3. CI/CD:

   * GitHub Actions pipeline: test → build → deploy to App Service (zip-deploy or Docker).
4. Mobile:

   * Flutter build (release), distribute via APK sideload (android) or TestFlight (iOS, requires dev account).
5. Backups:

   * Database backups via Azure snapshots or scheduled pg\_dump to blob storage (encrypted).
6. Monitoring:

   * Enable Application Insights on App Service for logs, set alerts on error rate.

# 17 — CI / CD (GitHub Actions - outline)

* jobs:

  * test: run unit tests (backend + dart analyze).
  * build: create docker image or node artifact.
  * deploy: push to Azure App Service (using AZURE\_WEBAPP action) or push docker to ACR then Deploy.

# 18 — Tests & QA plan

* Unit tests backend (routes, triggers logic).
* Integration tests: simulate sync flow (client creates txs, sync, validate balances).
* End-to-end: run Flutter integration\_test for onboarding → transaction creation → IA insight.
* Security: pen-test basic (JWT expiry, rate limiting, input validation).
* Performance: load test minimal concurrency (single user but ensure correct triggers).

# 19 — Observabilité & monitoring

* Logs: request logs, error logs, transaction ingestion events.
* Metrics: number of transactions, sync queue length, AI suggestion accept rate.
* Alerts: failed migrations, DB connection errors, 5xx rate > threshold.

# 20 — Backlog & roadmap (milestones)

M0 (week 0): PRD finalisé, OpenAPI, DB migration (done).
M1 (week 1–2): Onboarding, local storage Hive, transaction CRUD, UI basic.
M2 (week 3–4): Categorisation rules + classifier on-device, recurrence engine.
M3 (week 5–6): AI insights (local LLM fallback or server LLM), imports CSV.
M4 (week 7–8): Polish UI/UX, accessibility, tests, deploy on Azure, seed data.
M5+: OCR, SMS parsing, sharing/export, multi-user.

# 21 — Risques & mitigations

* R1: LLM local trop lourd → Mitigation: use rule-based + tiny classifier; offload heavy LLM to laptop server if needed.
* R2: Azure free limitations (sleeping app) → Mitigation: run backend local/private or schedule wake; keep offline-first so app usable sans backend.
* R3: Data loss on sync conflicts → Mitigation: implement versioning, timestamps, client-wins with audit trail and manual reconcile UI.
* R4: Security misconfig → Mitigation: use KeyVault, rotate secrets, pen-test.

# 22 — Handoff / artefacts pour un agent IA (ce qu’il faut fournir)

Pour qu’un agent (IA ou dev) construise tout sans autre contexte fournir :

1. `openapi.yaml` (déjà fourni).
2. `001_init.sql` migration (fourni).
3. Design tokens & wireframes (fourni).
4. Dataset initial (ex. CSV 200 tx labellées) — si non dispo agent doit simuler réalistement transactions senegalaises (Wave/Orange/BRT).
5. Exemples prompts FR et templates (fourni).
6. Accès Azure credentials (si déploiement automatisé).
7. Requirements du device cible (Android min API, iOS min version).

# 23 — Checklist livraison « build-to-ground »

* [x] PRD complet (this document).
* [x] OpenAPI spec (YAML) — endpoints & schemas.
* [x] Migrations SQL initiales (triggers et seed).
* [x] Wireframes & design tokens.
* [x] IA prompt templates + pipeline description.
* [ ] Dataset labellisé initial (optionnel mais recommandé).
* [ ] Stubs Fastify / Flutter templates (peut être généré automatiquement).

# 24 — Prochaine action que je peux livrer immédiatement

Je peux **maintenant** générer (en français) un ou plusieurs des éléments suivants (choisis tout ce que tu veux — je produis immédiatement) :
A. Stub serveur Fastify complet (routes + validation + intégration OpenAPI) prêt à déployer.
B. Code Flutter (modèles Dart + Hive TypeAdapters + controllers GetX) complet pour transactions/editions/home.
C. Script GitHub Actions pour CI/CD -> Azure App Service.
D. Dataset seed complet (200 transactions réalistes sénégalaises) en CSV pour entraîner ton classifieur.
E. Template de tests d’acceptation (BDD) en Gherkin (FR) pour QA.

Dis simplement les lettres (ex : A,C,D) et je génère ça tout de suite.
