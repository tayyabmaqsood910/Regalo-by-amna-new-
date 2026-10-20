import 'package:regalo_by_amna/models/bill_item.dart';
import 'package:regalo_by_amna/models/invoice.dart';
import 'package:regalo_by_amna/models/invoice_settings.dart';
import 'package:regalo_by_amna/models/product.dart';

abstract final class DemoData {
  static const settings = InvoiceSettings.regalo();

  static List<Product> products() {
    return const [
      Product(
        id: 'red-rose',
        name: 'Red Rose',
        category: ProductCategory.roses,
        price: 150,
        description: 'Single long-stem red rose.',
      ),
      Product(
        id: 'white-rose',
        name: 'White Rose',
        category: ProductCategory.roses,
        price: 150,
        description: 'Single long-stem white rose.',
      ),
      Product(
        id: 'pink-rose',
        name: 'Pink Rose',
        category: ProductCategory.roses,
        price: 160,
        description: 'Single long-stem pink rose.',
      ),
      Product(
        id: 'rose-bouquet',
        name: 'Rose Bouquet',
        category: ProductCategory.bouquets,
        price: 4500,
        description: 'A tied bouquet of mixed roses.',
      ),
      Product(
        id: 'mixed-bouquet',
        name: 'Mixed Flower Bouquet',
        category: ProductCategory.bouquets,
        price: 3200,
        description: 'Seasonal flowers in a hand-tied bunch.',
      ),
      Product(
        id: 'wedding-bouquet',
        name: 'Wedding Bouquet',
        category: ProductCategory.bouquets,
        price: 16500,
        description: 'Bridal bouquet arranged to order.',
      ),
      Product(
        id: 'birthday-bouquet',
        name: 'Birthday Bouquet',
        category: ProductCategory.bouquets,
        price: 5200,
        description: 'A bright bouquet for a birthday.',
      ),
      Product(
        id: 'sunflower',
        name: 'Sunflower',
        category: ProductCategory.stems,
        price: 200,
        description: 'Single sunflower stem.',
      ),
      Product(
        id: 'lily',
        name: 'Lily',
        category: ProductCategory.stems,
        price: 400,
        description: 'Single lily stem.',
      ),
      Product(
        id: 'jasmine',
        name: 'Jasmine',
        category: ProductCategory.stems,
        price: 180,
        description: 'A small bunch of jasmine.',
      ),
      Product(
        id: 'flower-basket',
        name: 'Flower Basket',
        category: ProductCategory.bouquets,
        price: 3800,
        description: 'A basket filled with mixed blooms.',
      ),
      Product(
        id: 'custom-arrangement',
        name: 'Custom Floral Arrangement',
        category: ProductCategory.bouquets,
        price: 6000,
        description: 'An arrangement made for the occasion.',
      ),
      Product(
        id: 'wrapping',
        name: 'Wrapping',
        category: ProductCategory.extras,
        price: 250,
        description: 'Paper and ribbon for a bouquet.',
      ),
      Product(
        id: 'gift-card',
        name: 'Gift Card',
        category: ProductCategory.extras,
        price: 1000,
        description: 'A shop gift card.',
      ),
    ];
  }

  static List<Invoice> sessionBills({DateTime? now}) {
    final clock = now ?? DateTime.now();
    const profile = settings;
    return [
      Invoice(
        id: 'inv-1004',
        number: 'INV-1004',
        createdAt: clock.subtract(const Duration(minutes: 12)),
        customerName: 'Sara Malik',
        customerPhone: '0301-5550142',
        items: const [
          BillItem(
            id: 'line-1004-1',
            productId: 'birthday-bouquet',
            name: 'Birthday Bouquet',
            quantity: 1,
            unitPrice: 5200,
          ),
          BillItem(
            id: 'line-1004-2',
            productId: 'gift-card',
            name: 'Gift Card',
            quantity: 1,
            unitPrice: 1000,
            discount: 200,
          ),
        ],
        amountPaid: 6000,
        settings: profile,
      ),
      Invoice(
        id: 'inv-1001',
        number: 'INV-1001',
        createdAt: clock.subtract(const Duration(minutes: 40)),
        customerName: 'Ayesha Khan',
        customerPhone: '0300-1234501',
        items: const [
          BillItem(
            id: 'line-1001-1',
            productId: 'rose-bouquet',
            name: 'Rose Bouquet',
            quantity: 1,
            unitPrice: 4500,
          ),
        ],
        amountPaid: 4500,
        settings: profile,
      ),
      Invoice(
        id: 'inv-1002',
        number: 'INV-1002',
        createdAt: clock.subtract(const Duration(hours: 2)),
        items: const [
          BillItem(
            id: 'line-1002-1',
            productId: 'mixed-bouquet',
            name: 'Mixed Flower Bouquet',
            quantity: 1,
            unitPrice: 3200,
          ),
          BillItem(
            id: 'line-1002-2',
            productId: 'wrapping',
            name: 'Wrapping',
            quantity: 1,
            unitPrice: 250,
          ),
        ],
        billDiscount: 150,
        deliveryCharges: 200,
        amountPaid: 1500,
        settings: profile,
      ),
      Invoice(
        id: 'inv-1003',
        number: 'INV-1003',
        createdAt: clock.subtract(const Duration(hours: 3)),
        customerName: 'Hassan Ali',
        customerPhone: '0321-5550198',
        items: const [
          BillItem(
            id: 'line-1003-1',
            productId: 'wedding-bouquet',
            name: 'Wedding Bouquet',
            quantity: 1,
            unitPrice: 16500,
          ),
          BillItem(
            id: 'line-1003-2',
            productId: 'lily',
            name: 'Lily',
            quantity: 6,
            unitPrice: 400,
          ),
        ],
        deliveryCharges: 500,
        notes: 'Deliver to the hall before 4 PM.',
        settings: profile,
      ),
    ];
  }
}
