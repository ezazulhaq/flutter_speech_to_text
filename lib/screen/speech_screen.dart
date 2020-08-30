import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:highlight_text/highlight_text.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechScreen extends StatefulWidget {
  @override
  _SpeechScreenState createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  stt.SpeechToText _speechToText;
  bool _isListening = false;
  String _text = "Press the Button and Start Speaking";
  double _confidence = 1.0;

  Map<String, HighlightedWord> _hightLight = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _speechToText = stt.SpeechToText();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speechToText.initialize(
        onStatus: (value) => print("onStatus : $value"),
        onError: (value) => print("onError : $value"),
      );

      if (available) {
        setState(() {
          _isListening = true;
        });

        _speechToText.listen(
          onResult: (value) {
            setState(() {
              _text = value.recognizedWords;
              if (value.hasConfidenceRating && value.confidence > 0) {
                setState(() {
                  _confidence = value.confidence;
                });
              }
            });
          },
        );
      } else {
        setState(() {
          _isListening = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Confidence Level : ${(_confidence * 100).toStringAsFixed(1)}%',
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _text = "Press the Button and Start Speaking";
                _isListening = false;
                _confidence = 1.0;
              });
            },
            icon: Icon(
              Icons.refresh,
              size: 30.0,
            ),
          )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        animate: _isListening,
        glowColor: Theme.of(context).primaryColor,
        endRadius: size.width * 0.25,
        duration: const Duration(milliseconds: 2000),
        repeatPauseDuration: const Duration(milliseconds: 100),
        repeat: true,
        child: SizedBox(
          height: size.width * 0.25,
          width: size.width * 0.25,
          child: FloatingActionButton(
            onPressed: _listen,
            child: Icon(
              _isListening ? Icons.mic : Icons.mic_none,
              size: (size.width * 0.25) / 2,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(30.0),
          child: TextHighlight(
            text: _text,
            words: _hightLight,
            textStyle: TextStyle(
              fontSize: 32.0,
              color: Colors.black,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
