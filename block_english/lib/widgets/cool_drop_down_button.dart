import 'package:cool_dropdown/cool_dropdown.dart';
import 'package:cool_dropdown/models/cool_dropdown_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoolDropDownButton extends StatelessWidget {
  const CoolDropDownButton({
    super.key,
    required this.dropdownList,
    required this.controller,
    required this.defaultItem,
    required this.onChange,
    required this.width,
    required this.height,
    required this.backgroundColor,
    required this.primaryColor,
    required this.textStyle,
  });

  final List<CoolDropdownItem<String>> dropdownList;
  final DropdownController<String> controller;
  final CoolDropdownItem<String>? defaultItem;
  final Function(String) onChange;
  final double width;
  final double height;
  final Color backgroundColor;
  final Color primaryColor;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    return CoolDropdown<String>(
      dropdownList: dropdownList,
      controller: controller,
      defaultItem: defaultItem,
      onChange: onChange,
      resultOptions: ResultOptions(
        padding: const EdgeInsets.symmetric(horizontal: 15).r,
        width: width,
        height: height,
        textStyle: textStyle,
        openBoxDecoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8).r,
          border: Border.all(
            width: 1,
            color: primaryColor,
          ),
        ),
        icon: SizedBox(
          width: 13.31.r,
          height: 10.r,
          child: const CustomPaint(
            painter: DropdownArrowPainter(color: Colors.black),
          ),
        ),
        render: ResultRender.all,
        isMarquee: false,
      ),
      dropdownOptions: DropdownOptions(
        top: 0,
        width: width,
        borderSide: BorderSide(
          width: 0,
          color: backgroundColor,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6).r,
        align: DropdownAlign.center,
        animationType: DropdownAnimationType.size,
      ),
      dropdownTriangleOptions: const DropdownTriangleOptions(
        width: 0,
        height: 0,
      ),
      dropdownItemOptions: DropdownItemOptions(
        isMarquee: true,
        mainAxisAlignment: MainAxisAlignment.start,
        render: DropdownItemRender.all,
        height: height,
        textStyle: textStyle,
        selectedBoxDecoration: BoxDecoration(
          color: backgroundColor,
        ),
        selectedTextStyle: textStyle.copyWith(
          color: primaryColor,
        ),
        selectedPadding: EdgeInsets.symmetric(
          horizontal: 10.r,
        ),
      ),
    );
  }
}
