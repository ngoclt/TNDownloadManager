//
//  DownloadFileOperation.h
//  PikchaTV
//
//  Created by Tuan-Ngoc Le on 10/27/12.
//
//

#import <Foundation/Foundation.h>

@protocol DownloadFileOperationDelegate <NSObject>

@optional
- (void)didReceive:(long)received inTotal:(long)total userInfo:(NSDictionary *)userInfo;
- (void)didFinishDownloadFile:(NSDictionary *)userInfo;
- (void)didFailToDownloadFile:(NSDictionary *)userInfo;

@end

@interface DownloadFileOperation : NSOperation {
    NSError*  error_;
    
    // In concurrent operations, we have to manage the operation's state
    BOOL executing_;
    BOOL finished_;
    
    // The actual NSURLConnection management
    NSURL* connectionURL_;
    NSURLConnection* connection_;
    NSDictionary *userInfo_;
    long receivedSize_;
    
    // To save to disk
    NSString *filePath;
    NSOutputStream *stream;
    long fileSize_;
}

@property (nonatomic,readonly) NSError* error;
@property(nonatomic, readonly) NSURL *connectionURL;
@property (nonatomic,readonly) long fileSize;
@property (nonatomic,readonly) long receivedSize;
@property(nonatomic, strong) NSString *filePath;
@property(nonatomic, strong) NSDictionary *userInfo;

@property (strong) id<DownloadFileOperationDelegate> delegate;

-(id)initWithUrl:(NSURL *)aUrl saveToFilePath:(NSString *)aFilePath;

@end


@interface DownloadFileOperationQueue : NSOperationQueue

+(DownloadFileOperationQueue*)sharedQueue;

@end

