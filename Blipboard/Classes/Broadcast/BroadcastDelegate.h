//
//  BroadcastFlowDelegate.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 3/30/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#ifndef Blipboard_BroadcastFlowDelegate_h
#define Blipboard_BroadcastFlowDelegate_h

@protocol BroadcastFlowDelegate <NSObject>
-(void)broadcastFlowDidFinish:(Blip *)blip;
-(void)broadcastFlowDidCancel;
@end


#endif
