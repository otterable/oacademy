// lib/screens/admin_dashboard.dart

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:responsive_builder/responsive_builder.dart';
import '../services/api_service.dart';
import '../models/presentation.dart';
import '../widgets/top_bar.dart';
import '../l10n/app_localizations.dart';

class AdminDashboard extends StatefulWidget {
  final String? userName; // Add this line to accept userName

  const AdminDashboard({super.key, this.userName});

  @override
  AdminDashboardState createState() => AdminDashboardState();
}

class AdminDashboardState extends State<AdminDashboard> {
  final ApiService _apiService = ApiService();
  bool _isUploading = false;
  bool _isLoading = false;
  String _errorMessage = "";
  List<String> _categories = [];
  List<Presentation> _allPresentations = [];

  final TextEditingController _categoryController = TextEditingController();

  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _fetchPresentations();
    _fetchCategories();
  }

  void _fetchPresentations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });
    try {
      _allPresentations = await _apiService.fetchPresentations(_searchQuery);
    } catch (e) {
      debugPrint('Error fetching presentations: $e');
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _fetchCategories() async {
    try {
      _categories = await _apiService.fetchCategories();
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _createCategory(String categoryName) async {
    try {
      await _apiService.createCategory(categoryName);
      _fetchCategories();
    } catch (e) {
      debugPrint('Error creating category: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating category: $e')),
        );
      }
    }
  }

  void _deleteCategory(String categoryName) async {
    try {
      await _apiService.deleteCategory(categoryName);
      _fetchCategories();
    } catch (e) {
      debugPrint('Error deleting category: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting category: $e')),
        );
      }
    }
  }

  void _assignPresentation(String presentationId, String categoryName) async {
    try {
      await _apiService.assignPresentation(presentationId, categoryName);
      _fetchPresentations();
    } catch (e) {
      debugPrint('Error assigning presentation: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error assigning presentation: $e')),
        );
      }
    }
  }

  void _unassignPresentation(String presentationId) async {
    try {
      await _apiService.unassignPresentation(presentationId);
      _fetchPresentations();
    } catch (e) {
      debugPrint('Error unassigning presentation: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error unassigning presentation: $e')),
        );
      }
    }
  }

  void _uploadPresentation() async {
    setState(() {
      _isUploading = true;
    });

    // Use a file picker to select a .pptx file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pptx'],
    );

    if (result != null && result.files.single.path != null) {
      String filePath = result.files.single.path!;
      String title = result.files.single.name.replaceAll('.pptx', '');
      String category = 'Default Category'; // You might want to let the admin choose the category

      try {
        bool success = await _apiService.uploadPresentation(title, category, filePath);
        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context).uploadSuccessful)),
            );
            _fetchPresentations();
            _fetchCategories();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context).uploadFailed)),
            );
          }
        }
      } catch (error) {
        debugPrint('Upload error: $error');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${AppLocalizations.of(context).uploadFailed} $error')),
          );
        }
      }
    } else {
      // User canceled the picker
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).noFileSelected)),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _showCreateCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).createCategory),
          content: TextField(
            controller: _categoryController,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context).selectCategory,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _categoryController.clear();
              },
              child: Text(AppLocalizations.of(context).cancel),
            ),
            TextButton(
              onPressed: () {
                String categoryName = _categoryController.text.trim();
                if (categoryName.isNotEmpty) {
                  _createCategory(categoryName);
                  Navigator.of(context).pop();
                  _categoryController.clear();
                }
              },
              child: Text(AppLocalizations.of(context).create),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteCategoryDialog(String categoryName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).deleteCategory),
          content: Text('${AppLocalizations.of(context).confirmDeleteCategory} "$categoryName"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context).cancel),
            ),
            TextButton(
              onPressed: () {
                _deleteCategory(categoryName);
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context).delete),
            ),
          ],
        );
      },
    );
  }

  void _showAssignCategoryDialog(String presentationId) {
    showDialog(
      context: context,
      builder: (context) {
        String selectedCategory = _categories.isNotEmpty ? _categories[0] : '';
        return AlertDialog(
          title: Text(AppLocalizations.of(context).assignToCategory),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return DropdownButtonFormField<String>(
                value: selectedCategory.isNotEmpty ? selectedCategory : null,
                items: _categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value ?? '';
                  });
                },
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).selectCategory,
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context).cancel),
            ),
            TextButton(
              onPressed: () {
                if (selectedCategory.isNotEmpty) {
                  _assignPresentation(presentationId, selectedCategory);
                  Navigator.of(context).pop();
                }
              },
              child: Text(AppLocalizations.of(context).assign),
            ),
          ],
        );
      },
    );
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _fetchPresentations();
    });
  }

  bool isMobile(BuildContext context) {
    return getDeviceType(MediaQuery.of(context).size) == DeviceScreenType.mobile;
  }

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(userName: widget.userName), // Pass userName to TopBar
      backgroundColor: const Color(0xFFF5F1E4),
      drawer: ScreenTypeLayout.builder(
        mobile: (BuildContext context) => Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Color(0xFF003058),
                ),
                child: Text(
                  AppLocalizations.of(context).categories,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ..._categories.map((category) {
                int count = _allPresentations.where((p) => p.category == category).length;
                return ListTile(
                  title: Text(category),
                  trailing: Text('$count'),
                  onTap: () {
                    // Implement category filtering or other actions
                  },
                  onLongPress: () {
                    _showDeleteCategoryDialog(category);
                  },
                );
              }),
              ListTile(
                leading: const Icon(Icons.add, color: Colors.white),
                title: Text(
                  AppLocalizations.of(context).addCategory,
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: _showCreateCategoryDialog,
              ),
            ],
          ),
        ),
      ),
      body: Row(
        children: [
          // Sidebar for Desktop
          if (!isMobile(context))
            Container(
              width: 200,
              color: const Color(0xFF003058),
              child: Column(
                children: [
                  DrawerHeader(
                    decoration: const BoxDecoration(
                      color: Color(0xFF003058),
                    ),
                    child: Text(
                      AppLocalizations.of(context).categories,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: [
                        ..._categories.map((category) {
                          int count = _allPresentations.where((p) => p.category == category).length;
                          return ListTile(
                            title: Text(
                              category,
                              style: const TextStyle(color: Colors.white),
                            ),
                            trailing: Text(
                              '$count',
                              style: const TextStyle(color: Colors.white),
                            ),
                            onTap: () {
                              // Implement category filtering or other actions
                            },
                            onLongPress: () {
                              _showDeleteCategoryDialog(category);
                            },
                          );
                        }),
                        ListTile(
                          leading: const Icon(Icons.add, color: Colors.white),
                          title: Text(
                            AppLocalizations.of(context).addCategory,
                            style: const TextStyle(color: Colors.white),
                          ),
                          onTap: _showCreateCategoryDialog,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          // Main Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch, // Changed alignment
                children: [
                  Text(
                    AppLocalizations.of(context).stimmungskompassDescription,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context).searchHint,
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    onChanged: _onSearchChanged,
                  ),
                  const SizedBox(height: 20),
                  _isUploading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _uploadPresentation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF003058),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                          child: Text(AppLocalizations.of(context).uploadPresentation),
                        ),
                  const SizedBox(height: 20),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _errorMessage.isNotEmpty
                          ? Center(child: Text(_errorMessage))
                          : Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: _categories.map((category) {
                                    List<Presentation> categoryPresentations = _allPresentations
                                        .where((p) => p.category == category)
                                        .toList();
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          category,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Roboto',
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        CarouselSlider(
                                          options: CarouselOptions(
                                            height: 250.0,
                                            enlargeCenterPage: true,
                                            enableInfiniteScroll: false,
                                          ),
                                          items: categoryPresentations.map((presentation) {
                                            return Builder(
                                              builder: (BuildContext context) {
                                                return Column(
                                                  children: [
                                                    Expanded(
                                                      child: Container(
                                                        margin: const EdgeInsets.symmetric(horizontal: 5.0),
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(10.0),
                                                          image: DecorationImage(
                                                            image: NetworkImage(presentation.imageUrl),
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 5),
                                                    Text(
                                                      presentation.title,
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                        fontFamily: 'Roboto',
                                                      ),
                                                    ),
                                                    Text(
                                                      '${AppLocalizations.of(context).uploadedOn}: ${presentation.uploadDate}',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey[600],
                                                        fontFamily: 'Roboto',
                                                      ),
                                                    ),
                                                    const SizedBox(height: 5),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        IconButton(
                                                          icon: const Icon(Icons.check, color: Color(0xFF003058)),
                                                          onPressed: () {
                                                            _showAssignCategoryDialog(presentation.id.toString());
                                                          },
                                                        ),
                                                        IconButton(
                                                          icon: const Icon(Icons.close, color: Color(0xFF003058)),
                                                          onPressed: () {
                                                            _unassignPresentation(presentation.id.toString());
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          }).toList(),
                                        ),
                                        const SizedBox(height: 20),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
