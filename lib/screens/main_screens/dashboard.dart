import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:multi_store_app/screens/dashboard_components/edit_business.dart';
import 'package:multi_store_app/screens/dashboard_components/manage_product.dart';
import 'package:multi_store_app/screens/dashboard_components/my_store.dart';
import 'package:multi_store_app/screens/dashboard_components/supplier_balance.dart';
import 'package:multi_store_app/screens/dashboard_components/supplier_orders.dart';
import 'package:multi_store_app/screens/dashboard_components/supplier_statics.dart';
import 'package:multi_store_app/screens/minor_screens/visit_store.dart';
import 'package:multi_store_app/widgets/appbar_widget.dart';
import 'package:multi_store_app/widgets/nextscreen.dart';

import '../../widgets/alert_dialog.dart';

List<String> label = [
  'my store',
  'orders',
  'edit profile',
  'manage products',
  'balance',
  'statics'
];

List<IconData> icons = [
  Icons.store,
  Icons.shop_2_outlined,
  Icons.edit,
  Icons.settings,
  Icons.attach_money,
  Icons.show_chart
];

List<Widget> pages = [
  VisitStore(suppId: FirebaseAuth.instance.currentUser!.uid),
  const SupplierOrders(),
  const EditBusiness(),
  const ManageProduct(),
  const BalanceScreen(),
  const SupplierStaticScreen()
];

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: AppBarTitle(title: 'Dashboard'),
        actions: [
          IconButton(
            onPressed: () {
              MyAlertDilaog.showMyDialog(
                  context: context,
                  title: 'Log Out',
                  content: 'Are you sure to log out ?',
                  tabNo: () {
                    Navigator.pop(context);
                  },
                  tabYes: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, '/welcome_screen');
                  });
            },
            icon: const Icon(Icons.logout),
            color: Colors.black,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: GridView.count(
            mainAxisSpacing: 50,
            crossAxisSpacing: 50,
            crossAxisCount: 2,
            children: List.generate(6, (index) {
              return InkWell(
                onTap: () {
                  nextScreen(context, pages[index]);
                },
                child: Card(
                  color: Colors.blueGrey.withOpacity(0.7),
                  shadowColor: Colors.purpleAccent.shade200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Icon(
                        icons[index],
                        size: 50,
                        color: Colors.yellowAccent,
                      ),
                      Text(
                        label[index].toUpperCase(),
                        style: const TextStyle(
                            fontSize: 24,
                            color: Colors.yellowAccent,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2,
                            fontFamily: 'Acme'),
                      )
                    ],
                  ),
                ),
              );
            })),
      ),
    );
  }
}
