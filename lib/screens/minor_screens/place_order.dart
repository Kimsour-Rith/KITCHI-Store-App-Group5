import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:multi_store_app/screens/customer_screens/add_address.dart';
import 'package:multi_store_app/screens/customer_screens/address_book.dart';
import 'package:multi_store_app/screens/minor_screens/payment_screen.dart';
import 'package:multi_store_app/widgets/appbar_widget.dart';
import 'package:multi_store_app/widgets/nextscreen.dart';
import 'package:multi_store_app/widgets/yellow_button.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';

class PlaceOrderScreen extends StatefulWidget {
  const PlaceOrderScreen({super.key});

  @override
  State<PlaceOrderScreen> createState() => _PlaceOrderScreenState();
}

class _PlaceOrderScreenState extends State<PlaceOrderScreen> {
  final Stream<QuerySnapshot> addressStream = FirebaseFirestore.instance
      .collection('customers')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('address')
      .where('default', isEqualTo: true)
      .limit(1)
      .snapshots();
  late String name;
  late String phone;
  late String address;
  CollectionReference customers =
      FirebaseFirestore.instance.collection('customers');
  @override
  Widget build(BuildContext context) {
    double totalPrice = context.watch<Cart>().totalPrice;
    return StreamBuilder<QuerySnapshot>(
        stream: addressStream,
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

          return Material(
            color: Colors.grey.shade200,
            child: SafeArea(
              child: Scaffold(
                backgroundColor: Colors.grey.shade100,
                appBar: AppBar(
                  elevation: 0,
                  backgroundColor: Colors.grey.shade100,
                  leading: const AppBarBackButton(),
                  title: AppBarTitle(title: 'Place Order'),
                ),
                body: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 60),
                  child: Column(children: [
                    snapshot.data!.docs.isEmpty
                        ? GestureDetector(
                            onTap: () {
                              nextScreen(context, const AddAddress());
                            },
                            child: Container(
                              height: 120,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15)),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 16),
                                child: Center(
                                  child: Text(
                                    'Please set your Address',
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Acme',
                                        letterSpacing: 1.5,
                                        color: Colors.blueGrey),
                                  ),
                                ),
                              ),
                            ))
                        : GestureDetector(
                            onTap: () {
                              nextScreen(context, const AddressBook());
                            },
                            child: Container(
                              height: 120,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15)),
                              child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 4, horizontal: 16),
                                  child: ListView.builder(
                                      itemCount: snapshot.data!.docs.length,
                                      itemBuilder: (context, index) {
                                        var customer =
                                            snapshot.data!.docs[index];
                                        name = customer['firstname'] +
                                            customer['lastname'];
                                        phone = customer['phone'];
                                        address = customer['country'] +
                                            ' - ' +
                                            customer['state'] +
                                            ' - ' +
                                            customer['city'];

                                        return ListTile(
                                          title: SizedBox(
                                            height: 50,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    '${customer['firstname']} ${customer['lastname']}'),
                                                Text(customer['phone'])
                                              ],
                                            ),
                                          ),
                                          subtitle: SizedBox(
                                            height: 70,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    'city/state : ${customer['city']} ${customer['state']}'),
                                                Text(
                                                    'country : ${customer['country']}')
                                              ],
                                            ),
                                          ),
                                        );
                                      })),
                            ),
                          ),
                    const SizedBox(
                      height: 20,
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15)),
                        child: Consumer<Cart>(builder: (context, cart, child) {
                          return ListView.builder(
                              itemCount: cart.getItems.length,
                              itemBuilder: (context, index) {
                                var order = cart.getItems[index];
                                return Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: Container(
                                    height: 100,
                                    decoration: BoxDecoration(
                                      border: Border.all(width: 0.3),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(15),
                                              bottomLeft: Radius.circular(15)),
                                          child: SizedBox(
                                            height: 100,
                                            width: 100,
                                            child: Image.network(
                                                order.imagesUrl.first),
                                          ),
                                        ),
                                        Flexible(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              Text(
                                                order.name,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        Colors.grey.shade600),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 4,
                                                        horizontal: 12),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      order.price
                                                          .toStringAsFixed(2),
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Colors
                                                              .grey.shade600),
                                                    ),
                                                    Text(
                                                      'x ${order.qty.toString()}',
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Colors
                                                              .grey.shade600),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              });
                        }),
                      ),
                    ),
                  ]),
                ),
                bottomSheet: Container(
                  color: Colors.grey.shade200,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: YellowButton(
                        label: 'Confirm ${totalPrice.toStringAsFixed(2)} USD',
                        onPressed: snapshot.data!.docs.isEmpty
                            ? () {
                                nextScreen(context, const AddressBook());
                              }
                            : () {
                                nextScreen(
                                    context,
                                    PaymentScreen(
                                      name: name,
                                      phone: phone,
                                      address: address,
                                    ));
                              },
                        width: 1),
                  ),
                ),
              ),
            ),
          );
        });
  }
}
