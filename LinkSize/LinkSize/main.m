//
//  main.m
//  LinkSize
//
//  Created by aiijim on 16/8/27.
//  Copyright © 2016年 aiijim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LinkMapParse.h"
#import "LinkMapUtil.h"

#define BUFFER_LENGTH 1024

int main(int argc, const char * argv[])
{
    @autoreleasepool {
        
        NSDictionary* paramDict = [LinkMapUtil parseParameter:argc argv:argv];
        if( !paramDict )
        {
            [LinkMapUtil printHelp];
        }
        else
        {
            NSString* linkMapFile = [paramDict objectForKey:FILE_KEY];
            char pwd[BUFFER_LENGTH] = {0};
            getcwd(pwd, BUFFER_LENGTH);
            NSString* currentDir = [NSString stringWithFormat:@"%s",pwd];

            if (![linkMapFile isAbsolutePath])
            {
                linkMapFile = [currentDir stringByAppendingPathComponent:linkMapFile];
            }
            LinkMapParse* linkMapParse = [[LinkMapParse alloc] initWithFileName:linkMapFile];
            [linkMapParse parse];
                    
            NSString * html = [linkMapParse getFileAnalyzeLog];
            
            NSString* logFileName = [paramDict objectForKey:OUTPUT_KEY];
            if (!logFileName)
            {
                logFileName = [currentDir stringByAppendingPathComponent:@"OutLog.html"];
            }
            else
            {
                if (![logFileName isAbsolutePath])
                {
                    logFileName = [currentDir stringByAppendingPathComponent:logFileName];
                }
            }
                
            [html writeToFile:logFileName atomically:YES encoding:NSUTF8StringEncoding error:nil];

        }
    }
    return 0;
}
