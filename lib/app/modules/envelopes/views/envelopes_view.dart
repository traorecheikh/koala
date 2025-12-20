import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:koaa/app/modules/envelopes/controllers/envelopes_controller.dart';
import 'package:koaa/app/core/design_system.dart';
import 'package:intl/intl.dart';

class EnvelopesView extends GetView<EnvelopesController> {
  const EnvelopesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Ensure controller is loaded if not already
    if (!Get.isRegistered<EnvelopesController>()) {
      Get.put(EnvelopesController());
    }

    final currencyFormat =
        NumberFormat.currency(locale: 'fr_FR', symbol: 'GNF', decimalDigits: 0);

    return Scaffold(
      backgroundColor: KoalaColors.surface(context),
      appBar: AppBar(
        title: Text('Enveloppes Intelligentes',
            style: KoalaTypography.heading3(context)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        return Column(
          children: [
            // Header Summary
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: KoalaColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: KoalaColors.accent.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Disponible',
                          style: KoalaTypography.bodySmall(context)),
                      Text(currencyFormat.format(controller.freeBalance),
                          style: KoalaTypography.heading2(context)
                              .copyWith(color: KoalaColors.accent)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Alloué', style: KoalaTypography.bodySmall(context)),
                      Text(currencyFormat.format(controller.totalAllocated),
                          style: KoalaTypography.bodyLarge(context)
                              .copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),

            // List
            Expanded(
              child: controller.envelopes.isEmpty
                  ? Center(
                      child: Text('Aucune enveloppe créée.',
                          style: KoalaTypography.bodyMedium(context)),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: controller.envelopes.length,
                      itemBuilder: (context, index) {
                        final envelope = controller.envelopes[index];
                        final progress = envelope.targetAmount > 0
                            ? (envelope.currentAmount / envelope.targetAmount)
                                .clamp(0.0, 1.0)
                            : 0.0;

                        return GestureDetector(
                          onTap: () => _showAllocationDialog(
                              context, envelope.id, envelope.name),
                          onLongPress: () =>
                              _showDeleteDialog(context, envelope.id),
                          child: Container(
                            decoration: BoxDecoration(
                              color: KoalaColors.surface(context),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4)),
                              ],
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  backgroundColor:
                                      KoalaColors.accent.withValues(alpha: 0.2),
                                  child: Icon(Icons.savings_outlined,
                                      color: KoalaColors.accent),
                                ),
                                const Spacer(),
                                Text(envelope.name,
                                    style: KoalaTypography.heading4(context),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Text(
                                    '${currencyFormat.format(envelope.currentAmount)} / ${currencyFormat.format(envelope.targetAmount)}',
                                    style: KoalaTypography.caption(context)),
                                const SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor:
                                      Colors.grey.withValues(alpha: 0.2),
                                  color: KoalaColors.accent,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context),
        backgroundColor: KoalaColors.accent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    controller.textController.clear();
    controller.amountController.clear();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: KoalaColors.surface(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nouvelle Enveloppe',
                style: KoalaTypography.heading3(context)),
            const SizedBox(height: 16),
            TextField(
              controller: controller.textController,
              decoration: const InputDecoration(labelText: 'Nom (ex: Loyer)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller.amountController,
              decoration: const InputDecoration(labelText: 'Cible (GNF)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: KoalaColors.accent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  if (controller.textController.text.isNotEmpty) {
                    final target =
                        double.tryParse(controller.amountController.text) ??
                            0.0;
                    controller.createEnvelope(
                        controller.textController.text, target);
                    Get.back();
                  }
                },
                child: const Text('Créer',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showAllocationDialog(BuildContext context, String id, String name) {
    controller.amountController.clear();
    Get.defaultDialog(
      title: 'Remplir "$name"',
      content: Column(
        children: [
          TextField(
            controller: controller.amountController,
            decoration: const InputDecoration(labelText: 'Montant à ajouter'),
            keyboardType: TextInputType.number,
            autofocus: true,
          ),
        ],
      ),
      textConfirm: 'Ajouter',
      textCancel: 'Annuler',
      confirmTextColor: Colors.white,
      onConfirm: () {
        final amount = double.tryParse(controller.amountController.text);
        if (amount != null && amount > 0) {
          controller.allocateToEnvelope(id, amount);
          Get.back();
        }
      },
    );
  }

  void _showDeleteDialog(BuildContext context, String id) {
    Get.defaultDialog(
        title: 'Supprimer',
        middleText:
            'Voulez-vous supprimer cette enveloppe ? Les fonds seront désalloués.',
        textConfirm: 'Oui',
        textCancel: 'Non',
        confirmTextColor: Colors.white,
        onConfirm: () {
          controller.deleteEnvelope(id);
          Get.back();
        });
  }
}
