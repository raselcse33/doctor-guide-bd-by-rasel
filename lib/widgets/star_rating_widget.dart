import 'package:flutter/material.dart';
import '../theme.dart';

/// Renders a row of filled/outline stars, e.g. ⭐⭐⭐⭐⭐ for a 5-star match.
class StarRatingWidget extends StatelessWidget {
  final int stars; // 0-5
  final double size;

  const StarRatingWidget({super.key, required this.stars, this.size = 18});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final filled = index < stars;
        return Icon(
          filled ? Icons.star_rounded : Icons.star_border_rounded,
          color: AppColors.star,
          size: size,
        );
      }),
    );
  }
}
