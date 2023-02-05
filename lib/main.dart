import 'package:flutter/material.dart';
import 'package:flutter3d_perspective_pageview/PageViewHolder.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Perspective PageView',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late PageViewHolder holder;
  late PageController _controller;
  double fraction =
      0.57; // By using this fraction, we're telling the PageView to show the 50% of the previous and the next page area along with the main page

  @override
  void initState() {
    super.initState();
    holder = PageViewHolder(value: 2.0);
    _controller = PageController(initialPage: 2, viewportFraction: fraction);
    _controller.addListener(() {
      holder.setValue(_controller.page);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text("Perspective PageView"),
      ),
      body: Container(
        child: Center(
          child: AspectRatio(
            aspectRatio: 1,
            child: ChangeNotifierProvider<PageViewHolder>.value(
              value: holder,
              child: PageView.builder(
                  controller: _controller,
                  itemCount: 6,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return MyPage(
                      number: index.toDouble(),
                      fraction: fraction,
                    );
                  }),
            ),
          ),
        ),
      ),
    ));
  }
}

class MyPage extends StatelessWidget {
  final number;
  final double? fraction;

  const MyPage({super.key, this.number, this.fraction});

  @override
  Widget build(BuildContext context) {
    double? value = Provider.of<PageViewHolder>(context).value;
    double diff = (number - value);
    // diff is negative = left page
    // diff is 0 = current page
    // diff is positive = next page

    //Matrix for Elements
    final Matrix4 pvMatrix = Matrix4.identity()
      ..setEntry(3, 2, 1 / 0.9) //Increasing Scale by 90%
      ..setEntry(1, 1, fraction!) //Changing Scale Along Y Axis
      ..setEntry(3, 0, 0.004 * -diff); //Changing Perspective Along X Axis

    final Matrix4 shadowMatrix = Matrix4.identity()
      ..setEntry(3, 3, 1 / 1.6) //Increasing Scale by 60%
      ..setEntry(3, 1, -0.004) //Changing Scale Along Y Axis
      ..setEntry(3, 0, 0.002 * diff) //Changing Perspective along X Axis
      ..rotateX(1.309); //Rotating Shadow along X Axis

    return Stack(
      fit: StackFit.expand,
      alignment: FractionalOffset.center,
      children: <Widget>[
        /*if (diff <= 1.0 && diff >= -1.0) ...[
          AnimatedOpacity(
            duration: const Duration(milliseconds: 100),
            opacity: 1 - diff.abs(),
            child: Transform(
              transform: shadowMatrix,
              alignment: FractionalOffset.bottomCenter,
              child: Container(
                decoration: const BoxDecoration(boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10.0,
                      spreadRadius: 1.0)
                ]),
              ),
            ),
          ),
        ],*/
        Material(
          elevation: 50,
          child: Transform(
            transform: pvMatrix,
            alignment: FractionalOffset.center,
            child: Container(
              child: Image.asset(
                  "assets/images/image_${number.toInt() + 1}.jpg",
                  fit: BoxFit
                      .fill), //Fill the target box by distorting the source's aspect ratio.
            ),
          ),
        ),
      ],
    );
  }
}
