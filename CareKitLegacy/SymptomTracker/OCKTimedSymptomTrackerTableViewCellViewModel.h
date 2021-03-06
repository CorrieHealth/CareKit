//
//  OCKTimedSymptomTrackerTableViewCellViewModel.h
//  CareKit
//
//  Created by Ryan Demo on 11/25/17.
//  Copyright © 2017 carekit.org. All rights reserved.
//

#import <CareKitLegacy/CareKitLegacy.h>
#import "OCKTableViewCell.h"
#import "OCKTimedSymptomTrackerViewController.h"


NS_ASSUME_NONNULL_BEGIN

@interface OCKTimedSymptomTrackerTableViewCellViewModel : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithTime:(OCKTimedSymptomTrackerTime)time andEvents:(NSArray<OCKCarePlanEvent *> *)events onSelectedDate:(NSDateComponents *)selectedDate;

@property (nonatomic, readonly) OCKTimedSymptomTrackerTime time;

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *subtitle;
@property (nonatomic, readonly) NSString *valueText;

@property (nonatomic, readonly) NSArray<OCKCarePlanEvent *> *events;

- (BOOL) cellShouldBeEnabled;

@end

NS_ASSUME_NONNULL_END
