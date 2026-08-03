import 'package:flutter/material.dart';

import '../../../global/constants/app_colors.dart';

class FilterBar extends StatelessWidget {
  const FilterBar({super.key, required this.onSearchChanged});

  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: TextField(
        onChanged: onSearchChanged,
        decoration: InputDecoration(
          isDense: true,
          hintText: 'Search tasks or tags…',
          prefixIcon: const Icon(Icons.search_rounded, size: 20),
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.border),
          ),
        ),
      ),
    );
  }
}
