import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import 'package:intl/intl.dart';
import 'package:koaa/app/core/design_system.dart';
import 'package:koaa/app/services/isar_service.dart';
import 'package:koaa/app/core/utils/navigation_helper.dart';
import 'package:koaa/app/data/models/job.dart';
import 'package:uuid/uuid.dart';

void showJobDialog(BuildContext context, {Job? job}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _JobDialog(job: job),
  );
}

class _JobDialog extends StatefulWidget {
  final Job? job;

  const _JobDialog({this.job});

  @override
  State<_JobDialog> createState() => _JobDialogState();
}

class _JobDialogState extends State<_JobDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _amountController;

  late PaymentFrequency _frequency;
  late DateTime _paymentDate;
  late bool _isActive;
  DateTime? _endDate; // Added

  @override
  void initState() {
    super.initState();
    final job = widget.job;
    _nameController = TextEditingController(text: job?.name ?? '');
    _amountController = TextEditingController(
        text: job?.amount.toStringAsFixed(0) ??
            ''); // Remove decimals for clean look

    _frequency = job?.frequency ?? PaymentFrequency.monthly;
    _paymentDate = job?.paymentDate ?? DateTime.now();
    _isActive = job?.isActive ?? true;
    _endDate = job?.endDate; // Added initialization
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _paymentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: KoalaColors.primaryUi(context),
              onPrimary: Colors.white,
              surface: KoalaColors.surface(context),
              onSurface: KoalaColors.text(context),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _paymentDate = picked);
    }
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    String amountText =
        _amountController.text.replaceAll(RegExp(r'[^0-9.]'), '');
    if (amountText.isEmpty) amountText = '0';
    final amount = double.parse(amountText);

    try {
      // Using IsarService

      // Explicitly NOT passing endDate to constructor to avoid crash on stale app instances
      final newJob = Job(
        id: widget.job?.id ?? const Uuid().v4(),
        name: name,
        amount: amount,
        frequency: _frequency,
        paymentDate: _paymentDate,
        isActive: _isActive,
        createdAt: widget.job?.createdAt ?? DateTime.now(),
        endDate: _endDate, // Added saving using the field
      );

      await newJob.save();

      NavigationHelper.safeBack();
    } catch (e) {
      Get.snackbar('Erreur', 'Sauvegarde impossible: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: KoalaColors.destructive.withValues(alpha: 0.1),
          colorText: KoalaColors.destructive);
    }
  }

  void _delete() {
    if (widget.job == null) return;
    KoalaConfirmationDialog.show(
      context: context,
      title: 'Supprimer ?',
      message: 'Cette action est irréversible.',
      confirmText: 'Supprimer',
      isDestructive: true,
      onConfirm: () async {
        try {
          // Using IsarService
          await IsarService.deleteJob(widget.job!.id);
          NavigationHelper.safeBack();
          NavigationHelper.safeBack();
        } catch (_) {}
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return KoalaBottomSheet(
      title: widget.job == null ? 'Nouveau revenu' : 'Modifier',

      // Add trash icon to header if editing
      headerAction: widget.job != null
          ? IconButton(
              icon: Icon(CupertinoIcons.trash,
                  color: KoalaColors.destructive, size: 20.sp),
              onPressed: _delete,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            )
          : null,

      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
              24.w, 0, 24.w, 24.h + MediaQuery.of(context).viewInsets.bottom),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 16.h),

                // Hero Amount Input
                Text(
                  'Montant du salaire',
                  textAlign: TextAlign.center,
                  style: KoalaTypography.label(context)
                      .copyWith(color: KoalaColors.textSecondary(context)),
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    IntrinsicWidth(
                      child: TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: KoalaTypography.heading1(context).copyWith(
                          fontSize: 36.sp,
                          fontWeight: FontWeight.bold,
                          color: KoalaColors.primaryUi(context),
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: '0',
                          hintStyle:
                              TextStyle(color: KoalaColors.border(context)),
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                        validator: (v) => v?.isEmpty == true ? '' : null,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'FCFA',
                      style: KoalaTypography.heading4(context).copyWith(
                          color: KoalaColors.textSecondary(context),
                          fontSize: 16.sp),
                    ),
                  ],
                ),
                SizedBox(height: 32.h),

                // Job Name
                KoalaTextField(
                  controller: _nameController,
                  label: 'Intitulé du poste',
                  validator: (v) => v?.isEmpty == true ? 'Requis' : null,
                ),
                SizedBox(height: 24.h),

                // Frequency Selector (Custom Chips)
                Text('Fréquence de paiement',
                    style: KoalaTypography.label(context)),
                SizedBox(height: 12.h),
                Row(
                  children: PaymentFrequency.values.map((freq) {
                    final isSelected = _frequency == freq;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                            right:
                                freq == PaymentFrequency.values.last ? 0 : 8.w),
                        child: InkWell(
                          onTap: () => setState(() => _frequency = freq),
                          borderRadius: BorderRadius.circular(KoalaRadius.md),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? KoalaColors.primaryUi(context)
                                  : KoalaColors.inputBackground(context),
                              borderRadius:
                                  BorderRadius.circular(KoalaRadius.md),
                              border: isSelected
                                  ? null
                                  : Border.all(
                                      color: KoalaColors.border(context)),
                            ),
                            child: Center(
                              child: Text(
                                _getFrequencyLabel(freq),
                                style:
                                    KoalaTypography.caption(context).copyWith(
                                  color: isSelected
                                      ? Colors.white
                                      : KoalaColors.text(context),
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 24.h),

                // Next Payment Date
                InkWell(
                  onTap: () => _selectDate(context),
                  borderRadius: BorderRadius.circular(KoalaRadius.md),
                  child: Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: KoalaColors.inputBackground(context),
                      borderRadius: BorderRadius.circular(KoalaRadius.md),
                      border: Border.all(color: KoalaColors.border(context)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: KoalaColors.surface(context),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(CupertinoIcons.calendar,
                              size: 20.sp,
                              color: KoalaColors.primaryUi(context)),
                        ),
                        SizedBox(width: 16.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Prochain paiement',
                                style: KoalaTypography.caption(context)),
                            SizedBox(height: 4.h),
                            Text(
                              DateFormat('dd MMMM yyyy', 'fr_FR')
                                  .format(_paymentDate),
                              style: KoalaTypography.bodyMedium(context)
                                  .copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        Spacer(),
                        Icon(CupertinoIcons.chevron_right,
                            size: 16.sp,
                            color: KoalaColors.textSecondary(context)),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24.h),

                // End Date Selector
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Date de fin (Optionnel)',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (_endDate != null)
                          GestureDetector(
                            onTap: () => setState(() => _endDate = null),
                            child: Text(
                              'Effacer',
                              style: TextStyle(
                                color: KoalaColors.destructive,
                                fontWeight: FontWeight.w600,
                                fontSize: 13.sp,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: KoalaSpacing.md),
                    GestureDetector(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _endDate ??
                              DateTime.now().add(const Duration(days: 30)),
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 3650)),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: KoalaColors.primaryUi(context),
                                  onPrimary: Colors.white,
                                  surface: KoalaColors.surface(context),
                                  onSurface: KoalaColors.text(context),
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (date != null) {
                          setState(() => _endDate = date);
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 14.h),
                        decoration: BoxDecoration(
                          color: KoalaColors.inputBackground(context),
                          borderRadius: BorderRadius.circular(KoalaRadius.md),
                          border:
                              Border.all(color: KoalaColors.border(context)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              CupertinoIcons.calendar_today,
                              color: _endDate != null
                                  ? KoalaColors.primaryUi(context)
                                  : KoalaColors.textSecondary(context),
                              size: 20.sp,
                            ),
                            SizedBox(width: KoalaSpacing.md),
                            Text(
                              _endDate != null
                                  ? 'Se termine le : ${DateFormat('dd MMM yyyy', 'fr_FR').format(_endDate!)}'
                                  : 'Pas de date de fin (Indéfini)',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: _endDate != null
                                    ? KoalaColors.text(context)
                                    : KoalaColors.textSecondary(context),
                                fontWeight: _endDate != null
                                    ? FontWeight.w500
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),

                // Active Status Toggle
                if (widget.job != null)
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: KoalaColors.inputBackground(context)
                          .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(KoalaRadius.md),
                    ),
                    child: SwitchListTile.adaptive(
                      value: _isActive,
                      onChanged: (v) => setState(() => _isActive = v),
                      title: Text('Revenu actif',
                          style: KoalaTypography.bodyMedium(context)),
                      activeTrackColor: KoalaColors.primaryUi(context),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(KoalaRadius.md)),
                    ),
                  ),

                SizedBox(height: 32.h),

                // Save Button
                KoalaButton(
                  text: 'Enregistrer',
                  onPressed: _save,
                  backgroundColor: KoalaColors.primaryUi(context),
                  textColor: Colors.white,
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getFrequencyLabel(PaymentFrequency freq) {
    switch (freq) {
      case PaymentFrequency.weekly:
        return 'Hebdo';
      case PaymentFrequency.biweekly:
        return 'Bi-hebdo';
      case PaymentFrequency.monthly:
        return 'Mensuel';
    }
  }
}
