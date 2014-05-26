import { Point, pow, sqrt } from "math";

function Segment(start, end) {
  this.start = start;
  this.end = end;

  this.distance = sqrt(
    pow(start.x - end.x, 2) +
    pow(start.y - end.y, 2)
  );
}

export default Segment;
