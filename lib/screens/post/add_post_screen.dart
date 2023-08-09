import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/screens/post/post_option_popup.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../components/audio_tile.dart';
import '../../components/hashtag_tile.dart';
import '../../components/user_card.dart';
import '../../components/video_widget.dart';
import '../../controllers/misc/users_controller.dart';
import '../../controllers/post/add_post_controller.dart';
import '../../controllers/post/select_post_media_controller.dart';
import '../chat/media.dart';
import 'audio_file_player.dart';

class AddPostScreen extends StatefulWidget {
  final PostType postType;

  final List<Media>? items;
  final int? competitionId;
  final int? clubId;
  final bool? isReel;
  final int? audioId;
  final double? audioStartTime;
  final double? audioEndTime;

  const AddPostScreen(
      {Key? key,
      required this.postType,
      this.items,
      this.competitionId,
      this.clubId,
      this.isReel,
      this.audioId,
      this.audioStartTime,
      this.audioEndTime})
      : super(key: key);

  @override
  AddPostState createState() => AddPostState();
}

class AddPostState extends State<AddPostScreen> {
  TextEditingController descriptionText = TextEditingController();
  final SelectPostMediaController _selectPostMediaController =
      SelectPostMediaController();

  final AddPostController addPostController = Get.find();
  final UsersController _usersController = Get.find();

  final RefreshController _usersRefreshController =
      RefreshController(initialRefresh: false);
  final RefreshController _hashtagRefreshController =
      RefreshController(initialRefresh: false);

