//
//  DownloadFileOperation.m
//  PikchaTV
//
//  Created by Tuan-Ngoc Le on 10/27/12.
//
//

#import "DownloadFileOperation.h"

@implementation DownloadFileOperation

@synthesize error = error_, connectionURL=connectionURL_, userInfo=userInfo_, fileSize=fileSize_, receivedSize=receivedSize_, filePath, delegate;

- (void)dealloc
{
    self.delegate = nil;
	if(connection_) {
        [connection_ cancel];
        connection_ = nil;
        [stream close];
		stream = nil;
    }
    connectionURL_ = nil;
    
    error_ = nil;
    
    self.filePath = nil;
}

-(id)initWithUrl:(NSURL *)aUrl saveToFilePath:(NSString *)aFilePath {
	if ((self = [super init])) {
		connectionURL_ = [aUrl copy];
		self.filePath = aFilePath;
		stream = [[NSOutputStream alloc] initToFileAtPath:aFilePath append:NO];
        
	}
	return self;
}

- (void)done:(BOOL)isSuccess
{
    if( connection_ ) {
		[connection_ cancel];
        connection_ = nil;
        
		[stream close];
		stream = nil;
        fileSize_ = 0;
    }
    
    executing_ = NO;
    finished_  = YES;
    if (isSuccess) {
        if ([self.delegate respondsToSelector:@selector(didFinishDownloadFile:)]) {
            [self.delegate didFinishDownloadFile:self.userInfo];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(didFailToDownloadFile:)]) {
            [self.delegate didFailToDownloadFile:self.userInfo];
        }
    }
}

-(void)cancelled {
	// Code for cancelled
    error_ = [[NSError alloc] initWithDomain:@"DownloadFileOperation" code:123 userInfo:nil];
    [self done:NO];
}

- (void)start
{
    // Ensure this operation is not being restarted and that it has not been cancelled
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(start)
                               withObject:nil waitUntilDone:NO];
        return;
    }
    if( finished_ || [self isCancelled] ) { [self done:NO]; return; }
    
    // From this point on, the operation is officially executing--remember, isExecuting
    // needs to be KVO compliant!
    executing_ = YES;
    
    // Create the NSURLConnection--this could have been done in init, but we delayed
    // until no in case the operation was never enqueued or was cancelled before starting
    connection_ = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:connectionURL_
                                        cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0]
                                            delegate:self];
}

#pragma mark Overrides

- (BOOL)isConcurrent {
    return YES;
}

- (BOOL)isExecuting {
    return executing_;
}

- (BOOL)isFinished {
    return finished_;
}

#pragma mark - Delegate Methods for NSURLConnection

// The connection failed
- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error
{
	if([self isCancelled]) {
        [self cancelled];
		return;
    }
	else {
		[self done:NO];
	}
}

// The connection received more data
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if([self isCancelled]) {
        [self cancelled];
		return;
    }
    // dump the data
    // Write to disk.
	int success = [stream write:[data bytes] maxLength:[data length]];
	if (success < 0) {
		error_ = [[NSError alloc] initWithDomain:@"DownloadFileOperation" code:1 userInfo:[NSDictionary
                                dictionaryWithObject:@"Error writing to disk" forKey:NSLocalizedDescriptionKey]];
        
        [self done:NO];
	}
    receivedSize_ = receivedSize_ + success;
    if ([self.delegate respondsToSelector:@selector(didReceive:inTotal:userInfo:)]) {
        [self.delegate didReceive:self.receivedSize inTotal:self.fileSize userInfo:self.userInfo];
    }
}

// Initial response
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if([self isCancelled]) {
        [self cancelled];
		return;
    }
    
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    NSInteger statusCode = [httpResponse statusCode];
    if( statusCode == 200 ) {
        receivedSize_ = 0;
        fileSize_ = [[httpResponse.allHeaderFields objectForKey:@"Content-Length"] longLongValue];
        [stream open];
    } else {
        NSString* statusError  = [NSString stringWithFormat:NSLocalizedString(@"HTTP Error: %ld", nil), statusCode];
        NSDictionary* userInfo = [NSDictionary dictionaryWithObject:statusError forKey:NSLocalizedDescriptionKey];
        error_ = [[NSError alloc] initWithDomain:@"DownloadFileOperation"
                                            code:statusCode
                                        userInfo:userInfo];
        [self done:NO];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	if([self isCancelled]) {
        [self cancelled];
    } else {
		[self done:YES];
	}
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return nil;
}

@end

@implementation DownloadFileOperationQueue

+(DownloadFileOperationQueue*)sharedQueue
{
    static DownloadFileOperationQueue *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DownloadFileOperationQueue alloc] init];
    });
    return sharedInstance;
}

@end
