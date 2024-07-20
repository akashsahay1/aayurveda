import 'package:flutter/material.dart';
import '../common/appbar.dart';
import '../common/bottombar.dart';

class About extends StatelessWidget {
  const About({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: Appbar(title: 'About Us'),
      backgroundColor: Colors.white,
      body: SafeArea(
          child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Padding(
                padding: EdgeInsets.all(15.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'About Aayurveda',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 30.0,
                            fontWeight: FontWeight.w600),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                      Text(
                        '''The ancient wisdom of Ayurveda meets modern convenience. Our mission is to bring balance, harmony, and holistic well-being to your life through the timeless principles of Ayurveda. At Aayurveda, we believe in the transformative power of Ayurveda, an ancient system of medicine that originated in India thousands of years ago. \n\nAyurveda, which translates to "science of life," emphasizes a personalized approach to health, focusing on the mind, body, and spirit connection. Our app is designed to be your digital guide on the journey to wellness. Whether you're a seasoned Ayurvedic enthusiast or just beginning to explore its benefits, we offer a wealth of information, curated resources, and practical tools to integrate Ayurveda seamlessly into your daily routine. Discover a treasure trove of knowledge about Ayurvedic principles, doshas, and dietary guidelines. \n\nExplore a variety of recipes, yoga practices, and meditation techniques tailored to your unique constitution. Our expertly crafted content aims to empower you with the wisdom to make informed lifestyle choices that resonate with the rhythms of nature. Join our vibrant community of wellness seekers, where you can engage in discussions, share your experiences, and find support on your Ayurvedic journey. We believe that fostering a sense of community enhances the healing process and inspires positive transformations. ''',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(height: 15.0),
                      Text(
                        '''At Aayurveda, we are committed to providing you with a user-friendly and enriching experience. Our team of Ayurvedic practitioners, nutritionists, and wellness experts is dedicated to guiding you towards a state of equilibrium and vitality. Thank you for choosing Aayurveda as your companion on the path to well-being. Embrace the wisdom of Ayurveda and embark on a holistic journey towards a healthier, happier, and more balanced life.''',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(height: 15.0),
                    ]),
              ))),
      bottomNavigationBar: Bottombar(currentIndex: 2),
    );
  }
}
