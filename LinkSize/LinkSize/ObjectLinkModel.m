//
//  ObjectLinkModel.m
//  LinkSize
//
//  Created by aiijim on 2017/2/15.
//  Copyright © 2017年 aiijim. All rights reserved.
//

#import "ObjectLinkModel.h"
#import "LinkMapUtil.h"

@interface ObjectLinkModel ()

@property (strong, nonatomic) NSMutableDictionary* symbolsContainer;

@end

@implementation ObjectLinkModel

-(instancetype) init
{
    self = [super init];
    if (self)
    {
        self.symbolsContainer = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSDictionary*)symbols
{
    return [self.symbolsContainer copy];
}

- (void)insertSymbols:(NSString*)symbol size:(int)size
{
    if ([symbol length] > 0)
    {
        [self.symbolsContainer setObject:[NSNumber numberWithInt:size] forKey:symbol];
    }
}

- (NSInteger) getTotalSize
{
    NSDictionary* symbolsList = self.symbols;
    NSInteger totalSize = 0;
    
    for(NSString* key in [symbolsList allKeys])
    {
        int size = [[symbolsList objectForKey:key] intValue];
        totalSize += size;
    }
    return totalSize;
}

@end
