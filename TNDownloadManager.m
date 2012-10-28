//
//  TNDownloadManager.m
//  PikchaTV
//
//  Created by Tuan-Ngoc Le on 10/27/12.
//
//

#import "TNDownloadManager.h"
#import <Cordova/JSONKit.h>

@implementation TNDownloadManager

- (void)downloadFile:(CDVInvokedUrlCommand*)command {
    NSString *urlString = [command.arguments objectAtIndex:0];
    NSString *fileName = [command.arguments objectAtIndex:1];
    NSString *destPath = [command.arguments objectAtIndex:2];
    NSDictionary *userInfo = [command.arguments objectAtIndex:3];
    
    NSFileManager *fileManager= [NSFileManager defaultManager];
    BOOL isDir;
    if(![fileManager fileExistsAtPath:destPath isDirectory:&isDir])
        if(![fileManager createDirectoryAtPath:destPath withIntermediateDirectories:YES attributes:nil error:NULL])
            NSLog(@"Error: Create folder failed %@", destPath);
    
    NSString *destFilePath = [destPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", fileName]];
    
    DownloadFileOperation *downloadFileOperation = [[DownloadFileOperation alloc] initWithUrl:[NSURL URLWithString:urlString]
                                                                               saveToFilePath:destFilePath];
    downloadFileOperation.userInfo = userInfo;
    downloadFileOperation.delegate = self;
    [[DownloadFileOperationQueue sharedQueue] addOperation:downloadFileOperation];
}

- (void)didReceive:(long)received inTotal:(long)total userInfo:(NSDictionary *)userInfo {
    NSString *js = [NSString stringWithFormat:@"plugins.tnDownloadManager.downloadingProgress(%ld, %ld, %@)", received, total, [userInfo cdvjk_JSONString]];
	[self writeJavascript: js];
}

- (void)didFinishDownloadFile:(NSDictionary *)userInfo {
    NSString *js = [NSString stringWithFormat:@"plugins.tnDownloadManager.downloadSuccessfull(%@)", [userInfo cdvjk_JSONString]];
	[self writeJavascript: js];
}

- (void)didFailToDownloadFile:(NSDictionary *)userInfo {
    NSString *js = [NSString stringWithFormat:@"plugins.tnDownloadManager.downloadFailed(%@)", [userInfo cdvjk_JSONString]];
	[self writeJavascript: js];
}


@end
