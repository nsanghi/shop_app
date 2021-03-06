import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';
import './cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({this.id, this.amount, this.products, this.dateTime});
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String authToken;
  final String userId;

  Orders(this.authToken, this.userId, this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url =
        'https://flutter-app-ns-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken';
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<OrderItem> loadedOrders = [];
      if (extractedData == null) {
        return;
      }
      extractedData.forEach(
        (orderId, orderData) {
          loadedOrders.add(
            OrderItem(
              id: orderId,
              amount: orderData['amount'],
              dateTime: DateTime.parse(orderData['dateTime']),
              products: (orderData['products'] as List<dynamic>)
                  .map(
                    (item) => CartItem(
                        id: item['id'],
                        title: item['title'],
                        price: item['price'],
                        quantity: item['quantity']),
                  )
                  .toList(),
            ),
          );
        },
      );
      _orders = loadedOrders;
      notifyListeners();
    } catch (error) {
      print("order: $error");
      throw error;
    }
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final timestamp = DateTime.now();
    final url =
        'https://flutter-app-ns-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken';
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'dateTime': timestamp.toIso8601String(),
          'amount': total,
          'products': cartProducts
              .map((cp) => {
                    'id': cp.id,
                    'title': cp.title,
                    'quantity': cp.quantity,
                    'price': cp.price,
                  })
              .toList(),
        }),
      );
      if (response.statusCode >= 400) {
        throw HttpException("Could not order!");
      }
      print(response.statusCode);
      _orders.insert(
          0,
          OrderItem(
            id: timestamp.toIso8601String(),
            amount: total,
            products: cartProducts,
            dateTime: DateTime.now(),
          ));
      notifyListeners();
    } catch (error) {
      print("Error in addOrder : $error");
      throw (error);
    }
  }
}
