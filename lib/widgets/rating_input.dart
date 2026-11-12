import 'package:flutter/material.dart';

// Reusable widget: input rating bintang 1–5 sebagai FormField
// (bisa divalidasi bersama field lain di dalam Form).
class RatingInput extends FormField<int> {
  RatingInput({
    super.key,
    super.initialValue,
    super.validator,
    ValueChanged<int?>? onChanged,
  }) : super(
         builder: (state) {
           final scheme = Theme.of(state.context).colorScheme;
           return Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Row(
                 children: [
                   for (var i = 1; i <= 5; i++)
                     IconButton(
                       tooltip: '$i bintang',
                       onPressed: () {
                         // Tap bintang yang sama -> hapus rating.
                         final value = state.value == i ? null : i;
                         state.didChange(value);
                         onChanged?.call(value);
                       },
                       icon: Icon(
                         i <= (state.value ?? 0)
                             ? Icons.star_rounded
                             : Icons.star_outline_rounded,
                         color: Colors.amber.shade700,
                         size: 32,
                       ),
                     ),
                   const SizedBox(width: 8),
                   Text(
                     state.value == null ? 'Belum dinilai' : '${state.value}/5',
                   ),
                 ],
               ),
               if (state.hasError)
                 Padding(
                   padding: const EdgeInsets.only(left: 12),
                   child: Text(
                     state.errorText!,
                     style: TextStyle(color: scheme.error, fontSize: 12),
                   ),
                 ),
             ],
           );
         },
       );
}

// Tampilan rating read-only (dipakai di list & detail).
class RatingStars extends StatelessWidget {
  const RatingStars({super.key, required this.rating, this.size = 16});

  final int? rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          Icon(
            i <= (rating ?? 0)
                ? Icons.star_rounded
                : Icons.star_outline_rounded,
            size: size,
            color: Colors.amber.shade700,
          ),
      ],
    );
  }
}
