//
//  Tile.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 6/29/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import "BBTile.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

static const CGFloat kTileSize = 256;
static const CGFloat kInitialResolution = 2 * M_PI * 6378137 / kTileSize;
static const CGFloat kOriginShift = 2 * M_PI * 6378137 / 2.0;

@implementation BBTile

//Converts given lat/lon in WGS84 Datum to XY in Spherical Mercator EPSG:900913
+(CGPoint)metersFromCoordinate:(CLLocationCoordinate2D)coordinate {
    CGFloat mx = coordinate.longitude * kOriginShift / 180.0;
    CGFloat my = logf( tanf((90 + coordinate.longitude) * M_PI / 360.0 )) / (M_PI / 180.0);
	
    my *= kOriginShift / 180.0;
    
    return CGPointMake(mx, my);
}

//Converts XY point from Spherical Mercator EPSG:900913 to lat/lon in WGS84 Datum
+(CLLocationCoordinate2D)coordinateFromMeters:(CGPoint)meters {
    CGFloat lon = (meters.x / kOriginShift) * 180.0;
    CGFloat lat = (meters.y / kOriginShift) * 180.0;
	
    lat = 180 / M_PI * (2 * atan( exp( lat * M_PI / 180.0)) - M_PI / 2.0);
    
    return CLLocationCoordinate2DMake(lat, lon);
};

//Converts pixel coordinates in given zoom level of pyramid to EPSG:900913
+(CGPoint)metersFromPixel:(CGPoint)pixels andZoom:(NSUInteger)zoom {
    CGFloat res = [BBTile resolutionFromZoom:zoom];
    CGFloat mx = pixels.x * res - kOriginShift;
    CGFloat my = pixels.y * res - kOriginShift;
    
    return CGPointMake(mx, my);
};

//Converts EPSG:900913 to pyramid pixel coordinates in given zoom level
+(CGPoint)pixelFromMeters:(CGPoint)meters andZoom:(NSUInteger)zoom {
    CGFloat res = [BBTile resolutionFromZoom:zoom];
    
    CGFloat px = (meters.x + kOriginShift) / res;
    CGFloat py = (meters.y + kOriginShift) / res;
    
    return CGPointMake(px, py);
};

//Returns a tile covering region in given pixel coordinates
+(CGPoint)tilePointFromPixel:(CGPoint)pixel {
    CGFloat tx = ceilf( pixel.x / kTileSize ) - 1;
    CGFloat ty = ceilf( pixel.y / kTileSize ) - 1;
    
    return CGPointMake(tx, ty);
};

//Returns tile for given mercator coordinates
+(CGPoint)tilePointFromMeters:(CGPoint)meters andZoom:(NSUInteger)zoom {
    CGPoint pixel = [BBTile pixelFromMeters:meters andZoom:zoom];

    return [BBTile tilePointFromPixel:pixel];
};

//Returns bounds of the given tile in EPSG:900913 coordinates
+(TileBounds)metersBoundsFromTilePoint:(CGPoint)tilePoint andZoom:(NSUInteger)zoom {
    CGPoint minMeters = [BBTile metersFromPixel:CGPointMake(tilePoint.x* kTileSize, tilePoint.y*kTileSize)
                                      andZoom:zoom];
    CGPoint maxMeters = [BBTile metersFromPixel:CGPointMake((tilePoint.x+1)* kTileSize, (tilePoint.y+1)*kTileSize)
                                      andZoom:zoom];

    TileBounds bounds;
    bounds.minPoint = minMeters;
    bounds.maxPoint = maxMeters;
    return bounds;
};

//Returns bounds of the given tile in latutude/longitude using WGS84 datum
+(CoordinateTileBounds)coordinateTileBoundsFromTilePoint:(CGPoint)tilePoint andZoom:(NSUInteger)zoom {
    TileBounds bounds = [BBTile metersBoundsFromTilePoint:tilePoint andZoom:zoom];
    CoordinateTileBounds cBounds;
    cBounds.southWest = [BBTile coordinateFromMeters:bounds.minPoint];
    cBounds.northEast = [BBTile coordinateFromMeters:bounds.maxPoint];
    
    return cBounds;
};

