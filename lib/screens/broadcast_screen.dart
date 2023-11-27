// ignore_for_file: library_prefixes

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:http/http.dart' as http;
import 'package:twitch_clone/providers/user_provider.dart';
import 'package:twitch_clone/resources/firestore_methods.dart';
import 'package:twitch_clone/responsive/responsive_layout.dart';
import 'package:twitch_clone/screens/home_screen.dart';
import 'package:twitch_clone/utilities/colors.dart';
import 'package:twitch_clone/widgets/chat.dart';
import 'package:twitch_clone/widgets/custom_buttons.dart';

class BroadcastScreen extends StatefulWidget {
  final bool isBroadcaster;
  final String channelId;
  const BroadcastScreen({
    Key? key,
    required this.isBroadcaster,
    required this.channelId,
  }) : super(key: key);

  @override
  State<BroadcastScreen> createState() => _BroadcastScreenState();
}

class _BroadcastScreenState extends State<BroadcastScreen> {
  late final RtcEngine _engine;
  List<int> remoteUid = [];
  bool switchCamera = true;
  bool isMuted = false;
  bool isScreenSharing = false;

  @override
  void initState() {
    super.initState();
    _initEngine();
  }

  void _initEngine() async {
    _engine = await RtcEngine.createWithContext(RtcEngineContext(appId));
    _addListeners();

    await _engine.enableVideo();
    await _engine.startPreview();
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    if (widget.isBroadcaster) {
      _engine.setClientRole(ClientRole.Broadcaster);
    } else {
      _engine.setClientRole(ClientRole.Audience);
    }
    _joinChannel();
  }

  String baseUrl = "https://twitch-clone-4ed3fc44eeba.herokuapp.com";

  String? token;

  Future<void> getToken() async {
    final res = await http.get(
      Uri.parse(
          '$baseUrl/rtc/${widget.channelId}/publisher/userAccount/${Provider.of<UserProvider>(context, listen: false).user.uid}/'),
    );

    if (res.statusCode == 200) {
      setState(() {
        token = res.body;
        token = jsonDecode(token!)['rtcToken'];
      });
    } else {
      debugPrint('Failed to fetch the token');
    }
  }

  void _addListeners() {
    print(remoteUid.toString() + "123456789");

    _engine.setEventHandler(
        RtcEngineEventHandler(joinChannelSuccess: (channel, uid, elapsed) {
      debugPrint('joinChannelSuccess $channel $uid $elapsed');
    }, userJoined: (uid, elapsed) {
      debugPrint('userJoined $uid $elapsed');
      setState(() {
        remoteUid.add(uid);
      });
    }, userOffline: (uid, reason) {
      debugPrint('userOffline $uid $reason');
      setState(() {
        remoteUid.removeWhere((element) => element == uid);
      });
    }, leaveChannel: (stats) {
      debugPrint('leaveChannel $stats');
      setState(() {
        remoteUid.clear();
      });
    }, tokenPrivilegeWillExpire: (token) async {
      await getToken();
      await _engine.renewToken(token);
    }));
    print(remoteUid.toString() + "123456789");
  }

  void _joinChannel() async {
    await getToken();
    if (token != null) {
      if (defaultTargetPlatform == TargetPlatform.android) {
        await [Permission.microphone, Permission.camera].request();
      }
      await _engine.joinChannelWithUserAccount(
        token,
        widget.channelId,
        // ignore: use_build_context_synchronously
        Provider.of<UserProvider>(context, listen: false).user.uid,
      );
    }
  }

  void _switchCamera() {
    _engine.switchCamera().then((value) {
      setState(() {
        switchCamera = !switchCamera;
      });
    }).catchError((err) {
      debugPrint('switchCamera $err');
    });
  }

  void onToggleMute() async {
    setState(() {
      isMuted = !isMuted;
    });
    await _engine.muteLocalAudioStream(isMuted);
  }

