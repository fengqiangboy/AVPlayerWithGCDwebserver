//
//  VideoCacheTool.m
//  WebServerDemo
//
//  Created by 广州加减信息技术有限公司 on 16/2/18.
//  Copyright © 2016年 奉强. All rights reserved.
//

#import "VideoCacheTool.h"
#import "GCDWebServer.h"
#import "GCDWebServerPrivate.h"
#import "VideoCacheFileManager.h"

#define FirstPatrFileName   @"list.m3u8"

@interface VideoCacheTool ()

@property (nonatomic, strong) GCDWebServer *webServer;

@end

@implementation VideoCacheTool

- (instancetype)init {
    if (self = [super init]) {
        [self initWebServer];
    }
    
    
    return self;
}

#pragma mark 初始化本地web服务器
- (void)initWebServer {
    
    //初始化本地web服务器
    self.webServer = [[GCDWebServer alloc] init];
    
    //添加一个get响应
    __weak typeof (self) weakSelf = self;
    [self.webServer addDefaultHandlerForMethod:@"GET" requestClass:[GCDWebServerRequest class] asyncProcessBlock:^(GCDWebServerRequest *request, GCDWebServerCompletionBlock completionBlock) {
        
        __strong typeof (weakSelf) blockSelf = weakSelf;
        
        //请求的段名
        NSString *requestPath = [request.path stringByReplacingOccurrencesOfString:@"/" withString:@""];

        //判断是否已经开始缓存了
        if ([VideoCacheFileManager videoFileIsAlreadyCache:blockSelf.videoRealUrlString]) {
            //判断该段数据是否已经缓存了
            if([VideoCacheFileManager videoFilePartIsAlreadyCache:blockSelf.videoRealUrlString filePart:requestPath]) {
                //已经缓存了，直接返回本地数据
                NSString *responseContentType = [blockSelf getReturnValueContenTypeWithPartName:requestPath];
                NSString *responseFilePathString = [VideoCacheFileManager getVideoCacheFileWithVideoRealUrl:blockSelf.videoRealUrlString filePart:requestPath];
                NSLog(@"%@", [NSThread currentThread]);
                NSData *responseData = [NSData dataWithContentsOfFile:responseFilePathString];
                
                GCDWebServerDataResponse *response = [GCDWebServerDataResponse responseWithData:responseData contentType:responseContentType];
                
                completionBlock(response);
                
                //有缓存，返回数据，结束本次
                return;
            }
        }
        
        //没有缓存
        //1、先请求数据
        NSString *videoUrlString = [NSString stringWithFormat:@"%@/%@", blockSelf.videoRealUrlString, requestPath];
        NSURL *videoUrl = [NSURL URLWithString:videoUrlString];
        NSString *responseContentType = [blockSelf getReturnValueContenTypeWithPartName:requestPath];
        
        GCDWebServerStreamedResponse *responseStreame = [GCDWebServerStreamedResponse responseWithContentType:responseContentType asyncStreamBlock:^(GCDWebServerBodyReaderCompletionBlock completionBlock) {
            
            NSData *data;

            if ([VideoCacheFileManager videoFilePartIsAlreadyCache:blockSelf.videoRealUrlString filePart:requestPath]) {
                data = [NSData data];
            }
            else {
                
                data = [NSData dataWithContentsOfURL:videoUrl];
                [VideoCacheFileManager copyCacheFileToCacheDirectoryWithData:data VideoRealUrl:blockSelf.videoRealUrlString filePart:requestPath];

            }
            
            completionBlock(data, nil);
        }];
        
        completionBlock(responseStreame);
    }];
    
    
    [self.webServer start];
        
    
    //设置服务器的本地url
    self.videoLocalUrlString = self.webServer.serverURL.relativeString;
}

- (NSString *)getUrlStringWithRealUrlString:(NSString *)realUrlString {
    
    self.videoRealUrlString = [realUrlString stringByReplacingOccurrencesOfString:@"/list.m3u8" withString:@""];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@",self.videoLocalUrlString];
    
    urlStr = [NSString stringWithFormat:@"%@%@?realUrlStr=%@", urlStr, FirstPatrFileName, realUrlString];
    
    return urlStr;
}

- (NSString *)getReturnValueContenTypeWithPartName:(NSString *)partName {
    
    //第一段文件ContenType为application/x-mpegURL
    NSString *contenTypeString = [partName isEqualToString:FirstPatrFileName] ? @"application/x-mpegURL" : @"video/MP2T";
    
    return contenTypeString;
}

- (void)stopWebSever {
    [self.webServer stop];
}

@end
