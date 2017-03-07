//
//  LinkMapParse.m
//  LinkSize
//
//  Created by aiijim on 16/8/27.
//  Copyright © 2016年 aiijim. All rights reserved.
//

#import "LinkMapParse.h"
#import "ObjectLinkModel.h"
#import "LinkMapUtil.h"

static const char* const htmlHeader = "<html> \
                                       <head>\
                                       <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">\
                                       <title>LinkMap文件分析日志</title>\
                                       <style type=\"text/css\">\
                                       table {\
                                       width: 100%;\
                                       border-right:1px solid #490;\
                                       border-bottom:1px solid #490;\
                                       }\
                                       table td{\
                                       border-left:1px solid #490;\
                                       border-top:1px solid #490;\
                                       }\
                                       </style>\
                                       </head>\
                                       <body>\
                                       <div>\
                                       <h1>File: @BinFileName@</h1>\
                                       <h2>Arch: @Arch@</h2>\
                                       </div>";

static const char* const objectDivHeader = "<div>\
                                            <h2>Object Files:</h2> \
                                            <table>\
                                            <tr><td>文件名</td><td>大小</td><td>静态库名或Framework名</td></tr>";

static const char* const divFooter = "</table></div>";

static const char* const libDivHeader = "<div>\
                                         <h2>Library Or Framework Link Size:</h2> \
                                         <table>\
                                         <tr><td>静态库名或Framework名</td><td>大小</td></tr>";

static const char* const htmlFooter = "</body>\
                                       </html>";


#define TRIMNSSTRING(str) [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]

const static int MAXSIZE = 4096;

@interface LinkMapParse()
{
}

//解析的可执行文件名
@property (strong, nonatomic) NSString* binFileName;

//linkmap文件体系架构
@property (strong, nonatomic) NSString* arch;

//.o文件模型对象数组
@property (strong, nonatomic) NSMutableArray* objsModel;

//当前解析的section名
@property (strong, nonatomic) NSString* sectionName;

//静态库或framework在可执行文件中的链接大小
@property (strong, nonatomic) NSMutableDictionary* libraryInfo;

@end

@implementation LinkMapParse

- (instancetype) initWithFileName:(NSString*)fileName
{
    self = [super init];
    if (self) {
        self.fileName = fileName;
        _objsModel = [NSMutableArray array];
        _libraryInfo = [NSMutableDictionary dictionary];
    }
    return self;
}

//开始解析一个新的段,以#开始的行
- (void)startSection:(NSString*)txtLine
{
    NSRange range = [txtLine rangeOfString:@":"];
    if (range.length > 0)
    {
        self.sectionName = [txtLine substringWithRange:NSMakeRange(1, range.location-1)];
        self.sectionName = TRIMNSSTRING(self.sectionName);
        
        if ([self.sectionName compare:@"Path" options:NSCaseInsensitiveSearch] == NSOrderedSame)
        {
            self.binFileName = [txtLine substringFromIndex:(range.location + range.length)];
            self.binFileName = TRIMNSSTRING(self.binFileName);
        }
        else if([self.sectionName compare:@"Arch" options:NSCaseInsensitiveSearch] == NSOrderedSame)
        {
            self.arch = [txtLine substringFromIndex:(range.location + range.length)];
            self.arch = TRIMNSSTRING(self.arch);
        }
        
//        NSLog(@"%@",self.sectionName);
    }
}

//解析一行object file描述信息
- (void)parseObjectLine:(NSString*)txtLine
{
    if ([txtLine hasPrefix:@"["])
    {
        NSRange range = [txtLine rangeOfString:@"]"];
        if (range.length > 0)
        {
            ObjectLinkModel* obj = [ObjectLinkModel new];
            NSString* indexString = [txtLine substringWithRange:NSMakeRange(1, range.location-1)];
            obj.index = [TRIMNSSTRING(indexString) intValue];
            
            NSString* objFileName = [txtLine substringFromIndex:(range.location + range.length)];
            objFileName = [TRIMNSSTRING(objFileName) lastPathComponent];
            NSRange leftRange = [objFileName rangeOfString:@"("];
            NSRange rightRange = [objFileName rangeOfString:@")"];
            if (leftRange.length > 0 && rightRange.length > 0)
            {
                obj.libName = [objFileName substringToIndex:leftRange.location];
                obj.objName = [objFileName substringWithRange:NSMakeRange(leftRange.location+leftRange.length, rightRange.location-leftRange.location-1)];
            }
            else
            {
                obj.objName = objFileName;
            }
            
//            NSLog(@"File:%@, Lib:%@, index:%zd",obj.objName,obj.libName,obj.index);
            [self.objsModel addObject:obj];
        }
    }
    
}