  _startScreenShare() async {
    final helper = await _engine.getScreenShareHelper(
        appGroup: kIsWeb || Platform.isWindows ? null : 'io.agora');
    await helper.disableAudio();
    await helper.enableVideo();
    await helper.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await helper.setClientRole(ClientRole.Broadcaster);
    var windowId = 0;
    var random = Random();
    if (!kIsWeb &&
        (Platform.isWindows || Platform.isMacOS || Platform.isAndroid)) {
      final windows = _engine.enumerateWindows();
      if (windows.isNotEmpty) {
        final index = random.nextInt(windows.length - 1);
        debugPrint('Screensharing window with index $index');
        windowId = windows[index].id;
      }
    }
    await helper.startScreenCaptureByWindowId(windowId);
    setState(() {
      isScreenSharing = true;
    });
    await helper.joinChannelWithUserAccount(
      token,
      widget.channelId,
      // ignore: use_build_context_synchronously
      Provider.of<UserProvider>(context, listen: false).user.uid,
    );
  }

  _stopScreenShare() async {
    final helper = await _engine.getScreenShareHelper();
    await helper.destroy().then((value) {
      setState(() {
        isScreenSharing = false;
      });
    }).catchError((err) {
      debugPrint('StopScreenShare $err');
    });
  }

  _leaveChannel() async {
    await _engine.leaveChannel();
    // ignore: use_build_context_synchronously
    if ('${Provider.of<UserProvider>(context, listen: false).user.uid}${Provider.of<UserProvider>(context, listen: false).user.username}' ==
        widget.channelId) {
      await FireStoreMethods().endLiveStream(widget.channelId);
    } else {
      await FireStoreMethods().updateViewCount(widget.channelId, false);
    }
    // ignore: use_build_context_synchronously
    Navigator.pushReplacementNamed(context, HomeScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return WillPopScope(
      onWillPop: () async {
        await _leaveChannel();
        return Future.value(true);
      },
      child: Scaffold(
        bottomNavigationBar: widget.isBroadcaster
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: CustomButton(
                  text: 'End Stream',
                  onTap: _leaveChannel,
                ),
              )
            : null,
        body: Padding(
          padding: const EdgeInsets.all(8),
          child: ResponsiveLayout(
            desktopBody: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.45,
                    height: MediaQuery.of(context).size.height,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _renderVideo(user, isScreenSharing),
                        if ("${user.uid}${user.username}" == widget.channelId)
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: _switchCamera,
                                child: const Text('Switch Camera'),
                              ),
                              InkWell(
                                onTap: onToggleMute,
                                child: Text(isMuted ? 'Unmute' : 'Mute'),
                              ),
                              InkWell(
                                onTap: isScreenSharing
                                    ? _stopScreenShare
                                    : _startScreenShare,
                                child: Text(
                                  isScreenSharing
                                      ? 'Stop ScreenSharing'
                                      : 'Start Screensharing',
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  SizedBox(
                      width: MediaQuery.of(context).size.width * 0.45,
                      height: MediaQuery.of(context).size.height,
                      child: Chat(channelId: widget.channelId))
                ],
              ),
            ),
            mobileBody: Column(
              children: [
                _renderVideo(user, isScreenSharing),
                if ("${user.uid}${user.username}" == widget.channelId)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: _switchCamera,
                        child: const Text('Switch Camera'),
                      ),
                      InkWell(
                        onTap: onToggleMute,
                        child: Text(isMuted ? 'Unmute' : 'Mute'),
                      ),
                    ],
                  ),
                Expanded(
                  child: Chat(
                    channelId: widget.channelId,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _renderVideo(user, isScreenSharing) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: "${user.uid}${user.username}" == widget.channelId
          ? isScreenSharing
              ? kIsWeb
                  ? const RtcLocalView.SurfaceView.screenShare()
                  : const RtcLocalView.TextureView.screenShare()
              : const RtcLocalView.SurfaceView(
                  zOrderMediaOverlay: true,
                  zOrderOnTop: true,
                )
          : isScreenSharing
              ? kIsWeb
                  ? const RtcLocalView.SurfaceView.screenShare()
                  : const RtcLocalView.TextureView.screenShare()
              : remoteUid.isNotEmpty
                  ? kIsWeb
                      ? RtcRemoteView.SurfaceView(
                          uid: remoteUid[0],
                          channelId: widget.channelId,
                        )
                      : RtcRemoteView.TextureView(
                          uid: remoteUid[0],
                          channelId: widget.channelId,
                        )
                  : Container(
                      color: Colors.red,
                    ),
    );
  }
}
