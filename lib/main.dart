import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_products/provider/products_service.dart';
import 'package:flutter_products/pages/product_add.dart';
import 'package:flutter_products/pages/product_detail.dart';

void main() {
  runApp(const ProductsApp());
}

class ProductsApp extends StatelessWidget {
  const ProductsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Products',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const Products(),
    );
  }
}

class Products extends StatefulWidget {
  const Products({super.key});

  @override
  State<Products> createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  @override
  Widget build(BuildContext context) {
    // ChangeNotifierProvider: Inyecta el servicio de datos en esta pantalla
    return ChangeNotifierProvider(
      create: (_) => ProductsService(),
      child: Consumer<ProductsService>(
        // Consumer: Escucha cambios en el servicio para redibujar la lista
        builder: (context, productsService, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Productos'),
              actions: [
                // Boton + para ir a la pantalla de crear
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProductAdd(),
                      ),
                    ).then((_) {
                      // Importante: Refresca la lista al volver de crear
                      setState(() {});
                    });
                  },
                ),
              ],
            ),
            // Constructor eficiente de la lista
            body: ListView.builder(
              itemCount: ProductsService.products.length,
              itemBuilder: (context, index) {
                final product = ProductsService.products[index];
                return ListTile(
                  // Al pulsar un elemento vamos al detalle
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetail(product: product),
                      ),
                    ).then((_) {
                      // Refresca la lista al volver (por si borramos el producto)
                      setState(() {});
                    });
                  },
                  // Logica para mostrar imagen (Web vs Local vs Icono vacio)
                  leading: SizedBox(
                    width: 60,
                    height: 60,
                    child: product.imageUrl.isNotEmpty
                        ? (product.imageUrl.startsWith('http')
                            ? Image.network(
                                product.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.broken_image),
                              )
                            : Image.file(
                                File(product.imageUrl),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.broken_image),
                              ))
                        : const Icon(Icons.image_outlined, size: 50),
                  ),
                  title: Text(product.description),
                  subtitle: Text('${product.price} €'),
                  // Genera las estrellas de valoracion (llenas vs vacias)
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < product.rating; i++)
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                      for (var i = 0; i < 5 - product.rating; i++)
                        const Icon(Icons.star, color: Colors.grey, size: 14),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}