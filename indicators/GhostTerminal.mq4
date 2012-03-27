//|-----------------------------------------------------------------------------------------|
//|                                                                       GhostTerminal.mq4 |
//|                                                            Copyright © 2012, Dennis Lee |
//| Assert History                                                                          |
//| 1.00    Creates an EMPTY indicator window used by PlusGhost.mqh.                        |
//|-----------------------------------------------------------------------------------------|
#property copyright "Copyright © 2012, Dennis Lee"

// ------------------------------------------------------------------------------------------|
//                          I N D I C A T O R   S E T T I N G S                              |
// ------------------------------------------------------------------------------------------|
#property  indicator_separate_window

// ------------------------------------------------------------------------------------------|
//                             I N I T I A L I S A T I O N                                   |
// ------------------------------------------------------------------------------------------|
int init()
{
//---- Assert window name is the same as PlusGhost property GhostTerminal.
	IndicatorShortName("GhostTerminal");
//---- initialization done
	return(0);
}

