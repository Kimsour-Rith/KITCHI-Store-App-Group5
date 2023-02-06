import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:multi_store_app/screens/main_screens/category.dart';
import 'package:multi_store_app/screens/main_screens/dashboard.dart';
import 'package:multi_store_app/screens/main_screens/home.dart';
import 'package:multi_store_app/screens/main_screens/store.dart';
import 'package:multi_store_app/screens/main_screens/upload_product.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';

class SupplierHomeScreen extends StatefulWidget {
  const SupplierHomeScreen({Key? key}) : super(key: key);

  @override
  State<SupplierHomeScreen> createState() => _SupplierHomeScreenState();
}

class _SupplierHomeScreenState extends State<SupplierHomeScreen> {
  int _selectedIndex = 0;
  final List<Widget> _tabs = [
    const HomeScreen(),
    const CategoryScreen(),
    const StoreScreen(),
    const DashboardScreen(),
    const UploadProductScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> _productsStream = FirebaseFirestore.instance
        .collection('orders')
        .where('sid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .where('deliverystatus', isEqualTo: 'preparing')
        .snapshots();
    return StreamBuilder<QuerySnapshot>(
      stream: _productsStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Material(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        return Scaffold(
          body: _tabs[_selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
            selectedItemColor: const Color(0xFF4C53A5),
            unselectedItemColor: Colors.grey,
            currentIndex: _selectedIndex,
            items: [
              const BottomNavigationBarItem(
                  icon: Icon(Icons.home), label: 'Home'),
              const BottomNavigationBarItem(
                  icon: Icon(Icons.search), label: 'Category'),
              const BottomNavigationBarItem(
                  icon: Icon(Icons.shop), label: 'Stores'),
              BottomNavigationBarItem(
                  icon: Badge(
                      showBadge: snapshot.data!.docs.isEmpty ? false : true,
                      badgeStyle:
                          const BadgeStyle(badgeColor: Color(0xFF4C53A5)),
                      badgeContent: Text(
                        snapshot.data!.docs.length.toString(),
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                      child: const Icon(Icons.dashboard)),
                  label: 'Dashboard'),
              const BottomNavigationBarItem(
                  icon: Icon(Icons.upload), label: 'Upload')
            ],
            onTap: ((index) {
              setState(() {
                _selectedIndex = index;
              });
            }),
          ),
        );
      },
    );
  }
}
