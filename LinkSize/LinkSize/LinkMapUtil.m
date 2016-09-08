//
//  LinkMapUtil.m
//  LinkSize
//
//  Created by aiijim on 16/8/27.
//  Copyright © 2016年 aiijim. All rights reserved.
//

#import "LinkMapUtil.h"

NSString* const LIB_KEY = @"lib";
NSString* const FILE_KEY = @"file";

@implementation LinkMapUtil

+ (void) printHelp
{
    NSLog(@"Usage: LinkSize -%@ [libname ...] -%@ [linkmapfile ...] or LinkSize -%@ [linkmapfile ...] -%@ [libname ...]", LIB_KEY, FILE_KEY,FILE_KEY, LIB_KEY);
}

+ (NSDictionary*) parseParameter:(int)argc argv:(const char* [])argv
{
    NSMutableDictionary* paramDict = [NSMutableDictionary dictionary];
    NSString* lastKey = nil;
    for (int i = 1; i < argc; i++)
    {
        if (*argv[i] == '-')
        {
            NSMutableArray* fileArr = [NSMutableArray array];
            lastKey = [NSString stringWithCString:(argv[i] + 1) encoding:NSUTF8StringEncoding];
            [paramDict setObject:fileArr forKey:lastKey];
        }
        else
        {
            if ( !lastKey || ![paramDict objectForKey:lastKey])
            {
                return nil;
            }
            
            [[paramDict objectForKey:lastKey] addObject:[NSString stringWithCString:argv[i] encoding:NSUTF8StringEncoding]];
        }
    }
    
    NSSet * keySet = [NSSet setWithObjects:LIB_KEY, FILE_KEY,nil];
    NSArray* allKey = [paramDict allKeys];
    NSDictionary* resultDict = nil;
    if ([[paramDict objectForKey:LIB_KEY] count] > 0 && [[paramDict objectForKey:FILE_KEY] count] > 0 && [[NSSet setWithArray:allKey] isSubsetOfSet:keySet])
    {
        resultDict = [paramDict copy];
    }

    return resultDict;
}

+ (NSString*) getDescStr:(NSInteger) totalSize
{
    NSString* desc = nil;
    if (totalSize > 1024 * 1024 * 1024)
    {
        desc = [NSString stringWithFormat:@"%.4fGB",(double)totalSize / 1024.0 / 1024.0 / 1024.0];
    }
    else if(totalSize > 1024 * 1024)
    {
        desc = [NSString stringWithFormat:@"%.4fMB",(double)totalSize / 1024.0 / 1024.0];
    }
    else if(totalSize > 1024)
    {
        desc = [NSString stringWithFormat:@"%.4fKB",(double)totalSize / 1024.0];
    }
    else
    {
        desc = [NSString stringWithFormat:@"%.4fB",(double)totalSize];
    }
    
    return desc;
}

@end
