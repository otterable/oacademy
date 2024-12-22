// lib/screens/admin_dashboard.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'dart:js' as js; // For opening new tab in web
import '../services/api_service.dart';
import '../models/presentation.dart';
import '../widgets/top_bar.dart';
import '../l10n/app_localizations.dart';

class AdminDashboard extends StatefulWidget {
  final String? userName; // pass userName for display

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

  // Debug console
  bool _showDebugConsole = false;
  final List<String> _debugLog = [];

  void _addLog(String message) {
    setState(() {
      final timestamp = DateTime.now().toIso8601String();
      _debugLog.add("[$timestamp] $message");
    });
  }

  @override
  void initState() {
    super.initState();
    _addLog("AdminDashboard initState");
    _fetchPresentations();
    _fetchCategories();
  }

  void _fetchPresentations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });
    _addLog("Fetching presentations...");
    try {
      _allPresentations = await _apiService.fetchPresentations(_searchQuery);
      _addLog("Got ${_allPresentations.length} presentations.");
    } catch (e) {
      _addLog("Error fetching presentations: $e");
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
    _addLog("Fetching categories...");
    try {
      _categories = await _apiService.fetchCategories();
      _addLog("Got categories: $_categories");
    } catch (e) {
      _addLog("Error fetching categories: $e");
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _createCategory(String categoryName) async {
    _addLog("Creating category: $categoryName");
    try {
      await _apiService.createCategory(categoryName);
      _addLog("Category created successfully.");
      _fetchCategories();
    } catch (e) {
      _addLog("Error creating category: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating category: $e')),
        );
      }
    }
  }

  void _deleteCategory(String categoryName) async {
    _addLog("Deleting category: $categoryName");
    try {
      await _apiService.deleteCategory(categoryName);
      _addLog("Category deleted successfully.");
      _fetchCategories();
    } catch (e) {
      _addLog("Error deleting category: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting category: $e')),
        );
      }
    }
  }

  void _assignPresentation(String presentationId, String categoryName) async {
    _addLog("Assigning presentation $presentationId to $categoryName");
    try {
      await _apiService.assignPresentation(presentationId, categoryName);
      _addLog("Presentation assigned successfully.");
      _fetchPresentations();
    } catch (e) {
      _addLog("Error assigning presentation: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error assigning presentation: $e')),
        );
      }
    }
  }

  void _unassignPresentation(String presentationId) async {
    _addLog("Unassigning presentation $presentationId");
    try {
      await _apiService.unassignPresentation(presentationId);
      _addLog("Presentation unassigned successfully.");
      _fetchPresentations();
    } catch (e) {
      _addLog("Error unassigning presentation: $e");
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

    _addLog("User triggered uploadPresentation.");
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pptx'],
    );

    if (result != null && result.files.isNotEmpty) {
      final pickedFile = result.files.single; // PlatformFile
      final fileName = pickedFile.name;
      final title = fileName.replaceAll('.pptx', '');
      final category = 'Default Category'; // or let user pick

      _addLog("Uploading file: $fileName, title=$title, category=$category");

      try {
        bool success;
        if (kIsWeb) {
          // On web, we must upload from bytes
          if (pickedFile.bytes == null) {
            _addLog("No bytes found for the selected file on web. Aborting.");
            setState(() => _isUploading = false);
            return;
          }
          success = await _apiService.uploadPresentationWeb(
            title: title,
            category: category,
            fileName: fileName,
            fileBytes: pickedFile.bytes!,
          );
        } else {
          // On mobile/desktop, fromPath
          final filePath = pickedFile.path!;
          success =
              await _apiService.uploadPresentation(title, category, filePath);
        }

        if (mounted) {
          if (success) {
            _addLog("Upload successful.");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context).uploadSuccessful),
              ),
            );
            _fetchPresentations();
            _fetchCategories();
          } else {
            _addLog("Upload returned false? Check the backend logs.");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context).uploadFailed),
              ),
            );
          }
        }
      } catch (error) {
        _addLog("Error while uploading: $error");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('${AppLocalizations.of(context).uploadFailed} $error'),
            ),
          );
        }
      }
    } else {
      _addLog("File picker canceled by user or no file selected.");
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

  // Show a dialog to create a category
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

  // Show a dialog to delete a category
  void _showDeleteCategoryDialog(String categoryName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).deleteCategory),
          content: Text(
            '${AppLocalizations.of(context).confirmDeleteCategory} "$categoryName"?',
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

  // Show a dialog to assign a category
  void _showAssignCategoryDialog(String presentationId) {
    showDialog(
      context: context,
      builder: (context) {
        String selectedCategory =
            _categories.isNotEmpty ? _categories[0] : '';
        return AlertDialog(
          title: Text(AppLocalizations.of(context).assignToCategory),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return DropdownButtonFormField<String>(
                value: selectedCategory.isNotEmpty ? selectedCategory : null,
                items: _categories.map((cat) {
                  return DropdownMenuItem<String>(
                    value: cat,
                    child: Text(cat),
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
              onPressed: () => Navigator.of(context).pop(),
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
    });
    _addLog("Search changed to: $query");
    _fetchPresentations();
  }

  bool isMobile(BuildContext context) {
    return getDeviceType(MediaQuery.of(context).size) ==
        DeviceScreenType.mobile;
  }

  // Opens a presentation in a new browser tab
  void _openPresentation(Presentation p) {
    final url = "http://localhost:5656/view_presentation/${p.id}";
    js.context.callMethod('open', [url, "_blank"]);
  }

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(userName: widget.userName),
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
              ..._categories.map((cat) {
                int count =
                    _allPresentations.where((p) => p.category == cat).length;
                return ListTile(
                  title: Text(cat),
                  trailing: Text('$count'),
                  onTap: () {
                    _addLog("Tapped on category: $cat");
                  },
                  onLongPress: () {
                    _showDeleteCategoryDialog(cat);
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
                    decoration:
                        const BoxDecoration(color: Color(0xFF003058)),
                    child: Text(
                      AppLocalizations.of(context).categories,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: [
                        ..._categories.map((cat) {
                          int count = _allPresentations
                              .where((p) => p.category == cat)
                              .length;
                          return ListTile(
                            title: Text(
                              cat,
                              style: const TextStyle(color: Colors.white),
                            ),
                            trailing: Text(
                              '$count',
                              style: const TextStyle(color: Colors.white),
                            ),
                            onTap: () {
                              _addLog("Category tapped: $cat");
                            },
                            onLongPress: () {
                              _showDeleteCategoryDialog(cat);
                            },
                          );
                        }),
                        ListTile(
                          leading:
                              const Icon(Icons.add, color: Colors.white),
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Debug console toggle
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _showDebugConsole = !_showDebugConsole;
                        });
                      },
                      icon: Icon(
                        _showDebugConsole ? Icons.bug_report : Icons.bug_report_outlined,
                      ),
                      label: Text(
                        _showDebugConsole
                            ? "Hide Debug Console"
                            : "Show Debug Console",
                      ),
                    ),
                  ),
                  if (_showDebugConsole)
                    Container(
                      height: 120,
                      color: Colors.grey[300],
                      child: ListView.builder(
                        itemCount: _debugLog.length,
                        itemBuilder: (context, index) {
                          return Text(
                            _debugLog[index],
                            style: const TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
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
                          child: Text(
                            AppLocalizations.of(context).uploadPresentation,
                          ),
                        ),
                  const SizedBox(height: 20),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _errorMessage.isNotEmpty
                          ? Center(child: Text(_errorMessage))
                          : Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: _categories.map((category) {
                                    List<Presentation> categoryPresentations =
                                        _allPresentations
                                            .where((p) =>
                                                p.category == category)
                                            .toList();
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                          items: categoryPresentations
                                              .map((presentation) {
                                            return Builder(
                                              builder:
                                                  (BuildContext context) {
                                                // Make each item clickable
                                                return GestureDetector(
                                                  onTap: () {
                                                    // Open in new tab
                                                    _openPresentation(presentation);
                                                  },
                                                  child: Column(
                                                    children: [
                                                      Expanded(
                                                        child: Container(
                                                          margin:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      5.0),
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0),
                                                            image:
                                                                DecorationImage(
                                                              image:
                                                                  NetworkImage(
                                                                presentation
                                                                    .imageUrl,
                                                              ),
                                                              fit:
                                                                  BoxFit.cover,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 5),
                                                      Text(
                                                        presentation.title,
                                                        style:
                                                            const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontFamily: 'Roboto',
                                                        ),
                                                      ),
                                                      Text(
                                                        '${AppLocalizations.of(context).uploadedOn}: ${presentation.uploadDate}',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              Colors.grey[600],
                                                          fontFamily: 'Roboto',
                                                        ),
                                                      ),
                                                      const SizedBox(height: 5),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          IconButton(
                                                            icon: const Icon(
                                                              Icons.check,
                                                              color: Color(
                                                                  0xFF003058),
                                                            ),
                                                            onPressed: () {
                                                              _showAssignCategoryDialog(
                                                                presentation.id
                                                                    .toString(),
                                                              );
                                                            },
                                                          ),
                                                          IconButton(
                                                            icon: const Icon(
                                                              Icons.close,
                                                              color: Color(
                                                                  0xFF003058),
                                                            ),
                                                            onPressed: () {
                                                              _unassignPresentation(
                                                                presentation.id
                                                                    .toString(),
                                                              );
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
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
