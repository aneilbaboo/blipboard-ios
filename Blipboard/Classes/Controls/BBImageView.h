//
//  BBImageView.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 1/30/12
//  Copyright 2011 Blipboard. All rights reserved.
//

#import "ASIHTTPRequest.h"

typedef UIColor *(^BackgroundColorFn)(UIImage *);

@interface BBImageView : UIImageView 

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder;
- (void)setImageWithURLString:(NSString *)urlString placeholderImage:(UIImage *)placeholder;

@end