//
//  TNDownloadManager.h
//  PikchaTV
//
//  Created by Tuan-Ngoc Le on 10/27/12.
//
//

#import <Cordova/CDVPlugin.h>
#import "DownloadFileOperation.h"

@interface TNDownloadManager : CDVPlugin <DownloadFileOperationDelegate>

- (void)downloadFile:(CDVInvokedUrlCommand*)command;

@end
