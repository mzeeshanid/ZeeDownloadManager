//
//  ZeeDownloadsViewController.h
//  ZeeDownloadManager
//
//  Created by Muhammad Zeeshan on 2/3/13.
//  Copyright (c) 2013 Muhammad Zeeshan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"

@protocol ZeeDownloadsViewControllerDelegate <NSObject>

@optional
-(void)downloadRequestStarted:(ASIHTTPRequest *)request;
-(void)downloadRequestReceivedResponseHeaders:(ASIHTTPRequest *)request responseHeaders:(NSDictionary *)responseHeaders;
-(void)downloadRequestFinished:(ASIHTTPRequest *)request;
-(void)downloadRequestFailed:(ASIHTTPRequest *)request;
-(void)downloadRequestPaused:(ASIHTTPRequest *)request;
-(void)downloadRequestCanceled:(ASIHTTPRequest *)request;
@end

@interface ZeeDownloadsViewController : UIViewController<ASIHTTPRequestDelegate,ASIProgressDelegate>
{
    IBOutlet UITableView *zeeDownloadTableView;
    NSMutableArray *downloadingArray;
    NSOperationQueue *downloadingRequestsQueue;
    
    __unsafe_unretained id <ZeeDownloadsViewControllerDelegate> delegate;
}
-(void)initializeDownloadingArrayIfNot;
-(void)createDirectoryIfNotExistAtPath:(NSString *)path;
-(void)createTemporaryFile:(NSString *)path;
-(ASIHTTPRequest *)initializeRequestAndSetProperties:(NSString *)urlString isResuming:(BOOL)isResuming;
-(void)addDownloadRequest:(NSString *)urlString;
-(void)initializeDownloadingRequestsQueueIfNot;
-(void)updateProgressForCell:(UITableViewCell *)cell withRequest:(ASIHTTPRequest *)request;
-(void)resumeInterruptedDownloads:(NSIndexPath *)indexPath :(NSString *)urlString;
-(void)insertTableviewCellForRequest:(ASIHTTPRequest *)request;
-(float)calculateFileSizeInUnit:(unsigned long long)contentLength;
-(NSString *)calculateUnit:(unsigned long long)contentLength;
-(void)writeURLStringToFileIfNotExistForResumingPurpose:(NSString *)urlString;
-(void)removeURLStringFromInterruptedDownloadFileIfRequestCancelByTheUser:(NSString *)urlString;
-(void)removeRequest:(ASIHTTPRequest *)request :(NSIndexPath *)indexPath;
-(void)showAlertViewWithMessage:(NSString *)message;
-(void)resumeAllInterruptedDownloads;

-(IBAction)cancelButtonTapped:(UIButton *)sender;
-(IBAction)pauseButtonTapped:(UIButton *)sender;

@property (nonatomic, unsafe_unretained)id <ZeeDownloadsViewControllerDelegate> delegate;
@end
