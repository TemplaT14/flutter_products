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
  // Instanciamos el servicio directamente para asegurar la conexion
  final ProductsService _productsService = ProductsService();
  
  // Clave global para identificar y validar este formulario especifico
  final _formKey = GlobalKey<FormState>();
  
  // Controladores: Capturan el texto que escribe el usuario en cada campo
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _availableController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _ratingController = TextEditingController();

  // Limpieza de memoria cuando cerramos la pantalla (evita fugas)
  @override
  void dispose() {
    _descriptionController.dispose();
    _priceController.dispose();
    _availableController.dispose();
    _imageUrlController.dispose();
    _ratingController.dispose();
    super.dispose();
  }

  // Abre la galeria del movil para seleccionar una foto
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          // Guardamos la ruta del archivo seleccionado en el campo de texto
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
        key: _formKey, // Asignamos la clave para validar todo junto luego
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              // --- Campo Descripcion ---
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
              
              // --- Campo Precio ---
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
                  if (double.parse(value) <= 0) return 'Mayor que 0';
                  return null;
                },
              ),
              const SizedBox(height: 10),
              
              // --- Campo Fecha (Selector) ---
              TextFormField(
                controller: _availableController,
                readOnly: true, // No se puede escribir a mano, solo tocar
                decoration: const InputDecoration(
                  icon: Icon(Icons.calendar_today),
                  labelText: 'Disponible',
                ),
                onTap: () async {
                  // Muestra el calendario nativo
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      // Formatea la fecha a texto (yyyy-MM-dd)
                      _availableController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                    });
                  }
                },
              ),
              const SizedBox(height: 10),
              
              // --- Campo Imagen ---
              TextFormField(
                controller: _imageUrlController,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  icon: const Icon(Icons.image_outlined),
                  labelText: 'URL de Imagen',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.folder_open),
                    onPressed: _pickImage, // Boton para abrir galeria
                  ),
                ),
              ),
              const SizedBox(height: 10),
              
              // --- Campo Rating ---
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
              
              // --- Boton Crear ---
              ElevatedButton(
                onPressed: () async {
                  // Validamos todos los campos del formulario a la vez
                  if (_formKey.currentState!.validate()) {
                    
                    // Creamos el objeto Product con los datos del formulario
                    final newProduct = Product(
                      id: DateTime.now().millisecondsSinceEpoch, // Usamos la hora como ID unico
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

                    // Guardamos usando el servicio y esperamos (await)
                    await _productsService.addProduct(newProduct);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Producto anadido')),
                    );
                    
                    // Cerramos la pantalla para volver a la lista
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