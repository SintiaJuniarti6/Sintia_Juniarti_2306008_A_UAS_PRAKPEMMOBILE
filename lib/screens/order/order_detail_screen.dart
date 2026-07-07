import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final _rupiahFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderProvider>(context, listen: false).loadOrderDetail(widget.orderId);
    });
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Menunggu';
      case 'processing':
        return 'Diproses';
      case 'shipped':
        return 'Dikirim';
      case 'delivered':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pesanan')),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, _) {
          if (orderProvider.isLoadingDetail) {
            return const Center(child: CircularProgressIndicator());
          }

          if (orderProvider.detailError != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(orderProvider.detailError!),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => orderProvider.loadOrderDetail(widget.orderId),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          final order = orderProvider.selectedOrder;
          if (order == null) {
            return const Center(child: Text('Pesanan tidak ditemukan'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // STATUS PESANAN (dengan indikator warna)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _statusColor(order.status).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _statusColor(order.status)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#${order.orderNumber}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.circle, size: 12, color: _statusColor(order.status)),
                        const SizedBox(width: 8),
                        Text(
                          _statusLabel(order.status),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _statusColor(order.status),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // TANGGAL PEMESANAN
              _sectionTitle('Tanggal Pemesanan'),
              Text(DateFormat('dd MMMM yyyy, HH:mm').format(order.createdAt)),
              const SizedBox(height: 16),

              // ALAMAT PENGIRIMAN
              _sectionTitle('Alamat Pengiriman'),
              Text(order.address),
              const SizedBox(height: 16),

              // CATATAN
              if (order.notes != null && order.notes!.isNotEmpty) ...[
                _sectionTitle('Catatan'),
                Text(order.notes!),
                const SizedBox(height: 16),
              ],

              const Divider(height: 32),

              // DAFTAR ITEM PESANAN
              _sectionTitle('Daftar Item'),
              const SizedBox(height: 8),
              Card(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: order.items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = order.items[index];
                    return ListTile(
                      title: Text(item.productName),
                      subtitle: Text(
                        '${item.quantity} x ${_rupiahFormat.format(item.price)}',
                      ),
                      trailing: Text(
                        _rupiahFormat.format(item.subtotal),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // TOTAL KESELURUHAN
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Keseluruhan',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      _rupiahFormat.format(order.total),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }
}