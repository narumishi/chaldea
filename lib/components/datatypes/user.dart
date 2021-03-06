// userdata: plan etc.
part of datatypes;

@JsonSerializable(checked: true)
class User {
  String name;

  Map<int, ServantStatus> servants;
  int curSvtPlanNo;

  /// Map<planNo, Map<SvtNo, SvtPlan>>
  List<Map<int, ServantPlan>> servantPlans;

  /// user own items, key: item name, value: item count
  Map<String, int> items;
  EventPlans events;
  Map<String, int> mysticCodes;
  Set<String> plannedSummons;
  bool isMasterGirl;

  /// milliseconds of event's startTimeJP
  int msProgress;

  // <svt_no_for_user, origin_svt_user>
  Map<int, int> duplicatedServants;

  User({
    String? name,
    Map<int, ServantStatus>? servants,
    int? curSvtPlanNo,
    List<Map<int, ServantPlan>>? servantPlans,
    Map<String, int>? items,
    EventPlans? events,
    Map<String, int>? mysticCodes,
    Set<String>? plannedSummons,
    bool? isMasterGirl,
    int? msProgress,
    Map<int, int>? duplicatedServants,
  })  : name = name?.isNotEmpty == true ? name! : 'default',
        servants = servants ?? {},
        curSvtPlanNo = curSvtPlanNo ?? 0,
        servantPlans = servantPlans ?? [],
        items = items ?? {},
        events = events ?? EventPlans(),
        mysticCodes = mysticCodes ?? {},
        plannedSummons = plannedSummons ?? <String>{},
        isMasterGirl = isMasterGirl ?? true,
        msProgress = msProgress ?? -1,
        duplicatedServants = duplicatedServants ?? {} {
    this.curSvtPlanNo =
        fixValidRange(this.curSvtPlanNo, 0, this.servantPlans.length);
    fillListValue(this.servantPlans, max(5, this.servantPlans.length),
        (_) => <int, ServantPlan>{});
  }

  Map<int, ServantPlan> get curSvtPlan {
    curSvtPlanNo = fixValidRange(curSvtPlanNo, 0, servantPlans.length - 1);
    return servantPlans[curSvtPlanNo];
  }

  Servant addDuplicatedForServant(Servant svt,[int? newNo]) {
    for (int no = svt.originNo * 1000 + 1;
        no < svt.originNo * 1000 + 999;
        no++) {
      if (!db.gameData.servantsWithUser.containsKey(no)) {
        duplicatedServants[no] = svt.originNo;
        final newSvt = svt.duplicate(no);
        db.gameData.servantsWithUser[no] = newSvt;
        return newSvt;
        // return
      }
    }
    return svt;
  }

  void removeDuplicatedServant(int svtNo) {
    duplicatedServants.remove(svtNo);
    servants.remove(svtNo);
    servantPlans.forEach((plans) {
      plans.remove(svtNo);
    });
    db.gameData.updateUserDuplicatedServants();
  }

  void ensurePlanLarger() {
    curSvtPlan.forEach((key, plan) {
      if (plan.favorite) {
        plan.validate(servants[key]?.curVal);
      }
    });
  }

  ServantPlan svtPlanOf(int no) =>
      curSvtPlan.putIfAbsent(no, () => ServantPlan())..validate();

  ServantStatus svtStatusOf(int no) =>
      servants.putIfAbsent(no, () => ServantStatus())..curVal.validate();

  factory User.fromJson(Map<String, dynamic> data) => _$UserFromJson(data);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable(checked: true)
class ServantStatus {
  ServantPlan curVal;
  int npLv;

  /// null-not set, >=0 index, sorted from non-enhanced to enhanced
  List<int?> skillIndex; //length=3
  /// default 0, origin order in wiki
  int npIndex;

  /// priority 1-5
  int priority;

  ServantStatus({
    ServantPlan? curVal,
    int? npLv,
    List<int?>? skillIndex,
    int? npIndex,
    int? priority,
  })  : curVal = curVal ?? ServantPlan(),
        npLv = npLv ?? 1,
        skillIndex = List.generate(3, (index) => skillIndex?.getOrNull(index)),
        npIndex = npIndex ?? 0,
        priority = priority ?? 1 {
    validate();
  }

  void validate() {
    curVal.validate();
    npLv = fixValidRange(npLv, 1, 5);
    npIndex = fixValidRange(npIndex, 0);
    for (int i = 0; i < 3; i++) {
      if (skillIndex[i] != null) {
        skillIndex[i] = fixValidRange(skillIndex[i]!, 0);
      }
    }
    priority = fixValidRange(priority, 1, 5);
  }

  void reset() {
    curVal.reset();
    npLv = 1;
    priority = 1;
    resetEnhancement();
  }

  void resetEnhancement() {
    skillIndex.fillRange(0, 3, null);
    npIndex = 0;
  }

