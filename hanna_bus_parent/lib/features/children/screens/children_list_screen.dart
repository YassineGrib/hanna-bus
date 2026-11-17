import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/motion/hanna_motion.dart';
import '../../../core/state/app_state.dart';
import '../../../core/state/models.dart';
import '../../../core/theme/hanna_tokens.dart';
import '../../../core/widgets/hanna_background.dart';
import '../../../core/widgets/hanna_button.dart';
import '../../../core/widgets/hanna_card.dart';
import '../../../core/widgets/hanna_header.dart';
import '../../home/screens/quick_qr_pass_screen.dart';
import 'add_edit_child_screen.dart';
import 'child_dossier_screen.dart';

class ChildrenListScreen extends StatefulWidget {
  const ChildrenListScreen({super.key, required this.onOpenTrack});
  final VoidCallback onOpenTrack;

  @override
  State<ChildrenListScreen> createState() => _ChildrenListScreenState();
}

class _ChildrenListScreenState extends State<ChildrenListScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _activeFilter = 'all'; // 'all', 'on_bus', 'school', 'home'

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  bool _matchesFilter(ChildProfile child) {
    switch (_activeFilter) {
      case 'on_bus':
        return child.transitStatus == 'on_bus';
      case 'school':
        return child.transitStatus == 'arrived';
      case 'home':
        return child.transitStatus == 'at_home' || child.transitStatus == 'absent';
      default:
        return true;
    }
  }

  bool _matchesSearch(ChildProfile child, String query) {
    if (query.isEmpty) return true;
    final q = query.toLowerCase();
    return child.fullName.toLowerCase().contains(q) ||
        child.schoolName.toLowerCase().contains(q) ||
        child.busNumber.toLowerCase().contains(q) ||
        child.studentCode.toLowerCase().contains(q) ||
        child.grade.toLowerCase().contains(q);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final t = HannaTokens.of(context);
    final state = AppStateScope.of(context);
    final allKids = state.children;

    final busCount = allKids.where((c) => c.transitStatus == 'on_bus').length;
    final schoolCount = allKids.where((c) => c.transitStatus == 'arrived').length;
    final homeCount = allKids.where((c) => c.transitStatus == 'at_home' || c.transitStatus == 'absent').length;

    final filteredKids = allKids.where((c) {
      return _matchesFilter(c) && _matchesSearch(c, _searchCtrl.text.trim());
    }).toList();

    return Scaffold(
      body: HannaBackground(
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              HannaSpace.lg,
              HannaSpace.md,
              HannaSpace.lg,
              HannaSpace.pageBottomPad,
            ),
            children: [
              HannaHeader(
                title: s.chListTitle,
                trailing: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      HannaMotion.route(const AddEditChildScreen()),
                    );
                  },
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: t.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: t.border),
                    ),
                    child: Center(
                      child: Icon(LucideIcons.plus, size: 20, color: t.text),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: HannaSpace.md),

              // Search input + Filter button row (y=116 in FigCraft)
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: t.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: t.border),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          Icon(LucideIcons.search, size: 18, color: t.textMuted),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchCtrl,
                              onChanged: (_) => setState(() {}),
                              style: Theme.of(context).textTheme.bodyMedium,
                              decoration: InputDecoration(
                                hintText: s.chSearchPh,
                                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: t.textMuted,
                                      fontSize: 13,
                                    ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          if (_searchCtrl.text.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _searchCtrl.clear();
                                setState(() {});
                              },
                              child: Icon(LucideIcons.x, size: 16, color: t.textMuted),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      // Cycle or reset filters
                      setState(() {
                        _activeFilter = _activeFilter == 'all' ? 'on_bus' : 'all';
                      });
                    },
                    child: Container(
                      width: 44,
                      height: 46,
                      decoration: BoxDecoration(
                        color: t.actionPrimary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Icon(LucideIcons.filter, size: 18, color: t.onPrimary),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Filter chips row (y=172 in FigCraft)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _FilterChip(
                      label: s.isArabic ? 'الكل (${allKids.length})' : 'All (${allKids.length})',
                      selected: _activeFilter == 'all',
                      onTap: () => setState(() => _activeFilter = 'all'),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: s.isArabic ? 'في الحافلة ($busCount)' : 'On Bus ($busCount)',
                      selected: _activeFilter == 'on_bus',
                      onTap: () => setState(() => _activeFilter = 'on_bus'),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: s.isArabic ? 'في المدرسة ($schoolCount)' : 'At School ($schoolCount)',
                      selected: _activeFilter == 'school',
                      onTap: () => setState(() => _activeFilter = 'school'),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: s.isArabic ? 'في المنزل ($homeCount)' : 'At Home ($homeCount)',
                      selected: _activeFilter == 'home',
                      onTap: () => setState(() => _activeFilter = 'home'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: HannaSpace.md),

              // 3 Rich Child Cards
              if (filteredKids.isEmpty)
                HannaCard(
                  padding: const EdgeInsets.all(HannaSpace.xl),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.users, size: 36, color: t.textMuted),
                        const SizedBox(height: 10),
                        Text(
                          s.tr('No children found', 'لا يوجد طلاب مطابقون للبحث', 'Aucun enfant trouvé'),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...filteredKids.map((child) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _RichChildCard(
                      child: child,
                      onTap: () async {
                        await state.selectChild(child.id);
                        if (context.mounted) {
                          Navigator.of(context).push(
                            HannaMotion.route(
                              ChildDossierScreen(
                                childId: child.id,
                                onOpenTrack: widget.onOpenTrack,
                              ),
                            ),
                          );
                        }
                      },
                      onQuickQr: () {
                        Navigator.of(context).push(
                          HannaMotion.route(const QuickQrPassScreen()),
                        );
                      },
                      onQuickEdit: () {
                        Navigator.of(context).push(
                          HannaMotion.route(AddEditChildScreen(existingChild: child)),
                        );
                      },
                    ),
                  );
                }),

              const SizedBox(height: HannaSpace.sm),
              // Bottom "+ Add New Child" button (y=742 in FigCraft)
              HannaButton(
                label: s.chBtnAddNew,
                icon: LucideIcons.plus,
                onPressed: () {
                  Navigator.of(context).push(
                    HannaMotion.route(const AddEditChildScreen()),
                  );
                },
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = HannaTokens.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? t.actionPrimary : t.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? t.actionPrimary : t.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            color: selected ? t.onPrimary : t.text,
          ),
        ),
      ),
    );
  }
}

