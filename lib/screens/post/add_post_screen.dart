import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:foap/components/smart_text_field.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/setting_imports.dart';
import 'package:foap/screens/post/post_option_popup.dart';
import 'package:photo_editor_sdk/photo_editor_sdk.dart';
import 'package:video_editor_sdk/video_editor_sdk.dart';
import '../../components/place_picker/entities/location_result.dart';
import '../../components/place_picker/widgets/place_picker.dart';
import '../../components/post_card/video_widget.dart';
import '../../controllers/post/add_post_controller.dart';
import '../../controllers/post/select_post_media_controller.dart';
import '../../model/location.dart';
import '../dashboard/dashboard_screen.dart';
import 'tag_hashtag_view.dart';
import 'tag_users_view.dart';
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
  final SmartTextFieldController _smartTextFieldController = Get.find();
  final SettingsController settingController = Get.find();
  final AddPostController addPostController = Get.find();

  @override
  void initState() {
    _smartTextFieldController.clear();
    super.initState();
  }

  @override
  void dispose() {
    descriptionText.text = '';
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
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
                              onTap: () {
                                Get.back();
                                addPostController.clear();

                                if (!settingsController
                                    .setting.value!.enableReel) {
                                  DashboardController dashboardController =
                                      Get.find();

                                  dashboardController.indexChanged(0);
                                }
                              },
                              child: ThemeIconWidget(ThemeIcon.backArrow)),
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
                            if ((widget.items ??
                                        _selectPostMediaController
                                            .selectedMediaList)
                                    .isNotEmpty ||
                                descriptionText.text.isNotEmpty) {
                              addPostController.uploadAllPostFiles(
                                  allowComments:
                                      addPostController.enableComments.value,
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
                            }
                          }),
                        ],
                      ).hp(DesignConstants.horizontalPadding),
                      const SizedBox(
                        height: 30,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          media().ripple(() {
                            showModalBottomSheet<void>(
                                backgroundColor: Colors.transparent,
                                context: context,
                                enableDrag: true,
                                isDismissible: true,
                                isScrollControlled: true,
                                builder: (BuildContext context) {
                                  return FractionallySizedBox(
                                      heightFactor: 1,
                                      child: Container(
                                        color:
                                            AppColorConstants.backgroundColor,
                                        child: AddedMediaList(
                                          selectPostMediaController:
                                              _selectPostMediaController,
                                        ),
                                      ));
                                });
                          }),
                          Expanded(child: addDescriptionView()),
                        ],
                      ).hp(DesignConstants.horizontalPadding),
                      const SizedBox(
                        height: 20,
                      ),
                      divider(height: 0.5),
                      SizedBox(
                        height: 50,
                        child: Row(
                          children: [
                            ThemeIconWidget(ThemeIcon.message),
                            const SizedBox(
                              width: 15,
                            ),
                            BodyLargeText(allowCommentsString),
                            const Spacer(),
                            Obx(() => ThemeIconWidget(
                                        addPostController.enableComments.value
                                            ? ThemeIcon.selectedCheckbox
                                            : ThemeIcon.emptyCheckbox)
                                    .ripple(() {
                                  addPostController.toggleEnableComments();
                                })),
                          ],
                        ),
                      ).hp(DesignConstants.horizontalPadding),
                      divider(height: 0.5),
                      SizedBox(
                        height: 50,
                        child: Row(
                          children: [
                             ThemeIconWidget(ThemeIcon.location),
                            const SizedBox(
                              width: 15,
                            ),
                            Obx(() =>
                                addPostController.taggedLocation.value == null
                                    ? BodyLargeText(addLocationString)
                                    : BodyLargeText(addPostController
                                        .taggedLocation.value!.name)),
                            const Spacer(),
                            Obx(() => addPostController.taggedLocation.value ==
                                    null
                                ?  ThemeIconWidget(ThemeIcon.nextArrow)
                                :  ThemeIconWidget(ThemeIcon.close)
                                    .ripple(() {
                                    addPostController.setTaggedLocation(null);
                                  })),
                          ],
                        ),
                      ).hp(DesignConstants.horizontalPadding).ripple(() {
                        openLocationPicker();
                      }),
                      divider(height: 0.5),
                      const SizedBox(
                        height: 10,
                      ),
                      Obx(() {
                        return _smartTextFieldController.isEditing.value == 1
                            ? Expanded(
                                child: Container(
                                  // height: 500,
                                  width: double.infinity,
                                  color: AppColorConstants.disabledColor
                                      .withOpacity(0.1),
                                  child: _smartTextFieldController
                                          .currentHashtag.isNotEmpty
                                      ? TagHashtagView()
                                      : _smartTextFieldController
                                              .currentUserTag.isNotEmpty
                                          ? TagUsersView()
                                          : Container().ripple(() {
                                              FocusManager.instance.primaryFocus
                                                  ?.unfocus();
                                            }),
                                ),
                              )
                            : Container();
                      }),
                      Obx(() => _smartTextFieldController.isEditing.value == 0
                          ? const Spacer()
                          : Container()),
                      if (widget.isReel != true)
                        PostOptionsPopup(
                          selectedMediaList: (medias) {
                            _selectPostMediaController.mediaSelected(medias);
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
                    ]),
              ],
            );
          }),
    );
  }

  Widget media() {
    return Obx(() {
      if (_selectPostMediaController.selectedMediaList.isNotEmpty) {
        Media media = _selectPostMediaController.selectedMediaList.first;
        return Container(
          height: 70,
          width: 70,
          color: AppColorConstants.cardColor,
          child: media.mediaType == GalleryMediaType.photo
              ? Image.file(
                  media.file!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                )
              : media.mediaType == GalleryMediaType.gif
                  ? CachedNetworkImage(
                      fit: BoxFit.cover, imageUrl: media.filePath!)
                  : media.mediaType == GalleryMediaType.video
                      ? Stack(
                          children: [
                            Image.memory(
                              media.thumbnail!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                            Container(
                              color: Colors.black45,
                            ),
                             Center(
                              child: ThemeIconWidget(
                                ThemeIcon.play,
                                size: 50,
                                color: Colors.white,
                              ),
                            )
                          ],
                        )
                      :  ThemeIconWidget(ThemeIcon.mic),
        ).round(10).rP8;
      } else {
        return Container();
      }
    });
  }

  Widget addDescriptionView() {
    return SizedBox(
      height: 70,
      child: Obx(() {
        descriptionText.value = TextEditingValue(
            text: _smartTextFieldController.searchText.value,
            selection: TextSelection.fromPosition(TextPosition(
                offset: _smartTextFieldController.position.value)));

        return Container(
          color: AppColorConstants.cardColor,
          child: SmartTextField(
              maxLine: 5,
              controller: descriptionText,
              onTextChangeActionHandler: (text, offset) {
                _smartTextFieldController.textChanged(text, offset);
              },
              onFocusChangeActionHandler: (status) {
                if (status == true) {
                  _smartTextFieldController.startedEditing();
                } else {
                  _smartTextFieldController.stoppedEditing();
                }
              }),
        ).round(5);
      }),
    );
  }

  void openLocationPicker() {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        isScrollControlled: true,
        builder: (context) => FractionallySizedBox(
            heightFactor: 0.9,
            child: PlacePicker(
              apiKey: AppConfigConstants.googleMapApiKey,
              displayLocation: null,
            ))).then((location) {
      if (location != null) {
        LocationResult result = location as LocationResult;
        LocationModel locationModel = LocationModel(
            latitude: result.latLng!.latitude,
            longitude: result.latLng!.longitude,
            name: result.name!);
        addPostController.setTaggedLocation(locationModel);
      }
    });
  }
}

