// Generated by CoffeeScript 1.6.3
var TileTiers;

TileTiers = (function() {
  function TileTiers(parentTag) {
    this.parentTag = parentTag;
    this.tiers = [];
  }

  TileTiers.prototype.addTier = function(tier) {
    return this.tiers.push(tier);
  };

  TileTiers.prototype.addGroup = function(tierIdx, groupTitle) {
    if (tierIdx >= this.tiers.length) {
      return;
    }
    return this.tiers[tierIdx].addGroup(groupTitle);
  };

  TileTiers.prototype.reDoLayout = function() {
    var tier, _i, _len, _ref, _results;
    _ref = this.tiers;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      tier = _ref[_i];
      _results.push(tier.reDoLayout());
    }
    return _results;
  };

  TileTiers.prototype.addTileToTierGroup = function(tierIdx, groupIdx, tile) {
    if (tierIdx >= this.tiers.length) {
      return;
    }
    return this.tiers[tierIdx].addTileToGroup(groupIdx, tile);
  };

  return TileTiers;

})();
