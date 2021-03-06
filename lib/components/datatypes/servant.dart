part of datatypes;

enum SvtCompare { no, className, rarity, atk, hp, priority }

@JsonSerializable(checked: true)
class Servant {
  // left avatar & model
  int no;
  @JsonKey(ignore: true)
  int originNo;

  /// the real identity [svtId] in game database
  /// default -1 for [Servant.unavailable]
  int svtId;
  String mcLink;
  String icon;
  ServantBaseInfo info;
  List<NobelPhantasm> nobelPhantasm;
  List<ActiveSkill> activeSkills;
  List<Skill> passiveSkills;
  ItemCost itemCost;
  List<int> bondPoints;
  List<SvtProfileData> profiles;
  List<VoiceTable> voices;
  int bondCraft;
  List<int> valentineCraft;

  // from data file not in code
  static const List<int> unavailable = [83, 149, 151, 152, 168, 240];

  String toString() => mcLink;

  Servant({
    required this.no,
    required this.svtId,
    required this.mcLink,
    required this.icon,
    required this.info,
    required this.nobelPhantasm,
    required this.activeSkills,
    required this.passiveSkills,
    required this.itemCost,
    required this.bondPoints,
    required this.profiles,
    required this.voices,
    required this.bondCraft,
    required this.valentineCraft,
  }) : originNo = no;

  Servant duplicate(int newNo) {
    return Servant.fromJson(deepCopy(this))
      ..no = newNo
      ..originNo = originNo;
  }

  /// [cur]=[target]=null: all
  /// [cur.favorite]=[target.favorite]=true
  /// else empty
  Map<String, int> getAllCost(
      {ServantPlan? cur, ServantPlan? target, bool all = false}) {
    if (all) {
      return sumDict(
          [getAscensionCost(), getSkillCost(), getDressCost(), getGrailCost()]);
    }
    target ??= ServantPlan();
    if (cur?.favorite == true) {
      return sumDict([
        getAscensionCost(cur: cur!.ascension, target: target.ascension),
        getSkillCost(cur: cur.skills, target: target.skills),
        getDressCost(cur: cur.dress, target: target.dress),
        getGrailCost(cur: cur.grail, target: target.grail)
      ]);
    } else {
      return {};
    }
  }

  SvtParts<Map<String, int>> getAllCostParts(
      {ServantPlan? cur, ServantPlan? target, bool all = false}) {
    // no grail?
    if (all) {
      return SvtParts(
        ascension: getAscensionCost(),
        skill: getSkillCost(),
        dress: getDressCost(),
        grailAscension: getGrailCost(),
      );
    }
    target ??= ServantPlan();
    if (cur?.favorite == true) {
      return SvtParts(
        ascension:
            getAscensionCost(cur: cur!.ascension, target: target.ascension),
        skill: getSkillCost(cur: cur.skills, target: target.skills),
        dress: getDressCost(cur: cur.dress, target: target.dress),
        grailAscension: getGrailCost(cur: cur.grail, target: target.grail),
      );
    } else {
      return SvtParts(k: () => <String, int>{});
    }
  }

  Map<String, int> getAscensionCost({int cur = 0, int target = 4}) {
    cur = fixValidRange(cur, 0, 4);
    target = fixValidRange(target, 0, 4);
    if (itemCost.ascension.isEmpty) return {};
    return sumDict(itemCost.ascension.sublist(cur, max(cur, target)));
  }

  Map<String, int> getSkillCost({List<int>? cur, List<int>? target}) {
    if (itemCost.skill.isEmpty || itemCost.skill.first.isEmpty) return {};
    cur ??= [1, 1, 1];
    target ??= [10, 10, 10];
    Map<String, int> items = {};

    for (int i = 0; i < 3; i++) {
      cur[i] = fixValidRange(cur[i], 1, 10);
      target[i] = fixValidRange(target[i], 1, 10);
      // lv 1-10 -> 0-9
      for (int j = cur[i] - 1; j < target[i] - 1; j++) {
        sumDict([items, itemCost.skill[j]], inPlace: true);
      }
    }
    return items;
  }