class AddedMediaList extends StatelessWidget {
  final SelectPostMediaController selectPostMediaController;
  final SettingsController settingController = Get.find();

  AddedMediaList({Key? key, required this.selectPostMediaController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 40,
            ),
            Row(
              children: [
                SizedBox(
                  width: DesignConstants.horizontalPadding,
                ),
                Container(
                    height: 40,
                    width: 40,
                    color: AppColorConstants.themeColor,
                    child:  ThemeIconWidget(
                      ThemeIcon.close,
                      color: Colors.white,
                    )).circular.ripple(() {
                  Navigator.pop(context);
                })
              ],
            ),
            SizedBox(
              height: Get.height * 0.5,
              child: Stack(
                children: [
                  Obx(() {
                    return CarouselSlider(
                      items: [
                        for (Media media
                            in selectPostMediaController.selectedMediaList)
                          media.mediaType == GalleryMediaType.photo
                              ? Image.file(
                                  media.file!,
                                  fit: BoxFit.contain,
                                  width: double.infinity,
                                ).ripple(() {
                            if (settingController
                                .setting.value!.canEditPhotoVideo) {
                              openImageEditor(media);
                            }
                          })
                              : media.mediaType == GalleryMediaType.gif
                                  ? CachedNetworkImage(
                                      fit: BoxFit.cover,
                                      imageUrl: media.filePath!)
                                  : media.mediaType == GalleryMediaType.video
                                      ? VideoPostTile(
                                          width: Get.width,
                                          url: media.file!.path,
                                          isLocalFile: true,
                                          play: true,
                                          onTapActionHandler: () {
                                            if (settingController
                                                .setting.value!.canEditPhotoVideo) {
                                              openVideoEditor(media);
                                            }
                                          },
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
                          selectPostMediaController.updateGallerySlider(index);
                        },
                      ),
                    );
                  }),
                  Obx(() {
                    return selectPostMediaController.selectedMediaList.length >
                            1
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
                                          dotsCount: selectPostMediaController
                                              .selectedMediaList.length,
                                          position: selectPostMediaController
                                              .currentIndex.value,
                                          decorator: DotsDecorator(
                                              activeColor:
                                                  AppColorConstants.themeColor),
                                        ).hP8)
                                    .round(20)),
                          )
                        : Container();
                  })
                ],
              ).p16,
            ),
            const SizedBox(
              height: 20,
            ),
            if (selectPostMediaController.selectedMediaList.isNotEmpty &&
                settingController.setting.value!.canEditPhotoVideo &&
                selectPostMediaController.canEditMedia)
              Heading2Text(
                tapToEditString.tr,
                weight: TextWeight.bold,
              ),
          ],
        ),
      ],
    );
  }

  Widget audioPostTile(Media media) {
    return AudioFilePlayer(
      path: media.filePath!,
    );
  }

  openImageEditor(Media media) async {
    // PESDK.unlockWithLicense("assets/pesdk_license");

    final result = await PESDK.openEditor(image: media.file!.path);

    if (result != null) {
      // The user exported a new photo successfully and the newly generated photo is located at `result.image`.
      Media editedMedia = media.copy;
      editedMedia.file = File(result.image.replaceAll('file://', ''));
      selectPostMediaController.replaceMediaWithEditedMedia(
          originalMedia: media, editedMedia: editedMedia);
    } else {
      // The user exported a new photo successfully and the newly generated photo is located at `result.image`.
      return;
    }
  }

  openVideoEditor(Media media) async {
    // PESDK.unlockWithLicense("assets/pesdk_license");

    print('openVideoEditor');
    final video = Video(media.file!.path);
    final result = await VESDK.openEditor(video);

    if (result != null) {
      // The user exported a new photo successfully and the newly generated photo is located at `result.image`.
      Media editedMedia = media.copy;
      editedMedia.file = File(result.video.replaceAll('file://', ''));
      selectPostMediaController.replaceMediaWithEditedMedia(
          originalMedia: media, editedMedia: editedMedia);
    } else {
      // The user exported a new photo successfully and the newly generated photo is located at `result.image`.
      return;
    }
  }
}
