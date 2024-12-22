// lib/screens/index_screen.dart

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'dart:js' as js; // For opening new tab in web
import '../utils/storage_helper.dart';
import '../services/api_service.dart';
import '../models/presentation.dart';
import '../widgets/top_bar.dart';
import '../l10n/app_localizations.dart';

class IndexScreen extends StatefulWidget {
  const IndexScreen({super.key});

  @override
  IndexScreenState createState() => IndexScreenState();
}

class IndexScreenState extends State<IndexScreen> {
  final ApiService _apiService = ApiService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Presentation> _presentations = [];
  List<String> _categories = [];

  String _searchQuery = "";
  bool _isLoading = false;
  String _errorMessage = "";

  // Admin token for login persistence
  String? _adminToken;

  // Debug console
  bool _showDebugConsole = false;
  final List<String> _debugLog = [];

  @override
  void initState() {
    super.initState();
    _addLog("IndexScreen initState called");
    _loadAdminToken();
  }

  // Helper to add logs to our debug console
  void _addLog(String message) {
    setState(() {
      final timestamp = DateTime.now().toIso8601String();
      _debugLog.add("[$timestamp] $message");
    });
  }

  // Load admin token (either from localStorage on web or SharedPreferences on mobile/desktop)
  Future<void> _loadAdminToken() async {
    _addLog("Loading admin token via StorageHelper...");
    final token = await StorageHelper.getToken();
    setState(() {
      _adminToken = token;
    });

    if (_adminToken != null && _adminToken!.isNotEmpty) {
      _addLog("Found token: $_adminToken. Attempting adminLogin...");
      try {
        await _apiService.adminLogin(_adminToken!);
        _addLog("Admin login successful via stored token.");
        _fetchCategories();
        _fetchPresentations();
      } catch (err) {
        _addLog("Admin login failed: $err");
        // Remove invalid token
        await StorageHelper.saveToken(null);
        setState(() {
          _adminToken = null;
        });
      }
    } else {
      _addLog("No admin token found. Fetching categories/presentations anyway...");
      _fetchCategories();
      _fetchPresentations();
    }
  }

  void _fetchCategories() async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });
    _addLog("Fetching categories...");
    try {
      final cats = await _apiService.fetchCategories();
      setState(() {
        _categories = cats;
      });
      _addLog("Fetched categories: $_categories");
    } catch (e) {
      _addLog("Error fetching categories: $e");
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

  void _fetchPresentations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });
    _addLog("Fetching presentations with query='$_searchQuery'...");
    try {
      final pres = await _apiService.fetchPresentations(_searchQuery);
      setState(() {
        _presentations = pres;
      });
      _addLog("Fetched ${pres.length} presentations.");
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

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _addLog("Search changed to: $query");
    _fetchPresentations();
  }

  bool isMobile(BuildContext context) {
    return getDeviceType(MediaQuery.of(context).size) == DeviceScreenType.mobile;
  }

  // Called when user clicks a presentation to open
  void _openPresentation(Presentation p) {
    final url = "http://localhost:5656/view_presentation/${p.id}";
    // On web, open in a new tab
    js.context.callMethod('open', [url, "_blank"]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: TopBar(
        userName: _adminToken != null ? "Admin" : null,
        showMenuIcon: isMobile(context),
        onMenuPressed: () {
          _scaffoldKey.currentState?.openEndDrawer();
        },
      ),
      backgroundColor: const Color(0xFFF5F1E4),
      endDrawer: isMobile(context)
          ? Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: const BoxDecoration(color: Color(0xFF003058)),
                    child: Text(
                      AppLocalizations.of(context).categories,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ..._categories.map((cat) {
                    final count =
                        _presentations.where((p) => p.category == cat).length;
                    return ListTile(
                      title: Text(cat),
                      trailing: Text('$count'),
                      onTap: () {
                        _addLog("Tapped on category: $cat");
                      },
                    );
                  }),
                ],
              ),
            )
          : null,
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
                    decoration: const BoxDecoration(color: Color(0xFF003058)),
                    child: Text(
                      AppLocalizations.of(context).categories,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: _categories.map((cat) {
                        final count = _presentations
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
                            _addLog("Clicked category: $cat");
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          // Main Content
          Expanded(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Toggle debug console
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _showDebugConsole = !_showDebugConsole;
                          });
                        },
                        icon: Icon(_showDebugConsole
                            ? Icons.bug_report
                            : Icons.bug_report_outlined),
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
                                      final categoryPresentations =
                                          _presentations
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
                                            items:
                                                categoryPresentations.map(
                                              (presentation) {
                                                return Builder(
                                                  builder: (BuildContext ctx) {
                                                    // Make clickable
                                                    return GestureDetector(
                                                      onTap: () =>
                                                          _openPresentation(
                                                              presentation),
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
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 5),
                                                          Text(
                                                            presentation.title,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily:
                                                                  'Roboto',
                                                            ),
                                                          ),
                                                          Text(
                                                            '${AppLocalizations.of(context).uploadedOn}: ${presentation.uploadDate}',
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color: Colors
                                                                  .grey[600],
                                                              fontFamily:
                                                                  'Roboto',
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                            ).toList(),
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
          ),
        ],
      ),
    );
  }
}
