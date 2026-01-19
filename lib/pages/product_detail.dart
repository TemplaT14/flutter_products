import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_products/models/products.dart';
import 'package:flutter_products/provider/products_service.dart';
import 'package:flutter_products/pages/product_edit.dart';

class ProductDetail extends StatefulWidget {
  final Product product;

  // Recibimos el producto desde la lista
  const ProductDetail({super.key, required this.product});

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  late Product product;

  @override
  void initState() {
    product = widget.product;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Importante: Creamos un proveedor nuevo solo para esta pantalla
    // Esto evita problemas al volver de otras paginas
    return ChangeNotifierProvider(
      create: (_) => ProductsService(),
      child: Consumer<ProductsService>(
        builder: (context, productsService, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text(product.description),
              actions: [
                // --- Boton Editar ---
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Editar Producto',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductEdit(product: product),
                      ),
                    ).then((_) {
                      // Al volver de editar, recargamos el producto desde el servicio
                      // para ver los cambios reflejados inmediatamente
                      final updatedProduct = productsService.getProduct(product.id);
                      setState(() {
                        product = updatedProduct;
                      });
                    });
                  },
                ),
                
                // --- Boton Eliminar ---
                IconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: 'Eliminar Producto',
                  onPressed: () {
                    // Mostramos dialogo de confirmacion
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Confirmar'),
                          content: Text('¿Esta seguro de eliminar "${product.description}"?'),
                          actions: [
                            TextButton(
                              child: const Text('Cancelar'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: const Text('Eliminar'),
                              onPressed: () {
                                // Borramos y cerramos la pantalla
                                productsService.removeProduct(product);
                                Navigator.of(context).pop(); // Cierra dialogo
                                Navigator.of(context).pop(); // Vuelve a la lista
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  // Imagen grande
                  SizedBox(
                    width: double.infinity,
                    height: 200,
                    child: product.imageUrl.isNotEmpty
                        ? (product.imageUrl.startsWith('http')
                            ? Image.network(product.imageUrl, fit: BoxFit.cover)
                            : Image.file(File(product.imageUrl), fit: BoxFit.cover))
                        : const Icon(Icons.image_outlined, size: 200, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  
                  // Textos de informacion
                  Text(
                    product.description,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '${product.price} €',
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    DateFormat('dd/MM/yyyy').format(product.available),
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Rating: ${product.rating}',
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}