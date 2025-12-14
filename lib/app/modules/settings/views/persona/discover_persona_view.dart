import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<FinancialPersona?>(
        future: _getPersona(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CupertinoActivityIndicator());
          }

          final persona = snapshot.data!;

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            child:
                !_isRevealed
                    ? _buildRevealScreen(persona)
                    : _buildPersonaDetails(persona),
          );
        },
      ),
    );
  }

  Future<FinancialPersona?> _getPersona() async {
    try {
      await Future.delayed(const Duration(milliseconds: 1500));
      final engine = Get.find<KoalaMLEngine>();
      final profile = engine.currentUserProfile;

      if (profile != null) {
        return FinancialPersona.values.firstWhere(
          (e) => e.name == profile.personaType,
          orElse: () => FinancialPersona.planner,
        );
      }
      return FinancialPersona.planner;
    } catch (e) {
      return FinancialPersona.planner;
    }
  }

  Widget _buildRevealScreen(FinancialPersona persona) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF1E3A5F), const Color(0xFF2D3250)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
                CupertinoIcons.sparkles,
                size: 80.sp,
                color: Colors.white.withOpacity(0.9),
              )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scale(
                begin: const Offset(0.9, 0.9),
                end: const Offset(1.1, 1.1),
                duration: 1500.ms,
              ),
          SizedBox(height: 32.h),
          Text(
            'Analyse de vos habitudes...',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w300,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.2, end: 0),
          SizedBox(height: 16.h),
          Text(
            'L\'IA de Koala étudie vos transactions\npour découvrir votre profil unique.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white60,
              height: 1.5,
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
          SizedBox(height: 60.h),
          CupertinoButton(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30.r),
            padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
            child: Text(
              'Révéler mon profil',
              style: TextStyle(
                color: const Color(0xFF1E3A5F),
                fontWeight: FontWeight.w600,
                fontSize: 16.sp,
              ),
            ),
            onPressed: () => setState(() => _isRevealed = true),
          ).animate().fadeIn(delay: 1000.ms).scale(),
        ],
      ),
    );
  }

  Widget _buildPersonaDetails(FinancialPersona persona) {
    final info = _getPersonaInfo(persona);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F1E) : const Color(0xFFF8F9FE),
      // surfaceTintColor: Colors.transparent, // Not needed here as backgroundColor is explicit, but good practice
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            CupertinoIcons.xmark,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () => NavigationHelper.safeBack(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 40.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Card
            Center(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 24.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF4A6C9B), const Color(0xFF2E3B55)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(32.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4A6C9B).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        info.icon,
                        size: 56.sp,
                        color: Colors.white,
                      ),
                    ).animate().scale(
                      duration: 600.ms,
                      curve: Curves.easeOutBack,
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      info.title,
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ).animate().fadeIn().slideY(begin: 0.2, end: 0),
                    SizedBox(height: 8.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        info.tagline,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ).animate().fadeIn(delay: 200.ms),
                  ],
                ),
              ),
            ).animate().slideY(begin: 0.1, end: 0, duration: 600.ms),

            SizedBox(height: 40.h),

            // Description
            Text(
              'Analyse',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
                letterSpacing: 1,
              ),
            ).animate().fadeIn(delay: 300.ms),
            SizedBox(height: 12.h),
            Text(
              info.description,
              style: TextStyle(
                fontSize: 16.sp,
                height: 1.6,
                color: isDark ? Colors.white70 : const Color(0xFF2D3250),
              ),
            ).animate().fadeIn(delay: 400.ms),

            SizedBox(height: 32.h),

            // Strengths Section
            _buildSectionHeader('Vos Super-Pouvoirs', CupertinoIcons.bolt_fill)
                .animate()
                .fadeIn(delay: 500.ms),
            SizedBox(height: 16.h),
            ...info.strengths.asMap().entries.map(
                  (entry) => _buildListItem(
                    entry.value,
                    isDark,
                    delay: 600 + (entry.key * 100),
                    icon: CupertinoIcons.check_mark_circled_solid,
                    iconColor: Colors.green,
                  ),
                ),

            SizedBox(height: 32.h),

            // Tips Section
            _buildSectionHeader('Pistes d\'Amélioration', CupertinoIcons.lightbulb_fill)
                .animate()
                .fadeIn(delay: 800.ms),
            SizedBox(height: 16.h),
            ...info.tips.asMap().entries.map(
                  (entry) => _buildListItem(
                    entry.value,
                    isDark,
                    delay: 900 + (entry.key * 100),
                    icon: CupertinoIcons.arrow_up_right_circle_fill,
                    iconColor: Colors.orange,
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Row(
      children: [
        Icon(icon, size: 20.sp, color: isDark ? const Color(0xFF64B5F6) : const Color(0xFF4A6C9B)),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.titleLarge?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildListItem(
    String text,
    bool isDark, {
    required int delay,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1B1E) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade100,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 2.h),
            child: Icon(icon, size: 20.sp, color: iconColor),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15.sp,
                color: isDark ? Colors.white70 : Colors.black87,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay.ms).slideX(begin: 0.1, end: 0);
  }

  _PersonaInfo _getPersonaInfo(FinancialPersona persona) {
    switch (persona) {
      case FinancialPersona.saver:
        return _PersonaInfo(
          title: 'L\'Écureuil Avisé',
          tagline: 'Sécurité & Vision Long Terme',
          icon: CupertinoIcons.checkmark_shield_fill,
          description:
              'Votre profil indique une excellente discipline financière. Vous privilégiez la sécurité et réfléchissez avant chaque dépense. Votre fonds d\'urgence est probablement votre plus grande fierté.',
          strengths: [
            'Discipline de fer face aux achats impulsifs',
            'Forte résilience face aux imprévus',
            'Vision claire de vos objectifs futurs',
          ],
          tips: [
            'Votre argent dort peut-être trop. Pensez à investir pour battre l\'inflation.',
            'N\'oubliez pas de vivre ! Allouez un budget "plaisir" sans culpabilité.',
          ],
        );
      case FinancialPersona.spender:
        return _PersonaInfo(
          title: 'Le Bon Vivant',
          tagline: 'Expériences & Instant Présent',
          icon: CupertinoIcons.gift_fill,
          description:
              'Pour vous, l\'argent est un moyen de vivre des expériences et de faire plaisir. Vous êtes généreux et profitez de la vie, parfois au détriment de votre sécurité financière future.',
          strengths: [
            'Générosité naturelle envers vos proches',
            'Optimisme et capacité à profiter de la vie',
            'Investissement dans des expériences mémorables',
          ],
          tips: [
            'Adoptez la règle 50/30/20 pour sécuriser votre avenir sans arrêter de vivre.',
            'Automatisez votre épargne dès le jour de paie pour ne pas la dépenser.',
          ],
        );
      case FinancialPersona.planner:
        return _PersonaInfo(
          title: 'Le Stratège',
          tagline: 'Organisation & Contrôle',
          icon: CupertinoIcons.map_fill,
          description:
              'Vos finances sont un mécanisme bien huilé. Vous savez exactement où va chaque franc et vous avez un plan pour tout. L\'imprévu est votre seul véritable ennemi.',
          strengths: [
            'Maîtrise totale de votre cash-flow',
            'Clarté sur vos objectifs financiers',
            'Capacité à optimiser chaque dépense',
          ],
          tips: [
            'Laissez un peu de place à l\'imprévu pour réduire votre stress.',
            'Vérifiez si votre plan rigoureux correspond toujours à vos envies de vie actuelles.',
          ],
        );
      case FinancialPersona.survival:
        return _PersonaInfo(
          title: 'Le Résilient',
          tagline: 'Courage & Priorités',
          icon: CupertinoIcons.heart_fill,
          description:
              'Vous gérez des flux tendus avec courage. Votre priorité actuelle est de couvrir les besoins essentiels. Chaque décision financière est un arbitrage important.',
          strengths: [
            'Capacité exceptionnelle à prioriser l\'essentiel',
            'Débrouillardise pour trouver des solutions',
            'Grande résilience face aux défis quotidiens',
          ],
          tips: [
            'Concentrez-vous sur la constitution d\'un micro-fonds de secours (20.000F).',
            'Cherchez à stabiliser ou augmenter vos revenus avant de couper davantage.',
          ],
        );
      case FinancialPersona.fluctuator:
        return _PersonaInfo(
          title: 'L\'Acrobate',
          tagline: 'Adaptabilité & Réactivité',
          icon: CupertinoIcons.graph_circle_fill,
          description:
              'Vos revenus ou dépenses font les montagnes russes. Vous avez développé une capacité unique à jongler entre les périodes d\'abondance et les périodes de vaches maigres.',
          strengths: [
            'Adaptabilité rapide aux changements de situation',
            'Réactivité face aux opportunités',
            'Capacité à vivre avec peu quand il le faut',
          ],
          tips: [
            'Lissez votre budget : mettez de côté les mois fastes pour couvrir les mois creux.',
            'Basez votre train de vie sur votre revenu minimum, jamais sur la moyenne.',
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
