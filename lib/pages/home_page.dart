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
  String errorMessage = "";

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

  // =========================
  // LOAD JSON
  // =========================

  Future<void> loadData() async {
    try {
      final jsonString = await rootBundle.loadString('assets/json/blog.json');

      final jsonData = jsonDecode(jsonString);

      setState(() {
        categories = jsonData["categories"] ?? [];
        posts = jsonData["posts"] ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  // =========================
  // TAMBAH KATEGORI
  // =========================

  void showAddCategory() {
    categoryController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Tambah Kategori"),
          content: TextField(
            controller: categoryController,
            decoration: const InputDecoration(
              labelText: "Nama Kategori",
              hintText: "Contoh: Berita",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Batal"),
            ),
            ElevatedButton(onPressed: addCategory, child: const Text("Tambah")),
          ],
        );
      },
    );
  }

  void addCategory() {
    final nama = categoryController.text.trim();

    if (nama.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nama kategori harus diisi")),
      );
      return;
    }

    final sudahAda = categories.any(
      (category) =>
          category["nama"].toString().toLowerCase() == nama.toLowerCase(),
    );

    if (sudahAda) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Kategori sudah ada")));
      return;
    }

    final newId = categories.isEmpty
        ? 1
        : categories
                  .map((category) => category["id"] as int)
                  .reduce((a, b) => a > b ? a : b) +
              1;

    final newCategory = {"id": newId, "nama": nama};

    setState(() {
      categories.add(newCategory);
      selectedCategory = newId;
    });

    categoryController.clear();

    Navigator.pop(context);

    ScaffoldMessenger.of(this.context).showSnackBar(
      SnackBar(content: Text('Kategori "$nama" berhasil ditambahkan')),
    );
  }

  // =========================
  // FORM TAMBAH / EDIT
  // =========================

  void showFormArtikel({Map? post}) {
    if (post != null) {
      editingId = post["id"];

      titleController.text = post["title"] ?? "";
      authorController.text = post["author"] ?? "";
      contentController.text = post["content"] ?? "";

      selectedCategory = post["category_id"];
    } else {
      editingId = null;

      titleController.clear();
      authorController.clear();
      contentController.clear();

      selectedCategory = categories.isNotEmpty ? categories[0]["id"] : null;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(post == null ? "Tambah Artikel" : "Edit Artikel"),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(child: formArtikel()),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: saveArtikel,
              child: Text(post == null ? "Tambah" : "Simpan"),
            ),
          ],
        );
      },
    );
  }

  Widget formArtikel() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: titleController,
          decoration: const InputDecoration(
            labelText: "Judul Artikel",
            border: OutlineInputBorder(),
          ),
        ),

        const SizedBox(height: 12),

        TextField(
          controller: authorController,
          decoration: const InputDecoration(
            labelText: "Nama Penulis",
            border: OutlineInputBorder(),
          ),
        ),

        const SizedBox(height: 12),

        // KATEGORI + TOMBOL TAMBAH
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<int>(
                value: selectedCategory,
                decoration: const InputDecoration(
                  labelText: "Kategori",
                  border: OutlineInputBorder(),
                ),
                items: categories.map<DropdownMenuItem<int>>((category) {
                  return DropdownMenuItem<int>(
                    value: category["id"],
                    child: Text(category["nama"]),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                  });
                },
              ),
            ),

            const SizedBox(width: 8),

            IconButton(
              onPressed: showAddCategory,
              icon: const Icon(Icons.add),
              tooltip: "Tambah Kategori",
            ),
          ],
        ),

        const SizedBox(height: 12),

        TextField(
          controller: contentController,
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: "Isi Artikel",
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }

  // =========================
  // SIMPAN ARTIKEL
  // =========================

  void saveArtikel() {
    final title = titleController.text.trim();
    final author = authorController.text.trim();
    final content = contentController.text.trim();

    if (title.isEmpty ||
        author.isEmpty ||
        content.isEmpty ||
        selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Semua data harus diisi")));
      return;
    }

    final selectedCategoryData = categories.firstWhere(
      (category) => category["id"] == selectedCategory,
    );

    if (editingId == null) {
      // TAMBAH ARTIKEL

      final newId = posts.isEmpty
          ? 1
          : posts
                    .map((post) => post["id"] as int)
                    .reduce((a, b) => a > b ? a : b) +
                1;

      final newPost = {
        "id": newId,
        "category_id": selectedCategory,
        "title": title,
        "content": content,
        "author": author,
        "category": selectedCategoryData["nama"],
      };

      setState(() {
        posts.add(newPost);
      });

      Navigator.pop(context);

      ScaffoldMessenger.of(this.context).showSnackBar(
        const SnackBar(content: Text("Artikel berhasil ditambahkan")),
      );
    } else {
      // EDIT ARTIKEL

      final index = posts.indexWhere((post) => post["id"] == editingId);

      if (index != -1) {
        setState(() {
          posts[index] = {
            "id": editingId,
            "category_id": selectedCategory,
            "title": title,
            "content": content,
            "author": author,
            "category": selectedCategoryData["nama"],
          };
        });
      }

      Navigator.pop(context);

      ScaffoldMessenger.of(this.context).showSnackBar(
        const SnackBar(content: Text("Artikel berhasil diperbarui")),
      );
    }
  }

  // =========================
  // HAPUS ARTIKEL
  // =========================

  void deleteArtikel(int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Hapus Artikel"),
          content: const Text("Apakah kamu yakin ingin menghapus artikel ini?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  posts.removeWhere((post) => post["id"] == id);
                });

                Navigator.pop(context);

                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(content: Text("Artikel berhasil dihapus")),
                );
              },
              child: const Text("Hapus"),
            ),
          ],
        );
      },
    );
  }

  // =========================
  // TAMPILAN
  // =========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Blog App"), centerTitle: true),

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
              child: Text("Error: $errorMessage", textAlign: TextAlign.center),
            )
          : posts.isEmpty
          ? const Center(child: Text("Belum ada artikel"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),

                    title: Text(
                      post["title"] ?? "",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),

                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Kategori: ${post["category"]}"),
                          Text("Penulis: ${post["author"]}"),
                          const SizedBox(height: 8),
                          Text(
                            post["content"] ?? "",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailPage(post: post),
                        ),
                      );
                    },

                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == "edit") {
                          showFormArtikel(post: post);
                        }

                        if (value == "delete") {
                          deleteArtikel(post["id"]);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: "edit",
                          child: Row(
                            children: [
                              Icon(Icons.edit),
                              SizedBox(width: 8),
                              Text("Edit"),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: "delete",
                          child: Row(
                            children: [
                              Icon(Icons.delete),
                              SizedBox(width: 8),
                              Text("Hapus"),
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
