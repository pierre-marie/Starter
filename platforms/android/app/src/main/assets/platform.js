window.platform = {
  name: function () {
    return 'andoid';
  },

  alert: function (message) {
    android.alert(message);
  },

  yesOrNo: function (message) {
    var _this = this;
    return new Promise(function (resolve, reject) {
      var index = _this._callbacks.length;
      _this._callbacks.push(resolve);
      _this._callbacks.push(reject);
      android.yesOrNo(message, index, index + 1);
    });
  },

  _callbacks: [],

  _invoke: function (index, obj) {
    this._callbacks[index](obj);
  },
};