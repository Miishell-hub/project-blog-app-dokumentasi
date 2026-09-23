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

  // ============================================================
  // LOAD DATA
  // ============================================================

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    final savedCategories = prefs.getString('categories');
    final savedPosts = prefs.getString('posts');

    setState(() {
      if (savedCategories != null) {
        categories = jsonDecode(savedCategories);
      } else {
        categories = [
          {'id': 1, 'nama': 'Teknologi'},
          {'id': 2, 'nama': 'Pendidikan'},
          {'id': 3, 'nama': 'Olahraga'},
          {'id': 4, 'nama': 'Lifestyle'},
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
            'content': 'Flutter adalah framework yang digunakan untuk membuat aplikasi mobile.',
            'author': 'Admin',
            'category': 'Teknologi',
          },
          {
            'id': 2,
            'category_id': 2,
            'title': 'Pentingnya Belajar Teknologi',
            'content': 'Teknologi sangat penting untuk membantu kegiatan manusia sehari-hari.',
            'author': 'Admin',
            'category': 'Pendidikan',
          },
          {
            'id': 3,
            'category_id': 3,
            'title': 'Manfaat Berolahraga',
            'content': 'Olahraga secara teratur dapat membantu menjaga kebugaran tubuh.',
            'author': 'Admin',
            'category': 'Olahraga',
          },
        ];
      }
    });

    await saveData();
  }

  // ============================================================
  // SAVE DATA
  // ============================================================

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('categories', jsonEncode(categories));

    await prefs.setString('posts', jsonEncode(posts));
  }

  // ============================================================
  // TAMBAH KATEGORI
  // ============================================================

  void showAddCategory(StateSetter setDialogState) {
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
                final nama = categoryController.text.trim();

                if (nama.isEmpty) {
                  return;
                }

                final sudahAda = categories.any(
                  (category) =>
                      category['nama'].toString().toLowerCase() ==
                      nama.toLowerCase(),
                );

                if (sudahAda) {
                  Navigator.pop(categoryContext);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Kategori sudah ada')),
                  );

                  return;
                }

                int newId = 1;

                if (categories.isNotEmpty) {
                  newId =
                      categories
                          .map((category) => category['id'] as int)
                          .reduce((a, b) => a > b ? a : b) +
                      1;
                }

                setState(() {
                  categories.add({'id': newId, 'nama': nama});

                  selectedCategory = newId;
                });

                await saveData();

                setDialogState(() {});

                Navigator.pop(categoryContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Kategori "$nama" berhasil ditambahkan'),
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

  // ============================================================
  // FORM ARTIKEL
  // ============================================================

  void showFormArtikel({Map? post}) {
    if (post != null) {
      editingId = post['id'];

      titleController.text = post['title'] ?? '';
      authorController.text = post['author'] ?? '';
      contentController.text = post['content'] ?? '';

      selectedCategory = post['category_id'];
    } else {
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
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(post == null ? 'Tambah Artikel' : 'Edit Artikel'),
              ),

              content: LayoutBuilder(
                builder: (context, constraints) {
                  return SizedBox(
                    width: constraints.maxWidth > 500
                        ? 500
                        : constraints.maxWidth,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          TextField(
                            controller: titleController,
                            decoration: const InputDecoration(
                              labelText: 'Judul Artikel',
                              border: OutlineInputBorder(),
                            ),
                          ),

                          const SizedBox(height: 12),

                          TextField(
                            controller: authorController,
                            decoration: const InputDecoration(
                              labelText: 'Nama Penulis',
                              border: OutlineInputBorder(),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // ==================================================
                          // FLEXIBLE
                          // ==================================================
                          Row(
                            children: [
                              Flexible(
                                child: DropdownButtonFormField<int>(
                                  value: selectedCategory,

                                  isExpanded: true,

                                  decoration: const InputDecoration(
                                    labelText: 'Kategori',
                                    border: OutlineInputBorder(),
                                  ),

                                  items: categories.map<DropdownMenuItem<int>>((
                                    category,
                                  ) {
                                    return DropdownMenuItem<int>(
                                      value: category['id'],
                                      child: Text(
                                        category['nama'],
                                        overflow: TextOverflow.ellipsis,
                                      ),
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

                              // ==================================================
                              // EXPANDED
                              // ==================================================
                              Expanded(
                                flex: 0,
                                child: IconButton(
                                  onPressed: () {
                                    showAddCategory(setDialogState);
                                  },
                                  icon: const Icon(Icons.add),
                                  tooltip: 'Tambah Kategori',
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

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
                      ),
                    ),
                  );
                },
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
      },
    );
  }

  // ============================================================
  // SIMPAN ARTIKEL
  // ============================================================

  Future<void> saveArtikel(BuildContext dialogContext) async {
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

      posts.add({
        'id': newId,
        'category_id': selectedCategory,
        'title': title,
        'content': content,
        'author': author,
        'category': category['nama'],
      });
    } else {
      final index = posts.indexWhere((post) => post['id'] == editingId);

      if (index != -1) {
        posts[index] = {
          'id': editingId,
          'category_id': selectedCategory,
          'title': title,
          'content': content,
          'author': author,
          'category': category['nama'],
        };
      }
    }

    setState(() {});

    await saveData();

    Navigator.pop(dialogContext);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          editingId == null
              ? 'Artikel berhasil ditambahkan'
              : 'Artikel berhasil diperbarui',
        ),
      ),
    );
  }

  // ============================================================
  // HAPUS ARTIKEL
  // ============================================================

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
              onPressed: () async {
                setState(() {
                  posts.removeWhere((post) => post['id'] == id);
                });

                await saveData();

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

  // ============================================================
  // MOBILE ARTICLE
  // ============================================================

  Widget mobileArticle(Map post) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),

      child: ListTile(
        contentPadding: const EdgeInsets.all(12),

        title: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,

          child: Text(
            post['title'] ?? '',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),

        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text('Kategori: ${post['category']}'),

              const SizedBox(height: 4),

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

        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailPage(
                post: post,

                edit: () {
                  Navigator.pop(context);

                  showFormArtikel(post: post);
                },

                hapus: () {
                  Navigator.pop(context);

                  deleteArtikel(post['id']);
                },
              ),
            ),
          );
        },

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
                children: [Icon(Icons.edit), SizedBox(width: 8), Text('Edit')],
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
  }

  // ============================================================
  // DESKTOP ARTICLE BOX
  // ============================================================

  Widget desktopArticle(Map post) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailPage(
                post: post,

                edit: () {
                  Navigator.pop(context);

                  showFormArtikel(post: post);
                },

                hapus: () {
                  Navigator.pop(context);

                  deleteArtikel(post['id']);
                },
              ),
            ),
          );
        },

        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // ==================================================
              // FLEXIBLE + FITTED BOX
              // ==================================================

              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,

                  child: Text(
                    post['title'] ?? '',
                    maxLines: 2,

                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Text('Kategori: ${post['category']}'),

              const SizedBox(height: 4),

              Text('Penulis: ${post['author']}'),

              const SizedBox(height: 10),

              // ==================================================
              // EXPANDED
              // ==================================================
              Expanded(
                child: Text(
                  post['content'] ?? '',
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,

                children: [
                  PopupMenuButton<String>(
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    // ============================================================
    // MEDIA QUERY
    // ============================================================

    final sizeWidth = MediaQuery.sizeOf(context).width;

    final sizeHeight = MediaQuery.sizeOf(context).height;

    final orientation = MediaQuery.orientationOf(context);

    final paddingDevice = MediaQuery.paddingOf(context);

    final isPortrait = orientation == Orientation.portrait;

    // Prevent unused variable warning
    if (sizeHeight < 0 || paddingDevice.top < 0) {
      return const SizedBox();
    }

    return Scaffold(
      appBar: AppBar(
        title: FittedBox(
          fit: BoxFit.scaleDown,

          child: const Text(
            'Blog App',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),

        centerTitle: true,
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showFormArtikel();
        },

        child: const Icon(Icons.add),
      ),

      // ==========================================================
      // LAYOUT BUILDER
      // ==========================================================
      body: LayoutBuilder(
        builder: (context, constraints) {
          // ======================================================
          // NARROW SCREEN
          // ======================================================

          if (constraints.maxWidth < 600) {
            if (posts.isEmpty) {
              return const Center(child: Text('Belum ada artikel'));
            }

            return ListView.builder(
              padding: EdgeInsets.fromLTRB(
                12,
                12,
                12,
                12 + paddingDevice.bottom,
              ),

              itemCount: posts.length,

              itemBuilder: (context, index) {
                return mobileArticle(posts[index]);
              },
            );
          }

          // ======================================================
          // WIDE SCREEN
          // ======================================================

          if (posts.isEmpty) {
            return const Center(child: Text('Belum ada artikel'));
          }

          int crossAxisCount = 2;

          if (constraints.maxWidth >= 1200) {
            crossAxisCount = 3;
          }

          if (constraints.maxWidth >= 1600) {
            crossAxisCount = 4;
          }

          return GridView.builder(
            padding: EdgeInsets.fromLTRB(
              sizeWidth >= 1200 ? 50 : 24,
              24,
              sizeWidth >= 1200 ? 50 : 24,
              24,
            ),

            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,

              crossAxisSpacing: 16,

              mainAxisSpacing: 16,

              childAspectRatio: isPortrait ? 1.3 : 1.6,
            ),

            itemCount: posts.length,

            itemBuilder: (context, index) {
              return desktopArticle(posts[index]);
            },
          );
        },
      ),
    );
  }
}
