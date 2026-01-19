import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/products.dart';

class ProductsService extends ChangeNotifier {
  // Lista estática de productos
  static List<Product> products = [];

  ProductsService() {
    // Al iniciar, intentamos cargar los productos guardados
    loadProducts().then((value) {
      products = value;
      notifyListeners();

      // Si no hay productos guardados (primera vez), cargamos el JSON por defecto
      if (products.isEmpty) {
        readJsonFile().then((value) {
          products = value;
          saveProducts(products); // Los guardamos en local para la próxima
          notifyListeners();
        });
      }
    });
  }

  // --- CRUD (Create, Read, Update, Delete) ---

  // Añade un nuevo producto
  void addProduct(Product product) {
    products.add(product);
    saveProducts(products);
    notifyListeners();
  }

  // Elimina un producto
  void removeProduct(Product product) {
    products.removeWhere((element) => element.id == product.id);
    saveProducts(products);
    notifyListeners();
  }

  // Obtiene un producto por ID
  Product getProduct(int id) {
    return products.firstWhere((element) => element.id == id);
  }

  // Modifica un producto existente
  void modifyProduct(Product product) {
    int index = products.indexWhere((element) => element.id == product.id);
    products[index] = product;
    saveProducts(products);
    notifyListeners();
  }

  // --- PERSISTENCIA DE DATOS ---

  // Lee el archivo JSON original (assets)
  Future<List<Product>> readJsonFile() async {
    String jsonString = await rootBundle.loadString('assets/products.json');
    List jsonList = jsonDecode(jsonString);
    List<Product> products = [];
    for (var item in jsonList) {
      Product product = Product.fromJson(item);
      products.add(product);
    }
    return products;
  }

  // Guarda la lista en el almacenamiento local (SharedPreferences)
  Future<void> saveProducts(List<Product> products) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('products', jsonEncode(products));
  }

  // Carga la lista del almacenamiento local
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

  // Borra todo (opcional, útil para pruebas)
  Future<void> clearProducts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('products');
    products = [];
    notifyListeners();
  }
}