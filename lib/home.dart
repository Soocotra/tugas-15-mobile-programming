import 'package:tugas_15/location_service.dart';
import 'package:tugas_15/location_model.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tugas_15/main.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Container(
          width: MediaQuery.of(context).size.width,
          height: 230,
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              border: Border.all(color: Colors.black.withOpacity(0.6))),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: locPermission
                ? GoogleMap(
                    zoomControlsEnabled: false,
                    zoomGesturesEnabled: true,
                    tiltGesturesEnabled: true,
                    trafficEnabled: true,
                    onMapCreated: (controller) async {
                      List<NearbyLocation> nearbies = await MyLocation()
                          .getNearbyLodging(LatLng(
                              userPosition.latitude, userPosition.longitude));

                      print(nearbies[2].photo);
                    },
                    initialCameraPosition: CameraPosition(
                        target: LatLng(
                            userPosition.latitude, userPosition.longitude),
                        zoom: 14),
                    myLocationEnabled: true,
                    circles: {
                      Circle(
                          circleId: const CircleId('user'),
                          fillColor: Colors.blue.shade300.withOpacity(0.7),
                          center: LatLng(
                              userPosition.latitude, userPosition.longitude),
                          radius: 500,
                          strokeColor: Colors.transparent)
                    },
                  )
                : GestureDetector(
                    onTap: () async {
                      locPermission =
                          await MyLocation().handleLocationPermission();
                    },
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: const Center(
                          child: Text(
                        'Izinkan layanan lokasi',
                        style: TextStyle(color: Colors.white),
                      )),
                    ),
                  ),
          ),
        ),
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Selamat datang',
            style: TextStyle(fontSize: 24, color: Colors.black),
          ),
        ),
        // backgroundColor: const Color(0xff1F1F29),
        body: ListView(
          physics: BouncingScrollPhysics(),
          children: [
            const SizedBox(
              height: 20,
            ),
            const SizedBox(
              height: 30,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Kost-Kostan terdekat',
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            locPermission
                ? lodgeCards()
                : GestureDetector(
                    onTap: () async {
                      locPermission =
                          await MyLocation().handleLocationPermission();
                    },
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: const Center(
                          child: Text(
                        'Izinkan layanan lokasi',
                        style: TextStyle(color: Colors.white),
                      )),
                    ),
                  ),
            const SizedBox(
              height: 30,
            )
          ],
        ),
      ),
    );
  }

  Widget lodgeCards() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 250.0),
      child: FutureBuilder<List<NearbyLocation>>(
          future: MyLocation().getNearbyLodging(
              LatLng(userPosition.latitude, userPosition.longitude)),
          builder: (context, snapshot) {
            print(snapshot.connectionState);
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              );
            }
            snapshot.data?.sort((b, a) => Geolocator.distanceBetween(
                    userPosition.latitude,
                    userPosition.longitude,
                    b.latLng!.latitude,
                    b.latLng!.longitude)
                .compareTo(Geolocator.distanceBetween(
                    userPosition.latitude,
                    userPosition.longitude,
                    a.latLng!.latitude,
                    a.latLng!.longitude)));
            return ListView.separated(
              separatorBuilder: (context, index) => const SizedBox(
                height: 20,
              ),
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              shrinkWrap: true,
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) => GestureDetector(
                onTap: () async {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  );
                  var url =
                      await MyLocation().getUrl(snapshot.data![index].placeId);
                  if (await canLaunchUrl(Uri.parse(url))) {
                    Navigator.pop(context);
                    await launchUrl(Uri.parse(url));
                  } else {
                    // ignore: use_build_context_synchronously
                    Navigator.pop(context);
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Gagal membuka snackbar')));
                  }
                },
                child: SizedBox(
                  width: 200,
                  height: 300,
                  child: Stack(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 300,
                        child: Card(
                          shape: ContinuousRectangleBorder(
                              borderRadius: BorderRadius.circular(50)),
                          elevation: 10,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: snapshot.data?[index].photo != null
                                ? Image.network(
                                    snapshot.data![index].photo!,
                                    fit: BoxFit.fill,
                                  )
                                : const Center(child: Icon(Icons.broken_image)),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height / 6,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  colors: [
                                    Colors.black,
                                    Colors.black.withOpacity(0.8),
                                    Colors.transparent,
                                  ],
                                  end: Alignment.topCenter,
                                  begin: Alignment.bottomCenter),
                              borderRadius: BorderRadius.circular(20)),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        snapshot.data![index].name,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    Text(
                                      snapshot.data![index].isOpen
                                          ? 'Buka'
                                          : 'Tutup',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: snapshot.data![index].isOpen
                                              ? Colors.green
                                              : Colors.red,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  snapshot.data![index].address.toString(),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Text(
                                  '${Geolocator.distanceBetween(userPosition.latitude, userPosition.longitude, snapshot.data?[index].latLng?.latitude ?? 0, snapshot.data?[index].latLng?.longitude ?? 0).round() / 1000} KM',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }
}
