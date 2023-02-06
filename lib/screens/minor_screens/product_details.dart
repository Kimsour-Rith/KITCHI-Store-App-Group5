import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:multi_store_app/screens/main_screens/visit_store.dart';
import 'package:multi_store_app/screens/minor_screens/full_screen_view.dart';
import 'package:multi_store_app/widgets/appbar_widget.dart';
import 'package:multi_store_app/widgets/nextscreen.dart';
import 'package:multi_store_app/widgets/snackbar.dart';
import 'package:multi_store_app/widgets/yellow_button.dart';
import 'package:provider/provider.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_grid_view.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_tile.dart';
import '../main_screens/cart.dart';
import '../../models/product_model.dart';
import 'package:multi_store_app/providers/cart_provider.dart';
import '../../providers/whistlist_provider.dart';
import 'package:badges/badges.dart';

class ProductDetailsScreen extends StatefulWidget {
  final dynamic proList;
  const ProductDetailsScreen({Key? key, required this.proList})
      : super(key: key);

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late List<dynamic> imageList = widget.proList['proimages'];
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    var existingItemInCart = context.read<Cart>().getItems.firstWhereOrNull(
        (product) => product.documentId == widget.proList['proid']);

    late final Stream<QuerySnapshot> _productsStream = FirebaseFirestore
        .instance
        .collection('products')
        .where('maincateg', isEqualTo: widget.proList['maincateg'])
        .where('subcateg', isEqualTo: widget.proList['subcateg'])
        .snapshots();

    var height = MediaQuery.of(context).size.height;
    return Material(
      child: SafeArea(
        child: ScaffoldMessenger(
          key: _scaffoldKey,
          child: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      nextScreen(
                          context,
                          FullScreenView(
                            imagesList: imageList,
                          ));
                    },
                    child: Stack(children: [
                      SizedBox(
                        height: height * 0.5,
                        width: double.maxFinite,
                        child: Swiper(
                            pagination: const SwiperPagination(
                                builder: SwiperPagination.fraction),
                            itemBuilder: (context, index) {
                              return Image(
                                  image: NetworkImage(imageList[index]));
                            },
                            itemCount: imageList.length),
                      ),
                      Positioned(
                          left: 15,
                          top: 20,
                          child: CircleAvatar(
                            backgroundColor: const Color(0xFF4C53A5),
                            child: IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: const Icon(
                                  Icons.arrow_back_ios_new,
                                  color: Colors.white,
                                )),
                          )),
                      Positioned(
                          right: 15,
                          top: 20,
                          child: CircleAvatar(
                            backgroundColor: const Color(0xFF4C53A5),
                            child: IconButton(
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.share,
                                  color: Colors.white,
                                )),
                          ))
                    ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 8, right: 8, bottom: 50, left: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.proList['proname'],
                          style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'USD ',
                                  style: TextStyle(
                                      color: Color(0xFF4C53A5),
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  widget.proList['price'].toStringAsFixed(2),
                                  style: const TextStyle(
                                      color: Color(0xFF4C53A5),
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: () {
                                var existingItemWishlist = context
                                    .read<Wish>()
                                    .getWishItems
                                    .firstWhereOrNull((product) =>
                                        product.documentId ==
                                        widget.proList['proid']);
                                existingItemWishlist != null
                                    ? context
                                        .read<Wish>()
                                        .removeThis(widget.proList['proid'])
                                    : context.read<Wish>().addWishItem(
                                        widget.proList['proname'],
                                        widget.proList['price'],
                                        1,
                                        widget.proList['instock'],
                                        widget.proList['proimages'],
                                        widget.proList['proid'],
                                        widget.proList['sid']);
                              },
                              icon: context
                                          .watch<Wish>()
                                          .getWishItems
                                          .firstWhereOrNull((product) =>
                                              product.documentId ==
                                              widget.proList['proid']) !=
                                      null
                                  ? const Icon(
                                      Icons.favorite,
                                      color: Color(0xFF4C53A5),
                                    )
                                  : const Icon(
                                      Icons.favorite_border_outlined,
                                      color: Color(0xFF4C53A5),
                                    ),
                            ),
                          ],
                        ),
                        widget.proList['instock'] == 0
                            ? const Text(
                                'this item is out of stock',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.blueGrey),
                              )
                            : Text(
                                (widget.proList['instock']).toString() +
                                    (" piecs avaiable in stock"),
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.blueGrey),
                              ),
                        const ProDetailHeader(
                          label: ' Item Description ',
                        ),
                        Text(
                          widget.proList['prodesc'],
                          textScaleFactor: 1.1,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.blueGrey.shade600),
                        ),
                        const ProDetailHeader(
                          label: ' Similar Items ',
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 60),
                    child: SizedBox(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: _productsStream,
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            return const Text('Something went wrong');
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (snapshot.data!.docs.isEmpty) {
                            return const Center(
                              child: Text(
                                'This category \n \n has no item yet',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 26,
                                    color: Color(0xFF4C53A5),
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Acme',
                                    letterSpacing: 1.5),
                              ),
                            );
                          }

                          return SingleChildScrollView(
                            child: StaggeredGridView.countBuilder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: snapshot.data!.docs.length,
                                crossAxisCount: 2,
                                itemBuilder: (context, index) {
                                  return ProductModel(
                                      products: snapshot.data!.docs[index]);
                                },
                                staggeredTileBuilder: (context) =>
                                    const StaggeredTile.fit(1)),
                          );
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
            bottomSheet: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            nextScreen(context,
                                VisitStore(suppId: widget.proList['sid']));
                          },
                          icon: const Icon(Icons.store)),
                      const SizedBox(
                        width: 20,
                      ),
                      IconButton(
                          onPressed: () {
                            nextScreen(
                                context,
                                const CartScreen(
                                  back: AppBarBackButton(),
                                ));
                          },
                          icon: Badge(
                              showBadge: context.read<Cart>().getItems.isEmpty
                                  ? false
                                  : true,
                              badgeStyle: const BadgeStyle(
                                  badgeColor: Color(0xFF4C53A5)),
                              badgeContent: Text(
                                context
                                    .watch<Cart>()
                                    .getItems
                                    .length
                                    .toString(),
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white),
                              ),
                              child: const Icon(Icons.shopping_cart))),
                    ],
                  ),
                  YellowButton(
                      label: existingItemInCart != null
                          ? "Added To Cart"
                          : 'ADD TO CART',
                      onPressed: () {
                        if (widget.proList['instock'] == 0) {
                          MyMessageHandler.showSnackBar(
                              _scaffoldKey, "this item is out of stock");
                        } else if (existingItemInCart != null) {
                          MyMessageHandler.showSnackBar(
                              _scaffoldKey, "This item already in cart");
                        } else {
                          context.read<Cart>().addItem(
                              widget.proList['proname'],
                              widget.proList['price'],
                              1,
                              widget.proList['instock'],
                              widget.proList['proimages'],
                              widget.proList['proid'],
                              widget.proList['sid']);
                        }
                      },
                      width: 0.55)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ProDetailHeader extends StatelessWidget {
  final String label;
  const ProDetailHeader({
    Key? key,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            height: 40,
            width: 50,
            child: Divider(
              color: Color.fromARGB(255, 112, 120, 199),
              thickness: 1,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
                color: Color.fromARGB(255, 112, 120, 199),
                fontSize: 24,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(
            height: 40,
            width: 50,
            child: Divider(
              color: Color.fromARGB(255, 112, 120, 199),
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }
}
