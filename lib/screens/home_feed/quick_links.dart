import 'package:foap/controllers/coupons/near_by_offers.dart';
import 'package:foap/controllers/fund_raising/fund_raising_controller.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/event_imports.dart';
import 'package:foap/screens/add_on/ui/dating/dating_dashboard.dart';
import 'package:foap/screens/add_on/ui/dating/profile/upload_profile_picture.dart';
import 'package:foap/screens/add_on/ui/podcast/podcast_list_dashboard.dart';
import 'package:foap/screens/chatgpt/chat_gpt.dart';
import 'package:foap/screens/fund_raising/fund_raising_dashboard.dart';
import 'package:foap/screens/live/live_users_screen.dart';
import 'package:foap/screens/near_by_offers/offers_dashboard.dart';
import '../../controllers/home/home_controller.dart';
import '../add_on/ui/dating/profile/add_name.dart';
import '../add_on/ui/dating/profile/allow_notifications.dart';
import '../add_on/ui/podcast/podcast_dashboard.dart';
import '../add_on/ui/reel/create_reel_video.dart';
import '../chat/random_chat/choose_profile_category.dart';

import '../club/explore_clubs.dart';
import '../competitions/competitions_screen.dart';
import '../highlights/choose_stories.dart';
import '../live/checking_feasibility.dart';
import '../story/choose_media_for_story.dart';
import '../tvs/tv_dashboard.dart';

enum QuickLinkType {
  live,
  randomChat,
  randomCall,
  competition,
  clubs,
  pages,
  tv,
  event,
  podcast,
  story,
  highlights,
  goLive,
  liveUsers,
  reel,
  dating,
  chatGPT,
  fundRaising,
  offers
}

class QuickLink {
  String icon;
  String heading;
  String subHeading;
  QuickLinkType linkType;

  QuickLink(
      {required this.icon,
      required this.heading,
      required this.subHeading,
      required this.linkType});
}

class QuickLinkWidget extends StatefulWidget {
  final VoidCallback callback;

  const QuickLinkWidget({Key? key, required this.callback}) : super(key: key);

  @override
  State<QuickLinkWidget> createState() => _QuickLinkWidgetState();
}

class _QuickLinkWidgetState extends State<QuickLinkWidget> {
  final HomeController _homeController = Get.find();
  final UserProfileManager _userProfileManager = Get.find();
  final FundRaisingController _fundRaisingController = Get.find();
  final NearByOffersController _nearByOffersController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() => GridView(
            padding: EdgeInsets.only(
                left: DesignConstants.horizontalPadding,
                right: DesignConstants.horizontalPadding,
                top: 20,
                bottom: 100),
            clipBehavior: Clip.hardEdge,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
                childAspectRatio: 2),
            children: [
              for (QuickLink link in _homeController.quickLinks)
                quickLinkView2(link).ripple(() {
                  widget.callback();

                  if (link.linkType == QuickLinkType.competition) {
                    Get.to(() => const CompetitionsScreen());
                  } else if (link.linkType == QuickLinkType.randomChat) {
                    if (AppConfigConstants.isDemoApp) {
                      AppUtil.showDemoAppConfirmationAlert(
                          title: 'Demo app',
                          subTitle:
                              'This is demo app so might not find online user to test it',
                          okHandler: () {
                            Get.to(() => const ChooseProfileCategory(
                                  isCalling: false,
                                ));
                          });
                      return;
                    } else {
                      Get.to(() => const ChooseProfileCategory(
                            isCalling: false,
                          ));
                    }
                  } else if (link.linkType == QuickLinkType.randomCall) {
                    Get.to(() => const ChooseProfileCategory(
                          isCalling: true,
                        ));
                  } else if (link.linkType == QuickLinkType.clubs) {
                    Get.to(() => const ExploreClubs());
                  } else if (link.linkType == QuickLinkType.pages) {
                  } else if (link.linkType == QuickLinkType.goLive) {
                    Get.to(() => CheckingLiveFeasibility(
                          successCallbackHandler: () {},
                        ));
                  } else if (link.linkType == QuickLinkType.story) {
                    Get.to(() => const ChooseMediaForStory());
                  } else if (link.linkType == QuickLinkType.highlights) {
                    Get.to(() => const ChooseStoryForHighlights());
                  } else if (link.linkType == QuickLinkType.tv) {
                    Get.to(() => const TvDashboardScreen());
                  } else if (link.linkType == QuickLinkType.liveUsers) {
                    Get.to(() => const LiveUserScreen());
                  } else if (link.linkType == QuickLinkType.event) {
                    Get.to(() => const EventsDashboardScreen());
                  } else if (link.linkType == QuickLinkType.podcast) {
                    Get.to(() => PodcastDashboard());
                  } else if (link.linkType == QuickLinkType.reel) {
                    Get.to(() => const CreateReelScreen());
                  } else if (link.linkType == QuickLinkType.dating) {
                    if (_userProfileManager.user.value!.canUseDating) {
                      Get.to(() => const DatingDashboard());
                    } else {
                      AppUtil.showNewConfirmationAlert(
                          title: enableDatingString,
                          subTitle: enableDatingProfileToUseString,
                          okHandler: () {
                            Get.to(() => const UploadProfilePicture(
                                isSettingProfile: true));
                          },
                          cancelHandler: () {});
                    }
                  } else if (link.linkType == QuickLinkType.chatGPT) {
                    Get.to(() => const ChatGPT());
                  } else if (link.linkType == QuickLinkType.fundRaising) {
                    _fundRaisingController.initiate();
                    Get.to(() => FundRaisingDashboard())!.then((value) {
                      _fundRaisingController.clear();
                    });
                  } else if (link.linkType == QuickLinkType.offers) {
                    _nearByOffersController.initiate();
                    Get.to(() => OffersDashboard())!.then((value){
                      _nearByOffersController.clear();
                    });
                  }
                })
            ]));
  }

  Widget quickLinkView1(QuickLink link) {
    return Container(
      color: AppColorConstants.cardColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            height: 20,
          ),
          Image.asset(
            link.icon,
            height: 80,
            width: 80,
          ),
          // const Spacer(),
          const Spacer(),
          Heading6Text(
            link.heading.tr,
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    ).round(20);
  }

  Widget quickLinkView2(QuickLink link) {
    return Container(
      color: AppColorConstants.cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            link.icon,
            height: 30,
            width: 30,
          ),
          const SizedBox(
            height: 10,
          ),
          BodyMediumText(
            link.heading.tr,
            weight: TextWeight.semiBold,
          ),
        ],
      ).hP16,
    ).round(20);
  }
}
