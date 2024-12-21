import 'package:flutter/material.dart';
import 'package:hide_out_lounge/pages/signup.dart';
import 'package:hide_out_lounge/widget/model.dart';
import 'package:hide_out_lounge/widget/widget_support.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Onboard extends StatefulWidget {
  const Onboard({super.key});

  @override
  State<Onboard> createState() => _OnboardState();
}

class _OnboardState extends State<Onboard> {
  int currentIndex = 0;
  late PageController _controller;

  @override
  void initState() {
    _controller = PageController(initialPage: 0);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: contents.length,
                onPageChanged: (int index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
                itemBuilder: (_, i) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          contents[i].image,
                          height: 300,
                          width: MediaQuery.of(context).size.width,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(height: 40.0),
                        Text(
                          contents[i].title,
                          style: AppWidget.HeadlineTextFeildStyle(),
                        ),
                        const SizedBox(height: 20.0),
                        Text(
                          contents[i].description,
                          style: AppWidget.LightTextFeildStyle(),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  contents.length,
                  (index) => buildDot(index, context),
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                if (currentIndex == contents.length - 1) {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('onboardingComplete', true);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Signup()),
                  );
                } else {
                  _controller.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                height: 60,
                margin: const EdgeInsets.all(20),
                width: double.infinity,
                child: Center(
                  child: Text(
                    currentIndex == contents.length - 1 ? "Start" : "Next",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container buildDot(int index, BuildContext context) {
    return Container(
      height: 10.0,
      width: currentIndex == index ? 18 : 7,
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: Colors.black38,
      ),
    );
  }
}
