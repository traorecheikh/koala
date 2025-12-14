import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:hive_ce/hive.dart';
import 'dart:async'; // Added import for StreamSubscription

enum FilterType { all, income, expense }
enum SortOption { dateNewest, dateOldest, amountHighest, amountLowest, description }

class TransactionsController extends GetxController {
  final transactions = <LocalTransaction>[].obs;
  final displayedTransactions = <LocalTransaction>[].obs;
  
  final isLoading = false.obs;
  final hasMore = false.obs;
  final scrollController = ScrollController();
  
  // Filters & Search
  final searchController = TextEditingController();
  final currentFilter = FilterType.all.obs;
  final currentSort = SortOption.dateNewest.obs;
  final dateRange = Rxn<DateTimeRange>();

  StreamSubscription? _transactionBoxSubscription; // Store the subscription

  @override
  void onInit() {
    super.onInit();
    _loadTransactions();
    
    // Listeners
    searchController.addListener(_filterAndSort);
    scrollController.addListener(_onScroll);
    
    // Watch Hive box for changes and store the subscription
    final box = Hive.box<LocalTransaction>('transactionBox');
    _transactionBoxSubscription = box.watch().listen((_) => _loadTransactions());
  }

  @override
  void onClose() {
    searchController.dispose();
    scrollController.dispose();
    _transactionBoxSubscription?.cancel(); // Cancel the subscription
    super.onClose();
  }

  void _loadTransactions() {
    isLoading.value = true;
    final box = Hive.box<LocalTransaction>('transactionBox');
    transactions.assignAll(box.values.toList());
    _filterAndSort();
    isLoading.value = false;
  }

  void _filterAndSort() {
    var result = List<LocalTransaction>.from(transactions.where((t) => !t.isHidden));

    // 1. Filter by Type
    if (currentFilter.value == FilterType.income) {
      result = result.where((t) => t.type == TransactionType.income).toList();
    } else if (currentFilter.value == FilterType.expense) {
      result = result.where((t) => t.type == TransactionType.expense).toList();
    }

    // 2. Filter by Date Range
    if (dateRange.value != null) {
      result = result.where((t) {
        return t.date.isAfter(dateRange.value!.start.subtract(const Duration(days: 1))) &&
               t.date.isBefore(dateRange.value!.end.add(const Duration(days: 1)));
      }).toList();
    }

    // 3. Search
    if (searchController.text.isNotEmpty) {
      final query = searchController.text.toLowerCase();
      result = result.where((t) {
        return t.description.toLowerCase().contains(query) ||
               t.amount.toString().contains(query) ||
               (t.category?.displayName.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // 4. Sort
    switch (currentSort.value) {
      case SortOption.dateNewest:
        result.sort((a, b) => b.date.compareTo(a.date));
        break;
      case SortOption.dateOldest:
        result.sort((a, b) => a.date.compareTo(b.date));
        break;
      case SortOption.amountHighest:
        result.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case SortOption.amountLowest:
        result.sort((a, b) => a.amount.compareTo(b.amount));
        break;
      case SortOption.description:
        result.sort((a, b) => a.description.compareTo(b.description));
        break;
    }

    displayedTransactions.assignAll(result);
  }

  void _onScroll() {
    // Pagination logic if needed later
  }

  void setFilter(FilterType filter) {
    currentFilter.value = filter;
    _filterAndSort();
  }

  void setSort(SortOption sort) {
    currentSort.value = sort;
    _filterAndSort();
  }

  void setDateRange(DateTimeRange range) {
    dateRange.value = range;
    _filterAndSort();
  }

  void clearFilters() {
    currentFilter.value = FilterType.all;
    currentSort.value = SortOption.dateNewest;
    dateRange.value = null;
    searchController.clear();
    _filterAndSort();
  }

  bool get hasActiveFilters {
    return currentFilter.value != FilterType.all ||
           dateRange.value != null ||
           searchController.text.isNotEmpty;
  }
}

