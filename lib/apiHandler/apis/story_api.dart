import 'dart:ui';
import 'package:foap/apiHandler/api_wrapper.dart';
import '../../model/story_model.dart';

class StoryApi {
  static postStory({required List<Map<String, String>> gallery}) async {
    var url = NetworkConstantsUtil.addStory;

    var param = {
      "stories": gallery,
    };

    await ApiWrapper().postApi(url: url, param: param).then((value) {});
  }

  static getMyStories(
      {required Function(List<StoryMediaModel>) resultCallback})async  {
    var url = NetworkConstantsUtil.myStories;

    await ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['story']['items'];
        resultCallback(List<StoryMediaModel>.from(
            items.map((x) => StoryMediaModel.fromJson(x))));
      }
    });
  }

  static getStories({required Function(List<StoryModel>) resultCallback})async  {
    var url = NetworkConstantsUtil.stories;

    await ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['story'];
          resultCallback(
              List<StoryModel>.from(items.map((x) => StoryModel.fromJson(x))));

      }
    });
  }

  static Future<void> getMyCurrentActiveStories(
      {required Function(List<StoryMediaModel>) resultCallback}) async {
    var url = NetworkConstantsUtil.myCurrentActiveStories;

    await ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['story']['items'];

          resultCallback(List<StoryMediaModel>.from(
              items.map((x) => StoryMediaModel.fromJson(x))));

        return;
      }
    });
  }

  static deleteStory({required int id, required VoidCallback callback}) async {
    var url = NetworkConstantsUtil.deleteStory + id.toString();

    await ApiWrapper().deleteApi(url: url).then((value) {
      callback();
    });
  }
}
