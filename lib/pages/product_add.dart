import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter_products/models/products.dart';
import 'package:flutter_products/provider/products_service.dart';

class ProductAdd extends StatefulWidget {
  const ProductAdd({super.key});

  @override
  State<ProductAdd> createState() => _ProductAddState();
}

class _ProductAddState extends State<ProductAdd> {
  // Instanciamos el servicio directamente (como indica el tutorial)
  final ProductsService _productsService = ProductsService();
  
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _availableController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _ratingController = TextEditingController();

  @override
  void dispose() {
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
      appBar: AppBar(title: const Text('Nuevo Producto')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  icon: Icon(Icons.description_outlined),
                  labelText: 'Descripción',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Introduzca una descripción';
                  if (value.length < 5) return 'Mínimo 5 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  icon: Icon(Icons.attach_money_outlined),
                  labelText: 'Precio',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Introduzca un precio';
                  if (double.tryParse(value) == null) return 'Valor numérico requerido';
                  if (double.parse(value) <= 0) return 'Mayor que 0';
                  return null;
                },
              ),
              const SizedBox(height: 10),
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
                    initialDate: DateTime.now(),
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
              TextFormField(
                controller: _imageUrlController,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  icon: const Icon(Icons.image_outlined),
                  labelText: 'Image URL',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.folder_open),
                    onPressed: _pickImage,
                  ),
                ),
              ),
              const SizedBox(height: 10),
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
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final newProduct = Product(
                      id: DateTime.now().millisecondsSinceEpoch,
                      description: _descriptionController.text,
                      price: double.parse(_priceController.text),
                      available: _availableController.text.isNotEmpty
                          ? DateTime.parse(_availableController.text)
                          : DateTime.now(),
                      imageUrl: _imageUrlController.text,
                      rating: _ratingController.text.isNotEmpty
                          ? int.parse(_ratingController.text)
                          : 0,
                    );
                    _productsService.addProduct(newProduct);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Producto añadido')),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Crear'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}