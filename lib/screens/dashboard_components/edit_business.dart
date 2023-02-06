import 'package:flutter/material.dart';

import '../../widgets/appbar_widget.dart';

class EditBusiness extends StatelessWidget {
  const EditBusiness({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: AppBarTitle(title: 'Edit Business'),
        leading: const AppBarBackButton(),
      ),
    );
  }
}
