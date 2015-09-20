//
//  FBGeometry.swift
//  Swift VectorBoolean for iOS
//
//  Based on FBGeometry - Created by Andrew Finnell on 5/28/11.
//  Copyright 2011 Fortunate Bear, LLC. All rights reserved.
//
//  Created by Leslie Titze on 2015-05-21.
//  Copyright (c) 2015 Leslie Titze. All rights reserved.
//

import UIKit


// ===================================
// MARK: Point Helpers
// ===================================

let isRunningOn64BitDevice = sizeof(Int) == sizeof(Int64)

var FBPointClosenessThreshold: Double {
  if isRunningOn64BitDevice {
    return 1e-10
  } else {
    return 1e-2
  }
}
var FBTangentClosenessThreshold: Double {
  if isRunningOn64BitDevice {
    return 1e-12
  } else {
    return 1e-2
  }
}
var FBBoundsClosenessThreshold: Double {
  if isRunningOn64BitDevice {
    return 1e-9
  } else {
    return 1e-2
  }
}

func FBDistanceBetweenPoints(point1: CGPoint, point2: CGPoint) -> Double {

  let xDelta = Double(point2.x - point1.x)
  let yDelta = Double(point2.y - point1.y)

  return sqrt(xDelta * xDelta + yDelta * yDelta);
}

func FBDistancePointToLine(point: CGPoint, lineStartPoint: CGPoint, lineEndPoint: CGPoint) -> Double {

  let lineLength = FBDistanceBetweenPoints(lineStartPoint, point2: lineEndPoint)
  if lineLength == 0.0 {
    return 0.0
  }
  let num = Double((point.x - lineStartPoint.x) * (lineEndPoint.x - lineStartPoint.x) + (point.y - lineStartPoint.y) * (lineEndPoint.y - lineStartPoint.y))

  let u = CGFloat(num / (lineLength * lineLength))

  let intersectionPoint = CGPoint(
    x: lineStartPoint.x + u * (lineEndPoint.x - lineStartPoint.x),
    y: lineStartPoint.y + u * (lineEndPoint.y - lineStartPoint.y)
  )

  return FBDistanceBetweenPoints(point, point2: intersectionPoint)
}

func FBAddPoint(point1: CGPoint, point2: CGPoint) -> CGPoint {

  return CGPoint(
    x: point1.x + point2.x,
    y: point1.y + point2.y)
}

func FBUnitScalePoint(point: CGPoint, scale: Double) -> CGPoint {

  var result = point
  let length = FBPointLength(point)
  if length != 0.0 {
    result.x = CGFloat(Double(result.x) * (scale/length))
    result.y = CGFloat(Double(result.y) * (scale/length))
  }
  return result
}

func FBScalePoint(point: CGPoint, scale: CGFloat) -> CGPoint {

  return CGPoint(
    x: point.x * scale,
    y: point.y * scale)
}

func FBDotMultiplyPoint(point1: CGPoint, point2: CGPoint) -> Double {

  let dotX = Double(point1.x) * Double(point2.x)
  let dotY = Double(point1.y) * Double(point2.y)
  return dotX + dotY
}

func FBSubtractPoint(point1: CGPoint, point2: CGPoint) -> CGPoint {

  return CGPoint(
    x: point1.x - point2.x,
    y: point1.y - point2.y)
}

func FBPointLength(point: CGPoint) -> Double {
  let xSq = Double(point.x) * Double(point.x)
  let ySq = Double(point.y) * Double(point.y)
  return sqrt(xSq + ySq)
}

func FBPointSquaredLength(point: CGPoint) -> Double {
  let xSq = Double(point.x) * Double(point.x)
  let ySq = Double(point.y) * Double(point.y)
  return xSq + ySq
}

func FBNormalizePoint(point: CGPoint) -> CGPoint {

  var result = point
  let length = FBPointLength(point)
  if length != 0.0 {
    result.x = CGFloat(Double(result.x) / length)
    result.y = CGFloat(Double(result.y) / length)
  }
  return result
}

func FBNegatePoint(point: CGPoint) -> CGPoint {

  return CGPoint(
    x: -point.x,
    y: -point.y)
}

func FBRoundPoint(point: CGPoint) -> CGPoint {

  return CGPoint(
    x: round(point.x),
    y: round(point.y))
}

func FBLineNormal(lineStart: CGPoint, lineEnd: CGPoint) -> CGPoint {

  return FBNormalizePoint(CGPoint(
    x: -(lineEnd.y - lineStart.y),
    y: lineEnd.x - lineStart.x))
}

