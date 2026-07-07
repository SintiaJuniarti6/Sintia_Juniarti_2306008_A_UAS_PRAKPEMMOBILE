import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../product/product_detail_screen.dart';
import '../order/order_history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      productProvider.fetchProducts();
      productProvider.fetchCategories();

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isLoggedIn) {
        Provider.of<CartProvider>(context, listen: false).fetchCart();
      }
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        Provider.of<ProductProvider>(context, listen: false).loadMoreProducts();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String _formatRupiah(double price) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(price);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Commerce App'),
        actions: [
          if (authProvider.isLoggedIn)
            IconButton(
              icon: const Icon(Icons.receipt_long_outlined),
              tooltip: 'Riwayat Pesanan',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(productProvider),
          _buildCategoryChips(productProvider),
          _buildSortDropdown(productProvider),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => productProvider.fetchProducts(),
              child: _buildBody(productProvider),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ProductProvider productProvider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Cari produk...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    productProvider.setSearchQuery('');
                  },
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
        ),
        onSubmitted: (value) => productProvider.setSearchQuery(value),
      ),
    );
  }

  Widget _buildCategoryChips(ProductProvider productProvider) {
    if (productProvider.categories.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: const Text('Semua'),
              selected: productProvider.selectedCategoryId == null,
              onSelected: (_) => productProvider.setSelectedCategory(null),
            ),
          ),
          ...productProvider.categories.map((category) {
            final isSelected = productProvider.selectedCategoryId == category.id;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(category.name),
                selected: isSelected,
                onSelected: (_) => productProvider.setSelectedCategory(
                  isSelected ? null : category.id,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSortDropdown(ProductProvider productProvider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Text('Urutkan: ', style: TextStyle(fontSize: 13, color: Colors.grey)),
          DropdownButton<String>(
            value: productProvider.sortBy,
            underline: const SizedBox.shrink(),
            items: const [
              DropdownMenuItem(value: 'newest', child: Text('Terbaru')),
              DropdownMenuItem(value: 'price_asc', child: Text('Termurah')),
              DropdownMenuItem(value: 'price_desc', child: Text('Termahal')),
            ],
            onChanged: (value) {
              if (value != null) productProvider.setSortBy(value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ProductProvider productProvider) {
    if (productProvider.isLoading && productProvider.products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (productProvider.errorMessage != null && productProvider.products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 8),
            Text(productProvider.errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => productProvider.fetchProducts(),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (productProvider.products.isEmpty) {
      return const Center(child: Text('Produk tidak ditemukan'));
    }

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: productProvider.products.length + (productProvider.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == productProvider.products.length) {
          return const Center(child: CircularProgressIndicator());
        }

        final product = productProvider.products[index];

        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductDetailScreen(productId: product.id),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CachedNetworkImage(
                    imageUrl: product.imageUrl ?? '',
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported, color: Colors.grey),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatRupiah(product.price),
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      if (product.categoryName != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            product.categoryName!,
                            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}