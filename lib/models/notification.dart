class MyNotification {
  MyNotification(this._message, this._date, this._timestamp);

  MyNotification.map(dynamic obj) {
    this._message = obj['Message'];
    this._timestamp = obj['Timestamp'];
    this._date = obj['Date'];
  }

  String _message, _date;
  int _timestamp;

  String get message =>   _message;

  String get date => _date;

  int get timestamp => _timestamp;
}
