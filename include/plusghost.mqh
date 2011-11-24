//|-----------------------------------------------------------------------------------------|
//|                                                                           PlusGhost.mqh |
//|                                                            Copyright © 2011, Dennis Lee |
//| Assert History                                                                          |
//| 1.00    Created a paper trading module using Sqlite wrapper.                            |
//|-----------------------------------------------------------------------------------------|
#property   copyright "Copyright © 2011, Dennis Lee"
#include    <sqlite.mqh>

//|-----------------------------------------------------------------------------------------|
//|                 P L U S L I N E X   E X T E R N A L   V A R I A B L E S                 |
//|-----------------------------------------------------------------------------------------|
extern   int    GhostMaxAccountTrades   = 1;
extern   int    GhostDebug              = 1;

//|-----------------------------------------------------------------------------------------|
//|                           I N T E R N A L   V A R I A B L E S                           |
//|-----------------------------------------------------------------------------------------|
string   GhostName="PlusGhost";
string   GhostVer="1.0";
string   GhostDb="ghost.db";
string   GhostTable="orders";

//|-----------------------------------------------------------------------------------------|
//|                             I N I T I A L I Z A T I O N                                 |
//|-----------------------------------------------------------------------------------------|
void GhostInit()
{
    if(GhostMaxAccountTrades>0)
    {
    //  Check if table exists - create
        if(!IsTableExists(GhostDb,GhostTable))
        {
        //--- Create table schema
            DbCreateTable(GhostDb,GhostTable);
            DbAlterTableInteger(GhostDb,GhostTable,"ticket");
            DbAlterTableDT(GhostDb,GhostTable,"opentime");
            DbAlterTableDT(GhostDb,GhostTable,"closetime");
        //--- Status: Enum OPENED, PENDING, CLOSED, CANCELLED
            DbAlterTableInteger(GhostDb,GhostTable,"status");
            DbAlterTableText(GhostDb,GhostTable,"symbol");
            DbAlterTableInteger(GhostDb,GhostTable,"type");
            DbAlterTableReal(GhostDb,GhostTable,"lots");
            DbAlterTableReal(GhostDb,GhostTable,"price");
            DbAlterTableReal(GhostDb,GhostTable,"slippage");
            DbAlterTableReal(GhostDb,GhostTable,"stoploss");
            DbAlterTableReal(GhostDb,GhostTable,"takeprofit");
            DbAlterTableText(GhostDb,GhostTable,"comment");
            DbAlterTableInteger(GhostDb,GhostTable,"magic");
            DbAlterTableDT(GhostDb,GhostTable,"expiration");
        //--- Net Profit Value without swaps or commissions
        //      For opened, it is the current unrealized profit
        //      For closed, it is the fixed profit
            DbAlterTableReal(GhostDb,GhostTable,"profit");
            DbAlterTableReal(GhostDb,GhostTable,"swap");
            DbAlterTableReal(GhostDb,GhostTable,"commission");
        }
    
    //  Check if table created successfully
        if(!IsTableExists(GhostDb,GhostTable))
        {
            Print("Creation of database and table failed. Ghost trading has been disabled.");
            GhostMaxAccountTrades=0;
        }
        else if(GhostDebug>=1)
            Print("Database "+GhostDb+" and table "+GhostTable+" created.");
    }
}

//|-----------------------------------------------------------------------------------------|
//|                                 O P E N   O R D E R S                                   |
//|-----------------------------------------------------------------------------------------|
int GhostOrderSend(string symbol, int type, double lots, double price, int slippage,
                    double stoploss, double takeprofit, string comment="", int magic=0,
                    datetime expiration=0, color arrow_color=CLR_NONE)
{
   return(0);
}

bool GhostOrderModify(int ticket, double price, double stoploss, double takeprofit, 
                        datetime expiration=0, color arrow_color=CLR_NONE)
{
    return(false);
}

//|-----------------------------------------------------------------------------------------|
//|                                O R D E R S   S T A T U S                                |
//|-----------------------------------------------------------------------------------------|
int GhostOrdersTotal()
{
    return(0);
}

//|-----------------------------------------------------------------------------------------|
//|                                  C L O S E  O R D E R S                                 |
//|-----------------------------------------------------------------------------------------|
bool GhostOrderClose(int ticket, double lots, double price, int slippage, color Color=CLR_NONE)
{
    return(false);
}

bool GhostOrderDelete(int ticket, color Color=CLR_NONE)
{
    return(false);
}

//|-----------------------------------------------------------------------------------------|
//|                                     C O M M E N T                                       |
//|-----------------------------------------------------------------------------------------|
string GhostComment(string cmt="")
{
   string strtmp = cmt+"  -->"+GhostName+" "+GhostVer+"<--";

//---- Assert Trade info in comment
   int total=GhostOrdersTotal();
   if (GhostMaxAccountTrades==0)
      strtmp=strtmp+"\n    No Ghost Allowed.";
   else if (total<=0)
      strtmp=strtmp+"\n    No Active Ghost Trades.";
   else if (total==GhostMaxAccountTrades)
      strtmp=strtmp+"\n    Ghost Trades="+total+" (Filled the maximum of "+DoubleToStr(GhostMaxAccountTrades,0)+")";
   else
      strtmp=strtmp+"\n    Ghost Trades="+total+" (OK <= "+DoubleToStr(GhostMaxAccountTrades,0)+")";
                         
   strtmp = strtmp+"\n";
   return(strtmp);
}

//|-----------------------------------------------------------------------------------------|
//|                                S C H E M A   S T A T U S                                |
//|-----------------------------------------------------------------------------------------|
bool IsTableExists(string db, string table)
{
    int err=sqlite_table_exists(db,table);
    if(err<0)
    {
        Print("Check for table "+table+" existence. Error Code: "+err);
        return(false);
    }
    return(err>0);
}

void DbCreateTable(string db, string table)
{
    string exp="CREATE TABLE "+table+" (id INTEGER PRIMARY KEY ASC)";
    DbExec(db,exp);
}

void DbAlterTableText(string db, string table, string field)
{
    string exp="ALTER TABLE "+table+" ADD COLUMN "+field+" TEXT NOT NULL DEFAULT ''";
    DbExec(db,exp);
}

void DbAlterTableInteger(string db, string table, string field)
{
    string exp="ALTER TABLE "+table+" ADD COLUMN "+field+" INTEGER NOT NULL DEFAULT '0'";
    DbExec(db,exp);
}

void DbAlterTableReal(string db, string table, string field)
{
    string exp="ALTER TABLE "+table+" ADD COLUMN "+field+" REAL NOT NULL DEFAULT '0.0'";
    DbExec(db,exp);
}

void DbAlterTableDT(string db, string table, string field)
{
//--- DT can be stored as TEXT, REAL or INTEGER
    string exp="ALTER TABLE "+table+" ADD COLUMN "+field+" INTEGER NOT NULL DEFAULT '0'";
    DbExec(db,exp);
}

void DbExec(string db, string exp)
{
    int err=sqlite_exec(db,exp);
    if (err!=0)
        Print("Check expression '"+exp+"'. Error Code: "+err);
}

//|-----------------------------------------------------------------------------------------|
//|                       E N D   O F   E X P E R T   A D V I S O R                         |
//|-----------------------------------------------------------------------------------------|