func FBLineMidpoint(lineStart: CGPoint, lineEnd: CGPoint) -> CGPoint {

  let distance = FBDistanceBetweenPoints(lineStart, point2: lineEnd)
  let tangent = FBNormalizePoint(FBSubtractPoint(lineEnd, point2: lineStart))
  return FBAddPoint(lineStart, point2: FBUnitScalePoint(tangent, scale: distance / 2.0))
}

func FBRectGetTopLeft(rect : CGRect) -> CGPoint {

  return CGPoint(
    x: CGRectGetMinX(rect),
    y: CGRectGetMinY(rect))
}

func FBRectGetTopRight(rect : CGRect) -> CGPoint {

  return CGPoint(
    x: CGRectGetMaxX(rect),
    y: CGRectGetMinY(rect))
}

func FBRectGetBottomLeft(rect : CGRect) -> CGPoint {

  return CGPoint(
    x: CGRectGetMinX(rect),
    y: CGRectGetMaxY(rect))
}

func FBRectGetBottomRight(rect : CGRect) -> CGPoint {

  return CGPoint(
    x: CGRectGetMaxX(rect),
    y: CGRectGetMaxY(rect))
}

func FBExpandBoundsByPoint(inout topLeft: CGPoint, inout bottomRight: CGPoint, point: CGPoint) {

  if point.x < topLeft.x     { topLeft.x = point.x }

  if point.x > bottomRight.x { bottomRight.x = point.x }

  if point.y < topLeft.y     { topLeft.y = point.y }

  if point.y > bottomRight.y { bottomRight.y = point.y }
}

func FBUnionRect(rect1: CGRect, rect2: CGRect) -> CGRect {

  var topLeft = FBRectGetTopLeft(rect1)
  var bottomRight = FBRectGetBottomRight(rect1)
  FBExpandBoundsByPoint(&topLeft, bottomRight: &bottomRight, point: FBRectGetTopLeft(rect2))
  FBExpandBoundsByPoint(&topLeft, bottomRight: &bottomRight, point: FBRectGetTopRight(rect2))
  FBExpandBoundsByPoint(&topLeft, bottomRight: &bottomRight, point: FBRectGetBottomRight(rect2))
  FBExpandBoundsByPoint(&topLeft, bottomRight: &bottomRight, point: FBRectGetBottomLeft(rect2))

  return CGRect(
    x: topLeft.x,
    y: topLeft.y,
    width: bottomRight.x - topLeft.x,
    height: bottomRight.y - topLeft.y)
}


// ===================================
// MARK: -- Distance Helper methods --
// ===================================


func FBArePointsClose(point1: CGPoint, point2: CGPoint) -> Bool {

  return FBArePointsCloseWithOptions(point1, point2: point2, threshold: FBPointClosenessThreshold)
}

func FBArePointsCloseWithOptions(point1: CGPoint, point2: CGPoint, threshold: Double) -> Bool {

  return FBAreValuesCloseWithOptions(Double(point1.x), value2: Double(point2.x), threshold: threshold) && FBAreValuesCloseWithOptions(Double(point1.y), value2: Double(point2.y), threshold: threshold);
}

func FBAreValuesClose(value1: CGFloat, value2: CGFloat) -> Bool {

  return FBAreValuesCloseWithOptions(Double(value1), value2: Double(value2), threshold: FBPointClosenessThreshold)
}

func FBAreValuesClose(value1: Double, value2: Double) -> Bool {

  return FBAreValuesCloseWithOptions(value1, value2: value2, threshold: Double(FBPointClosenessThreshold))
}

func FBAreValuesCloseWithOptions(value1: Double, value2: Double, threshold: Double) -> Bool {

  let delta = value1 - value2
  return (delta <= threshold) && (delta >= -threshold)
}




// ===================================
// MARK: ---- Angle Helpers ----
// ===================================


//////////////////////////////////////////////////////////////////////////
// Helper methods for angles
//

let Two_π = 2.0 * M_PI
let π = M_PI
let Half_π = M_PI_2


// Normalize the angle between 0 and 2 π
func NormalizeAngle(var value: Double) -> Double {

  while value < 0.0 {  value = value + Two_π }
  while value >= Two_π { value = value - Two_π }

  return value
}

// Compute the polar angle from the cartesian point
func PolarAngle(point: CGPoint) -> Double {

  var value = 0.0
  let dpx = Double(point.x)
  let dpy = Double(point.y)

  if point.x > 0.0 {
    value = atan(dpy / dpx)
  }
  else if point.x < 0.0 {
    if point.y >= 0.0 {
      value = atan(dpy / dpx) + π
    } else {
      value = atan(dpy / dpx) - π
    }
  } else {
    if point.y > 0.0 {
      value =  Half_π
    }
    else if point.y < 0.0 {
      value =  -Half_π
    }
    else {
      value = 0.0
    }
  }

  return NormalizeAngle(value)
}



