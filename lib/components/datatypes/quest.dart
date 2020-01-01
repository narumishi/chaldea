part of datatypes;

@JsonSerializable()
class Quest {
  String chapter;
  String nameJp;
  String nameCn;
  int level;
  int bondPoint;
  int experience;
  int qp;
  List<Battle> battles;

  String get placeJp => battles?.first?.placeJp;

  String get placeCn => battles?.first?.placeCn;

  Quest(
      {this.chapter,
      this.nameJp,
      this.nameCn,
      this.level,
      this.bondPoint,
      this.experience,
      this.qp,
      this.battles});

  factory Quest.fromJson(Map<String, dynamic> data) => _$QuestFromJson(data);

  Map<String, dynamic> toJson() => _$QuestToJson(this);
}

@JsonSerializable()
class Battle {
  int ap;
  String placeJp;
  String placeCn;
  /// wave_num*enemy_num
  List<List<Enemy>> enemies;

  Battle({this.ap, this.placeJp, this.placeCn, this.enemies});


  factory Battle.fromJson(Map<String, dynamic> data) => _$BattleFromJson(data);

  Map<String, dynamic> toJson() => _$BattleToJson(this);
}

@JsonSerializable()
class Enemy {
  String name;
  String shownName;
  String className;
  int rank;

  Enemy({this.name, this.shownName, this.className, this.rank, this.hp});

  int hp;

  factory Enemy.fromJson(Map<String, dynamic> data) => _$EnemyFromJson(data);

  Map<String, dynamic> toJson() => _$EnemyToJson(this);
}