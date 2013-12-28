//
//  BBLog.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 7/16/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#ifndef Blipboard_BBLog_h
#define Blipboard_BBLog_h

#import "LoggerClient.h"

#if !defined CONFIGURATION_Release
#define BBLogging 1
#define BBLog(fmt, ...) LogMessageF(__FILE__, __LINE__, __PRETTY_FUNCTION__, @"bbapp", 0, fmt, ##__VA_ARGS__); \
                        NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

#define BBTrace() LogMessageF(__FILE__, __LINE__, __PRETTY_FUNCTION__, @"bbapp", 0, @"(trace)"); \
                    NSLog(@"%s [Line %d] ", __PRETTY_FUNCTION__, __LINE__);


#define BBLogLevel(level, fmt, ...) LogMessageF(__FILE__, __LINE__, __PRETTY_FUNCTION__, @"bbapp", level, fmt, ##__VA_ARGS__);

#define BBTraceLevel(level) LogMessageF(__FILE__, __LINE__, __PRETTY_FUNCTION__, @"bbapp", level, @"(trace)");

#define BBLogImage(width,height,data) LogImageDataF(__FILE__, __LINE__, __PRETTY_FUNCTION__, @"bbapp", 0, width, height, data);

#else
#define BBLogging 0
#define BBLog(...) do{}while(0);
#define BBTrace() do{}while(0);
#define BBTraceLevel(...) do{}while(0);
#define BBLogLevel(...) do{}while(0);
#define BBLogImage(...) do{}while(0);

#endif

#endif