// ===================================
// MARK: ---- Angle Range ----
// ===================================


//////////////////////////////////////////////////////////////////////////
// Angle Range structure provides a simple way to store angle ranges
//  and determine if a specific angle falls within.
//
struct FBAngleRange {
  var minimum : Double
  var maximum : Double
}


// NOTE: Should just use Swift:
//    var something = FBAngleRange(minimum: 12.0, maximum: 4.0)
//func FBAngleRangeMake(minimum: CGFloat, maximum: CGFloat) -> FBAngleRange {
//
//  return FBAngleRange(minimum: minimum, maximum: maximum)
//}


//func FBIsValueGreaterThanWithOptions(value: CGFloat, minimum: CGFloat, threshold: CGFloat) -> Bool {
//
//  if FBAreValuesCloseWithOptions(value, value2: minimum, threshold: threshold) {
//    return false
//  }
//
//  return value > minimum
//}
//
func FBIsValueGreaterThan(value: CGFloat, minimum: CGFloat) -> Bool {

  return FBIsValueGreaterThanWithOptions(Double(value), minimum: Double(minimum), threshold: FBTangentClosenessThreshold)
}

func FBIsValueGreaterThanWithOptions(value: Double, minimum: Double, threshold: Double) -> Bool {

  if FBAreValuesCloseWithOptions(value, value2: minimum, threshold: threshold) {
    return false
  }

  return value > minimum
}

func FBIsValueGreaterThan(value: Double, minimum: Double) -> Bool {

  return FBIsValueGreaterThanWithOptions(value, minimum: minimum, threshold: Double(FBTangentClosenessThreshold))
}

func FBIsValueLessThan(value: CGFloat, maximum: CGFloat) -> Bool {

  if FBAreValuesCloseWithOptions(Double(value), value2: Double(maximum), threshold: FBTangentClosenessThreshold) {
    return false
  }

  return value < maximum
}

func FBIsValueLessThan(value: Double, maximum: Double) -> Bool {

  if FBAreValuesCloseWithOptions(value, value2: maximum, threshold: Double(FBTangentClosenessThreshold)) {
    return false
  }

  return value < maximum
}

func FBIsValueGreaterThanEqual(value: CGFloat, minimum: CGFloat) -> Bool {

  if FBAreValuesCloseWithOptions(Double(value), value2: Double(minimum), threshold: FBTangentClosenessThreshold) {
    return true
  }

  return value >= minimum
}

func FBIsValueGreaterThanEqual(value: Double, minimum: Double) -> Bool {

  if FBAreValuesCloseWithOptions(value, value2: minimum, threshold: Double(FBTangentClosenessThreshold)) {
    return true
  }

  return value >= minimum
}
//
//func FBIsValueLessThanEqualWithOptions(value: CGFloat, maximum: CGFloat, threshold: CGFloat) -> Bool {
//
//  if FBAreValuesCloseWithOptions(value, value2: maximum, threshold: threshold) {
//    return true
//  }
//
//  return value <= maximum
//}

func FBIsValueLessThanEqualWithOptions(value: Double, maximum: Double, threshold: Double) -> Bool {

  if FBAreValuesCloseWithOptions(value, value2: maximum, threshold: threshold) {
    return true
  }

  return value <= maximum
}

func FBIsValueLessThanEqual(value: CGFloat, maximum: CGFloat) -> Bool {

  return FBIsValueLessThanEqualWithOptions(Double(value), maximum: Double(maximum), threshold: FBTangentClosenessThreshold)
}

func FBIsValueLessThanEqual(value: Double, maximum: Double) -> Bool {

  return FBIsValueLessThanEqualWithOptions(value, maximum: maximum, threshold: FBTangentClosenessThreshold)
}


func FBAngleRangeContainsAngle(range: FBAngleRange, angle: Double) -> Bool {

  if range.minimum <= range.maximum {
    return FBIsValueGreaterThan(angle, minimum: range.minimum) && FBIsValueLessThan(angle, maximum: range.maximum)
  }

  // The range wraps around 0. See if the angle falls in the first half
  if FBIsValueGreaterThan(angle, minimum: range.minimum) && angle <= Two_π {
    return true
  }

  return angle >= 0.0 && FBIsValueLessThan(angle, maximum: range.maximum)
}


