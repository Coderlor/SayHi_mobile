import 'package:foap/controllers/coupons/near_by_offers.dart';
import 'package:foap/model/offer_model.dart';
import '../../components/sm_tab_bar.dart';
import '../../helper/imports/common_import.dart';
import 'about_offer.dart';
import 'offer_comments.dart';

class OfferDetail extends StatelessWidget {
  final NearByOffersController _offersController = Get.find();
  final OfferModel offer;

  OfferDetail({Key? key, required this.offer}) : super(key: key);

  final List<String> tabs = [
    aboutString.tr,
    commentsString.tr,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(
                height: Get.height * 0.4,
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: offer.coverImage,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                child: SizedBox(
                  height: Get.height - (Get.height * 0.4),
                  child: DefaultTabController(
                      length: tabs.length,
                      initialIndex: 0,
                      child: Column(
                        children: [
                          SMTabBar(tabs: tabs),
                          const SizedBox(
                            height: 20,
                          ),
                          Expanded(
                            child: TabBarView(children: [
                              AboutOffer(
                                offer: offer,
                              ).hp(DesignConstants.horizontalPadding),
                              const OfferCommentsScreen(),
                            ]),
                          ),
                        ],
                      )),
                ),
              ),
            ],
          ),
          backNavigationBarWithTrailingWidget(
              title: '',
              widget: Obx(() => Container(
                    height: 40,
                    width: 40,
                    color: AppColorConstants.themeColor.withOpacity(0.2),
                    child: ThemeIconWidget(
                        _offersController.currentOffer.value!.isFavourite
                            ? ThemeIcon.favFilled
                            : ThemeIcon.fav,
                        color: _offersController.currentOffer.value!.isFavourite
                            ? AppColorConstants.red
                            : AppColorConstants.iconColor),
                  ).round(10).ripple(() {
                    _offersController
                        .favUnFavOffer(_offersController.currentOffer.value!);
                  }))),
        ],
      ),
    );
  }
}
