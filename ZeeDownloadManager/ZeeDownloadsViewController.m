//
//  ZeeDownloadsViewController.m
//  ZeeDownloadManager
//
//  Created by Muhammad Zeeshan on 2/3/13.
//
//  Copyright (c) 2013 Muhammad Zeeshan. All rights reserved.
//

#import "ZeeDownloadsViewController.h"

@interface ZeeDownloadsViewController ()

@end

#define fontNameUsed @"Helvetica"
#define fontSizeUsed 13.0f
#define textColorOfLabels [UIColor darkGrayColor]
#define temporaryFileDestination [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/Temporary Files"]
#define fileDestination [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/Downloaded Files"]
#define interruptedDownloadsArrayFileDestination [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/InterruptedDownloadsFile/interruptedDownloads.txt"]
#define keyForTitle @"fileTitle"
#define keyForFileHandler @"filehandler"
#define keyForTimeInterval @"timeInterval"
#define keyForTotalFileSize @"totalfilesize"
#define keyForFileSizeInUnits @"fileSizeInUnits"
#define keyForRemainingFileSize @"remainigFileSize"

@implementation ZeeDownloadsViewController
@synthesize delegate;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
        [self initializeDownloadingArrayIfNot];
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Downloads";
}
-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc
{
}
#pragma mark - Tableview delegate and dateasource -
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(downloadingArray.count == 0)
        return 1;
    else
        return downloadingArray.count;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"Downloading"];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [NSString stringWithFormat:@"Cell"];
    if(downloadingArray.count != 0)
        cellIdentifier = [NSString stringWithFormat:@"Cell-%d-%d%@",indexPath.section,indexPath.row,[[NSProcessInfo processInfo] globallyUniqueString]];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == NULL)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if(downloadingArray.count == 0)
        {
            cell.textLabel.textAlignment = UITextAlignmentCenter;
            cell.textLabel.text = @"No downloads";
        }
        else
        {
            UILabel *titleLabel;
            if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 5, 207, 30)];
            else
                titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, 207, 30)];
            [titleLabel setTag:100];
            [titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:17.0f]];
            [titleLabel setBackgroundColor:[UIColor clearColor]];
            [titleLabel setText:@"File Title: Downloading..."];
            [cell addSubview:titleLabel];
            
            UILabel *detailLabel;
            if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 35, 207, 70)];
            else
                detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 35, 207, 70)];
            [detailLabel setTag:101];
            [detailLabel setFont:[UIFont fontWithName:fontNameUsed size:fontSizeUsed]];
            [detailLabel setBackgroundColor:[UIColor clearColor]];
            [detailLabel setNumberOfLines:4];
            [detailLabel setTextColor:textColorOfLabels];
            [detailLabel setText:@"File Size: Calculating...\nDownloaded: Calculating...\nSpeed: Calculating...\nTime Left: Calculating..."];
            [cell addSubview:detailLabel];
            
            UIProgressView *progressView;
            if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(60, 115, 280, 9)];
            else
                progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(20, 115, 280, 9)];
            [progressView setTag:105];
            [progressView setProgress:0.0f];
            [cell addSubview:progressView];
            
            UIButton *pauseResumeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                [pauseResumeButton setFrame:CGRectMake(270, 10, 70, 37)];
            else
                [pauseResumeButton setFrame:CGRectMake(230, 10, 70, 37)];
            /*[pauseResumeButton setFrame:CGRectMake(230, 7, 36, 36)];*/
            [pauseResumeButton setTitle:@"Pause" forState:UIControlStateNormal];
            [pauseResumeButton setTag:1000];
            [pauseResumeButton addTarget:self action:@selector(pauseButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:pauseResumeButton];
            
            UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                [cancelButton setFrame:CGRectMake(270, 70, 70, 37)];
            else
                [cancelButton setFrame:CGRectMake(230, 70, 70, 37)];
            /*[cancelButton setFrame:CGRectMake(268, 7, 36, 36)];*/
            [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
            [cancelButton addTarget:self action:@selector(cancelButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:cancelButton];
            
            /*UIImageView *image = [[UIImageView alloc] init];
             [image setFrame:CGRectMake(235, 45, 65, 65)];
             [image setBackgroundColor:[UIColor orangeColor]];
             [cell addSubview:image];*/
        }
    }
    if(downloadingArray.count != 0)
        [self updateProgressForCell:cell withRequest:[downloadingArray objectAtIndex:indexPath.row]];
    return cell;
}
#pragma mark - My Methods -
-(void)initializeDownloadingArrayIfNot
{
    if(!downloadingArray)
        downloadingArray = [[NSMutableArray alloc] init];
}
-(void)createDirectoryIfNotExistAtPath:(NSString *)path
{
    NSLog(@"Directory path %@",path);
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:path])
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:&error];
    if(error)
        NSLog(@"Error while creating directory %@",[error localizedDescription]);
}
-(void)createTemporaryFile:(NSString *)path
{
    NSLog(@"Directory path %@",path);
    if(![[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        BOOL success = [[NSFileManager defaultManager] createFileAtPath:path contents:Nil attributes:Nil];
        if(!success)
            NSLog(@"Failed to create file");
        else {
            NSLog(@"success");
        }
    }
}
-(ASIHTTPRequest *)initializeRequestAndSetProperties:(NSString *)urlString isResuming:(BOOL)isResuming
{
    NSURL *url = [NSURL URLWithString:urlString];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
    
    [request setDelegate:self];
    [request setDownloadProgressDelegate:self];
    [request setAllowResumeForFileDownloads:YES];
    [request setShouldContinueWhenAppEntersBackground:YES];
    [request setNumberOfTimesToRetryOnTimeout:2];
    [request setTimeOutSeconds:20.0];
    if(!request.userInfo)
        request.userInfo = [[NSMutableDictionary alloc] init];
    NSString *fileName = [request.userInfo objectForKey:keyForTitle];
    if(!fileName)
    {
        fileName = [request.url.absoluteString lastPathComponent];
        [request.userInfo setValue:fileName forKey:keyForTitle];
    }
    NSString *temporaryDestinationPath = [NSString stringWithFormat:@"%@/%@.download",temporaryFileDestination,fileName];
    [request setTemporaryFileDownloadPath:temporaryDestinationPath];
    if(!isResuming)
        [self createTemporaryFile:request.temporaryFileDownloadPath];
    
    [request setDownloadDestinationPath:[NSString stringWithFormat:@"%@/%@",fileDestination,fileName]];
    [request setDidFinishSelector:@selector(requestDone:)];
    [request setDidFailSelector:@selector(requestWentWrong:)];
    [self initializeDownloadingRequestsQueueIfNot];
    return request;
}
-(void)addDownloadRequest:(NSString *)urlString
{
    [self initializeDownloadingArrayIfNot];
    [self createDirectoryIfNotExistAtPath:temporaryFileDestination];
    [self createDirectoryIfNotExistAtPath:fileDestination];
    
    [self createDirectoryIfNotExistAtPath:[interruptedDownloadsArrayFileDestination stringByDeletingLastPathComponent]];
    [self createTemporaryFile:interruptedDownloadsArrayFileDestination];
    [self writeURLStringToFileIfNotExistForResumingPurpose:urlString];
    
    [self insertTableviewCellForRequest:[self initializeRequestAndSetProperties:urlString isResuming:NO]];
}
-(void)initializeDownloadingRequestsQueueIfNot
{
    if(!downloadingRequestsQueue)
        downloadingRequestsQueue = [[NSOperationQueue alloc] init];
}
-(void)updateProgressForCell:(UITableViewCell *)cell withRequest:(ASIHTTPRequest *)request
{
    NSFileHandle *fileHandle = [request.userInfo objectForKey:keyForFileHandler];
    if(fileHandle)
    {
        unsigned long long partialContentLength = [fileHandle offsetInFile];
        unsigned long long totalContentLenght = [[request.userInfo objectForKey:keyForTotalFileSize] unsignedLongLongValue];
        unsigned long long remainingContentLength = totalContentLenght - partialContentLength;
        
        NSTimeInterval downloadTime = -1 * [[request.userInfo objectForKey:keyForTimeInterval] timeIntervalSinceNow];
        
        float speed = (partialContentLength - (totalContentLenght - [[request.userInfo objectForKey:keyForRemainingFileSize] unsignedLongLongValue])) / downloadTime;
        
        int remainingTime = (int)(remainingContentLength / speed);
		int hours = remainingTime / 3600;
		int minutes = (remainingTime - hours * 3600) / 60;
		int seconds = remainingTime - hours * 3600 - minutes * 60;
        
        NSString *remainingTimeStr = [NSString stringWithFormat:@""];
        
        if(hours>0)
            remainingTimeStr = [remainingTimeStr stringByAppendingFormat:@"%d Hours ",hours];
        if(minutes>0)
            remainingTimeStr = [remainingTimeStr stringByAppendingFormat:@"%d Min ",minutes];
        if(seconds>0)
            remainingTimeStr = [remainingTimeStr stringByAppendingFormat:@"%d sec",seconds];
        
        float percentComplete = (float)partialContentLength/totalContentLenght*100;
        float progressForProgressView = percentComplete / 100;
        
        [cell.subviews enumerateObjectsUsingBlock:^(UIView *cellSubView, NSUInteger index, BOOL *stop){
            if(cellSubView.tag >= 100)
            {
                if(cellSubView.tag == 100)
                {
                    UILabel *titleLabel = (UILabel *)cellSubView;
                    [titleLabel setText:[NSString stringWithFormat:@"File Title: %@",[request.userInfo objectForKey:keyForTitle]]];
                }
                else if(cellSubView.tag == 101)
                {
                    NSString *fileSizeInUnits = [request.userInfo objectForKey:keyForFileSizeInUnits];
                    if(!fileSizeInUnits)
                    {
                        fileSizeInUnits = [NSString stringWithFormat:@"%.2f %@",
                                           [self calculateFileSizeInUnit:totalContentLenght],
                                           [self calculateUnit:totalContentLenght]];
                        [request.userInfo setValue:fileSizeInUnits forKey:keyForFileSizeInUnits];
                    }
                    NSString *detailLabelText = [NSString stringWithFormat:@"File Size: %@\nDownloaded: %.2f %@ (%.2f%%)\nSpeed: %.2f %@/sec\n",fileSizeInUnits,
                                                 [self calculateFileSizeInUnit:partialContentLength],
                                                 [self calculateUnit:partialContentLength],percentComplete,
                                                 [self calculateFileSizeInUnit:(unsigned long long) speed],
                                                 [self calculateUnit:(unsigned long long)speed]
                                                 ];
                    if(progressForProgressView == 1.0)
                        detailLabelText = [detailLabelText stringByAppendingFormat:@"Plz wait, copying file"];
                    else
                        detailLabelText = [detailLabelText stringByAppendingFormat:@"Time Left: %@",remainingTimeStr];
                    UILabel *detailedLabel = (UILabel *)cellSubView;
                    [detailedLabel setText:detailLabelText];
                }
                else if(cellSubView.tag == 105)
                {
                    UIProgressView *progressView = (UIProgressView *)cellSubView;
                    progressView.progress = progressForProgressView;
                }
            }
        }];
    }
}
-(void)resumeInterruptedDownloads:(NSIndexPath *)indexPath :(NSString *)urlString
{
    ASIHTTPRequest *request = [self initializeRequestAndSetProperties:urlString isResuming:YES];
    unsigned long long size = [[[NSFileManager defaultManager] attributesOfItemAtPath:request.temporaryFileDownloadPath error:Nil] fileSize];
    if(size != 0)
    {
        NSString* range = @"bytes=";
        range = [range stringByAppendingString:[[NSNumber numberWithInt:size] stringValue]];
        range = [range stringByAppendingString:@"-"];
        [request addRequestHeader:@"Range" value:range];
    }
    if(indexPath)
    {
        [downloadingArray replaceObjectAtIndex:indexPath.row withObject:request];
        [downloadingRequestsQueue addOperation:request];
    }
    else
        [self insertTableviewCellForRequest:request];
}
-(void)insertTableviewCellForRequest:(ASIHTTPRequest *)request
{
    if(downloadingArray.count == 0)
    {
        [downloadingArray addObject:request];
        [downloadingRequestsQueue addOperation:request];
        [zeeDownloadTableView reloadData];
    }
    else
    {
        [downloadingArray addObject:request];
        [downloadingRequestsQueue addOperation:request];
        [zeeDownloadTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:downloadingArray.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}
-(float)calculateFileSizeInUnit:(unsigned long long)contentLength
{
    if(contentLength >= pow(1024, 3))
        return (float) (contentLength / pow(1024, 3));
    else if(contentLength >= pow(1024, 2))
        return (float) (contentLength / pow(1024, 2));
    else if(contentLength >= 1024)
        return (float) (contentLength / 1024);
    else
        return (float) (contentLength);
}
-(NSString *)calculateUnit:(unsigned long long)contentLength
{
    if(contentLength >= pow(1024, 3))
        return @"GB";
    else if(contentLength >= pow(1024, 2))
        return @"MB";
    else if(contentLength >= 1024)
        return @"KB";
    else
        return @"Bytes";
}
-(void)writeURLStringToFileIfNotExistForResumingPurpose:(NSString *)urlString
{
    NSMutableArray *interruptedDownloads = [NSMutableArray arrayWithContentsOfFile:interruptedDownloadsArrayFileDestination];
    if(!interruptedDownloads)
        interruptedDownloads = [[NSMutableArray alloc] init];
    if(![interruptedDownloads containsObject:urlString])
    {
        [interruptedDownloads addObject:urlString];
        [interruptedDownloads writeToFile:interruptedDownloadsArrayFileDestination atomically:YES];
    }
}
-(void)removeURLStringFromInterruptedDownloadFileIfRequestCancelByTheUser:(NSString *)urlString
{
    NSMutableArray *interruptedDownloads = [NSMutableArray arrayWithContentsOfFile:interruptedDownloadsArrayFileDestination];
    [interruptedDownloads removeObject:urlString];
    [interruptedDownloads writeToFile:interruptedDownloadsArrayFileDestination atomically:YES];
}
-(void)removeRequest:(ASIHTTPRequest *)request :(NSIndexPath *)indexPath
{
    
    [downloadingArray removeObject:request];
    if(downloadingArray.count == 0)
        [zeeDownloadTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    else
        [zeeDownloadTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}
-(void)showAlertViewWithMessage:(NSString *)message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [alertView show];
}
-(void)resumeAllInterruptedDownloads
{
    [self initializeDownloadingArrayIfNot];
    NSMutableArray *tempArray = [NSMutableArray arrayWithContentsOfFile:interruptedDownloadsArrayFileDestination];
    for(int i=0;i<tempArray.count;i++)
        [self resumeInterruptedDownloads:nil :[tempArray objectAtIndex:i]];
}
#pragma mark - My IBActions -
-(IBAction)cancelButtonTapped:(UIButton *)sender
{
    UITableViewCell *cell = (UITableViewCell *)[sender superview];
    NSIndexPath *indexPath = [zeeDownloadTableView indexPathForCell:cell];
    [self removeURLStringFromInterruptedDownloadFileIfRequestCancelByTheUser:[[[downloadingArray objectAtIndex:indexPath.row]url]absoluteString]];
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath:[[downloadingArray objectAtIndex:indexPath.row] temporaryFileDownloadPath] error:&error];
    if(error)
        NSLog(@"Error while deleting filehandle %@",error);
    
    if([self.delegate respondsToSelector:@selector(downloadRequestCanceled:)])
        [self.delegate downloadRequestCanceled:[downloadingArray objectAtIndex:indexPath.row]];
    [[downloadingArray objectAtIndex:indexPath.row] cancel];
    [self removeRequest:[downloadingArray objectAtIndex:indexPath.row] :indexPath];
}
-(IBAction)pauseButtonTapped:(UIButton *)sender
{
    UITableViewCell *cell = (UITableViewCell *)[sender superview];
    NSIndexPath *indexPath = [zeeDownloadTableView indexPathForCell:cell];
    if([[sender titleForState:UIControlStateNormal] isEqualToString:@"Pause"])
    {
        [sender setTitle:@"Resume" forState:UIControlStateNormal];
        if([self.delegate respondsToSelector:@selector(downloadRequestPaused:)])
            [self.delegate downloadRequestPaused:[downloadingArray objectAtIndex:indexPath.row]];
        [[downloadingArray objectAtIndex:indexPath.row] cancel];
    }
    else
    {
        [sender setTitle:@"Pause" forState:UIControlStateNormal];
        [self resumeInterruptedDownloads:indexPath :[[[downloadingArray objectAtIndex:indexPath.row]url]absoluteString]];
    }
}
#pragma mark - ASIHTTPRequest Delegate -
-(void)requestStarted:(ASIHTTPRequest *)request
{
    if([self.delegate respondsToSelector:@selector(downloadRequestStarted:)])
        [self.delegate downloadRequestStarted:request];
}
-(void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders
{
    [downloadingArray enumerateObjectsUsingBlock:^(ASIHTTPRequest *req, NSUInteger index, BOOL *stop){
        if([req isEqual:request])
        {
            NSFileHandle *fileHandle = [req.userInfo objectForKey:keyForFileHandler];
            if(!fileHandle)
            {
                if(![req requestHeaders])
                {
                    fileHandle = [NSFileHandle fileHandleForWritingAtPath:req.temporaryFileDownloadPath];
                    [req.userInfo setValue:fileHandle forKey:keyForFileHandler];
                }
            }
            long long length = [[req.userInfo objectForKey:keyForTotalFileSize] longLongValue];
            if(length == 0)
            {
                length = [req contentLength];
                if (length != NSURLResponseUnknownLength)
                {
                    NSNumber *totalSize = [NSNumber numberWithUnsignedLongLong:(unsigned long long)length];
                    [req.userInfo setValue:totalSize forKey:keyForTotalFileSize];
                }
                [req.userInfo setValue:[NSDate date] forKey:keyForTimeInterval];
            }
            if([request requestHeaders])
            {
                NSString *range = [[request requestHeaders] objectForKey:@"Range"];
                NSString *numbers = [range stringByTrimmingCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
                unsigned long long size = [numbers longLongValue];
                
                if(length != 0)
                {
                    [req.userInfo setValue:[NSNumber numberWithUnsignedLongLong:length] forKey:keyForRemainingFileSize];
                    length = length + size;
                    NSNumber *totalSize = [NSNumber numberWithUnsignedLongLong:(unsigned long long)length];
                    [req.userInfo setValue:totalSize forKey:keyForTotalFileSize];
                    
                    
                    fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:req.temporaryFileDownloadPath];
                    [req.userInfo setValue:fileHandle forKey:keyForFileHandler];
                    [fileHandle seekToFileOffset:size];
                }
            }
            [self updateProgressForCell:[zeeDownloadTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]] withRequest:req];
            if([self.delegate respondsToSelector:@selector(downloadRequestReceivedResponseHeaders:responseHeaders:)])
                [self.delegate downloadRequestReceivedResponseHeaders:request responseHeaders:responseHeaders];
            *stop = YES;
        }
    }];
}
-(void)request:(ASIHTTPRequest *)request didReceiveData:(NSData *)data
{
    [downloadingArray enumerateObjectsUsingBlock:^(ASIHTTPRequest *req, NSUInteger index, BOOL *stop){
        if([req isEqual:request])
        {
            NSFileHandle *fileHandle = [req.userInfo objectForKey:keyForFileHandler];
			[fileHandle writeData:data];
            
            [self updateProgressForCell:[zeeDownloadTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]] withRequest:req];
            *stop = YES;
        }
    }];
}
-(void)requestDone:(ASIHTTPRequest *)request
{
    [self removeURLStringFromInterruptedDownloadFileIfRequestCancelByTheUser:request.url.absoluteString];
    [self removeRequest:request :[NSIndexPath indexPathForRow:[downloadingArray indexOfObject:request] inSection:0]];
    if([self.delegate respondsToSelector:@selector(downloadRequestFinished:)])
        [self.delegate downloadRequestFinished:request];
}
- (void)requestWentWrong:(ASIHTTPRequest *)request
{
    if([request.error.localizedDescription isEqualToString:@"The request was cancelled"])
    {
        
    }
    else
    {
        [self showAlertViewWithMessage:request.error.localizedDescription];
        UITableViewCell *cell = [zeeDownloadTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[downloadingArray indexOfObject:request] inSection:0]];
        [cell.subviews enumerateObjectsUsingBlock:^(UIView *cellSubview, NSUInteger index, BOOL *stop){
            if(cellSubview.tag == 1000)
            {
                UIButton *pauseButton = (UIButton *)cellSubview;
                [pauseButton setTitle:@"Retry" forState:UIControlStateNormal];
                *stop = YES;
            }
        }];
    }
    if([self.delegate respondsToSelector:@selector(downloadRequestFailed:)])
        [self.delegate downloadRequestFailed:request];
}
@end
