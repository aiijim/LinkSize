//
//  LinkMapUtil.h
//  LinkSize
//
//  Created by aiijim on 16/8/27.
//  Copyright © 2016年 aiijim. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* const LIB_KEY;
extern NSString* const FILE_KEY;

@interface LinkMapUtil : NSObject

+ (void) printHelp;

+ (NSDictionary*) parseParameter:(int)argc argv:(const char* [])argv;

+ (NSString*) getDescStr:(NSInteger) totalSize;

@end
