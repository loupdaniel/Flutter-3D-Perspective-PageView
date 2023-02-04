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
  double fraction = 0.50;

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

    return Transform(
      transform: pvMatrix,
      alignment: FractionalOffset.center,
      child: Container(
        child: Image.asset("assets/images/image_${number.toInt() + 1}.jpg",
            fit: BoxFit
                .fill), //Fill the target box by distorting the source's aspect ratio.
      ),
    );
  }
}
