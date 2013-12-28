//
//  CommentNotification.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 3/7/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import "CommentNotification.h"

@implementation CommentNotification

+(RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [super mapping];
    mapping.objectClass = [CommentNotification class];
    [mapping mapKeyPath:@"commentId" toAttribute:@"commentId"];
    [mapping mapKeyPath:@"blipId" toAttribute:@"blipId"];
    return mapping;
}

-(BOOL)resolveBlips:(NSDictionary *)blips andChannels:(NSDictionary *)channels {
    self.blip = [blips objectForKey:self.blipId];
    for (Comment *comment in self.blip.comments) {
        if ([comment.id isEqualToString:self.commentId]) {
            _comment = comment;
        }
    }
    return (self.comment!=nil) && (self.blip!=nil);
    
}

-(NSString *)title {
    return super.title ? super.title : self.comment.author.name;
}

-(NSString *)picture {
    return super.picture ? super.picture : self.comment.author.picture;
}

-(NSString *)subtitle {
    if (super.subtitle) {
        return super.subtitle;
    }
    else if ([self.blip.author.id isEqualToString:BBAppDelegate.sharedDelegate.myAccount.id]) {
        return @"commented on your blip";
    }
    else {
        return @"commented on a blip you commented on";
    }
}

-(void)takeAction:(id<NotificationActions>)responder {
    [responder showBlip:self.blip withComment:self.commentId];
}

@end



