import 'package:dio/dio.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

class SmartDropdownField<T> extends StatefulWidget {
  final String? url;
  final List<T>? items; // Optional manually passed items
  final T? defaultValue; // Default value for single selection
  final List<T>? defaultValues; // Default values for multi-selection
  final bool isMultiSelection; // Flag to enable multi-selection
  final T Function(dynamic)? fromJson;
  final String Function(T) itemAsString;
  final void Function(T?)? onChanged;
  final void Function(List<T>?)? onChangedMulti;
  final dynamic Function(T)? idGetter; // Optional callback to get the id

  const SmartDropdownField({
    super.key,
    this.url,
    this.items,
    this.fromJson,
    required this.itemAsString,
    this.onChanged,
    this.defaultValue,
    this.defaultValues,
    this.isMultiSelection = false,
    this.onChangedMulti,
    this.idGetter,
  });

  @override
  SmartDropdownFieldState<T> createState() => SmartDropdownFieldState<T>();
}

// Remove the underscore to make this class public
class SmartDropdownFieldState<T> extends State<SmartDropdownField<T>> {
  late final ValueNotifier<T?> selectedItemNotifier;
  late final ValueNotifier<List<T>?> selectedItemsNotifier;

  @override
  void initState() {
    super.initState();
    selectedItemNotifier = ValueNotifier<T?>(widget.defaultValue);
    selectedItemsNotifier = ValueNotifier<List<T>?>(widget.defaultValues ?? []);
  }

  Future<List<T>> fetchData(String? filter) async {
    if (widget.url != null && widget.fromJson != null) {
      try {
        final response =
            await Dio().get(widget.url!, queryParameters: {"filter": filter});
        final data = response.data;
        if (data != null) {
          return data.map<T>((item) => widget.fromJson!(item)).toList();
        }
      } catch (e) {
        debugPrint("Error fetching data: $e");
      }
    }
    return [];
  }

  Widget _buildMultiSelectionDropdown() {
    return ValueListenableBuilder<List<T>?>(
      valueListenable: selectedItemsNotifier,
      builder: (context, selectedItems, _) {
        return DropdownSearch<T>.multiSelection(
          items: (filter, _) async => widget.items ?? await fetchData(filter),
          itemAsString: widget.itemAsString,
          selectedItems: selectedItems ?? [],
          onChanged: (List<T>? value) {
            selectedItemsNotifier.value = value;
            widget.onChangedMulti?.call(value);
          },
          compareFn: _compareItems,
          popupProps: PopupPropsMultiSelection.menu(
            showSearchBox: true,
            showSelectedItems: true,
          ),
        );
      },
    );
  }

  Widget _buildSingleSelectionDropdown() {
    return ValueListenableBuilder<T?>(
      valueListenable: selectedItemNotifier,
      builder: (context, selectedItem, _) {
        return DropdownSearch<T>(
          items: (filter, _) async => widget.items ?? await fetchData(filter),
          itemAsString: widget.itemAsString,
          selectedItem: selectedItem,
          onChanged: (T? value) {
            selectedItemNotifier.value = value;
            widget.onChanged?.call(value);
          },
          compareFn: _compareItems,
          dropdownBuilder: (_, item) {
            return Text(
              item != null ? widget.itemAsString(item) : 'Select an item',
              style: const TextStyle(fontSize: 16),
            );
          },
          popupProps: PopupProps.menu(
            showSearchBox: widget.items == null,
            showSelectedItems: true,
          ),
        );
      },
    );
  }

  bool _compareItems(T item, T selectedItem) {
    if (widget.idGetter != null) {
      return widget.idGetter!(item) == widget.idGetter!(selectedItem);
    }
    return item == selectedItem;
  }

  @override
  Widget build(BuildContext context) {
    return widget.isMultiSelection
        ? _buildMultiSelectionDropdown()
        : _buildSingleSelectionDropdown();
  }

  @override
  void dispose() {
    selectedItemNotifier.dispose();
    selectedItemsNotifier.dispose();
    super.dispose();
  }
}
