"use strict";
var Point = require("math").Point;
var pow = require("math").pow;
var sqrt = require("math").sqrt;

function Segment(start, end) {
  this.start = start;
  this.end = end;

  this.distance = sqrt(
    pow(start.x - end.x, 2) +
    pow(start.y - end.y, 2)
  );
}

exports["default"] = Segment;