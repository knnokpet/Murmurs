//
//  MBSecondViewController.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/25.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBSecondViewController.h"
#import "MBAccountManager.h"
#import "MBAccount.h"

@interface MBSecondViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) NSMutableArray *hogeDataSource;

@end

@implementation MBSecondViewController

#pragma mark -
#pragma mark Initialize
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark -
#pragma mark View
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    
    self.hogeDataSource = [NSMutableArray array];
    
    for (int i = 0; i < 100; i++) {
        NSNumber *number = [NSNumber numberWithInt:i];
        [self.hogeDataSource addObject:number];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = [[MBAccountManager sharedInstance] currentAccount].screenName;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark UITableView DataSource & Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.hogeDataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    [self updateCell:cell AtIndexPath:indexPath];
    
    return cell;
}

- (void)updateCell:(UITableViewCell *)cell AtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *numbmer = [self.hogeDataSource objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", [numbmer stringValue]];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
