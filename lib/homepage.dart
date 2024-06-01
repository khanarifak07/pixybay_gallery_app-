import 'dart:developer';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pixybay_gallery_app/config.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> imagesData = [];
  bool isLoading = false;
  bool showBlur = false;

  @override
  void initState() {
    getImages();
    super.initState();
  }

  Future<void> getImages() async {
    try {
      setState(() {
        isLoading = true;
      });
      //dio instance
      Dio dio = Dio();
      //make dio get request
      Response response = await dio.get(uri);
      //handle the response
      if (response.statusCode == 200) {
        var data = response.data;
        List hits = data['hits'];
        List<Map<String, dynamic>> tempData = [];
        for (var hit in hits) {
          String imageUrl = hit['webformatURL'];
          int likes = hit['likes'];
          int views = hit['views'];

          tempData.add({
            'imageUrl': imageUrl,
            'likes': likes,
            'views': views,
          });
          //update state with the fetched data
          setState(() {
            imagesData = tempData;
          });
          log(imagesData.toString());
        }
      } else {
        log("${response.statusCode}");
      }
    } catch (e) {
      print('error $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void closeDialog() {
    setState(() {
      showBlur = false;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                  ),
                  itemCount: imagesData.length,
                  itemBuilder: (BuildContext context, int index) {
                    Map<String, dynamic> imageData = imagesData[index];
                    return GestureDetector(
                      onTap: () { 
                        setState(() {
                          showBlur = true;
                        });
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) {
                            return Dialog(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    showBlur = false;
                                  });
                                  Navigator.pop(context);
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Stack(
                                    children: [
                                      Image.network(
                                        imageData['imageUrl'],
                                        fit: BoxFit.cover,
                                      ),
                                      Positioned(
                                        top: 5,
                                        left: 5,
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.remove_red_eye,
                                              size: 20,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              '${imageData['views']}',
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 5,
                                        left: 5,
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.favorite,
                                              size: 20,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              '${imageData['likes']}',
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.all(6),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Stack(
                            children: [
                              Image.network(
                                imageData['imageUrl'],
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                              Positioned(
                                top: 5,
                                left: 5,
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.remove_red_eye,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${imageData['views']}',
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                bottom: 5,
                                left: 5,
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.favorite,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${imageData['likes']}',
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Positioned.fill(
                  child: showBlur
                      ? BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: 5,
                            sigmaY: 5,
                          ),
                          child: Container(
                            color: Colors.black.withOpacity(.5),
                          ),
                        )
                      : Container(),
                )
              ],
            ),
    );
  }
}
