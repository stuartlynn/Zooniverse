// Generated by CoffeeScript 1.6.3
(function() {
  var $, Api, Favorite, Recent, User, _base, _ref,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  if (window.zooniverse == null) {
    window.zooniverse = {};
  }

  if ((_base = window.zooniverse).models == null) {
    _base.models = {};
  }

  Recent = window.zooniverse.models.Recent || require('./recent');

  Api = window.zooniverse.Api || require('../lib/api');

  User = window.zooniverse.models.User || require('./user');

  $ = window.jQuery;

  Favorite = (function(_super) {
    __extends(Favorite, _super);

    function Favorite() {
      this.toJSON = __bind(this.toJSON, this);
      _ref = Favorite.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    Favorite.type = 'favorite';

    Favorite.clearOnUserChange();

    Favorite.prototype.toJSON = function() {
      var subject;
      return {
        favorite: {
          subject_ids: (function() {
            var _i, _len, _ref1, _results;
            _ref1 = this.subjects;
            _results = [];
            for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
              subject = _ref1[_i];
              _results.push(subject.id);
            }
            return _results;
          }).call(this)
        }
      };
    };

    Favorite.prototype.send = function() {
      var _this = this;
      this.trigger('sending');
      return Api.current.post("/projects/" + Api.current.project + "/favorites", this.toJSON(), function(response) {
        _this.id = response.id;
        return _this.trigger('send');
      });
    };

    Favorite.prototype["delete"] = function() {
      var _this = this;
      this.trigger('deleting');
      return Api.current["delete"]("/projects/" + Api.current.project + "/favorites/" + this.id, function() {
        _this.trigger('delete');
        return _this.destroy();
      });
    };

    return Favorite;

  })(Recent);

  window.zooniverse.models.Favorite = Favorite;

  if (typeof module !== "undefined" && module !== null) {
    module.exports = Favorite;
  }

}).call(this);