  factory ServantStatus.fromJson(Map<String, dynamic> data) =>
      _$ServantStatusFromJson(data);

  Map<String, dynamic> toJson() => _$ServantStatusToJson(this);
}

@JsonSerializable(checked: true)
class ServantPlan {
  bool favorite;
  int ascension;
  List<int> skills; // length 3
  List<int> dress;
  int grail;

  ServantPlan({
    bool? favorite,
    int? ascension,
    List<int>? skills,
    List<int>? dress,
    int? grail,
  })  : favorite = favorite ?? false,
        ascension = ascension ?? 0,
        skills = List.generate(3, (index) => skills?.getOrNull(index) ?? 0),
        dress = List.generate(
            dress?.length ?? 0, (index) => dress?.getOrNull(index) ?? 0),
        grail = grail ?? 0 {
    validate();
  }

  void reset() {
    favorite = false;
    ascension = 0;
    skills.fillRange(0, 3, 1);
    dress.fillRange(0, dress.length, 0);
    grail = 0;
  }

  void setMax({int skill = 10}) {
    // not change grail lv
    favorite = true;
    ascension = 4;
    skills.fillRange(0, 3, skill);
    dress.fillRange(0, dress.length, 1);
    // grail = grail;
  }

  void fixDressLength(int length, [int fill = 0]) {
    fillListValue(dress, length, (_) => fill);
  }

  void validate([ServantPlan? lowerPlan]) {
    ascension = fixValidRange(ascension, lowerPlan?.ascension ?? 0, 4);
    for (int i = 0; i < skills.length; i++) {
      skills[i] = fixValidRange(skills[i], lowerPlan?.skills[i] ?? 1, 10);
    }
    for (int i = 0; i < dress.length; i++) {
      dress[i] = fixValidRange(dress[i], lowerPlan?.dress.getOrNull(i) ?? 0, 1);
    }
    // check grail max limit when used
    grail = fixValidRange(grail, lowerPlan?.grail ?? 0);
  }

  factory ServantPlan.fromJson(Map<String, dynamic> data) =>
      _$ServantPlanFromJson(data)..validate();

  Map<String, dynamic> toJson() => _$ServantPlanToJson(this);

  ServantPlan copyWith({
    bool? favorite,
    int? ascension,
    List<int>? skills,
    List<int>? dress,
    int? grail,
  }) {
    return ServantPlan(
      favorite: favorite ?? this.favorite,
      ascension: ascension ?? this.ascension,
      skills: skills ?? this.skills,
      dress: dress ?? this.dress,
      grail: grail ?? this.grail,
    );
  }

  void copyFrom(ServantPlan other) {
    favorite = other.favorite;
    ascension = other.ascension;
    skills = List.from(other.skills);
    dress = List.from(other.dress);
    grail = other.grail;
  }

  static ServantPlan from(ServantPlan other) => ServantPlan()..copyFrom(other);
}

@JsonSerializable(checked: true)
class EventPlans {
  Map<String, LimitEventPlan> limitEvents;

  /// {'chapter 1': [drops_switch,rewards_switch]}
  Map<String, List<bool>> mainRecords;

  ///{'monthCn': [num1, num2, num3]}
  Map<String, List<int>> exchangeTickets;

  EventPlans({
    Map<String, LimitEventPlan>? limitEvents,
    Map<String, List<bool>>? mainRecords,
    Map<String, List<int>>? exchangeTickets,
  })  : limitEvents = limitEvents ?? {},
        mainRecords = mainRecords ?? {},
        exchangeTickets = exchangeTickets ?? {};

  LimitEventPlan limitEventOf(String indexKey) =>
      limitEvents.putIfAbsent(indexKey, () => LimitEventPlan());

  List<bool> mainRecordOf(String indexKey) =>
      mainRecords.putIfAbsent(indexKey, () => [false, false]);

  List<int> exchangeTicketOf(String indexKey) =>
      exchangeTickets.putIfAbsent(indexKey, () => [0, 0, 0]);

  factory EventPlans.fromJson(Map<String, dynamic> data) =>
      _$EventPlansFromJson(data);

  Map<String, dynamic> toJson() => _$EventPlansToJson(this);
}

@JsonSerializable(checked: true)
class LimitEventPlan {
  bool enable;
  bool rerun;
  int lottery;
  Map<String, int> extra;

  LimitEventPlan({
    bool? enable,
    bool? rerun,
    int? lottery,
    Map<String, int>? extra,
  })  : enable = enable ?? true,
        rerun = rerun ?? true,
        lottery = lottery ?? 0,
        extra = extra ?? {};

  factory LimitEventPlan.fromJson(Map<String, dynamic> data) =>
      _$LimitEventPlanFromJson(data);

  Map<String, dynamic> toJson() => _$LimitEventPlanToJson(this);
}
