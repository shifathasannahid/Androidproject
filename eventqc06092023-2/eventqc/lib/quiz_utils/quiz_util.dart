class Quiz{
  late String _id;
  late String _question;
  late String _optionA;
  late String _optionB;
  late String _optionC;
  late String _optionD;
  late String _answer;

  Quiz(this._id, this._question, this._optionA, this._optionB, this._optionC,
      this._optionD, this._answer);

  Quiz.fromJson(Map<String, dynamic> json){
    _id = json['id'].toString();
    _question = json['question'].toString();
    _optionA = json['optionA'].toString();
    _optionB = json['optionB'].toString();
    _optionC = json['optionC'].toString();
    _optionD = json['optionD'].toString();
    _answer = json['answer'].toString();
  }

  Map<String, dynamic> toJson(){
    return{
      "id" : _id,
      "question" : _question,
      "optionA" : _optionA,
      "optionB" : _optionB,
      "optionC" : _optionC,
      "optionD" : _optionD,
      "answer" : _answer,
    };
  }
  String get answer => _answer;

  set answer(String value) {
    _answer = value;
  }

  String get optionD => _optionD;

  set optionD(String value) {
    _optionD = value;
  }

  String get optionC => _optionC;

  set optionC(String value) {
    _optionC = value;
  }

  String get optionB => _optionB;

  set optionB(String value) {
    _optionB = value;
  }

  String get optionA => _optionA;

  set optionA(String value) {
    _optionA = value;
  }

  String get question => _question;

  set question(String value) {
    _question = value;
  }

  String get id => _id;

  set id(String value) {
    _id = value;
  }
}