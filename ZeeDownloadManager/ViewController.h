//
//  ViewController.h
//  ZeeDownloadManager
//
//  Created by Muhammad Zeeshan on 2/3/13.
//  Copyright (c) 2013 Muhammad Zeeshan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZeeDownloadsViewController.h"

@interface ViewController : UIViewController<ZeeDownloadsViewControllerDelegate>
{
    IBOutlet UITableView *availableDownloadTableview;
    ZeeDownloadsViewController *zeeDownloadViewObj;
    NSMutableArray *urlArray;
}
-(IBAction)showManagerButtonTapped:(UIButton *)sender;

-(void)downloadButtonTapped:(UIButton *)sender;
-(void)checkForInterruptedDownload;
@end