  // RateMyApp rateMyApp = RateMyApp(
  //   preferencesPrefix: 'rateMyApp_',
  //   minDays: 0, // Show rate popup on first day of install.
  //   minLaunches:
  //       0, // Show rate popup after 5 launches of app after minDays is passed.
  // );

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // await rateMyApp.init();
      // if (mounted && rateMyApp.shouldOpenDialog) {
      //   rateMyApp.showRateDialog(context);
      // }
      // _selectPostMediaController.clear();
    });
  }

  @override
  void dispose() {
    descriptionText.text = '';
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: GetBuilder<AddPostController>(
          init: addPostController,
          builder: (ctx) {
            return Stack(
              children: [
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(
                        height: 55,
                      ),
                      Row(
                        children: [
                          InkWell(
                              onTap: () => Get.back(),
                              child:
                                  const ThemeIconWidget(ThemeIcon.backArrow)),
                          const Spacer(),
                          Container(
                                  color: AppColorConstants.themeColor,
                                  child: BodyLargeText(
                                    widget.competitionId == null
                                        ? postString.tr
                                        : submitString.tr,
                                    weight: TextWeight.medium,
                                    color: Colors.white,
                                  ).setPadding(
                                      left: 8, right: 8, top: 5, bottom: 5))
                              .round(10)
                              .ripple(() {
                            addPostController.uploadAllPostFiles(
                                postType: widget.postType,
                                isReel: widget.isReel ?? false,
                                audioId: widget.audioId,
                                audioStartTime: widget.audioStartTime,
                                audioEndTime: widget.audioEndTime,
                                items: widget.items ??
                                    _selectPostMediaController
                                        .selectedMediaList,
                                title: descriptionText.text,
                                competitionId: widget.competitionId,
                                clubId: widget.clubId);
                          }),
                        ],
                      ).hp(DesignConstants.horizontalPadding),
                      const SizedBox(
                        height: 30,
                      ),
                      addDescriptionView()
                          .hp(DesignConstants.horizontalPadding),
                      const SizedBox(
                        height: 10,
                      ),
                      Obx(() {
                        return addPostController.isEditing.value == 1
                            ? Expanded(
                                child: Container(
                                  // height: 500,
                                  width: double.infinity,
                                  color: AppColorConstants.disabledColor
                                      .withOpacity(0.1),
                                  child: addPostController
                                          .currentHashtag.isNotEmpty
                                      ? hashTagView()
                                      : addPostController
                                              .currentUserTag.isNotEmpty
                                          ? usersView()
                                          : Container().ripple(() {
                                              FocusManager.instance.primaryFocus
                                                  ?.unfocus();
                                            }),
                                ),
                              )
                            : mediaList();
                      }),
                      Obx(() => addPostController.isEditing.value == 0
                          ? const Spacer()
                          : Container()),
                      Obx(() => addPostController.isEditing.value == 0
                          ? PostOptionsPopup(
                              selectedMediaList: (medias) {
                                _selectPostMediaController
                                    .mediaSelected(medias);
                              },
                              selectGif: (gifMedia) {
                                _selectPostMediaController
                                    .mediaSelected([gifMedia]);
                              },
                              recordedAudio: (audioMedia) {
                                _selectPostMediaController
                                    .mediaSelected([audioMedia]);
                              },
                            )
                          : Container())
                    ]),
              ],
            );
          }),
    );
  }

  Widget mediaList() {
    return Stack(
      children: [
        AspectRatio(
            aspectRatio: 1,
            child: Obx(() {
              return CarouselSlider(
                items: [
                  for (Media media
                      in _selectPostMediaController.selectedMediaList)
                    media.mediaType == GalleryMediaType.photo
                        ? Image.file(
                            media.file!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          )
                        : media.mediaType == GalleryMediaType.gif
                            ? CachedNetworkImage(
                                fit: BoxFit.cover, imageUrl: media.fileUrl!)
                            : media.mediaType == GalleryMediaType.video
                                ? VideoPostTile(
                                    url: media.file!.path,
                                    isLocalFile: true,
                                    play: true,
                                  )
                                : audioPostTile(media)
                ],
                options: CarouselOptions(
                  aspectRatio: 1,
                  enlargeCenterPage: false,
                  enableInfiniteScroll: false,
                  height: double.infinity,
                  viewportFraction: 1,
                  onPageChanged: (index, reason) {
                    _selectPostMediaController.updateGallerySlider(index);
                  },
                ),
              );
            })),
        Obx(() {
          return _selectPostMediaController.selectedMediaList.length > 1
              ? Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Align(
                      alignment: Alignment.center,
                      child: Container(
                              height: 25,
                              color: AppColorConstants.cardColor,
                              child: DotsIndicator(
                                dotsCount: _selectPostMediaController
                                    .selectedMediaList.length,
                                position: _selectPostMediaController
                                    .currentIndex.value,
                                decorator: DotsDecorator(
                                    activeColor: AppColorConstants.themeColor),
                              ).hP8)
                          .round(20)),
                )
              : Container();
        })
      ],
    ).p16;
  }

  Widget audioPostTile(Media media) {
    return AudioFilePlayer(
      path: media.fileUrl!,
    );
  }

  Widget addDescriptionView() {
    return SizedBox(
      height: 100,
      child: Obx(() {
        descriptionText.value = TextEditingValue(
            text: addPostController.searchText.value,
            selection: TextSelection.fromPosition(
                TextPosition(offset: addPostController.position.value)));

        return Focus(
          child: Container(
            color: AppColorConstants.cardColor,
            child: TextField(
              controller: descriptionText,
              textAlign: TextAlign.left,
              style: TextStyle(
                  fontSize: FontSizes.h5,
                  color: AppColorConstants.grayscale900),
              maxLines: 5,
              onChanged: (text) {
                addPostController.textChanged(
                    text, descriptionText.selection.baseOffset);
              },
              decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.only(top: 10, left: 10, right: 10),
                  counterText: "",
                  hintStyle: TextStyle(
                      fontSize: FontSizes.h5,
                      color: AppColorConstants.grayscale500),
                  hintText: addSomethingAboutPostString.tr),
            ),
          ).round(10),
          onFocusChange: (hasFocus) {
            if (hasFocus == true) {
              addPostController.startedEditing();
            } else {
              addPostController.stoppedEditing();
            }
          },
        );
      }),
    );
  }

  usersView() {
    return GetBuilder<AddPostController>(
        init: addPostController,
        builder: (ctx) {
          return ListView.separated(
              padding: EdgeInsets.only(
                  top: 20,
                  left: DesignConstants.horizontalPadding,
                  right: DesignConstants.horizontalPadding),
              itemCount: _usersController.searchedUsers.length,
              itemBuilder: (BuildContext ctx, int index) {
                return UserTile(
                  profile: _usersController.searchedUsers[index],
                  viewCallback: () {
                    addPostController.addUserTag(
                        _usersController.searchedUsers[index].userName);
                  },
                );
              },
              separatorBuilder: (BuildContext ctx, int index) {
                return const SizedBox(
                  height: 20,
                );
              }).addPullToRefresh(
              refreshController: _usersRefreshController,
              onRefresh: () {},
              onLoading: () {
                addPostController.searchUsers(
                    text: addPostController.currentUserTag.value,
                    callBackHandler: () {
                      _usersRefreshController.loadComplete();
                    });
              },
              enablePullUp: true,
              enablePullDown: false);
        });
  }

  hashTagView() {
    return GetBuilder<AddPostController>(
        init: addPostController,
        builder: (ctx) {
          return ListView.builder(
            padding: EdgeInsets.only(
                left: DesignConstants.horizontalPadding,
                right: DesignConstants.horizontalPadding),
            itemCount: addPostController.hashTags.length,
            itemBuilder: (BuildContext ctx, int index) {
              return HashTagTile(
                hashtag: addPostController.hashTags[index],
                onItemCallback: () {
                  addPostController
                      .addHashTag(addPostController.hashTags[index].name);
                },
              );
            },
          ).addPullToRefresh(
              refreshController: _hashtagRefreshController,
              onRefresh: () {},
              onLoading: () {
                addPostController.searchHashTags(
                    text: addPostController.currentHashtag.value,
                    callBackHandler: () {
                      _hashtagRefreshController.loadComplete();
                    });
              },
              enablePullUp: true,
              enablePullDown: false);
        });
  }
}
