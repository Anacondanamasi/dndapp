import 'package:jewello/data/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jewello/features/products/controllers/review_controller.dart';
import 'package:jewello/utils/loaders.dart';
import 'package:jewello/utils/theme/appbar_theme.dart';
import 'package:jewello/utils/theme/buttons_theme.dart';
import 'package:jewello/utils/theme/dropdown_theme.dart';
import 'package:jewello/utils/validator.dart';

class ReviewScreen extends StatefulWidget {
  final String productId;
  const ReviewScreen({super.key, required this.productId});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {

  final _formKey = GlobalKey<FormState>();
  final reviewController = Get.put(ReviewController());


  @override
  void initState(){
    super.initState();
    reviewController.productId = widget.productId;
    reviewController.userId = AuthService.instance.sbUser?.id;
  }

  final TextEditingController comment = TextEditingController();
  String rating = "5";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarThemeStyle(
        title: 'Add Review'
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [   
                // Reviews section
                const Text(
                  'Review',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Review text field
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextFormField(
                    controller: comment,
                    validator: (value) => Validator.validateText(value, 'Review'),
                    maxLines: 8,
                    decoration: const InputDecoration(
                      hintText: 'Add review...',
                      hintStyle: TextStyle(
                        color: Color(0xFF9E9E9E),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Rating section
                const Text(
                  'Rating',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                ),
                const SizedBox(height: 12),
            
                CustomDropdownTheme(
                  label: 'Give Rating',
                  options: ['5', '4', '3', '2', '1'],
                  initialValue: '5',
                  onChanged: (q) => rating = q,
                  needLabel: false,
                ),
                
                DDSilverAuthButton(
                  text: 'Submit',
                  onPressed: () {
                    // Navigator.pop(context);
                    if(comment.text.trim() != "" && rating != ""){
                      reviewController.submitReview(rating: rating, comment: comment.text.trim());
                    }else{
                      Loaders.warningSnackBar(title: 'Incomplete', message: 'Please provide both review and rating');
                    }
                  },
            
                  inv: true
                ),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
