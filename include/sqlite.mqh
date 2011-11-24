/*
 * SQLite interface for MT4
 */

#import "sqlite3_wrapper.dll"
int sqlite_exec (string db_fname, string sql);
int sqlite_table_exists (string db_fname, string table);
int sqlite_query (string db_fname, string sql, int& cols[]);
int sqlite_next_row (int handle);
string sqlite_get_col (int handle, int col);
int sqlite_free_query (int handle);
#import
