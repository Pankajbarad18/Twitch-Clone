import 'dart:typed_data';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:twitch_clone/resources/firestore_methods.dart';
import 'package:twitch_clone/screens/broadcast_screen.dart';
import 'package:twitch_clone/utilities/colors.dart';
import 'package:twitch_clone/widgets/custom_buttons.dart';
import 'package:twitch_clone/widgets/custom_textfield.dart';

class GoLiveScreen extends StatefulWidget {
  const GoLiveScreen({super.key});

  @override
  State<GoLiveScreen> createState() => _GoLiveScreenState();
}

class _GoLiveScreenState extends State<GoLiveScreen> {
  final TextEditingController _titleController = TextEditingController();
  Uint8List? image;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  startLive() async {
    String channelId = await FireStoreMethods()
        .goToLive(context, _titleController.text, image);
    if (channelId.isNotEmpty) {
      // ignore: use_build_context_synchronously
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BroadcastScreen(
                    isBroadcaster: true,
                    channelId: channelId,
                  )));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () async {
                    Uint8List? pickedImage = await pickImage();
                    if (pickedImage != null) {
                      setState(() {
                        image = pickedImage;
                      });
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 20),
                    child: image != null
                        ? SizedBox(
                            height: 300,
                            child: Image.memory(image!),
                          )
                        : DottedBorder(
                            borderType: BorderType.RRect,
                            radius: const Radius.circular(10),
                            color: buttonColor,
                            strokeCap: StrokeCap.round,
                            dashPattern: const [10, 4],
                            child: Container(
                              height: 150,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: buttonColor.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.folder_open,
                                    size: 40,
                                    color: buttonColor,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    'Select Your Thumbnail',
                                    style: TextStyle(
                                        fontSize: 15, color: Colors.grey),
                                  )
                                ],
                              ),
                            ),
                          ),
                  ),
                ),
                const Text(
                  'Title',
                  style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
                const SizedBox(
                  height: 10,
                ),
                CustomTextField(controller: _titleController)
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: CustomButton(
                onTap: startLive,
                text: 'Go Live!',
              ),
            )
          ],
        ),
      ),
    );
  }
}
