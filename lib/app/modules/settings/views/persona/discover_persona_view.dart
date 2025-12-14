import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:koaa/app/core/design_system.dart';
import 'package:koaa/app/data/models/ml/user_financial_profile.dart';
import 'package:koaa/app/services/financial_context_service.dart';
import 'package:koaa/app/services/ml/koala_ml_engine.dart';
import 'package:koaa/app/services/ml/models/behavior_profiler.dart';
import 'package:koaa/app/core/utils/navigation_helper.dart';

class DiscoverPersonaView extends StatefulWidget {
  const DiscoverPersonaView({super.key});

  @override
  State<DiscoverPersonaView> createState() => _DiscoverPersonaViewState();
}

class _DiscoverPersonaViewState extends State<DiscoverPersonaView> {
  bool _isRevealed = false;
  String _loadingStatus = 'Initialisation...';
  double _progress = 0.0;
  UserFinancialProfile? _profile;
  bool _isAnalyzing = true;

  @override
  void initState() {
    super.initState();
    _startAnalysis();
  }

  Future<void> _startAnalysis() async {
    try {
      final engine = Get.find<KoalaMLEngine>();
      final contextService = Get.find<FinancialContextService>();

      // Artificial delay steps for UX "Smartness"
      _updateStatus(
          'Analyse de ${contextService.allTransactions.length} transactions...',
          0.2);
      await Future.delayed(300.ms);

      _updateStatus('Calcul des taux d\'épargne...', 0.4);
      // Trigger real analysis
      await engine.runFullAnalysis(contextService.allTransactions, []);
      await Future.delayed(300.ms);

      _updateStatus('Détection des habitudes...', 0.6);
      await Future.delayed(500.ms);

      _updateStatus('Classification du profil...', 0.8);
      await Future.delayed(200.ms);

      _updateStatus('Finalisation...', 1.0);

      if (mounted) {
        setState(() {
          _profile = engine.currentUserProfile;
          _isAnalyzing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _profile = UserFinancialProfile(
              personaType: FinancialPersona.planner.name,
              savingsRate: 0,
              consistencyScore: 0,
              categoryPreferences: {},
              detectedPatterns: []);
          _isAnalyzing = false;
        });
      }
    }
  }

  void _updateStatus(String status, double progress) {
    if (mounted) {
      setState(() {
        _loadingStatus = status;
        _progress = progress;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KoalaColors.background(context),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 600),
        child: (_isRevealed && _profile != null)
            ? _buildPersonaDetails(_profile!)
            : _buildRevealScreen(isAnalyzing: _isAnalyzing),
      ),
    );
  }

  Widget _buildRevealScreen({required bool isAnalyzing}) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: KoalaColors.background(context),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Smart Minimal Pulse
          Container(
            padding: EdgeInsets.all(32.w),
            decoration: BoxDecoration(
              color: KoalaColors.primaryUi(context).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isAnalyzing
                  ? CupertinoIcons.gear_alt_fill
                  : CupertinoIcons.waveform_circle_fill,
              size: 64.sp,
              color: KoalaColors.primaryUi(context),
            )
                .animate(
                  onPlay: (controller) => controller.repeat(),
                )
                .rotate(duration: 2000.ms, begin: 0, end: isAnalyzing ? 1 : 0),
          )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scale(
                begin: const Offset(0.95, 0.95),
                end: const Offset(1.05, 1.05),
                duration: 2000.ms,
              ),
          SizedBox(height: 40.h),

