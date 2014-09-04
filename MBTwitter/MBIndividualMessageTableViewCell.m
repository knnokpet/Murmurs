//
//  MBIndividualMessageTableViewCell.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/09/02.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBIndividualMessageTableViewCell.h"

#import "MBTweetTextView.h"
#import "MBAvatorImageView.h"
#import "MBMessageView.h"

@interface MBIndividualMessageTableViewCell()
{
    CGFloat maxEdgeSpace;
    CGFloat edgeSpaceToPop;
    CGFloat imageViewSpace;
    CGFloat tweetTextViewSpace;
    CGFloat tweetTextViewSpaceFromPop;
}

@end

@implementation MBIndividualMessageTableViewCell
#pragma mark - Initialize
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self commonInit];
        _tweetTextView = [[MBTweetTextView alloc] init];
        self.tweetTextView.backgroundColor = [UIColor clearColor];
        
        _avatorImageView = [[MBAvatorImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        _messageView = [[MBMessageView alloc] initWithFrame:CGRectZero];
        _dateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.dateLabel setFont:[UIFont systemFontOfSize:10.0f]];
        [self.dateLabel setTextColor:[UIColor lightGrayColor]];
        [self.dateLabel setBaselineAdjustment:UIBaselineAdjustmentAlignBaselines];
        
        [self.messageView addSubview:self.tweetTextView];
        [self.contentView addSubview:self.messageView];
        [self.contentView addSubview:self.avatorImageView];
        [self.contentView addSubview:self.dateLabel];
        
        imageViewSpace = 10.0f;
        maxEdgeSpace = 60.0f;
        edgeSpaceToPop = self.avatorImageView.frame.size.width + imageViewSpace * 2;
        tweetTextViewSpace = 12.0f;
        tweetTextViewSpaceFromPop = 18.0f;
        _maxTweetTextViewWidth = self.contentView.bounds.size.width - (edgeSpaceToPop + maxEdgeSpace) - (tweetTextViewSpace + tweetTextViewSpaceFromPop);
    }
    
    return self;
}

- (void)awakeFromNib {
    // Initialization code
    [self commonInit];
}

- (void)commonInit
{
    self.backgroundColor = [UIColor clearColor];
}

#pragma mark - Accessor
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setDateString:(NSString *)dateString
{
    _dateString = dateString;
    self.dateLabel.text = dateString;
    [self setNeedsLayout];
}

- (void)setTweetViewRect:(CGRect)tweetViewRect
{
    _tweetViewRect = tweetViewRect;
    [self setNeedsLayout];
}

- (void)setPopsFromRight:(BOOL)popsFromRight
{
    _popsFromRight = popsFromRight;
    [self.messageView setPopsFromRight:popsFromRight];
    [self setNeedsLayout];
}

#pragma mark - View
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect contentViewBounds = self.contentView.bounds;
    CGFloat outerVerticalMargin = 8.0f;
    CGFloat dateAvatorBetweenSpace = 10.0f;
    CGFloat dateMessageBetweetSpace = 2.0f;
    
    
    CGRect avatorRect = self.avatorImageView.frame;
    avatorRect.origin = CGPointMake(imageViewSpace, contentViewBounds.origin.y + contentViewBounds.size.height - (avatorRect.size.height + imageViewSpace));
    if (self.popsFromRight) {
        avatorRect.origin.x = contentViewBounds.origin.x + contentViewBounds.size.width - (avatorRect.size.width + imageViewSpace);
    }
    self.avatorImageView.frame = avatorRect;
    
    
    CGRect messageRect = CGRectMake(avatorRect.origin.x + avatorRect.size.width + imageViewSpace, contentViewBounds.origin.y + outerVerticalMargin, self.tweetViewRect.size.width + (tweetTextViewSpace + tweetTextViewSpaceFromPop), self.tweetViewRect.size.height + tweetTextViewSpace * 2);
    if (self.popsFromRight) {
        messageRect.origin.x = avatorRect.origin.x - (messageRect.size.width + imageViewSpace);
    }
    self.messageView.frame = messageRect;
    
    CGRect tweetTextViewRect = CGRectMake(tweetTextViewSpaceFromPop, tweetTextViewSpace, self.tweetViewRect.size.width, self.tweetViewRect.size.height);
    if (self.popsFromRight) {
        tweetTextViewRect.origin.x = tweetTextViewSpace;
    }
    self.tweetTextView.frame = tweetTextViewRect;
    
    
    [self.dateLabel sizeToFit];
    CGRect labelRect = self.dateLabel.frame;
    labelRect.origin = CGPointMake(avatorRect.origin.x + avatorRect.size.width + dateAvatorBetweenSpace, messageRect.origin.y + messageRect.size.height + dateMessageBetweetSpace);
    if (self.popsFromRight) {
        labelRect.origin.x = avatorRect.origin.x - (labelRect.size.width + dateAvatorBetweenSpace);
    }
    self.dateLabel.frame = labelRect;
}

@end
