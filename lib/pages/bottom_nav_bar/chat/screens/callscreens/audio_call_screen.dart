import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:r2a_mobile/pages/bottom_nav_bar/chat/models/call.dart';
import 'package:r2a_mobile/pages/bottom_nav_bar/chat/services/call_methods.dart';
import 'package:r2a_mobile/shared_state/call_ringtone_state.dart';
import 'package:r2a_mobile/shared_state/call_screen.dart';
import 'package:r2a_mobile/shared_state/user.dart';
import 'package:r2a_mobile/utils/agora_config.dart';

class AudioCallSCreen extends StatefulWidget {
  final Call call;

  AudioCallSCreen({
    @required this.call,
  });

  @override
  _AudioCallSCreenState createState() => _AudioCallSCreenState();
}

class _AudioCallSCreenState extends State<AudioCallSCreen> {
  final CallMethods callMethods = CallMethods();
  final CollectionReference callLogsCollection =
      Firestore.instance.collection("callLogs");
  UserState user;
  StreamSubscription callStreamSubscription;
  CallScreenState callScreenState;
  TimerCounterState timerCounterState;
  bool isLifted = false;
  static final _users = <int>[];
  final _infoStrings = <String>[];
  bool muted = false;
  bool speaker = false;
  bool _showTime = false;
  final assetsAudioPlayer = AssetsAudioPlayer();
  String ringingStatus = '';
  Timer _timer;
  int _start;
  int counter = 0;
  @override
  void initState() {
    super.initState();
    // FlutterRingtonePlayer.stop();
    addPostFrameCallback();
    initializeAgora();
  }