          // Typographic Header
          Text(
            isAnalyzing ? 'INTELLIGENCE ARTIFICIELLE' : 'ANALYSE TERMINÉE',
            style: KoalaTypography.caption(context).copyWith(
              letterSpacing: 4,
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(duration: 800.ms),
          SizedBox(height: 16.h),

          AnimatedSwitcher(
            duration: 300.ms,
            child: Text(
              isAnalyzing
                  ? _loadingStatus
                  : 'Votre profil financier\nest prêt.',
              key: ValueKey(_loadingStatus),
              textAlign: TextAlign.center,
              style: KoalaTypography.heading2(context).copyWith(
                height: 1.3,
              ),
            ),
          ),

          SizedBox(height: 60.h),

          // Action Button
          if (!isAnalyzing)
            SizedBox(
              width: 200.w,
              child: KoalaButton(
                text: 'Révéler',
                onPressed: () => setState(() => _isRevealed = true),
              ),
            ).animate().fadeIn(delay: 200.ms).scale(),

          if (isAnalyzing)
            SizedBox(
              width: 100.w,
              child: LinearProgressIndicator(
                value: _progress,
                backgroundColor: KoalaColors.border(context),
                color: KoalaColors.primaryUi(context),
                borderRadius: BorderRadius.circular(4),
              ),
            )
        ],
      ),
    );
  }

  Widget _buildPersonaDetails(UserFinancialProfile profile) {
    final persona = FinancialPersona.values.firstWhere(
        (e) => e.name == profile.personaType,
        orElse: () => FinancialPersona.planner);

    final info = _getPersonaInfo(persona, profile);
    final primaryColor = KoalaColors.primaryUi(context);

    return Scaffold(
      backgroundColor: KoalaColors.background(context),
      appBar: AppBar(
        backgroundColor: KoalaColors.background(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            CupertinoIcons.xmark,
            color: KoalaColors.text(context),
          ),
          onPressed: () => NavigationHelper.safeBack(),
        ),
        title: Text('Mon Profil', style: KoalaTypography.heading3(context)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 40.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Big Persona Card (Bento Style)
            Container(
              padding: EdgeInsets.symmetric(vertical: 32.h, horizontal: 24.w),
              decoration: BoxDecoration(
                color: KoalaColors.surface(context),
                borderRadius: BorderRadius.circular(KoalaRadius.xl),
                border: Border.all(color: KoalaColors.border(context)),
                boxShadow: KoalaShadows.sm,
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      info.icon,
                      size: 48.sp,
                      color: primaryColor,
                    ),
                  )
                      .animate()
                      .scale(duration: 600.ms, curve: Curves.easeOutBack),
                  SizedBox(height: 24.h),
                  Text(
                    info.title,
                    style: KoalaTypography.heading1(context).copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn().slideY(begin: 0.2, end: 0),
                  SizedBox(height: 8.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: KoalaColors.background(context),
                      borderRadius: BorderRadius.circular(KoalaRadius.full),
                      border: Border.all(color: KoalaColors.border(context)),
                    ),
                    child: Text(
                      info.tagline,
                      style: KoalaTypography.caption(context).copyWith(
                        fontWeight: FontWeight.w600,
                        color: KoalaColors.textSecondary(context),
                      ),
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                  SizedBox(height: 24.h),
                  Text(
                    info.description,
                    style: KoalaTypography.bodyMedium(context).copyWith(
                      height: 1.6,
                      color: KoalaColors.textSecondary(context),
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 300.ms),
                ],
              ),
            ).animate().slideY(begin: 0.05, end: 0, duration: 500.ms),

            SizedBox(height: 24.h),

            // 2. Bento Grid: Super-Pouvoirs
            _buildBentoSectionHeader('Vos Smart Insights',
                    CupertinoIcons.bolt_fill, KoalaColors.success)
                .animate()
                .fadeIn(delay: 400.ms),
            SizedBox(height: 12.h),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12.h,
              crossAxisSpacing: 12.w,
              childAspectRatio: 1.3,
              children: info.strengths.asMap().entries.map((entry) {
                return _buildSmallBentoCard(
                  entry.value,
                  delay: 500 + (entry.key * 100),
                  icon: CupertinoIcons.checkmark_circle_fill,
                  accentColor: KoalaColors.success,
                );
              }).toList(),
            ),

            SizedBox(height: 24.h),

            // 3. Bento Grid: Pistes d'Amélioration
            _buildBentoSectionHeader('Recommandations IA',
                    CupertinoIcons.lightbulb_fill, KoalaColors.warning)
                .animate()
                .fadeIn(delay: 700.ms),
            SizedBox(height: 12.h),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 1, // Full width for tips to allow more text
              mainAxisSpacing: 12.h,
              crossAxisSpacing: 12.w,
              childAspectRatio: 3.5, // Wider aspect ratio for list-like cards
              children: info.tips.asMap().entries.map((entry) {
                return _buildWideBentoCard(
                  entry.value,
                  delay: 800 + (entry.key * 100),
                  icon: CupertinoIcons.arrow_up_right_circle_fill,
                  accentColor: KoalaColors.warning,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBentoSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18.sp, color: color),
        SizedBox(width: 8.w),
        Text(
          title,
          style: KoalaTypography.label(context),
        ),
      ],
    );
  }

  Widget _buildSmallBentoCard(String text,
      {required int delay,
      required IconData icon,
      required Color accentColor}) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
          color: KoalaColors.surface(context),
          borderRadius: BorderRadius.circular(KoalaRadius.lg),
          border: Border.all(color: KoalaColors.border(context)),
          boxShadow: KoalaShadows.xs,
          // Small accent line at top
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [
                0.02,
                0.02
              ],
              colors: [
                accentColor.withValues(alpha: 0.5),
                KoalaColors.surface(context)
              ])),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon(icon, size: 24.sp, color: accentColor),
          // Spacer(),
          Expanded(
            child: Text(
              text,
              style: KoalaTypography.bodySmall(context).copyWith(
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay.ms).scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildWideBentoCard(String text,
      {required int delay,
      required IconData icon,
      required Color accentColor}) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: KoalaColors.surface(context),
        borderRadius: BorderRadius.circular(KoalaRadius.lg),
        boxShadow: KoalaShadows.xs,
        border: Border.all(color: KoalaColors.border(context)),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4.w, color: accentColor),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        text,
                        style: KoalaTypography.bodyMedium(context).copyWith(
                          height: 1.4,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Icon(icon,
                        size: 24.sp, color: accentColor.withValues(alpha: 0.5)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: delay.ms).slideX(begin: 0.05, end: 0);
  }

  _PersonaInfo _getPersonaInfo(
      FinancialPersona persona, UserFinancialProfile profile) {
    // Dynamic Data Injection
    final savingsPct = (profile.savingsRate * 100).toStringAsFixed(0);
    final topCategory = profile.categoryPreferences.isNotEmpty
        ? profile.categoryPreferences.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key
        : 'Divers';

    switch (persona) {
      case FinancialPersona.saver:
        return _PersonaInfo(
          title: 'L\'Écureuil Avisé',
          tagline: 'Sécurité & Vision Long Terme',
          icon: CupertinoIcons.checkmark_shield_fill,
          description:
              'Votre discipline est impressionnante. Avec un taux d\'épargne de $savingsPct%, vous bâtissez une sécurité durable.',
          strengths: [
            'Vous épargnez $savingsPct% de vos revenus chaque mois.',
            'Votre dépense principale ($topCategory) est maîtrisée.',
            'Vision claire et résilience forte.',
            'Gestion prudente des risques.'
          ],
          tips: [
            'Votre argent dort peut-être trop. Pensez à investir pour battre l\'inflation.',
            'Allouez un budget "plaisir" pour ne pas vous priver totalement.',
          ],
        );
      case FinancialPersona.spender:
        return _PersonaInfo(
          title: 'Le Bon Vivant',
          tagline: 'Expériences & Instant Présent',
          icon: CupertinoIcons.gift_fill,
          description:
              'Vous croquez la vie à pleines dents ! Vos dépenses en "$topCategory" montrent que vous valorisez l\'expérience.',
          strengths: [
            'Vous soutenez l\'économie par vos choix.',
            'Optimisme et générosité naturels.',
            'Vous savez vous faire plaisir.',
            'Aucun regret sur vos achats.'
          ],
          tips: [
            'Visez d\'augmenter votre épargne (actuellement $savingsPct%) vers 10-20%.',
            'Automatisez un virement vers un compte épargne dès le jour de paie.',
          ],
        );
      case FinancialPersona.planner:
        return _PersonaInfo(
          title: 'Le Stratège',
          tagline: 'Organisation & Contrôle',
          icon: CupertinoIcons.map_fill,
          description:
              'Tout est sous contrôle. Votre taux d\'épargne de $savingsPct% et vos dépenses régulières montrent une grande maîtrise.',
          strengths: [
            'Cash-flow parfaitement maîtrisé.',
            'Objectifs financiers clairs.',
            'Vous anticipez chaque dépense.',
            'Pas de surprise en fin de mois.'
          ],
          tips: [
            'Relâchez parfois la pression, l\'imprévu a du bon.',
            'Vérifiez si vottre plan correspond toujours à vos envies de vie.',
          ],
        );
      case FinancialPersona.survival:
        return _PersonaInfo(
          title: 'Le Résilient',
          tagline: 'Courage & Priorités',
          icon: CupertinoIcons.heart_fill,
          description:
              'Vous gérez un budget serré avec courage. Chaque choix compte, et vous priorisez l\'essentiel.',
          strengths: [
            'Capacité à prioriser l\'essentiel.',
            'Grande débrouillardise quotidienne.',
            'Vous savez faire beaucoup avec peu.',
            'Résilience exemplaire.'
          ],
          tips: [
            'Concentrez-vous sur la création d\'un micro-fonds de secours (20.000F).',
            'Analysez vos dépenses en "$topCategory" pour trouver des économies.',
          ],
        );
      case FinancialPersona.fluctuator:
        return _PersonaInfo(
          title: 'L\'Acrobate',
          tagline: 'Adaptabilité & Réactivité',
          icon: CupertinoIcons.graph_circle_fill,
          description:
              'Vos finances sont dynamiques. Vous savez jongler entre les mois fastes et les périodes creuses.',
          strengths: [
            'Adaptabilité face aux changements.',
            'Réactivité immédiate.',
            'Vous savez réduire la voilure si besoin.',
            'Gestion agile du budget.'
          ],
          tips: [
            'Lissez votre budget en mettant de côté quand tout va bien.',
            'Basez votre train de vie sur votre revenu minimum observé.',
          ],
        );
    }
  }
}

class _PersonaInfo {
  final String title;
  final String tagline;
  final IconData icon;
  final String description;
  final List<String> strengths;
  final List<String> tips;

  _PersonaInfo({
    required this.title,
    required this.tagline,
    required this.icon,
    required this.description,
    required this.strengths,
    required this.tips,
  });
}

