class CategoryModel{
  late String _key;
  late String _name;

  CategoryModel(this._key, this._name);

  CategoryModel.fromJson(Map<String, dynamic> json){
    _key = json['key'];
    _name = json['name'];
  }
  Map<String, dynamic> toJson(){
    return {
      "key": _key,
      "name": _name,
    };
  }


  String get name => _name;

  set name(String value) {
    _name = value;
  }

  String get key => _key;

  set key(String value) {
    _key = value;
  }
}