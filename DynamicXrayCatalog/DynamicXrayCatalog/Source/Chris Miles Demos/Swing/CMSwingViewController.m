//
//  CMSwingViewController.m
//  DynamicXrayCatalog
//
//  Created by Chris Miles on 6/11/2013.
//  Copyright (c) 2013-2014 Chris Miles. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "CMSwingViewController.h"
#import <DynamicXray/DynamicXray.h>


@interface CMSwingViewController ()

@property (strong, nonatomic) IBOutlet UIView *swingView;

@property (strong, nonatomic) UIDynamicAnimator *animator;
@property (strong, nonatomic) UIPushBehavior *pushBehavior;

@property (strong, nonatomic) DynamicXray *dynamicXray;

@end


@implementation CMSwingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self initializeAnimator];

    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *xrayItem = [[UIBarButtonItem alloc] initWithTitle:@"Xray" style:UIBarButtonItemStyleBordered target:self action:@selector(xrayAction:)];
    self.toolbarItems = @[flexibleItem, xrayItem];

    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognized:)];
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

- (void)initializeAnimator
{
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];

    CGRect swingFrame = self.swingView.frame;
    CGPoint attachmentPoint = CGPointMake(CGRectGetWidth(swingFrame)/2.0f, CGRectGetWidth(swingFrame)/2.0f);
    UIOffset attachmentOffset = UIOffsetMake(attachmentPoint.x - CGRectGetWidth(swingFrame)/2.0f, attachmentPoint.y - CGRectGetHeight(swingFrame)/2.0f);
    CGPoint anchorPoint = [self.view convertPoint:attachmentPoint fromView:self.swingView];
    UIAttachmentBehavior *attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:self.swingView offsetFromCenter:attachmentOffset attachedToAnchor:anchorPoint];

    UIGravityBehavior *gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[self.swingView]];

    self.pushBehavior = [[UIPushBehavior alloc] initWithItems:@[self.swingView] mode:UIPushBehaviorModeInstantaneous];

    UIDynamicItemBehavior *itemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.swingView]];
    itemBehavior.density = 1.6f;
    itemBehavior.resistance = 1.4f;

    [self.animator addBehavior:attachmentBehavior];
    [self.animator addBehavior:gravityBehavior];
    [self.animator addBehavior:self.pushBehavior];
    [self.animator addBehavior:itemBehavior];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.navigationController setToolbarHidden:NO animated:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self pushSwingWithAngle:(CGFloat)M_PI magnitude:0.5f swingOffset:UIOffsetMake(30.0f, CGRectGetHeight(self.swingView.frame)/2.0f)];
}


#pragma mark - Tap Gesture Recognizer

- (void)tapGestureRecognized:(UITapGestureRecognizer *)tapGestureRecognizer
{
    CGPoint tapPoint = [tapGestureRecognizer locationInView:self.view];
    [self applySwingPushFromPoint:tapPoint];
}


#pragma mark - Push

- (void)applySwingPushFromPoint:(CGPoint)pushPoint
{
    UIView *swingView = self.swingView;

    UIOffset swingOffset = UIOffsetMake(0, CGRectGetHeight(swingView.bounds) / 2.0f);
    CGPoint itemOffsetPoint = CGPointMake(swingOffset.horizontal + CGRectGetWidth(swingView.bounds)/2.0f, swingOffset.vertical + CGRectGetHeight(swingView.bounds)/2.0f);
    CGPoint itemPoint = [self.view convertPoint:itemOffsetPoint fromView:swingView];

    CGFloat xDiff = itemPoint.x - pushPoint.x;
    CGFloat yDiff = itemPoint.y - pushPoint.y;

    CGFloat angle = atan2f(yDiff, xDiff);

    CGFloat distance = sqrtf(xDiff*xDiff + yDiff*yDiff);
    CGFloat maxPushDistance = [self maximumPushDistance];
    CGFloat magnitude = (maxPushDistance - distance) / maxPushDistance;
    if (magnitude <= 0) magnitude = 0.05f;

    [self pushSwingWithAngle:angle magnitude:magnitude swingOffset:swingOffset];
}

- (CGFloat)maximumPushDistance
{
    return CGRectGetWidth(self.view.bounds);
}

- (void)pushSwingWithAngle:(CGFloat)angle magnitude:(CGFloat)magnitude swingOffset:(UIOffset)swingOffset
{
    //DLog(@"angle: %g˚  magnitude: %g  swingOffset: %@", (angle*180.0f/M_PI), magnitude, NSStringFromUIOffset(swingOffset));
    [self.pushBehavior setTargetOffsetFromCenter:swingOffset forItem:self.swingView];
    [self.pushBehavior setAngle:angle magnitude:magnitude];
    [self.pushBehavior setActive:YES];
}


#pragma mark - DynamicXray

- (DynamicXray *)dynamicXray
{
    if (_dynamicXray == nil) {
        _dynamicXray = [[DynamicXray alloc] init];
        _dynamicXray.active = NO;

        [self.animator addBehavior:_dynamicXray];
    }

    return _dynamicXray;
}

- (void)xrayAction:(__unused id)sender
{
    [self.dynamicXray presentConfigurationViewController];
}

@end
