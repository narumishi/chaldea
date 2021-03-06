import 'package:chaldea/components/components.dart';

import 'tabs/exchange_ticket_tab.dart';
import 'tabs/limit_event_tab.dart';
import 'tabs/main_record_tab.dart';

class EventListPage extends StatefulWidget {
  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool reversed = true;
  bool showOutdated = false;

  List<String> get tabNames => [
        S.current.limited_event,
        S.current.main_record,
        S.current.exchange_ticket
      ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabNames.length, vsync: this);
    db.itemStat.update();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).event_title),
        centerTitle: true,
        titleSpacing: 0,
        leading: MasterBackButton(),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              setState(() {
                showOutdated = !showOutdated;
              });
            },
            tooltip: 'Outdated',
            icon: Icon(showOutdated ? Icons.timer_off : Icons.timer),
          ),
          IconButton(
            icon: Icon(
                reversed ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
            tooltip: 'Reversed',
            onPressed: () => setState(() => reversed = !reversed),
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: tabNames.map((name) => Tab(text: name)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        // desktop: direction of drag may be confused
        physics: AppInfo.isMobile ? null : NeverScrollableScrollPhysics(),
        children: <Widget>[
          KeepAliveBuilder(
              builder: (_) =>
                  LimitEventTab(reverse: reversed, showOutdated: showOutdated)),
          KeepAliveBuilder(
              builder: (_) => MainRecordTab(
                  reversed: reversed, showOutdated: showOutdated)),
          KeepAliveBuilder(
              builder: (_) => ExchangeTicketTab(
                  reverse: reversed, showOutdated: showOutdated)),
        ],
      ),
    );
  }

  @override
  void deactivate() {
    super.deactivate();
    db.saveUserData();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }
}
