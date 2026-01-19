class Product {
  // Claves para el mapa JSON
  static const String idKey = 'id';
  static const String descriptionKey = 'description';
  static const String priceKey = 'price';
  static const String availableKey = 'available';
  static const String imageUrlKey = 'imageUrl';
  static const String ratingKey = 'rating';

  // Datos del producto
  final int id;
  final String description;
  final double price;
  final DateTime available;
  final String imageUrl;
  final int rating;

  // Constructor principal
  Product({
    required this.id,
    required this.description,
    required this.price,
    required this.available,
    required this.imageUrl,
    required this.rating,
  });

  // Crea un producto desde un mapa JSON
  Product.fromJson(Map<String, dynamic> json)
      : id = int.tryParse(json[idKey].toString()) ?? 0,
        description = json[descriptionKey] != null
            ? json[descriptionKey].toString()
            : '',
        price = double.tryParse(json[priceKey].toString()) ?? 0.0,
        available = json[availableKey] != null
            ? DateTime.parse(json[availableKey].toString())
            : DateTime.now(),
        imageUrl = json[imageUrlKey] != null
            ? json[imageUrlKey].toString()
            : '',
        rating = int.tryParse(json[ratingKey].toString()) ?? 0;

  // Convierte el producto a formato JSON
  Map<String, dynamic> toJson() {
    return {
      idKey: id,
      descriptionKey: description,
      priceKey: price,
      availableKey: available.toIso8601String(),
      imageUrlKey: imageUrl,
      ratingKey: rating,
    };
  }
}