//
//  Tile.h - a port of GlobalMapTiles.js; completely untested!
//  Blipboard
//
//  Created by Aneil Mallavarapu on 6/29/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

typedef struct {
    CGPoint minPoint;
    CGPoint maxPoint;
} TileBounds;

typedef struct {
    CLLocationCoordinate2D southWest;
    CLLocationCoordinate2D northEast;
} CoordinateTileBounds;


@interface BBTile : NSObject 
//
//  Tile.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 6/29/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//


//Converts given lat/lon in WGS84 Datum to XY in Spherical Mercator EPSG:900913
+(CGPoint)metersFromCoordinate:(CLLocationCoordinate2D)coordinate ;

//Converts XY point from Spherical Mercator EPSG:900913 to lat/lon in WGS84 Datum
+(CLLocationCoordinate2D)coordinateFromMeters:(CGPoint)meters ;

//Converts pixel coordinates in given zoom level of pyramid to EPSG:900913
+(CGPoint)metersFromPixel:(CGPoint)pixels andZoom:(NSUInteger)zoom;

//Converts EPSG:900913 to pyramid pixel coordinates in given zoom level
+(CGPoint)pixelFromMeters:(CGPoint)meters andZoom:(NSUInteger)zoom ;

//Returns a tile covering region in given pixel coordinates
+(CGPoint)tilePointFromPixel:(CGPoint)pixel ;

//Returns tile for given mercator coordinates
+(CGPoint)tilePointFromMeters:(CGPoint)meters andZoom:(NSUInteger)zoom ;

//Returns bounds of the given tile in EPSG:900913 coordinates
+(TileBounds)metersBoundsFromTilePoint:(CGPoint)tilePoint andZoom:(NSUInteger)zoom;

//Returns bounds of the given tile in latutude/longitude using WGS84 datum
+(CoordinateTileBounds)coordinateTileBoundsFromTilePoint:(CGPoint)tilePoint andZoom:(NSUInteger)zoom;

//Resolution (meters/pixel) for given zoom level (measured at Equator)
+(CGFloat)resolutionFromZoom:(NSUInteger)zoom ;

//Converts TMS tile coordinates to Microsoft QuadTree
+(NSString *)quadTreeFromTilePoint:(CGPoint)tilePoint andZoom:(NSUInteger)zoom;

//Converts a quadtree to tile coordinates
+(CGPoint)tilePointFromQuadTree:(NSString *)quadtree andZoom:(NSUInteger)zoom ;

//Converts a latitude and longitude to quadtree at the specified zoom level 
+(NSString *)quadTreeFromCoordinate:(CLLocationCoordinate2D)coordinate andZoom:(NSUInteger)zoom;

//Converts a quadtree location into a latitude/longitude bounding rectangle
+(CoordinateTileBounds)coordinateTileBoundsFromQuadTree:(NSString *)quadtree ;

//Returns a list of all of the quadtree locations at a given zoom level within a latitude/longude box
+(NSMutableArray *)quadTreeListAtZoom:(NSUInteger)zoom 
                            southWest:(CLLocationCoordinate2D)latLon
                            northEast:(CLLocationCoordinate2D)latLonMax ;
@end
