import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:multi_store_app/widgets/appbar_widget.dart';
import 'package:multi_store_app/widgets/nextscreen.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_grid_view.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_tile.dart';

import '../../models/product_model.dart';
import 'edit_store.dart';

class VisitStore extends StatefulWidget {
  final String suppId;
  const VisitStore({Key? key, required this.suppId}) : super(key: key);

  @override
  State<VisitStore> createState() => _VisitStoreState();
}

class _VisitStoreState extends State<VisitStore> {
  bool following = false;
  @override
  Widget build(BuildContext context) {
    CollectionReference suppliers =
        FirebaseFirestore.instance.collection('suppliers');
    final Stream<QuerySnapshot> _productsStream = FirebaseFirestore.instance
        .collection('products')
        .where('sid', isEqualTo: widget.suppId)
        .snapshots();

    final currentSupplier = FirebaseAuth.instance.currentUser!.uid;

    return FutureBuilder<DocumentSnapshot>(
      future: suppliers.doc(widget.suppId).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text("Something went wrong");
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Material(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {}

        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          return Scaffold(
            appBar: AppBar(
              leading: const AppBarPurpleBackButton(),
              flexibleSpace: data['coverimage'] == ''
                  ? Image.asset("images/inapp/coverimage.jpg",
                      fit: BoxFit.cover)
                  : Image.network(data['coverimage'], fit: BoxFit.cover),
              toolbarHeight: 100,
              title: Row(
                children: [
                  Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      border:
                          Border.all(width: 4, color: const Color(0xFF4C53A5)),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: Image.network(
                        data['storelogo'],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 100,
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(data['storename'].toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 20,
                                  )),
                            ),
                          ],
                        ),
                        data['sid'] == currentSupplier
                            ? Container(
                                height: 35,
                                width: MediaQuery.of(context).size.width * 0.3,
                                decoration: BoxDecoration(
                                    color: const Color(0xFF4C53A5),
                                    border: Border.all(
                                        width: 1, color: Colors.white),
                                    borderRadius: BorderRadius.circular(25)),
                                child: MaterialButton(
                                  onPressed: () {
                                    nextScreen(
                                        context,
                                        EditStore(
                                          data: data,
                                        ));
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: const [
                                      Text(
                                        'EDIT',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                      )
                                    ],
                                  ),
                                ))
                            : Container(
                                height: 35,
                                width: MediaQuery.of(context).size.width * 0.3,
                                decoration: BoxDecoration(
                                    color: const Color(0xFF4C53A5),
                                    border: Border.all(
                                        width: 1, color: Colors.white),
                                    borderRadius: BorderRadius.circular(25)),
                                child: MaterialButton(
                                  onPressed: () {
                                    setState(() {
                                      following = !following;
                                    });
                                  },
                                  child: following == true
                                      ? const Text("Following",
                                          style: TextStyle(color: Colors.white))
                                      : const Text(
                                          "FOLLOW",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                ))
                      ],
                    ),
                  )
                ],
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: StreamBuilder<QuerySnapshot>(
                stream: _productsStream,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
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

                  if (snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'This store \n \n has no product available yet',
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
            floatingActionButton: FloatingActionButton(
              onPressed: () {},
              backgroundColor: Colors.green,
              child: const Icon(
                FontAwesomeIcons.whatsapp,
                color: Colors.white,
                size: 40,
              ),
            ),
          );
        }

        return const Text("loading");
      },
    );
  }
}
