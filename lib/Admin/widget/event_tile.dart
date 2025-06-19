import 'package:flutter/material.dart';

class EventTile extends StatelessWidget {
  final String title;
  final num price;
  final bool boosted;
  final VoidCallback onTap;

  const EventTile({
    super.key,
    required this.title,
    required this.price,
    required this.boosted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Icon(Icons.event, color: boosted ? Colors.orange : Colors.grey),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("Price: \$${price.toStringAsFixed(0)}"),
        trailing: boosted
            ? const Chip(
                label: Text("Boosted", style: TextStyle(color: Colors.white)),
                backgroundColor: Colors.orange,
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}
