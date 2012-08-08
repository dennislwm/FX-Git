#property copyright "© 2010 Bernd Kreuss"
#define MT4R_VERSION_MAJOR 1
#define MT4R_VERSION_MINOR 3  // must change to 4

/** @file
* Metatrader-4 -> R Interface Library
*
*     This source is free software; you can redistribute it and/or 
*     modify it under the terms of the GNU General Public License 
*     as published by the Free Software Foundation; either version 2 
*     of the License, or (at your option) any later version.
*
*     A commercial license and support is available upon request
*
* mt4R.dll allows the direct usage of the R environment
* (The R Project for Statistical Computing, http//www.r-proect.org) 
* from within your mql4 code. You can start an R session (one or more 
* for each EA instance), send data to it, call R functions and get 
* results back ino your mql4 program. Each R session will run as a 
* separate process but the communication of the mql4 program with R 
* will appear towards mql4 as synchronuos function calls. Behind the
* scenes it will construct and execute small snippets of R code at 
* the REPL, wait for the prompt to return and parse the output, very 
* much like you would do it manually in an interactive R session.
*
* mt4R.mqh (this file) is the header file for mt4R.dll. Put the dll 
* into experts/libraries and put this file into experts/include. 
* Then use it in your EA with
* <PRE>
*
*   #include <mt4R.mqh>
*
* </PRE>
* The following two external variables are recommended, but of course 
* you might also hardcode them. You must use --no-save but you 
* MUST NOT use --slave or otherwise turn off the echo or change 
* the default prompt or it will fail.
* <PRE>
*   
*   extern string R_command = "C:\Programme\R\R-2.11.1\bin\Rterm.exe --no-save";
*   extern int R_debuglevel = 2;
*   
* </PRE>
* Debug level can be 0, 1 or 2. During development you should set it 
* to 2 which will output every available message. A value of 1 will 
* only output warnings and notes and a value of 0 will only output 
* fatal errors, this is the recommended setting for production use.
*  
* Debug output will go to the system debug monitor. You can use 
* the free DebugView.exe tool from microsoft to log it in real time.
*
* The library defines a handful of functions to directly assign and
* read a few data types without the need for manually formatting and
* executing snippets of R code for these purposes. Not all possible
* data types are directly supported, for example there is no function
* to directly assign a matrix of strings since I never saw the need 
* to do this. The main emphasis is on vectors and matrices containing
* only floating point values. Once you have transferred the bulk of
* your data as vectors or matrices into the R session you can execute 
* snippets of R code to combine them or convert them into something 
* more complex if needed. 
*
* Also the main emphasis is on getting huge amounts of numeric data 
* into the R session quickly but not the other way, since the assumption
* is that you want to feed it with vast amounts of numerical data to 
* crunch numbers and only need to get back a single value or a vector 
* as a result.
*
* All the vector functions have a size parameter. Be very careful 
* that the array you supply has actually the same size (bigger 
* won't hurt but smaller is not allowed). You should always use
* ArraySize() or ArrrayRange() for the size parameter, this will 
* make your life much easier.
* <PRE>
*   // *** EXAMPLE USAGE ***
*
*   #include <mt4R.mqh>
*
*   extern string R_command = "C:\Programme\R\R-2.11.1\bin\Rterm.exe --no-save";
*   extern int R_debuglevel = 2;
*
*   int rhandle;
*
*   int init() {
*      rhandle = RInit(R_command, R_debuglevel);
*   }
*
*   int deinit() {
*      RDeinit(rhandle);
*   }
*
*   int start() {
*      int i;
*      int k;
*      double vecfoo[5];
*      double vecbaz[5];
* 
*      for (i=0; i<5; i++) {
*         vecfoo[i] = SomeThingElse(i);
*      }
*
*      RAssign(rhandle, "foo", vecfoo, ArraySize(vecfoo));
*      RExecute(rhandle, "baz <- foo * 42");
*      k = RGetVector(rhandle, "baz", vecbaz, ArraySize(vecbaz));
* 
*      for (i=0; i<k; i++) {
*         Print(vecbaz[i]);
*      }
*   }
*
*   double SomeThingElse(int n) {
*      [...]
*   }
*
* </PRE>
*/

