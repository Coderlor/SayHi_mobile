import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/reel_imports.dart';

class Reels extends StatefulWidget {
  final bool needBackBtn;

  const Reels({Key? key, required this.needBackBtn}) : super(key: key);

  @override
  State<Reels> createState() => _ReelsState();
}

class _ReelsState extends State<Reels> {
  final ReelsController _reelsController = Get.find();

  @override
  void initState() {
    super.initState();
    _reelsController.getReels();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
          backgroundColor: AppColorConstants.backgroundColor,
          body: Stack(
            children: [
              GetBuilder<ReelsController>(
                  init: _reelsController,
                  builder: (ctx) {
                    return PageView(
                        scrollDirection: Axis.vertical,
                        allowImplicitScrolling: true,
                        onPageChanged: (index) {
                          _reelsController.currentPageChanged(
                              index, _reelsController.publicMoments[index]);
                        },
                        children: [
                          for (int i = 0;
                              i < _reelsController.publicMoments.length;
                              i++)
                            SizedBox(
                              height: Get.height,
                              width: Get.width,
                              // color: Colors.brown,
                              child: ReelVideoPlayer(
                                reel: _reelsController.publicMoments[i],
                                // play: false,
                              ),
                            )
                        ]);
                  }),
              Positioned(
                  right: DesignConstants.horizontalPadding,
                  left: DesignConstants.horizontalPadding,
                  top: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      widget.needBackBtn ?
                        Container(
                          height: 40,
                          width: 40,
                          color: AppColorConstants.themeColor.withOpacity(0.5),
                          child: const ThemeIconWidget(
                            ThemeIcon.backArrow,
                            color: Colors.white,
                          ).lP8.ripple(() {
                            Get.back();
                          }),
                        ).circular : Container(),
                      Container(
                        height: 40,
                        width: 40,
                        color: AppColorConstants.themeColor.withOpacity(0.5),
                        child: const ThemeIconWidget(
                          ThemeIcon.camera,
                          color: Colors.white,
                        ).ripple(() {
                          Get.to(() => const CreateReelScreen());
                        }),
                      ).circular,
                    ],
                  ))
            ],
          )),
    );
  }
}