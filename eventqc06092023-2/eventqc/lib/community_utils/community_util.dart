class Community{
  late String _key;
  late String _categoryKey;
  late String _name;
  late String _creationDate;
  late String _category;
  late String _coverImageUrl;
  late String _description;


  Community(this._key,this._categoryKey, this._name, this._creationDate, this._category, this._coverImageUrl, this._description,);

  Community.fromJson(Map<String, dynamic> json){
    _key = json['key'];
    _categoryKey = json['categoryKey'];
    _name = json['name'];
    _creationDate = json['creationDate'];
    _category = json['category'];
    _coverImageUrl = json['coverImageUrl'];
    _description = json['description'];
  }

  Map<String, dynamic> toJson(){
    return {
      "key" : _key,
      "categoryKey" : _categoryKey,
      "name" : _name,
      "creationDate" : _creationDate,
      "category" : _category,
      "coverImageUrl" : _coverImageUrl,
      "description" : _description,
    };
  }


  String get categoryKey => _categoryKey;

  set categoryKey(String value) {
    _categoryKey = value;
  }

  String get coverImageUrl => _coverImageUrl;

  set coverImageUrl(String value) {
    _coverImageUrl = value;
  }

  String get category => _category;

  set category(String value) {
    _category = value;
  }

  String get creationDate => _creationDate;

  set creationDate(String value) {
    _creationDate = value;
  }

  String get name => _name;

  set name(String value) {
    _name = value;
  }

  String get key => _key;

  set key(String value) {
    _key = value;
  }

  String get description => _description;

  set description(String value) {
    _description = value;
  }
}