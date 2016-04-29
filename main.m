#include <dispatch/dispatch.h>
#include "gtkgcd.h"

#import "TextWindow.h"

// Create some dispatch queues to create concurrent activity

dispatch_queue_t queue1;
dispatch_queue_t queue2;

dispatch_source_t timer1;
dispatch_source_t timer2;

// launch a timer to print messages
void launch_messages(dispatch_queue_t q, TextWindow *win, NSString *message) {

  dispatch_time_t delTime = dispatch_time(DISPATCH_TIME_NOW, 0.5*NSEC_PER_SEC);

  dispatch_after(delTime, dispatch_get_global_queue(0,0), ^{
      [win doLog:message];

      launch_messages(q, win, message);
    });
  }



int main(int argc, char *argv[], char **env) {

  //init gtk engine
  gtk_init(&argc, &argv);

  // create a logging text window
  TextWindow *textWindow = [[TextWindow alloc] init];

  // send a message to the window
  [textWindow doLog:@"Message 1 from main()\n"];

  // launch a timer thread to write messages
  queue1 = dispatch_queue_create("dispatch queue 1", NULL);

  timer1 =  dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,
				    0, 0, dispatch_get_global_queue(0,0));
  if (timer1) {
    dispatch_source_set_timer(timer1, dispatch_walltime(NULL, 0), 1.0*NSEC_PER_SEC, 0.1*NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer1, ^{
	[textWindow doLog:@"timer1\n"];
      });
    dispatch_resume(timer1);
  }

  // launch another timer thread to write messages
  queue2 = dispatch_queue_create("dispatch queue 2", NULL);

  timer2 =  dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,
				    0, 0, dispatch_get_global_queue(0,0));
  if (timer2) {
    dispatch_source_set_timer(timer2, dispatch_walltime(NULL, 0), 1.0*NSEC_PER_SEC, 0.1*NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer2, ^{
	[textWindow doLog:@"timer2\n"];
      });
    dispatch_resume(timer2);
  }


  // launch gtk event dispatch handler
  gtkgcd_launch(textWindow.window);

  dispatch_main();

}



