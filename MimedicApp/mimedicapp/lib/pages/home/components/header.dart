import 'package:flutter/material.dart';
import 'package:mimedicapp/configs/colors.dart';

class Header extends StatelessWidget {
  final String titulo;
  final String imagePath;

  const Header({
    super.key,
    required this.titulo,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Image.asset(
            imagePath,
            height: 70,
          ),
        ),
        Text(
          titulo,
          style: const TextStyle(
            fontFamily: 'Titulo',
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}