#import "mt4R.dll"
   /**
   * Return the dll version. The upper 16 bit of the return value
   * are the major version and the lower 16 bit the minor. This
   * is used in RInit() to make sure that this header file and 
   * the dll fit together.
   */ 
   int RGetDllVersion();
   
   /**
   * This is not meant to be called directly, it will be
   * called by RInit() after the successful version check. 
   * You should call RInit() to start a new R session.
   */
   int RInit_(string commandline, int debuglevel);
   
   /**
   * Teminate the R session. Call this in your deinit() function.
   * After this the handle is no longer valid.
   */
   void RDeinit(int rhandle);
   
   /**
   * return true if the R session belonging to this handle is 
   * still runing. R will terminate on any fatal error in the 
   * code you send it. You should check this at the beginning
   * of your start function and stop all actions. The last
   * command prior to the crash will be found in the log.
   * If R is not running anymore this library won't emit any
   * more log messages and will silently ignore all commands.
   */
   bool RIsRunning(int rhandle);
   
   
   /**
   * return true if R is still executing a command (resulting 
   * from a call to RExecuteAsync())
   */
   bool RIsBusy(int rhandle);
   
   /**
   * execute code and do not wait. Any subsequent call however
   * will wait since there can only be one thread executing at
   * any given time. Use RIsBusy() to check whether it is finished
   */
   void RExecuteAsync(int rhandle, string code);
   
   /**
   * execute code and wait until it is finished. This will not
   * return anything. You can basically achieve the same with
   * the RGet*() functions, evaluating the expression is also
   * just executig code, the only difference is that these
   * RGet*() functions will additionally try to parse and return 
   * the output while RExecute() will just execute, wait and 
   * ignore all output.
   */
   void RExecute(int rhandle, string code);
   
   /**
   * assign a bool to the variable name. In R this type is called "logical"
   */
   void RAssignBool(int rhandle, string variable, bool value);
   
   /**
   * assign an integer to the variable name.
   */
   void RAssignInteger(int rhandle, string variable, int value);
   
   /**
   * assign a double to the variable name.
   */
   void RAssignDouble(int rhandle, string variable, double value);
   
   /**
   * assign a string to the variable namd. In R this type is called "character"
   */
   void RAssignString(int rhandle, string variable, string value);
   
   /** 
   * assign a vector to the variable name. If the size does not match
   * your actual array size then bad things might happen.
   */
   void RAssignVector(int rhandle, string variable, double &vector[], int size);
   
   /**
   * assign a vector of character (an array of strings) to the variable. If you need
   * a factor then you should execute code to convert it after this command. In
   * recent versions of R a vector of strings does not need any more memory than
   * a factor and it is easier to append new elements to it.
   */ 
   void RAssignStringVector(int rhandle, string variable, string &vector[], int size);
   
   /**
   * assign a matrix to the variable name. The matrix must have the row number as the
   * first dimension (byrow=TRUE will be used on the raw data). This function is much 
   * faster than building a huge matrix (hundreds of rows) from scratch by appending 
   * new rows at the end with RRowBindVector() for every row. This function is optimized
   * for huge throughput with a single function call through using file-IO with the
   * raw binary data. For very small matrices and vectors with only a handful of elements 
   * this might be too much overhead and the other functions will be faster. Once you 
   * have the matrix with possibly thousands of rows transferred to R you should then
   * only use RRowBindVector() to further grow it slowly on the arrival of single new 
   * data vectors instead of always sending a new copy of the entire matrix.
   */
   void RAssignMatrix(int rhandle, string variable, double &matrix[][], int rows, int cols);
   
   /** 
   * append a row to a matrix or dataframe. This will exexute 
   * variable <- rbind(variable, vector)
   * if the size does not match the actual array size bad things might happen.
   */
   void RAppendMatrixRow(int rhandle, string variable, double &vector[], int size);
   
   /**
   * return true if the variable exists, false otherwise.
   */
   bool RExists(int rhandle, string variable);
   
   /**
   * evaluate expression and return a bool. Expression can be any R code 
   * that will evaluate to logical. If it is a vector of logical then only
   * the first element is returned.
   */
   bool RGetBool(int rhandle, string expression);
   
   /**
   * evaluate expression and return an integer. Expression can be any R code 
   * that will evaluate to an integer. If it is a floating point it will be
   * rounded, if it is a vector then only the first element will be returned.
   */
   int RGetInteger(int rhandle, string expression);
   
   /**
   * evaluate expression and return a double. Expression can be any R code 
   * that will evaluate to a floating point number, if it is a vector then
   * only the first element is returned.
   */
   double RGetDouble(int rhandle, string expression);
   
   /**
   * evaluate expression and return a vector of doubles. Expression can
   * be anything that evaluates to a vector of floating point numbers.
   * Return value is the number of elements that could be copied into the
   * array. It will never be bigger than size but might be smaller.
   * warnings are output on debuglevel 1 if the sizes don't match.
   */
   int RGetVector(int rhandle, string expression, double &vector[], int size);
   
   /**
   * do a print(expression) for debugging purposes. The outout will be 
   * sent to the debug monitor on debuglevel 0.
   */
   void RPrint(int rhandle, string expression);
#import

/*
* start and initialize a new R session. Call this function in init() and store 
* the handle it returns. This will start an R session and all subsequent calls 
* to R functions will need this handle to identify the R session. This function
* will check the version of the dll against the version of this header file and
* if there is a mismatch it will report an error and refuse to initialize R.
*/
int RInit(string commandline, int debuglevel){
   int dll_version;
   int dll_major;
   int dll_minor;
   string error;
   dll_version = RGetDllVersion();
   if (dll_version == MT4R_VERSION_MAJOR << 16 + MT4R_VERSION_MINOR){
      return(RInit_(commandline, debuglevel));
   }else{
      dll_major = dll_version >> 16;
      dll_minor = dll_version & 0xffff;
      error = "Version mismatch mt4R.dll: "
            + "expected version " + MT4R_VERSION_MAJOR + "." + MT4R_VERSION_MINOR
            + "  -  found dll version " + dll_major + "." + dll_minor;
      Print(error);
      return(0);
   }
}


/**
* shorthands for some of the above functions
*/

int hR;

void StartR(string path, int debug=1){
   hR = RInit(path, debug);
}

void StopR(){
   RDeinit(hR);
}

void Rx(string code){
   RExecute(hR, code);
}

void Rs(string var, string s){
   RAssignString(hR, var, s);
}

void Ri(string var, int i){
   RAssignInteger(hR, var, i);
}

void Rd(string var, double d){
   RAssignDouble(hR, var, d);
}

void Rv(string var, double v[]){
   RAssignVector(hR, var, v, ArraySize(v));
}

void Rf(string name, string factor[]){
   RAssignStringVector(hR, name, factor, ArraySize(factor));
   Rx(name + " <- as.factor(" + name + ")");
}

void Rm(string var, double matrix[], int rows, int cols){
   RAssignMatrix(hR, var, matrix, rows, cols);
}

int Rgi(string var){
   return(RGetInteger(hR, var));
}

double Rgd(string var){
   return(RGetDouble(hR, var));
}

void Rgv(string var, double &v[]){
   RGetVector(hR, var, v, ArraySize(v));
}

void Rp(string expression){
   RPrint(hR, expression);
}


