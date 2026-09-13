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
  List posts = [];
  List categories = [];

  bool isLoading = true;
  String errorMessage = "";

  final TextEditingController titleController =
      TextEditingController();

  final TextEditingController authorController =
      TextEditingController();

  final TextEditingController contentController =
      TextEditingController();

  int? selectedCategory;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/json/blog.json',
      );

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

      print("Error membaca JSON: $e");
    }
  }

  void clearForm() {
    titleController.clear();
    authorController.clear();
    contentController.clear();
    selectedCategory = null;
  }

  void showAddForm() {
    clearForm();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Tambah Artikel"),

          content: formArtikel(),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Batal"),
            ),

            ElevatedButton(
              onPressed: () {
                addPost();
              },
              child: const Text("Tambah"),
            ),
          ],
        );
      },
    );
  }

  void addPost() {
    if (titleController.text.trim().isEmpty ||
        authorController.text.trim().isEmpty ||
        contentController.text.trim().isEmpty ||
        selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Semua data harus diisi"),
        ),
      );

      return;
    }

    final category = categories.firstWhere(
      (item) => item["id"] == selectedCategory,
    );

    final newId = posts.isEmpty
        ? 1
        : posts
                .map((post) => post["id"] as int)
                .reduce((a, b) => a > b ? a : b) +
            1;

    final newPost = {
      "id": newId,
      "category_id": selectedCategory,
      "title": titleController.text.trim(),
      "content": contentController.text.trim(),
      "author": authorController.text.trim(),
      "category": category["nama"],
    };

    setState(() {
      posts.add(newPost);
    });

    clearForm();

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Artikel berhasil ditambahkan"),
      ),
    );
  }

  void showEditForm(Map post) {
    titleController.text = post["title"] ?? "";
    authorController.text = post["author"] ?? "";
    contentController.text = post["content"] ?? "";
    selectedCategory = post["category_id"];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Artikel"),

          content: formArtikel(),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Batal"),
            ),

            ElevatedButton(
              onPressed: () {
                updatePost(post);
              },
              child: const Text("Update"),
            ),
          ],
        );
      },
    );
  }

  void updatePost(Map post) {
    if (titleController.text.trim().isEmpty ||
        authorController.text.trim().isEmpty ||
        contentController.text.trim().isEmpty ||
        selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Semua data harus diisi"),
        ),
      );

      return;
    }

    final category = categories.firstWhere(
      (item) => item["id"] == selectedCategory,
    );

    setState(() {
      post["category_id"] = selectedCategory;
      post["title"] = titleController.text.trim();
      post["content"] = contentController.text.trim();
      post["author"] = authorController.text.trim();
      post["category"] = category["nama"];
    });

    clearForm();

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Artikel berhasil diupdate"),
      ),
    );
  }

  void confirmDelete(Map post) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Hapus Artikel"),

          content: Text(
            'Apakah kamu yakin ingin menghapus "${post["title"]}"?',
          ),

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
                  posts.remove(post);
                });

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Artikel berhasil dihapus"),
                  ),
                );
              },
              child: const Text("Hapus"),
            ),
          ],
        );
      },
    );
  }

  Widget formArtikel() {
    return SizedBox(
      width: 400,

      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // JUDUL
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Nama Artikel",
                hintText: "Masukkan nama artikel",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            // KATEGORI
            DropdownButtonFormField<int>(
              value: selectedCategory,

              decoration: const InputDecoration(
                labelText: "Kategori",
                border: OutlineInputBorder(),
              ),

              items: categories.map<DropdownMenuItem<int>>(
                (category) {
                  return DropdownMenuItem<int>(
                    value: category["id"],
                    child: Text(category["nama"]),
                  );
                },
              ).toList(),

              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                });
              },
            ),

            const SizedBox(height: 15),

            // PENULIS
            TextField(
              controller: authorController,
              decoration: const InputDecoration(
                labelText: "Nama Penulis",
                hintText: "Masukkan nama penulis",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            // ISI
            TextField(
              controller: contentController,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: "Isi Artikel",
                hintText: "Masukkan isi artikel",
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // BUILD
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Koleksi Artikel"),
        centerTitle: true,
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    "Gagal membaca JSON:\n$errorMessage",
                    textAlign: TextAlign.center,
                  ),
                )
              : posts.isEmpty
                  ? const Center(
                      child: Text(
                        "Belum ada artikel",
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: posts.length,

                      itemBuilder: (context, index) {
                        final post = posts[index];

                        return Card(
                          margin: const EdgeInsets.only(
                            bottom: 15,
                          ),

                          elevation: 3,

                          child: Padding(
                            padding: const EdgeInsets.all(16),

                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,

                              children: [

                                Text(
                                  post["title"] ?? "",

                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 10),

                                Row(
                                  children: [
                                    const Icon(
                                      Icons.category,
                                      size: 18,
                                    ),

                                    const SizedBox(width: 6),

                                    Text(
                                      post["category"] ?? "",
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 6),

                                Row(
                                  children: [
                                    const Icon(
                                      Icons.person,
                                      size: 18,
                                    ),

                                    const SizedBox(width: 6),

                                    Text(
                                      post["author"] ?? "",
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                Text(
                                  post["content"] ?? "",

                                  maxLines: 3,

                                  overflow:
                                      TextOverflow.ellipsis,

                                  style: const TextStyle(
                                    fontSize: 15,
                                    height: 1.5,
                                  ),
                                ),

                                const SizedBox(height: 10),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.end,

                                  children: [
                                    // DETAIL
                                    TextButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    DetailPage(
                                              post: post,
                                            ),
                                          ),
                                        );
                                      },

                                      icon: const Icon(
                                        Icons.visibility,
                                      ),

                                      label: const Text(
                                        "Detail",
                                      ),
                                    ),

                                    TextButton.icon(
                                      onPressed: () {
                                        showEditForm(post);
                                      },

                                      icon: const Icon(
                                        Icons.edit,
                                      ),

                                      label: const Text(
                                        "Edit",
                                      ),
                                    ),

                                    TextButton.icon(
                                      onPressed: () {
                                        confirmDelete(post);
                                      },

                                      icon: const Icon(
                                        Icons.delete,
                                      ),

                                      label: const Text(
                                        "Hapus",
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

      floatingActionButton: FloatingActionButton(
        onPressed: showAddForm,

        child: const Icon(Icons.add),
      ),
    );
  }
}