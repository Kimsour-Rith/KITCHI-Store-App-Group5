import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_store_app/widgets/snackbar.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import '../../utilities/categ_list.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

class UploadProductScreen extends StatefulWidget {
  const UploadProductScreen({Key? key}) : super(key: key);

  @override
  State<UploadProductScreen> createState() => _UploadProductScreenState();
}

class _UploadProductScreenState extends State<UploadProductScreen> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();

  late double price;
  late int quantity;
  late String proName;
  late String proDesc;
  late String proId;
  int? discount = 0;
  String mainCategValue = 'select category';
  String subCategValue = 'subcategory';
  List<String> subCategList = [];
  bool processing = false;

  final ImagePicker _picker = ImagePicker();

  List<XFile> imagesFileList = [];
  List<String>? imagesUrlList = [];
  dynamic _pickedImageError;

  void selectedMainCateg(value) {
    if (value == 'select category') {
      subCategList = [];
    } else if (value == 'men') {
      subCategList = men;
    } else if (value == 'women') {
      subCategList = women;
    } else if (value == 'electronics') {
      subCategList = electronics;
    } else if (value == 'accessories') {
      subCategList = accessories;
    } else if (value == 'shoes') {
      subCategList = shoes;
    } else if (value == 'homeandgarden') {
      subCategList = homeandgarden;
    } else if (value == 'beauty') {
      subCategList = beauty;
    } else if (value == 'kids') {
      subCategList = kids;
    } else if (value == 'bags') {
      subCategList = bags;
    }
    setState(() {
      mainCategValue = value.toString();
      subCategValue = 'subcategory';
    });
  }

  void _pickProductImages() async {
    try {
      final pickedImages = await _picker.pickMultiImage(
          maxHeight: 300, maxWidth: 300, imageQuality: 95);
      setState(() {
        imagesFileList = pickedImages;
      });
    } catch (e) {
      setState(() {
        _pickedImageError = e;
      });
    }
  }

  Future<void> uploadImages() async {
    if (mainCategValue != 'select category' && subCategValue != 'subcategory') {
      if (_formkey.currentState!.validate()) {
        _formkey.currentState!.save();
        if (imagesFileList.isNotEmpty) {
          setState(() {
            processing = true;
          });
          try {
            for (var image in imagesFileList) {
              firebase_storage.Reference ref = firebase_storage
                  .FirebaseStorage.instance
                  .ref('products/${path.basename(image.path)}');
              await ref.putFile(File(image.path)).whenComplete(() async {
                await ref.getDownloadURL().then((value) {
                  imagesUrlList!.add(value);
                });
              });
            }
          } catch (e) {
            print(e);
          }
        } else {
          MyMessageHandler.showSnackBar(
              _scaffoldKey, "please pick images first");
        }
      } else {
        MyMessageHandler.showSnackBar(_scaffoldKey, "please fill all fields");
      }
    } else {
      MyMessageHandler.showSnackBar(_scaffoldKey, "please select categories");
    }
  }

  void uploadData() async {
    if (imagesUrlList!.isNotEmpty) {
      CollectionReference productRef =
          FirebaseFirestore.instance.collection("products");
      proId = const Uuid().v4();
      await productRef.doc(proId).set({
        'proid': proId,
        'maincateg': mainCategValue,
        'subcateg': subCategValue,
        'price': price,
        'instock': quantity,
        'proname': proName,
        'prodesc': proDesc,
        'sid': FirebaseAuth.instance.currentUser!.uid,
        'proimages': imagesUrlList,
        'discount': discount,
      }).whenComplete(() {
        setState(() {
          processing = false;
          imagesFileList = [];
          mainCategValue = 'select category';
          subCategValue = 'subcategory';
          subCategList = [];
          imagesUrlList = [];
        });
        _formkey.currentState!.reset();
      });
    } else {
      print("no images");
    }
  }

  void uploadProduct() async {
    await uploadImages().whenComplete(() => uploadData());
  }

  Widget previewImages() {
    if (imagesFileList.isNotEmpty) {
      return ListView.builder(
          itemCount: imagesFileList.length,
          itemBuilder: (context, index) {
            return Image.file(File(imagesFileList[index].path));
          });
    } else {
      return const Center(
        child: Text(
          "You have not \n \n picked images yet!",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return ScaffoldMessenger(
      key: _scaffoldKey,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            reverse: true,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Form(
              key: _formkey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        color: const Color.fromARGB(255, 216, 232, 245),
                        height: height * 0.25,
                        width: width * 0.5,
                        child: imagesFileList.isNotEmpty
                            ? previewImages()
                            : const Center(
                                child: Text(
                                  "You have not \n \n picked images yet!",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                      ),
                      SizedBox(
                        height: height * 0.25,
                        width: width * 0.5,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                const Text(
                                  "* Select main Category",
                                  style: TextStyle(color: Colors.red),
                                ),
                                DropdownButton(
                                    iconSize: 40,
                                    iconEnabledColor: const Color(0xFF4C53A5),
                                    dropdownColor: Colors.purple.shade50,
                                    iconDisabledColor: Colors.black,
                                    menuMaxHeight: 500,
                                    value: mainCategValue,
                                    items: maincateg
                                        .map<DropdownMenuItem<String>>((val) {
                                      return DropdownMenuItem(
                                        child: Text(val),
                                        value: val,
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      selectedMainCateg(value);
                                    }),
                              ],
                            ),
                            Column(
                              children: [
                                const Text(
                                  "* select subcategory",
                                  style: TextStyle(color: Colors.red),
                                ),
                                DropdownButton(
                                    iconSize: 40,
                                    iconEnabledColor: const Color(0xFF4C53A5),
                                    dropdownColor: Colors.purple.shade50,
                                    iconDisabledColor: Colors.black,
                                    menuMaxHeight: 500,
                                    disabledHint: const Text("select category"),
                                    value: subCategValue,
                                    items: subCategList
                                        .map<DropdownMenuItem<String>>((value) {
                                      return DropdownMenuItem(
                                        child: Text(value),
                                        value: value,
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        subCategValue = value.toString();
                                      });
                                    })
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                    child: Divider(
                      color: Color(0xFF4C53A5),
                      thickness: 1.5,
                    ),
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: width * 0.4,
                          child: TextFormField(
                              validator: ((value) {
                                if (value!.isEmpty) {
                                  return 'please enter price';
                                } else if (value.isValidPrice() != true) {
                                  return 'invalid price';
                                }
                                return null;
                              }),
                              onSaved: (value) {
                                price = double.parse(value!);
                              },
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              decoration: textFormDecoration.copyWith(
                                  labelText: 'price..\$',
                                  hintText: 'price..\$')),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SizedBox(
                          width: width * 0.4,
                          child: TextFormField(
                              maxLength: 2,
                              validator: ((value) {
                                if (value!.isEmpty) {
                                  return null;
                                } else if (value.isValidDiscount() != true) {
                                  return 'invalid discount';
                                }
                                return null;
                              }),
                              onSaved: (value) {
                                discount = int.parse(value!);
                              },
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              decoration: textFormDecoration.copyWith(
                                  labelText: 'discount',
                                  hintText: 'discount..%')),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: width * 0.45,
                      child: TextFormField(
                          validator: ((value) {
                            if (value!.isEmpty) {
                              return 'please enter quantity';
                            } else if (value.isValidQuantity() != true) {
                              return 'not valid quantity';
                            }
                            return null;
                          }),
                          onSaved: (value) {
                            quantity = int.parse(value!);
                          },
                          keyboardType: TextInputType.number,
                          decoration: textFormDecoration.copyWith(
                              labelText: 'Quantity', hintText: 'Add Quantity')),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: width,
                      child: TextFormField(
                          validator: ((value) {
                            if (value!.isEmpty) {
                              return 'please enter product name';
                            }
                            return null;
                          }),
                          onSaved: (value) {
                            proName = value!;
                          },
                          maxLength: 100,
                          maxLines: 3,
                          decoration: textFormDecoration.copyWith(
                              labelText: 'product name',
                              hintText: 'Enter product name')),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: width,
                      child: TextFormField(
                          validator: ((value) {
                            if (value!.isEmpty) {
                              return 'please enter product description';
                            }
                            return null;
                          }),
                          onSaved: (value) {
                            proDesc = value!;
                          },
                          maxLength: 800,
                          maxLines: 5,
                          decoration: textFormDecoration.copyWith(
                              labelText: 'product description',
                              hintText: 'Enter product description')),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: FloatingActionButton(
                onPressed: () {
                  setState(() {
                    imagesFileList = [];
                  });
                },
                backgroundColor: const Color(0xFF4C53A5),
                child: const Icon(
                  Icons.delete_forever,
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: FloatingActionButton(
                  onPressed: () {
                    _pickProductImages();
                  },
                  backgroundColor: const Color(0xFF4C53A5),
                  child: const Icon(
                    Icons.photo_library,
                    color: Colors.white,
                  )),
            ),
            FloatingActionButton(
              onPressed: processing == true
                  ? null
                  : () {
                      uploadProduct();
                    },
              backgroundColor: const Color(0xFF4C53A5),
              child: processing == true
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : const Icon(
                      Icons.upload,
                      color: Colors.white,
                    ),
            )
          ],
        ),
      ),
    );
  }
}

var textFormDecoration = InputDecoration(
    labelText: 'price',
    hintText: 'price..\$',
    fillColor: const Color(0xFF4C53A5),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF4C53A5), width: 1)),
    focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF4C53A5), width: 1),
        borderRadius: BorderRadius.circular(10)));

extension QuantityValidator on String {
  bool isValidQuantity() {
    return RegExp(r'^[1-9][0-9]*$').hasMatch(this);
  }
}

extension PriceValidator on String {
  bool isValidPrice() {
    return RegExp(r'^((([1-9][0-9]*[\.]*)||[0][\.]*))([0-9]{1,2})$')
        .hasMatch(this);
  }
}

extension DiscountValidator on String {
  bool isValidDiscount() {
    return RegExp(r'^([0-9]*)$').hasMatch(this);
  }
}