//解析一行符号描述信息
- (void)parseSymbolLine:(NSString*)txtLine
{
    if([txtLine hasPrefix:@"0x"])
    {
        NSRange leftRange = [txtLine rangeOfString:@"["];
        NSRange rightRange = [txtLine rangeOfString:@"]"];
        NSString* indexString = [txtLine substringWithRange:NSMakeRange(leftRange.location+leftRange.length, rightRange.location-leftRange.location-1)];
        NSInteger index = [TRIMNSSTRING(indexString) intValue];
        
        ObjectLinkModel* obj = (index < [self.objsModel count] ? [self.objsModel objectAtIndex:index] : nil);
        if (obj.index == index)
        {
            NSString* numString = [txtLine substringToIndex:(leftRange.location-1)];
            NSString* sizeString = [[TRIMNSSTRING(numString) componentsSeparatedByString:@"\t"] lastObject];
            
            NSString* symbolString = [txtLine substringFromIndex:(rightRange.location+rightRange.length)];
            symbolString = TRIMNSSTRING(symbolString);
            int size = [LinkMapUtil hexStringToInt:sizeString];
            [obj insertSymbols:symbolString size:size];
            
//            NSLog(@"symbol:%@, size:%zd,index:%zd",symbolString,size,index);
        }
        else
        {
//            NSLog(@"error!");
        }
    }
    
}

- (void)parseSection:(NSString*)txtLine
{
    if ([self.sectionName compare:@"Object files" options:NSCaseInsensitiveSearch] == NSOrderedSame)
    {
        //object file list
        [self parseObjectLine:txtLine];
    }
    else if([self.sectionName compare:@"Symbols" options:NSCaseInsensitiveSearch] == NSOrderedSame)
    {
        //symbol list
        [self parseSymbolLine:txtLine];
    }
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
            [self startSection:lineStr];
        }
        else
        {
            [self parseSection:lineStr];
        }
    }
    
    fclose(pFile);
}

- (NSString*) getFileAnalyzeLog
{
    NSString* html = [NSString stringWithCString:htmlHeader encoding:NSUTF8StringEncoding];
    
    if (self.binFileName)
    {
        html = [html stringByReplacingOccurrencesOfString:@"@BinFileName@" withString:self.binFileName];
    }
    
    if (self.arch)
    {
        html = [html stringByReplacingOccurrencesOfString:@"@Arch@" withString:self.arch];
    }
    
    NSString* objDiv = [NSString stringWithCString:objectDivHeader encoding:NSUTF8StringEncoding];
    
    for (ObjectLinkModel* obj in self.objsModel)
    {
        NSInteger fileSize = [obj getTotalSize];
        if (obj.libName)
        {
            NSArray* libs = [self.libraryInfo allKeys];
            if ([libs containsObject:obj.libName])
            {
                NSInteger size = [[self.libraryInfo objectForKey:obj.libName] integerValue];
                size += fileSize;
                [self.libraryInfo setObject:[NSNumber numberWithInteger:size] forKey:obj.libName];
            }
            else
            {
                [self.libraryInfo setObject:[NSNumber numberWithInteger:fileSize] forKey:obj.libName];
            }
            
        }
        
        objDiv = [objDiv stringByAppendingFormat:@"<tr><td>%@</td><td>%@</td><td>%@</td></tr>",obj.objName,[LinkMapUtil getDescStr:fileSize], obj.libName];
    }
    
    NSString* libDiv = [NSString stringWithCString:libDivHeader encoding:NSUTF8StringEncoding];
    NSArray* libKeys = [self.libraryInfo allKeys];
    for (NSString* libName in libKeys)
    {
        NSInteger size = [[self.libraryInfo objectForKey:libName] integerValue];
        libDiv = [libDiv stringByAppendingFormat:@"<tr><td>%@</td><td>%@</td></tr>",libName,[LinkMapUtil getDescStr:size]];
    }
    
    html = [html stringByAppendingFormat:@"%@%s",libDiv,divFooter];
    
    html = [html stringByAppendingFormat:@"%@%s",objDiv,divFooter];
    
    html = [html stringByAppendingFormat:@"%s",htmlFooter];
    
    return html;
}

@end
