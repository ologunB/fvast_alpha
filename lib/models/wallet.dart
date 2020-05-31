class EachTransaction {
  String _id;
  String _userUid;
  double _amount;
  String _date;
  String _type;
  int _timeStamp;

  String get id => _id;
  String get type => _type;
  String get userId => _userUid;
  double get amount => _amount;
  String get date => _date;
  int get timeStamp => _timeStamp;

  EachTransaction(this._amount, this._userUid, this._id, this._timeStamp,
      this._date, this._type);

  EachTransaction.map(dynamic obj) {
    this._amount = obj["Amount"];
    this._userUid = obj["uid"];
    this._date = obj["date"];
    this._type = obj["type"];
    this._timeStamp = obj['Timestamp'];
    this._id = obj["id"];
  }
}
