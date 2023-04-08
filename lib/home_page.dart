import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tiffin_app/firebase/firebridge.dart';
import 'package:tiffin_app/main.dart';

import 'common/font_style.dart';
import 'common/io_lib.dart';

class HomePage extends StatefulWidget {
  final String name;

  const HomePage({Key? key, required this.name}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

final DateFormat format = DateFormat('yyyy/MM/dd');
final DateFormat displayFormat = DateFormat('EEEE dd-MMM-yyyy');

class _HomePageState extends State<HomePage> {
  Map<String, bool>? ticks;
  bool error = false;
  int start = 0, end = 10;
  static List<String> weekList = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun'
  ];
  final Map<int, bool> filter = {
    DateTime.friday: false,
    DateTime.saturday: false,
    DateTime.sunday: false,
  };

  @override
  void initState() {
    if (Platform.isAndroid) {
      start = -55;
    }
    super.initState();
  }

  @override
  void didChangeDependencies() {
    FireBridge.loadTicks(widget.name).then((value) {
      ticks = value;
      setState(() {});
    }).onError((error, stackTrace) {
      setState(() {
        print('ERROR ${error.toString()}');
        error = true;
      });
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final DateTime today = DateTime.now();
    print('TODAY ${today.hour} ${today.minute}');
    final DateTime disableLine =
        DateTime(today.year, today.month, today.day, 14, 0);
    final dates = List.generate(end - start, (index) {
      return today.add(Duration(days: start + index));
    })
        .where((element) => filter[element.weekday] ?? true)
        .toList(growable: false);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tiffin Management',
          style: AppFontStyle.fontLato(fontSize: 21, color: Colors.white),
        ),
      ),

      body: Container(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                'Name: ${widget.name}',
                style: AppFontStyle.fontLato(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                'Note: Tick before 2 PM',
                style: AppFontStyle.fontLato(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade700),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            ExpansionTile(
              childrenPadding: EdgeInsets.zero,
              title: Text(
                'Days',
                style: AppFontStyle.fontLato(
                    fontSize: 16, fontWeight: FontWeight.w700),
              ),
              children: [
                Wrap(
                  children: List.generate(
                    7,
                    (index) => Container(
                      width: 90,
                      margin: const EdgeInsets.only(right: 8),
                      child: CheckboxListTile(
                        dense: true,
                        visualDensity: VisualDensity.compact,
                        contentPadding: EdgeInsets.zero,
                        value: filter[index + 1] ?? true,
                        title: Text(
                          weekList[index],
                          style: AppFontStyle.fontLato(
                            fontSize: 14,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onChanged: (value) {
                          if (value != null) {
                            filter[index + 1] = value;
                            setState(() {});
                          }
                        },
                      ),
                    ),
                  ),
                )
              ],
            ),
            if (error)
              Text(
                'ERROR',
                style: AppFontStyle.fontLato(fontSize: 24),
              )
            else if (ticks == null)
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  child: const SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(),
                  ),
                ),
              )
            else
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xffd3d3d3).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: ListView.separated(
                    separatorBuilder: (_, __) => const Divider(
                      height: 4,
                    ),
                    itemBuilder: (context, i) {
                      final key = format.format(dates[i]);
                      final isToday = dates[i].isSameDate(today);
                      return CheckboxListTile(
                          title: Text(
                            isToday ? 'Today' : displayFormat.format(dates[i]),
                            style: AppFontStyle.fontLato(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          enabled: (Platform.isAndroid)||(today.isBefore(dates[i])||(today.isSameDate(dates[i])&&disableLine.isAfter(dates[i]))),
                          value: ticks![key] ?? false,
                          onChanged: (value) {
                            if (value != null) {
                              ticks![key] = value;
                              FireBridge.updateTick(widget.name, ticks!);
                              setState(() {});
                            }
                          });
                    },
                    itemCount: dates.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
