//
//  ViewController.m
//  ZeeDownloadManager
//
//  Created by Muhammad Zeeshan on 2/3/13.
//  Copyright (c) 2013 Muhammad Zeeshan. All rights reserved.
//

#import "ViewController.h"
#import "ZeeDownloadsViewController.h"

#define fileDestination [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/Downloaded Files"]
#define interruptedDownloadsArrayFileDestination [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/InterruptedDownloadsFile/interruptedDownloads.txt"]

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.title = @"Available";
    urlArray = [NSMutableArray arrayWithObjects:
                @"http://dl.dropbox.com/u/97700329/file1.mp4",
                @"http://dl.dropbox.com/u/97700329/file2.mp4",
                @"http://dl.dropbox.com/u/97700329/file3.mp4",
                @"http://dl.dropbox.com/u/97700329/FileZilla_3.6.0.2_i686-apple-darwin9.app.tar.bz2",
                @"http://dl.dropbox.com/u/97700329/GCDExample-master.zip", nil];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        zeeDownloadViewObj = [[ZeeDownloadsViewController alloc] initWithNibName:@"ZeeDownloadsViewController" bundle:nil];
    else
        zeeDownloadViewObj = [[ZeeDownloadsViewController alloc] initWithNibName:@"ZeeDownloadsViewController_ipad" bundle:nil];
    
    [zeeDownloadViewObj setDelegate:self];
    
    [zeeDownloadViewObj resumeAllInterruptedDownloads];
    
    [self checkForInterruptedDownload];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - My IBActions -
-(IBAction)showManagerButtonTapped:(UIButton *)sender
{
    [self.navigationController pushViewController:zeeDownloadViewObj animated:YES];
}
#pragma mark - My Methods -
-(void)downloadButtonTapped:(UIButton *)sender
{
    UITableViewCell *cell = (UITableViewCell *)sender.superview;
    NSIndexPath *indexPath = [availableDownloadTableview indexPathForCell:cell];
    [zeeDownloadViewObj addDownloadRequest:[urlArray objectAtIndex:indexPath.row]];
    [urlArray removeObjectAtIndex:indexPath.row];
    [availableDownloadTableview reloadData];
}
-(void)checkForInterruptedDownload
{
    NSMutableArray *interruptedRequests = [NSMutableArray arrayWithContentsOfFile:interruptedDownloadsArrayFileDestination];
    [interruptedRequests enumerateObjectsUsingBlock:^(NSString *str, NSUInteger index, BOOL *stop){
        if([urlArray containsObject:str])
            [urlArray removeObject:str];
    }];
    [availableDownloadTableview reloadData];
}
#pragma mark - Tableview Delegate and Datasource -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return urlArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [NSString stringWithFormat:@"Cell-%d-%d-%@",indexPath.section,indexPath.row,urlArray];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == Nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        [cell.textLabel setText:[[[urlArray objectAtIndex:indexPath.row] componentsSeparatedByString:@"/"] lastObject]];
        
        UIButton *downloadButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [downloadButton setFrame:CGRectMake(230, 5, 80, 35)];
        [downloadButton setTitle:@"Download" forState:UIControlStateNormal];
        [downloadButton addTarget:self action:@selector(downloadButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:downloadButton];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
#pragma mark - ZeeDownloadsViewControllerDelegate -
-(void)downloadRequestStarted:(ASIHTTPRequest *)request
{
    NSLog(@"Request userinfo %@",request.userInfo);
}
-(void)downloadRequestReceivedResponseHeaders:(ASIHTTPRequest *)request responseHeaders:(NSDictionary *)responseHeaders
{
    NSLog(@"response Headers %@",responseHeaders);
}
-(void)downloadRequestFinished:(ASIHTTPRequest *)request
{
    NSLog(@"Request userinfo %@",request.userInfo);
}
-(void)downloadRequestFailed:(ASIHTTPRequest *)request
{
    if([request.error.localizedDescription isEqualToString:@"The request was cancelled"])
    {
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:request.error.localizedDescription delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alertView show];
    }
}
-(void)downloadRequestPaused:(ASIHTTPRequest *)request
{
    NSLog(@"Request paused %@",request.userInfo);
}
-(void)downloadRequestCanceled:(ASIHTTPRequest *)request
{
    NSLog(@"Request canceled %@",request.userInfo);
    [urlArray addObject:[request.url absoluteString]];
    [availableDownloadTableview reloadData];
}
@end
