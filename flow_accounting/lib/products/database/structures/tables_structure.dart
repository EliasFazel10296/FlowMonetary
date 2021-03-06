/*
 * Copyright © 2022 By Geeks Empire.
 *
 * Created by Elias Fazel
 * Last modified 3/19/22, 5:57 AM
 *
 * Licensed Under MIT License.
 * https://opensource.org/licenses/MIT
 */

import 'package:flow_accounting/resources/ColorsResources.dart';

class ProductsData {

  final int id;

  final String productImageUrl;

  final String productName;
  final String productDescription;

  final String productCategory;

  final String productBrand;
  final String productBrandLogoUrl;

  final String productPrice;
  final String productProfitPercent;

  final String productTax;

  int productQuantity = 0;
  final String productQuantityType;

  final String extraBarcodeData;

  int colorTag = ColorsResources.dark.value;

  ProductsData({
    required this.id,

    required this.productImageUrl,

    required this.productName,
    required this.productDescription,

    required this.productCategory,

    required this.productBrand,
    required this.productBrandLogoUrl,

    required this.productPrice,
    required this.productProfitPercent,

    required this.productTax,

    required this.productQuantity,
    required this.productQuantityType,

    required this.extraBarcodeData,

    required this.colorTag,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,

      'productImageUrl': productImageUrl,

      'productName': productName,
      'productDescription': productDescription,

      'productCategory': productCategory,

      'productBrand': productBrand,
      'productBrandLogoUrl': productBrandLogoUrl,

      'productPrice': productPrice,
      'productProfitPercent': productProfitPercent,

      'productTax': productTax,

      'productQuantity': productQuantity,
      'productQuantityType': productQuantityType,

      'extraBarcodeData': extraBarcodeData,

      'colorTag': colorTag,
    };
  }

  @override
  String toString() {
    return 'ProductsData{'
      'id: $id,'

      'productImageUrl: $productImageUrl,'

      'productName: $productName,'
      'productDescription: $productDescription,'

      'productCategory: $productCategory,'

      'productBrand: $productBrand,'
      'productBrandLogoUrl: $productBrandLogoUrl,'

      'productPrice: $productPrice,'
      'productProfitPercent: $productProfitPercent,'

      'productTax: $productTax,'

      'productQuantity: $productQuantity,'
      'productQuantityType: $productQuantityType,'

      'extraBarcodeData: $extraBarcodeData,'

      'colorTag: $colorTag,'
    '}';
  }
}
