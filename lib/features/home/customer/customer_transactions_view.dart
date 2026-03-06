import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speakdine_app/core/theme/color_ext.dart';

class CustomerTransactionsView extends StatelessWidget {
  const CustomerTransactionsView({super.key});

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
              'Your payment history',
              style: TextStyle(color: colorExt.secondaryText, fontSize: 14),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('transactions')
                  .where('customerId', isEqualTo: user?.uid)
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
                        Icon(Icons.receipt_long_rounded,
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
                          'Your payments will appear here',
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
    final restaurantName = tx['restaurantName'] as String? ?? 'Restaurant';
    final amount = (tx['amount'] as num?)?.toDouble() ?? 0;
    final paymentMethod = tx['paymentMethod'] as String? ?? 'online';
    final createdAt = tx['createdAt'] as Timestamp?;
    final orderId = tx['orderId'] as String? ?? '';
    final dateStr = createdAt != null
        ? '${createdAt.toDate().day}/${createdAt.toDate().month}/${createdAt.toDate().year}'
        : '';

    return Container(
      decoration: BoxDecoration(
        color: colorExt.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorExt.primary.withValues(alpha: 0.1),
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
                  restaurantName,
                  style: TextStyle(
                    color: colorExt.primaryText,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
              Text(
                '${amount.toStringAsFixed(0)} PKR',
                style: TextStyle(
                  color: colorExt.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
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
