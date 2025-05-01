class UserBasicInfo{
  late String _userUid;
  late String _firstName;
  late String _lastName;
  late String _email;
  late String _phone;
  late String _dateOfBirth;
  late String _gender;
  late String _userType;
  late String _profileImageUrl;

  UserBasicInfo(this._userUid, this._firstName, this._lastName, this._email, this._phone, this._dateOfBirth,
      this._gender, this._userType, this._profileImageUrl);

  UserBasicInfo.fromJson(Map<String, dynamic> json){
    _userUid = json['userUid'];
    _firstName = json['firstName'];
    _lastName = json['lastName'];
    _email = json['email'];
    _phone = json['phone'];
    _dateOfBirth = json['dateOfBirth'];
    _gender = json['gender'];
    _userType = json['userType'];
    _profileImageUrl = json['profileImageUrl'];
  }
  Map<String, dynamic> toJson(){
    return {
      "userUid" : _userUid,
      "firstName" : _firstName,
      "lastName" : _lastName,
      "email" : _email,
      "phone" : _phone,
      "dateOfBirth" : _dateOfBirth,
      "gender" : _gender,
      "userType" : _userType,
      "profileImageUrl" : _profileImageUrl,
    };
  }


  String get userUid => _userUid;

  set userUid(String value) {
    _userUid = value;
  }

  String get profileImageUrl => _profileImageUrl;

  set profileImageUrl(String value) {
    _profileImageUrl = value;
  }

  String get userType => _userType;

  set userType(String value) {
    _userType = value;
  }

  String get gender => _gender;

  set gender(String value) {
    _gender = value;
  }

  String get dateOfBirth => _dateOfBirth;

  set dateOfBirth(String value) {
    _dateOfBirth = value;
  }

  String get phone => _phone;

  set phone(String value) {
    _phone = value;
  }

  String get email => _email;

  set email(String value) {
    _email = value;
  }

  String get lastName => _lastName;

  set lastName(String value) {
    _lastName = value;
  }

  String get firstName => _firstName;

  set firstName(String value) {
    _firstName = value;
  }
}