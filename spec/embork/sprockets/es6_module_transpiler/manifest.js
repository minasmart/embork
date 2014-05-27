define("my_fancy_module",
  ["math","exports"],
  function(__dependency1__, __exports__) {
    "use strict";
    var Point = __dependency1__.Point;
    var pow = __dependency1__.pow;
    var sqrt = __dependency1__.sqrt;

    function Segment(start, end) {
      this.start = start;
      this.end = end;

      this.distance = sqrt(
        pow(start.x - end.x, 2) +
        pow(start.y - end.y, 2)
      );
    }

    __exports__["default"] = Segment;
  });