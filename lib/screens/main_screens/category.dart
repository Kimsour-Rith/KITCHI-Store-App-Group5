import 'package:flutter/material.dart';
import 'package:multi_store_app/screens/categories/accessory_category.dart';
import 'package:multi_store_app/screens/categories/bags_category.dart';
import 'package:multi_store_app/screens/categories/beauty_category.dart';
import 'package:multi_store_app/screens/categories/electronic_category.dart';
import 'package:multi_store_app/screens/categories/home_garden.dart';
import 'package:multi_store_app/screens/categories/kids_category.dart';
import 'package:multi_store_app/screens/categories/men_category.dart';
import 'package:multi_store_app/screens/categories/shoe_category.dart';
import 'package:multi_store_app/screens/categories/women_category.dart';
import 'package:multi_store_app/widgets/fake_search.dart';

List<ItemsData> items = [
  ItemsData(label: 'men'),
  ItemsData(label: 'women'),
  ItemsData(label: 'shoes'),
  ItemsData(label: 'bags'),
  ItemsData(label: 'electronics'),
  ItemsData(label: 'accessories'),
  ItemsData(label: 'home & gargen'),
  ItemsData(label: 'kids'),
  ItemsData(label: 'beauty'),
];

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  @override
  void initState() {
    for (var element in items) {
      element.isSelected = false;
    }
    setState(() {
      items[0].isSelected = true;
    });
    super.initState();
  }

  final PageController _pageController = PageController();
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const FakeSearch(),
      ),
      body: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            child: sideNavigator(size),
          ),
          Positioned(bottom: 0, right: 0, child: cateView(size))
        ],
      ),
    );
  }

  Widget sideNavigator(Size size) {
    return SizedBox(
      height: size.height * 0.78,
      width: size.width * 0.2,
      child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                _pageController.animateToPage(index,
                    duration: Duration(microseconds: 100),
                    curve: Curves.bounceInOut);
              },
              child: Container(
                  color: items[index].isSelected == true
                      ? Colors.white
                      : Colors.grey.shade300,
                  height: 100,
                  child: Center(child: Text(items[index].label))),
            );
          }),
    );
  }

  Widget cateView(Size size) {
    return Container(
      height: size.height * 0.85,
      width: size.width * 0.8,
      color: Colors.white,
      child: PageView(
        controller: _pageController,
        onPageChanged: ((value) {
          for (var element in items) {
            element.isSelected = false;
          }
          setState(() {
            items[value].isSelected = true;
          });
        }),
        scrollDirection: Axis.vertical,
        children: [
          MenCategory(),
          WomenCategory(),
          ShoeCategory(),
          BagCategory(),
          ElectronicCategory(),
          AccessoryCategory(),
          HomeAndGardenCategory(),
          KidsCategory(),
          BeautyCategory(),
        ],
      ),
    );
  }
}

class ItemsData {
  String label;
  bool isSelected;
  ItemsData({required this.label, this.isSelected = false});
}
