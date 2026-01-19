import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/products.dart';

class ProductsService extends ChangeNotifier {
  // Lista estatica de productos compartida
  static List<Product> products = [];

  ProductsService() {
    // Si ya tenemos datos cargados, no hacemos nada
    if (products.isNotEmpty) return;

    // Carga inicial de datos
    loadProducts().then((value) {
      products = value;
      notifyListeners(); // Actualiza la UI

      // Si la lista esta vacia, cargamos el JSON por defecto
      if (products.isEmpty) {
        readJsonFile().then((value) {
          products = value;
          saveProducts(products); // Guarda copia local
          notifyListeners();
        });
      }
    });
  }

  // --- Funciones CRUD ---

  // Anade un producto y guarda cambios
  Future<void> addProduct(Product product) async {
    products.add(product);
    await saveProducts(products);
    notifyListeners();
  }

  // Elimina un producto por su ID
  Future<void> removeProduct(Product product) async {
    products.removeWhere((element) => element.id == product.id);
    await saveProducts(products);
    notifyListeners();
  }

  // Modifica un producto existente buscando su indice
  Future<void> modifyProduct(Product product) async {
    int index = products.indexWhere((element) => element.id == product.id);
    products[index] = product;
    await saveProducts(products);
    notifyListeners();
  }

  // Busca un producto especifico
  Product getProduct(int id) {
    return products.firstWhere((element) => element.id == id);
  }

  // --- Persistencia ---

  // Lee el archivo products.json de la carpeta assets
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

  // Guarda la lista actual en la memoria del dispositivo
  Future<void> saveProducts(List<Product> products) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('products', jsonEncode(products));
  }

  // Recupera la lista guardada en el dispositivo
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