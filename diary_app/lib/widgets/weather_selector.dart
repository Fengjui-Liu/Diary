import 'package:flutter/material.dart';
import '../models/diary_entry.dart';

class WeatherSelector extends StatelessWidget {
  final String selectedWeather;
  final Function(String) onWeatherSelected;

  const WeatherSelector({
    super.key,
    required this.selectedWeather,
    required this.onWeatherSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: DiaryEntry.weatherOptions.map((weather) {
        final isSelected = selectedWeather == weather['label'];
        return InkWell(
          onTap: () => onWeatherSelected(weather['label']!),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.secondary
                  : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.secondary
                    : Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  weather['emoji']!,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 8),
                Text(
                  weather['label']!,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
