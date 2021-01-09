import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoPostDetail extends StatefulWidget {
  InfoPostDetail({this.eveId, this.title});
  String eveId;
  String title;
  @override
  _InfoPostDetailState createState() =>
      _InfoPostDetailState(eveID: eveId, title: title);
}

class _InfoPostDetailState extends State<InfoPostDetail> {
  String eveID;
  String title;
  _InfoPostDetailState({this.eveID, this.title});

  CollectionReference infoEvent =
      FirebaseFirestore.instance.collection('infoPost');

  Future<void> _launchInWebViewWithJavaScript(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: true,
        forceWebView: true,
        enableJavaScript: true,
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  final slider = SleekCircularSlider(
      appearance: CircularSliderAppearance(
    spinnerMode: true,
    size: 50.0,
  ));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: GestureDetector(
          child: Icon(Icons.arrow_back_ios),
          onTap: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: infoEvent.doc(eveID).get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text("Something went wrong");
          }

          if (snapshot.connectionState == ConnectionState.done) {
            Map<String, dynamic> data = snapshot.data.data();
            return ListView(
              scrollDirection: Axis.vertical,
              padding: EdgeInsets.all(10.0),
              children: [
                Text(
                  'Event: ${data['Event']}',
                  style: TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Text(
                  'Organised by: ${data['Organiser']}',
                  style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.w400),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Text(
                  'Description: ${data['Description']}',
                  style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.w400),
                ),
                SizedBox(
                  height: 20.0,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    children: [
                      Text('More Info at: ', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500),),
                      SizedBox(width: 5.0,),
                      Flexible(
                        fit: FlexFit.tight,
                        child: GestureDetector(
                          child: Text('${data['URL']}', style: TextStyle(fontSize: 20.0, color: Colors.blueAccent[700]),),
                          onTap: () =>
                              _launchInWebViewWithJavaScript(data['URL']),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          return Center(
            child: slider,
          );
        },
      ),
    );
  }
}
