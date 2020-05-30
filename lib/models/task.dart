class Task {
  String _id;
  String _adminUid;
  String _userUid;
  double _amount;
  String _name;
  String _startDate;
  String _endDate;
  int _routeType;

  int _distance;
  String _type;
  String _weight;
  String _size;
  String _deliInstru;
  String _pickInstr;
  String _reNum;
  String _reName;
  String _coupon;
  String _paymentType;
  double _toLong;
  double _toLat;
  double _fromLong;
  double _fromLat;
  int _timeStamp;

  String get name => _name;
  int get distance => _distance;
  String get type => _type;
  String get weight => _weight;
  String get size => _size;
  String get deliInstru => _deliInstru;
  String get pickInstr => _pickInstr;
  String get reNum => _reNum;
  String get reName => _reName;
  String get coupon => _coupon;
  String get paymentType => _paymentType;
  double get toLong => _toLong;
  double get toLat => _toLat;
  double get fromLong => _fromLong;
  double get fromLat => _fromLat;
  String get startDate => _startDate;
  String get endDate => _endDate;
  String get id => _id;
  String get userUid => _userUid;
  String get adminUid => _adminUid;
  int get routeType => _routeType;
  double get amount => _amount;
  int get timeStamp => _timeStamp;

  Task(
      this._id,
      this._startDate,
      this._amount,
      this._timeStamp,
      this._routeType,
      this._name,
      this._adminUid,
      this._userUid,
      this._type,
      this._coupon,
      this._deliInstru,
      this._distance,
      this._fromLat,
      this._fromLong,
      this._paymentType,
      this._pickInstr,
      this._reName,
      this._reNum,
      this._size,
      this._toLat,
      this._endDate,
      this._toLong,
      this._weight);

  Task.map(dynamic obj) {
    this._name = obj["Name"];
    this._startDate = obj['startDate'];
    this._amount = obj['Amount'];
    this._userUid = obj["userUid"];
    this._fromLat = obj["fromLat"];
    this._fromLong = obj["fromLong"];
    this._toLat = obj["toLat"];
    this._toLong = obj["toLong"];
    this._paymentType = obj["Payment Type"];
    this._routeType = obj["Route Type"];
    this._coupon = obj["coupon"];
    this._reName = obj["Receiver Name"];
    this._reNum = obj["Receiver Number"];
    this._pickInstr = obj["Pickup Instru"];
    this._deliInstru = obj["Delivery Instru"];
    this._size = obj["Size"];
    this._weight = obj["Weight"];
    this._endDate = obj["endDate"];
    this._type = obj["type"];
    this._distance = obj["distance"];
    this._timeStamp = obj['Timestamp'];

    this._id = obj["id"];
  }
}