class _RichChildCard extends StatelessWidget {
  const _RichChildCard({
    required this.child,
    required this.onTap,
    required this.onQuickQr,
    required this.onQuickEdit,
  });

  final ChildProfile child;
  final VoidCallback onTap;
  final VoidCallback onQuickQr;
  final VoidCallback onQuickEdit;

  @override
  Widget build(BuildContext context) {
    final t = HannaTokens.of(context);
    final s = AppStrings.of(context);

    // Status pill styling
    final (statusBg, statusFg, statusText) = switch (child.transitStatus) {
      'on_bus' => (
          t.actionPrimary,
          t.onPrimary,
          s.isArabic ? 'في الحافلة · ${child.etaMinutes} د' : 'On Bus · ${child.etaMinutes}m',
        ),
      'arrived' => (
          t.heroAccent,
          t.text,
          s.isArabic ? 'في المدرسة' : 'At School',
        ),
      _ => (
          t.surfaceSubtle,
          t.text,
          s.isArabic ? 'في المنزل' : 'At Home',
        ),
    };

    // Live timestamp text
    final timestampText = switch (child.transitStatus) {
      'on_bus' => s.isArabic
          ? 'صعد 07:16 ص · محطة حي النصر'
          : 'Boarded 07:16 AM · ${child.stopName}',
      'arrived' => s.isArabic
          ? 'وصلت 07:42 ص · البوابة الشرقية'
          : 'Checked in 07:42 AM · East Gate',
      _ => s.isArabic
          ? 'موعد الصعود 08:15 ص'
          : 'Morning pickup at ${child.stopTime}',
    };

    // Medical badge text & styling
    final lowerAllergies = child.allergies.toLowerCase().trim();
    final hasMedicalAlert = lowerAllergies.isNotEmpty &&
        !lowerAllergies.contains('none') &&
        !lowerAllergies.contains('no medical') &&
        !lowerAllergies.contains('no alerts') &&
        !lowerAllergies.contains('لا توجد') &&
        !lowerAllergies.contains('لا يوجد') &&
        !lowerAllergies.contains('سليم');

    final (medBg, medFg, medLabel) = hasMedicalAlert
        ? (
            t.destructiveSurface,
            t.actionDestructive,
            s.isArabic
                ? (lowerAllergies.contains('peanut')
                    ? 'حساسية فول سوداني'
                    : (lowerAllergies.contains('asthma') ? 'بخاخ ربو' : child.allergies))
                : child.allergies,
          )
        : (
            t.surfaceSubtle,
            t.textMuted,
            s.isArabic ? 'لا توجد تنبيهات طبية' : 'No Medical Alerts',
          );

    final displayName = s.isArabic
        ? (child.fullName.contains('Youssef')
            ? 'يوسف منصوري'
            : (child.fullName.contains('Amina')
                ? 'أمينة منصوري'
                : (child.fullName.contains('Rayan') ? 'ريان منصوري' : child.fullName)))
        : child.fullName;

    final displayGrade = s.isArabic
        ? (child.fullName.contains('Youssef')
            ? 'السنة 3 ابتدائي · مدرسة الوئام'
            : (child.fullName.contains('Amina')
                ? 'السنة 1 متوسط · متوسطة ابن خلدون'
                : (child.fullName.contains('Rayan') ? 'تحضيري 2 · روضة المنار' : '${child.grade} · ${child.schoolName}')))
        : '${child.grade} · ${child.schoolName}';

    return Container(
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: t.border),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 4),
            blurRadius: 14,
            color: t.text.withValues(alpha: 0.06),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top row: Avatar, Name & Grade, Status pill pinned to right
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: t.heroAccent,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Center(
                        child: Icon(LucideIcons.graduationCap, size: 24, color: t.text),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            displayGrade,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: t.textMuted,
                                  fontSize: 12,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      fit: FlexFit.loose,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          statusText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: statusFg,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Card divider
                Container(height: 1, color: t.border),
                const SizedBox(height: 10),

                // Bus & live timestamp row
                Row(
                  children: [
                    Icon(LucideIcons.bus, size: 15, color: t.text),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        s.isArabic
                            ? 'حافلة ${child.busNumber} · مقعد ${child.seatNumber}'
                            : 'Bus ${child.busNumber} · Seat ${child.seatNumber}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: t.text,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  timestampText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: t.textMuted,
                  ),
                ),
                const SizedBox(height: 10),

                // Medical badge pill + Quick actions (QR + Edit)
                Row(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: medBg,
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Text(
                            medLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: medFg,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Quick QR Button
                    GestureDetector(
                      onTap: onQuickQr,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: t.background,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: t.border),
                        ),
                        child: Center(
                          child: Icon(LucideIcons.qrCode, size: 16, color: t.text),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Quick Edit Button
                    GestureDetector(
                      onTap: onQuickEdit,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: t.background,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: t.border),
                        ),
                        child: Center(
                          child: Icon(LucideIcons.pencil, size: 15, color: t.text),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
