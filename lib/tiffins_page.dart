import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:tiffin_app/home_page.dart';
import 'package:tiffin_app/main.dart';

import 'common/app_colors.dart';
import 'common/font_style.dart';
import 'common/io_lib.dart';
import 'firebase/firebridge.dart';

class ViewStatsPage extends StatefulWidget {
  final List<String> users;

  const ViewStatsPage({Key? key, required this.users}) : super(key: key);

  @override
  State<ViewStatsPage> createState() => _ViewStatsPageState();
}

class _ViewStatsPageState extends State<ViewStatsPage> {
  DateTime today = DateTime.now();
  late DateTime start, end;
  final Map<String, num> cost = {};
  final ValueNotifier<TiffinViewModel?> tiffinData = ValueNotifier(null);
  final ValueNotifier<Map<String, List<TransactionModel>>?> transactions =
      ValueNotifier(null);
  final Debouncer _debouncer = Debouncer(milliseconds: 200);

  final Map<String, double> userWiseCost = {};

  @override
  void initState() {
    start = DateTime(2022, 10, 17);
    end = today.add(const Duration(days: 0));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          'Tiffin Management',
          style: AppFontStyle.fontLato(fontSize: 21, color: Colors.white),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                'Tiffin Details',
                style: AppFontStyle.fontLato(
                    fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'From',
                        style: AppFontStyle.fontLato(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      InkWell(
                        onTap: () {
                          chooseDate(start, (value) {
                            start = value;
                            setState(() {});
                          });
                        },
                        child: Text(
                          displayFormat.format(start),
                          style: AppFontStyle.fontLato(
                              fontSize: 16,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Text(
                        'To',
                        style: AppFontStyle.fontLato(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      InkWell(
                        onTap: () {
                          chooseDate(end, (value) {
                            end = value;
                            setState(() {});
                          });
                        },
                        child: Text(displayFormat.format(end),
                            style: AppFontStyle.fontLato(
                                fontSize: 16,
                                color: Colors.blue,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Builder(builder: (context) {
                return InkWell(
                  onTap: () {
                    if (tiffinData.value != null) {
                      final dateMonthFormat = DateFormat('dd-MM');
                      String text = '';
                      for (final data in tiffinData.value!.map.entries) {
                        if (data.value.isNotEmpty) {
                          text +=
                              '${dateMonthFormat.format(format.parse(data.key))} : ${data.value.map((e) => e).join(',')}\n';
                        }
                      }
                      Clipboard.setData(ClipboardData(text: text));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Copied!!!'),
                        ),
                      );
                    }
                  },
                  child: Row(
                    children: [
                      Text(
                        'Copy Data',
                        style: AppFontStyle.fontLato(fontSize: 14),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      const Icon(
                        Icons.copy,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                );
              }),
            ),
            Expanded(
              child: FutureBuilder<TiffinViewModel?>(
                builder: (context, data) {
                  if (data.hasData && data.data != null) {
                    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                      tiffinData.value = data.data!;
                    });
                    userWiseCost.clear();
                    cost.clear();
                    cost.addAll(data.data!.cost);
                    final entries =
                        data.data!.map.entries.toList(growable: false);
                    entries.sort((a, b) =>
                        format.parse(a.key).isAfter(format.parse(b.key))
                            ? 1
                            : -1);
                    return ListView.separated(
                      padding: const EdgeInsets.all(10).copyWith(
                          bottom: MediaQuery.of(context).viewInsets.bottom),
                      separatorBuilder: (_, i) => const SizedBox(
                        height: 10,
                      ),
                      itemBuilder: (context, i) {
                        final entry = entries.elementAt(i);

                        return Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  offset: const Offset(3, 3),
                                  blurRadius: 8,
                                  spreadRadius: 2)
                            ],
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.all(8),
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    displayFormat
                                        .format(format.parse(entry.key)),
                                    style: AppFontStyle.fontLato(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Container(
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.blue,
                                    ),
                                    padding: const EdgeInsets.all(5),
                                    child: Text(
                                      '${entry.value.length}',
                                      style: AppFontStyle.fontLato(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                  const Spacer(),
                                  SizedBox(
                                    width: 150,
                                    child: CommonTextField(
                                      readOnly: !Platform.isAndroid,
                                      value: cost[entry.key]?.toString(),
                                      textInputType: TextInputType.number,
                                      border: true,
                                      onEditingComplete: () {},
                                      onChanged: (value) {
                                        final dval = double.tryParse(value);
                                        if (dval != null) {
                                          cost[entry.key] = dval;
                                        } else {
                                          cost.remove(entry.key);
                                        }
                                        _debouncer.run(() {
                                          tiffinData.notifyListeners();
                                          FireBridge.updateCost(
                                              entry.key, cost[entry.key]);
                                        });
                                      },
                                      hintText: 'Cost',
                                    ),
                                  )
                                ],
                              ),
                              Text(
                                entry.value.join(', '),
                                style: AppFontStyle.fontLato(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              )
                            ],
                          ),
                        );
                      },
                      itemCount: data.data!.map.length,
                    );
                  }
                  if (data.hasError || (data.hasData && data.data == null)) {
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
                future: FireBridge.loadTiffins(widget.users, start, end),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: kElevationToShadow[10],
              ),
              padding: const EdgeInsets.all(15),
              child: ValueListenableBuilder(
                  valueListenable: transactions,
                  builder: (context, transactions, _) {
                    if (transactions != null) {
                      return ValueListenableBuilder(
                          valueListenable: tiffinData,
                          builder: (context, value, _) {
                            if (value != null) {
                              userWiseCost.clear();
                              for (final user in widget.users) {
                                userWiseCost[user] = 0;
                              }
                              for (final tiffin
                                  in tiffinData.value!.map.entries) {
                                if (!cost.containsKey(tiffin.key)) {
                                  continue;
                                }
                                final perHeadPrice =
                                    cost[tiffin.key]! / tiffin.value.length;
                                for (final user in tiffin.value) {
                                  userWiseCost[user] =
                                      userWiseCost[user]! + perHeadPrice;
                                }
                              }
                              userWiseCost
                                  .removeWhere((key, value) => value == 0);
                            }

                            final total = userWiseCost.isEmpty?0:userWiseCost.values
                                .reduce((value, element) => value + element);
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (userWiseCost.isNotEmpty) ...[
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        userWiseCost.entries
                                            .map((entry) =>
                                                '${entry.key} : ${formatter.format(entry.value)} ${ ' Remaining ${formatter.format((entry.value - ((transactions[entry.key]?.isNotEmpty ?? false) ? transactions[entry.key]!.map((e) => e.amount).reduce((value, element) => value + element) : 0)))}'}')
                                            .join('\n'),
                                        style: AppFontStyle.fontLato(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blueAccent.shade700,
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          String copy = '';
                                          for (final entry
                                              in userWiseCost.entries) {
                                            copy +=
                                                '${entry.key} : ${entry.value}';
                                          }
                                          Clipboard.setData(
                                              ClipboardData(text: copy));
                                        },
                                        child: const Icon(Icons.copy),
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    'Total : ${formatter.format(total)}',
                                    style: AppFontStyle.fontLato(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                                // ElevatedButton(
                                //
                                //   onPressed: () {
                                //
                                //   },
                                //   child: Container(
                                //     width: double.infinity,
                                //     alignment: Alignment.center,
                                //     child: Text(
                                //       'Total Up',
                                //       style: AppFontStyle.fontLato(
                                //           fontSize: 18, color: Colors.white),
                                //     ),
                                //   ),
                                // ),
                              ],
                            );
                          });
                    }
                    return const Offstage();
                  }),
            ),
            Column(
              children: [
                FutureBuilder<Map<String, List<TransactionModel>>?>(
                  builder: (context, value) {
                    if (value.hasData && value.data != null) {
                      final entries = value.data!.entries;
                      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                        transactions.value = value.data!;
                      });
                      return Column(
                        children: [
                          ExpansionTile(
                            tilePadding: const EdgeInsets.all(8),
                            title: Text(
                              'Payments',
                              style: AppFontStyle.fontLato(
                                fontSize: 18,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            children: [
                              ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxHeight: 150),
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    padding: EdgeInsets.zero,
                                    itemCount: value.data!.length,
                                    itemBuilder: (context, i) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15.0, vertical: 5),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                entries.elementAt(i).key,
                                                style: AppFontStyle.fontLato(
                                                    fontSize: 16,
                                                    color: Colors.blue,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                entries
                                                    .elementAt(i)
                                                    .value
                                                    .map((e) =>
                                                        '₹${formatter.format(e.amount)} on ${displayFormat.format(e.dateTime)}')
                                                    .join('\n'),
                                                style: AppFontStyle.fontLato(
                                                        fontSize: 16,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold)
                                                    .copyWith(height: 1.5),
                                              ),
                                            )
                                          ],
                                        ),
                                      );
                                    }),
                              )
                            ],
                          )
                        ],
                      );
                    }
                    if (value.hasError) {
                      return Text('ERROR ${value.error}');
                    }
                    return const SizedBox(
                      height: 50,
                      width: 50,
                      child: CircularProgressIndicator(),
                    );
                  },
                  future: FireBridge.loadTransaction(),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  void chooseDate(DateTime date, ValueChanged<DateTime> onChange) {
    showDialog(
        context: context,
        builder: (context) {
          return DatePickerDialog(
            initialDate: date,
            firstDate: today.subtract(const Duration(days: 365)),
            lastDate: today.add(const Duration(days: 10)),
          );
        }).then((value) {
      if (value != null) {
        onChange.call(value);
      }
    });
  }
}

class CommonTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final void Function(String)? onChanged;
  final bool border;
  final FormFieldValidator? validator;
  final bool enabled;
  final TextInputType textInputType;
  final double? fontSize;
  final String? value;
  final VoidCallback? onEditingComplete;
  final bool readOnly;

  const CommonTextField(
      {Key? key,
      this.enabled = true,
      this.border = false,
      this.readOnly = false,
      this.onEditingComplete,
      this.value,
      this.controller,
      this.hintText,
      this.onChanged,
      this.validator,
      this.fontSize,
      required this.textInputType})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: enabled,
      validator: validator,
      onChanged: onChanged,
      controller: controller,
      keyboardType: textInputType,
      onEditingComplete: onEditingComplete,
      readOnly: readOnly,
      initialValue: value,
      style: AppFontStyle.fontLato(
          fontSize: fontSize ?? (border ? 14 : 18),
          color: AppColors.darkGrey,
          fontWeight: border ? FontWeight.normal : FontWeight.w500),
      decoration: InputDecoration(
        hintText: hintText,
        border: border
            ? const OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.lightGrey))
            : InputBorder.none,
        enabledBorder: border
            ? const OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.grey))
            : InputBorder.none,
        hintStyle: AppFontStyle.fontLato(
            fontSize: fontSize ?? (border ? 15 : 18), color: AppColors.grey),
        errorStyle: AppFontStyle.fontLato(
            fontSize: fontSize ?? 14,
            color: AppColors.red,
            fontWeight: FontWeight.normal),
        contentPadding: border
            ? const EdgeInsets.symmetric(horizontal: 10)
            : const EdgeInsets.all(10),
      ),
    );
  }
}
