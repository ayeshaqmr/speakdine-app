import 'package:flutter/material.dart';
import 'package:speakdine_app/core/theme/color_ext.dart';
import 'package:speakdine_app/features/home/customer/order_history_view.dart';
import 'package:speakdine_app/features/home/customer/notifications_view.dart';
import 'package:speakdine_app/features/home/customer/payment_methods_view.dart';

class MoreView extends StatefulWidget {
  const MoreView({super.key});

  @override
  State<MoreView> createState() => _MoreViewState();
}

class _MoreViewState extends State<MoreView> {
  List<Map> moreArr = [
    {"name": "Payment Details", "icon": Icons.payment_outlined},
    {"name": "My Orders", "icon": Icons.shopping_bag_outlined},
    {"name": "Notifications", "icon": Icons.notifications_none_rounded},
    {"name": "Inbox", "icon": Icons.mail_outline_rounded},
    {"name": "About Us", "icon": Icons.info_outline_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 46),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Scaffold.of(context).openDrawer(),
                        icon: Icon(Icons.menu_rounded, color: colorExt.primary, size: 28),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "More",
                        style: TextStyle(
                            color: colorExt.primaryText,
                            fontSize: 24,
                            fontWeight: FontWeight.w800),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.shopping_cart_outlined,
                          size: 28,
                          color: colorExt.primaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: moreArr.length,
                    itemBuilder: (context, index) {
                      var mObj = moreArr[index] as Map? ?? {};
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))
                          ]
                        ),
                        child: InkWell(
                          onTap: () {
                            if (index == 0) {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const PaymentMethodsView()));
                            } else if (index == 1) {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const OrderHistoryView()));
                            } else if (index == 2) {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsView()));
                            }
                          },
                          borderRadius: BorderRadius.circular(15),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: colorExt.textField,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Icon(mObj["icon"], size: 22, color: colorExt.primary),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Text(
                                    mObj["name"],
                                    style: TextStyle(
                                        color: colorExt.primaryText,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      color: colorExt.placeholder.withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(15)),
                                  child: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: colorExt.secondaryText,)
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            )),
      ),
    );
  }
}
