import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter_products/models/products.dart';
import 'package:flutter_products/provider/products_service.dart';

class ProductEdit extends StatefulWidget {
  final Product product;
  const ProductEdit({super.key, required this.product});

  @override
  State<ProductEdit> createState() => _ProductEditState();
}

class _ProductEditState extends State<ProductEdit> {
  final ProductsService _productsService = ProductsService();
  
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _availableController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _ratingController = TextEditingController();

  late Product product;

  @override
  void initState() {
    product = widget.product;
    // Rellenamos el formulario con los datos actuales del producto
    _descriptionController.text = product.description;
    _priceController.text = product.price.toString();
    _availableController.text = DateFormat('yyyy-MM-dd').format(product.available);
    _imageUrlController.text = product.imageUrl;
    _ratingController.text = product.rating.toString();
    super.initState();
  }

  @override
  void dispose() {
    // Limpiamos memoria
    _descriptionController.dispose();
    _priceController.dispose();
    _availableController.dispose();
    _imageUrlController.dispose();
    _ratingController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageUrlController.text = pickedFile.path;
        });
      }
    } catch (e) {
      if (kDebugMode) print('Error al seleccionar imagen: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Editar ${product.description}')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              // --- Descripcion ---
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  icon: Icon(Icons.description_outlined),
                  labelText: 'Descripcion',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Introduzca una descripcion';
                  if (value.length < 5) return 'Minimo 5 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 10),
              
              // --- Precio ---
              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  icon: Icon(Icons.attach_money_outlined),
                  labelText: 'Precio',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Introduzca un precio';
                  if (double.tryParse(value) == null) return 'Valor numerico requerido';
                  return null;
                },
              ),
              const SizedBox(height: 10),
              
              // --- Fecha ---
              TextFormField(
                controller: _availableController,
                readOnly: true,
                decoration: const InputDecoration(
                  icon: Icon(Icons.calendar_today),
                  labelText: 'Disponible',
                ),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: product.available,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _availableController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                    });
                  }
                },
              ),
              const SizedBox(height: 10),
              
              // --- Imagen ---
              TextFormField(
                controller: _imageUrlController,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  icon: const Icon(Icons.image_outlined),
                  labelText: 'URL de Imagen',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.folder_open),
                    onPressed: _pickImage,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              
              // --- Rating ---
              TextFormField(
                controller: _ratingController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  icon: Icon(Icons.star_outline),
                  labelText: 'Rating (0-5)',
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final intVal = int.tryParse(value);
                    if (intVal == null || intVal < 0 || intVal > 5) return 'Entre 0 y 5';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              
              // --- Boton Guardar Cambios ---
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // Creamos un objeto nuevo pero manteniendo el ID original
                    final modifiedProduct = Product(
                      id: product.id, // Mismo ID para sobrescribir
                      description: _descriptionController.text,
                      price: double.parse(_priceController.text),
                      available: DateTime.parse(_availableController.text),
                      imageUrl: _imageUrlController.text,
                      rating: _ratingController.text.isNotEmpty
                          ? int.parse(_ratingController.text)
                          : 0,
                    );

                    // Llamamos a modificar y esperamos (await)
                    await _productsService.modifyProduct(modifiedProduct);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Producto modificado')),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Guardar cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}