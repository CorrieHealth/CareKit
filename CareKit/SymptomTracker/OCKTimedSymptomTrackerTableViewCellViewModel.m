//
//  OCKTimedSymptomTrackerTableViewCellViewModel.m
//  CareKit
//
//  Created by Ryan Demo on 11/25/17.
//  Copyright © 2017 carekit.org. All rights reserved.
//

#import "OCKTimedSymptomTrackerTableViewCellViewModel.h"
#import "OCKTimedSymptomTrackerViewController.h"
#import "OCKHelpers.h"


@implementation OCKTimedSymptomTrackerTableViewCellViewModel {
    NSDateComponents *_selectedDate;
    NSDate *_earliestEventDate;
}

- (instancetype)init {
    OCKThrowMethodUnavailableException();
    return nil;
}

- (instancetype)initWithTime:(OCKTimedSymptomTrackerTime)time andEvents:(NSArray<OCKCarePlanEvent *> *)events onSelectedDate:(NSDateComponents *)selectedDate {
    self = [super init];
    if (!self) return nil;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"hh:mm a"];
    
    NSMutableArray *titles = [NSMutableArray arrayWithCapacity:[events count]];
    int completionCount = 0;
    
    for (OCKCarePlanEvent *event in events) {
        [titles addObject:[self shortenedTitleFrom:event]];
        completionCount += event.state == OCKCarePlanEventStateCompleted ? 1 : 0;
        NSDate *eventDate = [dateFormat dateFromString:event.activity.text];
        if (!_earliestEventDate || [_earliestEventDate timeIntervalSinceDate:_earliestEventDate] < 0) {
            _earliestEventDate = eventDate;
        }
    }
    
    _time = time;
    _title = [self titleFor:time];
    _subtitle = [titles componentsJoinedByString:@", "];
    _valueText = [NSString stringWithFormat:@"%i/%lu", completionCount, (unsigned long)[events count]];
    
    _selectedDate = selectedDate;
    
    _events = events;
    
    return self;
}

- (NSString *) titleFor:(OCKTimedSymptomTrackerTime)time {
    switch (time) {
        case OCKTimedSymptomTrackerTimeMorning:
            return @"Morning";
        case OCKTimedSymptomTrackerTimeNoon:
            return @"Noon";
        case OCKTimedSymptomTrackerTimeAfternoon:
            return @"Afternoon";
        case OCKTimedSymptomTrackerTimeEvening:
            return @"Evening";
    }
}

- (NSInteger) hourComponentFor:(OCKTimedSymptomTrackerTime)time {
    switch (time) {
        case OCKTimedSymptomTrackerTimeMorning:
            return 8;
        case OCKTimedSymptomTrackerTimeNoon:
            return 12;
        case OCKTimedSymptomTrackerTimeAfternoon:
            return 16;
        case OCKTimedSymptomTrackerTimeEvening:
            return 20;
    }
}

- (NSString *) shortenedTitleFrom:(OCKCarePlanEvent *)event {
    if ([event.activity.title isEqualToString:@"Blood Pressure"]) {
        return @"BP";
    } else if ([event.activity.title isEqualToString:@"Heart Rate"]) {
        return @"HR";
    }
    return event.activity.title;
}

/// Used to determine if the measurement group is too far into the future (>2 hours).
- (BOOL) cellShouldBeEnabled {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *todayComponents = [calendar componentsInTimeZone:[NSTimeZone localTimeZone] fromDate:[NSDate date]];
    
    if (todayComponents.day != _selectedDate.day) {
        return true;  // Return true if the date isn't today (i.e. all past events are selectable)
    }
    
    // If the date is today, limit the time at which you can take a measurement so people don't do it too early
    NSInteger hour = [self hourComponentFor:_time];
    return todayComponents.hour >= hour - 2;
}

@end
