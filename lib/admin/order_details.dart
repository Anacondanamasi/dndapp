import 'package:flutter/material.dart';
import 'package:jewello/utils/theme/appbar_theme.dart';
import 'package:jewello/utils/theme/text_theme.dart';
class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key});

  @override
  State<OrderDetailScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<OrderDetailScreen> {
  String selectedSize = "42";
  String quantity = "1";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarThemeStyle(
        title: 'Product Detail',
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
        
            children: [
              Container(
                height: 500,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),

                child: ClipRRect(
                  child: Image.asset(
                    "assets/images/banner2.jpg",
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Center(
                      child: Icon(
                        Icons.diamond,
                        color: Color(0xFFD4AF37),
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 25),

              // Product Description
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8F8),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order Details',
                        style: DDSilverTextStyles.prodDescTitle,
                      ),
                      SizedBox(height: 10),
                      Text("""
Product Name : Pearl Bangles
Order Id : #12
Order date : 12-03-2025
Customer Namr : Rushi Sorathiya
Address : RK university
Status :  Deliverd
Amount : 1199""",
                        style: DDSilverTextStyles.prodDesc,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 30),
            ],
            
          ),
        ),   
      ),    
    );
  }
}
