import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speakdine_app/core/theme/color_ext.dart';

class RestaurantTransactionsView extends StatelessWidget {
  const RestaurantTransactionsView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: colorExt.surface,
      appBar: AppBar(
        title: Text(
          'Transactions',
          style: TextStyle(
            color: colorExt.primaryText,
            fontWeight: FontWeight.w900,
            fontSize: 22,
            fontFamily: 'Metropolis',
          ),
        ),
        backgroundColor: colorExt.surface,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Payments received from customers',
              style: TextStyle(color: colorExt.secondaryText, fontSize: 14),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('transactions')
                  .where('restaurantId', isEqualTo: user?.uid)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.payments_rounded,
                            size: 64, color: colorExt.secondaryText.withValues(alpha: 0.5)),
                        const SizedBox(height: 16),
                        Text(
                          'No transactions yet',
                          style: TextStyle(
                            color: colorExt.primaryText,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Payments from customers will appear here',
                          style: TextStyle(color: colorExt.secondaryText),
                        ),
                      ],
                    ),
                  );
                }

                final docs = snapshot.data!.docs;
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final tx = docs[index].data() as Map<String, dynamic>;
                    return _buildTransactionCard(tx);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> tx) {
    final customerName = tx['customerName'] as String? ?? 'Customer';
    final amount = (tx['amount'] as num?)?.toDouble() ?? 0;
    final platformFee = (tx['platformFee'] as num?)?.toDouble() ?? 0;
    final restaurantAmount = (tx['restaurantAmount'] as num?)?.toDouble() ?? 0;
    final debtRecovered = (tx['debtRecovered'] as num?)?.toDouble() ?? 0;
    final debtRemaining = (tx['debtRemaining'] as num?)?.toDouble() ?? 0;
    final paymentMethod = tx['paymentMethod'] as String? ?? 'online';
    final createdAt = tx['createdAt'] as Timestamp?;
    final orderId = tx['orderId'] as String? ?? '';
    final dateStr = createdAt != null
        ? '${createdAt.toDate().day}/${createdAt.toDate().month}/${createdAt.toDate().year}'
        : '';
    final hasDebtRecovery = debtRecovered > 0;

    return Container(
      decoration: BoxDecoration(
        color: colorExt.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasDebtRecovery
              ? Colors.orange.withValues(alpha: 0.5)
              : colorExt.primary.withValues(alpha: 0.1),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  customerName,
                  style: TextStyle(
                    color: colorExt.primaryText,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
              Text(
                '${restaurantAmount.toStringAsFixed(0)} PKR',
                style: TextStyle(
                  color: restaurantAmount > 0 ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                'Total: ${amount.toStringAsFixed(0)} PKR',
                style: TextStyle(color: colorExt.secondaryText, fontSize: 11),
              ),
              const SizedBox(width: 8),
              Text(
                'Fee: ${platformFee.toStringAsFixed(0)} PKR',
                style: const TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          if (hasDebtRecovery) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, size: 16, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'COD fee recovery: ${debtRecovered.toStringAsFixed(0)} PKR deducted'
                      '${debtRemaining > 0 ? ' · ${debtRemaining.toStringAsFixed(0)} PKR still owed' : ' · Debt cleared'}',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              if (orderId.isNotEmpty) ...[
                Text(
                  'Order #${orderId.substring(0, 6).toUpperCase()}',
                  style: TextStyle(color: colorExt.secondaryText, fontSize: 12),
                ),
                const SizedBox(width: 12),
              ],
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colorExt.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  paymentMethod.toUpperCase().replaceAll('_', ' '),
                  style: TextStyle(
                    color: colorExt.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Spacer(),
              if (dateStr.isNotEmpty)
                Text(
                  dateStr,
                  style: TextStyle(color: colorExt.secondaryText, fontSize: 12),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
