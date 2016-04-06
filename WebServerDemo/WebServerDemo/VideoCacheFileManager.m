//
//  VideoCacheFileManager.m
//  WebServerDemo
//
//  Created by 广州加减信息技术有限公司 on 16/2/18.
//  Copyright © 2016年 奉强. All rights reserved.
//

#import "VideoCacheFileManager.h"
#import <CommonCrypto/CommonDigest.h>


@implementation VideoCacheFileManager


/**
 *  获取视频缓存文件
 *
 *  @param videoRealUrl 视频真实网络地址
 *  @param filePart     要取的视屏文件段，分段规则如下：1、videoCache.m3u8   2、video_000.ts    3、video_001.ts...
 *
 *  @return 缓存文件的路径
 */
+ (NSString *)getVideoCacheFileWithVideoRealUrl:(NSString *)videoRealUrl filePart:(NSString *)filePart {
    //获取文件夹目录路径
    NSString *retStr = [self getVideoCachePathWithVideoRealUrl:videoRealUrl];
    retStr = [retStr stringByAppendingPathComponent:filePart];
    
    return retStr;
}

/**
 *  根据视频真实路径，判断某一段是否已经下载
 *
 *  @param videoRealUrl 视频的真实路径
 *  @param filePart     视频的第几段，分段规则如下：1、videoCache.m3u8   2、video_000.ts    3、video_001.ts...
 *
 *  @return 是否存在
 */
+ (BOOL)videoFilePartIsAlreadyCache:(NSString *)videoRealUrl filePart:(NSString *)filePart{
    NSString *videPartFileCachePathStr = [self getVideoCacheFileWithVideoRealUrl:videoRealUrl filePart:filePart];
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    BOOL isFileExists = [fileManager fileExistsAtPath:videPartFileCachePathStr];
    
    return isFileExists;
}

/**
 *  根据视频真实地址，判断视频文件是否已经开始缓存（即使只缓存一个文件也返回真）
 *
 *  @param videoRealUrl 视频的真实网络地址
 *
 *  @return 是否已经缓存了
 */
+ (BOOL)videoFileIsAlreadyCache:(NSString *)videoRealUrl {
    NSString *cacheDirectoryPathString = [self getVideoCachePathWithVideoRealUrl:videoRealUrl];
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    BOOL isFileExists = [fileManager fileExistsAtPath:cacheDirectoryPathString];
    
    //如果不存在，顺便创建这个文件夹
    if (!isFileExists) {
        [fileManager createDirectoryAtPath:cacheDirectoryPathString withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return isFileExists;
}

/**
 *  获取沙盒中Liberary/cache目录路径
 *
 *  @return Liberary/cache目录路径
 */
+ (NSString *)getSandboxCacheDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDir = [paths objectAtIndex:0];
    return cachesDir;
}

/**
 *  根据视频地址，获取视频缓存文件夹
 *
 *  @param videoRealUrl 视频的网络地址
 *
 *  @return 视屏的缓存文件夹路径
 */
+ (NSString *)getVideoCachePathWithVideoRealUrl:(NSString *)videoRealUrl {
    NSString *retStr = [self getSandboxCacheDirectory];
    retStr = [retStr stringByAppendingPathComponent:@"FQVideoCache"];
    retStr = [retStr stringByAppendingPathComponent:[self md5HexDigest:videoRealUrl]];
    
    return retStr;
}


/**
 *  把下载下来的缓存文件保存到缓存文件夹
 *
 *  @param tempPath     下载下来的临时文件夹
 *  @param videoRealUrl 视频真实地址
 *  @param filePart     视频文件缓存文件段号
 *
 *  @return 是否复制成功
 */
+ (BOOL)copyCacheFileToCacheDirectoryWithData:(NSData *)data VideoRealUrl:(NSString *)videoRealUrl filePart:(NSString *)filePart{
//    NSLog(@"%@", tempPath);
    NSString *newFilePathString = [self getVideoCacheFileWithVideoRealUrl:videoRealUrl filePart:filePart];
    
//    newFilePathString = [newFilePathString stringByReplacingOccurrencesOfString:@"list.m3u8" withString:@""];
    NSURL *newFilePathUrl = [NSURL fileURLWithPath:newFilePathString];
    
    BOOL ret = [data writeToURL:newFilePathUrl atomically:YES];
    
    if (!ret) {
        NSLog(@"文件复制错误");
    }
    
    return ret;
}

/**
 *  根据传入字符串  进行MD5加密
 *
 *  @param url 要加密的字符串
 *
 *  @return 加密之后的字符串
 */
+ (NSString *)md5HexDigest:(NSString *)url
{
    const char *original_str = [url UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(original_str, strlen(original_str), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < 16; i++)
        [hash appendFormat:@"%02X", result[i]];
    return [hash lowercaseString];
}

@end
