import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/products.dart';

class ProductsService extends ChangeNotifier {
  static List<Product> products = [];

  ProductsService() {
    print("--- Servicio Iniciado ---");
    if (products.isNotEmpty) {
      print("Ya hay productos en memoria. No recargamos.");
      return;
    }

    loadProducts().then((value) {
      products = value;
      print("Productos cargados iniciales: ${products.length}");
      notifyListeners();

      if (products.isEmpty) {
        print("Lista vacía. Cargando JSON por defecto...");
        readJsonFile().then((value) {
          products = value;
          saveProducts(products); // Guardamos los defaults
          notifyListeners();
        });
      }
    }).catchError((error) {
      print("Error cargando productos: $error");
    });
  }

  // --- CRUD con Logs y Await ---

  Future<void> addProduct(Product product) async {
    print("Añadiendo producto: ${product.description}");
    products.add(product);
    await saveProducts(products);
    notifyListeners();
  }

  Future<void> removeProduct(Product product) async {
    print("Borrando producto: ${product.description}");
    products.removeWhere((element) => element.id == product.id);
    await saveProducts(products);
    notifyListeners();
  }

  Future<void> modifyProduct(Product product) async {
    print("Modificando producto: ${product.description}");
    int index = products.indexWhere((element) => element.id == product.id);
    if (index != -1) {
      products[index] = product;
      await saveProducts(products);
      notifyListeners();
    }
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
      print("Error leyendo assets: $e");
      return [];
    }
  }

  Future<void> saveProducts(List<Product> products) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String data = jsonEncode(products);
      await prefs.setString('products', data);
      print("--- DATOS GUARDADOS EN DISCO (${products.length} productos) ---");
    } catch (e) {
      print("ERROR AL GUARDAR: $e");
    }
  }

  Future<List<Product>> loadProducts() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? jsonString = prefs.getString('products');
      
      if (jsonString != null && jsonString.isNotEmpty) {
        List jsonList = jsonDecode(jsonString);
        List<Product> loadedProducts = [];
        for (var item in jsonList) {
          loadedProducts.add(Product.fromJson(item));
        }
        print("Recuperados ${loadedProducts.length} productos de SharedPreferences");
        return loadedProducts;
      } else {
        print("No hay datos en SharedPreferences");
        return [];
      }
    } catch (e) {
      print("Error al cargar de SharedPreferences: $e");
      return [];
    }
  }
}