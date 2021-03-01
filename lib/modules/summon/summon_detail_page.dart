//@dart=2.12
import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/event/limit_event_detail_page.dart';
import 'package:chaldea/modules/event/main_record_detail_page.dart';
import 'package:chaldea/modules/servant/servant_detail_page.dart';
import 'package:getwidget/getwidget.dart';

class SummonDetailPage extends StatefulWidget {
  final Summon summon;

  const SummonDetailPage({Key? key, required this.summon}) : super(key: key);

  @override
  _SummonDetailPageState createState() => _SummonDetailPageState();
}

class _SummonDetailPageState extends State<SummonDetailPage> {
  Summon get summon => widget.summon;
  int curIndex = 0;

  @override
  void initState() {
    super.initState();
    if (showOverview) curIndex = -1;
  }

  @override
  Widget build(BuildContext context) {
    bool planned = db.curUser.plannedSummons.contains(summon.indexKey);
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: AutoSizeText(summon.localizedName, maxLines: 1),
        titleSpacing: 0,
        actions: [
          IconButton(
            icon: Icon(planned ? Icons.favorite : Icons.favorite_outline),
            onPressed: () {
              if (planned) {
                db.curUser.plannedSummons.remove(summon.indexKey);
              } else {
                db.curUser.plannedSummons.add(summon.indexKey);
              }
              db.onAppUpdate();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: listView),
          kDefaultDivider,
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: () {}, child: Text('上一个')),
              if (summon.dataList.isNotEmpty)
                ElevatedButton(onPressed: () {}, child: Text('抽卡模拟器')),
              ElevatedButton(onPressed: () {}, child: Text('下一个')),
            ],
          )
        ],
      ),
    );
  }

  Widget get listView {
    List<Widget> banners = [];
    for (String? url in [summon.bannerUrl, summon.bannerUrlJp]) {
      if (url?.isNotEmpty == true) {
        banners.add(CachedImage(
          imageUrl: summon.bannerUrl ?? summon.bannerUrlJp,
          imageBuilder: (context, image) =>
              FittedBox(child: Image(image: image)),
          isMCFile: true,
          placeholder: (_, __) => Container(),
        ));
      }
    }
    return ListView(
      children: [
        if (banners.isNotEmpty)
          GFCarousel(
            items: banners,
            autoPlay: true,
            aspectRatio: 8 / 3,
            viewportFraction: 1.0,
            enableInfiniteScroll: banners.length > 1,
          ),
        SHeader('卡池时间'),
        ListTile(
          title: Text(
              '日服: ${summon.startTimeJp ?? "?"} ~ ${summon.endTimeJp ?? "?"}\n'
              '国服: ${summon.startTimeCn ?? "?"} ~ ${summon.endTimeCn ?? "?"}'),
        ),
        if (summon.dataList.length > 1) dropdownButton,
        if (summon.dataList.isNotEmpty) gachaDetails,
        if (summon.associatedEvents.isNotEmpty) ...[
          SHeader('关联活动'),
          for (String event in summon.associatedEvents) associateEvent(event)
        ],
        if (summon.associatedSummons.isNotEmpty) ...[
          SHeader('关联卡池'),
          for (String _summon in summon.associatedSummons)
            associateSummon(_summon)
        ],
      ],
    );
  }

  Widget associateEvent(String name) {
    name = name.replaceAll('_', ' ');
    dynamic event;
    SplitLayoutBuilder? builder;
    if (db.gameData.events.limitEvents.containsKey(name)) {
      event = db.gameData.events.limitEvents[name]!;
      builder = (context, _) => LimitEventDetailPage(name: name);
    } else if (db.gameData.events.mainRecords.containsKey(name)) {
      event = db.gameData.events.mainRecords[name]!;
      builder = (context, _) => MainRecordDetailPage(name: name);
    }

    return ListTile(
      leading: Icon(Icons.event),
      title: Text(event?.localizedName ?? name),
      onTap: builder == null
          ? null
          : () => SplitRoute.push(context: context, builder: builder!),
    );
  }

  Widget associateSummon(String name) {
    name = name.replaceAll('_', ' ');
    Summon? _summon = db.gameData.summons[name];
    return ListTile(
      leading: Icon(Icons.anchor),
      title: Text(_summon?.localizedName ?? name),
      onTap: _summon == null
          ? null
          : () => SplitRoute.push(
                context: context,
                builder: (context, _) => SummonDetailPage(summon: _summon),
              ),
    );
  }

  bool get showOverview {
    return summon.dataList.length > 1 &&
        !summon.classPickUp &&
        summon.luckyBag == 0;
  }

  Widget get dropdownButton {
    List<DropdownMenuItem<int>> items = [];
    if (showOverview) {
      items.add(DropdownMenuItem(
        child: Text('概览'),
        value: -1,
      ));
    }
    items.addAll(summon.dataList.map((e) => DropdownMenuItem(
          child: Text(e.name ?? '-', maxLines: 1),
          value: summon.dataList.indexOf(e),
        )));
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text('日替 '),
          Flexible(
            child: DropdownButton<int>(
              value: curIndex,
              items: items,
              onChanged: (v) {
                setState(() {
                  curIndex = v ?? curIndex;
                });
              },
              isExpanded: true,
            ),
          )
        ],
      ),
    );
  }

  Widget get gachaDetails {
    if (curIndex < 0) {
      return gachaOverview;
    }
    final data = summon.dataList[curIndex]!;

    List<Widget> children = [];
    data.svts.forEach((block) {
      if (!block.display && summon.luckyBag == 0 && !summon.classPickUp) return;
      final row = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${block.rarity}星  '),
          Flexible(
            child: Wrap(
              spacing: 3,
              runSpacing: 3,
              children: block.ids.map((id) {
                final svt = db.gameData.servants[id];
                if (svt == null) return Text('No.$id');
                return _svtAvatar(svt, block.ids.length == 1);
              }).toList(),
            ),
          )
        ],
      );
      children.add(Padding(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: row,
      ));
    });
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: divideTiles(children),
    );
  }

  Widget get gachaOverview {
    Map<int, Set<int>> svts = {5: {}, 4: {}, 3: {}};
    for (var data in summon.dataList) {
      for (var blockData in data.svts) {
        if (!blockData.display) continue;
        svts[blockData.rarity]?.addAll(blockData.ids);
      }
    }
    List<Widget> children = [];
    for (int rarity in [5, 4, 3]) {
      if (svts[rarity]!.isEmpty) continue;
      final row = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$rarity星  '),
          Flexible(
            child: Wrap(
              spacing: 3,
              runSpacing: 3,
              children: svts[rarity]!.map((id) {
                final svt = db.gameData.servants[id];
                if (svt == null) return Text('No.$id');
                return _svtAvatar(svt, summon.hasSinglePickupSvt(id));
              }).toList(),
            ),
          )
        ],
      );
      children.add(Padding(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: row,
      ));
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: divideTiles(children),
    );
  }

  Widget _svtAvatar(Servant svt, [bool star = false]) {
    return InkWell(
      onTap: () {
        SplitRoute.push(
          context: context,
          builder: (context, _) => ServantDetailPage(svt),
        );
      },
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 6, right: 6),
            child: ImageWithText(
              image: db.getIconImage(svt.icon, height: 64),
              text: svt.info.obtain.replaceAll('常驻', ''),
            ),
          ),
          if (star) ...[
            Icon(Icons.star, color: Colors.yellow, size: 18),
            Icon(Icons.star_outline, color: Colors.redAccent, size: 18),
          ]
        ],
      ),
    );
  }
}