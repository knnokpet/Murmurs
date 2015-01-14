//
//  MBCreateListViewController.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/15.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBCreateListViewController.h"

@interface MBCreateListViewController ()

@end

@implementation MBCreateListViewController
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
- (void)commonConfigureModel
{
    _aoAPICenter = [[MBAOuth_TwitterAPICenter alloc] init];
    _aoAPICenter.delegate = self;
}

- (void)commonConfigureView
{
    [self commonConfigureNavigationItem];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    UINib *textFieldCell = [UINib nibWithNibName:@"MBTextFieldTableViewCell" bundle:nil];
    [self.tableView registerNib:textFieldCell forCellReuseIdentifier:textFieldCellIdentifier];
    UINib *textViewCell = [UINib nibWithNibName:@"MBTextViewTableViewCell" bundle:nil];
    [self.tableView registerNib:textViewCell forCellReuseIdentifier:textViewCellIdentifier];
    UINib *switchCell = [UINib nibWithNibName:@"MBSwitchTableViewCell" bundle:nil];
    [self.tableView registerNib:switchCell forCellReuseIdentifier:switchCellIdentifier];
    
}

- (void)commonConfigureNavigationItem
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(didPushCancelButton)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Create", nil) style:UIBarButtonItemStyleDone target:self action:@selector(didPushCreateButton)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self commonConfigureModel];
    
    self.title = NSLocalizedString(@"New List", nil);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self commonConfigureView];
    
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    if (selectedIndexPath) {
        [self.tableView deselectRowAtIndexPath:selectedIndexPath animated:animated];
    }
    
    NSNotificationCenter *nCenter = [NSNotificationCenter defaultCenter];
    [nCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [nCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    MBTextFieldTableViewCell *textFieldCell = (MBTextFieldTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    if (textFieldCell) {
        [textFieldCell.textField becomeFirstResponder];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    NSNotificationCenter *nCenter = [NSNotificationCenter defaultCenter];
    [nCenter removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [nCenter removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Instance Method
- (BOOL)checksListName:(NSString *)listName
{
    BOOL isOK = YES;
    if (25 < listName.length) {
        NSString *alertTitle = NSLocalizedString(@"Over Limit", nil);
        NSString *alertMessage = NSLocalizedString(@"List Name is ferwer than 25.", nil);
        NSString *alertOtherButtonTitle = NSLocalizedString(@"OK", nil);
        
        if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:alertOtherButtonTitle style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alertController animated:YES completion:nil];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle message:alertMessage delegate:nil cancelButtonTitle:nil otherButtonTitles:alertOtherButtonTitle, nil];
            [alert show];
        }
        
        isOK = NO;
    }
    return isOK;
}

- (void)resignInputViewsFirstResponder
{
    MBTextFieldTableViewCell *listNameCell = (MBTextFieldTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    MBTextViewTableViewCell *descriptionCell = (MBTextViewTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    [listNameCell.textField resignFirstResponder];
    [descriptionCell.placeholderTextView resignFirstResponder];
}

#pragma mark Notification
- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    CGSize keyboarSize = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGFloat duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGFloat curve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] floatValue];
    self.bottomConstraint.constant = keyboarSize.height;
    [UIView animateWithDuration:duration delay:0.0f options:curve animations:^{
        [self.view layoutIfNeeded];
    }completion:nil];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    CGFloat duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGFloat curve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] floatValue];
    self.bottomConstraint.constant = 0.0f;
    [UIView animateWithDuration:duration delay:0.0f options:curve animations:^{
        [self.view layoutIfNeeded];
    }completion:nil];
}

#pragma mark Action
- (void)didPushCancelButton
{
    if ([_delegate respondsToSelector:@selector(dismissCreateListViewController:animated:)]) {
        [_delegate dismissCreateListViewController:self animated:YES];
    }
}

#warning リストネームの添削が必要。だけど、それは API に任せようかしら 説明の添削も必要じゃん
- (void)didPushCreateButton
{
    MBTextFieldTableViewCell *listNameCell = (MBTextFieldTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    MBTextViewTableViewCell *descriptionCell = (MBTextViewTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    MBSwitchTableViewCell *switchCell = (MBSwitchTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    NSString *listName = listNameCell.textField.text;
    BOOL isOK = [self checksListName:listName];
    if (NO == isOK) {
        return;
    }
    
    NSString *description = descriptionCell.placeholderTextView.text;
    if (description.length > 100) {
        return;
    }
    BOOL isOn = switchCell.switchView.on;
    
    [self.aoAPICenter postCreateList:listName isPublic:isOn description:description];
    
    [self resignInputViewsFirstResponder];
}

#pragma mark -
#pragma markTableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 44;
    if (indexPath.section == 0 && indexPath.row == 1) {
        height = 64;
    }
    return height;
}

- (NSInteger )numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows;
    if (section == 0) {
        rows = 2;
    } else {
        rows = 1;
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell = [self.tableView dequeueReusableCellWithIdentifier:textFieldCellIdentifier];
        } else if (indexPath.row == 1) {
            cell = [self.tableView dequeueReusableCellWithIdentifier:textViewCellIdentifier];
        }
    } else if (indexPath.section == 1) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:switchCellIdentifier];
    }
    
    [self updateCell:cell atIndexpath:indexPath];
    return cell;
}

- (void)updateCell:(UITableViewCell *)cell atIndexpath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self updateTextFieldCell:(MBTextFieldTableViewCell *)cell atIndexPath:indexPath];
        } else if (indexPath.row == 1) {
            [self updateTextViewCell:(MBTextViewTableViewCell *)cell atIndexPath:indexPath];
            
        }
    } else if (indexPath.section == 1) {
        [self updateSwitchCell:cell atIndexPath:indexPath];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)updateTextFieldCell:(MBTextFieldTableViewCell  *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.row) {
        cell.textField.placeholder = NSLocalizedString(@"List Name. Fewer than 25 char.", nil);
    } else if (1 == indexPath.row) {
        cell.textField.placeholder = NSLocalizedString(@"List Detail. Ferwer than 100 char.", nil);
    }
    
}

- (void)updateTextViewCell:(MBTextViewTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.placeholderTextView.placeHolder = NSLocalizedString(@"List Detail. Ferwer than 100 char.", nil);
}

- (void)updateSwitchCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.textLabel.text = NSLocalizedString(@"Public", nil);
}

#pragma mark AOuthAPICenter Delegate
- (void)twitterAPICenter:(MBAOuth_TwitterAPICenter *)center parsedLists:(NSArray *)lists
{
    MBList *createdList = [lists firstObject];
    if (createdList) {
        if ([_delegate respondsToSelector:@selector(createListViewController:withList:)]) {
            [_delegate createListViewController:self withList:createdList];
        }
    }
    
    if ([_delegate respondsToSelector:@selector(dismissCreateListViewController:animated:)]) {
        [_delegate dismissCreateListViewController:self animated:YES];
    }
}

@end
