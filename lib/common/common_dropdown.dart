import 'package:drop_down_list/drop_down_list.dart';
import 'package:drop_down_list/model/selected_list_item.dart';
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'font_style.dart';

class CommonDropDown<T> extends StatelessWidget {
  final String? title;
  final void Function(T?)? onChanged;
  final double fontSize;
  final String? hint;
  final bool enable;
  final List<T> items;
  final T? value;

  // final String? Function(String?)? validator;

  const CommonDropDown(
      {Key? key,
      this.title,
      this.onChanged,
      this.fontSize = 14,
      this.hint,
      this.enable = true,
      required this.items,
      this.value})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (value != null && !items.contains(value)) {
        if (items.isNotEmpty) {
          onChanged?.call(items.first);
        } else {
          onChanged?.call(null);
        }
      }
    });
    return DropdownButtonHideUnderline(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          if (title != null) ...[
            Expanded(
              child: Text(
                '$title*',
                style: AppFontStyle.fontLato(
                  color: Colors.black,
                  fontSize: fontSize,
                ),
                textAlign: TextAlign.left,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
          ],
          Expanded(
            flex: 3,
            child: FormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              key: ValueKey(value),
              validator: (_) {
                if (value == null) {
                  return 'Please select $title';
                }
              },
              builder: (field) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: AppColors.borderColor, width: 1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          if (FocusScope.of(context).hasFocus) {
                            FocusScope.of(context).unfocus();
                          }
                          DropDownState(
                            DropDown(
                              bottomSheetTitle: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Text(
                                  title ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20.0,
                                  ),
                                ),
                              ),
                              submitButtonChild: const Text(
                                'Done',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              data: items
                                  .map((e) => SelectedListItem(
                                      name: e.toString(), value: e.toString()))
                                  .toList(),
                              selectedItems: (List<dynamic> selectedList) {
                                if (selectedList.isNotEmpty) {
                                  onChanged?.call(items.firstWhere((element) =>
                                      element.toString() ==
                                      selectedList.first.name));
                                }
                              },
                              enableMultipleSelection: false,
                            ),
                          ).showModal(context);
                        },
                        child: AbsorbPointer(
                          absorbing: true,
                          child: DropdownButton<T>(
                              isExpanded: true,
                              onTap: () {},
                              dropdownColor: Colors.white,
                              icon: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 30,
                                color: AppColors.black,
                              ),
                              value: (value != null &&
                                      !items.contains(value) &&
                                      items.isNotEmpty)
                                  ? items.first
                                  : value,
                              hint: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Select $title',
                                    style: AppFontStyle.fontLato(
                                        fontWeight: FontWeight.normal,fontSize: 14),
                                  )),
                              items: items
                                  .map((e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(
                                          e.toString(),
                                          style: AppFontStyle.fontLato(
                                              color: AppColors.black,
                                              fontWeight: FontWeight.normal, fontSize: 14,),
                                        ),
                                      ))
                                  .toList(),
                              selectedItemBuilder: (context) => items
                                  .map((e) => Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          e.toString(),
                                          style: AppFontStyle.fontLato(

                                            color: AppColors.black,
                                            fontWeight: FontWeight.normal,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ))
                                  .toList(),
                              enableFeedback: false,
                              onChanged: (value) {
                                if (value != null && enable) {
                                  onChanged?.call(value);
                                }
                              }),
                        ),
                      ),
                    ),
                    if (field.hasError)
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        builder: (context, double value, child) {
                          return Transform.translate(
                            offset: Offset(0, (1 - value) * -10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  field.errorText ?? '',
                                  style: AppFontStyle.fontLato(
                                      fontSize: 12,
                                      color: AppColors.colorED3737
                                          .withOpacity(value)),
                                )
                              ],
                            ),
                          );
                        },
                        duration: const Duration(milliseconds: 300),
                      )
                  ],
                );
              },
            ),
          )
        ],
      ),
    );
    /*
     return DropdownButtonHideUnderline(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(
            title,
            style: GoogleFonts.getFont(
              'Montserrat',
              textStyle: TextStyle(
                fontSize: fontSize,
                color: ColorAssets.textFieldTitleColor,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.normal,
                decoration: TextDecoration.none,
              ),
            ),
            textAlign: TextAlign.left,
          ),
          const SizedBox(
            height: 6,
          ),
          FormField(
            key: ValueKey(value),
            validator: (_){
              if(value==null){
                return 'Please select $title';
              }
            },
            builder: (field) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                        border:
                            Border.all(color: ColorAssets.borderColor, width: 1),
                        borderRadius: BorderRadius.circular(10)),
                    child: DropdownButton<T>(
                        dropdownColor: Colors.white,
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 30,
                          color: ColorAssets.color4B5563,
                        ),
                        value: value,
                        hint: Center(
                            child: Text(
                          'Select $title',
                          style: AppFontStyle.montserrat(14,
                              fontWeight: FontWeight.normal),
                        )),
                        items: items
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(
                                    e.toString(),
                                    style: AppFontStyle.montserrat(14,
                                        color: ColorAssets.black,
                                        fontWeight: FontWeight.normal),
                                  ),
                                ))
                            .toList(),
                        selectedItemBuilder: (context) => items
                            .map((e) => Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    e.toString(),
                                    style: AppFontStyle.montserrat(
                                      14,
                                      color: ColorAssets.color22242a,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            onChanged?.call(value);
                          }
                        }),
                  ),
                  if (field.hasError)
                    TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: 1),
                      builder: (context, double value, child) {
                        return Transform.translate(
                          offset: Offset(0, (1 - value) * -10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 8,
                              ),
                              Text(
                                field.errorText ?? '',
                                style: AppFontStyle.textButtonStyle(fontSize: 12, color: ColorAssets.colorED3737.withOpacity(value)),
                              )
                            ],
                          ),
                        );
                      },
                      duration: const Duration(milliseconds: 300),
                    )
                ],
              );
            },
          )
        ],
      ),
    );
    * */
  }
}