  void startTimer() {
    _start = 30;
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (_start < 1) {
            // _resend = true;
            timer.cancel();
          } else {
            _start = _start - 1;
          }
        },
      ),
    );
  }

  Future<void> initializeAgora() async {
    if (widget.call.hasDialled) {
      assetsAudioPlayer.open(Audio("assets/audio/phone_ringing_sound.mp3"),
          loopMode: LoopMode.single);
      // assetsAudioPlayer.setLoopMode(LoopMode.single);
    }
    if (APP_ID.isEmpty) {
      setState(() {
        _infoStrings.add(
          'APP_ID missing, please provide your APP_ID in settings.dart',
        );
        _infoStrings.add('Agora Engine is not starting');
      });
      return;
    }

    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    await AgoraRtcEngine.setEnableSpeakerphone(false);
    await AgoraRtcEngine.enableWebSdkInteroperability(true);
    await AgoraRtcEngine.setParameters(
        '''{\"che.video.lowBitRateStreamParameter\":{\"width\":320,\"height\":180,\"frameRate\":15,\"bitRate\":140}}''');
    await AgoraRtcEngine.joinChannel(null, widget.call.channelId, null, 0);
  }

  addPostFrameCallback() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      user = Provider.of<UserState>(context, listen: false);
      callScreenState = Provider.of<CallScreenState>(context, listen: false);
      // timerCounterState = Provider.of<TimerCounterState>(context,listen: true);

      callScreenState.updateIsCallDailled = false;
      callStreamSubscription =
          callMethods.callStream(uid: user.id).listen((QuerySnapshot ds) {
        // defining the logic
        switch (ds.documents.length) {
          case 0:
            // snapshot is 0 which means that call is hanged and documents are deleted
            timerCounterState
                .reset(); // reset the timer provider when the screen is about to get disposed
            Navigator.pop(context);
            break;
          default:
            print("default");
            break;
        }
      });
    });
  }

  /// Create agora sdk instance and initialize
  Future<void> _initAgoraRtcEngine() async {
    await AgoraRtcEngine.create(APP_ID);
    // await AgoraRtcEngine.enableAudio();
    // await AgoraRtcEngine.setEnableSpeakerphone(false);
  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() {
    AgoraRtcEngine.onError = (dynamic code) {
      setState(() {
        final info = 'onError: $code';
        _infoStrings.add(info);
      });
    };

    AgoraRtcEngine.onJoinChannelSuccess = (
      String channel,
      int uid,
      int elapsed,
    ) {
      setState(() {
        final info = 'onJoinChannel: $channel, uid: $uid';
        _infoStrings.add(info);
      });
    };

    AgoraRtcEngine.onUserJoined = (int uid, int elapsed) async {
      assetsAudioPlayer.stop();
      setState(() {
        _showTime = true;
      });
      timerCounterState.start();
      isLifted = true;
      await AgoraRtcEngine.enableAudio();
      await AgoraRtcEngine.setEnableSpeakerphone(false);
      setState(() {
        final info = 'onUserJoined: $uid';
        _infoStrings.add(info);
        _users.add(uid);
      });
    };

    AgoraRtcEngine.onUpdatedUserInfo = (AgoraUserInfo userInfo, int i) {
      setState(() {
        final info = 'onUpdatedUserInfo: ${userInfo.toString()}';
        _infoStrings.add(info);
      });
    };

    AgoraRtcEngine.onRejoinChannelSuccess = (String string, int a, int b) {
      timerCounterState.start();
      setState(() {
        final info = 'onRejoinChannelSuccess: $string';
        _infoStrings.add(info);
      });
    };

    AgoraRtcEngine.onUserOffline = (int a, int b) {
      timerCounterState.stop();
      // callMethods.endCall(call: widget.call);
      setState(() {
        final info = 'onUserOffline: a: ${a.toString()}, b: ${b.toString()}';
        _infoStrings.add(info);
      });
    };

    AgoraRtcEngine.onRegisteredLocalUser = (String s, int i) {
      setState(() {
        final info = 'onRegisteredLocalUser: string: s, i: ${i.toString()}';
        _infoStrings.add(info);
      });
    };

    AgoraRtcEngine.onLeaveChannel = () {
      setState(() {
        _infoStrings.add('onLeaveChannel');
        _users.clear();
      });
    };

    AgoraRtcEngine.onConnectionLost = () {
      setState(() {
        final info = 'onConnectionLost';
        _infoStrings.add(info);
      });
    };

    AgoraRtcEngine.onUserOffline = (int uid, int reason) {
      // if call was picked
      timerCounterState.stop();
      setState(() {
        final info = 'userOffline: $uid';
        _infoStrings.add(info);
        _users.remove(uid);
      });
    };

    AgoraRtcEngine.onFirstRemoteVideoFrame = (
      int uid,
      int width,
      int height,
      int elapsed,
    ) {
      setState(() {
        final info = 'firstRemoteVideo: $uid ${width}x $height';
        _infoStrings.add(info);
      });
    };
  }

  /// Helper function to get list of native views
  List<Widget> _getRenderViews() {
    final List<AgoraRenderWidget> list = [
      AgoraRenderWidget(0, local: true, preview: true),
    ];
    _users.forEach((int uid) => list.add(AgoraRenderWidget(uid)));
    return list;
  }

  /// Video view wrapper
  Widget _videoView(view) {
    return Expanded(child: Container(child: view));
  }

  /// Video view row wrapper
  Widget _expandedVideoRow(List<Widget> views) {
    final wrappedViews = views.map<Widget>(_videoView).toList();
    return Expanded(
      child: Row(
        children: wrappedViews,
      ),
    );
  }

  /// Video layout wrapper
  Widget _viewRows() {
    final views = _getRenderViews();
    switch (views.length) {
      case 1:
        return Container(
            child: Column(
          children: <Widget>[_videoView(views[0])],
        ));
      case 2:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow([views[0]]),
            _expandedVideoRow([views[1]])
          ],
        ));
      case 3:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 3))
          ],
        ));
      case 4:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 4))
          ],
        ));
      default:
    }
    return Container();
  }

  /// Info panel to show logs
  Widget _panel() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: ListView.builder(
            reverse: true,
            itemCount: _infoStrings.length,
            itemBuilder: (BuildContext context, int index) {
              if (_infoStrings.isEmpty) {
                return null;
              }
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 3,
                  horizontal: 10,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 2,
                          horizontal: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.yellowAccent,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          _infoStrings[index],
                          style: TextStyle(color: Colors.blueGrey),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    AgoraRtcEngine.muteLocalAudioStream(muted);
  }

  void _onToggleSpeaker() {
    setState(() {
      speaker = !speaker;
    });
    AgoraRtcEngine.setEnableSpeakerphone(speaker);
  }

  /// Toolbar layout
  Widget _toolbar() {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            onPressed: _onToggleMute,
            child: Icon(
              muted ? Icons.mic : Icons.mic_off,
              color: muted ? Colors.white : Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: muted ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
          RawMaterialButton(
            onPressed: () {
              timerCounterState.reset();
              callMethods.endCall(call: widget.call, status: isLifted ? 2 : 1);
            },
            child: Icon(
              Icons.call_end,
              color: Colors.white,
              size: 35.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
          ),
          RawMaterialButton(
            onPressed: _onToggleSpeaker,
            child: Icon(
              speaker ? Icons.volume_up : Icons.volume_off,
              color: speaker ? Colors.white : Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: speaker ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // timerCounterState.reset();
    callMethods.endCall(call: widget.call, status: isLifted ? 2 : 1);
    // clear usersadd
    assetsAudioPlayer.stop();
    _users.clear();
    // destroy sdk
    // AgoraRtcEngine.disableVideo();
    AgoraRtcEngine.leaveChannel();
    AgoraRtcEngine.destroy();
    callStreamSubscription.cancel();

    super.dispose();
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) =>  AlertDialog(
            // title: new Text('Are you sure?',style: TextStyle(color: Colors.black),),
            content:  Text(
              'Do you want to End the call',
              style: TextStyle(color: Colors.black),
            ),
            actions: <Widget>[
               FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child:  Text('No'),
              ),
               FlatButton(
                onPressed: () => Navigator.of(context).pop(true),
                child:  Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    // userState = Provider.of<UserState>(context, listen: true);
    callScreenState = Provider.of<CallScreenState>(context, listen: false);
    timerCounterState = Provider.of<TimerCounterState>(context, listen: true);
    final CallRingToneState callRingToneState =
        Provider.of<CallRingToneState>(context, listen: true);
    if (callRingToneState.isPLaying) {
      callRingToneState.stopRingTone();
    }
    // Provider.of<TimerCounterState>(context,listen: true).

    // callScreenState.updateIsCallDailled = false;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Stack(
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                child: SafeArea(
                  child: Column(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.1),
                      widget.call.hasDialled
                          ? CircleAvatar(
                              backgroundImage:
                                  NetworkImage(widget.call.receiverPic),
                              radius: MediaQuery.of(context).size.width * 0.2,
                            )
                          : CircleAvatar(
                              backgroundImage:
                                  NetworkImage(widget.call.callerPic),
                              radius: MediaQuery.of(context).size.width * 0.2,
                            ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02),
                      widget.call.hasDialled
                          ? Text(
                              widget.call.receiverName,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                              ),
                            )
                          : Text(
                              widget.call.callerName,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                              ),
                            ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02),
                      Text(
                        timerCounterState.currentDuration.inHours >= 1
                            ? "${timerCounterState.currentDuration.inHours.remainder(60).toString().padLeft(2, '0')}:${timerCounterState.currentDuration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${(timerCounterState.currentDuration.inSeconds.remainder(60) % 60).toString().padLeft(2, '0')}"
                            : "${timerCounterState.currentDuration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${(timerCounterState.currentDuration.inSeconds.remainder(60) % 60).toString().padLeft(2, '0')}",
                        style: TextStyle(fontSize: 19),
                      ),
                    ],
                  ),
                ),
              ),
              // _viewRows(),
              // _panel(),
              _toolbar(),
            ],
          ),
        ),
      ),
    );
  }
}
