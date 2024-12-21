// lib/screens/presentations_screen.dart

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../services/api_service.dart';
import '../models/presentation.dart';
import '../widgets/top_bar.dart';

class PresentationsScreen extends StatefulWidget {
  const PresentationsScreen({super.key});

  @override
  PresentationsScreenState createState() => PresentationsScreenState();
}

class PresentationsScreenState extends State<PresentationsScreen> {
  final ApiService _apiService = ApiService();
  List<Presentation> _presentations = [];
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
      _presentations = await _apiService.fetchPresentations("");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : CarouselSlider(
                  options: CarouselOptions(
                    height: 400.0,
                    enlargeCenterPage: true,
                    enableInfiniteScroll: false,
                  ),
                  items: _presentations.map((presentation) {
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
                              'Uploaded on: ${presentation.uploadDate}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontFamily: 'Roboto',
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  }).toList(),
                ),
    );
  }
}
