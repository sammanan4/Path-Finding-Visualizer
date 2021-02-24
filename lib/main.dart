import 'dart:async';
// import 'dart:io';

import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
// import 'dart:math' show pow, sqrt;

void main() {
  runApp(MyApp());
}

class Node {
  Color nodeColor;
  int x, y;
  int parentCoordsX, parentCoordsY;
  // int distToSourceX = 99999, distToSourceY = 99999;
  int distToSource;
  double eulerDist = 99999.0;
  bool blocked, visited;
  Node({
    this.nodeColor = Colors.grey,
    this.x,
    this.y,
    this.visited = false,
    this.blocked = false,
    this.distToSource = 9999,
    // this.distToSourceX = 99999,
    // this.distToSourceY = 99999,
  });
  @override
  String toString() {
    return "${this.nodeColor} , x:${this.x}, y:${this.y}";
  }
}

enum Operations { source, dest, block }

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PathFinder',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home:
          // NewApp(),
          MyHomePage(title: 'PathFinder'),
      // MyHomePage1(title: 'PathFinder'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  GlobalKey _gridKey = GlobalKey();
  GlobalKey _itemKey = GlobalKey();
  bool mouseHeld = false, tapped = true;
  Operations _selectedOp = Operations.source;
  List<List<Node>> adjMat;
  List<List<AnimationController>> _controllers;
  List<List<CurvedAnimation>> _scaleAnimations;
  Node sourceNode, destNode;

  void initializeGraph() {
    // graph
    adjMat = List();

    // separate controller for each node
    _controllers = List();

    // curved animations for each node
    _scaleAnimations = List();

    // initialize the arrays
    for (int i = 0; i < 25; i++) {
      adjMat.add(List());
      _controllers.add(List());
      _scaleAnimations.add(List());
      for (int j = 0; j < 45; j++) {
        adjMat[i].add(Node(x: i, y: j));
        _controllers[i].add(
          AnimationController(
            vsync: this,
            duration: Duration(milliseconds: 300),
          ),
        );
        _scaleAnimations[i].add(
          CurvedAnimation(
            curve: Curves.bounceInOut,
            parent: _controllers[i][j],
          ),
        );
      }
    }
  }

  void dijkstraFind() async {
    // Comparator<Node> comp = (Node node1, Node node2) {
    // double d1 = sqrt(pow(node1.distToSourceX - 0, 2) + pow(node1.distToSourceY - 0, 2));
    // double d2 = sqrt(pow(node2.distToSourceX - 0, 2) + pow(node2.distToSourceY - 0, 2));
    // return node1.eulerDist.compareTo(node2.eulerDist);
    // return node1.distToSource.compareTo(node2.distToSource);
    // };

    PriorityQueue<List<int>> queue = PriorityQueue<List<int>>((List<int> node1, List<int> node2) {
      return adjMat[node1[0]][node1[1]].distToSource.compareTo(adjMat[node2[0]][node2[1]].distToSource);
    });
    queue.add([sourceNode.x, sourceNode.y]);
    sourceNode.distToSource = 0;

    Node node;
    while (queue.isNotEmpty) {
      await Future.delayed(Duration(microseconds: 1));
      List<int> nodeCoords = queue.removeFirst();
      node = adjMat[nodeCoords[0]][nodeCoords[1]];
      if (node == destNode) break;
      node.visited = true;
      if (node != sourceNode) node.nodeColor = Colors.amber[900];

      // node to right
      if (node.x < 25 &&
          node.y < 44 &&
          node.x >= 0 &&
          node.y >= 0 &&
          !adjMat[node.x][node.y + 1].visited &&
          !adjMat[node.x][node.y + 1].blocked) {
        // compare current distance to source and new distance to source (if we update)
        if (node.distToSource + 1 < adjMat[node.x][node.y + 1].distToSource) {
          // adjMat[node.x][node.y + 1].distToSourceX = tempNode.distToSourceX;
          adjMat[node.x][node.y + 1].distToSource = node.distToSource + 1;
          // adjMat[node.x][node.y + 1].eulerDist = sqrt(pow(tempNode.distToSourceX,2) + pow(tempNode.distToSourceY,2));
          adjMat[node.x][node.y + 1].parentCoordsX = node.x;
          adjMat[node.x][node.y + 1].parentCoordsY = node.y;
          if (!queue.contains([node.x, node.y + 1])) queue.add([node.x, node.y + 1]);
        }
      }

      // node below
      if (node.x < 24 &&
          node.y < 45 &&
          node.x >= 0 &&
          node.y >= 0 &&
          !adjMat[node.x + 1][node.y].visited &&
          !adjMat[node.x + 1][node.y].blocked) {
        if (node.distToSource + 1 < adjMat[node.x + 1][node.y].distToSource) {
          // adjMat[node.x + 1][node.y].distToSourceX = tempNode.distToSourceX;
          adjMat[node.x + 1][node.y].distToSource = node.distToSource + 1;
          // adjMat[node.x + 1][node.y].eulerDist = sqrt(pow(tempNode.distToSourceX,2) + pow(tempNode.distToSourceY,2));
          adjMat[node.x + 1][node.y].parentCoordsX = node.x;
          adjMat[node.x + 1][node.y].parentCoordsY = node.y;
          if (!queue.contains([node.x + 1, node.y])) queue.add([node.x + 1, node.y]);
        }
      }

      //
      if (node.x < 25 &&
          node.y < 45 &&
          node.x >= 0 &&
          node.y > 0 &&
          !adjMat[node.x][node.y - 1].visited &&
          !adjMat[node.x][node.y - 1].blocked) {
        if (node.distToSource + 1 < adjMat[node.x][node.y - 1].distToSource) {
          // adjMat[node.x][node.y - 1].distToSourceX = tempNode.distToSourceX;
          adjMat[node.x][node.y - 1].distToSource = node.distToSource + 1;
          // adjMat[node.x][node.y - 1].eulerDist = sqrt(pow(tempNode.distToSourceX,2) + pow(tempNode.distToSourceY,2));
          adjMat[node.x][node.y - 1].parentCoordsX = node.x;
          adjMat[node.x][node.y - 1].parentCoordsY = node.y;
          if (!queue.contains([node.x, node.y - 1])) queue.add([node.x, node.y - 1]);
        }
      }

      if (node.x < 25 &&
          node.y < 45 &&
          node.x > 0 &&
          node.y >= 0 &&
          !adjMat[node.x - 1][node.y].visited &&
          !adjMat[node.x - 1][node.y].blocked) {
        if (node.distToSource + 1 < adjMat[node.x - 1][node.y].distToSource) {
          // adjMat[node.x - 1][node.y].distToSourceX = tempNode.distToSourceX;
          adjMat[node.x - 1][node.y].distToSource = node.distToSource + 1;
          // adjMat[node.x - 1][node.y].eulerDist = sqrt(pow(tempNode.distToSourceX,2) + pow(tempNode.distToSourceY,2));
          adjMat[node.x - 1][node.y].parentCoordsX = node.x;
          adjMat[node.x - 1][node.y].parentCoordsY = node.y;
          if (!queue.contains([node.x - 1, node.y])) queue.add([node.x - 1, node.y]);
        }
      }
      setState(() {
        _controllers[nodeCoords[0]][nodeCoords[1]].forward(from: 0);
      });
    }
    node = adjMat[destNode.parentCoordsX][destNode.parentCoordsY];
    while (node.parentCoordsX != null) {
      await Future.delayed(Duration(microseconds: 1));
      node.nodeColor = Colors.green[900];
      node = adjMat[node.parentCoordsX][node.parentCoordsY];
      setState(() {
        _controllers[node.x][node.y].forward(from: 0);
      });
    }
  }

  @override
  void initState() {
    initializeGraph();
    for (List item in _controllers) {
      for (AnimationController i in item) {
        i.forward();
      }
    }
    super.initState();
  }

  @override
  void dispose() {
    for (List item in _controllers) {
      for (AnimationController controller in item) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  List getCoords(double curPosX, double curPosY) {
    Size elSize = _itemKey.currentContext.size;
    RenderBox obj = _gridKey.currentContext.findRenderObject();
    double gridPosX = obj.localToGlobal(Offset.zero).dx;
    double gridPosY = obj.localToGlobal(Offset.zero).dy;
    int x = ((curPosX - gridPosX) ~/ elSize.width).floor().toInt();
    int y = ((curPosY - gridPosY) ~/ elSize.height).floor().toInt();
    return [x, y];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: GestureDetector(
        onTapDown: (details) {
          List vals = getCoords(details.globalPosition.dx, details.globalPosition.dy);
          if (vals[0] < 0 || vals[1] < 0) return;
          if (adjMat[vals[1]][vals[0]].nodeColor != Colors.red[900]) {
            if (_selectedOp == Operations.source) {
              if (sourceNode != null) sourceNode.nodeColor = Colors.grey;
              sourceNode = adjMat[vals[1]][vals[0]];
              sourceNode.nodeColor = Colors.lightBlue[900];
            } else if (_selectedOp == Operations.dest) {
              if (destNode != null) destNode.nodeColor = Colors.grey;
              destNode = adjMat[vals[1]][vals[0]];
              destNode.nodeColor = Color(0xff5f0707);
            }
            _controllers[vals[1]][vals[0]].forward(from: 0);
          }
          setState(() {});
        },
        // dragging to block
        onPanStart: _selectedOp != Operations.block
            ? null
            : (details) {
                setState(() {
                  mouseHeld = true;
                  List vals = getCoords(details.globalPosition.dx, details.globalPosition.dy);
                  if (mouseHeld && adjMat[vals[1]][vals[0]].nodeColor != Colors.red[900]) {
                    adjMat[vals[1]][vals[0]].nodeColor = Colors.red[900];
                    adjMat[vals[1]][vals[0]].blocked = true;
                    _controllers[vals[1]][vals[0]].forward(from: 0);
                  }
                });
              },
        // dragging to block
        onPanUpdate: _selectedOp != Operations.block
            ? null
            : (details) {
                List vals = getCoords(details.globalPosition.dx, details.globalPosition.dy);
                setState(() {
                  if (mouseHeld && adjMat[vals[1]][vals[0]].nodeColor != Colors.red[900]) {
                    adjMat[vals[1]][vals[0]].nodeColor = Colors.red[900];
                    adjMat[vals[1]][vals[0]].blocked = true;
                    _controllers[vals[1]][vals[0]].forward(from: 0);
                  }
                });
              },
        // stop dragging to block
        onPanEnd: _selectedOp != Operations.block
            ? null
            : (details) {
                setState(() {
                  mouseHeld = false;
                });
              },
        child: Center(
          child: Row(
            children: [
              // Options
              // Expanded(
              // child:
              Container(
                width: 300.0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(30.0, 5.0, 30.0, 5.0),
                      child: ListTile(
                        tileColor: Colors.blueGrey,
                        leading: Radio(
                          activeColor: Colors.white,
                          value: Operations.source,
                          groupValue: _selectedOp,
                          onChanged: (value) {
                            setState(() {
                              _selectedOp = value;
                            });
                          },
                        ),
                        title: Text(
                          "Drop Source",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(30.0, 5.0, 30.0, 5.0),
                      child: ListTile(
                        tileColor: Colors.blueGrey,
                        leading: Radio(
                          activeColor: Colors.white,
                          value: Operations.dest,
                          groupValue: _selectedOp,
                          onChanged: (value) {
                            setState(() {
                              _selectedOp = value;
                            });
                          },
                        ),
                        title: Text(
                          "Drop Destination",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(30.0, 5.0, 30.0, 5.0),
                      child: ListTile(
                        tileColor: Colors.blueGrey,
                        leading: Radio(
                          activeColor: Colors.white,
                          value: Operations.block,
                          groupValue: _selectedOp,
                          onChanged: (value) {
                            setState(() {
                              _selectedOp = value;
                            });
                          },
                        ),
                        title: Text(
                          "Block Paths",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    RaisedButton(
                      onPressed: dijkstraFind,
                      child: Text("Find Path"),
                    ),
                  ],
                ),
              ),
              // ),
              VerticalDivider(
                color: Colors.grey,
                thickness: 1.0,
                indent: 100.0,
                endIndent: 100.0,
              ),
              // // Graph
              // Expanded(
              //   flex: 2,
              //   child:
              Padding(
                padding: EdgeInsets.only(top: 50.0, bottom: 0.0),
                child: Column(
                  key: _gridKey,
                  children: [
                    for (List row in adjMat)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (Node n in row)
                            ScaleTransition(
                              scale: _scaleAnimations[n.x][n.y],
                              child: Container(
                                key: n.x == 0 && n.y == 0 ? _itemKey : null,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black, width: 0.5),
                                  color: n.nodeColor,
                                ),
                                padding: EdgeInsets.all(50.0),
                                width: 20.0,
                                height: 20.0,
                              ),
                            )
                        ],
                      )
                  ],
                ),
              ),
              // ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
