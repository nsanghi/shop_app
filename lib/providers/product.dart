import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';

class Product extends ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product(
      {@required this.id,
      @required this.title,
      @required this.description,
      @required this.price,
      @required this.imageUrl,
      this.isFavorite = false});

  Future<void> toggleFavorite(String token, String userId) async {
    final oldValue = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    final url =
        'https://flutter-app-ns-default-rtdb.firebaseio.com/userFavorites/$userId/$id.json?auth=$token';
    final result = await http.put(
      url,
      body: json.encode(
        isFavorite,
      ),
    );
    print(result.statusCode);
    if (result.statusCode >= 400) {
      isFavorite = oldValue;
      notifyListeners();
      throw HttpException("Udating favorite failed!");
    }
  }
}
