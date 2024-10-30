import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/components/common/bottom_navigationbar.dart';
import 'package:frontend/components/common/top_bar.dart';
import 'package:frontend/components/common/spinner.dart';
import 'package:frontend/controller.dart';
import 'package:get/get.dart';
import 'package:frontend/services/api_service.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final MainController controller = Get.put(MainController());
  final ScrollController _scrollController = ScrollController();
  List<String> images = [];
  bool isLoading = false;
  int loadedItems = 0;

  @override
  void initState() {
    super.initState();
    fetchGallery();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !isLoading) {
        fetchGallery();
      }
    });
  }

  void fetchGallery() async {
    final apiService = ApiService();
    setState(() {
      isLoading = true;
    });

    try {
      final response = await apiService.findGallery();

      if (response != null && response.containsKey('imageUrls')) {
        List<dynamic> galleryImages = response['imageUrls'];

        setState(() {
          images.addAll(galleryImages
              .map<String>((image) {
                if (image is String) {
                  return image;
                }
                return '';
              })
              .where((element) => element.isNotEmpty)
              .toList());
          loadedItems += galleryImages.length;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: TopBar(onNotificationTap: () {}),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  '내 저장소',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '총 $loadedItems건',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.builder(
                    controller: _scrollController,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1,
                    ),
                    itemCount: images.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.memory(
                          base64Decode(images[index]),
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          if (isLoading)
            const Center(
              child: Spinner(),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigation(
        onTap: (int index) async {
          controller.changePage(index);
        },
      ),
    );
  }
}
