import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List categories = [];
  List posts = [];

  bool isLoading = true;
  String errorMessage = '';

  final titleController = TextEditingController();
  final authorController = TextEditingController();
  final contentController = TextEditingController();
  final categoryController = TextEditingController();

  int? selectedCategory;
  int? editingId;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void dispose() {
    titleController.dispose();
    authorController.dispose();
    contentController.dispose();
    categoryController.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    try {
      final jsonString = await rootBundle.loadString('assets/json/blog.json');

      final jsonData = jsonDecode(jsonString);

      setState(() {
        categories = jsonData['categories'] ?? [];
        posts = jsonData['posts'] ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  void showAddCategory() {
    categoryController.clear();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Tambah Kategori'),

          content: TextField(
            controller: categoryController,
            decoration: const InputDecoration(
              labelText: 'Nama Kategori',
              hintText: 'Contoh: Berita',
              border: OutlineInputBorder(),
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Batal'),
            ),

            ElevatedButton(
              onPressed: () {
                addCategory(dialogContext);
              },
              child: const Text('Tambah'),
            ),
          ],
        );
      },
    );
  }

  void addCategory(BuildContext dialogContext) {
    final nama = categoryController.text.trim();

    if (nama.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama kategori harus diisi')),
      );
      return;
    }

    final sudahAda = categories.any(
      (category) =>
          category['nama'].toString().toLowerCase() == nama.toLowerCase(),
    );

    if (sudahAda) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Kategori sudah ada')));
      return;
    }

    // Membuat ID baru
    int newId = 1;

    if (categories.isNotEmpty) {
      newId =
          categories
              .map((category) => category['id'] as int)
              .reduce((a, b) => a > b ? a : b) +
          1;
    }

    final newCategory = {'id': newId, 'nama': nama};

    // Tambahkan kategori
    setState(() {
      categories.add(newCategory);
      selectedCategory = newId;
    });

    // Tutup dialog kategori
    Navigator.pop(dialogContext);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Kategori "$nama" berhasil ditambahkan')),
    );
  }

  void showFormArtikel({Map? post}) {
    if (post != null) {
      // MODE EDIT
      editingId = post['id'];

      titleController.text = post['title'] ?? '';
      authorController.text = post['author'] ?? '';
      contentController.text = post['content'] ?? '';

      selectedCategory = post['category_id'];
    } else {
      // MODE TAMBAH
      editingId = null;

      titleController.clear();
      authorController.clear();
      contentController.clear();

      if (categories.isNotEmpty) {
        selectedCategory = categories[0]['id'];
      } else {
        selectedCategory = null;
      }
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(post == null ? 'Tambah Artikel' : 'Edit Artikel'),

          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: StatefulBuilder(
                builder: (context, setDialogState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // JUDUL
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Judul Artikel',
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // PENULIS
                      TextField(
                        controller: authorController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Penulis',
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // KATEGORI
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: selectedCategory,
                              decoration: const InputDecoration(
                                labelText: 'Kategori',
                                border: OutlineInputBorder(),
                              ),

                              items: categories.map<DropdownMenuItem<int>>((
                                category,
                              ) {
                                return DropdownMenuItem<int>(
                                  value: category['id'],
                                  child: Text(category['nama']),
                                );
                              }).toList(),

                              onChanged: (value) {
                                setDialogState(() {
                                  selectedCategory = value;
                                });
                              },
                            ),
                          ),

                          const SizedBox(width: 8),

                          // TOMBOL TAMBAH KATEGORI
                          IconButton(
                            onPressed: () async {
                              categoryController.clear();

                              final nama = await showDialog<String>(
                                context: context,
                                builder: (categoryDialogContext) {
                                  return AlertDialog(
                                    title: const Text('Tambah Kategori'),

                                    content: TextField(
                                      controller: categoryController,
                                      decoration: const InputDecoration(
                                        labelText: 'Nama Kategori',
                                        hintText: 'Contoh: Berita',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),

                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(categoryDialogContext);
                                        },
                                        child: const Text('Batal'),
                                      ),

                                      ElevatedButton(
                                        onPressed: () {
                                          final nama = categoryController.text
                                              .trim();

                                          Navigator.pop(
                                            categoryDialogContext,
                                            nama,
                                          );
                                        },
                                        child: const Text('Tambah'),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (nama == null || nama.isEmpty) {
                                return;
                              }

                              // Cek kategori
                              final sudahAda = categories.any(
                                (category) =>
                                    category['nama'].toString().toLowerCase() ==
                                    nama.toLowerCase(),
                              );

                              if (sudahAda) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Kategori sudah ada'),
                                  ),
                                );
                                return;
                              }

                              // ID baru
                              int newId = 1;

                              if (categories.isNotEmpty) {
                                newId =
                                    categories
                                        .map(
                                          (category) => category['id'] as int,
                                        )
                                        .reduce((a, b) => a > b ? a : b) +
                                    1;
                              }

                              final newCategory = {'id': newId, 'nama': nama};

                              // Tambahkan kategori
                              setState(() {
                                categories.add(newCategory);
                                selectedCategory = newId;
                              });

                              // Refresh dialog artikel
                              setDialogState(() {});

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Kategori "$nama" berhasil ditambahkan',
                                  ),
                                ),
                              );
                            },

                            icon: const Icon(Icons.add),

                            tooltip: 'Tambah Kategori',
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // ISI ARTIKEL
                      TextField(
                        controller: contentController,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          labelText: 'Isi Artikel',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Batal'),
            ),

            ElevatedButton(
              onPressed: () {
                saveArtikel(dialogContext);
              },
              child: Text(post == null ? 'Tambah' : 'Simpan'),
            ),
          ],
        );
      },
    );
  }

  void saveArtikel(BuildContext dialogContext) {
    final title = titleController.text.trim();
    final author = authorController.text.trim();
    final content = contentController.text.trim();

    if (title.isEmpty ||
        author.isEmpty ||
        content.isEmpty ||
        selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Semua data harus diisi')));
      return;
    }

    final category = categories.firstWhere(
      (item) => item['id'] == selectedCategory,
    );

    if (editingId == null) {
      int newId = 1;

      if (posts.isNotEmpty) {
        newId =
            posts
                .map((post) => post['id'] as int)
                .reduce((a, b) => a > b ? a : b) +
            1;
      }

      final newPost = {
        'id': newId,
        'category_id': selectedCategory,
        'title': title,
        'content': content,
        'author': author,
        'category': category['nama'],
      };

      setState(() {
        posts.add(newPost);
      });

      Navigator.pop(dialogContext);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Artikel berhasil ditambahkan')),
      );
    }

    else {
      final index = posts.indexWhere((post) => post['id'] == editingId);

      if (index != -1) {
        setState(() {
          posts[index] = {
            'id': editingId,
            'category_id': selectedCategory,
            'title': title,
            'content': content,
            'author': author,
            'category': category['nama'],
          };
        });
      }

      Navigator.pop(dialogContext);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Artikel berhasil diperbarui')),
      );
    }
  }

  void deleteArtikel(int id) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Artikel'),

          content: const Text('Apakah kamu yakin ingin menghapus artikel ini?'),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Batal'),
            ),

            ElevatedButton(
              onPressed: () {
                setState(() {
                  posts.removeWhere((post) => post['id'] == id);
                });

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Artikel berhasil dihapus')),
                );
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Blog App'), centerTitle: true),

      // Tombol tambah artikel
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showFormArtikel();
        },
        child: const Icon(Icons.add),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Error:\n$errorMessage',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : posts.isEmpty
          ? const Center(child: Text('Belum ada artikel'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),

                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),

                    // JUDUL
                    title: Text(
                      post['title'] ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    // DATA ARTIKEL
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text('Kategori: ${post['category']}'),

                          Text('Penulis: ${post['author']}'),

                          const SizedBox(height: 8),

                          Text(
                            post['content'] ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // DETAIL
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailPage(post: post),
                        ),
                      );
                    },

                    // EDIT / HAPUS
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          showFormArtikel(post: post);
                        }

                        if (value == 'delete') {
                          deleteArtikel(post['id']);
                        }
                      },

                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',

                          child: Row(
                            children: [
                              Icon(Icons.edit),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),

                        const PopupMenuItem(
                          value: 'delete',

                          child: Row(
                            children: [
                              Icon(Icons.delete),
                              SizedBox(width: 8),
                              Text('Hapus'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
