import 'package:flutter/material.dart';
import 'package:jewello/utils/theme/color_theme.dart';

class DDSilverTextStyles {
  DDSilverTextStyles._();

  static const TextStyle authHeading = TextStyle(
    fontSize: 36,
    fontFamily: 'Montserrat',
    fontWeight: FontWeight.bold,
  );

  static const TextStyle linkText = TextStyle(
    color: DDSilverColors.linkTXTColor,
    fontSize:12,
    fontFamily: 'Montserrat',
    fontWeight: FontWeight.bold,
  );

  static final TextStyle authRegular = TextStyle(
    color: DDSilverColors.authTXTRegular,
    fontFamily: 'Montserrat',
    fontSize: 14,
  );

  static final TextStyle appBarStyle = TextStyle(
    fontFamily: 'Antic Didone',
    fontSize: 30,
    fontWeight: FontWeight.w500,
    color: DDSilverColors.appBarTXT,
  );

  static const TextStyle productTitle = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 22,
    fontWeight: FontWeight.w500,
    color: DDSilverColors.appBarTXT,
  );

  static const TextStyle ratingCalc = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.black,
    fontFamily: 'Montserrat',

  );
  
  static const TextStyle totalRating = TextStyle(
    fontSize: 14,
    color: DDSilverColors.authTXTRegular,
    fontFamily: 'Montserrat',
  );

  static const TextStyle labelText = TextStyle(
    fontSize: 14,
    color: DDSilverColors.authTXTRegular,
    fontWeight: FontWeight.w500,
    fontFamily: 'Montserrat',
  );

  static const TextStyle prodDescTitle = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.black,
  );

  static const TextStyle prodDesc= TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 14,
    color: DDSilverColors.authTXTRegular,
    height: 1.5,
  );

  static const TextStyle reviewerName= TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.black,
  );

  static const TextStyle comment = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 13,
    color: DDSilverColors.authTXTRegular,
    height: 1.4,
  );

  static final Text priceLabel = Text(
    'Price',
    style:TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 14,
      color: Colors.grey[600],
      fontWeight: FontWeight.w400,
    )
  );

  static final Text revieweLabel = Text(
    'Reviews',
    style: TextStyle(
      fontSize: 18,
      fontFamily: 'Montserrat',
      fontWeight: FontWeight.w600,
      color: Colors.black,
    ),
  );

  static final TextStyle discountLabel = TextStyle(
    fontSize: 10,
    fontFamily: 'Montserrat',
    color: Colors.red[600],
    fontWeight: FontWeight.w500,
  );

  
  static finalPrice(final price, bool isProductDetails) {
    return Text(
      '$price',
      style: TextStyle(
        fontFamily: 'Montserrat',
        fontSize: isProductDetails ? 24 : 14,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    );
  }

  static Text originalPrice(final originalPrice,  bool isProductDetails) {
    return Text(
      '$originalPrice',
      style: TextStyle(
        fontSize: isProductDetails ? 18 : 13,
        fontFamily: 'Montserrat',
        color: Colors.grey[500],
        decoration: TextDecoration.lineThrough,
      ),
    );
  }

}
