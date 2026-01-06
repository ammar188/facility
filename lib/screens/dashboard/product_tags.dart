import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:facility/models/product_tag.dart';
import 'package:facility/screens/dashboard/product_search_cubit/product_search_cubit.dart';
import 'package:facility/core/fetch_list_cubit.dart';
import 'package:facility/constants/app_text_styles.dart';

class ProductTags extends StatefulWidget {
  const ProductTags({super.key});

  @override
  ProductTagsState createState() => ProductTagsState();
}

class ProductTagsState extends State<ProductTags> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchListCubit<ProductTag>,
        (List<ProductTag>, ListStateEnum)>(
      builder: (context, state) {
        final (tags, _) = state;
        final cube = context.read<ProductSearchCubit>();
        final selectedTags = cube.selectedTags;
        return Padding(
          padding: const EdgeInsets.only(left: 14),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: tags.map((tag) {
                final isSelected = selectedTags.contains(tag.id);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(
                      tag.tagName,
                      style: isSelected
                          ? AppTextStyles.tagSelectedStyle
                          : AppTextStyles.tagStyle,
                    ),
                    selected: isSelected,
                    onSelected: (selected) => setState(() {
                      cube.toggleTag(tag.id);
                    }),
                    backgroundColor: Colors.white,
                    selectedColor: Colors.red.shade100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Color(0xFFF75555)),
                    ),
                    checkmarkColor: AppTextStyles.tagSelectedStyle.color,
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
