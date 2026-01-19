import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/products.dart';

class ProductsService extends ChangeNotifier {
  static List<Product> products = [];

  ProductsService() {
    // Si ya tenemos datos, no recargamos
    if (products.isNotEmpty) return;

    loadProducts().then((value) {
      products = value;
      notifyListeners();

      if (products.isEmpty) {
        readJsonFile().then((value) {
          products = value;
          saveProducts(products);
          notifyListeners();
        });
      }
    });
  }

  // --- CRUD ---

  Future<void> addProduct(Product product) async {
    products.add(product);
    await saveProducts(products);
    notifyListeners();
  }

  Future<void> removeProduct(Product product) async {
    products.removeWhere((element) => element.id == product.id);
    await saveProducts(products);
    notifyListeners();
  }

  Future<void> modifyProduct(Product product) async {
    int index = products.indexWhere((element) => element.id == product.id);
    products[index] = product;
    await saveProducts(products);
    notifyListeners();
  }

  Product getProduct(int id) {
    return products.firstWhere((element) => element.id == id);
  }

  // --- PERSISTENCIA ---

  Future<List<Product>> readJsonFile() async {
    try {
      String jsonString = await rootBundle.loadString('assets/products.json');
      List jsonList = jsonDecode(jsonString);
      List<Product> list = [];
      for (var item in jsonList) {
        list.add(Product.fromJson(item));
      }
      return list;
    } catch (e) {
      return [];
    }
  }

  Future<void> saveProducts(List<Product> products) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('products', jsonEncode(products));
  }

  Future<List<Product>> loadProducts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('products');
    
    if (jsonString != null && jsonString.isNotEmpty) {
      List jsonList = jsonDecode(jsonString);
      List<Product> loadedProducts = [];
      for (var item in jsonList) {
        loadedProducts.add(Product.fromJson(item));
      }
      return loadedProducts;
    } else {
      return [];
    }
  }
}