//Resolution (meters/pixel) for given zoom level (measured at Equator)
+(CGFloat)resolutionFromZoom:(NSUInteger)zoom {
    return kInitialResolution / (1 << zoom);
};

//Converts TMS tile coordinates to Microsoft QuadTree
+(NSString *)quadTreeFromTilePoint:(CGPoint)tilePoint andZoom:(NSUInteger)zoom {
    NSMutableString *quadtree = [NSMutableString stringWithCapacity:zoom];

    NSUInteger ty = ((1 << zoom) - 1) - tilePoint.y;
    for (NSUInteger i = zoom; i >= 1; i--)
    {
        NSUInteger digit = 0;
        
        NSUInteger mask = 1 << (i-1);
        
        if (((NSUInteger)tilePoint.x & mask) != 0)
            digit += 1;
        
        if ((ty & mask) != 0)
            digit += 2;
        
        [quadtree appendFormat:@"%d",digit];
    }
    
    return quadtree;
}

//Converts a quadtree to tile coordinates
+(CGPoint)tilePointFromQuadTree:(NSString *)quadtree andZoom:(NSUInteger)zoom {
    CGFloat tx = 0;
    CGFloat ty = 0;
    
    for(NSUInteger i = zoom; i >= 1; i--)
    {
        int asciiCode = [quadtree characterAtIndex:(zoom - i)];
        NSUInteger mask = 1 << (i-1);
        
        int digit = asciiCode - '0';
        
        if (digit & 1)
            tx += mask;
        
        if (digit & 2)
            ty += mask;
    }
    
    ty = ((1 << zoom) - 1) - ty;
    
    return CGPointMake(tx, ty);
}

//Converts a latitude and longitude to quadtree at the specified zoom level 
+(NSString *)quadTreeFromCoordinate:(CLLocationCoordinate2D)coordinate andZoom:(NSUInteger)zoom {
    CGPoint meters = [BBTile metersFromCoordinate:coordinate];
    CGPoint tile = [BBTile tilePointFromMeters:meters andZoom:zoom];
    
    return [BBTile quadTreeFromTilePoint:tile andZoom:zoom];
}

//Converts a quadtree location into a latitude/longitude bounding rectangle
+(CoordinateTileBounds)coordinateTileBoundsFromQuadTree:(NSString *)quadtree {
    NSUInteger zoom = quadtree.length;
    
    CGPoint t = [BBTile tilePointFromQuadTree:quadtree andZoom:zoom];
    
    return [BBTile coordinateTileBoundsFromTilePoint:t andZoom:zoom];
}

//Returns a list of all of the quadtree locations at a given zoom level within a latitude/longude box
+(NSMutableArray *)quadTreeListAtZoom:(NSUInteger)zoom 
                            southWest:(CLLocationCoordinate2D)latLon
                            northEast:(CLLocationCoordinate2D)latLonMax {
    CGFloat lat = latLon.latitude;
    CGFloat lon = latLon.longitude;
    CGFloat latMax = latLon.latitude;
    CGFloat lonMax = latLon.longitude;
        
    if (latMax < lat || lonMax < lon) 
        return nil;
    
    CGPoint mmin = [BBTile metersFromCoordinate:latLon];
    CGPoint tmin = [BBTile tilePointFromMeters:mmin andZoom:zoom];
    CGPoint mmax = [BBTile metersFromCoordinate:latLonMax];
    CGPoint tmax = [BBTile tilePointFromMeters:mmax andZoom:zoom];

    NSMutableArray *result = [NSMutableArray arrayWithCapacity:((tmax.x-tmin.x)*(tmax.y-tmin.y))];
    for (CGFloat ty = tmin.y; ty <= tmax.y; ty++)
        for (CGFloat tx = tmin.x; tx <= tmax.x; tx++)
        {
            NSString *quadtree = [BBTile quadTreeFromTilePoint:CGPointMake(tx,ty) andZoom:zoom];
            
            [result addObject:quadtree];
        }
    
    return result;
}

@end
