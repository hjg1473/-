import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:block_english/utils/color.dart';
import 'package:block_english/utils/text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GroupProgressDropdown extends StatelessWidget {
  const GroupProgressDropdown({
    super.key,
    required this.itemList,
    required this.initialItem,
    required this.onChanged,
    this.enabled = true,
  });

  final List<String> itemList;
  final String initialItem;
  final Function(String?) onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return CustomDropdown(
      closedHeaderPadding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 8).r,
      expandedHeaderPadding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 8).r,
      listItemPadding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 8.r),
      decoration: CustomDropdownDecoration(
        closedFillColor: primaryPurple[100],
        expandedFillColor: primaryPurple[100],
        closedBorderRadius: BorderRadius.circular(8).r,
        expandedBorderRadius: BorderRadius.circular(8).r,
        hintStyle: textStyle16,
        headerStyle: textStyle16,
        listItemStyle: textStyle16,
        overlayScrollbarDecoration: ScrollbarThemeData(
          thumbVisibility: WidgetStateProperty.all(false),
          trackVisibility: WidgetStateProperty.all(false),
          interactive: false,
          crossAxisMargin: 100,
          mainAxisMargin: 100,
          thumbColor: WidgetStateProperty.all(Colors.red),
          trackColor: WidgetStateProperty.all(Colors.green),
          trackBorderColor: WidgetStateProperty.all(Colors.blue),
          minThumbLength: 200,
        ),
      ),
      initialItem: initialItem,
      items: itemList,
      onChanged: onChanged,
    );
  }
}
