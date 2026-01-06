import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

// Temporary stubs
class AppInsets {
  static const sideInsets = EdgeInsets.symmetric(horizontal: 16, vertical: 8);
}

class TileHollow extends StatelessWidget {
  final EdgeInsets margin;
  final EdgeInsets padding;
  final Color? color;
  final Widget child;
  
  const TileHollow({
    required this.margin,
    required this.padding,
    this.color,
    required this.child,
    super.key,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      color: color,
      child: child,
    );
  }
}

class BannersView extends StatefulWidget {
  const BannersView({required this.mainBannerList, super.key});

  final List<MainBanner>? mainBannerList;

  @override
  BannersViewState createState() => BannersViewState();
}

class BannersViewState extends State<BannersView>
    with TickerProviderStateMixin {
  int _currentIndex = 0;

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppInsets.sideInsets,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Material(
            borderRadius: BorderRadius.circular(8),
            elevation: 1,
            child: TileHollow(
              margin: EdgeInsets.zero,
              padding: EdgeInsets.zero,
              color: Colors.grey[300],
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 190,
                child: _buildCarousel(),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < widget.mainBannerList!.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 20,
                  ),
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == _currentIndex
                          ? Theme.of(context)
                              .primaryColor
                              .withValues(alpha: 0.7)
                          : Colors.grey.withValues(alpha: 0.7),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // Carousel Slider
  Widget _buildCarousel() {
    return CarouselSlider.builder(
      options: CarouselOptions(
        viewportFraction: 1,
        autoPlay: true,
        enlargeCenterPage: true,
        disableCenter: true,
        onPageChanged: (index, reason) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      itemCount: widget.mainBannerList!.length,
      itemBuilder: (context, index, _) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1 + 0.03 * _animationController.value,
                child: child,
              );
            },
            child: Image.asset(
              widget.mainBannerList![index].photo,
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }
}

// Dummy class for MainBanner
class MainBanner {
  MainBanner({required this.id, required this.photo});

  final int? id;
  final String photo;
}

// Dummy data for MainBanner - exported for use in HomeScreen
List<MainBanner> dummyMainBanners = [
  MainBanner(
    id: 0,
    photo: 'assets/banners/group_buy_banner.png',
  ),
  MainBanner(
    id: 1,
    photo: 'assets/banners/custom_requests_banner.png',
  ),
  MainBanner(
    id: 2,
    photo: 'assets/banners/chats_banner.png',
  ),
  MainBanner(
    id: 3,
    photo: 'assets/banners/loyalty_banner.png',
  ),
  MainBanner(
    id: 4,
    photo: 'assets/banners/affiliates_banner.png',
  ),
  MainBanner(
    id: 5,
    photo: 'assets/banners/signup_banner.png',
  ),
  // Add more dummy data
];
