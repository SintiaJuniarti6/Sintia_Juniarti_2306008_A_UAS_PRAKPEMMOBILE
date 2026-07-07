import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../models/review_model.dart';
import '../services/product_service.dart';
import '../services/review_service.dart';

class ProductProvider with ChangeNotifier {
  final ProductService _productService = ProductService();
  final ReviewService _reviewService = ReviewService();

  // ============================================
  // STATE UNTUK DAFTAR PRODUK
  // ============================================
  List<ProductModel> _products = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;

  // State untuk pagination
  int _currentPage = 1;
  bool _hasMore = true;

  // State untuk filter/search aktif
  String _searchQuery = '';
  String? _selectedCategoryId;
  String _sortBy = 'newest';

  // State untuk kategori
  List<CategoryModel> _categories = [];

  // Getters - daftar produk
  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;
  List<CategoryModel> get categories => _categories;
  String get searchQuery => _searchQuery;
  String? get selectedCategoryId => _selectedCategoryId;
  String get sortBy => _sortBy;

  // AMBIL PRODUK PERTAMA KALI (atau reset filter)
  Future<void> fetchProducts({bool reset = true}) async {
    if (reset) {
      _currentPage = 1;
      _products = [];
      _hasMore = true;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _productService.getProducts(
      search: _searchQuery,
      categoryId: _selectedCategoryId,
      sort: _sortBy,
      page: _currentPage,
    );

    if (result['success']) {
      _products = result['products'];
      _hasMore = result['hasMore'];
    } else {
      _errorMessage = result['message'];
    }

    _isLoading = false;
    notifyListeners();
  }

  // LOAD LEBIH BANYAK PRODUK (infinite scroll / load more)
  Future<void> loadMoreProducts() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    final nextPage = _currentPage + 1;
    final result = await _productService.getProducts(
      search: _searchQuery,
      categoryId: _selectedCategoryId,
      sort: _sortBy,
      page: nextPage,
    );

    if (result['success']) {
      _products.addAll(result['products']);
      _currentPage = nextPage;
      _hasMore = result['hasMore'];
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  // UBAH KEYWORD PENCARIAN
  void setSearchQuery(String query) {
    _searchQuery = query;
    fetchProducts(reset: true);
  }

  // UBAH FILTER KATEGORI
  void setSelectedCategory(String? categoryId) {
    _selectedCategoryId = categoryId;
    fetchProducts(reset: true);
  }

  // UBAH SORTING
  void setSortBy(String sort) {
    _sortBy = sort;
    fetchProducts(reset: true);
  }

  // AMBIL DAFTAR KATEGORI (dipanggil sekali pas Home dibuka)
  Future<void> fetchCategories() async {
    final result = await _productService.getCategories();
    if (result['success']) {
      _categories = result['categories'];
      notifyListeners();
    }
  }

  // ============================================
  // STATE UNTUK DETAIL PRODUK
  // ============================================
  ProductModel? _selectedProduct;
  bool _isLoadingDetail = false;
  List<ReviewModel> _reviews = [];
  bool _isLoadingReviews = false;
  bool _isSubmittingReview = false;

  // Getters - detail produk & review
  ProductModel? get selectedProduct => _selectedProduct;
  bool get isLoadingDetail => _isLoadingDetail;
  List<ReviewModel> get reviews => _reviews;
  bool get isLoadingReviews => _isLoadingReviews;
  bool get isSubmittingReview => _isSubmittingReview;

  // AMBIL DETAIL SATU PRODUK
  Future<void> fetchProductDetail(String id) async {
    _isLoadingDetail = true;
    _selectedProduct = null;
    notifyListeners();

    final result = await _productService.getProductDetail(id);
    if (result['success']) {
      _selectedProduct = result['product'];
    }

    _isLoadingDetail = false;
    notifyListeners();
  }

  // AMBIL ULASAN UNTUK PRODUK YANG SEDANG DIBUKA
  Future<void> fetchProductReviews(String productId) async {
    _isLoadingReviews = true;
    notifyListeners();

    final result = await _reviewService.getProductReviews(productId);
    if (result['success']) {
      _reviews = result['reviews'];
    }

    _isLoadingReviews = false;
    notifyListeners();
  }

  // KIRIM ULASAN BARU
  Future<Map<String, dynamic>> submitReview({
    required String productId,
    required int rating,
    String? comment,
  }) async {
    _isSubmittingReview = true;
    notifyListeners();

    final result = await _reviewService.createReview(
      productId: productId,
      rating: rating,
      comment: comment,
    );

    if (result['success']) {
      // Refresh daftar ulasan setelah berhasil submit
      await fetchProductReviews(productId);
    }

    _isSubmittingReview = false;
    notifyListeners();
    return result;
  }
}