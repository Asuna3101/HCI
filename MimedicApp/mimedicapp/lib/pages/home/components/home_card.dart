import 'package:flutter/material.dart';
import 'package:mimedicapp/configs/colors.dart';

class HomeCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final VoidCallback onTap;

  const HomeCard(
      {super.key,
      required this.title,
      required this.imagePath,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: const [
            BoxShadow(
              color: Color.fromARGB(255, 168, 164, 164),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Imagen
            SizedBox(
              height: 100,
              width: 100,
              child: Image.asset(imagePath, fit: BoxFit.contain),
            ),
            const SizedBox(height: 12),
            // Texto
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
