class Discussion{
  late String _key;
  late String _publisherUid;
  late String _publishDate;
  late String _publishTime;
  late String _problemTitle;
  late String _description;
  late String _isSolved;
  late String _isPined;
  late String _categoryKey;
  late String _communityKey;
  late String _timeStamp;

  Discussion(
      this._key,
      this._publisherUid,
      this._publishDate,
      this._publishTime,
      this._problemTitle,
      this._description,
      this._isSolved,
      this._isPined,
      this._categoryKey,
      this._communityKey,
      this._timeStamp);

  Discussion.fromJson(Map<String, dynamic> json){
    _key = json['key'];
    _publisherUid = json['publisherUid'];
    _publishDate = json['publishDate'];
    _publishTime = json['publishTime'];
    _problemTitle = json['problemTitle'];
    _description = json['description'];
    _isSolved = json['isSolved'];
    _isPined = json['isPined'];
    _categoryKey = json['categoryKey'];
    _communityKey = json['communityKey'];
    _timeStamp = json['timeStamp'];
  }

  Map<String, dynamic> toJson(){
    return{
      "key" : _key,
      "publisherUid" : _publisherUid,
      "publishDate" : _publishDate,
      "publishTime" : _publishTime,
      "problemTitle" : _problemTitle,
      "description" : _description,
      "isSolved" : _isSolved,
      "isPined" : _isPined,
      "categoryKey" : _categoryKey,
      "communityKey" : _communityKey,
      "timeStamp" : _timeStamp,
    };
  }


  String get timeStamp => _timeStamp;

  set timeStamp(String value) {
    _timeStamp = value;
  }

  String get communityKey => _communityKey;

  set communityKey(String value) {
    _communityKey = value;
  }

  String get categoryKey => _categoryKey;

  set categoryKey(String value) {
    _categoryKey = value;
  }

  String get isPined => _isPined;

  set isPined(String value) {
    _isPined = value;
  }

  String get isSolved => _isSolved;

  set isSolved(String value) {
    _isSolved = value;
  }

  String get description => _description;

  set description(String value) {
    _description = value;
  }

  String get problemTitle => _problemTitle;

  set problemTitle(String value) {
    _problemTitle = value;
  }

  String get publishTime => _publishTime;

  set publishTime(String value) {
    _publishTime = value;
  }

  String get publishDate => _publishDate;

  set publishDate(String value) {
    _publishDate = value;
  }

  String get publisherUid => _publisherUid;

  set publisherUid(String value) {
    _publisherUid = value;
  }

  String get key => _key;

  set key(String value) {
    _key = value;
  }
}