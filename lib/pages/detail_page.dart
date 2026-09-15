import 'package:flutter/material.dart';

class DetailPage extends StatelessWidget {
  final Map post;
  final VoidCallback edit;
  final VoidCallback hapus;

  const DetailPage({
    super.key,
    required this.post,
    required this.edit,
    required this.hapus,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detail Artikel',
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            // JUDUL
            Text(
              post['title'] ?? '',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            // KATEGORI
            Text(
              'Kategori: ${post['category'] ?? ''}',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 5),

            // PENULIS
            Text(
              'Penulis: ${post['author'] ?? ''}',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),

            const Divider(
              height: 30,
            ),

            // ISI ARTIKEL
            Text(
              post['content'] ?? '',
              style: const TextStyle(
                fontSize: 18,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 30),

            // TOMBOL EDIT
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: edit,
                icon: const Icon(
                  Icons.edit,
                ),
                label: const Text(
                  'Edit Artikel',
                ),
              ),
            ),

            const SizedBox(height: 10),

            // TOMBOL HAPUS
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: hapus,
                icon: const Icon(
                  Icons.delete,
                ),
                label: const Text(
                  'Hapus Artikel',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
