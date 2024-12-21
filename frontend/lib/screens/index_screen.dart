// lib/screens/index_screen.dart

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:responsive_builder/responsive_builder.dart';
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // Added GlobalKey
  List<Presentation> _presentations = [];
  List<String> _categories = [];
  String _searchQuery = "";
  bool _isLoading = false;
  String _errorMessage = "";

  @override
  void initState() {
    super.initState();
    _fetchPresentations();
  }

  void _fetchPresentations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    try {
      _presentations = await _apiService.fetchPresentations(_searchQuery);
      _categories = _presentations.map((p) => p.category).toSet().toList();
    } catch (e) {
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
      _fetchPresentations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Assign the GlobalKey to Scaffold
      appBar: TopBar(
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
                    decoration: const BoxDecoration(
                      color: Color(0xFF003058),
                    ),
                    child: Text(
                      AppLocalizations.of(context).categories,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold, // Made text bold
                      ),
                    ),
                  ),
                  ..._categories.map((category) {
                    int count = _presentations
                        .where((p) => p.category == category)
                        .length;
                    return ListTile(
                      title: Text(category),
                      trailing: Text('$count'),
                      onTap: () {
                        // Implement category filtering or other actions
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
                    decoration: const BoxDecoration(
                      color: Color(0xFF003058),
                    ),
                    child: Text(
                      AppLocalizations.of(context).categories,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold, // Made text bold
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: [
                        ..._categories.map((category) {
                          int count = _presentations
                              .where((p) => p.category == category)
                              .length;
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
                          );
                        }),
                      ],
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
                    Text(
                      AppLocalizations.of(context)
                          .stimmungskompassDescription,
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
                                      List<Presentation> categoryPresentations =
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
                                            items: categoryPresentations.map(
                                                (presentation) {
                                              return Column(
                                                children: [
                                                  Expanded(
                                                    child: Container(
                                                      margin:
                                                          const EdgeInsets
                                                                  .symmetric(
                                                              horizontal: 5.0),
                                                      decoration:
                                                          BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    10.0),
                                                        image:
                                                            DecorationImage(
                                                          image: NetworkImage(
                                                              presentation
                                                                  .imageUrl),
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
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily: 'Roboto',
                                                    ),
                                                  ),
                                                  Text(
                                                    'Uploaded on: ${presentation.uploadDate}',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey[600],
                                                      fontFamily: 'Roboto',
                                                    ),
                                                  ),
                                                ],
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
          ),
        ],
      ),
    );
  }

  bool isMobile(BuildContext context) {
    return getDeviceType(MediaQuery.of(context).size) ==
        DeviceScreenType.mobile;
  }
}
