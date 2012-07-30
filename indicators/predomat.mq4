#property copyright "© Bernd Kreuss"


#property indicator_chart_window

#property indicator_buffers 1
#property indicator_color1 Red
#property indicator_width1 2


#include <mt4R.mqh>

extern int order = 200;
extern int back = 500;
extern int ahead = 20;

int R;
double buf_prediction[];

int init(){
   SetIndexBuffer(0, buf_prediction);
   SetIndexStyle(0, DRAW_LINE);
   SetIndexShift(0, ahead);
   R = RInit("C:/Program Files/R/R-2.15.1/bin/i386/Rterm.exe --no-save", 2);
   Comment("history: " + back + " bars, method: OLS, order: " + order);
}

int deinit(){
   RDeinit(R);
}

int start(){
   double hist[];
   double pred[];
   int i;
   
   if (RIsBusy(R)){
      // last RExecuteAsync() is still not finished, do nothing.
      return(0);
   }
   
   if (RGetInteger(R, "as.integer(exists('model'))") == 1){
      // there exists a model (the variable is set). 
      // This means a previously started RExecuteAsync() has finished. 
      // we can now predict from this model and plot it.
      RAssignInteger(R, "ahead", ahead);
      RExecute(R, "pred <- predict(model, n.ahead=ahead)$pred");
      ArrayResize(pred, ahead);
      RGetVector(R, "rev(pred)", pred, ahead);
      for (i=0; i<ahead; i++){
         buf_prediction[i] = pred[i];
      }
   }
   
   // make a (new) prediction
   // move some history over to R   
   ArrayResize(hist, back);
   for (i=0; i<back; i++){
      hist[i] = Close[i];
   }
   RAssignVector(R, "hist", hist, ArraySize(hist));
   RExecute(R, "hist <- rev(hist)");
   
   // crunch the numbers in the background and return from the start() function
   // RIsBusy() in the next ticks will tell us when it is finished.
   RAssignInteger(R, "ord", order);
   RExecuteAsync(R, "model <- ar(hist, aic=FALSE, order=ord, method='ols')");
   return(0);   
}