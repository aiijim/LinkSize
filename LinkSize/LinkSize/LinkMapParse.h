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

//解析linkmap文件
- (void) parse;

//获取linkmap文件分析日志，html格式
- (NSString*) getFileAnalyzeLog;

@end
