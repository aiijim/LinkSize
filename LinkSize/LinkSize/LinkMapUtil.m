//
//  LinkMapUtil.m
//  LinkSize
//
//  Created by aiijim on 16/8/27.
//  Copyright © 2016年 aiijim. All rights reserved.
//

#import "LinkMapUtil.h"

NSString* const OUTPUT_KEY = @"output";
NSString* const FILE_KEY = @"file";

@implementation LinkMapUtil

+ (void) printHelp
{
    NSLog(@"Usage: LinkSize -%@ linkmapfile [-%@ logFile] or LinkSize [-%@ logFile] -%@ linkmapfile", FILE_KEY, OUTPUT_KEY, OUTPUT_KEY, FILE_KEY);
}

+ (NSDictionary*) parseParameter:(int)argc argv:(const char* [])argv
{
    NSDictionary* resultDict = nil;
    if (argc != 3 && argc != 5)
    {
        return resultDict;
    }
    
    NSMutableDictionary* paramDict = [NSMutableDictionary dictionary];
    NSString* lastKey = nil;
    BOOL isValid = NO;
    for (int i = 1; (i + 1) < argc; i+=2)
    {
        if (*argv[i] == '-')
        {
            lastKey = [NSString stringWithCString:(argv[i] + 1) encoding:NSUTF8StringEncoding];
            NSString* value = [NSString stringWithCString:argv[i+1] encoding:NSUTF8StringEncoding];
            
            if ([lastKey isEqualToString:FILE_KEY])
            {
                [paramDict setObject:value forKey:lastKey];
                isValid = YES;
            }
            else if([lastKey isEqualToString:OUTPUT_KEY])
            {
                [paramDict setObject:value forKey:lastKey];
            }
            else
            {
                isValid = NO;
                break;
            }
        }
        else
        {
            isValid = NO;
            break;
        }
    }

    if (isValid)
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


+ (int) hexStringToInt:(NSString*)hexString
{
    int outVal;
    NSScanner* scanner = [NSScanner scannerWithString:hexString];
    [scanner scanHexInt:(unsigned int*)&outVal];
    return outVal;
}


@end
