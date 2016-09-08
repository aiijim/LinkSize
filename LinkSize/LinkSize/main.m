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
            NSArray* libsArr = [paramDict objectForKey:LIB_KEY];
            for (NSString*  lib in libsArr)
            {
                NSInteger totalSize = 0;
                NSInteger index = 0;
                while (index < [[paramDict objectForKey:FILE_KEY] count])
                {
                    NSString* fileName = [(NSArray*)[paramDict objectForKey:FILE_KEY] objectAtIndex:index];
                    LinkMapParse* linkMapParse = [[LinkMapParse alloc] initWithFileName:fileName];
                    [linkMapParse parse];
                    NSInteger size = [linkMapParse getLibrarySizeInApp:lib];
                    totalSize += size;
                    index++;

                }
                NSLog(@"(%@)Lib size in App::---- %@",lib,[LinkMapUtil getDescStr:totalSize]);
            }
        }
    }
    return 0;
}
