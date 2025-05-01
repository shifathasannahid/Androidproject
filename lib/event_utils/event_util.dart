class Event{
  late String _key;
  late String _communityKey;
  late String _communityName;
  late String _categoryKey;
  late String _categoryName;
  late String _title;
  late String _coverImageUrl;
  late String _eventType;
  late String _eventFormat;
  late String _publishDate;
  late String _startDate;
  late String _startTime;
  late String _endTime;
  late String _description;
  late String _maximumRegistration;
  late String _location;
  late String _publisherUid;
  late String _publisherName;
  late String _publisherContactNumber;
  late String _publicContactNumber;
  late String _registrationFee;
  late String _totalRegistration;
  late String _liveEventLink;
  late String _recordedEventLink;

  Event(
      this._key,
      this._communityKey,
      this._communityName,
      this._title,
      this._coverImageUrl,
      this._eventType,
      this._eventFormat,
      this._publishDate,
      this._startDate,
      this._startTime,
      this._endTime,
      this._description,
      this._maximumRegistration,
      this._location,
      this._publisherUid,
      this._publisherName,
      this._publisherContactNumber,
      this._publicContactNumber,
      this._registrationFee,
      this._totalRegistration,
      this._liveEventLink,
      this._recordedEventLink,
      this._categoryKey,
      this._categoryName,);

  Event.fromJson(Map<String, dynamic> json){
    _key = json['key'];
    _communityKey = json['communityKey'];
    _communityName = json['communityName'];
    _title = json['title'];
    _coverImageUrl = json['coverImageUrl'];
    _eventType = json['eventType'];
    _eventFormat = json['eventFormat'];
    _publishDate = json['publishDate'];
    _startDate = json['startDate'];
    _startTime = json['startTime'];
    _endTime = json['endTime'];
    _description = json['description'];
    _maximumRegistration = json['maximumRegistration'];
    _location = json['location'];
    _publisherUid = json['publisherUid'];
    _publisherName = json['publisherName'];
    _publisherContactNumber = json['publisherContactNumber'];
    _publicContactNumber = json['publicContactNumber'];
    _registrationFee = json['registrationFee'];
    _totalRegistration = json['totalRegistration'];
    _liveEventLink = json['liveEventLink'];
    _recordedEventLink = json['recordedEventLink'];
    _categoryKey = json['categoryKey'];
    _categoryName = json['categoryName'];
  }

  Map<String, dynamic> toJson(){
    return {
      "key" : _key,
      "communityKey" : _communityKey,
      "communityName" : _communityName,
      "title" : _title,
      "coverImageUrl" : _coverImageUrl,
      "eventType" : _eventType,
      "eventFormat" : _eventFormat,
      "publishDate" : _publishDate,
      "startDate" : _startDate,
      "startTime" : _startTime,
      "endTime" : _endTime,
      "description" : _description,
      "maximumRegistration" : _maximumRegistration,
      "location" : _location,
      "publisherUid" : _publisherUid,
      "publisherName" : _publisherName,
      "publisherContactNumber" : _publisherContactNumber,
      "publicContactNumber" : _publicContactNumber,
      "registrationFee" : _registrationFee,
      "totalRegistration" : _totalRegistration,
      "liveEventLink" : _liveEventLink,
      "recordedEventLink" : _recordedEventLink,
      "categoryKey" : _categoryKey,
      "categoryName" : _categoryName,
    };
  }


  String get categoryKey => _categoryKey;

  set categoryKey(String value) {
    _categoryKey = value;
  }

  String get recordedEventLink => _recordedEventLink;

  set recordedEventLink(String value) {
    _recordedEventLink = value;
  }

  String get liveEventLink => _liveEventLink;

  set liveEventLink(String value) {
    _liveEventLink = value;
  }

  String get totalRegistration => _totalRegistration;

  set totalRegistration(String value) {
    _totalRegistration = value;
  }

  String get registrationFee => _registrationFee;

  set registrationFee(String value) {
    _registrationFee = value;
  }

  String get publicContactNumber => _publicContactNumber;

  set publicContactNumber(String value) {
    _publicContactNumber = value;
  }

  String get publisherContactNumber => _publisherContactNumber;

  set publisherContactNumber(String value) {
    _publisherContactNumber = value;
  }

  String get publisherName => _publisherName;

  set publisherName(String value) {
    _publisherName = value;
  }

  String get publisherUid => _publisherUid;

  set publisherUid(String value) {
    _publisherUid = value;
  }

  String get location => _location;

  set location(String value) {
    _location = value;
  }

  String get maximumRegistration => _maximumRegistration;

  set maximumRegistration(String value) {
    _maximumRegistration = value;
  }

  String get description => _description;

  set description(String value) {
    _description = value;
  }

  String get endTime => _endTime;

  set endTime(String value) {
    _endTime = value;
  }

  String get startTime => _startTime;

  set startTime(String value) {
    _startTime = value;
  }

  String get startDate => _startDate;

  set startDate(String value) {
    _startDate = value;
  }

  String get publishDate => _publishDate;

  set publishDate(String value) {
    _publishDate = value;
  }

  String get eventFormat => _eventFormat;

  set eventFormat(String value) {
    _eventFormat = value;
  }

  String get eventType => _eventType;

  set eventType(String value) {
    _eventType = value;
  }

  String get coverImageUrl => _coverImageUrl;

  set coverImageUrl(String value) {
    _coverImageUrl = value;
  }

  String get title => _title;

  set title(String value) {
    _title = value;
  }

  String get communityName => _communityName;

  set communityName(String value) {
    _communityName = value;
  }

  String get communityKey => _communityKey;

  set communityKey(String value) {
    _communityKey = value;
  }

  String get key => _key;

  set key(String value) {
    _key = value;
  }

  String get categoryName => _categoryName;

  set categoryName(String value) {
    _categoryName = value;
  }
}