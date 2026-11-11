import 'package:flutter/material.dart';

class ImageService {
  static final ImageService _instance = ImageService._internal();

  factory ImageService() {
    return _instance;
  }

  ImageService._internal();

  Widget getImage(String imagePath, String type) {
    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Ошибка загрузки изображения: $imagePath');
        return Container(
          color: Colors.grey[300],
          child: const Center(
            child: Icon(
              Icons.image_not_supported,
              size: 64,
              color: Colors.grey,
            ),
          ),
        );
      },
    );
  }
}
