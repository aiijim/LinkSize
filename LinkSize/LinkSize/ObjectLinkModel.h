//
//  ObjectLinkModel.h
//  LinkSize
//
//  Created by aiijim on 2017/2/15.
//  Copyright © 2017年 aiijim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ObjectLinkModel : NSObject

//.o文件名
@property (strong, nonatomic) NSString* objName;

//.o所属的静态库名或framework名
@property (strong, nonatomic) NSString* libName;

//.o文件在二进制中的编号
@property (assign, nonatomic) NSInteger index;

//.o文件中的符号信息
@property (strong, nonatomic, readonly) NSDictionary* symbols;

//添加.o里的符号大小
- (void)insertSymbols:(NSString*)symbol size:(int)size;

//获取.o文件在最终的可执行文件中占的大小
- (NSInteger) getTotalSize;

@end
