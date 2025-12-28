import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class CategoryChips extends StatelessWidget {
  final String? selectedCategory;
  final Function(String?) onCategorySelected;

  const CategoryChips({
    Key? key,
    required this.selectedCategory,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final displayCategories = {
      null: 'All',
      '10': 'Music',
      '20': 'Gaming',
      '22': 'Vlogs',
      '23': 'Comedy',
      '24': 'Entertainment',
      '25': 'News',
      '26': 'How-to',
      '27': 'Education',
      '28': 'Tech',
    };

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: displayCategories.length,
        itemBuilder: (context, index) {
          final categoryId = displayCategories.keys.elementAt(index);
          final categoryName = displayCategories.values.elementAt(index);
          final isSelected = selectedCategory == categoryId;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(categoryName),
              selected: isSelected,
              onSelected: (selected) {
                onCategorySelected(selected ? categoryId : null);
              },
              backgroundColor: Theme.of(context).cardColor,
              selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              checkmarkColor: Theme.of(context).colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  width: 1.5,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
