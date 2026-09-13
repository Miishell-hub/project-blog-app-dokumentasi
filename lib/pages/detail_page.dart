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
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            Text(
              post["title"] ?? "Tanpa Judul",

              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                const Icon(Icons.category),

                const SizedBox(width: 8),

                Text(
                  post["category"] ?? "Tanpa Kategori",

                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(Icons.person),

                const SizedBox(width: 8),

                Text(
                  "Penulis: ${post["author"] ?? "Tidak diketahui"}",

                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Divider(),

            const SizedBox(height: 20),

            const Text(
              "Isi Artikel",

              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              post["content"] ??
                  "Isi artikel tidak tersedia.",

              textAlign: TextAlign.justify,

              style: const TextStyle(
                fontSize: 17,
                height: 1.7,
              ),
            ),
          ],
        ),
      ),
    );
  }
}