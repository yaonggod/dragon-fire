import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class CarouselWidget extends StatefulWidget {
  final List<String> asset;

  const CarouselWidget({
    super.key,
    required this.asset,
  });

  @override
  State<CarouselWidget> createState() => _CarouselWidgetState();
}

class _CarouselWidgetState extends State<CarouselWidget> {
  int _current = 0;
  final CarouselController _controller = CarouselController();

  @override
  Widget build(BuildContext context) {
    final List<Widget> imageSliders = widget.asset.map(
          (assetName) => Image.asset(
        assetName,
        fit: BoxFit.fitHeight,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height*0.8,
      ),
    ).toList();
    return Stack(
      children: [
        CarouselSlider(
          items: imageSliders,
          carouselController: _controller,
          options: CarouselOptions(
            height: MediaQuery.of(context).size.height*0.8,
            viewportFraction: 1.0,
            onPageChanged: (index, reason) {
              setState(() {
                _current = index;
              });
            },
            enableInfiniteScroll: true,
            autoPlay: false,
          ),
        ),
        Positioned(
          top:MediaQuery.of(context).size.height*0.75,
          left: 0,
          right: 0,
          child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: widget.asset.asMap().entries.map(
                  (entry) {
                return GestureDetector(
                  onTap: () => _controller.animateToPage(entry.key),
                  child: Container(
                    width: 12.0,
                    height: 15.0,
                    margin: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 4.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xffffff)
                          .withOpacity(_current == entry.key ? 1 : 0.3),
                    ),
                  ),
                );
              },
            ).toList(),
          ),
        ),
        ),
      ],
    );
  }
}
