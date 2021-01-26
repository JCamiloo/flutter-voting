import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:band_names/models/band_model.dart';
import 'package:band_names/providers/socket_provider.dart';

class HomeScreen extends StatefulWidget {

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  List<BandModel> bands = [];

  @override
  void initState() {
    super.initState();
    final socketProvider = Provider.of<SocketProvider>(context, listen: false);
    socketProvider.socket.on('active-bands', _handleActiveBands);
  }

  @override
  void dispose() {
    super.dispose();
    final socketProvider = Provider.of<SocketProvider>(context, listen: false);
    socketProvider.socket.off('active-bands');
  }

  _handleActiveBands(dynamic payload) {
    this.bands = (payload as List).map((band) => BandModel.fromMap(band)).toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {

    final serverStaus = Provider.of<SocketProvider>(context).serverStatus;

    return Scaffold(
      appBar: AppBar(
        title: Text('Bands', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 10),
            child: serverStaus == ServerStatus.Online ?
                   Icon(Icons.check_circle, color: Colors.blue[300]) :
                   Icon(Icons.offline_bolt, color: Colors.red)
          )
        ],
      ),
      body: Column(
        children: [
          _graph(),
          Expanded(
            child: ListView.builder(
              physics: BouncingScrollPhysics(),
              itemCount: bands.length,
              itemBuilder: (context, i) =>_bandTile(bands[i])
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        elevation: 1,
        onPressed: addNewBand
      )
    );
  }

  Widget _bandTile(BandModel band) {
    final socketProvider = Provider.of<SocketProvider>(context, listen: false);

    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (_) => socketProvider.emit('delete-band', { 'id': band.id }),
      background: Container(
        color: Colors.red,
        padding: EdgeInsets.only(left: 8),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Icon(Icons.delete, color: Colors.white)
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(band.name.substring(0,2)),
          backgroundColor: Colors.blue[100],
        ),
        title: Text(band.name),
        trailing: Text('${band.votes}', style: TextStyle(fontSize: 20)),
        onTap: () => socketProvider.emit('vote-band', { 'id': band.id })
      )
    );
  }

  addNewBand() {
    final textCtrl = TextEditingController();

    if (Platform.isAndroid) {
      return showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('New band name:'),
          content: TextField(
            controller: textCtrl,
          ),
          actions: <Widget>[
            MaterialButton(
              child: Text('Add'),
              elevation: 5,
              textColor: Colors.blue,
              onPressed: () => addBandToList(textCtrl.text)
            )
          ]
        )
      );
    } 

    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text('New band name:'),
        content: CupertinoTextField(
          controller: textCtrl,
        ),
        actions: <Widget>[
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text('Add'),
            onPressed: () => addBandToList(textCtrl.text)
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: Text('Dismiss'),
            onPressed: () => Navigator.pop(context)
          )
        ],
      )
    );
  }

  addBandToList(String name) {
    if (name.trim().length > 1) {
      final socketProvider = Provider.of<SocketProvider>(context, listen: false);
      socketProvider.emit('add-band', { 'name': name });
    }
    Navigator.pop(context);
  }

  Widget _graph() {
    Map<String, double> dataMap = {};
    this.bands.forEach((band) => dataMap[band.name] = band.votes.toDouble());

    final List<Color> colorList = [
      Colors.blue[50],
      Colors.blue[200],
      Colors.pink[50],
      Colors.pink[200],
      Colors.yellow[50],
      Colors.yellow[200]
    ];

    return Container(
      padding: EdgeInsets.only(top: 20, left: 20),
      width: double.infinity,
      height: 200,
      child: dataMap.isNotEmpty ? 
        PieChart(
          dataMap: dataMap,
          animationDuration: Duration(milliseconds: 800),
          colorList: colorList,
          initialAngleInDegree: 0,
          chartType: ChartType.ring,
          ringStrokeWidth: 32,
          legendOptions: LegendOptions(
            showLegendsInRow: false,
            legendPosition: LegendPosition.right,
            legendShape: BoxShape.circle,
            legendTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          chartValuesOptions: ChartValuesOptions(
            showChartValueBackground: true,
            showChartValues: true,
            showChartValuesInPercentage: false,
            showChartValuesOutside: false,
            decimalPlaces: 0
          ),
        ) :
        Center(child: Text('No data'))
    );
  }
}