import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/cmd_code/cmd_code_list_page.dart';
import 'package:chaldea/modules/craft/craft_list_page.dart';
import 'package:chaldea/modules/drop_calculator/drop_calculator_page.dart';
import 'package:chaldea/modules/event/events_page.dart';
import 'package:chaldea/modules/extras/ap_calc_page.dart';
import 'package:chaldea/modules/extras/mystic_code_page.dart';
import 'package:chaldea/modules/home/subpage/edit_gallery_page.dart';
import 'package:chaldea/modules/import_data/import_data_page.dart';
import 'package:chaldea/modules/item/item_list_page.dart';
import 'package:chaldea/modules/master_mission/master_mission_page.dart';
import 'package:chaldea/modules/servant/servant_list_page.dart';
import 'package:chaldea/modules/statistics/game_statistics_page.dart';
import 'package:chaldea/modules/summon/summon_list_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:getwidget/getwidget.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;

class GalleryPage extends StatefulWidget {
  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> with AfterLayoutMixin {
  @override
  void afterFirstLayout(BuildContext context) {
    if (db.userData.sliderUpdateTime?.isNotEmpty != true ||
        db.userData.sliderUrls.isEmpty) {
      resolveSliderImageUrls();
    } else {
      DateTime lastTime = DateTime.parse(db.userData.sliderUpdateTime!),
          now = DateTime.now();
      int dt = now.millisecondsSinceEpoch - lastTime.millisecondsSinceEpoch;
      if (dt > 24 * 3600 * 1000) {
        // more than 1 day
        resolveSliderImageUrls();
      }
    }
    checkAppUpdate();
  }

  Map<String, GalleryItem> get kAllGalleryItems {
    return {
      GalleryItem.servant: GalleryItem(
        name: GalleryItem.servant,
        title: S.of(context).servant_title,
        icon: Icons.people,
        builder: (context, _) => ServantListPage(),
      ),
      GalleryItem.craft_essence: GalleryItem(
        name: GalleryItem.craft_essence,
        title: S.of(context).craft_essence,
        icon: Icons.extension,
        builder: (context, _) => CraftListPage(),
      ),
      GalleryItem.cmd_code: GalleryItem(
        name: GalleryItem.cmd_code,
        title: S.of(context).cmd_code_title,
        icon: Icons.stars,
        builder: (context, _) => CmdCodeListPage(),
      ),
      GalleryItem.item: GalleryItem(
        name: GalleryItem.item,
        title: S.of(context).item_title,
        icon: Icons.category,
        builder: (context, _) => ItemListPage(),
      ),
      GalleryItem.event: GalleryItem(
        name: GalleryItem.event,
        title: S.of(context).event_title,
        icon: Icons.event_available,
        builder: (context, _) => EventListPage(),
      ),
      GalleryItem.plan: GalleryItem(
        name: GalleryItem.plan,
        title: S.of(context).plan_title,
        icon: Icons.article_outlined,
        builder: (context, _) => ServantListPage(planMode: true),
        isDetail: false,
      ),
      GalleryItem.drop_calculator: GalleryItem(
        name: GalleryItem.drop_calculator,
        title: S.of(context).drop_calculator_short,
        icon: Icons.pin_drop,
        builder: (context, _) => DropCalculatorPage(),
        isDetail: true,
      ),
      GalleryItem.weekly_mission: GalleryItem(
        name: GalleryItem.weekly_mission,
        title: S.of(context).master_mission,
        child: Padding(
          padding: EdgeInsets.all(2),
          child: FaIcon(FontAwesomeIcons.tasks, size: 36),
        ),
        builder: (context, _) => MasterMissionPage(),
        isDetail: true,
      ),
      GalleryItem.mystic_code: GalleryItem(
        name: GalleryItem.mystic_code,
        title: S.of(context).mystic_code,
        icon: Icons.toys,
        builder: (context, _) => MysticCodePage(),
        isDetail: true,
      ),
      // GalleryItem.calculator: GalleryItem(
      //   name: GalleryItem.calculator,
      //   title: S.of(context).calculator,
      //   icon: Icons.keyboard,
      //   builder: (context, _) => DamageCalcPage(),
      //   isDetail: true,
      // ),
      if (kDebugMode_)
        GalleryItem.ap_cal: GalleryItem(
          name: GalleryItem.ap_cal,
          title: S.of(context).ap_calc_title,
          icon: Icons.directions_run,
          builder: (context, _) => APCalcPage(),
          isDetail: true,
        ),
      GalleryItem.gacha: GalleryItem(
        name: GalleryItem.gacha,
        title: S.of(context).summon_title,
        child: Padding(
          padding: EdgeInsets.all(2),
          child: FaIcon(FontAwesomeIcons.chessQueen, size: 36),
        ),
        builder: (context, _) => SummonListPage(),
        isDetail: false,
      ),
      GalleryItem.statistics: GalleryItem(
        name: GalleryItem.statistics,
        title: S.of(context).statistics_title,
        icon: Icons.analytics,
        builder: (context, _) => GameStatisticsPage(),
        isDetail: true,
      ),
      GalleryItem.import_data: GalleryItem(
        name: GalleryItem.import_data,
        title: S.of(context).import_data,
        icon: Icons.cloud_download,
        builder: (context, _) => ImportDataPage(),
        isDetail: true,
      ),
      GalleryItem.more: GalleryItem(
        name: GalleryItem.more,
        title: S.of(context).more,
        icon: Icons.add,
        builder: (context, _) => EditGalleryPage(galleries: kAllGalleryItems),
        //fail
        isDetail: true,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(kAppName),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.refresh),
              tooltip: S.of(context).tooltip_refresh_sliders,
              onPressed: () => resolveSliderImageUrls(),
            ),
          ],
        ),
        body: ListView(
          children: <Widget>[
            _buildCarousel(),
            GridView.count(
              crossAxisCount: SplitRoute.isSplit(context) ? 4 : 4,
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              childAspectRatio: 1,
              children: _getShownGalleries(context),
            ),
            if (kDebugMode) buildTestInfoPad(),
          ],
        ));
  }

  Widget _buildCarousel() {
    final sliderPages = _getSliderPages();
    return sliderPages.isEmpty
        ? AspectRatio(
            aspectRatio: 8 / 3,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: Divider.createBorderSide(context, width: 0.5),
                ),
              ),
            ),
          )
        : GFCarousel(
            items: sliderPages,
            aspectRatio: 8.0 / 3.0,
            pagination: true,
            autoPlay: sliderPages.length > 1,
            autoPlayInterval: Duration(seconds: 5),
            viewportFraction: 1.0,
          );
  }

  List<Widget> _getShownGalleries(BuildContext context) {
    List<Widget> _galleryItems = [];
    kAllGalleryItems.forEach((name, item) {
      if ((db.userData.galleries[name] ?? true) || name == GalleryItem.more) {
        _galleryItems.add(TextButton(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 6,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: item.child == null
                      ? Icon(item.icon, size: 40)
                      : item.child,
                ),
              ),
              Expanded(
                flex: 4,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: AutoSizeText(
                    item.title,
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.normal),
                    textAlign: TextAlign.center,
                    maxFontSize: 14,
                  ),
                ),
              )
            ],
          ),
          onPressed: () {
            if (item.builder != null) {
              SplitRoute.push(
                context: context,
                builder: item.builder!,
                detail: item.isDetail,
                popDetail: true,
              );
            }
          },
        ));
      }
    });
    return _galleryItems;
  }

  List<Widget> _getSliderPages() {
    List<Widget> sliders = [];
    if (db.userData.sliderUrls.isEmpty) {
      resolveSliderImageUrls();
      return sliders;
    }
    final urls = db.userData.sliderUrls;
    urls.forEach((imgUrl, link) {
      sliders.add(GestureDetector(
        onTap: () => jumpToExternalLinkAlert(url: link, name: 'Mooncell'),
        child: CachedImage(
          imageUrl: imgUrl,
          connectivity: db.connectivity,
          errorWidget: (context, url, error) => Container(),
        ),
      ));
    });
    return sliders;
  }

  Widget buildTestInfoPad() {
    return Card(
        elevation: 2,
        margin: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: divideTiles(<Widget>[
            ListTile(
              title: Center(
                child: Text('Test Info Pad', style: TextStyle(fontSize: 18)),
              ),
            ),
            ListTile(
              title: Text('Screen size'),
              trailing: Text(MediaQuery.of(context).size.toString()),
            ),
            ListTile(
              title: Text('Dataset version'),
              trailing: Text(db.gameData.version),
            ),
          ]),
        ));
  }

  Future<Null> resolveSliderImageUrls() async {
    Map<String, String> _getImageLinks(dom.Element? element, Uri uri) {
      Map<String, String> _result = {};
      if (element == null) return _result;
      for (var linkNode in element.getElementsByTagName('a')) {
        String? link = linkNode.attributes['href'];
        var imgNodes = linkNode.getElementsByTagName('img');
        if (imgNodes.isNotEmpty) {
          String? imgUrl = imgNodes.first.attributes['src'];
          if (link != null && imgUrl != null) {
            imgUrl = uri.resolve(imgUrl).toString();
            link = uri.resolve(link).toString();
            _result[imgUrl] = link;
            print('imgUrl= "$imgUrl"\nhref  = "$link"');
          }
        }
      }
      return _result;
    }

    Map<String, String> result = {};
    try {
      final _dio = Dio();
      // mc slides
      final mcUrl =
          'https://fgo.wiki/w/%E6%A8%A1%E6%9D%BF:%E8%87%AA%E5%8A%A8%E5%8F%96%E5%80%BC%E8%BD%AE%E6%92%AD';
      var mcParser = parser.parse((await _dio.get(mcUrl)).data.toString());
      var mcElement = mcParser.getElementById('transImageBox');
      result.addAll(_getImageLinks(mcElement, Uri.parse(mcUrl)));

      // jp slides
      final jpUrl = 'http://view.fate-go.jp';
      var jpParser = parser.parse((await _dio.get(jpUrl)).data.toString());
      var jpElement = jpParser.getElementsByClassName('slide').getOrNull(0);
      result.addAll(_getImageLinks(jpElement, Uri.parse(jpUrl)));
    } catch (e, s) {
      logger.e('Error refresh slides', e, s);
    } finally {
      if (result.isNotEmpty) {
        db.userData.sliderUrls = result;
        db.userData.sliderUpdateTime = DateTime.now().toString();
      }
      if (mounted) {
        setState(() {});
        db.saveUserData();
      }
    }
  }
}
