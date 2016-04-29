//
// A simple logging window with a "clear' button in  ObjC2.
//

#import "TextWindow.h"

#include <dispatch/dispatch.h>
#include "gtkgcd.h"

@implementation TextWindow

- (id) init {

  if (self = [super init]) {
    _scrollview = gtk_scrolled_window_new( NULL, NULL ); 
    _textview = gtk_text_view_new(); 
    gtk_text_view_set_editable((GtkTextView*) _textview, FALSE);
    _avbox = gtk_vbox_new(FALSE, 0); 
    _window = gtk_window_new(GTK_WINDOW_TOPLEVEL); 

    _buffer = gtk_text_view_get_buffer(GTK_TEXT_VIEW (_textview)); 
    gtk_text_buffer_get_start_iter(_buffer, &_iter); 
     
    g_signal_connect(G_OBJECT (_window), "delete_event",
		     G_CALLBACK (deleteEvent_dispatcher),
		     (__bridge void*) self);

    g_signal_connect(G_OBJECT (_window), "destroy",
		     G_CALLBACK (destroyEvent_dispatcher),
		     (__bridge void*) self); 

    _button = gtk_button_new_with_label("clear");

    g_signal_connect(G_OBJECT (_button), "clicked",
		     G_CALLBACK (buttonEvent_dispatcher),
		     (__bridge void*) self);



    gtk_window_set_default_size(GTK_WINDOW (_window), 200, 200); 
     
    gtk_container_add(GTK_CONTAINER (_scrollview), _textview); 
    gtk_box_pack_start(GTK_BOX(_avbox), _button, FALSE, FALSE, 0);
    gtk_box_pack_start(GTK_BOX(_avbox), _scrollview, TRUE, TRUE, 0);
    gtk_container_add(GTK_CONTAINER (_window), _avbox); 
       
    gtk_widget_show(_textview); 
    gtk_widget_show(_button); 
    gtk_widget_show(_scrollview); 
    gtk_widget_show(_avbox); 
    gtk_widget_show(_window);

  }
  return self;
}

extern void gdkgcd_sync();

- (void) doLog:(NSString*)s {

  // update GTK in the main queue
  dispatch_async(dispatch_get_main_queue(), ^{
      gtk_text_buffer_insert(_buffer, &_iter,
			     [s cStringUsingEncoding:NSUTF8StringEncoding],
			     -1);
    });

  // sync the GTK graphics
  gtkgcd_sync();

}

- (void) deleteEvent {
  NSLog(@"delete Event");
}

static void deleteEvent_dispatcher (GtkObject *object, GdkEvent  *event, gpointer user_data) {

  TextWindow *w = (__bridge TextWindow*) user_data;
  [w deleteEvent];

}

- (void) destroyEvent {
  NSLog(@"destroy Event");

  dispatch_async(dispatch_get_main_queue(), ^{
      NSLog(@"Goodbye!");
      exit(0);
    });
}

static void destroyEvent_dispatcher (GtkObject *object, gpointer user_data) {

  TextWindow *w = (__bridge TextWindow*) user_data;
  [w destroyEvent];

}


- (void) buttonEvent {
  NSLog(@"button Event");

  GtkTextIter start;
  GtkTextIter end;

  gtk_text_buffer_get_start_iter (_buffer, &start);
  gtk_text_buffer_get_end_iter (_buffer, &end);
  gtk_text_buffer_delete (_buffer, &start, &end);

  gtk_text_buffer_get_start_iter(_buffer, &_iter);
}

static void buttonEvent_dispatcher (GtkObject *object, gpointer user_data) {

  TextWindow *w = (__bridge TextWindow*) user_data;
  [w buttonEvent];
}


@end
