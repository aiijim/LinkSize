//
//  LinkMapParse.h
//  LinkSize
//
//  Created by aiijim on 16/8/27.
//  Copyright © 2016年 aiijim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LinkMapParse : NSObject

@property (strong,nonatomic) NSString* fileName;

- (instancetype) init __attribute__((unavailable("Invoke the designated initializer")));

- (instancetype) initWithFileName:(NSString*)fileName NS_DESIGNATED_INITIALIZER;

- (void) parse;

- (NSInteger) getLibrarySizeInApp:(NSString*)libName;

- (NSArray*) getAllLibraryName;

@end
