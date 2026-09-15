import 'package:flutter/material.dart';

class DetailPage extends StatelessWidget {
  final Map post;

  const DetailPage({
    super.key,
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Artikel"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post["title"] ?? "",
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              "Kategori: ${post["category"]}",
              style: const TextStyle(
                fontSize: 16,
              ),
            ),

            Text(
              "Penulis: ${post["author"]}",
              style: const TextStyle(
                fontSize: 16,
              ),
            ),

            const Divider(height: 30),

            Text(
              post["content"] ?? "",
              style: const TextStyle(
                fontSize: 18,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}