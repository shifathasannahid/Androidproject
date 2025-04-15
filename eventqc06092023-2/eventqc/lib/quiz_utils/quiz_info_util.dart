class QuizInfo{
  late String _userUid;
  late String _categoryName;
  late String _categoryKey;
  late String _communityKey;
  late String _communityName;
  late int _quizTaken;
  late int _correctAnswer;
  late List<String> _takenIdList;
  late List<String> _takenDateList;

  QuizInfo(
      this._userUid,
      this._categoryName,
      this._categoryKey,
      this._communityKey,
      this._communityName,
      this._quizTaken,
      this._correctAnswer,
      this._takenIdList,
      this._takenDateList,
      );

  QuizInfo.fromJson(Map<String, dynamic> json){

    _userUid = json['userUid'];
    _categoryName = json['categoryName'];
    _categoryKey = json['categoryKey'];
    _communityKey = json['communityKey'];
    _communityName = json['communityName'];
    _quizTaken = json['quizTaken'];
    _correctAnswer = json['correctAnswer'];
    _takenIdList = json['takenIdList'].cast<String>();
    _takenDateList = json['takenDateList'].cast<String>();

  }

  Map<String, dynamic> toJson(){
    return {
      "userUid": _userUid,
      "categoryName": _categoryName,
      "categoryKey": _categoryKey,
      "communityKey": _communityKey,
      "communityName": _communityName,
      "quizTaken": _quizTaken,
      "correctAnswer": _correctAnswer,
      "takenIdList": _takenIdList,
      "takenDateList": _takenDateList,
    };
  }


  List<String> get takenDateList => _takenDateList;

  set takenDateList(List<String> value) {
    _takenDateList = value;
  }

  int get correctAnswer => _correctAnswer;

  set correctAnswer(int value) {
    _correctAnswer = value;
  }

  int get quizTaken => _quizTaken;

  set quizTaken(int value) {
    _quizTaken = value;
  }

  String get communityName => _communityName;

  set communityName(String value) {
    _communityName = value;
  }

  String get communityKey => _communityKey;

  set communityKey(String value) {
    _communityKey = value;
  }

  String get categoryKey => _categoryKey;

  set categoryKey(String value) {
    _categoryKey = value;
  }

  String get categoryName => _categoryName;

  set categoryName(String value) {
    _categoryName = value;
  }

  String get userUid => _userUid;

  set userUid(String value) {
    _userUid = value;
  }

  List<String> get takenIdList => _takenIdList;

  set takenIdList(List<String> value) {
    _takenIdList = value;
  }
}