  Map<String, int> getDressCost({List<int>? cur, List<int>? target}) {
    Map<String, int> items = {};
    final dressNum = itemCost.dress.length;
    if (cur == null) cur = List.filled(dressNum, 0, growable: true);
    if (target == null) target = List.filled(dressNum, 1, growable: true);
    if (cur.length < dressNum)
      cur.addAll(List.filled(dressNum - cur.length, 0, growable: true));
    if (target.length < dressNum)
      target.addAll(List.filled(dressNum - target.length, 0, growable: true));

    for (int i = 0; i < dressNum; i++) {
      cur[i] = fixValidRange(cur[i], 0, 1);
      target[i] = fixValidRange(target[i], 0, 1);
      for (int j = cur[i]; j < target[i]; j++) {
        sumDict([items, itemCost.dress[i]], inPlace: true);
      }
    }
    return items;
  }

  Map<String, int> getGrailCost({int cur = 0, int? target}) {
    final maxVal = [10, 10, 10, 9, 7, 5][this.info.rarity2];
    cur = fixValidRange(cur, 0, maxVal);
    target = fixValidRange(target ?? maxVal, 0, maxVal);
    target = max(cur, target);

    return target > cur ? {Item.grail: target - cur} : <String, int>{};
  }

  int getGrailLv(int grail) {
    final maxGrail = [10, 10, 10, 9, 7, 5][info.rarity];
    if (grail == 0) return [65, 60, 65, 70, 80, 90][info.rarity];
    return [100, 98, 96, 94, 92, 90, 85, 80, 75, 70][maxGrail - grail];
  }

  int getClassSortIndex() {
    if (info.className == 'Grand Caster') {
      return SvtFilterData.classesData.indexWhere((v) => v == 'Caster');
    } else if (info.className.startsWith('Beast')) {
      return SvtFilterData.classesData.indexWhere((v) => v == 'Beast');
    } else {
      return SvtFilterData.classesData
          .indexWhere((v) => v.startsWith(info.className.substring(0, 5)));
    }
  }

  static int compare(Servant a, Servant b,
      {List<SvtCompare>? keys, List<bool>? reversed, User? user}) {
    int res = 0;
    if (keys == null || keys.isEmpty) {
      keys = [SvtCompare.no];
    }
    for (var i = 0; i < keys.length; i++) {
      int r;
      switch (keys[i]) {
        case SvtCompare.no:
          r = a.originNo - b.originNo;
          if (r == 0) r = a.no - b.no;
          break;
        case SvtCompare.className:
          r = a.getClassSortIndex() - b.getClassSortIndex();
          break;
        case SvtCompare.rarity:
          r = a.info.rarity - b.info.rarity;
          break;
        case SvtCompare.atk:
          r = (a.info.atkMax) - (b.info.atkMax);
          break;
        case SvtCompare.hp:
          r = (a.info.hpMax) - (b.info.hpMax);
          break;
        case SvtCompare.priority:
          final aa = user?.svtStatusOf(a.no), bb = user?.svtStatusOf(b.no);
          r = (aa?.priority ?? 1) - (bb?.priority ?? 1);
          break;
      }
      res = res * 1000000 + ((reversed?.elementAt(i) ?? false) ? -r : r);
    }
    return res;
  }

  factory Servant.fromJson(Map<String, dynamic> data) =>
      _$ServantFromJson(data);

  Map<String, dynamic> toJson() => _$ServantToJson(this);
}

@JsonSerializable(checked: true)
class ServantBaseInfo {
  String name;
  String nameJp;
  String? nameEn;
  List<String> namesOther;
  List<String> namesJpOther;
  List<String> namesEnOther;
  List<String> nicknames;

  /// {'活动', '初始获得', '剧情', '常驻', '限定', '无法召唤', '友情点召唤'}
  String obtain;
  List<String> obtains;

  /// rarity 0-5, (小安-0, 玛修-4)
  int rarity;

  /// actual rarity for COST etc. 1~5, (小安-2, 玛修-3)
  int rarity2;
  String weight;
  String height;
  String gender;
  String illustrator;
  String className;
  String attribute;
  bool isHumanoid;
  bool isWeakToEA;
  bool isTDNS;
  List<String> cv;
  List<String> alignments;
  List<String> traits;
  Map<String, String> ability;
  Map<String, String> illustrations;
  List<String> cards;
  Map<String, int> cardHits;
  Map<String, List<int>> cardHitsDamage;
  Map<String, String> npRate;
  int atkMin;
  int hpMin;
  int atkMax;
  int hpMax;
  int atk90;
  int hp90;
  int atk100;
  int hp100;
  String starRate;
  String deathRate;
  String criticalRate;

