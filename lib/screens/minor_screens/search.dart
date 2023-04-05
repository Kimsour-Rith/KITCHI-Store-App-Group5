import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:multi_store_app/screens/minor_screens/product_details.dart';
import 'package:multi_store_app/widgets/nextscreen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late String searchInput = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios),
            color: Colors.black,
          ),
          title: CupertinoSearchTextField(
            onChanged: (value) {
              setState(() {
                searchInput = value;
              });
            },
          ),
        ),
        body: searchInput == ''
            ? Center(
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.lightBlue,
                      borderRadius: BorderRadius.circular(25)),
                  height: 30,
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Icon(
                          Icons.search,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Search for anything...',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              )
            : StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('products')
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final result = snapshot.data!.docs.where((e) =>
                      e['proname'.toLowerCase()]
                          .contains(searchInput.toLowerCase()));
                  return ListView(
                    children: result.map((e) => SearchModel(e: e)).toList(),
                  );
                }));
  }
}

class SearchModel extends StatelessWidget {
  final dynamic e;
  const SearchModel({super.key, required this.e});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        nextScreen(context, ProductDetailsScreen(proList: e));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(12)),
          height: 100,
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    height: 100,
                    width: 100,
                    child: Image(
                      image: NetworkImage(e['proimages'][0]),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Flexible(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      e['proname'],
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.w600),
                    ),
                    Text(
                      e['prodesc'],
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
