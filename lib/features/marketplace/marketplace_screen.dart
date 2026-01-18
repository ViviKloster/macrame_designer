// lib/features/marketplace/marketplace_screen.dart
import 'package:flutter/material.dart';

class MarketplaceScreen extends StatelessWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Marketplace', style: TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header del marketplace
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFF4CAF50).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.storefront, size: 40, color: Color(0xFF4CAF50)),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Vende tus creaciones',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                        Text(
                          'Comparte y vende los productos que has hecho siguiendo nuestros patrones',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24),
            
            // Productos en venta
            Text(
              'Productos en venta',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2D3748),
              ),
            ),
            
            SizedBox(height: 12),
            
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: 6,
              itemBuilder: (context, index) {
                return _buildProductCard(context, index);
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navegar de vuelta para publicar
          Navigator.pop(context);
        },
        icon: Icon(Icons.add),
        label: Text('Vender producto'),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, int index) {
    // Definir la lista de productos con tipos explícitos
    final List<Map<String, dynamic>> products = [
      {
        'title': 'Tapiz Ángel Blanco',
        'price': 89.99,
        'seller': 'María González',
        'rating': 4.8,
        'sold': 12,
        'image': 'assets/images/Tapiz_angel1.jpg',
      },
      {
        'title': 'Centro de Mesa Natural',
        'price': 149.99,
        'seller': 'Carlos Rodríguez',
        'rating': 4.9,
        'sold': 8,
        'image': 'assets/images/Centro-de-mesa1.jpg',
      },
      {
        'title': 'Corazón Rojo Grande',
        'price': 59.99,
        'seller': 'Ana Martínez',
        'rating': 4.7,
        'sold': 25,
        'image': 'assets/images/Corazon2.jpg',
      },
      {
        'title': 'Cartera de Cuero Sintético',
        'price': 79.99,
        'seller': 'Luis Fernández',
        'rating': 4.5,
        'sold': 18,
        'image': 'assets/images/cartera_de_mano.jpg',
      },
      {
        'title': 'Flor de Loto Rosa',
        'price': 129.99,
        'seller': 'Sofía López',
        'rating': 4.8,
        'sold': 6,
        'image': 'assets/images/Tapiz_flor_de_loto.jpg',
      },
      {
        'title': 'Banderín Multicolor',
        'price': 34.99,
        'seller': 'Pedro Sánchez',
        'rating': 4.3,
        'sold': 32,
        'image': 'assets/images/banderin.jpg',
      },
    ];
    
    final Map<String, dynamic> product = products[index];
    
    // Obtener los valores con seguridad
    final String title = product['title'] as String;
    final double price = (product['price'] as num).toDouble();
    final String seller = product['seller'] as String;
    final double rating = (product['rating'] as num).toDouble();
    final int sold = product['sold'] as int;
    final String image = product['image'] as String;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                image: DecorationImage(
                  image: AssetImage(image),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          
          // Información
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                SizedBox(height: 4),
                
                Text(
                  'Por $seller',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
                
                SizedBox(height: 8),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '\$${price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.star, size: 12, color: Colors.amber),
                            SizedBox(width: 2),
                            Text(
                              rating.toStringAsFixed(1),
                              style: TextStyle(fontSize: 11),
                            ),
                            SizedBox(width: 4),
                            Text(
                              '($sold vendidos)',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    ElevatedButton(
                      onPressed: () {
                        // Comprar producto - ahora context está disponible
                        _showBuyDialog(context, title, price, seller);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF4CAF50),
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        minimumSize: Size(0, 0),
                      ),
                      child: Text(
                        'Comprar',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showBuyDialog(BuildContext context, String title, double price, String seller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Comprar producto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Deseas comprar "$title"?',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.person, color: Color(0xFF4CAF50)),
              title: Text('Vendedor'),
              subtitle: Text(seller),
            ),
            ListTile(
              leading: Icon(Icons.attach_money, color: Colors.green),
              title: Text('Precio'),
              subtitle: Text(
                '\$${price.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.green,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.local_shipping, color: Color(0xFF2196F3)),
              title: Text('Envío'),
              subtitle: Text('Gratis dentro de la ciudad'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showPurchaseSuccess(context, title);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF4CAF50),
            ),
            child: Text('Confirmar compra'),
          ),
        ],
      ),
    );
  }

  void _showPurchaseSuccess(BuildContext context, String productName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¡Compra exitosa!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 60, color: Colors.green),
            SizedBox(height: 20),
            Text(
              'Has comprado "$productName"',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'El vendedor se pondrá en contacto contigo para coordinar la entrega.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Aceptar'),
          ),
        ],
      ),
    );
  }
}