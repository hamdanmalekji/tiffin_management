import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tiffin_app/common/common_dropdown.dart';
import 'package:tiffin_app/common/io_lib.dart';
import 'package:tiffin_app/firebase/firebridge.dart';
import 'package:tiffin_app/home_page.dart';
import 'package:tiffin_app/models/test_model.dart';
import 'package:tiffin_app/tiffins_page.dart';

import 'common/font_style.dart';
import 'firebase_options.dart';

final formatter = NumberFormat('#,##,###.##');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final input={ "name"   : "Alice Brown",
    "sku"    : "54321",
    "price"  : 199.95,
    "shipTo" : { "name" : "Bob Brown",
      "address" : "456 Oak Lane",
      "city" : "Pretendville",
      "state" : "HI",
      "zip"   : "98999" },
    "billTo" : { "name" : "Alice Brown",
      "address" : "456 Oak Lane",
      "city" : "Pretendville",
      "state" : "HI",
      "zip"   : "98999" }
  };
  print('REAL ${Abc.fromJson(input).toJson()}');
  print('EXP  ${input}');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tiffin Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AuthPage(),
    );
  }
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final ValueNotifier<List<String>?> users = ValueNotifier(null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tiffin Management',
          style: AppFontStyle.fontLato(fontSize: 21, color: Colors.white),
        ),
      ),
      floatingActionButton: Builder(builder: (context) {
        if(Platform.isAndroid) {
          return FloatingActionButton(
          backgroundColor: Colors.blueAccent,
          onPressed: () {
            if (users.value == null) {
              return;
            }
            String? payer;
            double? amount;
            showDialog(
                context: context,
                builder: (_) => StatefulBuilder(builder: (_, setState2) {
                      return Dialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Add payment entry',
                                style: AppFontStyle.fontLato(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              CommonDropDown<String>(
                                items: users.value!,
                                title: 'Choose payer',
                                value: payer,
                                onChanged: (value) {
                                  setState2(() {
                                    payer = value;
                                  });
                                },
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              CommonTextField(
                                border: true,
                                textInputType: TextInputType.number,
                                value: '',
                                onChanged: (value) {
                                  amount = double.tryParse(value);
                                  setState2(() {});
                                },
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              TextButton(
                                onPressed: () {
                                  if (payer != null && amount != null) {
                                    Navigator.pop(context);

                                    FireBridge.addTransaction(payer!, amount!)
                                        .then((value) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Payment entry has been added successfully!!',
                                            style: AppFontStyle.fontLato(
                                                fontSize: 18,
                                                color: Colors.white),
                                          ),
                                        ),
                                      );
                                    });
                                  }
                                },
                                child: const Text(
                                  'Submit',
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    }));
          },
          child: const Icon(Icons.add),
        );
        }
        return Container();
      }),
      body: Center(
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ValueListenableBuilder(
                    valueListenable: users,
                    builder: (context, value, _) {
                      if (users.value != null) {
                        return ElevatedButton(
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return ViewStatsPage(
                                users: users.value!,
                              );
                            }));
                          },
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(4),
                            width: double.infinity,
                            child: Text(
                              'View Tiffins',
                              style: AppFontStyle.fontLato(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      }
                      return const Offstage();
                    }),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  'Tick for your Tiffin',
                  style: AppFontStyle.fontLato(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: FutureBuilder<List<String>?>(
                  key: UniqueKey(),
                  builder: (context, data) {
                    if (data.hasData) {
                      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                        users.value = data.data;
                      });
                      return ListView.separated(
                        padding: const EdgeInsets.all(10),
                        separatorBuilder: (_, i) => const SizedBox(
                          height: 10,
                        ),
                        itemBuilder: (context, i) {
                          return InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return HomePage(name: data.data![i]);
                              }));
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                boxShadow: kElevationToShadow[10],
                                color: Colors.white,
                                border:
                                    Border.all(color: Colors.blue, width: 2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.all(8.0),
                              alignment: Alignment.center,
                              child: Text(
                                data.data![i],
                                style: AppFontStyle.fontLato(
                                    fontSize: 18, color: Colors.blue),
                              ),
                            ),
                          );
                        },
                        itemCount: data.data!.length,
                      );
                    }
                    if (data.hasError) {
                      return ListView(
                        children: [
                          Text(
                            'Error ${data.error?.toString()}',
                            style: AppFontStyle.fontLato(fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      );
                    }
                    return Container(
                      alignment: Alignment.center,
                      child: const SizedBox(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator(),
                      ),
                    );
                  },
                  future: FireBridge.loadAllUsers(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension DateOnlyCompare on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}

extension MapExt on Map {
  void addInValueList(String key, int value) {
    if (containsKey(key)) {
      this[key].add(value);
    } else {
      this[key] = [value];
    }
  }
}

class Debouncer {
  final int milliseconds;
  VoidCallback? action;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  run(VoidCallback action) {
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}
