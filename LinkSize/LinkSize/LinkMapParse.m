//
//  LinkMapParse.m
//  LinkSize
//
//  Created by aiijim on 16/8/27.
//  Copyright © 2016年 aiijim. All rights reserved.
//

#import "LinkMapParse.h"

const static int MAXSIZE = 1024;

@interface LinkMapParse()
{
    NSMutableDictionary* fileNumDic;    //库包含的文件编号字典
    NSMutableDictionary* fileSizeDic;   //文件大小字典
}

@end

@implementation LinkMapParse

- (instancetype) initWithFileName:(NSString*)fileName
{
    self = [super init];
    if (self) {
        self.fileName = fileName;
        fileNumDic = [NSMutableDictionary dictionary];
        fileSizeDic = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSScanner*)getIntegerScanner:(NSString*)lineStr
{
    NSScanner* scanner = [NSScanner scannerWithString:lineStr];
    NSMutableCharacterSet* charactersToBeSkipped = [NSMutableCharacterSet whitespaceCharacterSet];
    [charactersToBeSkipped addCharactersInString:@"[]"];
    scanner.charactersToBeSkipped = charactersToBeSkipped;
    return scanner;
}

- (void) parse
{
    FILE* pFile = fopen([self.fileName UTF8String], "r");
    if(pFile == NULL)
        return;
    
    char buffer[MAXSIZE] = {0};
    while(fgets(buffer, MAXSIZE, pFile))
    {
        NSString* lineStr = [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
        if ([lineStr hasPrefix:@"#"])
        {
            continue;
        }
        else if([lineStr hasPrefix:@"["])
        {
            //object files
            NSScanner* scanner = [self getIntegerScanner:lineStr];
            NSInteger fileNo = 0;
            [scanner scanInteger:&fileNo];
            
            NSRange range = [lineStr rangeOfString:@"]"];
            NSString* filePath = [[lineStr substringFromIndex:range.location+range.length] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString* fileName = [filePath lastPathComponent];
            
            if ([fileName containsString:@"("])
            {
                NSRange rng = [fileName rangeOfString:@"("];
                NSString* libName = [fileName substringToIndex:rng.location];
                NSMutableArray* libNumArr = [fileNumDic objectForKey:libName];
                if(!libNumArr)
                {
                    libNumArr = [NSMutableArray array];
                    [fileNumDic setObject:libNumArr forKey:libName];
                }
                [libNumArr addObject:@(fileNo)];
            }
        }
        else if([lineStr hasPrefix:@"0x"])
        {
            //symbols
            const char* ptr = [lineStr UTF8String];
            
            char* temp = strstr(ptr, "\t");
            if (temp == NULL)
                continue;
            
            char* pSizeStr = strstr(temp+1, "\t");
            if (pSizeStr == NULL)
                continue;

            NSString* sizeStr = [lineStr substringWithRange:NSMakeRange(temp-ptr+1, pSizeStr-temp-1)];
            if (*(pSizeStr+1) != '[')
            {
                continue;
            }
            
            NSScanner* scanner = [self getIntegerScanner:[NSString stringWithCString:pSizeStr+1 encoding:NSUTF8StringEncoding]];
            NSInteger fileNo = 0;
            [scanner scanInteger:&fileNo];
            NSInteger size = strtol([sizeStr UTF8String], NULL, 16);
            NSNumber* fileSize = [fileSizeDic objectForKey:[NSString stringWithFormat:@"%zd",fileNo]];
            [fileSizeDic setObject:@([fileSize integerValue] + size) forKey:[NSString stringWithFormat:@"%zd",fileNo]];
        }
    }
    
    fclose(pFile);
}

- (NSArray*) getAllLibraryName
{
    return [fileNumDic allKeys];
}

- (NSInteger) getLibrarySizeInApp:(NSString*)libName
{
    NSArray* fileArr = [fileNumDic objectForKey:libName];
    if ([fileArr count] <= 0)
    {
        return 0;
    }
    
    NSInteger totalSize = 0;
    for (NSNumber* fileNo in fileArr)
    {
        NSNumber* size = [fileSizeDic objectForKey:[NSString stringWithFormat:@"%@",fileNo]];
        totalSize += [size integerValue];
    }
    return totalSize;
}

@end
