class Answer{
  late String _key;
  late String _userUid;
  late String _answer;
  late int _helpPoint;
  late int _answerNumber;

  Answer(this._key, this._userUid, this._answer, this._helpPoint, this._answerNumber);

  Answer.fromJson(Map<String, dynamic> json){
    _key = json["key"];
    _userUid = json["userUid"];
    _answer = json["answer"];
    _helpPoint = json["helpPoint"];
    _answerNumber = json['answerNumber'];
  }

  Map<String, dynamic> toJson(){
    return {
      "key" : _key,
      "userUid" : _userUid,
      "answer" : _answer,
      "helpPoint" : _helpPoint,
      "answerNumber" : _answerNumber,
    };
  }

  int get helpPoint => _helpPoint;

  set helpPoint(int value) {
    _helpPoint = value;
  }

  String get answer => _answer;

  set answer(String value) {
    _answer = value;
  }

  String get userUid => _userUid;

  set userUid(String value) {
    _userUid = value;
  }

  String get key => _key;

  set key(String value) {
    _key = value;
  }

  int get answerNumber => _answerNumber;

  set answerNumber(int value) {
    _answerNumber = value;
  }
}