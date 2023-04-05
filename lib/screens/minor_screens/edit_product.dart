import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_store_app/widgets/pink_button.dart';
import 'package:multi_store_app/widgets/snackbar.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:multi_store_app/widgets/yellow_button.dart';
import '../../utilities/categ_list.dart';
import 'package:path/path.dart' as path;

class EditProduct extends StatefulWidget {
  final dynamic items;
  const EditProduct({Key? key, required this.items}) : super(key: key);

  @override
  State<EditProduct> createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
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
  List<dynamic>? imagesUrlList = [];
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
    } else if (value == 'home & garden') {
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
      print(_pickedImageError);
    }
  }

  Future uploadImages() async {
    if (_formkey.currentState!.validate()) {
      _formkey.currentState!.save();
      if (imagesFileList.isNotEmpty) {
        if (mainCategValue != 'select category' &&
            subCategValue != 'subcategory') {
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
              _scaffoldKey, "please select categories");
        }
      } else {
        imagesUrlList = widget.items['proimages'];
      }
    } else {
      MyMessageHandler.showSnackBar(_scaffoldKey, "please fill all fields");
    }
  }

  editProductData() async {
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentReference documentReference = FirebaseFirestore.instance
          .collection('products')
          .doc(widget.items['proid']);
      transaction.update(documentReference, {
        'maincateg': mainCategValue,
        'subcateg': subCategValue,
        'price': price,
        'instock': quantity,
        'proname': proName,
        'prodesc': proDesc,
        'proimages': imagesUrlList,
        'discount': discount,
      });
    }).whenComplete(() {
      Navigator.pop(context);
    });
  }

  saveChanges() async {
    await uploadImages().whenComplete(() {
      editProductData();
    });
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

  Widget previewCurrentImages() {
    List<dynamic> itemImages = widget.items['proimages'];
    return ListView.builder(
        itemCount: itemImages.length,
        itemBuilder: (context, index) {
          return Image.network(itemImages[index].toString());
        });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
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
                      Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                  color:
                                      const Color.fromARGB(255, 216, 232, 245),
                                  height: height * 0.25,
                                  width: width * 0.5,
                                  child: previewCurrentImages()),
                              SizedBox(
                                height: height * 0.25,
                                width: width * 0.5,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Column(
                                      children: [
                                        const Text(
                                          "*main Category",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.all(6),
                                          padding: const EdgeInsets.all(6),
                                          constraints: BoxConstraints(
                                              minWidth: width * 0.3),
                                          decoration: BoxDecoration(
                                              color: const Color(0xFF4C53A5),
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: Center(
                                              child: Text(
                                            widget.items['maincateg'],
                                            style: const TextStyle(
                                                color: Colors.white),
                                          )),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        const Text(
                                          "*subcategory",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.all(6),
                                          padding: const EdgeInsets.all(6),
                                          constraints: BoxConstraints(
                                              minWidth: width * 0.3),
                                          decoration: BoxDecoration(
                                              color: const Color(0xFF4C53A5),
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: Center(
                                              child: Text(
                                            widget.items['subcateg'],
                                            style: const TextStyle(
                                                color: Colors.white),
                                          )),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                          ExpandablePanel(
                              theme: const ExpandableThemeData(hasIcon: false),
                              header: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: const Color(0xFF4C53A5),
                                      borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.all(6),
                                  child: const Center(
                                    child: Text(
                                      'Change Images & Categories',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              collapsed: const SizedBox(),
                              expanded: changeImages(size)),
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
                                      initialValue: widget.items['price']
                                          .toStringAsFixed(2),
                                      validator: ((value) {
                                        if (value!.isEmpty) {
                                          return 'please enter price';
                                        } else if (value.isValidPrice() !=
                                            true) {
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
                                      initialValue:
                                          widget.items['discount'].toString(),
                                      maxLength: 2,
                                      validator: ((value) {
                                        if (value!.isEmpty) {
                                          return null;
                                        } else if (value.isValidDiscount() !=
                                            true) {
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
                                  initialValue:
                                      widget.items['instock'].toString(),
                                  validator: ((value) {
                                    if (value!.isEmpty) {
                                      return 'please enter quantity';
                                    } else if (value.isValidQuantity() !=
                                        true) {
                                      return 'not valid quantity';
                                    }
                                    return null;
                                  }),
                                  onSaved: (value) {
                                    quantity = int.parse(value!);
                                  },
                                  keyboardType: TextInputType.number,
                                  decoration: textFormDecoration.copyWith(
                                      labelText: 'Quantity',
                                      hintText: 'Add Quantity')),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: width,
                              child: TextFormField(
                                  initialValue: widget.items['proname'],
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
                                  initialValue: widget.items['prodesc'],
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
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  YellowButton(
                                      label: 'Cancel',
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      width: 0.25),
                                  YellowButton(
                                      label: 'Save Changes',
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      width: 0.5)
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: PinkButton(
                                    label: 'Delete Item',
                                    onPressed: () async {
                                      await FirebaseFirestore.instance
                                          .runTransaction((transaction) async {
                                        DocumentReference documentReference =
                                            FirebaseFirestore.instance
                                                .collection('products')
                                                .doc(widget.items['proid']);
                                        transaction.delete(documentReference);
                                      }).whenComplete(
                                              () => Navigator.pop(context));
                                    },
                                    width: 0.7),
                              )
                            ],
                          )
                        ],
                      ),
                    ]),
              ),
            ),
          ),
        ));
  }

  void pickProductImages() async {
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
      print(_pickedImageError);
    }
  }

  Widget changeImages(Size size) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              color: const Color.fromARGB(255, 216, 232, 245),
              height: size.height * 0.25,
              width: size.width * 0.5,
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
              height: size.height * 0.25,
              width: size.width * 0.5,
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
                          items: maincateg.map<DropdownMenuItem<String>>((val) {
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
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: imagesFileList.isNotEmpty
              ? YellowButton(
                  label: 'Reset Image',
                  onPressed: () {
                    setState(() {
                      imagesFileList = [];
                    });
                  },
                  width: 0.6)
              : YellowButton(
                  label: 'Change Image',
                  onPressed: () {
                    pickProductImages();
                  },
                  width: 0.6),
        )
      ],
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
