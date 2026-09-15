import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List categories = [];
  List posts = [];

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
  // LOAD DATA
  // =========================

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    final savedCategories = prefs.getString('categories');
    final savedPosts = prefs.getString('posts');

    setState(() {
      if (savedCategories != null) {
        categories = jsonDecode(savedCategories);
      } else {
        categories = [
          {
            'id': 1,
            'nama': 'Teknologi',
          },
          {
            'id': 2,
            'nama': 'Pendidikan',
          },
          {
            'id': 3,
            'nama': 'Olahraga',
          },
          {
            'id': 4,
            'nama': 'Lifestyle',
          },
        ];
      }

      if (savedPosts != null) {
        posts = jsonDecode(savedPosts);
      } else {
        posts = [
          {
            'id': 1,
            'category_id': 1,
            'title': 'Belajar Flutter untuk Pemula',
            'content':
                'Flutter adalah framework yang digunakan untuk membuat aplikasi mobile.',
            'author': 'Admin',
            'category': 'Teknologi',
          },
          {
            'id': 2,
            'category_id': 2,
            'title': 'Pentingnya Belajar Teknologi',
            'content':
                'Teknologi sangat penting untuk membantu kegiatan manusia sehari-hari.',
            'author': 'Admin',
            'category': 'Pendidikan',
          },
          {
            'id': 3,
            'category_id': 3,
            'title': 'Manfaat Berolahraga',
            'content':
                'Olahraga secara teratur dapat membantu menjaga kebugaran tubuh.',
            'author': 'Admin',
            'category': 'Olahraga',
          },
        ];
      }
    });

    await saveData();
  }

  // =========================
  // SAVE DATA
  // =========================

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'categories',
      jsonEncode(categories),
    );

    await prefs.setString(
      'posts',
      jsonEncode(posts),
    );
  }

  // =========================
  // TAMBAH KATEGORI
  // =========================

  void showAddCategory(
    StateSetter setDialogState,
  ) {
    categoryController.clear();

    showDialog(
      context: context,
      builder: (categoryContext) {
        return AlertDialog(
          title: const Text('Tambah Kategori'),

          content: TextField(
            controller: categoryController,
            decoration: const InputDecoration(
              labelText: 'Nama Kategori',
              border: OutlineInputBorder(),
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(categoryContext);
              },
              child: const Text('Batal'),
            ),

            ElevatedButton(
              onPressed: () async {
                final nama =
                    categoryController.text.trim();

                if (nama.isEmpty) {
                  return;
                }

                final sudahAda = categories.any(
                  (category) =>
                      category['nama']
                          .toString()
                          .toLowerCase() ==
                      nama.toLowerCase(),
                );

                if (sudahAda) {
                  Navigator.pop(categoryContext);

                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Kategori sudah ada',
                      ),
                    ),
                  );

                  return;
                }

                int newId = 1;

                if (categories.isNotEmpty) {
                  newId = categories
                          .map(
                            (category) =>
                                category['id'] as int,
                          )
                          .reduce(
                            (a, b) => a > b ? a : b,
                          ) +
                      1;
                }

                setState(() {
                  categories.add({
                    'id': newId,
                    'nama': nama,
                  });

                  selectedCategory = newId;
                });

                await saveData();

                setDialogState(() {});

                Navigator.pop(categoryContext);

                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  SnackBar(
                    content: Text(
                      'Kategori "$nama" berhasil ditambahkan',
                    ),
                  ),
                );
              },
              child: const Text('Tambah'),
            ),
          ],
        );
      },
    );
  }

  // =========================
  // FORM TAMBAH / EDIT
  // =========================

  void showFormArtikel({
    Map? post,
  }) {
    if (post != null) {
      editingId = post['id'];

      titleController.text =
          post['title'] ?? '';

      authorController.text =
          post['author'] ?? '';

      contentController.text =
          post['content'] ?? '';

      selectedCategory =
          post['category_id'];
    } else {
      editingId = null;

      titleController.clear();
      authorController.clear();
      contentController.clear();

      if (categories.isNotEmpty) {
        selectedCategory =
            categories[0]['id'];
      } else {
        selectedCategory = null;
      }
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              title: Text(
                post == null
                    ? 'Tambah Artikel'
                    : 'Edit Artikel',
              ),

              content: SizedBox(
                width: 500,

                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // JUDUL
                      TextField(
                        controller: titleController,
                        decoration:
                            const InputDecoration(
                          labelText: 'Judul Artikel',
                          border:
                              OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // PENULIS
                      TextField(
                        controller: authorController,
                        decoration:
                            const InputDecoration(
                          labelText: 'Nama Penulis',
                          border:
                              OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // KATEGORI
                      Row(
                        children: [
                          Expanded(
                            child:
                                DropdownButtonFormField<
                                    int>(
                              value:
                                  selectedCategory,

                              decoration:
                                  const InputDecoration(
                                labelText: 'Kategori',
                                border:
                                    OutlineInputBorder(),
                              ),

                              items: categories.map<
                                  DropdownMenuItem<int>>(
                                (category) {
                                  return DropdownMenuItem<
                                      int>(
                                    value:
                                        category['id'],
                                    child: Text(
                                      category['nama'],
                                    ),
                                  );
                                },
                              ).toList(),

                              onChanged:
                                  (value) {
                                setDialogState(() {
                                  selectedCategory =
                                      value;
                                });
                              },
                            ),
                          ),

                          const SizedBox(width: 8),

                          IconButton(
                            onPressed: () {
                              showAddCategory(
                                setDialogState,
                              );
                            },
                            icon: const Icon(
                              Icons.add,
                            ),
                            tooltip:
                                'Tambah Kategori',
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // ISI
                      TextField(
                        controller:
                            contentController,
                        maxLines: 5,
                        decoration:
                            const InputDecoration(
                          labelText: 'Isi Artikel',
                          border:
                              OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                    );
                  },
                  child: const Text('Batal'),
                ),

                ElevatedButton(
                  onPressed: () {
                    saveArtikel(
                      dialogContext,
                    );
                  },
                  child: Text(
                    post == null
                        ? 'Tambah'
                        : 'Simpan',
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // =========================
  // SIMPAN ARTIKEL
  // =========================

  Future<void> saveArtikel(
    BuildContext dialogContext,
  ) async {
    final title =
        titleController.text.trim();

    final author =
        authorController.text.trim();

    final content =
        contentController.text.trim();

    if (title.isEmpty ||
        author.isEmpty ||
        content.isEmpty ||
        selectedCategory == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Semua data harus diisi',
          ),
        ),
      );

      return;
    }

    final category =
        categories.firstWhere(
      (item) =>
          item['id'] == selectedCategory,
    );

    if (editingId == null) {
      // TAMBAH
      int newId = 1;

      if (posts.isNotEmpty) {
        newId = posts
                .map(
                  (post) =>
                      post['id'] as int,
                )
                .reduce(
                  (a, b) => a > b ? a : b,
                ) +
            1;
      }

      posts.add({
        'id': newId,
        'category_id':
            selectedCategory,
        'title': title,
        'content': content,
        'author': author,
        'category':
            category['nama'],
      });
    } else {
      // EDIT
      final index =
          posts.indexWhere(
        (post) =>
            post['id'] == editingId,
      );

      if (index != -1) {
        posts[index] = {
          'id': editingId,
          'category_id':
              selectedCategory,
          'title': title,
          'content': content,
          'author': author,
          'category':
              category['nama'],
        };
      }
    }

    setState(() {});

    await saveData();

    Navigator.pop(dialogContext);

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          editingId == null
              ? 'Artikel berhasil ditambahkan'
              : 'Artikel berhasil diperbarui',
        ),
      ),
    );
  }

  // =========================
  // HAPUS ARTIKEL
  // =========================

  void deleteArtikel(int id) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Hapus Artikel',
          ),

          content: const Text(
            'Apakah kamu yakin ingin menghapus artikel ini?',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },
              child: const Text('Batal'),
            ),

            ElevatedButton(
              onPressed: () async {
                setState(() {
                  posts.removeWhere(
                    (post) =>
                        post['id'] == id,
                  );
                });

                await saveData();

                Navigator.pop(
                  dialogContext,
                );

                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Artikel berhasil dihapus',
                    ),
                  ),
                );
              },
              child: const Text('Hapus'),
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
      appBar: AppBar(
        title: const Text('Blog App'),
        centerTitle: true,
      ),

      floatingActionButton:
          FloatingActionButton(
        onPressed: () {
          showFormArtikel();
        },
        child: const Icon(Icons.add),
      ),

      body: posts.isEmpty
          ? const Center(
              child: Text(
                'Belum ada artikel',
              ),
            )
          : ListView.builder(
              padding:
                  const EdgeInsets.all(16),

              itemCount: posts.length,

              itemBuilder:
                  (context, index) {
                final post =
                    posts[index];

                return Card(
                  margin:
                      const EdgeInsets.only(
                    bottom: 12,
                  ),

                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.all(
                      16,
                    ),

                    title: Text(
                      post['title'] ?? '',
                      style:
                          const TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    subtitle: Padding(
                      padding:
                          const EdgeInsets.only(
                        top: 8,
                      ),

                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Text(
                            'Kategori: ${post['category']}',
                          ),

                          Text(
                            'Penulis: ${post['author']}',
                          ),

                          const SizedBox(
                            height: 8,
                          ),

                          Text(
                            post['content'] ??
                                '',
                            maxLines: 2,
                            overflow:
                                TextOverflow
                                    .ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // =====================
                    // BUKA DETAIL
                    // =====================

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  DetailPage(
                            post: post,

                            edit: () {
                              Navigator.pop(
                                context,
                              );

                              showFormArtikel(
                                post: post,
                              );
                            },

                            hapus: () {
                              Navigator.pop(
                                context,
                              );

                              deleteArtikel(
                                post['id'],
                              );
                            },
                          ),
                        ),
                      );
                    },

                    // =====================
                    // MENU EDIT / HAPUS
                    // =====================

                    trailing:
                        PopupMenuButton<
                            String>(
                      onSelected:
                          (value) {
                        if (value ==
                            'edit') {
                          showFormArtikel(
                            post: post,
                          );
                        }

                        if (value ==
                            'delete') {
                          deleteArtikel(
                            post['id'],
                          );
                        }
                      },

                      itemBuilder:
                          (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit,
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Text('Edit'),
                            ],
                          ),
                        ),

                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete,
                              ),
                              SizedBox(
                                width: 8,
                              ),
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
