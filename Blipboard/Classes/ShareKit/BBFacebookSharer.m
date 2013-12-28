//
//  BBFacebookSharer.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 4/3/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import "SHKiOSFacebook.h"
#import "BBFacebookSharer.h"
#import "SHKConfiguration.h"

@implementation BBFacebookSharer
+(void)logout {
    // !am! don't log out!  We need it for the app.
}

- (void)share {
    
    if ([self socialFrameworkAvailable]) {
        
        SHKSharer *iosSharer = [SHKiOSFacebook shareItem:self.item];
        iosSharer.quiet = self.quiet;
        iosSharer.shareDelegate = self.shareDelegate;
        // !am! we need to get rid of this line:
        //      it logs us out of Blipboard
        // [SHKFacebook logout];
        
    } else {
        
        [super share];
    }
}

// !am! we have copy this over from 
- (BOOL)socialFrameworkAvailable {
    
    if ([SHKCONFIG(forcePreIOS6FacebookPosting) boolValue])
    {
        return NO;
    }
    
	if (NSClassFromString(@"SLComposeViewController"))
    {
		return YES;
	}
	
	return NO;
}

@end
