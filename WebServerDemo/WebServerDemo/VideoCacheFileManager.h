//
//  VideoCacheFileManager.h
//  WebServerDemo
//
//  Created by 广州加减信息技术有限公司 on 16/2/18.
//  Copyright © 2016年 奉强. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VideoCacheFileManager : NSObject


+ (BOOL)videoFileIsAlreadyCache:(NSString *)videoRealUrl;

+ (NSString *)getVideoCacheFileWithVideoRealUrl:(NSString *)videoRealUrl filePart:(NSString *)filePart ;

+ (BOOL)videoFilePartIsAlreadyCache:(NSString *)videoRealUrl filePart:(NSString *)filePart;

+ (BOOL)copyCacheFileToCacheDirectoryWithData:(NSData *)data VideoRealUrl:(NSString *)videoRealUrl filePart:(NSString *)filePart;


@end
