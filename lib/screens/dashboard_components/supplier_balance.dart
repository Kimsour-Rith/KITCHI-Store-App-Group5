import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:multi_store_app/screens/main_screens/dashboard.dart';
import '../../widgets/appbar_widget.dart';

class BalanceScreen extends StatelessWidget {
  const BalanceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('sid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
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

          double totalPrice = 0.0;
          for (var item in snapshot.data!.docs) {
            totalPrice += item['orderqty'] * item['orderprice'];
          }

          return Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              title: AppBarTitle(title: 'Balance Screen'),
              leading: const AppBarBackButton(),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  BalanceModel(
                    label: 'total balance',
                    value: totalPrice,
                    decimal: 2,
                  ),
                  const SizedBox(
                    height: 100,
                  ),
                  Container(
                    height: 35,
                    width: MediaQuery.of(context).size.width * 0.9,
                    decoration: BoxDecoration(
                      color: Colors.pink,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: MaterialButton(
                      onPressed: () {},
                      child: const Text(
                        'Get My Money !',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 60,
                  )
                ],
              ),
            ),
          );
        });
  }
}

class BalanceModel extends StatelessWidget {
  final String label;
  final dynamic value;
  final int decimal;
  const BalanceModel({
    super.key,
    required this.label,
    required this.value,
    required this.decimal,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 60,
          width: MediaQuery.of(context).size.width * 0.55,
          decoration: const BoxDecoration(
              color: Color(0xFF4C53A5),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              )),
          child: Center(
            child: Text(label.toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 20)),
          ),
        ),
        Container(
          height: 90,
          width: MediaQuery.of(context).size.width * 0.7,
          decoration: BoxDecoration(
              color: const Color(0xFF4C53A5).withOpacity(0.3),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              )),
          child: AnimatedCounter(
            decimal: decimal,
            count: value,
          ),
        ),
      ],
    );
  }
}

class AnimatedCounter extends StatefulWidget {
  final int decimal;
  final dynamic count;
  const AnimatedCounter(
      {super.key, required this.count, required this.decimal});

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation _animation;
  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _animation = _controller;
    setState(() {
      _animation = Tween(begin: _animation.value, end: widget.count)
          .animate(_controller);
    });
    _controller.forward();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Center(
            child: Text(
              _animation.value.toStringAsFixed(widget.decimal),
              style: const TextStyle(
                  color: Colors.red,
                  fontSize: 40,
                  fontFamily: 'Acme',
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold),
            ),
          );
        });
  }
}
