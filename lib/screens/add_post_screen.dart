import 'dart:io';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:iinstagram/screens/caption_screen.dart';
import 'package:image_gallery/image_gallery.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class AddPost extends StatefulWidget {
  @override
  _AddPostState createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  Map<dynamic, dynamic> allImageInfo = new HashMap();
  List allImages = new List();
  List allNamesList = new List();
  File imageInteractive;
  String imgName;
  GlobalKey _keyImg = GlobalKey();
  @override
  void initState() {
    super.initState();
    loadImageList();
  }

  _getSizes() {
    final RenderBox renderBoxRed = _keyImg.currentContext.findRenderObject();
    final sizeRed = renderBoxRed.size;
    print("SIZE of Red: $sizeRed");
  }

  Future<void> loadImageList() async {
    Map<dynamic, dynamic> allImageTemp;
    allImageTemp = await FlutterGallaryPlugin.getAllImages;
    print(" call $allImageTemp.length");

    setState(() {
      this.allImages = allImageTemp['URIList'] as List;
      this.imageInteractive = File(allImages[0].toString());
      this.allNamesList = allImageTemp['DISPLAY_NAME'] as List;
      this.imgName = allNamesList[0].toString();
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: Text(
          "Gallery",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
              icon: Icon(
                Icons.arrow_forward,
                color: Colors.blue,
              ),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        CaptionScreen(imageInteractive.path, imgName)));
              })
        ],
      ),
      body: SlidingUpPanel(
        panel: Column(children: [
          Padding(
            padding: EdgeInsets.only(bottom: 20, top: 20, left: 10, right: 10),
            child: Divider(
              color: Colors.black,
              endIndent: MediaQuery.of(context).size.width * 0.43,
              indent: MediaQuery.of(context).size.width * 0.43,
              thickness: 3.5,
            ),
          ),
          Expanded(
            child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1 / 1,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5),
                itemCount: allImages.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    child: Container(
                      decoration: BoxDecoration(color: Colors.black),
                      foregroundDecoration: BoxDecoration(
                          color: imgName == allNamesList[index].toString()
                              ? Colors.grey.withOpacity(0.7)
                              : Colors.transparent),
                      child: Image.file(
                        File(allImages[index].toString()),
                        fit: BoxFit.cover,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        imageInteractive = File(allImages[index].toString());
                        imgName = allNamesList[index].toString();
                      });
                    },
                  );
                }),
          ),
        ]),
        maxHeight: MediaQuery.of(context).size.height * .5,
        minHeight: MediaQuery.of(context).size.height * .25,
        color: Colors.grey.withOpacity(0.5),
        backdropEnabled: false,
        backdropTapClosesPanel: true,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        body: Column(children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.5,
            child: InteractiveViewer(
                constrained: true,
                onInteractionEnd: (ScaleEndDetails endDetails) {
                  print(endDetails);
                  print(endDetails.velocity);
                  setState(() {
                    _getSizes();
                  });
                },
                minScale: 0.5,
                maxScale: 1.3,
                panEnabled: true,
                scaleEnabled: true,
                child: AspectRatio(
                  aspectRatio: 2 / 2,
                  child: imageInteractive != null
                      ? Container(
                          key: _keyImg,
                          child: Image.file(
                            imageInteractive,
                            fit: BoxFit.cover,
                            scale: 1.0,
                          ),
                        )
                      : Container(),
                )),
          ),
        ]),
      ),
    );
  }
}
