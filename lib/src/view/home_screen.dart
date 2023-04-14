import 'dart:math';
import 'package:flutter/material.dart';
import '../app_utils.dart';
import 'package:provider/provider.dart';
import '../providers/home_provider.dart';
import '../model/location_model.dart';
import 'map_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeProvider(),
      child: Scaffold(body: SafeArea(
        child: Consumer<HomeProvider>(builder: (context, hp, child) {
          hp.determinePosition();
          if (hp.address.isEmpty) {
            hp.getAddresses();
          }
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              appBar(context, hp),
              const SizedBox(
                height: 50,
              ),
              if (hp.address.isEmpty)
                Container(
                  alignment: Alignment.center,
                  height: 150,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text("No Address Found "),
                      const Spacer(),
                      btnAdd(context),
                      const SizedBox(
                        height: 50,
                      ),
                    ],
                  ),
                ),
              if (hp.address.isNotEmpty)
                Column(
                  children: [
                    ListView.builder(
                        shrinkWrap: true,
                        itemCount: hp.address.length,
                        itemBuilder: (context, index) {
                          return addressView(hp.address[index], context);
                        }),
                    btnAdd(context),
                  ],
                )
            ],
          );
        }),
      )),
    );
  }

  addressView(Address address, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 150,
        padding: const EdgeInsets.all(5),
        width: 100,
        decoration: AppConstants.boxBorderDecoration,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: const [Icon(Icons.my_location_sharp), Spacer()],
              ),
              const SizedBox(width: 10),
              addDetails(address, context)
            ],
          ),
        ),
      ),
    );
  }

  addDetails(Address address, BuildContext context) {
    // print(address.toJSON());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Text(
            address.title!,
            textAlign: TextAlign.right,
            maxLines: 1,
            style: const TextStyle(
                color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 4),
        normal(
            "${address.street},${address.locality},${address.subAdminArea},${address.adminArea},${address.country},${address.postalCode}",
            context)
      ],
    );
  }

  normal(String txt, BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.75,
      height: 90,
      child: Text(
        txt,
        maxLines: 5,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          wordSpacing: 10,
          color: Colors.black,
          fontSize: 15,
        ),
      ),
    );
  }

  // btnRow() {
  //   Row(
  //     children: [
        
  //     ],
  //   );

  // }

  btnAdd(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const MapScreen(), maintainState: false),
        );
      },
      child: Container(
        width: 300,
        decoration: BoxDecoration(
            border: Border.all(
                color: Colors.green, style: BorderStyle.solid, width: 2)),
        child: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Center(
            child: Text(
              "Add new address",
              style: TextStyle(color: Colors.green),
            ),
          ),
        ),
      ),
    );
  }

  appBar(BuildContext context, HomeProvider hp) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FutureBuilder<Address>(
        future: hp.getLocation(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(snapshot.data!.name!,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.right),
                      Transform.rotate(
                          angle: pi / 2 * 3,
                          child: const Icon(
                            Icons.arrow_back_ios,
                            size: 10,
                          ))
                    ],
                  ),
                  Text(
                      "${snapshot.data!.street},${snapshot.data!.adminArea},${snapshot.data!.country}",
                      textAlign: TextAlign.right),
                ],
              ),
            );
          } else {
            return const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                ":)Loading...",
              ),
            );
          }
        },
      ),
    );
  }
}