// ===================================
// MARK: Parameter ranges
// ===================================


// FBRange is a range of parameter (t)
struct FBRange {
  var minimum : Double
  var maximum : Double
}

func FBRangeHasConverged(range: FBRange, decimalPlaces: Int) -> Bool {
  let factor = pow(10.0, Double(decimalPlaces))
  let minimum = Int(range.minimum * factor)
  let maxiumum = Int(range.maximum * factor)
  return minimum == maxiumum
}

func FBRangeGetSize(range: FBRange) -> Double {

  return range.maximum - range.minimum
}

func FBRangeAverage(range: FBRange) -> Double {

  return (range.minimum + range.maximum) / 2.0
}

func FBRangeScaleNormalizedValue(range: FBRange, value: Double) -> Double {

  return (range.maximum - range.minimum) * value + range.minimum
}

func FBRangeUnion(range1: FBRange, range2: FBRange) -> FBRange {

  return FBRange(minimum: min(range1.minimum, range2.minimum), maximum: max(range1.maximum, range2.maximum))
}


// ===================================
// MARK: Tangents
// ===================================


struct FBTangentPair {
  var left: CGPoint
  var right: CGPoint
}

func FBAreTangentsAmbigious(edge1Tangents: FBTangentPair, edge2Tangents: FBTangentPair) -> Bool {

  let normalEdge1 = FBTangentPair(left: FBNormalizePoint(edge1Tangents.left), right: FBNormalizePoint(edge1Tangents.right))
  let normalEdge2 = FBTangentPair(left: FBNormalizePoint(edge2Tangents.left), right: FBNormalizePoint(edge2Tangents.right))

  return FBArePointsCloseWithOptions(normalEdge1.left,  point2: normalEdge2.left,  threshold: FBTangentClosenessThreshold)
      || FBArePointsCloseWithOptions(normalEdge1.left,  point2: normalEdge2.right, threshold: FBTangentClosenessThreshold)
      || FBArePointsCloseWithOptions(normalEdge1.right, point2: normalEdge2.left,  threshold: FBTangentClosenessThreshold)
      || FBArePointsCloseWithOptions(normalEdge1.right, point2: normalEdge2.right, threshold: FBTangentClosenessThreshold)
}


struct FBAnglePair {
  var a: Double
  var b: Double
}

func FBTangentsCross(edge1Tangents: FBTangentPair, edge2Tangents: FBTangentPair) -> Bool {

  // Calculate angles for the tangents
  let edge1Angles = FBAnglePair(a: PolarAngle(edge1Tangents.left), b: PolarAngle(edge1Tangents.right))
  let edge2Angles = FBAnglePair(a: PolarAngle(edge2Tangents.left), b: PolarAngle(edge2Tangents.right))

  // Count how many times edge2 angles appear between the self angles
  let range1 = FBAngleRange(minimum: edge1Angles.a, maximum: edge1Angles.b)
  var rangeCount1 = 0

  if FBAngleRangeContainsAngle(range1, angle: edge2Angles.a) {
    rangeCount1++
  }

  if FBAngleRangeContainsAngle(range1, angle: edge2Angles.b) {
    rangeCount1++
  }

  // Count how many times self angles appear between the edge2 angles
  let range2 = FBAngleRange(minimum: edge1Angles.b, maximum: edge1Angles.a)
  var rangeCount2 = 0

  if FBAngleRangeContainsAngle(range2, angle: edge2Angles.a) {
    rangeCount2++
  }

  if FBAngleRangeContainsAngle(range2, angle: edge2Angles.b) {
    rangeCount2++
  }

  // If each pair of angles split the other two, then the edges cross.
  return rangeCount1 == 1 && rangeCount2 == 1
}


func FBLineBoundsMightOverlap(bounds1: CGRect, bounds2: CGRect) -> Bool
{
  let left = Double(max(CGRectGetMinX(bounds1), CGRectGetMinX(bounds2)))
  let right = Double(min(CGRectGetMaxX(bounds1), CGRectGetMaxX(bounds2)))

  if FBIsValueGreaterThanWithOptions(left, minimum: right, threshold: FBBoundsClosenessThreshold) {
    return false    // no horizontal overlap
  }

  let top = Double(max(CGRectGetMinY(bounds1), CGRectGetMinY(bounds2)))
  let bottom = Double(min(CGRectGetMaxY(bounds1), CGRectGetMaxY(bounds2)))
  return FBIsValueLessThanEqualWithOptions(top, maximum: bottom, threshold: FBBoundsClosenessThreshold)
}
