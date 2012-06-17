//
//  EventManager.h
//  calendar
//
//  Created by Fravic Fernando on 12-04-16.
//  Copyright 2012 University of Waterloo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

@interface EventManager : NSObject {
	EKEventStore *_eventStore;
}

- (NSArray*)getEventsForRefDate:(int)refDate;
- (void)createEvent;

@end