  ServantBaseInfo({
    required this.name,
    required this.nameJp,
    required this.nameEn,
    required this.namesOther,
    required this.namesJpOther,
    required this.namesEnOther,
    required this.nicknames,
    required this.obtain,
    required this.obtains,
    required this.rarity,
    required this.rarity2,
    required this.weight,
    required this.height,
    required this.gender,
    required this.illustrator,
    required this.className,
    required this.attribute,
    required this.isHumanoid,
    required this.isWeakToEA,
    required this.isTDNS,
    required this.cv,
    required this.alignments,
    required this.traits,
    required this.ability,
    required this.illustrations,
    required this.cards,
    required this.cardHits,
    required this.cardHitsDamage,
    required this.npRate,
    required this.atkMin,
    required this.hpMin,
    required this.atkMax,
    required this.hpMax,
    required this.atk90,
    required this.hp90,
    required this.atk100,
    required this.hp100,
    required this.starRate,
    required this.deathRate,
    required this.criticalRate,
  });

  String get localizedName => localizeNoun(name, nameJp, nameEn);

  factory ServantBaseInfo.fromJson(Map<String, dynamic> data) =>
      _$ServantBaseInfoFromJson(data);

  Map<String, dynamic> toJson() => _$ServantBaseInfoToJson(this);
}

@JsonSerializable(checked: true)
class NobelPhantasm {
  String state;
  String name;
  String nameJp;
  String upperName;
  String upperNameJp;
  String color;
  String category;
  String? rank;
  String typeText;
  List<Effect> effects;

  NobelPhantasm({
    required this.state,
    required this.name,
    required this.nameJp,
    required this.upperName,
    required this.upperNameJp,
    required this.color,
    required this.category,
    this.rank,
    required this.typeText,
    required this.effects,
  });

  factory NobelPhantasm.fromJson(Map<String, dynamic> data) =>
      _$NobelPhantasmFromJson(data);

  Map<String, dynamic> toJson() => _$NobelPhantasmToJson(this);
}

@JsonSerializable(checked: true)
class ActiveSkill {
  int cnState;
  List<Skill> skills;

  ActiveSkill({required this.cnState, required this.skills});

  factory ActiveSkill.fromJson(Map<String, dynamic> data) =>
      _$ActiveSkillFromJson(data);

  Map<String, dynamic> toJson() => _$ActiveSkillToJson(this);
}

@JsonSerializable(checked: true)
class Skill {
  String state;
  String name;
  String? nameJp;
  String? rank;
  String icon;
  int cd;
  List<Effect> effects;

  Skill({
    required this.state,
    required this.name,
    required this.nameJp,
    required this.rank,
    required this.icon,
    required this.cd,
    required this.effects,
  });

  String get localizedName => localizeNoun(name, nameJp, null);

  factory Skill.fromJson(Map<String, dynamic> data) => _$SkillFromJson(data);

  Map<String, dynamic> toJson() => _$SkillToJson(this);
}

@JsonSerializable(checked: true)
class Effect {
  String description;
  List<String> lvData;

  Effect({required this.description, required this.lvData});

  factory Effect.fromJson(Map<String, dynamic> data) => _$EffectFromJson(data);

  Map<String, dynamic> toJson() => _$EffectToJson(this);
}

@JsonSerializable(checked: true)
class SvtProfileData {
  String title;
  String description;
  String descriptionJp;
  String? condition;

  SvtProfileData({
    required this.title,
    required this.description,
    required this.descriptionJp,
    this.condition,
  });

  factory SvtProfileData.fromJson(Map<String, dynamic> data) =>
      _$SvtProfileDataFromJson(data);

  Map<String, dynamic> toJson() => _$SvtProfileDataToJson(this);
}

@JsonSerializable(checked: true)
class VoiceTable {
  String section;
  List<VoiceRecord> table;

  VoiceTable({required this.section, required this.table});

  factory VoiceTable.fromJson(Map<String, dynamic> data) =>
      _$VoiceTableFromJson(data);

  Map<String, dynamic> toJson() => _$VoiceTableToJson(this);
}

@JsonSerializable(checked: true)
class VoiceRecord {
  String title;
  String? text;
  String? textJp;
  String? condition;
  String voiceFile;

  VoiceRecord({
    required this.title,
    required this.text,
    required this.textJp,
    this.condition,
    required this.voiceFile,
  });

  factory VoiceRecord.fromJson(Map<String, dynamic> data) =>
      _$VoiceRecordFromJson(data);

  Map<String, dynamic> toJson() => _$VoiceRecordToJson(this);
}
