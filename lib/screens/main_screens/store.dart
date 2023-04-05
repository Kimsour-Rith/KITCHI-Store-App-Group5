import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:multi_store_app/screens/minor_screens/visit_store.dart';
import 'package:multi_store_app/widgets/appbar_widget.dart';
import 'package:multi_store_app/widgets/nextscreen.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEDECF2),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Center(child: AppBarTitle(title: "Store")),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection('suppliers').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var sData = snapshot.data!.docs;
                return GridView.builder(
                    itemCount: sData.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            mainAxisSpacing: 25,
                            crossAxisSpacing: 25,
                            crossAxisCount: 2),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          nextScreen(
                              context,
                              VisitStore(
                                suppId: sData[index]['sid'],
                              ));
                        },
                        child: Column(
                          children: [
                            Stack(children: [
                              SizedBox(
                                height: 120,
                                width: 120,
                                child: Image.asset('images/inapp/store.jpg'),
                              ),
                              Positioned(
                                  bottom: 28,
                                  left: 10,
                                  child: SizedBox(
                                    height: 40,
                                    width: 100,
                                    child: Image.network(
                                        sData[index]['storelogo'],
                                        fit: BoxFit.cover),
                                  ))
                            ]),
                            Text(
                              sData[index]['storename'],
                              style: const TextStyle(
                                  fontSize: 24, fontFamily: 'AkayaTelivigala'),
                            )
                          ],
                        ),
                      );
                    });
              }
              return const Center(
                child: Text("No Store"),
              );
            }),
      ),
    );
  }
}
