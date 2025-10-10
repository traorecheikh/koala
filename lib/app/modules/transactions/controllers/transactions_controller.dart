import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/modules/home/controllers/home_controller.dart';

enum SortOption {
  dateNewest,
  dateOldest,
  amountHighest,
  amountLowest,
  description,
}

enum FilterType { all, income, expense }

class TransactionsController extends GetxController {
  final HomeController _homeController = Get.find();
  final RxList<LocalTransaction> transactions = <LocalTransaction>[].obs;
  final RxList<LocalTransaction> _filteredTransactions =
      <LocalTransaction>[].obs;

  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  // Filter and sort state
  final Rx<FilterType> currentFilter = FilterType.all.obs;
  final Rx<SortOption> currentSort = SortOption.dateNewest.obs;
  final Rxn<DateTimeRange> dateRange = Rxn<DateTimeRange>();
  final Rxn<TransactionCategory> selectedCategory = Rxn<TransactionCategory>();

  // Pagination state
  final RxInt displayedCount = 20.obs;
  final int itemsPerPage = 20;
  final RxBool isLoading = false.obs;
  final RxBool hasMore = true.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeTransactions();

    searchController.addListener(_applyFilters);
    scrollController.addListener(_onScroll);

    // Listen to changes in home controller transactions
    ever(_homeController.transactions, (_) => _initializeTransactions());
  }

  void _initializeTransactions() {
    transactions.assignAll(_homeController.transactions);
    _applyFilters();
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      loadMore();
    }
  }

  void loadMore() {
    if (isLoading.value || !hasMore.value) return;

    isLoading.value = true;

    // Simulate loading delay for smooth UX
    Future.delayed(const Duration(milliseconds: 300), () {
      final newCount = displayedCount.value + itemsPerPage;
      displayedCount.value = newCount;

      if (newCount >= _filteredTransactions.length) {
        hasMore.value = false;
      }

      isLoading.value = false;
    });
  }

  List<LocalTransaction> get displayedTransactions {
    final count = displayedCount.value.clamp(0, _filteredTransactions.length);
    return _filteredTransactions.take(count).toList();
  }

  void _applyFilters() {
    List<LocalTransaction> filtered = List.from(transactions);

    // Apply search filter
    final query = searchController.text.toLowerCase().trim();
    if (query.isNotEmpty) {
      filtered = filtered.where((tx) {
        final categoryName = tx.category?.displayName ?? '';
        return tx.description.toLowerCase().contains(query) ||
            categoryName.toLowerCase().contains(query);
      }).toList();
    }

    // Apply type filter (income/expense/all)
    if (currentFilter.value != FilterType.all) {
      final type = currentFilter.value == FilterType.income
          ? TransactionType.income
          : TransactionType.expense;
      filtered = filtered.where((tx) => tx.type == type).toList();
    }

    // Apply category filter
    if (selectedCategory.value != null) {
      filtered = filtered
          .where((tx) => tx.category == selectedCategory.value)
          .toList();
    }

    // Apply date range filter
    if (dateRange.value != null) {
      filtered = filtered.where((tx) {
        return tx.date.isAfter(
              dateRange.value!.start.subtract(const Duration(days: 1)),
            ) &&
            tx.date.isBefore(dateRange.value!.end.add(const Duration(days: 1)));
      }).toList();
    }

    // Apply sorting
    switch (currentSort.value) {
      case SortOption.dateNewest:
        filtered.sort((a, b) => b.date.compareTo(a.date));
        break;
      case SortOption.dateOldest:
        filtered.sort((a, b) => a.date.compareTo(b.date));
        break;
      case SortOption.amountHighest:
        filtered.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case SortOption.amountLowest:
        filtered.sort((a, b) => a.amount.compareTo(b.amount));
        break;
      case SortOption.description:
        filtered.sort((a, b) => a.description.compareTo(b.description));
        break;
    }

    _filteredTransactions.assignAll(filtered);

    // Reset pagination
    displayedCount.value = itemsPerPage;
    hasMore.value = _filteredTransactions.length > itemsPerPage;
  }

  void setFilter(FilterType filter) {
    currentFilter.value = filter;
    _applyFilters();
  }

  void setSort(SortOption sort) {
    currentSort.value = sort;
    _applyFilters();
  }

  void setDateRange(DateTimeRange? range) {
    dateRange.value = range;
    _applyFilters();
  }

  void setCategory(TransactionCategory? category) {
    selectedCategory.value = category;
    _applyFilters();
  }

  void clearFilters() {
    searchController.clear();
    currentFilter.value = FilterType.all;
    currentSort.value = SortOption.dateNewest;
    dateRange.value = null;
    selectedCategory.value = null;
    _applyFilters();
  }

  bool get hasActiveFilters {
    return searchController.text.isNotEmpty ||
        currentFilter.value != FilterType.all ||
        dateRange.value != null ||
        selectedCategory.value != null;
  }

  @override
  void onClose() {
    searchController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
