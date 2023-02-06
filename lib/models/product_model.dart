import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:multi_store_app/widgets/nextscreen.dart';
import 'package:provider/provider.dart';

import '../screens/minor_screens/product_details.dart';
import '../providers/whistlist_provider.dart';

class ProductModel extends StatefulWidget {
  final dynamic products;
  const ProductModel({
    Key? key,
    this.products,
  }) : super(key: key);

  @override
  State<ProductModel> createState() => _ProductModelState();
}

class _ProductModelState extends State<ProductModel> {
  late var existingItemWishlist = context
      .read<Wish>()
      .getWishItems
      .firstWhereOrNull(
          (product) => product.documentId == widget.products['proid']);
  @override
  Widget build(BuildContext context) {
    final currentSupplier = FirebaseAuth.instance.currentUser!.uid;
    return InkWell(
      onTap: () {
        nextScreen(
            context,
            ProductDetailsScreen(
              proList: widget.products,
            ));
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                child: Container(
                  constraints:
                      const BoxConstraints(minHeight: 100, maxHeight: 250),
                  child: Image(
                      image: NetworkImage(widget.products['proimages'][0])),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      widget.products['proname'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.products['price'].toStringAsFixed(2) + (' \$'),
                          style: const TextStyle(
                              color: Color(0xFF4C53A5),
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                        widget.products['sid'] == currentSupplier
                            ? IconButton(
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.edit,
                                  color: Color(0xFF4C53A5),
                                ),
                              )
                            : IconButton(
                                onPressed: () {
                                  existingItemWishlist != null
                                      ? context
                                          .read<Wish>()
                                          .removeThis(widget.products['proid'])
                                      : context.read<Wish>().addWishItem(
                                          widget.products['proname'],
                                          widget.products['price'],
                                          1,
                                          widget.products['instock'],
                                          widget.products['proimages'],
                                          widget.products['proid'],
                                          widget.products['sid']);
                                },
                                icon: context
                                            .watch<Wish>()
                                            .getWishItems
                                            .firstWhereOrNull((product) =>
                                                product.documentId ==
                                                widget.products['proid']) !=
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
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
