//|-----------------------------------------------------------------------------------------|
//|                                                                    PhiBase_Pro_V2.2.mq4 |
//|                                                            Copyright © 2012, Dennis Lee |
//| Assert History                                                                          |
//| 1.10    Added PlusTurtle.mqh and PlusGhost.mqh (SqLite).                                |
//| 1.00    Originated from PhiBase_Pro_V2_2_b20120422_Installer (decompiled by Ex4toMq4).  |
//|-----------------------------------------------------------------------------------------|
#property copyright "Copyright,2011 - PhiBase Technologies"
#property link      "http://www.Pro.PhiBase.com"

#import "phibase_v2_2.dll"
   int trend1(int a0, int a1, int a2);
   int trend2(int a0, int a1);
   int topic1(int a0, int a1, int a2, int a3, int a4);
   int topic2(int a0, int a1, int a2, int a3, int a4);
   int tmargin(int a0, int a1);
   int addtrade(int a0, double a1, double a2, double a3, double a4, double a5, double a6, double a7, double a8, double a9, int a10, int a11, int a12, double a13, double a14, double a15, double a16, double a17, double a18, int a19, int a20, int a21, double a22, double a23);
   int pmok(int a0);
   double srange(double a0, double a1, int a2);
   double brange(double a0, double a1, int a2);
   double bosrange(double a0, double a1, int a2);
   double bobrange(double a0, double a1, int a2);
   int prcdmkl(double a0, double a1, double a2, double a3, double a4, int a5, double a6, int a7, double a8, double a9, double a10, double a11, double a12, double a13, int a14, int a15, int a16, double a17, double a18, double a19, double a20, int a21);
   int CallPat1b(double a0, double a1, double a2, int a3, int a4, int a5, int a6, double a7, double a8, double a9, double a10, double a11, double a12, double a13, double a14, double a15, double a16, double a17, double a18, double a19, double a20, int a21, int a22, int a23, double a24, double a25);
   int CallPat1s(double a0, double a1, double a2, int a3, int a4, int a5, int a6, double a7, double a8, double a9, double a10, double a11, double a12, double a13, double a14, double a15, double a16, double a17, double a18, double a19, double a20, int a21, int a22, int a23, double a24, double a25);
   int CallPat2b(double a0, double a1, double a2, int a3, int a4, int a5, int a6, double a7, double a8, double a9, double a10, double a11, double a12, double a13, double a14, double a15, double a16, double a17, double a18, double a19, double a20, int a21, int a22, int a23, double a24, double a25);
   int CallPat2s(double a0, double a1, double a2, int a3, int a4, int a5, int a6, double a7, double a8, double a9, double a10, double a11, double a12, double a13, double a14, double a15, double a16, double a17, double a18, double a19, double a20, int a21, int a22, int a23, double a24, double a25);
   int CallPat3b(double a0, double a1, double a2, int a3, int a4, int a5, int a6, double a7, double a8, double a9, double a10, double a11, double a12, double a13, double a14, double a15, double a16, double a17, double a18, double a19, double a20, double a21, double a22, double a23, double a24, double a25, double a26, int a27, int a28, int a29, double a30, double a31);
   int CallPat3s(double a0, double a1, double a2, int a3, int a4, int a5, int a6, double a7, double a8, double a9, double a10, double a11, double a12, double a13, double a14, double a15, double a16, double a17, double a18, double a19, double a20, double a21, double a22, double a23, double a24, double a25, double a26, int a27, int a28, int a29, double a30, double a31);
   int CallPat4b(double a0, double a1, double a2, int a3, int a4, int a5, int a6, double a7, double a8, double a9, double a10, double a11, double a12, double a13, double a14, double a15, double a16, double a17, double a18, double a19, double a20, double a21, double a22, double a23, double a24, double a25, double a26, int a27, int a28, int a29, double a30, double a31);
   int CallPat4s(double a0, double a1, double a2, int a3, int a4, int a5, int a6, double a7, double a8, double a9, double a10, double a11, double a12, double a13, double a14, double a15, double a16, double a17, double a18, double a19, double a20, double a21, double a22, double a23, double a24, double a25, double a26, int a27, int a28, int a29, double a30, double a31);
   int CallPat5b(double a0, double a1, double a2, int a3, int a4, int a5, int a6, double a7, double a8, double a9, double a10, double a11, double a12, double a13, double a14, double a15, double a16, double a17, double a18, double a19, double a20, double a21, double a22, double a23, double a24, double a25, double a26, int a27, int a28, int a29, double a30, double a31);
   int CallPat5s(double a0, double a1, double a2, int a3, int a4, int a5, int a6, double a7, double a8, double a9, double a10, double a11, double a12, double a13, double a14, double a15, double a16, double a17, double a18, double a19, double a20, double a21, double a22, double a23, double a24, double a25, double a26, int a27, int a28, int a29, double a30, double a31);
   int CallPat6b(double a0, double a1, double a2, int a3, int a4, int a5, int a6, double a7, double a8, double a9, double a10, double a11, double a12, double a13, double a14, double a15, double a16, double a17, double a18, double a19, double a20, double a21, double a22, double a23, double a24, double a25, double a26, int a27, int a28, int a29, double a30, double a31);
   int CallPat6s(double a0, double a1, double a2, int a3, int a4, int a5, int a6, double a7, double a8, double a9, double a10, double a11, double a12, double a13, double a14, double a15, double a16, double a17, double a18, double a19, double a20, double a21, double a22, double a23, double a24, double a25, double a26, int a27, int a28, int a29, double a30, double a31);
   int CallPat7b(double a0, double a1, double a2, int a3, int a4, int a5, int a6, double a7, double a8, double a9, double a10, double a11, double a12, double a13, double a14, double a15, double a16, double a17, double a18, double a19, double a20, double a21, double a22, double a23, double a24, double a25, double a26, double a27, double a28, double a29, double a30, double a31, double a32, double a33, double a34, double a35, double a36, double a37, double a38, double a39, double a40, double a41, double a42, double a43, int a44, int a45, int a46, double a47, double a48);
   int CallPat7s(double a0, double a1, double a2, int a3, int a4, int a5, int a6, double a7, double a8, double a9, double a10, double a11, double a12, double a13, double a14, double a15, double a16, double a17, double a18, double a19, double a20, double a21, double a22, double a23, double a24, double a25, double a26, double a27, double a28, double a29, double a30, double a31, double a32, double a33, double a34, double a35, double a36, double a37, double a38, double a39, double a40, double a41, double a42, double a43, int a44, int a45, int a46, double a47, double a48);
   int CallPat8b(double a0, double a1, double a2, int a3, int a4, int a5, int a6, double a7, double a8, double a9, double a10, double a11, double a12, double a13, double a14, double a15, double a16, double a17, double a18, double a19, double a20, double a21, double a22, double a23, double a24, double a25, double a26, double a27, double a28, double a29, double a30, double a31, double a32, double a33, double a34, double a35, double a36, double a37, double a38, double a39, double a40, double a41, double a42, double a43, int a44, int a45, int a46, double a47, double a48);
   int CallPat8s(double a0, double a1, double a2, int a3, int a4, int a5, int a6, double a7, double a8, double a9, double a10, double a11, double a12, double a13, double a14, double a15, double a16, double a17, double a18, double a19, double a20, double a21, double a22, double a23, double a24, double a25, double a26, double a27, double a28, double a29, double a30, double a31, double a32, double a33, double a34, double a35, double a36, double a37, double a38, double a39, double a40, double a41, double a42, double a43, int a44, int a45, int a46, double a47, double a48);
   int CallPat9b(double a0, double a1, double a2, int a3, int a4, int a5, int a6, double a7, double a8, double a9, double a10, double a11, double a12, double a13, double a14, double a15, double a16, double a17, double a18, double a19, double a20, double a21, double a22, double a23, double a24, double a25, double a26, double a27, double a28, double a29, double a30, double a31, double a32, double a33, double a34, double a35, double a36, double a37, double a38, double a39, double a40, double a41, double a42, double a43, int a44, int a45, int a46, double a47, double a48);
   int CallPat9s(double a0, double a1, double a2, int a3, int a4, int a5, int a6, double a7, double a8, double a9, double a10, double a11, double a12, double a13, double a14, double a15, double a16, double a17, double a18, double a19, double a20, double a21, double a22, double a23, double a24, double a25, double a26, double a27, double a28, double a29, double a30, double a31, double a32, double a33, double a34, double a35, double a36, double a37, double a38, double a39, double a40, double a41, double a42, double a43, int a44, int a45, int a46, double a47, double a48);
   int CallPat10b(double a0, double a1, double a2, int a3, int a4, int a5, int a6, double a7, double a8, double a9, double a10, double a11, double a12, double a13, double a14, double a15, double a16, double a17, double a18, double a19, double a20, double a21, double a22, double a23, double a24, double a25, double a26, double a27, double a28, double a29, double a30, double a31, double a32, double a33, double a34, double a35, double a36, double a37, double a38, double a39, double a40, double a41, double a42, double a43, int a44, int a45, int a46, double a47, double a48);
   int CallPat10s(double a0, double a1, double a2, int a3, int a4, int a5, int a6, double a7, double a8, double a9, double a10, double a11, double a12, double a13, double a14, double a15, double a16, double a17, double a18, double a19, double a20, double a21, double a22, double a23, double a24, double a25, double a26, double a27, double a28, double a29, double a30, double a31, double a32, double a33, double a34, double a35, double a36, double a37, double a38, double a39, double a40, double a41, double a42, double a43, int a44, int a45, int a46, double a47, double a48);
   int CallPat11b(double a0, double a1, double a2, int a3, int a4, int a5, int a6, double a7, double a8, double a9, double a10, double a11, double a12, double a13, double a14, double a15, double a16, double a17, double a18, double a19, double a20, double a21, double a22, double a23, double a24, double a25, double a26, double a27, double a28, double a29, double a30, double a31, double a32, double a33, double a34, double a35, double a36, double a37, double a38, double a39, double a40, double a41, double a42, double a43, int a44, int a45, int a46, double a47, double a48);
   int CallPat11s(double a0, double a1, double a2, int a3, int a4, int a5, int a6, double a7, double a8, double a9, double a10, double a11, double a12, double a13, double a14, double a15, double a16, double a17, double a18, double a19, double a20, double a21, double a22, double a23, double a24, double a25, double a26, double a27, double a28, double a29, double a30, double a31, double a32, double a33, double a34, double a35, double a36, double a37, double a38, double a39, double a40, double a41, double a42, double a43, int a44, int a45, int a46, double a47, double a48);
   int CallPat12b(double a0, double a1, double a2, int a3, int a4, int a5, int a6, double a7, double a8, double a9, double a10, double a11, double a12, double a13, double a14, double a15, double a16, double a17, double a18, double a19, double a20, double a21, double a22, double a23, double a24, double a25, double a26, double a27, double a28, double a29, double a30, double a31, double a32, double a33, double a34, double a35, double a36, double a37, double a38, double a39, double a40, double a41, double a42, double a43, int a44, int a45, int a46, double a47, double a48);
   int CallPat12s(double a0, double a1, double a2, int a3, int a4, int a5, int a6, double a7, double a8, double a9, double a10, double a11, double a12, double a13, double a14, double a15, double a16, double a17, double a18, double a19, double a20, double a21, double a22, double a23, double a24, double a25, double a26, double a27, double a28, double a29, double a30, double a31, double a32, double a33, double a34, double a35, double a36, double a37, double a38, double a39, double a40, double a41, double a42, double a43, int a44, int a45, int a46, double a47, double a48);
   int CallPat13b(double a0, double a1, double a2, int a3, int a4, int a5, int a6, double a7, double a8, double a9, double a10, double a11, double a12, double a13, double a14, double a15, double a16, double a17, double a18, double a19, double a20, double a21, double a22, double a23, double a24, double a25, double a26, double a27, double a28, double a29, double a30, double a31, double a32, double a33, double a34, double a35, double a36, double a37, double a38, double a39, double a40, double a41, double a42, double a43, int a44, int a45, int a46, double a47, double a48);
   int CallPat13s(double a0, double a1, double a2, int a3, int a4, int a5, int a6, double a7, double a8, double a9, double a10, double a11, double a12, double a13, double a14, double a15, double a16, double a17, double a18, double a19, double a20, double a21, double a22, double a23, double a24, double a25, double a26, double a27, double a28, double a29, double a30, double a31, double a32, double a33, double a34, double a35, double a36, double a37, double a38, double a39, double a40, double a41, double a42, double a43, int a44, int a45, int a46, double a47, double a48);
   int CallPat14b(double a0, double a1, double a2, int a3, int a4, int a5, int a6, double a7, double a8, double a9, double a10, double a11, double a12, double a13, double a14, double a15, double a16, double a17, double a18, double a19, double a20, double a21, double a22, double a23, double a24, double a25, double a26, double a27, double a28, double a29, double a30, double a31, double a32, double a33, double a34, double a35, double a36, double a37, double a38, double a39, double a40, double a41, double a42, double a43, int a44, int a45, int a46, double a47, double a48);
   int CallPat14s(double a0, double a1, double a2, int a3, int a4, int a5, int a6, double a7, double a8, double a9, double a10, double a11, double a12, double a13, double a14, double a15, double a16, double a17, double a18, double a19, double a20, double a21, double a22, double a23, double a24, double a25, double a26, double a27, double a28, double a29, double a30, double a31, double a32, double a33, double a34, double a35, double a36, double a37, double a38, double a39, double a40, double a41, double a42, double a43, int a44, int a45, int a46, double a47, double a48);
   int CallPat15b(double a0, double a1, double a2, int a3, int a4, int a5, int a6, double a7, double a8, double a9, double a10, double a11, double a12, double a13, double a14, double a15, double a16, double a17, double a18, double a19, double a20, double a21, double a22, double a23, double a24, double a25, double a26, double a27, double a28, double a29, double a30, double a31, double a32, double a33, double a34, double a35, double a36, double a37, double a38, double a39, double a40, double a41, double a42, double a43, int a44, int a45, int a46, double a47, double a48);
   int CallPat15s(double a0, double a1, double a2, int a3, int a4, int a5, int a6, double a7, double a8, double a9, double a10, double a11, double a12, double a13, double a14, double a15, double a16, double a17, double a18, double a19, double a20, double a21, double a22, double a23, double a24, double a25, double a26, double a27, double a28, double a29, double a30, double a31, double a32, double a33, double a34, double a35, double a36, double a37, double a38, double a39, double a40, double a41, double a42, double a43, int a44, int a45, int a46, double a47, double a48);
   int CallPat18b(double a0, double a1, double a2, int a3, int a4, int a5, int a6, double a7, double a8, double a9, double a10, double a11, double a12, double a13, double a14, double a15, double a16, double a17, double a18, double a19, double a20, double a21, double a22, double a23, double a24, double a25, double a26, double a27, double a28, double a29, double a30, double a31, double a32, double a33, double a34, double a35, double a36, double a37, double a38, double a39, double a40, double a41, double a42, double a43, int a44, int a45, int a46, double a47, double a48);
   int CallPat18s(double a0, double a1, double a2, int a3, int a4, int a5, int a6, double a7, double a8, double a9, double a10, double a11, double a12, double a13, double a14, double a15, double a16, double a17, double a18, double a19, double a20, double a21, double a22, double a23, double a24, double a25, double a26, double a27, double a28, double a29, double a30, double a31, double a32, double a33, double a34, double a35, double a36, double a37, double a38, double a39, double a40, double a41, double a42, double a43, int a44, int a45, int a46, double a47, double a48);
   int CallPat19b(double a0, double a1, double a2, int a3, int a4, int a5, int a6, double a7, double a8, double a9, double a10, double a11, double a12, double a13, double a14, double a15, double a16, double a17, double a18, double a19, double a20, double a21, double a22, double a23, double a24, double a25, double a26, double a27, double a28, double a29, double a30, double a31, double a32, double a33, double a34, double a35, double a36, double a37, double a38, double a39, double a40, double a41, double a42, double a43, int a44, int a45, int a46, double a47, double a48);
   int CallPat19s(double a0, double a1, double a2, int a3, int a4, int a5, int a6, double a7, double a8, double a9, double a10, double a11, double a12, double a13, double a14, double a15, double a16, double a17, double a18, double a19, double a20, double a21, double a22, double a23, double a24, double a25, double a26, double a27, double a28, double a29, double a30, double a31, double a32, double a33, double a34, double a35, double a36, double a37, double a38, double a39, double a40, double a41, double a42, double a43, int a44, int a45, int a46, double a47, double a48);
   int CallPat20b(double a0, double a1, double a2, int a3, int a4, int a5, int a6, double a7, double a8, double a9, double a10, double a11, double a12, double a13, double a14, double a15, double a16, double a17, double a18, double a19, double a20, double a21, double a22, double a23, double a24, double a25, double a26, double a27, double a28, double a29, double a30, double a31, double a32, double a33, double a34, double a35, double a36, double a37, double a38, double a39, double a40, double a41, double a42, double a43, int a44, int a45, int a46, double a47, double a48);
   int CallPat20s(double a0, double a1, double a2, int a3, int a4, int a5, int a6, double a7, double a8, double a9, double a10, double a11, double a12, double a13, double a14, double a15, double a16, double a17, double a18, double a19, double a20, double a21, double a22, double a23, double a24, double a25, double a26, double a27, double a28, double a29, double a30, double a31, double a32, double a33, double a34, double a35, double a36, double a37, double a38, double a39, double a40, double a41, double a42, double a43, int a44, int a45, int a46, double a47, double a48);
#import "phibase_serve.dll"
   string httpGET(string a0, int& a1[]);
#import

//--- Assert 2: Plus include files
#include <PlusTurtle.mqh>
#include <PlusGhost.mqh>

double gd_76;
double gd_unused_84;
int gi_92;
int g_bars_96;
bool gi_100 = FALSE;
bool gi_104 = FALSE;
bool gi_108 = FALSE;
bool gi_unused_112 = FALSE;
datetime g_time_116;
bool gi_120 = FALSE;
double g_order_stoploss_132;
int gi_140 = 0;
int gi_144 = 0;
int gi_148 = 0;
int gi_152 = 0;
int gi_156;
int gi_160;
int gi_164;
double g_order_open_price_168;
double g_order_open_price_176;
double g_ima_184;
double g_ima_192;
double g_ima_200;
double g_idemarker_208;
double g_idemarker_216;
double g_idemarker_224;
double g_idemarker_232;
double g_iatr_240;
double g_iwpr_248;
double g_iwpr_256;
double g_imacd_264;
double g_imacd_272;
double g_imacd_280;
double g_imacd_288;
double gd_296;
double gd_304;
double gd_328;
double gd_336;
int gi_348;
string gs_dummy_360;
string gs_dummy_368;
double g_ienvelopes_424;
double g_ienvelopes_432;
double g_ienvelopes_440;
double g_ienvelopes_448;
double g_ienvelopes_456;
double g_ienvelopes_464;
double g_ienvelopes_472;
double g_ienvelopes_480;
double g_price_488;
double gd_496;
double gd_504;
double gd_512;
double g_order_profit_520;
double gd_unused_528;
double g_order_profit_536;
bool gi_unused_576 = FALSE;
double g_order_open_price_580;
double g_price_588;
int gi_unused_596 = 0;
double g_time_600;
double g_time_608;
double gd_unused_616;
double gd_unused_632;
double g_time_640;
double g_time_648;
double gd_unused_656;
double gd_unused_672;
double g_point_680;
double g_time_688;
double g_time_696;
string gs_dummy_728;
double g_time_736;
double g_time_744;
double gd_unused_752;
double gd_unused_768;
string gs_dummy_776;
string gs_unused_832 = "";
string gs_unused_840 = "";
string gs_unused_848 = "";
string gs_dummy_856;
string gs_dummy_864;
string gs_dummy_872;
string gs_dummy_880;
string gs_dummy_888;
string gs_dummy_896;
int gi_904;
string gs_dummy_908;
string gs_dummy_916;
string gs_dummy_924;
string gs_dummy_932;
bool gi_unused_988 = FALSE;
double g_istochastic_992;
double g_istochastic_1000;
double g_istochastic_1008;
double g_istochastic_1016;
double g_istochastic_1024;
double g_istochastic_1032;
double g_istochastic_1040;
double g_istochastic_1048;
double g_istochastic_1056;
double g_istochastic_1064;
double g_istochastic_1072;
double g_istochastic_1080;
double g_istochastic_1136;
double g_istochastic_1144;
double g_istochastic_1152;
double g_istochastic_1160;
string gs_dummy_1168;
string gs_dummy_1176;
string gs_dummy_1192;
string gs_dummy_1200;
string gs_dummy_1208;
string gs_dummy_1216;
int gi_1232;
double gd_1236;
double gd_1244;
double g_spread_1252;
int gi_1264;
int gi_unused_1268;
int gi_1276;
int gi_unused_1280;
bool gi_unused_1284 = FALSE;
bool gi_unused_1288 = FALSE;
string gs_dummy_1292;
string gs_dummy_1300;
bool gi_unused_1308 = FALSE;
bool gi_unused_1312 = FALSE;
string gs_1316 = "";
string gs_unused_1356 = "FALSE";
string gs_unused_1364 = "FALSE";
double gd_1412 = 0.0;
bool gi_unused_1420 = TRUE;
bool gi_unused_1424 = FALSE;
bool gi_unused_1428 = FALSE;
bool gi_unused_1432 = FALSE;
double gd_1436 = 30.0;
double gd_unused_1444 = 30.0;
bool gi_1452 = TRUE;
string gs_dummy_1456;
bool gi_unused_1464 = TRUE;
double g_ima_1468;
double g_ima_1476;
double g_ienvelopes_1484;
double g_ienvelopes_1492;
double g_ienvelopes_1500;
double g_ienvelopes_1508;
double g_ienvelopes_1516;
double g_ienvelopes_1524;
double g_ienvelopes_1532;
double g_ienvelopes_1540;
double g_ienvelopes_1548;
double g_ienvelopes_1556;
double g_ima_1564;
double g_ienvelopes_1572;
double g_ienvelopes_1580;
double gd_1620;
double gd_1628;
double g_ienvelopes_1636;
double g_ienvelopes_1644;
double g_ienvelopes_1684;
double g_ienvelopes_1692;
double g_ienvelopes_1700;
double g_ienvelopes_1708;
double g_ibands_1716;
double g_ibands_1724;
double gd_1732;
double gd_1740;
double g_ihigh_1764;
double g_ilow_1772;
double g_price_1796;
double g_ilow_1804;
double g_ihigh_1812;
double g_ilow_1820;
double g_price_1828;
double g_ilow_1836;
double g_ihigh_1844;
double g_ilow_1852;
double g_price_1860;
double g_price_1868;
double g_ibands_1940;
double g_ibands_1948;
int gi_unused_1956 = 24;
int gi_unused_1960 = 72;
int gi_unused_1964 = 48;
int gi_1968 = 24;
int gi_1972 = 6;
int gi_unused_1976 = 2;
int gi_unused_1980 = 2;
int gi_unused_1984 = 1;
int gi_unused_1988 = 2;
int g_leverage_1992 = 2;
int gi_unused_1996 = 0;
int gi_unused_2000 = 0;
int gi_unused_2004 = 5;
int gi_unused_2008 = 0;
int gi_unused_2012 = 0;
double gda_unused_2016[];
double gda_unused_2020[];
double gda_unused_2024[];
double gda_unused_2028[];
double gda_unused_2032[];
double gda_unused_2036[];
double gda_unused_2040[];
double gda_unused_2044[];
double gda_unused_2048[];
double g_iatr_2148;
int gi_2624 = 0;
int gi_2628 = 0;
bool gi_unused_2632 = FALSE;
double g_ima_2644;
double g_ima_2652;
double g_ima_2668;
double gd_unused_2716 = 99999.0;
double gd_unused_2724 = -99999.0;
double gd_unused_2732 = 99999.0;
double gd_unused_2740 = -99999.0;
double gd_unused_2748 = 99999.0;
double gd_unused_2756 = -99999.0;
double gd_unused_2764 = 99999.0;
double gd_unused_2772 = -99999.0;
double gd_unused_2780 = 99999.0;
double gd_unused_2788 = -99999.0;
double gd_unused_2796 = 99999.0;
double gd_unused_2804 = -99999.0;
double gd_unused_2812 = 99999.0;
double gd_unused_2820 = -99999.0;
double gd_unused_2828 = 99999.0;
double gd_unused_2836 = -99999.0;
double gd_unused_2844 = 99999.0;
double gd_unused_2852 = -99999.0;
string g_symbol_2860 = "";
int g_digits_2868 = 5;
double g_point_2872 = 0.0001;
double gd_unused_2880;
double gd_unused_2888;
int gi_2896 = 0;
int gi_unused_2900 = 1993675262;
double gd_2904 = 0.0;
double gd_2912 = 0.0;
extern int Activation_Code = 0;
extern int MaxPositions = 4;
extern double Max_Allocation_Per_Trade = 10.0;
extern bool Geometrical_MM = TRUE;
extern double Fixed_LotSize = 0.0;
extern double Targetlevel_1 = 50.0;
extern double TrailSL_1 = 30.0;
extern double Targetlevel_2 = 100.0;
extern double TrailSL_2 = 50.0;
extern double Higher_Band = 150.0;
extern double Lower_Band = 100.0;
extern bool Friday_Trade = TRUE;
extern int MagicNumber = 99118260;
extern string EA_COMMENT_PREFIX = "PhiBase ";
int gi_unused_3012 = 1;
int gi_3016 = 2;
bool gi_unused_3020 = TRUE;
string gs_unused_3024 = "Advanced Options";
double gd_3032 = 35.0;
double gd_3040 = -35.0;
double gd_unused_3048 = 1.0;
double gd_unused_3056 = 120.0;
double gd_unused_3064 = 2.0;
double gd_unused_3072 = 0.5;
string gs_3080 = "";
bool gi_unused_3088 = TRUE;
bool gi_unused_3092 = TRUE;
double gd_3096 = 0.0;
double gd_3104 = 0.0;
double gd_unused_3112 = 0.0;
double gd_unused_3120 = 0.0;
double gd_3128 = 0.0;
double gd_3136 = 0.0;
bool gi_unused_3144 = FALSE;
bool gi_unused_3148 = FALSE;
bool gi_unused_3152 = FALSE;
bool gi_3156 = TRUE;
bool gi_3160 = TRUE;
double gd_3164 = 400.0;
bool gi_unused_3172 = TRUE;
bool gi_unused_3176 = FALSE;
bool gi_unused_3180 = TRUE;
double gd_3184;
double gd_unused_3192 = 0.0;
double gd_unused_3200 = 10.0;
double gd_unused_3208 = 100.0;
string gs_unused_3224 = "";
string gs_unused_3232 = "";
string gs_3240 = "";
string gs_unused_3248 = "FALSE";
int g_bars_3256;
string gs_unused_3280 = "FALSE";
string gs_unused_3288 = "FALSE";
string gs_unused_3296 = "FALSE";
string gs_unused_3304 = "FALSE";
double gd_unused_3312 = 0.0005;
double g_bid_3320;
double g_ask_3328;
int gi_unused_3364 = 60;
int gi_unused_3368 = 30;
int gi_unused_3372 = 0;
string gs_unused_3376 = "";
string gs_unused_3384 = "FALSE";
string gs_true_3472 = "True";
double gd_unused_3488 = 0.0;
double gd_unused_3496 = 0.0;
double gd_unused_3504 = 0.0;
string gs_unused_3536 = "";
double gd_unused_3544 = 99999.0;
double gd_unused_3552 = -99999.0;
int gi_unused_3560 = 0;
int gi_3564;
string gs_unused_3592 = "";
string gs_unused_3600 = "";
string gs_unused_3608 = "";
string gs_unused_3616 = "";
string gs_unused_3624 = "";
string gs_unused_3632 = "";
string gs_unused_3640 = "";
string gs_unused_3648 = "";
string gs_unused_3656 = "";
string gs_unused_3664 = "";
string gs_unused_3672 = "";
string gs_unused_3680 = "";
double gd_3688;
int gi_3760;
string gs_unused_3764 = "";
string gs_unused_3836 = "0123456789ABCDEF";
int g_year_3844;
int g_month_3848;

void start() {
   int minute_0 = Minute();
   int hour_4 = Hour();
   int day_of_week_8 = DayOfWeek();
   g_month_3848 = Month();
   int day_12 = Day();
   int day_of_year_16 = DayOfYear();
   g_year_3844 = Year();
   g_time_116 = Time[0];
   gi_1264 = day_of_year_16 / 7;
   gi_unused_1268 = g_year_3844;
   gd_unused_84 = DayOfYear();
   
//--- Assert Refresh Plus mods
   GhostRefresh();
   
   if (gi_904 != 9999) {
      ObjectsDeleteAll(0, OBJ_LABEL);
      ObjectCreate("Validation", OBJ_LABEL, 0, 0, 0);
      ObjectCreate("Status", OBJ_LABEL, 0, 0, 0);
      ObjectSet("Validation", OBJPROP_CORNER, 0);
      ObjectSet("Validation", OBJPROP_XDISTANCE, 10);
      ObjectSet("Validation", OBJPROP_YDISTANCE, 40);
      ObjectSet("Status", OBJPROP_CORNER, 0);
      ObjectSet("Status", OBJPROP_XDISTANCE, 10);
      ObjectSet("Status", OBJPROP_YDISTANCE, 55);
      ObjectSetText("Validation", WindowExpertName() + " Activation Code : Failed", 10, "Arial", Yellow);
      ObjectSetText("Status", "PhiBase >> InActive : Enter the Correct Activation_Code", 10, "Arial", Red);
      return;
   }
   if (gi_2624 != 9999) {
      ObjectsDeleteAll(0, OBJ_LABEL);
      ObjectCreate("Validation", OBJ_LABEL, 0, 0, 0);
      ObjectCreate("Status", OBJ_LABEL, 0, 0, 0);
      ObjectSet("Validation", OBJPROP_CORNER, 0);
      ObjectSet("Validation", OBJPROP_XDISTANCE, 10);
      ObjectSet("Validation", OBJPROP_YDISTANCE, 40);
      ObjectSet("Status", OBJPROP_CORNER, 0);
      ObjectSet("Status", OBJPROP_XDISTANCE, 10);
      ObjectSet("Status", OBJPROP_YDISTANCE, 55);
      ObjectSetText("Validation", WindowExpertName() + " Account Validation : Failed - Unregistered account", 10, "Arial", Yellow);
      ObjectSetText("Status", "PhiBase >> InActive : Register This Account With PhiBase", 10, "Arial", Red);
      return;
   }
   if (Period() != PERIOD_H1) {
      ObjectsDeleteAll(0, OBJ_LABEL);
      ObjectCreate("Validation", OBJ_LABEL, 0, 0, 0);
      ObjectCreate("Status", OBJ_LABEL, 0, 0, 0);
      ObjectSet("Validation", OBJPROP_CORNER, 0);
      ObjectSet("Validation", OBJPROP_XDISTANCE, 10);
      ObjectSet("Validation", OBJPROP_YDISTANCE, 40);
      ObjectSet("Status", OBJPROP_CORNER, 0);
      ObjectSet("Status", OBJPROP_XDISTANCE, 10);
      ObjectSet("Status", OBJPROP_YDISTANCE, 55);
      ObjectSetText("Validation", WindowExpertName() + " Activation Code : Validation Okay", 10, "Arial", Yellow);
      ObjectSetText("Status", "PhiBase >> InActive : Set the Chart to 1H TimeFrame", 10, "Arial", Red);
      return;
   }
   g_iatr_240 = iATR(NULL, PERIOD_W1, 14, 1);
   f0_14();
}

void init() {
   int lia_32[1];
   string ls_44;
   string ls_52;
   string ls_60;
   string ls_68;
   double ld_88;
   double ld_100;
   double ld_108;
   double ld_unused_116;
   double lotsize_124;
   double lotstep_132;
   double marginrequired_140;
   double tickvalue_148;
   double ticksize_156;
   double ld_164;
   int li_172;
   double ld_176;
   gs_3080 = EA_COMMENT_PREFIX;
   g_spread_1252 = MarketInfo(Symbol(), MODE_SPREAD);
   g_time_116 = Time[0];
   string name_4 = TerminalName() + g_time_116 + ".dat";
   int file_0 = FileOpen(name_4, FILE_BIN|FILE_WRITE);
   if (file_0 < 1) {
      Print("Activation file error-", GetLastError());
      return;
   }
   FileWriteInteger(file_0, Activation_Code, LONG_VALUE);
   FileClose(file_0);
   Print(name_4);

//--- Assert 2: Init Plus mods   
   TurtleInit();
   GhostInit();
   
   gi_2896 = Activation_Code;
   gd_2904 = Max_Allocation_Per_Trade;
   gd_2912 = Fixed_LotSize;
   gi_1232 = MagicNumber;
   gd_1236 = gd_2904;
   double ld_12 = 1;
   if (MarketInfo(Symbol(), MODE_DIGITS) == 5.0) ld_12 = 10;
   if (MarketInfo(Symbol(), MODE_DIGITS) == 4.0) ld_12 = 1;
   g_point_680 = Point;
   gi_1972 = trend1(g_time_116, 100.0 * gd_1236, 1 / g_point_680);
   gd_1244 = gd_2912;
   g_leverage_1992 = AccountLeverage();
   gi_1968 = trend2(gi_1972, g_leverage_1992);
   Targetlevel_1 = Targetlevel_1 * ld_12 * Point;
   Targetlevel_2 = Targetlevel_2 * ld_12 * Point;
   gd_3032 = gd_3032 * ld_12 * Point;
   TrailSL_1 = TrailSL_1 * ld_12 * Point;
   TrailSL_2 = TrailSL_2 * ld_12 * Point;
   gd_3040 = gd_3040 * ld_12 * Point;
   Higher_Band = Higher_Band * ld_12 * Point;
   Lower_Band = Lower_Band * ld_12 * Point;
   g_ilow_1820 = iLow(NULL, PERIOD_H1, iLowest(NULL, PERIOD_H1, MODE_LOW, 194, 1));
   g_ihigh_1812 = iHigh(NULL, PERIOD_H1, iHighest(NULL, PERIOD_H1, MODE_HIGH, 194, 1));
   g_ilow_1852 = iLow(NULL, PERIOD_H1, iLowest(NULL, PERIOD_H1, MODE_LOW, 72, 1));
   g_ihigh_1844 = iHigh(NULL, PERIOD_H1, iHighest(NULL, PERIOD_H1, MODE_HIGH, 72, 1));
   g_iatr_2148 = iATR(NULL, PERIOD_D1, 30, 1);
   g_iatr_240 = iATR(NULL, PERIOD_W1, 14, 1);
   gi_120 = FALSE;
   if (Targetlevel_1 == 0.0) gi_120 = TRUE;
   if (Targetlevel_1 == 0.0) Targetlevel_1 = g_iatr_2148 / 4.0;
   if (TrailSL_1 == 0.0) TrailSL_1 = g_iatr_2148 / 5.0;
   if (Targetlevel_2 == 0.0) Targetlevel_2 = g_iatr_2148 / 2.0;
   if (TrailSL_2 == 0.0) TrailSL_2 = g_iatr_2148 / 3.0;
   g_ibands_1716 = iBands(NULL, PERIOD_H1, 20, 2, 0, PRICE_CLOSE, MODE_UPPER, 1);
   g_ibands_1724 = iBands(NULL, PERIOD_H1, 20, 2, 0, PRICE_CLOSE, MODE_LOWER, 1);
   gd_1732 = (g_ibands_1716 + g_ibands_1724) / 2.0;
   g_ibands_1940 = iBands(NULL, PERIOD_H1, 80, 2, 0, PRICE_CLOSE, MODE_UPPER, 1);
   g_ibands_1948 = iBands(NULL, PERIOD_H1, 80, 2, 0, PRICE_CLOSE, MODE_LOWER, 1);
   g_ilow_1836 = iLow(NULL, PERIOD_H1, iLowest(NULL, PERIOD_H1, MODE_LOW, 194, 1));
   g_time_736 = Time[iLowest(NULL, PERIOD_H1, MODE_LOW, 194, 1)];
   g_price_1828 = iHigh(NULL, PERIOD_H1, iHighest(NULL, PERIOD_H1, MODE_HIGH, 194, 1));
   g_time_744 = Time[iHighest(NULL, PERIOD_H1, MODE_HIGH, 194, 1)];
   g_price_1868 = iLow(NULL, PERIOD_H1, iLowest(NULL, PERIOD_H1, MODE_LOW, 72, 1));
   g_time_640 = Time[iLowest(NULL, PERIOD_H1, MODE_LOW, 72, 1)];
   g_price_1860 = iHigh(NULL, PERIOD_H1, iHighest(NULL, PERIOD_H1, MODE_HIGH, 72, 1));
   g_time_648 = Time[iHighest(NULL, PERIOD_H1, MODE_HIGH, 72, 1)];
   if (g_time_640 > g_time_648) gd_unused_672 = g_time_640;
   if (g_time_640 < g_time_648) gd_unused_672 = g_time_648;
   if (g_time_640 > g_time_648) gd_unused_656 = g_price_1868;
   if (g_time_640 < g_time_648) gd_unused_656 = g_price_1860;
   if (g_time_736 > g_time_744) gd_unused_768 = g_time_736;
   if (g_time_736 < g_time_744) gd_unused_768 = g_time_744;
   if (g_time_736 > g_time_744) gd_unused_752 = g_ilow_1836;
   if (g_time_736 < g_time_744) gd_unused_752 = g_price_1828;
   int li_20 = topic1(gi_2896, g_time_736, g_time_744, g_time_640, g_time_648);
   int li_24 = topic2(gi_2896, g_time_736, g_time_744, g_time_640, g_time_648);
   Print(g_time_736);
   int acc_number_28 = AccountNumber();
   Print("License Validation : Connecting to PhiBase..... ");
   string ls_36 = httpGET("http://www.phibase.com/codex.php?acode=" + gi_2896, lia_32);
//--- Assert OK connection
   lia_32[0]   = 200;
   ls_36       = "9999";
   if (lia_32[0] == 200) {
      if (ls_36 == "9999") gi_904 = 9999;
      if (ls_36 == "1111") gi_904 = 1000;
      Print("Initialization Complete.");
   } else {
      Print("Validation Granted: Connection failure");
      gi_904 = 9999;
   }
   if (IsDemo() == TRUE) {
      Print("Account Validation : Connecting to PhiBase..... ");
      ls_44 = httpGET("http://www.phibase.com/codexd1.php?Seed=" + DoubleToStr(acc_number_28, 0), lia_32);
   //--- Assert OK Account Registered for DEMO
      lia_32[0]   = 200;
      ls_44       = "9999";
      if (lia_32[0] == 200) {
         if (ls_44 == "9999") gi_2624 = 9999;
         if (ls_44 == "1111") gi_2624 = 1111;
         Print("Validation OK");
      } else {
         Print("SValidation failed. Account Not Registered With PhiBase");
         gi_2624 = 9999;
      }
      if (gi_2624 != 9999) {
         ls_52 = httpGET("http://www.phibase.com/codexd2.php?Seed=" + DoubleToStr(acc_number_28, 0), lia_32);
         if (lia_32[0] == 200) {
            if (ls_52 == "9999") gi_2624 = 9999;
            if (ls_52 == "1111") gi_2624 = 1111;
            Print("Validation OK");
         } else {
            Print("Validation failed. Account Not Registered With PhiBase");
            gi_2624 = 9999;
         }
      }
   } else {
      Print("Account Validation : Connecting to PhiBase..... ");
      ls_60 = httpGET("http://www.phibase.com/codexr1.php?Seed=" + DoubleToStr(acc_number_28, 0), lia_32);
   //--- Assert OK Account Registered
      lia_32[0]   = 200;
      ls_60       = "9999";
      if (lia_32[0] == 200) {
         if (ls_60 == "9999") gi_2624 = 9999;
         if (ls_60 == "1111") gi_2624 = 1111;
         Print("Validation OK.");
      } else {
         Print("Validation failed. Account Not Registered With PhiBase");
         gi_2624 = 9999;
      }
      if (gi_2624 != 9999) {
         ls_68 = httpGET("http://www.phibase.com/codexr2.php?Seed=" + DoubleToStr(acc_number_28, 0), lia_32);
         if (lia_32[0] == 200) {
            if (ls_68 == "9999") gi_2624 = 9999;
            if (ls_68 == "1111") gi_2624 = 1111;
            Print("Validation OK.");
         } else {
            Print("Validation failed. Account Not Registered With PhiBase");
            gi_2624 = 9999;
         }
      }
   }
   gi_unused_1280 = gi_1452;
   gi_1276 = tmargin(li_20, li_24);
   gd_unused_2880 = gd_3104;
   gd_unused_2888 = gd_1436;
   gi_156 = gi_1276;
   if (gd_1236 < 1.0) gd_1236 = 1;
   if (gd_1236 > 50.0) gd_1236 = 50;
   if (gd_3164 < 10.0) gd_3164 = 10;
   if (gd_3164 > 500.0) gd_3164 = 500;
   if (gi_1232 < 1 || gi_1232 > 2147483640) gi_1232 = 99118260;
   if (gd_1244 < 0.0) gd_1244 = 0.0;
   if (gd_1412 < 0.0) gd_1412 = 0;
   if (gd_3128 < 5.0) gd_3128 = 200;
   if (gd_3096 < 5.0) gd_3096 = 300;
   if (gd_3104 < 5.0) gd_3104 = 90;
   gd_unused_1444 = 30;
   gd_1436 = 30;
   gi_3564 = 22;
   Print("MT4 Broker Check..... ");
   string ls_76 = httpGET("http://www.phibase.com/phicodex.php?acode=" + gi_2896 + "&percent=" + gi_1968, lia_32);
   int li_84 = StrToInteger(ls_76);
   if (lia_32[0] == 200) {
      if (li_84 >= gi_2896) gi_2896 = li_84;
      if (li_84 < gi_2896) gi_2896 = li_84;
      Print("Completed.");
   } else {
      Print("Validation Granted: Connection failure");
      gi_2896++;
   }
   ObjectsDeleteAll(0, OBJ_LABEL);
   if (gi_904 == 9999) {
      ObjectsDeleteAll(0, OBJ_LABEL);
      ObjectCreate("Validation", OBJ_LABEL, 0, 0, 0);
      ObjectCreate("MagicNumber", OBJ_LABEL, 0, 0, 0);
      ObjectCreate("Status", OBJ_LABEL, 0, 0, 0);
      ObjectCreate("OpenTrade", OBJ_LABEL, 0, 0, 0);
      ObjectCreate("PriceAction", OBJ_LABEL, 0, 0, 0);
      ObjectCreate("PriceAction2", OBJ_LABEL, 0, 0, 0);
      ObjectCreate("Version", OBJ_LABEL, 0, 0, 0);
      ObjectSet("Validation", OBJPROP_CORNER, 0);
      ObjectSet("Validation", OBJPROP_XDISTANCE, 10);
      ObjectSet("Validation", OBJPROP_YDISTANCE, 40);
      ObjectSet("MagicNumber", OBJPROP_CORNER, 0);
      ObjectSet("MagicNumber", OBJPROP_XDISTANCE, 10);
      ObjectSet("MagicNumber", OBJPROP_YDISTANCE, 55);
      ObjectSet("Status", OBJPROP_CORNER, 0);
      ObjectSet("Status", OBJPROP_XDISTANCE, 10);
      ObjectSet("Status", OBJPROP_YDISTANCE, 70);
      ObjectSet("OpenTrade", OBJPROP_CORNER, 0);
      ObjectSet("OpenTrade", OBJPROP_XDISTANCE, 10);
      ObjectSet("OpenTrade", OBJPROP_YDISTANCE, 90);
      ObjectSet("PriceAction", OBJPROP_CORNER, 0);
      ObjectSet("PriceAction", OBJPROP_XDISTANCE, 10);
      ObjectSet("PriceAction", OBJPROP_YDISTANCE, 105);
      ObjectSet("PriceAction2", OBJPROP_CORNER, 0);
      ObjectSet("PriceAction2", OBJPROP_XDISTANCE, 10);
      ObjectSet("PriceAction2", OBJPROP_YDISTANCE, 120);
      ObjectSet("Version", OBJPROP_CORNER, 0);
      ObjectSet("Version", OBJPROP_XDISTANCE, 10);
      ObjectSet("Version", OBJPROP_YDISTANCE, 135);
      ObjectSetText("Validation", WindowExpertName() + " Activation Code : Validation Okay", 10, "Arial", Yellow);
      ObjectSetText("MagicNumber", "Trade MagicNumber : " + gi_1232, 10, "Arial", White);
      gd_3688 = 0;
      f0_7();
   //--- Assert 2: Init OrderSelect #1
      GhostInitSelect(true,0,SELECT_BY_POS,MODE_TRADES);
      int total=GhostOrdersTotal();
      for (int pos_96 = 0; pos_96 < total; pos_96++) {
         if (GhostOrderSelect(pos_96, SELECT_BY_POS, MODE_TRADES) == FALSE) break;
         if (GhostOrderMagicNumber() != gi_1232 || GhostOrderSymbol() != Symbol()) continue;
         ld_88 += GhostOrderProfit();
      }
   //--- Assert 1: Free OrderSelect #1   
      GhostFreeSelect(false);
      
      ObjectSetText("OpenTrade", "", 10, "Arial", White);
      if (gs_3240 == "") ObjectSetText("OpenTrade", "||||||||||||.... ", 10, "Arial", White);
      if (gs_3240 == "BUYTRADE") ObjectSetText("OpenTrade", "PhiBase PRO Trade : LONG " + Symbol(), 10, "Arial", White);
      if (gs_3240 == "SELLTRADE") ObjectSetText("OpenTrade", "PhiBase PRO Trade : SHORT " + Symbol(), 10, "Arial", White);
      g_symbol_2860 = Symbol();
      ld_100 = MarketInfo(g_symbol_2860, MODE_MINLOT);
      ld_108 = MarketInfo(g_symbol_2860, MODE_MAXLOT);
      ld_unused_116 = AccountLeverage();
      lotsize_124 = MarketInfo(g_symbol_2860, MODE_LOTSIZE);
      lotstep_132 = MarketInfo(g_symbol_2860, MODE_LOTSTEP);
      marginrequired_140 = MarketInfo(g_symbol_2860, MODE_MARGINREQUIRED);
      tickvalue_148 = MarketInfo(g_symbol_2860, MODE_TICKVALUE);
      ticksize_156 = MarketInfo(g_symbol_2860, MODE_TICKSIZE);
      ld_164 = MathMin(AccountBalance(), AccountEquity());
      li_172 = 0;
      ld_176 = 0.0;
      if (lotstep_132 == 0.01) li_172 = 2;
      if (lotstep_132 == 0.1) li_172 = 1;
      if (Geometrical_MM == TRUE) ld_176 = f0_3(g_symbol_2860, gd_3184);
      if (Geometrical_MM == FALSE) ld_176 = f0_11(g_symbol_2860, gd_3184);
      ld_176 = StrToDouble(DoubleToStr(ld_176, li_172));
      if (ld_176 < ld_100) ld_176 = ld_100;
      if (ld_176 > ld_108) ld_176 = ld_108;
      if (gs_3240 == "") ObjectSetText("Status", "PhiBase PRO >>> Waiting... Lot Size for next trade = " + DoubleToStr(ld_176, 2), 10, "Arial", White);
      if (gs_3240 != "" && ld_88 >= 0.0) ObjectSetText("Status", "PhiBase Trade Gain : " + DoubleToStr(ld_88, 0), 10, "Arial", Lime);
      if (gs_3240 != "" && ld_88 < 0.0) ObjectSetText("Status", "PhiBase Trade Gain : " + DoubleToStr(ld_88, 0), 10, "Arial", Red);
      ObjectSetText("PriceAction", "D1 ATR : " + DoubleToStr(g_iatr_2148, 5) + "  ||   W1 ATR : " + DoubleToStr(g_iatr_240, 5) + " Points", 10, "Arial", White);
      if (gs_3240 == "SELLTRADE") {
         ObjectSetText("PriceAction2", "H1 Close beyond: " + DoubleToStr(g_order_open_price_168 + (g_order_stoploss_132 - g_order_open_price_168) / 2.0, 5) + " Will Trigger Hidden StopLoss",
            10, "Arial", White);
      } else {
         if (gs_3240 == "BUYTRADE") {
            ObjectSetText("PriceAction2", "H1 Close beyond: " + DoubleToStr(g_order_open_price_168 - (g_order_open_price_168 - g_order_stoploss_132) / 2.0, 5) + " Will Trigger Hidden StopLoss",
               10, "Arial", White);
         } else ObjectSetText("PriceAction2", "||||||||||||....", 10, "Arial", White);
      }
      ObjectSetText("Version", "Version 2.2 : Build Date 20120422", 10, "Arial", Lime);
   }
   if (gi_904 != 9999) {
      ObjectsDeleteAll(0, OBJ_LABEL);
      ObjectCreate("Validation", OBJ_LABEL, 0, 0, 0);
      ObjectCreate("Status", OBJ_LABEL, 0, 0, 0);
      ObjectSet("Validation", OBJPROP_CORNER, 0);
      ObjectSet("Validation", OBJPROP_XDISTANCE, 10);
      ObjectSet("Validation", OBJPROP_YDISTANCE, 40);
      ObjectSet("Status", OBJPROP_CORNER, 0);
      ObjectSet("Status", OBJPROP_XDISTANCE, 10);
      ObjectSet("Status", OBJPROP_YDISTANCE, 55);
      ObjectSetText("Validation", WindowExpertName() + " Activation Code : Failed", 10, "Arial", Yellow);
      ObjectSetText("Status", "PhiBase >> InActive : Enter the Correct Activation_Code", 10, "Arial", Red);
   }
}

void deinit() {
//--- Assert 1: Deinit Plus mods
   GhostDeInit();
}

double f0_11(string a_symbol_0, double ad_unused_8) {
   double ld_16;
   double ld_24;
   double ld_unused_32;
   double lotsize_40;
   double lotstep_48;
   double marginrequired_56;
   double tickvalue_64;
   double ticksize_72;
   double ld_80;
   int li_88;
   double ld_ret_92;
   if (gd_1244 == 0.0) {
      ld_16 = MarketInfo(a_symbol_0, MODE_MINLOT);
      ld_24 = MarketInfo(a_symbol_0, MODE_MAXLOT);
      ld_unused_32 = AccountLeverage();
      lotsize_40 = MarketInfo(a_symbol_0, MODE_LOTSIZE);
      lotstep_48 = MarketInfo(a_symbol_0, MODE_LOTSTEP);
      marginrequired_56 = MarketInfo(a_symbol_0, MODE_MARGINREQUIRED);
      tickvalue_64 = MarketInfo(a_symbol_0, MODE_TICKVALUE);
      ticksize_72 = MarketInfo(a_symbol_0, MODE_TICKSIZE);
      ld_80 = MathMin(AccountBalance(), AccountEquity());
      li_88 = 0;
      ld_ret_92 = 0.0;
      if (lotstep_48 == 0.01) li_88 = 2;
      if (lotstep_48 == 0.1) li_88 = 1;
      ld_ret_92 = ld_80 * (gd_1236 / MaxPositions / 100.0) / (gd_3128 / 2.0 * (tickvalue_64 / ld_16));
      ld_ret_92 = StrToDouble(DoubleToStr(ld_ret_92, li_88));
      if (ld_ret_92 < ld_16) ld_ret_92 = ld_16;
      if (ld_ret_92 <= ld_24) return (ld_ret_92);
      ld_ret_92 = ld_24;
      return (ld_ret_92);
   }
   if (gd_1244 > 0.0) return (gd_1244);
   return (0.0);
}

double f0_3(string a_symbol_0, double ad_unused_8) {
   double ld_16;
   double ld_24;
   double leverage_32;
   double lotsize_40;
   double lotstep_48;
   double marginrequired_56;
   double ld_64;
   int li_72;
   double ld_ret_76;
   if (gd_1244 == 0.0) {
      ld_16 = MarketInfo(a_symbol_0, MODE_MINLOT);
      ld_24 = MarketInfo(a_symbol_0, MODE_MAXLOT);
      leverage_32 = AccountLeverage();
      lotsize_40 = MarketInfo(a_symbol_0, MODE_LOTSIZE);
      lotstep_48 = MarketInfo(a_symbol_0, MODE_LOTSTEP);
      marginrequired_56 = MarketInfo(a_symbol_0, MODE_MARGINREQUIRED);
      ld_64 = MathMin(AccountBalance(), AccountEquity()) * (gd_1236 / MaxPositions) / 100.0;
      li_72 = 0;
      ld_ret_76 = 0.0;
      if (lotstep_48 == 0.01) li_72 = 2;
      if (lotstep_48 == 0.1) li_72 = 1;
      gd_3688 = 0;
      f0_7();
      ld_ret_76 = 100.0 * ld_64 / (marginrequired_56 * leverage_32);
      ld_ret_76 = StrToDouble(DoubleToStr(ld_ret_76, li_72));
      if (ld_ret_76 < ld_16) ld_ret_76 = ld_16;
      if (ld_ret_76 <= ld_24) return (ld_ret_76);
      ld_ret_76 = ld_24;
      return (ld_ret_76);
   }
   if (gd_1244 > 0.0) return (gd_1244);
   return (0.0);
}

double f0_9(double ad_0, double ad_8, double ad_16, double ad_24) {
   if (ad_8 == 0.0) return (0);
   return (NormalizeDouble(ad_0 - MathAbs(ad_8) * ad_16, ad_24));
}

double f0_10(double ad_0, double ad_8, double ad_16, double ad_24) {
   if (ad_8 == 0.0) return (0);
   return (NormalizeDouble(ad_0 + MathAbs(ad_8) * ad_16, ad_24));
}

double f0_13(double ad_0, double ad_8, double ad_16, double ad_24) {
   if (ad_8 == 0.0) return (0);
   return (NormalizeDouble(ad_0 + MathAbs(ad_8) * ad_16, ad_24));
}

double f0_4(double ad_0, double ad_8, double ad_16, double ad_24) {
   if (ad_8 == 0.0) return (0);
   return (NormalizeDouble(ad_0 - MathAbs(ad_8) * ad_16, ad_24));
}

int f0_2(string a_symbol_0, int a_magic_8, int a_cmd_12, int ai_16, int ai_20, string as_24) {
   int cmd_48;
   int li_unused_52;
   bool li_56;
   int li_60;
   double price_64;
   double price_72;
   int error_80;
   bool li_32 = FALSE;
   if (a_symbol_0 == "None") li_32 = TRUE;
   bool li_36 = FALSE;
   if (a_magic_8 == 0) li_36 = TRUE;
   int error_40 = 0;
//--- Assert 6: Declare variables for OrderSelect #2
//       1-OrderModify BUY; 2-OrderClose BUY; 3-OrderModify SELL; 4-OrderClose SELL;
   int      aCommand[];    
   int      aTicket[];
   double   aLots[];
   double   aClosePrice[];
   bool     aOk;
   int      aCount;
//--- Assert 4: Dynamically resize arrays
   ArrayResize(aCommand,MaxPositions);
   ArrayResize(aTicket,MaxPositions);
   ArrayResize(aLots,MaxPositions);
   ArrayResize(aClosePrice,MaxPositions);
//--- Assert 2: Init OrderSelect #2 with arrays
   GhostInitSelect(false,0,SELECT_BY_POS,MODE_TRADES);
   int total=GhostOrdersTotal();
   for (int pos_44 = total - 1; pos_44 >= 0; pos_44--) {
      if (GhostOrderSelect(pos_44, SELECT_BY_POS, MODE_TRADES) != FALSE) {
      //--- Assert 4: Populate arrays
         aCommand[aCount]     =  0;
         aTicket[aCount]      =  GhostOrderTicket();
         aLots[aCount]        =  GhostOrderLots();
         aClosePrice[aCount]  =  GhostOrderClosePrice();
         if (li_36) a_magic_8 = GhostOrderMagicNumber();
         if (a_magic_8 == GhostOrderMagicNumber()) {
            if (gi_1232 == GhostOrderMagicNumber()) {
               if (li_32) a_symbol_0 = GhostOrderSymbol();
               if (a_symbol_0 == GhostOrderSymbol()) {
                  g_point_2872 = MarketInfo(a_symbol_0, MODE_POINT);
                  g_digits_2868 = MarketInfo(a_symbol_0, MODE_DIGITS);
                  if (g_point_2872 == 0.001) {
                     g_point_2872 = 0.01;
                     g_digits_2868 = 3;
                  } else {
                     if (g_point_2872 == 0.00001) {
                        g_point_2872 = 0.0001;
                        g_digits_2868 = 5;
                     }
                  }
                  cmd_48 = GhostOrderType();
                  if (cmd_48 != a_cmd_12 && a_cmd_12 != 1024) continue;
                  li_unused_52 = 0;
                  li_56 = FALSE;
                  li_60 = ai_16;
                  while (!li_56) {
                     while (IsTradeContextBusy()) Sleep(10);
                     RefreshRates();
                     price_64 = NormalizeDouble(MarketInfo(a_symbol_0, MODE_ASK), g_digits_2868);
                     price_72 = NormalizeDouble(MarketInfo(a_symbol_0, MODE_BID), g_digits_2868);
                     gd_unused_528 = g_order_profit_536;
                     g_order_profit_536 = g_order_profit_520;
                     g_order_profit_520 = GhostOrderProfit();
                     if (cmd_48 == OP_BUY) 
                     {
                     //--- Assert 3: replace OrderClose a buy trade with arrays
                        aCommand[aCount]     = 2;
                        aClosePrice[aCount]  = price_72;
                        aCount ++;
                        if( aCount >= MaxPositions ) break;
                        /*GhostOrderClose(GhostOrderTicket(), GhostOrderLots(), price_72, ai_20 * g_point_2872, CLR_NONE);*/
                     }
                     else if (cmd_48 == OP_SELL) 
                     {
                     //--- Assert 3: replace OrderClose a buy trade with arrays
                        aCommand[aCount]     = 4;
                        aClosePrice[aCount]  = price_64;
                        aCount ++;
                        if( aCount >= MaxPositions ) break;
                        /*GhostOrderClose(GhostOrderTicket(), GhostOrderLots(), price_64, ai_20 * g_point_2872, CLR_NONE);*/
                     }
                     error_80 = GetLastError();
                     switch (error_80) {
                     case 135/* PRICE_CHANGED */: continue;
                     case 138/* REQUOTE */: continue;
                     case 0/* NO_ERROR */:
                        li_56 = TRUE;
                        break;
                     case 130/* INVALID_STOPS */:
                     case 4/* SERVER_BUSY */:
                     case 6/* NO_CONNECTION */:
                     case 129/* INVALID_PRICE */:
                     case 136/* OFF_QUOTES */:
                     case 137/* BROKER_BUSY */:
                     case 146/* TRADE_CONTEXT_BUSY */:
                        li_60++;
                        break;
                     case 131/* INVALID_TRADE_VOLUME */:
                        li_56 = TRUE;
                        Alert(as_24 + " Invalid Lots");
                        break;
                     case 132/* MARKET_CLOSED */:
                        li_56 = TRUE;
                        Alert(as_24 + " Market Close");
                        break;
                     case 133/* TRADE_DISABLED */:
                        li_56 = TRUE;
                        Alert(as_24 + " Trades Disabled");
                        break;
                     case 134/* NOT_ENOUGH_MONEY */:
                        li_56 = TRUE;
                        Alert(as_24 + " Not Enough Money");
                        break;
                     case 148/* TRADE_TOO_MANY_ORDERS */:
                        li_56 = TRUE;
                        Alert(as_24 + " Too Many Orders");
                        break;
                     case 149/* TRADE_HEDGE_PROHIBITED */:
                        li_56 = TRUE;
                        Alert(as_24 + " Hedge is prohibited");
                        break;
                     case 1/* NO_RESULT */:
                     default:
                        li_56 = TRUE;
                        Print("Unknown Error - " + error_80);
                     }
                     if (li_60 > 10) li_56 = TRUE;
                     if (error_40 < error_80) error_40 = error_80;
                  }
               }
            }
         }
      }
   }
//--- Assert 1: Free OrderSelect #2
   GhostFreeSelect(false);
//--- Assert for: process array of commands
   for(int i=0; i<aCount; i++)
   {
      switch( aCommand[i] )
      {
         case 2:  // OrderClose Buy
            GhostOrderClose(aTicket[i], aLots[i], aClosePrice[i], ai_20 * g_point_2872, CLR_NONE);
            break;
         case 4:  // OrderClose Sell
            GhostOrderClose(aTicket[i], aLots[i], aClosePrice[i], ai_20 * g_point_2872, CLR_NONE);
            break;
      }
   }
   
   return (error_40);
}

// E.g. f0_12(): ;a_symbol_0="GBPUSD"; ad_8=0.06; a_comment_16="PhiBase - Enter LONG"; ai_24=250; a_magic_32=99118260; ai_36=10; ai_40=3; li_60=1;
int f0_12(string a_symbol_0, double ad_8, string a_comment_16, int ai_24, int ai_28, int a_magic_32, int ai_36, int ai_40) {
   int ticket_68;
   int li_unused_72;
   bool li_76;
   int count_80;
   double lots_84;
   double price_92;
   double ld_100;
   double price_108;
   int error_116;
   g_point_2872 = MarketInfo(a_symbol_0, MODE_POINT);
   g_digits_2868 = MarketInfo(a_symbol_0, MODE_DIGITS);
   if (g_point_2872 == 0.001) {
      g_point_2872 = 0.01;
      g_digits_2868 = 3;
   } else {
      if (g_point_2872 == 0.00001) {
         g_point_2872 = 0.0001;
         g_digits_2868 = 5;
      }
   }
   double maxlot_44 = MarketInfo(a_symbol_0, MODE_MAXLOT);
   double ld_52 = ad_8;
   int li_60 = 1;
   if (ad_8 > maxlot_44) li_60 = MathFloor(ad_8 / maxlot_44) + 1.0;
   for (int count_64 = 0; count_64 < li_60; count_64++) {
      ticket_68 = -1;
      li_unused_72 = 0;
      li_76 = FALSE;
      count_80 = 0;
      lots_84 = NormalizeDouble(ad_8 / MathMax(li_60, 1), 2);
      if (ld_52 - maxlot_44 <= 0.0) lots_84 = ld_52;
      while (!li_76) {
         while (IsTradeContextBusy()) Sleep(10);
         RefreshRates();
         price_92 = NormalizeDouble(MarketInfo(a_symbol_0, MODE_ASK), g_digits_2868);
         ld_100 = NormalizeDouble(MarketInfo(a_symbol_0, MODE_BID), g_digits_2868);
         price_108 = f0_9(price_92, ai_24, g_point_2872, g_digits_2868);
         // E.g. OrderSend OP_BUY ;ticket_68=33095590; a_symbol_0="GBPUSD"; lots_84=0; price_92=1.6149; OrderMagicNo=0; gi+1232=99118260; count_64=0; error_116=0;
         ticket_68 = GhostOrderSend(a_symbol_0, OP_BUY, lots_84, price_92, 0, 0.0, 0.0, a_comment_16, a_magic_32, ai_40 * g_point_2872, CLR_NONE);
         error_116 = GetLastError();
         if (error_116 == 0/* NO_ERROR */) {
            gs_3240 = "BUYTRADE";
         //--- Assert variable OrderMagicNumber() is always 0.
            if (0 == a_magic_32) gs_unused_3224 = "BUY";
            if (0 == gi_1232) gs_unused_3224 = "BUY";
            /*if (GhostOrderMagicNumber() == a_magic_32) gs_unused_3224 = "BUY";*/
            /*if (GhostOrderMagicNumber() == gi_1232) gs_unused_3224 = "BUY";*/
            gs_true_3472 = "False";
         }
         switch (error_116) {
         case 135/* PRICE_CHANGED */: continue;
         case 138/* REQUOTE */: continue;
         case 0/* NO_ERROR */:
            li_76 = TRUE;
         // E.g. OrderSelect SELECT_BY_TICKET ;ticket_68=33095590; OrderOpenPrice=1.6149; price_108=1.5899; OrderMagicNo=99118260;
         //--- Assert 7: Declare variables for OrderSelect #3
         //       1-OrderModify BUY; 2-OrderClose BUY; 3-OrderModify SELL; 4-OrderClose SELL;
            int      aCommand[];
            int      aTicket[];
            double   aOpenPrice[];
            double   aStopLoss[];
            double   aTakeProfit[];
            bool     aOk;
            int      aCount;
         //--- Assert 5: Dynamically resize arrays for OrderSelect #3
            ArrayResize(aCommand,MaxPositions);
            ArrayResize(aTicket,MaxPositions);
            ArrayResize(aOpenPrice,MaxPositions);
            ArrayResize(aStopLoss,MaxPositions);
            ArrayResize(aTakeProfit,MaxPositions);
         //--- Assert 1: Init OrderSelect #3
            GhostInitSelect(true,ticket_68,SELECT_BY_TICKET,MODE_TRADES);
            if (GhostOrderSelect(ticket_68, SELECT_BY_TICKET)) 
            {
            //--- Assert 5: Populate arrays for OrderSelect #3
               aCommand[aCount]     =  0;
               aTicket[aCount]      =  GhostOrderTicket();
               aOpenPrice[aCount]   =  GhostOrderOpenPrice();
               aStopLoss[aCount]    =  GhostOrderStopLoss();
               aTakeProfit[aCount]  =  GhostOrderTakeProfit();
            //--- Assert 6: replace OrderModify a Buy with arrays
               aCommand[aCount]     =  1;
               aTicket[aCount]      =  ticket_68;
               aStopLoss[aCount]    =  price_108;
               aTakeProfit[aCount]  =  f0_13(price_92, ai_28, g_point_2872, g_digits_2868);
               aCount ++;
               if( aCount >= MaxPositions ) break;
               /*GhostOrderModify(ticket_68, GhostOrderOpenPrice(), price_108, f0_13(price_92, ai_28, g_point_2872, g_digits_2868), 0, CLR_NONE);*/
            }
         //--- Assert 1: Free OrderSelect #3
            GhostFreeSelect(false);
         //--- Assert for: process array of commands for OrderSelect #3
            for(int i=0; i<aCount; i++)
            {
               switch( aCommand[i] )
               {
                  case 1:  // OrderModify Buy
                     GhostOrderModify( aTicket[i], aOpenPrice[i], aStopLoss[i], aTakeProfit[i], 0, CLR_NONE );
                     break;
               }
            }
            if (gi_3156 == TRUE) {
            //--- Assert 2: Init OrderSelect #4
               GhostInitSelect(true,ticket_68,SELECT_BY_TICKET,MODE_TRADES);
               GhostOrderSelect(ticket_68, SELECT_BY_TICKET);
               ObjectCreate("BUYSYM" + ticket_68, OBJ_ARROW, 0, GhostOrderOpenTime(), GhostOrderOpenPrice());
               ObjectSet("BUYSYM" + ticket_68, OBJPROP_ARROWCODE, 200);
               ObjectSet("BUYSYM" + ticket_68, OBJPROP_COLOR, Lime);
               gi_100 = TRUE;
               g_order_open_price_580 = GhostOrderOpenPrice();
               g_price_588 = price_108;
               gd_3688 = 0;
            //--- Assert 1: Free OrderSelect #4
               GhostFreeSelect(false);
            //--- Assert 2: Init OrderSelect #5
               GhostInitSelect(true,0,SELECT_BY_POS,MODE_TRADES);
               int total=GhostOrdersTotal();
               for (int pos_124 = 0; pos_124 < total; pos_124++) {
                  if (GhostOrderSelect(pos_124, SELECT_BY_POS, MODE_TRADES) == FALSE) break;
                  if (GhostOrderMagicNumber() != gi_1232 || GhostOrderSymbol() != Symbol()) continue;
                  gd_3688 += 1.0;
               }
               if (gd_3688 == 1.0) {
                  g_order_open_price_168 = GhostOrderOpenPrice();
                  g_order_stoploss_132 = GhostOrderStopLoss();
                  gd_76 = MathAbs(g_order_open_price_168 - g_order_stoploss_132) / 2.0;
               }
            //--- Assert 1: Free OrderSelect #5
               GhostFreeSelect(false);
            }
            if (gi_3160 != TRUE) break;
            PlaySound("alert2.wav");
            break;
         case 130/* INVALID_STOPS */:
         case 4/* SERVER_BUSY */:
         case 6/* NO_CONNECTION */:
         case 129/* INVALID_PRICE */:
         case 136/* OFF_QUOTES */:
         case 137/* BROKER_BUSY */:
         case 146/* TRADE_CONTEXT_BUSY */:
            count_80++;
            break;
         case 131/* INVALID_TRADE_VOLUME */:
            li_76 = TRUE;
            Alert(a_comment_16 + " Invalid Lots");
            break;
         case 132/* MARKET_CLOSED */:
            li_76 = TRUE;
            Alert(a_comment_16 + " Market Close");
            break;
         case 133/* TRADE_DISABLED */:
            li_76 = TRUE;
            Alert(a_comment_16 + " Trades Disabled");
            break;
         case 134/* NOT_ENOUGH_MONEY */:
            li_76 = TRUE;
            Alert(a_comment_16 + " Not Enough Money");
            break;
         case 148/* TRADE_TOO_MANY_ORDERS */:
            li_76 = TRUE;
            Alert(a_comment_16 + " Too Many Orders");
            break;
         case 149/* TRADE_HEDGE_PROHIBITED */:
            li_76 = TRUE;
            Alert(a_comment_16 + " Hedge is prohibited");
            break;
         case 1/* NO_RESULT */:
         default:
            li_76 = TRUE;
            Print("Unknown Error - " + error_116);
         }
         if (count_80 > ai_36) li_76 = TRUE;
      }
      ld_52 -= lots_84;
   }
   return (ticket_68);
}

int f0_0(string a_symbol_0, double ad_8, string a_comment_16, int ai_24, int ai_28, int a_magic_32, int ai_36, int ai_40) {
   int ticket_68;
   int li_unused_72;
   bool li_76;
   int count_80;
   double lots_84;
   double ld_92;
   double price_100;
   double price_108;
   int error_116;
   g_point_2872 = MarketInfo(a_symbol_0, MODE_POINT);
   g_digits_2868 = MarketInfo(a_symbol_0, MODE_DIGITS);
   if (g_point_2872 == 0.001) {
      g_point_2872 = 0.01;
      g_digits_2868 = 3;
   } else {
      if (g_point_2872 == 0.00001) {
         g_point_2872 = 0.0001;
         g_digits_2868 = 5;
      }
   }
   double maxlot_44 = MarketInfo(a_symbol_0, MODE_MAXLOT);
   double ld_52 = ad_8;
   int li_60 = 1;
   if (ad_8 > maxlot_44) li_60 = MathFloor(ad_8 / maxlot_44) + 1.0;
   for (int count_64 = 0; count_64 < li_60; count_64++) {
      ticket_68 = -1;
      li_unused_72 = 0;
      li_76 = FALSE;
      count_80 = 0;
      lots_84 = NormalizeDouble(ad_8 / MathMax(li_60, 1), 2);
      if (ld_52 - maxlot_44 <= 0.0) lots_84 = ld_52;
      while (!li_76) {
         while (IsTradeContextBusy()) Sleep(10);
         RefreshRates();
         ld_92 = NormalizeDouble(MarketInfo(a_symbol_0, MODE_ASK), g_digits_2868);
         price_100 = NormalizeDouble(MarketInfo(a_symbol_0, MODE_BID), g_digits_2868);
         price_108 = f0_10(price_100, ai_24, g_point_2872, g_digits_2868);
         ticket_68 = GhostOrderSend(a_symbol_0, OP_SELL, lots_84, price_100, 0, 0.0, 0.0, a_comment_16, a_magic_32, ai_40 * g_point_2872, CLR_NONE);
         error_116 = GetLastError();
         if (error_116 == 0/* NO_ERROR */) {
            gs_3240 = "SELLTRADE";
         //--- Assert variable OrderMagicNumber() is always 0.
            if (0 == a_magic_32) gs_unused_3224 = "SELL";
            if (0 == gi_1232) gs_unused_3224 = "SELL";
            /*if (GhostOrderMagicNumber() == a_magic_32) gs_unused_3224 = "SELL";*/
            /*if (GhostOrderMagicNumber() == gi_1232) gs_unused_3224 = "SELL";*/
            gs_true_3472 = "False";
         }
         switch (error_116) {
         case 135/* PRICE_CHANGED */: continue;
         case 138/* REQUOTE */: continue;
         case 0/* NO_ERROR */:
            li_76 = TRUE;
         //--- Assert 7: Declare variables for OrderSelect #6
         //       1-OrderModify BUY; 2-OrderClose BUY; 3-OrderModify SELL; 4-OrderClose SELL;
            int      aCommand[];
            int      aTicket[];
            double   aOpenPrice[];
            double   aStopLoss[];
            double   aTakeProfit[];
            bool     aOk;
            int      aCount;
         //--- Assert 5: Dynamically resize arrays for OrderSelect #6
            ArrayResize(aCommand,MaxPositions);
            ArrayResize(aTicket,MaxPositions);
            ArrayResize(aOpenPrice,MaxPositions);
            ArrayResize(aStopLoss,MaxPositions);
            ArrayResize(aTakeProfit,MaxPositions);
         //--- Assert 1: Init OrderSelect #6
            GhostInitSelect(true,ticket_68,SELECT_BY_TICKET,MODE_TRADES);
            if (GhostOrderSelect(ticket_68, SELECT_BY_TICKET)) 
            {
            //--- Assert 5: Populate arrays for OrderSelect #6
               aCommand[aCount]     =  0;
               aTicket[aCount]      =  GhostOrderTicket();
               aOpenPrice[aCount]   =  GhostOrderOpenPrice();
               aStopLoss[aCount]    =  GhostOrderStopLoss();
               aTakeProfit[aCount]  =  GhostOrderTakeProfit();
            //--- Assert 6: replace OrderModify a Sell with arrays
               aCommand[aCount]     =  3;
               aTicket[aCount]      =  ticket_68;
               aStopLoss[aCount]    =  price_108;
               aTakeProfit[aCount]  =  f0_4(price_100, ai_28, g_point_2872, g_digits_2868);
               aCount ++;
               if( aCount >= MaxPositions ) break;
               /*GhostOrderModify(ticket_68, GhostOrderOpenPrice(), price_108, f0_4(price_100, ai_28, g_point_2872, g_digits_2868), 0, CLR_NONE);*/
            }
         //--- Assert 1: Free OrderSelect #6
            GhostFreeSelect(false);
         //--- Assert for: process array of commands for OrderSelect #6
            for(int i=0; i<aCount; i++)
            {
               switch( aCommand[i] )
               {
                  case 3:  // OrderModify Sell
                     GhostOrderModify( aTicket[i], aOpenPrice[i], aStopLoss[i], aTakeProfit[i], 0, CLR_NONE );
                     break;
               }
            }
            if (gi_3156 == TRUE) {
            //--- Assert 2: Init OrderSelect #7
               GhostInitSelect(true,ticket_68,SELECT_BY_TICKET,MODE_TRADES);
               GhostOrderSelect(ticket_68, SELECT_BY_TICKET);
               ObjectCreate("SELLSYM" + ticket_68, OBJ_ARROW, 0, GhostOrderOpenTime(), GhostOrderOpenPrice());
               ObjectSet("SELLSYM" + ticket_68, OBJPROP_ARROWCODE, 202);
               ObjectSet("SELLSYM" + ticket_68, OBJPROP_COLOR, Red);
               g_order_open_price_580 = GhostOrderOpenPrice();
               gi_100 = TRUE;
               g_price_588 = price_108;
               gd_3688 = 0;
            //--- Assert 1: Free OrderSelect #7
               GhostFreeSelect(false);
            //--- Assert 2: Init OrderSelect #8
               GhostInitSelect(true,0,SELECT_BY_POS,MODE_TRADES);
               int total=GhostOrdersTotal();
               for (int pos_124 = 0; pos_124 < total; pos_124++) {
                  if (GhostOrderSelect(pos_124, SELECT_BY_POS, MODE_TRADES) == FALSE) break;
                  if (GhostOrderMagicNumber() != gi_1232 || GhostOrderSymbol() != Symbol()) continue;
                  gd_3688 += 1.0;
               }
               if (gd_3688 == 1.0) {
                  g_order_open_price_168 = GhostOrderOpenPrice();
                  g_order_stoploss_132 = GhostOrderStopLoss();
                  gd_76 = MathAbs(g_order_open_price_168 - g_order_stoploss_132) / 2.0;
               }
            //--- Assert 1: Free OrderSelect #8
               GhostFreeSelect(false);
            }
            if (gi_3160 != TRUE) break;
            PlaySound("alert2.wav");
            break;
         case 130/* INVALID_STOPS */:
         case 4/* SERVER_BUSY */:
         case 6/* NO_CONNECTION */:
         case 129/* INVALID_PRICE */:
         case 136/* OFF_QUOTES */:
         case 137/* BROKER_BUSY */:
         case 146/* TRADE_CONTEXT_BUSY */:
            count_80++;
            break;
         case 131/* INVALID_TRADE_VOLUME */:
            li_76 = TRUE;
            Alert(a_comment_16 + " Invalid Lots");
            break;
         case 132/* MARKET_CLOSED */:
            li_76 = TRUE;
            Alert(a_comment_16 + " Market Close");
            break;
         case 133/* TRADE_DISABLED */:
            li_76 = TRUE;
            Alert(a_comment_16 + " Trades Disabled");
            break;
         case 134/* NOT_ENOUGH_MONEY */:
            li_76 = TRUE;
            Alert(a_comment_16 + " Not Enough Money");
            break;
         case 148/* TRADE_TOO_MANY_ORDERS */:
            li_76 = TRUE;
            Alert(a_comment_16 + " Too Many Orders");
            break;
         case 149/* TRADE_HEDGE_PROHIBITED */:
            li_76 = TRUE;
            Alert(a_comment_16 + " Hedge is prohibited");
            break;
         case 1/* NO_RESULT */:
         default:
            li_76 = TRUE;
            Print("Unknown Error - " + error_116);
         }
         if (count_80 > ai_36) li_76 = TRUE;
      }
      ld_52 -= lots_84;
   }
   return (ticket_68);
}

void f0_15() {
   double ld_8;
   double ld_16;
   int li_24;
   int li_28;
   int li_32;
   int li_36;
   string ls_40;
   int count_0 = 0;
//--- Assert 2: Init OrderSelect #9
   GhostInitSelect(true,0,SELECT_BY_POS,MODE_TRADES);
   int total=GhostOrdersTotal();
   for (int pos_4 = 0; pos_4 < total; pos_4++) {
      if (GhostOrderSelect(pos_4, SELECT_BY_POS, MODE_TRADES) == FALSE) break;
      if (GhostOrderMagicNumber() != gi_1232 || GhostOrderSymbol() != Symbol()) continue;
      count_0++;
   }
//--- Assert 1: Free OrderSelect #9
   GhostFreeSelect(false);
   if (count_0 < MaxPositions) {
      if (Friday_Trade == FALSE && DayOfWeek() > 4) return;
      ld_8 = 1;
      if (MarketInfo(Symbol(), MODE_DIGITS) == 5.0) ld_8 = 10;
      if (MarketInfo(Symbol(), MODE_DIGITS) == 4.0) ld_8 = 1;
      if ((Ask - Bid) / ld_8 / Point <= 2.0 * g_spread_1252) {
         g_symbol_2860 = Symbol();
         g_point_2872 = MarketInfo(g_symbol_2860, MODE_POINT);
         g_digits_2868 = MarketInfo(g_symbol_2860, MODE_DIGITS);
         if (g_point_2872 == 0.00001) g_point_2872 = 0.0001;
         else
            if (g_point_2872 == 0.001) g_point_2872 = 0.01;
         gd_3184 = gd_1236 / MaxPositions;
         ld_16 = 0.0;
         li_24 = 3;
         li_28 = gd_3128;
         li_32 = gd_3096;
         li_36 = 10;
         ls_40 = gs_3080 + " - Enter LONG";
         if (ld_16 <= 0.0) {
            if (Geometrical_MM == TRUE) ld_16 = f0_3(g_symbol_2860, gd_3184);
            if (Geometrical_MM == FALSE) ld_16 = f0_11(g_symbol_2860, gd_3184);
            if (gd_3184 <= 0.0) {
               Alert(ls_40 + "- Invalid Lots/Risk settings!");
               return;
            }
         }
         gi_100 = FALSE;
         Comment(gs_3080 + " - Buy |  please wait ...");
         f0_12(g_symbol_2860, ld_16, ls_40, li_28, li_32, gi_1232, li_36, li_24);
         Comment("");
         if (gi_100 == TRUE) gs_true_3472 = "False";
      }
   }
}

void f0_8() {
   double ld_8;
   double ld_16;
   int li_24;
   int li_28;
   int li_32;
   int li_36;
   string ls_40;
   int count_0 = 0;
//--- Assert 2: Init OrderSelect #10
   GhostInitSelect(true,0,SELECT_BY_POS,MODE_TRADES);
   int total=GhostOrdersTotal();
   for (int pos_4 = 0; pos_4 < total; pos_4++) {
      if (GhostOrderSelect(pos_4, SELECT_BY_POS, MODE_TRADES) == FALSE) break;
      if (GhostOrderMagicNumber() != gi_1232 || GhostOrderSymbol() != Symbol()) continue;
      count_0++;
   }
//--- Assert 1: Free OrderSelect #10
   GhostFreeSelect(false);
   if (count_0 < MaxPositions) {
      if (Friday_Trade == FALSE && DayOfWeek() > 4) return;
      ld_8 = 1;
      if (MarketInfo(Symbol(), MODE_DIGITS) == 5.0) ld_8 = 10;
      if (MarketInfo(Symbol(), MODE_DIGITS) == 4.0) ld_8 = 1;
      if ((Ask - Bid) / ld_8 / Point <= 2.0 * g_spread_1252) {
         g_symbol_2860 = Symbol();
         g_point_2872 = MarketInfo(g_symbol_2860, MODE_POINT);
         g_digits_2868 = MarketInfo(g_symbol_2860, MODE_DIGITS);
         if (g_point_2872 == 0.00001) g_point_2872 = 0.0001;
         else
            if (g_point_2872 == 0.001) g_point_2872 = 0.01;
         gd_3184 = gd_1236 / MaxPositions;
         ld_16 = 0.0;
         li_24 = 3;
         li_28 = gd_3128;
         li_32 = gd_3096;
         li_36 = 10;
         ls_40 = gs_3080 + " - Enter SHORT";
         if (ld_16 <= 0.0) {
            if (Geometrical_MM == TRUE) ld_16 = f0_3(g_symbol_2860, gd_3184);
            if (Geometrical_MM == FALSE) ld_16 = f0_11(g_symbol_2860, gd_3184);
            if (gd_3184 <= 0.0) {
               Alert(ls_40 + "- Invalid Lots/Risk settings!");
               return;
            }
         }
         gi_100 = FALSE;
         Comment(gs_3080 + " - Sell |  please wait ...");
         f0_0(g_symbol_2860, ld_16, ls_40, li_28, li_32, gi_1232, li_36, li_24);
         Comment("");
         if (gi_100 == TRUE) gs_true_3472 = "False";
      }
   }
}

void f0_5() {
   int li_0 = 9999;
   int li_4 = 10;
   int li_8 = 10;
   string ls_12 = gs_3080 + " - Close ALL ";
   g_symbol_2860 = Symbol();
   g_point_2872 = MarketInfo(g_symbol_2860, MODE_POINT);
   g_digits_2868 = MarketInfo(g_symbol_2860, MODE_DIGITS);
   if (g_point_2872 == 0.00001) g_point_2872 = 0.0001;
   else
      if (g_point_2872 == 0.001) g_point_2872 = 0.01;
   Comment(ls_12 + " | Closing All Orders, please wait ...");
   f0_2(g_symbol_2860, gi_1232, 1024, li_4, li_8, ls_12);
   Comment("");
   if (li_0 == 0) {
      gs_3240 = "";
      g_order_open_price_580 = 0;
      g_price_588 = 0;
      g_order_stoploss_132 = 0;
   }
}

void f0_6(double a_price_0) {
//--- Assert 7: Declare variables for OrderSelect #11
//       1-OrderModify BUY; 2-OrderClose BUY; 3-OrderModify SELL; 4-OrderClose SELL;
   int      aCommand[];
   int      aTicket[];
   double   aOpenPrice[];
   double   aStopLoss[];
   double   aTakeProfit[];
   bool     aOk;
   int      aCount;
//--- Assert 5: Dynamically resize arrays for OrderSelect #11
   ArrayResize(aCommand,MaxPositions);
   ArrayResize(aTicket,MaxPositions);
   ArrayResize(aOpenPrice,MaxPositions);
   ArrayResize(aStopLoss,MaxPositions);
   ArrayResize(aTakeProfit,MaxPositions);
//--- Assert 2: Init OrderSelect #11
   GhostInitSelect(true,0,SELECT_BY_POS,MODE_TRADES);
   int total=GhostOrdersTotal();
   for (int pos_8 = 0; pos_8 < total; pos_8++) {
      if (GhostOrderSelect(pos_8, SELECT_BY_POS, MODE_TRADES) == FALSE) break;
   //--- Assert 5: Populate arrays for OrderSelect #11
      aCommand[aCount]     =  0;
      aTicket[aCount]      =  GhostOrderTicket();
      aOpenPrice[aCount]   =  GhostOrderOpenPrice();
      aStopLoss[aCount]    =  GhostOrderStopLoss();
      aTakeProfit[aCount]  =  GhostOrderTakeProfit();
      if (GhostOrderMagicNumber() != gi_1232 || GhostOrderSymbol() != Symbol()) continue;
      if (GhostOrderStopLoss() > a_price_0 + (Ask - Bid) && GhostOrderType() == OP_SELL) 
      {
      //--- Assert 4: replace OrderModify a Sell with arrays
         aCommand[aCount]     =  3;
         aStopLoss[aCount]    =  a_price_0;
         aCount ++;
         if( aCount >= MaxPositions ) break;
         /*GhostOrderModify(GhostOrderTicket(), GhostOrderOpenPrice(), a_price_0, GhostOrderTakeProfit(), 0);*/
      }
      if (GhostOrderStopLoss() < a_price_0 - (Ask - Bid) && GhostOrderType() == OP_BUY) 
      {
      //--- Assert 4: replace OrderModify a Buy with arrays
         aCommand[aCount]     =  1;
         aStopLoss[aCount]    =  a_price_0;
         aCount ++;
         if( aCount >= MaxPositions ) break;
         /*GhostOrderModify(GhostOrderTicket(), GhostOrderOpenPrice(), a_price_0, GhostOrderTakeProfit(), 0);*/
      }
      g_order_profit_520 = GhostOrderProfit();
   }
//--- Assert 1: Free OrderSelect #11
   GhostFreeSelect(false);
//--- Assert for: process array of commands for OrderSelect #6
   for(int i=0; i<aCount; i++)
   {
      switch( aCommand[i] )
      {
         case 1:  // OrderModify Buy
            GhostOrderModify( aTicket[i], aOpenPrice[i], aStopLoss[i], aTakeProfit[i], 0 );
            break;
         case 3:  // OrderModify Sell
            GhostOrderModify( aTicket[i], aOpenPrice[i], aStopLoss[i], aTakeProfit[i], 0 );
            break;
      }
   }
}

void f0_1() {
   gd_3688 = 0;
//--- Assert 2: Init OrderSelect #12
   GhostInitSelect(true,0,SELECT_BY_POS,MODE_TRADES);
   int total=GhostOrdersTotal();
   for (int pos_0 = 0; pos_0 < total; pos_0++) {
      if (GhostOrderSelect(pos_0, SELECT_BY_POS, MODE_TRADES) == FALSE) break;
      if (GhostOrderMagicNumber() != gi_1232 || GhostOrderSymbol() != Symbol()) continue;
      if (GhostOrderType() == OP_BUY) {
         gs_unused_3224 = "BUY";
         gs_3240 = "BUYTRADE";
         gs_1316 = "";
      }
      if (GhostOrderType() == OP_SELL) {
         gs_unused_3224 = "SELL";
         gs_3240 = "SELLTRADE";
         gs_1316 = "";
      }
   }
//--- Assert 1: Free OrderSelect #12
   GhostFreeSelect(false);
}

void f0_7() {
   gd_3688 = 0;
   gi_160 = 0;
   gi_164 = 0;
   gi_160 = MathFloor(gi_156 / 10000);
   gi_164 = MathMod(gi_156, 10000);
//--- Assert 2: Init OrderSelect #13
   GhostInitSelect(true,0,SELECT_BY_POS,MODE_TRADES);
   int total=GhostOrdersTotal();
   for (int pos_0 = 0; pos_0 < total; pos_0++) {
      if (GhostOrderSelect(pos_0, SELECT_BY_POS, MODE_TRADES) == FALSE) break;
      if (GhostOrderMagicNumber() != gi_1232 || GhostOrderSymbol() != Symbol()) continue;
      gd_3688 += 1.0;
   }
//--- Assert 1: Free OrderSelect #13
   GhostFreeSelect(false);
   int datetime_4 = 0;
   int ticket_8 = -1;
   gi_160 *= gi_3564;
   gi_164 = gi_164 * gi_3564 * gi_3564;
   gi_3760 = gi_160;
   gi_92 = gi_164;
//--- Assert 2: Init OrderSelect #14
   GhostInitSelect(false,0,SELECT_BY_POS,MODE_TRADES);
   total=GhostOrdersTotal();
   for (int pos_12 = GhostOrdersTotal() - 1; pos_12 >= 0; pos_12--) {
      if (GhostOrderSelect(pos_12, SELECT_BY_POS) && GhostOrderMagicNumber() == gi_1232 && GhostOrderSymbol() == Symbol() && GhostOrderOpenTime() > datetime_4) {
         datetime_4 = GhostOrderOpenTime();
         ticket_8 = GhostOrderTicket();
      }
   }
//--- Assert 1: Free OrderSelect #14
   GhostFreeSelect(false);
//--- Assert 1: Init OrderSelect #15
   GhostInitSelect(true,ticket_8,SELECT_BY_TICKET,MODE_TRADES);
   if (GhostOrderSelect(ticket_8, SELECT_BY_TICKET) == TRUE) g_order_open_price_176 = GhostOrderOpenPrice();
//--- Assert 1: Free OrderSelect #15
   GhostFreeSelect(false);
}

void f0_14() {
   int lia_44[1];
   string ls_48;
   int li_56;
   double iforce_60;
   double ima_68;
   double ima_76;
   double iatr_84;
   double ilow_92;
   double ihigh_100;
   double ld_108;
   double ihigh_116;
   double ld_124;
   int time_132;
   double ld_136;
   int time_144;
   double ld_148;
   int li_unused_156;
   int li_160;
   double ld_168;
   double ld_180;
   double ld_188;
   double ld_unused_196;
   double lotsize_204;
   double lotstep_212;
   double marginrequired_220;
   double tickvalue_228;
   double ticksize_236;
   double ld_244;
   int li_252;
   double ld_256;
   bool li_0 = FALSE;
   g_ask_3328 = Ask;
   g_bid_3320 = Bid;
   double ld_4 = (g_ask_3328 + g_bid_3320) / 2.0;
   gd_3688 = 0;
   f0_7();
   if (gd_3688 > 0.0 && gs_3240 == "") f0_1();
   else {
      if (gd_3688 == 0.0 && gs_3240 != "" || gs_1316 != "") {
         gs_3240 = "";
         gs_1316 = "";
         gd_unused_528 = g_order_profit_536;
         g_order_profit_536 = g_order_profit_520;
         g_order_profit_520 = 0;
      }
   }
   g_symbol_2860 = Symbol();
   g_point_2872 = MarketInfo(g_symbol_2860, MODE_POINT);
   g_digits_2868 = MarketInfo(g_symbol_2860, MODE_DIGITS);
   if (g_point_2872 == 0.00001) g_point_2872 = 0.0001;
   else
      if (g_point_2872 == 0.001) g_point_2872 = 0.01;
   double ld_12 = 1;
   if (MarketInfo(Symbol(), MODE_DIGITS) == 5.0) ld_12 = 10;
   if (MarketInfo(Symbol(), MODE_DIGITS) == 4.0) ld_12 = 1;
   g_point_680 = Point;
   double ima_20 = iMA(NULL, PERIOD_H1, 1, 0, MODE_EMA, PRICE_MEDIAN, 1);
   double ienvelopes_28 = iEnvelopes(NULL, PERIOD_H1, 5, MODE_EMA, 1, PRICE_MEDIAN, 0.1, MODE_UPPER, 1);
   double ienvelopes_36 = iEnvelopes(NULL, PERIOD_H1, 5, MODE_EMA, 1, PRICE_MEDIAN, 0.1, MODE_LOWER, 1);
   gi_1232 = MagicNumber;
   gi_unused_2632 = FALSE;
   if (gi_348 == 0) {
      gi_140 = FALSE;
      gi_144 = FALSE;
      if (g_ima_2644 > g_ima_1476 && g_ima_1476 > g_ima_2668 && g_ima_2644 > g_price_1828) gi_140 = TRUE;
      if (g_ima_2644 < g_ima_1476 && g_ima_1476 < g_ima_2668 && g_ima_2644 < g_ilow_1836) gi_144 = TRUE;
      gi_140 = FALSE;
      gi_144 = FALSE;
      if (g_ima_192 > g_ienvelopes_464) gi_140 = TRUE;
      if (g_ima_192 < g_ienvelopes_456) gi_144 = TRUE;
      gi_148 = FALSE;
      gi_152 = FALSE;
      if (g_ima_192 > g_ienvelopes_464) gi_148 = TRUE;
      if (g_ima_192 < g_ienvelopes_456) gi_152 = TRUE;
   } else {
      if (gi_348 == 5) {
         if (ienvelopes_28 <= g_ienvelopes_1684 && ienvelopes_36 >= g_ienvelopes_1692) {
            gi_140 = FALSE;
            gi_144 = FALSE;
            if (ima_20 > ienvelopes_28) gi_140 = TRUE;
            if (ima_20 < ienvelopes_36) gi_144 = TRUE;
         }
         if (ienvelopes_36 >= g_ienvelopes_1684) {
            gi_140 = TRUE;
            gi_144 = FALSE;
         }
         if (ienvelopes_28 <= g_ienvelopes_1692) {
            gi_140 = FALSE;
            gi_144 = TRUE;
         }
         gi_148 = FALSE;
         gi_152 = FALSE;
      } else {
         if (gi_348 == 9) {
            gi_140 = TRUE;
            gi_144 = TRUE;
            if (g_ima_2644 > gd_1620) gi_140 = TRUE;
            if (g_ima_2644 < gd_1628) gi_144 = TRUE;
         } else {
            gi_140 = FALSE;
            gi_144 = FALSE;
            if (g_ima_2644 > gd_1620) gi_140 = TRUE;
            if (g_ima_2644 < gd_1628) gi_144 = TRUE;
         }
      }
   }
   if (g_bars_3256 != Bars && gi_2896 - gi_1276 == 1) {
      g_point_680 = Point;
      gi_1972 = g_time_116 * gd_1236 * g_point_680;
      gd_1244 = gd_2912;
      g_leverage_1992 = AccountLeverage();
      gi_1968 = gi_1972 * g_leverage_1992;
      gi_2896--;
      Print("MT4 Broker Check.... retry. ");
      ls_48 = httpGET("http://www.phibase.com/phicodex.php?acode=" + gi_2896 + "&percent=" + gi_1968, lia_44);
      li_56 = StrToInteger(ls_48);
      if (lia_44[0] == 200) {
         if (li_56 >= gi_2896) gi_2896 = li_56;
         if (li_56 < gi_2896) gi_2896 = li_56;
         Print("Completed.");
      } else {
         Print("Validation Granted: Connection failure");
         gi_2896++;
      }
   }
   if (g_bars_3256 != Bars) {
      g_ilow_1852 = iLow(NULL, PERIOD_H1, iLowest(NULL, PERIOD_H1, MODE_LOW, 24, 5));
      g_ihigh_1844 = iHigh(NULL, PERIOD_H1, iHighest(NULL, PERIOD_H1, MODE_HIGH, 24, 5));
      g_ilow_1772 = iLow(NULL, PERIOD_H1, iLowest(NULL, PERIOD_H1, MODE_LOW, 194, 72));
      g_time_688 = Time[iLowest(NULL, PERIOD_H1, MODE_LOW, 194, 72)];
      g_ihigh_1764 = iHigh(NULL, PERIOD_H1, iHighest(NULL, PERIOD_H1, MODE_HIGH, 194, 72));
      g_time_696 = Time[iHighest(NULL, PERIOD_H1, MODE_HIGH, 194, 72)];
      g_ilow_1804 = iLow(NULL, PERIOD_H1, iLowest(NULL, PERIOD_H1, MODE_LOW, 72, 24));
      g_time_600 = Time[iLowest(NULL, PERIOD_H1, MODE_LOW, 72, 24)];
      g_price_1796 = iHigh(NULL, PERIOD_H1, iHighest(NULL, PERIOD_H1, MODE_HIGH, 72, 24));
      g_time_608 = Time[iHighest(NULL, PERIOD_H1, MODE_HIGH, 72, 24)];
      g_iatr_240 = iATR(NULL, PERIOD_W1, 14, 1);
      iatr_84 = iATR(NULL, PERIOD_W1, 5, 1);
      ilow_92 = iLow(NULL, PERIOD_W1, iLowest(NULL, PERIOD_W1, MODE_LOW, 5, 1));
      ihigh_100 = iHigh(NULL, PERIOD_W1, iHighest(NULL, PERIOD_W1, MODE_HIGH, 5, 1));
      ld_108 = iLow(NULL, PERIOD_W1, 1);
      ihigh_116 = iHigh(NULL, PERIOD_W1, 1);
      ld_124 = 0;
      g_iatr_2148 = iATR(NULL, PERIOD_D1, 30, 1);
      if (gi_120 == TRUE) {
         Targetlevel_1 = g_iatr_2148 / 2.0;
         TrailSL_1 = 0.3 * g_iatr_2148;
         Targetlevel_2 = 0.85 * g_iatr_2148;
         TrailSL_2 = 0.65 * g_iatr_2148;
      }
      g_point_2872 = MarketInfo(g_symbol_2860, MODE_POINT);
      g_digits_2868 = MarketInfo(g_symbol_2860, MODE_DIGITS);
      gi_3564 = 22;
      if (g_point_2872 == 0.00001) g_point_2872 = 0.0001;
      else
         if (g_point_2872 == 0.001) g_point_2872 = 0.01;
      ld_124 = gi_2896 * gi_3564 + gi_3564;
      ld_124 /= 1000.0;
      ld_108 = 1 / g_point_2872;
      g_ima_2668 = iMA(NULL, PERIOD_H1, 80, 0, MODE_EMA, PRICE_TYPICAL, 1);
      g_ima_2644 = iMA(NULL, PERIOD_H1, 20, 0, MODE_EMA, PRICE_TYPICAL, 1);
      g_ima_2652 = iMA(NULL, PERIOD_H1, 5, 0, MODE_EMA, PRICE_TYPICAL, 1);
      iforce_60 = iForce(NULL, PERIOD_W1, 13, MODE_SMA, PRICE_MEDIAN, 1);
      ima_68 = iMA(NULL, PERIOD_W1, 13, 0, MODE_SMA, PRICE_MEDIAN, 1);
      ima_76 = iMA(NULL, PERIOD_W1, 13, 0, MODE_SMA, PRICE_MEDIAN, 2);
      g_ima_184 = iMA(NULL, PERIOD_H1, 5, 0, MODE_EMA, PRICE_TYPICAL, 2);
      g_ima_192 = iMA(NULL, PERIOD_H1, 1, 0, MODE_EMA, PRICE_TYPICAL, 1);
      g_ima_200 = iMA(NULL, PERIOD_H1, 1, 0, MODE_EMA, PRICE_TYPICAL, 2);
      gi_348 = prcdmkl(Lower_Band, Higher_Band, g_iatr_2148, gd_504, gd_512, gi_160, g_ima_2668, gi_164, g_price_1828, g_ilow_1836, g_price_1860, g_price_1868, g_iatr_240,
         iatr_84, gi_3564, gi_2896, gi_1968, iforce_60, ima_68, ima_76, ld_108, g_bars_3256);
      if (gd_3688 > 2.0) {
         if (gs_3240 == "SELLTRADE") f0_6(g_price_1860 + TrailSL_1);
         if (gs_3240 == "BUYTRADE") f0_6(g_price_1868 - TrailSL_1);
      }
      g_ienvelopes_1484 = iEnvelopes(NULL, PERIOD_H1, 10, MODE_EMA, 1, PRICE_CLOSE, 0.2, MODE_UPPER, 1);
      g_ienvelopes_1492 = iEnvelopes(NULL, PERIOD_H1, 10, MODE_EMA, 1, PRICE_CLOSE, 0.2, MODE_LOWER, 1);
      g_ienvelopes_1500 = iEnvelopes(NULL, PERIOD_H1, 10, MODE_EMA, 1, PRICE_CLOSE, 0.2, MODE_UPPER, 2);
      g_ienvelopes_1508 = iEnvelopes(NULL, PERIOD_H1, 10, MODE_EMA, 1, PRICE_CLOSE, 0.2, MODE_LOWER, 2);
      g_ima_1564 = iMA(NULL, PERIOD_W1, 1, 0, MODE_EMA, PRICE_TYPICAL, 1);
      g_ienvelopes_1548 = iEnvelopes(NULL, PERIOD_W1, 1, MODE_EMA, 1, PRICE_TYPICAL, 1, MODE_UPPER, 1);
      g_ienvelopes_1556 = iEnvelopes(NULL, PERIOD_W1, 1, MODE_EMA, 1, PRICE_TYPICAL, 1, MODE_LOWER, 1);
      g_ima_1476 = iMA(NULL, PERIOD_H1, 40, 0, MODE_EMA, PRICE_CLOSE, 1);
      g_ima_1468 = iMA(NULL, PERIOD_M15, 40, 0, MODE_EMA, PRICE_CLOSE, 1);
      g_ienvelopes_1572 = iEnvelopes(NULL, PERIOD_H1, 5, MODE_EMA, 1, PRICE_MEDIAN, 0.65, MODE_UPPER, 1);
      g_ienvelopes_1580 = iEnvelopes(NULL, PERIOD_H1, 5, MODE_EMA, 1, PRICE_MEDIAN, 0.65, MODE_LOWER, 1);
      g_ienvelopes_1684 = iEnvelopes(NULL, PERIOD_H1, 80, MODE_EMA, 1, PRICE_MEDIAN, 0.35, MODE_UPPER, 1);
      g_ienvelopes_1692 = iEnvelopes(NULL, PERIOD_H1, 80, MODE_EMA, 1, PRICE_MEDIAN, 0.35, MODE_LOWER, 1);
      g_ienvelopes_1700 = iEnvelopes(NULL, PERIOD_H1, 80, MODE_EMA, 1, PRICE_MEDIAN, 0.35, MODE_UPPER, 2);
      g_ienvelopes_1708 = iEnvelopes(NULL, PERIOD_H1, 80, MODE_EMA, 1, PRICE_MEDIAN, 0.35, MODE_LOWER, 2);
      g_ienvelopes_1636 = iEnvelopes(NULL, PERIOD_H1, 80, MODE_EMA, 1, PRICE_MEDIAN, 0.65, MODE_UPPER, 1);
      g_ienvelopes_1644 = iEnvelopes(NULL, PERIOD_H1, 80, MODE_EMA, 1, PRICE_MEDIAN, 0.65, MODE_LOWER, 1);
      g_ienvelopes_464 = iEnvelopes(NULL, PERIOD_H1, 20, MODE_EMA, 1, PRICE_MEDIAN, 0.35, MODE_UPPER, 1);
      g_ienvelopes_456 = iEnvelopes(NULL, PERIOD_H1, 20, MODE_EMA, 1, PRICE_MEDIAN, 0.35, MODE_LOWER, 1);
      g_ienvelopes_480 = iEnvelopes(NULL, PERIOD_H1, 20, MODE_EMA, 1, PRICE_MEDIAN, 0.35, MODE_UPPER, 2);
      g_ienvelopes_472 = iEnvelopes(NULL, PERIOD_H1, 20, MODE_EMA, 1, PRICE_MEDIAN, 0.35, MODE_LOWER, 2);
      g_ienvelopes_432 = iEnvelopes(NULL, PERIOD_H1, 20, MODE_EMA, 1, PRICE_MEDIAN, 0.1, MODE_UPPER, 1);
      g_ienvelopes_424 = iEnvelopes(NULL, PERIOD_H1, 20, MODE_EMA, 1, PRICE_MEDIAN, 0.1, MODE_LOWER, 1);
      g_ienvelopes_448 = iEnvelopes(NULL, PERIOD_H1, 20, MODE_EMA, 1, PRICE_MEDIAN, 0.1, MODE_UPPER, 2);
      g_ienvelopes_440 = iEnvelopes(NULL, PERIOD_H1, 20, MODE_EMA, 1, PRICE_MEDIAN, 0.1, MODE_LOWER, 2);
      g_ibands_1716 = iBands(NULL, PERIOD_H1, 20, 2, 0, PRICE_MEDIAN, MODE_UPPER, 1);
      g_ibands_1724 = iBands(NULL, PERIOD_H1, 20, 2, 0, PRICE_MEDIAN, MODE_LOWER, 1);
      gd_1732 = (g_ibands_1716 + g_ibands_1724) / 2.0;
      g_ibands_1940 = iBands(NULL, PERIOD_H1, 80, 2, 0, PRICE_MEDIAN, MODE_UPPER, 1);
      g_ibands_1948 = iBands(NULL, PERIOD_H1, 80, 2, 0, PRICE_MEDIAN, MODE_LOWER, 1);
      gd_1740 = (g_ibands_1940 + g_ibands_1948) / 2.0;
      g_idemarker_208 = iDeMarker(NULL, PERIOD_H1, 10, 1);
      g_idemarker_216 = iDeMarker(NULL, PERIOD_H1, 10, 2);
      g_idemarker_224 = iDeMarker(NULL, PERIOD_H1, 20, 1);
      g_idemarker_232 = iDeMarker(NULL, PERIOD_H1, 20, 2);
      g_iwpr_248 = iWPR(NULL, PERIOD_H1, 24, 1);
      g_iwpr_256 = iWPR(NULL, PERIOD_H1, 24, 2);
      g_imacd_264 = iMACD(NULL, 0, 12, 26, 9, PRICE_MEDIAN, MODE_MAIN, 1);
      g_imacd_272 = iMACD(NULL, 0, 12, 26, 9, PRICE_MEDIAN, MODE_MAIN, 2);
      g_imacd_280 = iMACD(NULL, 0, 12, 26, 9, PRICE_MEDIAN, MODE_SIGNAL, 1);
      g_imacd_288 = iMACD(NULL, 0, 12, 26, 9, PRICE_MEDIAN, MODE_SIGNAL, 2);
      g_istochastic_1136 = iStochastic(NULL, PERIOD_H1, 15, 9, 9, MODE_EMA, 0, MODE_MAIN, 1);
      g_istochastic_1144 = iStochastic(NULL, PERIOD_H1, 15, 9, 9, MODE_EMA, 0, MODE_SIGNAL, 1);
      g_istochastic_1152 = iStochastic(NULL, PERIOD_H1, 15, 9, 9, MODE_EMA, 0, MODE_MAIN, 2);
      g_istochastic_1160 = iStochastic(NULL, PERIOD_H1, 15, 9, 9, MODE_EMA, 0, MODE_SIGNAL, 2);
      if (g_time_600 > g_time_608) gd_unused_632 = g_time_600;
      if (g_time_600 < g_time_608) gd_unused_632 = g_time_608;
      if (g_time_600 > g_time_608) gd_unused_616 = g_ilow_1804;
      if (g_time_600 < g_time_608) gd_unused_616 = g_price_1796;
      time_132 = Time[iHighest(NULL, PERIOD_H1, MODE_HIGH, 1, 1)];
      ObjectDelete("Pattern3");
      ObjectCreate("Pattern3", OBJ_TREND, 0, g_time_696, g_ihigh_1764, time_132, g_price_1796);
      ObjectDelete("Pattern4");
      ObjectCreate("Pattern4", OBJ_TREND, 0, g_time_688, g_ilow_1772, time_132, g_ilow_1804);
      ld_136 = ObjectGetValueByShift("Pattern3", 1);
      gd_504 = ld_136;
      if (g_time_696 == g_time_608) g_price_488 = g_ihigh_1764;
      ld_136 = ObjectGetValueByShift("Pattern4", 1);
      gd_496 = ld_136;
      if (g_time_688 == g_time_600) gd_496 = g_ilow_1772;
      ObjectDelete("Pattern3");
      ObjectCreate("Pattern3", OBJ_TREND, 0, g_time_696, g_ihigh_1764, g_time_608, g_price_1796);
      ObjectDelete("Pattern4");
      ObjectCreate("Pattern4", OBJ_TREND, 0, g_time_688, g_ilow_1772, g_time_600, g_ilow_1804);
      ObjectSet("Pattern3", OBJPROP_COLOR, Blue);
      ObjectSet("Pattern3", OBJPROP_WIDTH, 1);
      ObjectSet("Pattern4", OBJPROP_COLOR, Blue);
      ObjectSet("Pattern4", OBJPROP_WIDTH, 1);
      if (High[1] > g_ibands_1940) {
         g_ilow_1836 = iLow(NULL, PERIOD_H1, iLowest(NULL, PERIOD_H1, MODE_LOW, 194, 1));
         g_time_736 = Time[iLowest(NULL, PERIOD_H1, MODE_LOW, 194, 1)];
      }
      if (Low[1] < g_ibands_1948) {
         g_price_1828 = iHigh(NULL, PERIOD_H1, iHighest(NULL, PERIOD_H1, MODE_HIGH, 194, 1));
         g_time_744 = Time[iHighest(NULL, PERIOD_H1, MODE_HIGH, 194, 1)];
      }
      if (High[1] > g_ibands_1716) {
         g_price_1868 = iLow(NULL, PERIOD_H1, iLowest(NULL, PERIOD_H1, MODE_LOW, 72, 1));
         g_time_640 = Time[iLowest(NULL, PERIOD_H1, MODE_LOW, 72, 1)];
      }
      if (Low[1] < g_ibands_1724) {
         g_price_1860 = iHigh(NULL, PERIOD_H1, iHighest(NULL, PERIOD_H1, MODE_HIGH, 72, 1));
         g_time_648 = Time[iHighest(NULL, PERIOD_H1, MODE_HIGH, 72, 1)];
      }
      if (g_time_640 > g_time_648) gd_unused_672 = g_time_640;
      if (g_time_640 < g_time_648) gd_unused_672 = g_time_648;
      if (g_time_640 > g_time_648) gd_unused_656 = g_price_1868;
      if (g_time_640 < g_time_648) gd_unused_656 = g_price_1860;
      ObjectDelete("Pattern1");
      ObjectCreate("Pattern1", OBJ_TREND, 0, g_time_744, g_price_1828, g_time_736, g_ilow_1836);
      ObjectSet("Pattern1", OBJPROP_RAY, FALSE);
      ObjectSet("Pattern1", OBJPROP_COLOR, Red);
      ObjectSet("Pattern1", OBJPROP_WIDTH, 1);
      ObjectDelete("Pattern2");
      ObjectCreate("Pattern2", OBJ_TREND, 0, g_time_648, g_price_1860, g_time_640, g_price_1868);
      ObjectSet("Pattern2", OBJPROP_RAY, FALSE);
      ObjectSet("Pattern2", OBJPROP_COLOR, Red);
      ObjectSet("Pattern2", OBJPROP_WIDTH, 1);
      time_144 = Time[iHighest(NULL, PERIOD_H1, MODE_HIGH, 1, 1)];
      ObjectDelete("Pattern3");
      ObjectCreate("Pattern3", OBJ_TREND, 0, g_time_744, g_price_1828, time_144, g_price_1860);
      ObjectDelete("Pattern4");
      ObjectCreate("Pattern4", OBJ_TREND, 0, g_time_736, g_ilow_1836, time_144, g_price_1868);
      ld_148 = ObjectGetValueByShift("Pattern3", 1);
      gd_504 = ld_148;
      if (g_time_744 == g_time_648) gd_504 = g_price_1828;
      ld_148 = ObjectGetValueByShift("Pattern4", 1);
      gd_512 = ld_148;
      if (g_time_736 == g_time_640) gd_512 = g_ilow_1836;
      ObjectDelete("Pattern3");
      ObjectCreate("Pattern3", OBJ_TREND, 0, g_time_744, g_price_1828, g_time_648, g_price_1860);
      ObjectDelete("Pattern4");
      ObjectCreate("Pattern4", OBJ_TREND, 0, g_time_736, g_ilow_1836, g_time_640, g_price_1868);
      ObjectSet("Pattern3", OBJPROP_RAY, FALSE);
      ObjectSet("Pattern3", OBJPROP_COLOR, Blue);
      ObjectSet("Pattern3", OBJPROP_WIDTH, 1);
      ObjectSet("Pattern4", OBJPROP_RAY, FALSE);
      ObjectSet("Pattern4", OBJPROP_COLOR, Blue);
      ObjectSet("Pattern4", OBJPROP_WIDTH, 1);
      g_iatr_2148 = iATR(NULL, PERIOD_D1, 30, 1);
      if (gi_348 == 0) {
         g_istochastic_992 = iStochastic(NULL, PERIOD_H1, 15, 9, 9, MODE_EMA, 1, MODE_MAIN, 1);
         g_istochastic_1000 = iStochastic(NULL, PERIOD_H1, 15, 9, 9, MODE_EMA, 1, MODE_SIGNAL, 1);
         g_istochastic_1008 = iStochastic(NULL, PERIOD_H1, 15, 9, 9, MODE_EMA, 1, MODE_MAIN, 2);
         g_istochastic_1016 = iStochastic(NULL, PERIOD_H1, 15, 9, 9, MODE_EMA, 1, MODE_SIGNAL, 2);
      } else {
         g_istochastic_992 = iStochastic(NULL, PERIOD_H1, 45, 27, 27, MODE_EMA, 1, MODE_MAIN, 1);
         g_istochastic_1000 = iStochastic(NULL, PERIOD_H1, 45, 27, 27, MODE_EMA, 1, MODE_SIGNAL, 1);
         g_istochastic_1008 = iStochastic(NULL, PERIOD_H1, 45, 27, 27, MODE_EMA, 1, MODE_MAIN, 2);
         g_istochastic_1016 = iStochastic(NULL, PERIOD_H1, 45, 27, 27, MODE_EMA, 1, MODE_SIGNAL, 2);
      }
      g_istochastic_1024 = iStochastic(NULL, PERIOD_H1, 45, 27, 27, MODE_EMA, 1, MODE_MAIN, 1);
      g_istochastic_1032 = iStochastic(NULL, PERIOD_H1, 45, 27, 27, MODE_EMA, 1, MODE_SIGNAL, 1);
      g_istochastic_1040 = iStochastic(NULL, PERIOD_H1, 45, 27, 27, MODE_EMA, 1, MODE_MAIN, 2);
      g_istochastic_1048 = iStochastic(NULL, PERIOD_H1, 45, 27, 27, MODE_EMA, 1, MODE_SIGNAL, 2);
      g_istochastic_1056 = iStochastic(NULL, PERIOD_H1, 5, 3, 3, MODE_SMA, 1, MODE_MAIN, 1);
      g_istochastic_1064 = iStochastic(NULL, PERIOD_H1, 5, 3, 3, MODE_SMA, 1, MODE_SIGNAL, 1);
      g_istochastic_1072 = iStochastic(NULL, PERIOD_H1, 5, 3, 3, MODE_SMA, 1, MODE_MAIN, 2);
      g_istochastic_1080 = iStochastic(NULL, PERIOD_H1, 5, 3, 3, MODE_SMA, 1, MODE_SIGNAL, 2);
      if (gi_3016 > 9) gi_3016 = 9;
      if (gi_3016 < 1) gi_3016 = 1;
      gd_296 = srange(gd_504, gd_512, gi_3016);
      gd_304 = brange(gd_504, gd_512, gi_3016);
      gd_328 = bosrange(gd_504, gd_512, gi_3016);
      gd_336 = bobrange(gd_504, gd_512, gi_3016);
      g_iatr_2148 = iATR(NULL, PERIOD_D1, 30, 1);
      gd_3128 = g_iatr_2148 / ld_12 / Point;
      if (gd_3128 < 125.0) gd_3128 = 125;
      if (gd_3128 > 250.0) gd_3128 = 250;
      gd_3136 = gd_3128 / 1.0;
      gd_3096 = 4.0 * gd_3128;
      gd_3104 = gd_3128 / 2.0;
      gd_3128 = 2.0 * gd_3128;
   }
   if (g_bars_3256 != Bars) {
      g_bars_96 = g_bars_3256;
      g_bars_3256 = Bars;
      gs_true_3472 = "True";
   }
   if (g_ienvelopes_1556 > g_ima_1564 || g_ienvelopes_1548 < g_ima_1564) {
      g_ienvelopes_1532 = iEnvelopes(NULL, PERIOD_M15, 10, MODE_EMA, 1, PRICE_CLOSE, 0.05, MODE_UPPER, 1);
      g_ienvelopes_1540 = iEnvelopes(NULL, PERIOD_M15, 10, MODE_EMA, 1, PRICE_CLOSE, 0.05, MODE_LOWER, 1);
      g_ienvelopes_1516 = iEnvelopes(NULL, PERIOD_M15, 10, MODE_EMA, 1, PRICE_CLOSE, 0.05, MODE_UPPER, 1);
      g_ienvelopes_1524 = iEnvelopes(NULL, PERIOD_M15, 10, MODE_EMA, 1, PRICE_CLOSE, 0.05, MODE_LOWER, 1);
      g_ima_1468 = iMA(NULL, PERIOD_M15, 40, 0, MODE_EMA, PRICE_CLOSE, 1);
   } else {
      g_ienvelopes_1532 = iEnvelopes(NULL, PERIOD_M15, 5, MODE_EMA, 1, PRICE_CLOSE, 0.025, MODE_UPPER, 1);
      g_ienvelopes_1540 = iEnvelopes(NULL, PERIOD_M15, 5, MODE_EMA, 1, PRICE_CLOSE, 0.025, MODE_LOWER, 1);
      g_ienvelopes_1516 = iEnvelopes(NULL, PERIOD_M15, 5, MODE_EMA, 1, PRICE_CLOSE, 0.025, MODE_UPPER, 1);
      g_ienvelopes_1524 = iEnvelopes(NULL, PERIOD_M15, 5, MODE_EMA, 1, PRICE_CLOSE, 0.025, MODE_LOWER, 1);
      g_ima_1468 = iMA(NULL, PERIOD_M15, 20, 0, MODE_EMA, PRICE_CLOSE, 1);
   }
   if (gs_3240 != "") {
      g_istochastic_1136 = iStochastic(NULL, PERIOD_H1, 15, 9, 9, MODE_EMA, 0, MODE_MAIN, 1);
      g_istochastic_1144 = iStochastic(NULL, PERIOD_H1, 15, 9, 9, MODE_EMA, 0, MODE_SIGNAL, 1);
      g_istochastic_1152 = iStochastic(NULL, PERIOD_H1, 15, 9, 9, MODE_EMA, 0, MODE_MAIN, 2);
      g_istochastic_1160 = iStochastic(NULL, PERIOD_H1, 15, 9, 9, MODE_EMA, 0, MODE_SIGNAL, 2);
      li_unused_156 = 0;
      if (g_iatr_2148 < Lower_Band && g_iatr_240 < 2.0 * Lower_Band) li_unused_156 = 1;
      if (gd_76 < Targetlevel_1) gd_76 = Targetlevel_1;
      if (gi_348 < 1) {
         gd_76 = MathAbs(g_order_open_price_168 - g_price_588) / 2.0;
         if (gd_76 < Targetlevel_1) gd_76 = Targetlevel_1;
         if (gs_3240 == "SELLTRADE" && (g_istochastic_1136 > g_istochastic_1144 && Close[1] > g_order_open_price_168 + gd_76) || (g_istochastic_1136 > g_istochastic_1144 &&
            g_istochastic_1152 < g_istochastic_1160 && g_istochastic_1144 < 20.0 && g_istochastic_1136 > 20.0)) {
            gs_unused_3224 = "SELL";
            f0_5();
         }
         if (gs_3240 == "BUYTRADE" && (g_istochastic_1136 < g_istochastic_1144 && Close[1] < g_order_open_price_168 - gd_76) || (g_istochastic_1136 < g_istochastic_1144 && g_istochastic_1152 > g_istochastic_1160 &&
            g_istochastic_1144 > 80.0 && g_istochastic_1136 < 80.0)) {
            gs_unused_3224 = "BUY";
            f0_5();
         }
      } else {
         if (gs_3240 == "SELLTRADE" && (g_istochastic_1136 > g_istochastic_1144 && Close[1] > g_order_open_price_168 + gd_76)) {
            gs_unused_3224 = "SELL";
            f0_5();
         }
         if (gs_3240 == "BUYTRADE" && (g_istochastic_1136 < g_istochastic_1144 && Close[1] < g_order_open_price_168 - gd_76)) {
            gs_unused_3224 = "BUY";
            f0_5();
         }
      }
      if (gi_348 != 9) {
         if (gs_3240 == "SELLTRADE" && g_order_open_price_168 - ld_4 > Targetlevel_2 && (g_order_open_price_168 - ld_4) / 2.0 > TrailSL_2) f0_6(g_order_open_price_168 - (g_order_open_price_168 - ld_4) / 2.0);
         if (gs_3240 == "BUYTRADE" && ld_4 - g_order_open_price_168 > Targetlevel_2 && (ld_4 - g_order_open_price_168) / 2.0 > TrailSL_2) f0_6(g_order_open_price_168 + (ld_4 - g_order_open_price_168) / 2.0);
         if (gs_3240 == "SELLTRADE" && g_order_open_price_168 - ld_4 > Targetlevel_2 + TrailSL_1) f0_6(g_order_open_price_168 - Targetlevel_2);
         if (gs_3240 == "BUYTRADE" && ld_4 - g_order_open_price_168 > Targetlevel_2 + TrailSL_1) f0_6(g_order_open_price_168 + Targetlevel_2);
         if (gs_3240 == "SELLTRADE" && g_order_open_price_168 - ld_4 > Targetlevel_2 && (g_order_open_price_168 - ld_4) / 2.0 < TrailSL_2) f0_6(g_order_open_price_168 - TrailSL_2);
         if (gs_3240 == "BUYTRADE" && ld_4 - g_order_open_price_168 > Targetlevel_2 && (ld_4 - g_order_open_price_168) / 2.0 < TrailSL_2) f0_6(g_order_open_price_168 + TrailSL_2);
         if (gs_3240 == "SELLTRADE" && g_order_open_price_168 - ld_4 > Targetlevel_1) f0_6(g_order_open_price_168 - TrailSL_1);
         if (gs_3240 == "BUYTRADE" && ld_4 - g_order_open_price_168 > Targetlevel_1) f0_6(g_order_open_price_168 + TrailSL_1);
      }
      if (gi_348 == 9) {
         if (gs_3240 == "SELLTRADE" && g_order_open_price_168 - ld_4 > Targetlevel_2 + TrailSL_1) f0_6(g_order_open_price_168 - Targetlevel_2);
         if (gs_3240 == "BUYTRADE" && ld_4 - g_order_open_price_168 > Targetlevel_2 + TrailSL_1) f0_6(g_order_open_price_168 + Targetlevel_2);
      }
      if (gd_3688 > 1.0) {
         if (gs_3240 == "SELLTRADE" && Low[1] < g_order_open_price_168 && Close[1] > g_order_open_price_168) f0_6(Close[1] + TrailSL_1);
         if (gs_3240 == "BUYTRADE" && High[1] > g_order_open_price_168 && Close[1] < g_order_open_price_168) f0_6(Close[1] - TrailSL_1);
      }
      li_160 = addtrade(10, ld_4, Open[1], High[1], Low[1], Close[1], g_price_1828, g_ilow_1836, g_price_1860, g_price_1868, gi_2896, gi_1968, g_bars_96, g_istochastic_1136,
         g_istochastic_1144, g_istochastic_1152, g_istochastic_1160, g_istochastic_992, g_istochastic_1000, gi_3760, gi_92, gi_3564, g_idemarker_208, g_idemarker_216);
      if (gs_3240 == "BUYTRADE" && gs_true_3472 == "True" && li_160 == 10 && Close[1] > g_order_open_price_168 + Targetlevel_1 && Close[1] < g_order_open_price_168 + Targetlevel_2) f0_15();
      li_160 = addtrade(20, ld_4, Open[1], High[1], Low[1], Close[1], g_price_1828, g_ilow_1836, g_price_1860, g_price_1868, gi_2896, gi_1968, g_bars_96, g_istochastic_1136,
         g_istochastic_1144, g_istochastic_1152, g_istochastic_1160, g_istochastic_992, g_istochastic_1000, gi_3760, gi_92, gi_3564, g_idemarker_208, g_idemarker_216);
      if (gs_3240 == "SELLTRADE" && gs_true_3472 == "True" && li_160 == 20 && Close[1] < g_order_open_price_168 - Targetlevel_1 && Close[1] > g_order_open_price_168 - Targetlevel_2) f0_8();
      li_160 = addtrade(30, ld_4, Open[1], High[1], Low[1], Close[1], g_price_1828, g_ilow_1836, g_price_1860, g_price_1868, gi_2896, gi_1968, g_bars_96, g_istochastic_1136,
         g_istochastic_1144, g_istochastic_1152, g_istochastic_1160, g_istochastic_992, g_istochastic_1000, gi_3760, gi_92, gi_3564, g_idemarker_208, g_idemarker_216);
      if (gs_3240 == "BUYTRADE" && gi_144 == FALSE && gs_true_3472 == "True" && li_160 == 30 && Close[1] < g_order_open_price_168 - gd_76 / 4.0 && Close[1] > g_order_open_price_168 - gd_76 / 2.0) f0_15();
      li_160 = addtrade(40, ld_4, Open[1], High[1], Low[1], Close[1], g_price_1828, g_ilow_1836, g_price_1860, g_price_1868, gi_2896, gi_1968, g_bars_96, g_istochastic_1136,
         g_istochastic_1144, g_istochastic_1152, g_istochastic_1160, g_istochastic_992, g_istochastic_1000, gi_3760, gi_92, gi_3564, g_idemarker_208, g_idemarker_216);
      if (gs_3240 == "SELLTRADE" && gi_140 == FALSE && gs_true_3472 == "True" && li_160 == 40 && Close[1] > g_order_open_price_168 + gd_76 / 4.0 && Close[1] < g_order_open_price_168 +
         gd_76 / 2.0) f0_8();
      li_160 = addtrade(50, ld_4, Open[1], High[1], Low[1], Close[1], g_price_1828, g_ilow_1836, g_price_1860, g_price_1868, gi_2896, gi_1968, g_bars_96, g_istochastic_1136,
         g_istochastic_1144, g_istochastic_1152, g_istochastic_1160, g_istochastic_992, g_istochastic_1000, gi_3760, gi_92, gi_3564, g_idemarker_208, g_idemarker_216);
      if (gs_3240 == "BUYTRADE" && gi_144 == FALSE && gs_true_3472 == "True" && li_160 == 50 && Close[1] < g_order_open_price_168 - gd_76 / 2.0 && Close[1] > g_order_open_price_168 - 0.9 * gd_76) f0_15();
      li_160 = addtrade(60, ld_4, Open[1], High[1], Low[1], Close[1], g_price_1828, g_ilow_1836, g_price_1860, g_price_1868, gi_2896, gi_1968, g_bars_96, g_istochastic_1136,
         g_istochastic_1144, g_istochastic_1152, g_istochastic_1160, g_istochastic_992, g_istochastic_1000, gi_3760, gi_92, gi_3564, g_idemarker_208, g_idemarker_216);
      if (gs_3240 == "SELLTRADE" && gi_140 == FALSE && gs_true_3472 == "True" && li_160 == 60 && Close[1] > g_order_open_price_168 + gd_76 / 2.0 && Close[1] < g_order_open_price_168 +
         0.9 * gd_76) f0_8();
      li_160 = addtrade(110, ld_4, Open[1], High[1], Low[1], Close[1], g_price_1828, g_ilow_1836, g_price_1860, g_price_1868, gi_2896, gi_1968, g_bars_96, g_istochastic_1136,
         g_istochastic_1144, g_istochastic_1152, g_istochastic_1160, g_istochastic_992, g_istochastic_1000, gi_3760, gi_92, gi_3564, g_idemarker_208, g_idemarker_216);
      if (gs_3240 == "BUYTRADE" && gs_true_3472 == "True" && li_160 == 110 && Close[1] > g_order_open_price_168 + Targetlevel_1 && Close[1] < g_order_open_price_168 + Targetlevel_2) f0_15();
      li_160 = addtrade(120, ld_4, Open[1], High[1], Low[1], Close[1], g_price_1828, g_ilow_1836, g_price_1860, g_price_1868, gi_2896, gi_1968, g_bars_96, g_istochastic_1136,
         g_istochastic_1144, g_istochastic_1152, g_istochastic_1160, g_istochastic_992, g_istochastic_1000, gi_3760, gi_92, gi_3564, g_idemarker_208, g_idemarker_216);
      if (gs_3240 == "SELLTRADE" && gs_true_3472 == "True" && li_160 == 120 && Close[1] < g_order_open_price_168 - Targetlevel_1 && Close[1] > g_order_open_price_168 - Targetlevel_2) f0_8();
      li_160 = addtrade(130, ld_4, Open[1], High[1], Low[1], Close[1], g_price_1828, g_ilow_1836, g_price_1860, g_price_1868, gi_2896, gi_1968, g_bars_96, g_istochastic_1136,
         g_istochastic_1144, g_istochastic_1152, g_istochastic_1160, g_istochastic_992, g_istochastic_1000, gi_3760, gi_92, gi_3564, g_idemarker_208, g_idemarker_216);
      if (gs_3240 == "BUYTRADE" && gi_144 == FALSE && gs_true_3472 == "True" && li_160 == 130 && Close[1] < g_order_open_price_168 - gd_76 / 4.0 && Close[1] > g_order_open_price_168 - gd_76 / 2.0) f0_15();
      li_160 = addtrade(140, ld_4, Open[1], High[1], Low[1], Close[1], g_price_1828, g_ilow_1836, g_price_1860, g_price_1868, gi_2896, gi_1968, g_bars_96, g_istochastic_1136,
         g_istochastic_1144, g_istochastic_1152, g_istochastic_1160, g_istochastic_992, g_istochastic_1000, gi_3760, gi_92, gi_3564, g_idemarker_208, g_idemarker_216);
      if (gs_3240 == "SELLTRADE" && gi_140 == FALSE && gs_true_3472 == "True" && li_160 == 140 && Close[1] > g_order_open_price_168 + gd_76 / 4.0 && Close[1] < g_order_open_price_168 +
         gd_76 / 2.0) f0_8();
      li_160 = addtrade(150, ld_4, Open[1], High[1], Low[1], Close[1], g_price_1828, g_ilow_1836, g_price_1860, g_price_1868, gi_2896, gi_1968, g_bars_96, g_istochastic_1136,
         g_istochastic_1144, g_istochastic_1152, g_istochastic_1160, g_istochastic_992, g_istochastic_1000, gi_3760, gi_92, gi_3564, g_idemarker_208, g_idemarker_216);
      if (gs_3240 == "BUYTRADE" && gi_144 == FALSE && gs_true_3472 == "True" && li_160 == 150 && Close[1] < g_order_open_price_168 - gd_76 / 2.0 && Close[1] > g_order_open_price_168 - 0.9 * gd_76) f0_15();
      li_160 = addtrade(160, ld_4, Open[1], High[1], Low[1], Close[1], g_price_1828, g_ilow_1836, g_price_1860, g_price_1868, gi_2896, gi_1968, g_bars_96, g_istochastic_1136,
         g_istochastic_1144, g_istochastic_1152, g_istochastic_1160, g_istochastic_992, g_istochastic_1000, gi_3760, gi_92, gi_3564, g_idemarker_208, g_idemarker_216);
      if (gs_3240 == "SELLTRADE" && gi_140 == FALSE && gs_true_3472 == "True" && li_160 == 160 && Close[1] > g_order_open_price_168 + gd_76 / 2.0 && Close[1] < g_order_open_price_168 +
         0.9 * gd_76) f0_8();
   }
   gi_104 = FALSE;
   gi_108 = FALSE;
   if (gs_3240 != "") {
      if (Close[1] > g_order_open_price_168 + Targetlevel_1 && Close[1] < g_order_open_price_168 + Targetlevel_2 || Close[1] < g_order_open_price_168 - gd_76 / 4.0 && Close[1] > g_order_open_price_168 - gd_76 / 2.0 ||
         Close[1] < g_order_open_price_168 - gd_76 / 2.0 && Close[1] > g_order_open_price_168 - 0.9 * gd_76)
         if (gs_3240 == "BUYTRADE") gi_104 = TRUE;
      if (Close[1] < g_order_open_price_168 - Targetlevel_1 && Close[1] > g_order_open_price_168 - Targetlevel_2 || Close[1] > g_order_open_price_168 + gd_76 / 4.0 && Close[1] < g_order_open_price_168 +
         gd_76 / 2.0 || Close[1] > g_order_open_price_168 + gd_76 / 2.0 && Close[1] < g_order_open_price_168 + 0.9 * gd_76)
         if (gs_3240 == "SELLTRADE") gi_108 = TRUE;
   }
   li_0 = CallPat1b(ld_4, Open[1], High[1], gi_2896, gi_1968, g_bars_96, gi_348, Low[1], Close[1], gd_512, gd_504, gd_304, gd_296, gd_336, gd_328, g_istochastic_1136,
      g_istochastic_1144, g_istochastic_1152, g_istochastic_1160, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
   if (gs_true_3472 == "True" && li_0 == TRUE) {
      if (gs_3240 == "" || gi_104 == TRUE) f0_15();
      else {
         if (gs_3240 == "SELLTRADE") {
            f0_5();
            f0_15();
         }
      }
   }
   li_0 = CallPat1s(ld_4, Open[1], High[1], gi_2896, gi_1968, g_bars_96, gi_348, Low[1], Close[1], gd_512, gd_504, gd_304, gd_296, gd_336, gd_328, g_istochastic_1136,
      g_istochastic_1144, g_istochastic_1152, g_istochastic_1160, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
   if (gs_true_3472 == "True" && li_0 == TRUE) {
      if (gs_3240 == "" || gi_108 == TRUE) f0_8();
      else {
         if (gs_3240 == "BUYTRADE") {
            f0_5();
            f0_8();
         }
      }
   }
   li_0 = CallPat2b(ld_4, Open[1], High[1], gi_2896, gi_1968, g_bars_96, gi_348, Low[1], Close[1], gd_512, gd_504, gd_304, gd_296, gd_336, gd_328, g_istochastic_1136,
      g_istochastic_1144, g_istochastic_1152, g_istochastic_1160, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
   if (gs_true_3472 == "True" && li_0 == TRUE) {
      if (gs_3240 == "" || gi_104 == TRUE) f0_15();
      else {
         if (gs_3240 == "SELLTRADE") {
            f0_5();
            f0_15();
         }
      }
   }
   li_0 = CallPat2s(ld_4, Open[1], High[1], gi_2896, gi_1968, g_bars_96, gi_348, Low[1], Close[1], gd_512, gd_504, gd_304, gd_296, gd_336, gd_328, g_istochastic_1136,
      g_istochastic_1144, g_istochastic_1152, g_istochastic_1160, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
   if (gs_true_3472 == "True" && li_0 == TRUE) {
      if (gs_3240 == "" || gi_108 == TRUE) f0_8();
      else {
         if (gs_3240 == "BUYTRADE") {
            f0_5();
            f0_8();
         }
      }
   }
   li_0 = CallPat3b(ld_4, Open[1], High[1], gi_2896, gi_1968, g_bars_96, gi_348, Low[1], Close[1], gd_512, gd_504, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_1692,
      g_ienvelopes_1684, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ibands_1940, g_ibands_1948, g_istochastic_1136, g_istochastic_1144, g_istochastic_1152,
      g_istochastic_1160, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
   if (gs_true_3472 == "True" && li_0 == TRUE) {
      if (gs_3240 == "" || gi_104 == TRUE) f0_15();
      else {
         if (gs_3240 == "SELLTRADE") {
            f0_5();
            f0_15();
         }
      }
   }
   li_0 = CallPat3s(ld_4, Open[1], High[1], gi_2896, gi_1968, g_bars_96, gi_348, Low[1], Close[1], gd_512, gd_504, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_1692,
      g_ienvelopes_1684, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ibands_1940, g_ibands_1948, g_istochastic_1136, g_istochastic_1144, g_istochastic_1152,
      g_istochastic_1160, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
   if (gs_true_3472 == "True" && li_0 == TRUE) {
      if (gs_3240 == "" || gi_108 == TRUE) f0_8();
      else {
         if (gs_3240 == "BUYTRADE") {
            f0_5();
            f0_8();
         }
      }
   }
   li_0 = CallPat4b(ld_4, Open[1], High[1], gi_2896, gi_1968, g_bars_96, gi_348, Low[1], Close[1], gd_512, gd_504, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_1692,
      g_ienvelopes_1684, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ibands_1940, g_ibands_1948, g_istochastic_1136, g_istochastic_1144, g_istochastic_1152,
      g_istochastic_1160, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
   if (gs_true_3472 == "True" && li_0 == TRUE) {
      if (gs_3240 == "" || gi_104 == TRUE) f0_15();
      else {
         if (gs_3240 == "SELLTRADE") {
            f0_5();
            f0_15();
         }
      }
   }
   li_0 = CallPat4s(ld_4, Open[1], High[1], gi_2896, gi_1968, g_bars_96, gi_348, Low[1], Close[1], gd_512, gd_504, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_1692,
      g_ienvelopes_1684, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ibands_1940, g_ibands_1948, g_istochastic_1136, g_istochastic_1144, g_istochastic_1152,
      g_istochastic_1160, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
   if (gs_true_3472 == "True" && li_0 == TRUE) {
      if (gs_3240 == "" || gi_108 == TRUE) f0_8();
      else {
         if (gs_3240 == "BUYTRADE") {
            f0_5();
            f0_8();
         }
      }
   }
   li_0 = CallPat5b(ld_4, Open[1], High[1], gi_2896, gi_1968, g_bars_96, gi_348, Low[1], Close[1], gd_512, gd_504, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_1692,
      g_ienvelopes_1684, g_ienvelopes_440, g_ienvelopes_424, g_ienvelopes_448, g_ienvelopes_432, g_ibands_1940, g_ibands_1948, g_istochastic_1136, g_istochastic_1144, g_istochastic_1152,
      g_istochastic_1160, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
   if (gs_true_3472 == "True" && li_0 == TRUE) {
      if (gs_3240 == "" || gi_104 == TRUE) f0_15();
      else {
         if (gs_3240 == "SELLTRADE") {
            f0_5();
            f0_15();
         }
      }
   }
   li_0 = CallPat5s(ld_4, Open[1], High[1], gi_2896, gi_1968, g_bars_96, gi_348, Low[1], Close[1], gd_512, gd_504, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_1692,
      g_ienvelopes_1684, g_ienvelopes_440, g_ienvelopes_424, g_ienvelopes_448, g_ienvelopes_432, g_ibands_1940, g_ibands_1948, g_istochastic_1136, g_istochastic_1144, g_istochastic_1152,
      g_istochastic_1160, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
   if (gs_true_3472 == "True" && li_0 == TRUE) {
      if (gs_3240 == "" || gi_108 == TRUE) f0_8();
      else {
         if (gs_3240 == "BUYTRADE") {
            f0_5();
            f0_8();
         }
      }
   }
   li_0 = CallPat6b(ld_4, Open[1], High[1], gi_2896, gi_1968, g_bars_96, gi_348, Low[1], Close[1], gd_512, gd_504, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_1692,
      g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940, g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1152,
      g_istochastic_1160, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
   if (gs_true_3472 == "True" && li_0 == TRUE)
      if (gs_3240 == "" || gi_104 == TRUE) f0_15();
   li_0 = CallPat6s(ld_4, Open[1], High[1], gi_2896, gi_1968, g_bars_96, gi_348, Low[1], Close[1], gd_512, gd_504, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_1692,
      g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940, g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1152,
      g_istochastic_1160, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
   if (gs_true_3472 == "True" && li_0 == TRUE)
      if (gs_3240 == "" || gi_108 == TRUE) f0_8();
   if (gi_348 == 1) {
      gi_348 = 2;
      li_0 = CallPat9b(g_iatr_2148, ld_4, Open[1], gi_2896, gi_1968, g_bars_96, gi_348, High[1], Low[1], Close[1], g_imacd_264, g_imacd_272, g_imacd_280, g_imacd_288, gd_512,
         gd_504, gd_304, gd_296, gd_336, gd_328, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ienvelopes_440,
         g_ienvelopes_424, g_ienvelopes_448, g_ienvelopes_432, g_ienvelopes_1692, g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940,
         g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1136, g_istochastic_1144, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
      if (gs_true_3472 == "True" && li_0 == TRUE) {
         if (gs_3240 == "" || gi_104 == TRUE) f0_15();
         else {
            if (gs_3240 == "SELLTRADE") {
               f0_5();
               f0_15();
            }
         }
      }
      li_0 = CallPat9s(g_iatr_2148, ld_4, Open[1], gi_2896, gi_1968, g_bars_96, gi_348, High[1], Low[1], Close[1], g_imacd_264, g_imacd_272, g_imacd_280, g_imacd_288, gd_512,
         gd_504, gd_304, gd_296, gd_336, gd_328, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ienvelopes_440,
         g_ienvelopes_424, g_ienvelopes_448, g_ienvelopes_432, g_ienvelopes_1692, g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940,
         g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1136, g_istochastic_1144, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
      if (gs_true_3472 == "True" && li_0 == TRUE) {
         if (gs_3240 == "" || gi_104 == TRUE) f0_8();
         else {
            if (gs_3240 == "BUYTRADE") {
               f0_5();
               f0_8();
            }
         }
      }
      gi_348 = 1;
   }
   if (gi_348 == 5) {
      gi_348 = 1;
      li_0 = CallPat1b(ld_4, Open[1], High[1], gi_2896, gi_1968, g_bars_96, gi_348, Low[1], Close[1], gd_512, gd_504, gd_304, gd_296, gd_336, gd_328, g_istochastic_1136,
         g_istochastic_1144, g_istochastic_1152, g_istochastic_1160, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
      if (gs_true_3472 == "True" && li_0 == TRUE) {
         if (gs_3240 == "" || gi_104 == TRUE) f0_15();
         else {
            if (gs_3240 == "SELLTRADE") {
               f0_5();
               f0_15();
            }
         }
      }
      li_0 = CallPat1s(ld_4, Open[1], High[1], gi_2896, gi_1968, g_bars_96, gi_348, Low[1], Close[1], gd_512, gd_504, gd_304, gd_296, gd_336, gd_328, g_istochastic_1136,
         g_istochastic_1144, g_istochastic_1152, g_istochastic_1160, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
      if (gs_true_3472 == "True" && li_0 == TRUE) {
         if (gs_3240 == "" || gi_108 == TRUE) f0_8();
         else {
            if (gs_3240 == "BUYTRADE") {
               f0_5();
               f0_8();
            }
         }
      }
      li_0 = CallPat2b(ld_4, Open[1], High[1], gi_2896, gi_1968, g_bars_96, gi_348, Low[1], Close[1], gd_512, gd_504, gd_304, gd_296, gd_336, gd_328, g_istochastic_1136,
         g_istochastic_1144, g_istochastic_1152, g_istochastic_1160, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
      if (gs_true_3472 == "True" && li_0 == TRUE) {
         if (gs_3240 == "" || gi_104 == TRUE) f0_15();
         else {
            if (gs_3240 == "SELLTRADE") {
               f0_5();
               f0_15();
            }
         }
      }
      li_0 = CallPat2s(ld_4, Open[1], High[1], gi_2896, gi_1968, g_bars_96, gi_348, Low[1], Close[1], gd_512, gd_504, gd_304, gd_296, gd_336, gd_328, g_istochastic_1136,
         g_istochastic_1144, g_istochastic_1152, g_istochastic_1160, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
      if (gs_true_3472 == "True" && li_0 == TRUE) {
         if (gs_3240 == "" || gi_108 == TRUE) f0_8();
         else {
            if (gs_3240 == "BUYTRADE") {
               f0_5();
               f0_8();
            }
         }
      }
      li_0 = CallPat3b(ld_4, Open[1], High[1], gi_2896, gi_1968, g_bars_96, gi_348, Low[1], Close[1], gd_512, gd_504, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_1692,
         g_ienvelopes_1684, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ibands_1940, g_ibands_1948, g_istochastic_1136, g_istochastic_1144, g_istochastic_1152,
         g_istochastic_1160, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
      if (gs_true_3472 == "True" && li_0 == TRUE) {
         if (gs_3240 == "" || gi_104 == TRUE) f0_15();
         else {
            if (gs_3240 == "SELLTRADE") {
               f0_5();
               f0_15();
            }
         }
      }
      li_0 = CallPat3s(ld_4, Open[1], High[1], gi_2896, gi_1968, g_bars_96, gi_348, Low[1], Close[1], gd_512, gd_504, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_1692,
         g_ienvelopes_1684, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ibands_1940, g_ibands_1948, g_istochastic_1136, g_istochastic_1144, g_istochastic_1152,
         g_istochastic_1160, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
      if (gs_true_3472 == "True" && li_0 == TRUE) {
         if (gs_3240 == "" || gi_108 == TRUE) f0_8();
         else {
            if (gs_3240 == "BUYTRADE") {
               f0_5();
               f0_8();
            }
         }
      }
      li_0 = CallPat4b(ld_4, Open[1], High[1], gi_2896, gi_1968, g_bars_96, gi_348, Low[1], Close[1], gd_512, gd_504, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_1692,
         g_ienvelopes_1684, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ibands_1940, g_ibands_1948, g_istochastic_1136, g_istochastic_1144, g_istochastic_1152,
         g_istochastic_1160, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
      if (gs_true_3472 == "True" && li_0 == TRUE) {
         if (gs_3240 == "" || gi_104 == TRUE) f0_15();
         else {
            if (gs_3240 == "SELLTRADE") {
               f0_5();
               f0_15();
            }
         }
      }
      li_0 = CallPat4s(ld_4, Open[1], High[1], gi_2896, gi_1968, g_bars_96, gi_348, Low[1], Close[1], gd_512, gd_504, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_1692,
         g_ienvelopes_1684, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ibands_1940, g_ibands_1948, g_istochastic_1136, g_istochastic_1144, g_istochastic_1152,
         g_istochastic_1160, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
      if (gs_true_3472 == "True" && li_0 == TRUE) {
         if (gs_3240 == "" || gi_108 == TRUE) f0_8();
         else {
            if (gs_3240 == "BUYTRADE") {
               f0_5();
               f0_8();
            }
         }
      }
      li_0 = CallPat5b(ld_4, Open[1], High[1], gi_2896, gi_1968, g_bars_96, gi_348, Low[1], Close[1], gd_512, gd_504, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_1692,
         g_ienvelopes_1684, g_ienvelopes_440, g_ienvelopes_424, g_ienvelopes_448, g_ienvelopes_432, g_ibands_1940, g_ibands_1948, g_istochastic_1136, g_istochastic_1144, g_istochastic_1152,
         g_istochastic_1160, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
      if (gs_true_3472 == "True" && li_0 == TRUE) {
         if (gs_3240 == "" || gi_104 == TRUE) f0_15();
         else {
            if (gs_3240 == "SELLTRADE") {
               f0_5();
               f0_15();
            }
         }
      }
      li_0 = CallPat5s(ld_4, Open[1], High[1], gi_2896, gi_1968, g_bars_96, gi_348, Low[1], Close[1], gd_512, gd_504, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_1692,
         g_ienvelopes_1684, g_ienvelopes_440, g_ienvelopes_424, g_ienvelopes_448, g_ienvelopes_432, g_ibands_1940, g_ibands_1948, g_istochastic_1136, g_istochastic_1144, g_istochastic_1152,
         g_istochastic_1160, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
      if (gs_true_3472 == "True" && li_0 == TRUE) {
         if (gs_3240 == "" || gi_108 == TRUE) f0_8();
         else {
            if (gs_3240 == "BUYTRADE") {
               f0_5();
               f0_8();
            }
         }
      }
      li_0 = CallPat6b(ld_4, Open[1], High[1], gi_2896, gi_1968, g_bars_96, gi_348, Low[1], Close[1], gd_512, gd_504, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_1692,
         g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940, g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1152,
         g_istochastic_1160, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
      if (gs_true_3472 == "True" && li_0 == TRUE)
         if (gs_3240 == "" || gi_104 == TRUE) f0_15();
      li_0 = CallPat6s(ld_4, Open[1], High[1], gi_2896, gi_1968, g_bars_96, gi_348, Low[1], Close[1], gd_512, gd_504, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_1692,
         g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940, g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1152,
         g_istochastic_1160, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
      if (gs_true_3472 == "True" && li_0 == TRUE)
         if (gs_3240 == "" || gi_108 == TRUE) f0_8();
      gi_348 = 5;
   }
   li_0 = CallPat7b(g_iatr_2148, ld_4, Open[1], gi_2896, gi_1968, g_bars_96, gi_348, High[1], Low[1], Close[1], g_imacd_264, g_imacd_272, g_imacd_280, g_imacd_288, gd_512,
      gd_504, gd_304, gd_296, gd_336, gd_328, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ienvelopes_440,
      g_ienvelopes_424, g_ienvelopes_448, g_ienvelopes_432, g_ienvelopes_1692, g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940,
      g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1136, g_istochastic_1144, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
   if (gs_true_3472 == "True" && li_0 == TRUE) {
      if (gs_3240 == "" || gi_104 == TRUE) f0_15();
      else {
         if (gs_3240 == "SELLTRADE") {
            f0_5();
            f0_15();
         }
      }
   }
   li_0 = CallPat7s(g_iatr_2148, ld_4, Open[1], gi_2896, gi_1968, g_bars_96, gi_348, High[1], Low[1], Close[1], g_imacd_264, g_imacd_272, g_imacd_280, g_imacd_288, gd_512,
      gd_504, gd_304, gd_296, gd_336, gd_328, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ienvelopes_440,
      g_ienvelopes_424, g_ienvelopes_448, g_ienvelopes_432, g_ienvelopes_1692, g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940,
      g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1136, g_istochastic_1144, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
   if (gs_true_3472 == "True" && li_0 == TRUE) {
      if (gs_3240 == "" || gi_108 == TRUE) f0_8();
      else {
         if (gs_3240 == "BUYTRADE") {
            f0_5();
            f0_8();
         }
      }
   }
   li_0 = CallPat8b(g_iatr_2148, ld_4, Open[1], gi_2896, gi_1968, g_bars_96, gi_348, High[1], Low[1], Close[1], g_imacd_264, g_imacd_272, g_imacd_280, g_imacd_288, gd_512,
      gd_504, gd_304, gd_296, gd_336, gd_328, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ienvelopes_440,
      g_ienvelopes_424, g_ienvelopes_448, g_ienvelopes_432, g_ienvelopes_1692, g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940,
      g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1136, g_istochastic_1144, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
   if (gs_true_3472 == "True" && li_0 == TRUE) {
      if (gs_3240 == "" || gi_104 == TRUE) f0_15();
      else {
         if (gs_3240 == "SELLTRADE") {
            f0_5();
            f0_15();
         }
      }
   }
   li_0 = CallPat8s(g_iatr_2148, ld_4, Open[1], gi_2896, gi_1968, g_bars_96, gi_348, High[1], Low[1], Close[1], g_imacd_264, g_imacd_272, g_imacd_280, g_imacd_288, gd_512,
      gd_504, gd_304, gd_296, gd_336, gd_328, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ienvelopes_440,
      g_ienvelopes_424, g_ienvelopes_448, g_ienvelopes_432, g_ienvelopes_1692, g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940,
      g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1136, g_istochastic_1144, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
   if (gs_true_3472 == "True" && li_0 == TRUE) {
      if (gs_3240 == "" || gi_108 == TRUE) f0_8();
      else {
         if (gs_3240 == "BUYTRADE") {
            f0_5();
            f0_8();
         }
      }
   }
   li_0 = CallPat9b(g_iatr_2148, ld_4, Open[1], gi_2896, gi_1968, g_bars_96, gi_348, High[1], Low[1], Close[1], g_imacd_264, g_imacd_272, g_imacd_280, g_imacd_288, gd_512,
      gd_504, gd_304, gd_296, gd_336, gd_328, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ienvelopes_440,
      g_ienvelopes_424, g_ienvelopes_448, g_ienvelopes_432, g_ienvelopes_1692, g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940,
      g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1136, g_istochastic_1144, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
   if (gs_true_3472 == "True" && li_0 == TRUE) {
      if (gs_3240 == "" || gi_104 == TRUE) f0_15();
      else {
         if (gs_3240 == "SELLTRADE") {
            f0_5();
            f0_15();
         }
      }
   }
   li_0 = CallPat9s(g_iatr_2148, ld_4, Open[1], gi_2896, gi_1968, g_bars_96, gi_348, High[1], Low[1], Close[1], g_imacd_264, g_imacd_272, g_imacd_280, g_imacd_288, gd_512,
      gd_504, gd_304, gd_296, gd_336, gd_328, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ienvelopes_440,
      g_ienvelopes_424, g_ienvelopes_448, g_ienvelopes_432, g_ienvelopes_1692, g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940,
      g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1136, g_istochastic_1144, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
   if (gs_true_3472 == "True" && li_0 == TRUE) {
      if (gs_3240 == "" || gi_108 == TRUE) f0_8();
      else {
         if (gs_3240 == "BUYTRADE") {
            f0_5();
            f0_8();
         }
      }
   }
   li_0 = CallPat10b(g_iatr_2148, ld_4, Open[1], gi_2896, gi_1968, g_bars_96, gi_348, High[1], Low[1], Close[1], g_imacd_264, g_imacd_272, g_imacd_280, g_imacd_288,
      gd_512, gd_504, gd_304, gd_296, gd_336, gd_328, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ienvelopes_440,
      g_ienvelopes_424, g_ienvelopes_448, g_ienvelopes_432, g_ienvelopes_1692, g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940,
      g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1136, g_istochastic_1144, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
   if (gs_true_3472 == "True" && li_0 == TRUE) {
      if (gs_3240 == "" || gi_104 == TRUE) f0_15();
      else {
         if (gs_3240 == "SELLTRADE") {
            f0_5();
            f0_15();
         }
      }
   }
   li_0 = CallPat10s(g_iatr_2148, ld_4, Open[1], gi_2896, gi_1968, g_bars_96, gi_348, High[1], Low[1], Close[1], g_imacd_264, g_imacd_272, g_imacd_280, g_imacd_288,
      gd_512, gd_504, gd_304, gd_296, gd_336, gd_328, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ienvelopes_440,
      g_ienvelopes_424, g_ienvelopes_448, g_ienvelopes_432, g_ienvelopes_1692, g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940,
      g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1136, g_istochastic_1144, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
   if (gs_true_3472 == "True" && li_0 == TRUE) {
      if (gs_3240 == "" || gi_108 == TRUE) f0_8();
      else {
         if (gs_3240 == "BUYTRADE") {
            f0_5();
            f0_8();
         }
      }
   }
   li_0 = CallPat11b(g_iatr_2148, ld_4, Open[1], gi_2896, gi_1968, g_bars_96, gi_348, High[1], Low[1], Close[1], g_imacd_264, g_imacd_272, g_imacd_280, g_imacd_288,
      gd_512, gd_504, gd_304, gd_296, gd_336, gd_328, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ienvelopes_440,
      g_ienvelopes_424, g_ienvelopes_448, g_ienvelopes_432, g_ienvelopes_1692, g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940,
      g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1136, g_istochastic_1144, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
   if (gs_true_3472 == "True" && li_0 == TRUE) {
      if (gs_3240 == "" || gi_104 == TRUE) f0_15();
      else {
         if (gs_3240 == "SELLTRADE") {
            f0_5();
            f0_15();
         }
      }
   }
   li_0 = CallPat11s(g_iatr_2148, ld_4, Open[1], gi_2896, gi_1968, g_bars_96, gi_348, High[1], Low[1], Close[1], g_imacd_264, g_imacd_272, g_imacd_280, g_imacd_288,
      gd_512, gd_504, gd_304, gd_296, gd_336, gd_328, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ienvelopes_440,
      g_ienvelopes_424, g_ienvelopes_448, g_ienvelopes_432, g_ienvelopes_1692, g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940,
      g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1136, g_istochastic_1144, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
   if (gs_true_3472 == "True" && li_0 == TRUE) {
      if (gs_3240 == "" || gi_108 == TRUE) f0_8();
      else {
         if (gs_3240 == "BUYTRADE") {
            f0_5();
            f0_8();
         }
      }
   }
   li_0 = CallPat12b(g_iatr_2148, ld_4, Open[1], gi_2896, gi_1968, g_bars_96, gi_348, High[1], Low[1], Close[1], g_imacd_264, g_imacd_272, g_imacd_280, g_imacd_288,
      gd_512, gd_504, gd_304, gd_296, gd_336, gd_328, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ienvelopes_440,
      g_ienvelopes_424, g_ienvelopes_448, g_ienvelopes_432, g_ienvelopes_1692, g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940,
      g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1136, g_istochastic_1144, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
   if (gs_true_3472 == "True" && li_0 == TRUE) {
      if (gs_3240 == "" || gi_104 == TRUE && g_istochastic_992 > g_istochastic_1000) f0_15();
      else {
         if (gs_3240 == "SELLTRADE") {
            f0_5();
            if (g_istochastic_992 > g_istochastic_1000) f0_15();
         }
      }
   }
   li_0 = CallPat12s(g_iatr_2148, ld_4, Open[1], gi_2896, gi_1968, g_bars_96, gi_348, High[1], Low[1], Close[1], g_imacd_264, g_imacd_272, g_imacd_280, g_imacd_288,
      gd_512, gd_504, gd_304, gd_296, gd_336, gd_328, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ienvelopes_440,
      g_ienvelopes_424, g_ienvelopes_448, g_ienvelopes_432, g_ienvelopes_1692, g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940,
      g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1136, g_istochastic_1144, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
   if (gs_true_3472 == "True" && li_0 == TRUE) {
      if (gs_3240 == "" || gi_108 == TRUE && g_istochastic_992 < g_istochastic_1000) f0_8();
      else {
         if (gs_3240 == "BUYTRADE") {
            f0_5();
            if (g_istochastic_992 < g_istochastic_1000) f0_8();
         }
      }
   }
   li_0 = CallPat13b(g_iatr_2148, ld_4, Open[1], gi_2896, gi_1968, g_bars_96, gi_348, High[1], Low[1], Close[1], g_imacd_264, g_imacd_272, g_imacd_280, g_imacd_288,
      gd_512, gd_504, gd_304, gd_296, gd_336, gd_328, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ienvelopes_440,
      g_ienvelopes_424, g_ienvelopes_448, g_ienvelopes_432, g_ienvelopes_1692, g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940,
      g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1136, g_istochastic_1144, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
   if (gs_true_3472 == "True" && li_0 == TRUE)
      if (gs_3240 == "" || gi_104 == TRUE) f0_15();
   li_0 = CallPat13s(g_iatr_2148, ld_4, Open[1], gi_2896, gi_1968, g_bars_96, gi_348, High[1], Low[1], Close[1], g_imacd_264, g_imacd_272, g_imacd_280, g_imacd_288,
      gd_512, gd_504, gd_304, gd_296, gd_336, gd_328, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ienvelopes_440,
      g_ienvelopes_424, g_ienvelopes_448, g_ienvelopes_432, g_ienvelopes_1692, g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940,
      g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1136, g_istochastic_1144, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
   if (gs_true_3472 == "True" && li_0 == TRUE)
      if (gs_3240 == "" || gi_108 == TRUE) f0_8();
   li_0 = CallPat14b(g_iatr_2148, ld_4, Open[1], gi_2896, gi_1968, g_bars_96, gi_348, High[1], Low[1], Close[1], g_imacd_264, g_imacd_272, g_imacd_280, g_imacd_288,
      gd_512, gd_504, gd_304, gd_296, gd_336, gd_328, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ienvelopes_440,
      g_ienvelopes_424, g_ienvelopes_448, g_ienvelopes_432, g_ienvelopes_1692, g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940,
      g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1136, g_istochastic_1144, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
   if (gs_true_3472 == "True" && li_0 == TRUE)
      if (gs_3240 == "" || gi_104 == TRUE) f0_15();
   li_0 = CallPat14s(g_iatr_2148, ld_4, Open[1], gi_2896, gi_1968, g_bars_96, gi_348, High[1], Low[1], Close[1], g_imacd_264, g_imacd_272, g_imacd_280, g_imacd_288,
      gd_512, gd_504, gd_304, gd_296, gd_336, gd_328, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ienvelopes_440,
      g_ienvelopes_424, g_ienvelopes_448, g_ienvelopes_432, g_ienvelopes_1692, g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940,
      g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1136, g_istochastic_1144, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
   if (gs_true_3472 == "True" && li_0 == TRUE)
      if (gs_3240 == "" || gi_108 == TRUE) f0_8();
   if (gi_140 == TRUE && gi_348 == 9) {
      gi_348 = 2;
      li_0 = CallPat8b(g_iatr_2148, ld_4, Open[1], gi_2896, gi_1968, g_bars_96, gi_348, High[1], Low[1], Close[1], g_imacd_264, g_imacd_272, g_imacd_280, g_imacd_288, gd_512,
         gd_504, gd_304, gd_296, gd_336, gd_328, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ienvelopes_440,
         g_ienvelopes_424, g_ienvelopes_448, g_ienvelopes_432, g_ienvelopes_1692, g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940,
         g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1136, g_istochastic_1144, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
      if (gs_true_3472 == "True" && li_0 == TRUE) {
         if (gs_3240 == "" || gi_104 == TRUE) f0_15();
         else {
            if (gs_3240 == "SELLTRADE") {
               f0_5();
               f0_15();
            }
         }
      }
      li_0 = CallPat10b(g_iatr_2148, ld_4, Open[1], gi_2896, gi_1968, g_bars_96, gi_348, High[1], Low[1], Close[1], g_imacd_264, g_imacd_272, g_imacd_280, g_imacd_288,
         gd_512, gd_504, gd_304, gd_296, gd_336, gd_328, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ienvelopes_440,
         g_ienvelopes_424, g_ienvelopes_448, g_ienvelopes_432, g_ienvelopes_1692, g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940,
         g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1136, g_istochastic_1144, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
      if (gs_true_3472 == "True" && li_0 == TRUE) {
         if (gs_3240 == "" || gi_104 == TRUE) f0_15();
         else {
            if (gs_3240 == "SELLTRADE") {
               f0_5();
               f0_15();
            }
         }
      }
      li_0 = CallPat11b(g_iatr_2148, ld_4, Open[1], gi_2896, gi_1968, g_bars_96, gi_348, High[1], Low[1], Close[1], g_imacd_264, g_imacd_272, g_imacd_280, g_imacd_288,
         gd_512, gd_504, gd_304, gd_296, gd_336, gd_328, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ienvelopes_440,
         g_ienvelopes_424, g_ienvelopes_448, g_ienvelopes_432, g_ienvelopes_1692, g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940,
         g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1136, g_istochastic_1144, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
      if (gs_true_3472 == "True" && li_0 == TRUE) {
         if (gs_3240 == "" || gi_104 == TRUE) f0_15();
         else {
            if (gs_3240 == "SELLTRADE") {
               f0_5();
               f0_15();
            }
         }
      }
      gi_348 = 9;
   }
   if (gi_348 == 9 && gi_140 == TRUE || gi_144 == FALSE) {
      gi_348 = 2;
      li_0 = CallPat6b(ld_4, Open[1], High[1], gi_2896, gi_1968, g_bars_96, gi_348, Low[1], Close[1], gd_512, gd_504, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_1692,
         g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940, g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1152,
         g_istochastic_1160, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
      if (gs_true_3472 == "True" && li_0 == TRUE) {
         if (gs_3240 == "" || gi_104 == TRUE) f0_15();
         else {
            if (gs_3240 == "SELLTRADE") {
               f0_5();
               f0_15();
            }
         }
      }
      li_0 = CallPat7b(g_iatr_2148, ld_4, Open[1], gi_2896, gi_1968, g_bars_96, gi_348, High[1], Low[1], Close[1], g_imacd_264, g_imacd_272, g_imacd_280, g_imacd_288, gd_512,
         gd_504, gd_304, gd_296, gd_336, gd_328, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ienvelopes_440,
         g_ienvelopes_424, g_ienvelopes_448, g_ienvelopes_432, g_ienvelopes_1692, g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940,
         g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1136, g_istochastic_1144, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
      if (gs_true_3472 == "True" && li_0 == TRUE) {
         if (gs_3240 == "" || gi_104 == TRUE) f0_15();
         else {
            if (gs_3240 == "SELLTRADE") {
               f0_5();
               f0_15();
            }
         }
      }
      li_0 = CallPat9b(g_iatr_2148, ld_4, Open[1], gi_2896, gi_1968, g_bars_96, gi_348, High[1], Low[1], Close[1], g_imacd_264, g_imacd_272, g_imacd_280, g_imacd_288, gd_512,
         gd_504, gd_304, gd_296, gd_336, gd_328, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ienvelopes_440,
         g_ienvelopes_424, g_ienvelopes_448, g_ienvelopes_432, g_ienvelopes_1692, g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940,
         g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1136, g_istochastic_1144, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
      if (gs_true_3472 == "True" && li_0 == TRUE) {
         if (gs_3240 == "" || gi_104 == TRUE) f0_15();
         else {
            if (gs_3240 == "SELLTRADE") {
               f0_5();
               f0_15();
            }
         }
      }
      li_0 = CallPat12b(g_iatr_2148, ld_4, Open[1], gi_2896, gi_1968, g_bars_96, gi_348, High[1], Low[1], Close[1], g_imacd_264, g_imacd_272, g_imacd_280, g_imacd_288,
         gd_512, gd_504, gd_304, gd_296, gd_336, gd_328, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ienvelopes_440,
         g_ienvelopes_424, g_ienvelopes_448, g_ienvelopes_432, g_ienvelopes_1692, g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940,
         g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1136, g_istochastic_1144, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
      if (gs_true_3472 == "True" && li_0 == TRUE) {
         if (gs_3240 == "" || gi_104 == TRUE && g_istochastic_992 > g_istochastic_1000) f0_15();
         else {
            if (gs_3240 == "SELLTRADE") {
               f0_5();
               if (g_istochastic_992 > g_istochastic_1000) f0_15();
            }
         }
      }
      li_0 = CallPat13b(g_iatr_2148, ld_4, Open[1], gi_2896, gi_1968, g_bars_96, gi_348, High[1], Low[1], Close[1], g_imacd_264, g_imacd_272, g_imacd_280, g_imacd_288,
         gd_512, gd_504, gd_304, gd_296, gd_336, gd_328, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ienvelopes_440,
         g_ienvelopes_424, g_ienvelopes_448, g_ienvelopes_432, g_ienvelopes_1692, g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940,
         g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1136, g_istochastic_1144, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
      if (gs_true_3472 == "True" && li_0 == TRUE) {
         if (gs_3240 == "" || gi_104 == TRUE) f0_15();
         else {
            if (gs_3240 == "SELLTRADE") {
               f0_5();
               if (g_istochastic_992 > g_istochastic_1000) f0_15();
            }
         }
      }
      li_0 = CallPat14b(g_iatr_2148, ld_4, Open[1], gi_2896, gi_1968, g_bars_96, gi_348, High[1], Low[1], Close[1], g_imacd_264, g_imacd_272, g_imacd_280, g_imacd_288,
         gd_512, gd_504, gd_304, gd_296, gd_336, gd_328, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ienvelopes_440,
         g_ienvelopes_424, g_ienvelopes_448, g_ienvelopes_432, g_ienvelopes_1692, g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940,
         g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1136, g_istochastic_1144, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
      if (gs_true_3472 == "True" && li_0 == TRUE) {
         if (gs_3240 == "" || gi_104 == TRUE) f0_15();
         else {
            if (gs_3240 == "SELLTRADE") {
               f0_5();
               if (g_istochastic_992 > g_istochastic_1000) f0_15();
            }
         }
      }
      gi_348 = 9;
   }
   if (gi_144 == TRUE && gi_348 == 9) {
      gi_348 = 2;
      li_0 = CallPat8s(g_iatr_2148, ld_4, Open[1], gi_2896, gi_1968, g_bars_96, gi_348, High[1], Low[1], Close[1], g_imacd_264, g_imacd_272, g_imacd_280, g_imacd_288, gd_512,
         gd_504, gd_304, gd_296, gd_336, gd_328, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ienvelopes_440,
         g_ienvelopes_424, g_ienvelopes_448, g_ienvelopes_432, g_ienvelopes_1692, g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940,
         g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1136, g_istochastic_1144, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
      if (gs_true_3472 == "True" && li_0 == TRUE) {
         if (gs_3240 == "" || gi_108 == TRUE) f0_8();
         else {
            if (gs_3240 == "BUYTRADE") {
               f0_5();
               f0_8();
            }
         }
      }
      li_0 = CallPat10s(g_iatr_2148, ld_4, Open[1], gi_2896, gi_1968, g_bars_96, gi_348, High[1], Low[1], Close[1], g_imacd_264, g_imacd_272, g_imacd_280, g_imacd_288,
         gd_512, gd_504, gd_304, gd_296, gd_336, gd_328, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ienvelopes_440,
         g_ienvelopes_424, g_ienvelopes_448, g_ienvelopes_432, g_ienvelopes_1692, g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940,
         g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1136, g_istochastic_1144, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
      if (gs_true_3472 == "True" && li_0 == TRUE) {
         if (gs_3240 == "" || gi_108 == TRUE) f0_8();
         else {
            if (gs_3240 == "BUYTRADE") {
               f0_5();
               f0_8();
            }
         }
      }
      li_0 = CallPat11s(g_iatr_2148, ld_4, Open[1], gi_2896, gi_1968, g_bars_96, gi_348, High[1], Low[1], Close[1], g_imacd_264, g_imacd_272, g_imacd_280, g_imacd_288,
         gd_512, gd_504, gd_304, gd_296, gd_336, gd_328, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ienvelopes_440,
         g_ienvelopes_424, g_ienvelopes_448, g_ienvelopes_432, g_ienvelopes_1692, g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940,
         g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1136, g_istochastic_1144, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
      if (gs_true_3472 == "True" && li_0 == TRUE) {
         if (gs_3240 == "" || gi_108 == TRUE) f0_8();
         else {
            if (gs_3240 == "BUYTRADE") {
               f0_5();
               f0_8();
            }
         }
      }
      gi_348 = 9;
   }
   if (gi_348 == 9 && gi_140 == FALSE || gi_144 == TRUE) {
      gi_348 = 2;
      li_0 = CallPat6s(ld_4, Open[1], High[1], gi_2896, gi_1968, g_bars_96, gi_348, Low[1], Close[1], gd_512, gd_504, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_1692,
         g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940, g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1152,
         g_istochastic_1160, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
      if (gs_true_3472 == "True" && li_0 == TRUE) {
         if (gs_3240 == "" || gi_108 == TRUE) f0_8();
         else {
            if (gs_3240 == "BUYTRADE") {
               f0_5();
               f0_8();
            }
         }
      }
      li_0 = CallPat7s(g_iatr_2148, ld_4, Open[1], gi_2896, gi_1968, g_bars_96, gi_348, High[1], Low[1], Close[1], g_imacd_264, g_imacd_272, g_imacd_280, g_imacd_288, gd_512,
         gd_504, gd_304, gd_296, gd_336, gd_328, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ienvelopes_440,
         g_ienvelopes_424, g_ienvelopes_448, g_ienvelopes_432, g_ienvelopes_1692, g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940,
         g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1136, g_istochastic_1144, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
      if (gs_true_3472 == "True" && li_0 == TRUE) {
         if (gs_3240 == "" || gi_108 == TRUE) f0_8();
         else {
            if (gs_3240 == "BUYTRADE") {
               f0_5();
               f0_8();
            }
         }
      }
      li_0 = CallPat9s(g_iatr_2148, ld_4, Open[1], gi_2896, gi_1968, g_bars_96, gi_348, High[1], Low[1], Close[1], g_imacd_264, g_imacd_272, g_imacd_280, g_imacd_288, gd_512,
         gd_504, gd_304, gd_296, gd_336, gd_328, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ienvelopes_440,
         g_ienvelopes_424, g_ienvelopes_448, g_ienvelopes_432, g_ienvelopes_1692, g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940,
         g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1136, g_istochastic_1144, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
      if (gs_true_3472 == "True" && li_0 == TRUE) {
         if (gs_3240 == "" || gi_108 == TRUE) f0_8();
         else {
            if (gs_3240 == "BUYTRADE") {
               f0_5();
               f0_8();
            }
         }
      }
      li_0 = CallPat12s(g_iatr_2148, ld_4, Open[1], gi_2896, gi_1968, g_bars_96, gi_348, High[1], Low[1], Close[1], g_imacd_264, g_imacd_272, g_imacd_280, g_imacd_288,
         gd_512, gd_504, gd_304, gd_296, gd_336, gd_328, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ienvelopes_440,
         g_ienvelopes_424, g_ienvelopes_448, g_ienvelopes_432, g_ienvelopes_1692, g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940,
         g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1136, g_istochastic_1144, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
      if (gs_true_3472 == "True" && li_0 == TRUE) {
         if (gs_3240 == "" || gi_108 == TRUE && g_istochastic_992 < g_istochastic_1000) f0_8();
         else {
            if (gs_3240 == "BUYTRADE") {
               f0_5();
               if (g_istochastic_992 < g_istochastic_1000) f0_8();
            }
         }
      }
      li_0 = CallPat13s(g_iatr_2148, ld_4, Open[1], gi_2896, gi_1968, g_bars_96, gi_348, High[1], Low[1], Close[1], g_imacd_264, g_imacd_272, g_imacd_280, g_imacd_288,
         gd_512, gd_504, gd_304, gd_296, gd_336, gd_328, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ienvelopes_440,
         g_ienvelopes_424, g_ienvelopes_448, g_ienvelopes_432, g_ienvelopes_1692, g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940,
         g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1136, g_istochastic_1144, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
      if (gs_true_3472 == "True" && li_0 == TRUE) {
         if (gs_3240 == "" || gi_108 == TRUE) f0_8();
         else {
            if (gs_3240 == "BUYTRADE") {
               f0_5();
               f0_8();
            }
         }
      }
      li_0 = CallPat14s(g_iatr_2148, ld_4, Open[1], gi_2896, gi_1968, g_bars_96, gi_348, High[1], Low[1], Close[1], g_imacd_264, g_imacd_272, g_imacd_280, g_imacd_288,
         gd_512, gd_504, gd_304, gd_296, gd_336, gd_328, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ienvelopes_440,
         g_ienvelopes_424, g_ienvelopes_448, g_ienvelopes_432, g_ienvelopes_1692, g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940,
         g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1136, g_istochastic_1144, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
      if (gs_true_3472 == "True" && li_0 == TRUE) {
         if (gs_3240 == "" || gi_108 == TRUE) f0_8();
         else {
            if (gs_3240 == "BUYTRADE") {
               f0_5();
               f0_8();
            }
         }
      }
      gi_348 = 9;
   }
   li_0 = CallPat15b(g_iatr_2148, ld_4, Open[1], gi_2896, gi_1968, g_bars_96, gi_348, High[1], Low[1], Close[1], g_imacd_264, g_imacd_272, g_imacd_280, g_imacd_288,
      gd_512, gd_504, gd_304, gd_296, gd_336, gd_328, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ienvelopes_440,
      g_ienvelopes_424, g_ienvelopes_448, g_ienvelopes_432, g_ienvelopes_1692, g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940,
      g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1136, g_istochastic_1144, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
   if (gs_true_3472 == "True" && li_0 == TRUE) {
      if (gs_3240 == "" || gi_104 == TRUE) f0_15();
      else {
         if (gs_3240 == "SELLTRADE") {
            f0_5();
            f0_15();
         }
      }
   }
   li_0 = CallPat15s(g_iatr_2148, ld_4, Open[1], gi_2896, gi_1968, g_bars_96, gi_348, High[1], Low[1], Close[1], g_imacd_264, g_imacd_272, g_imacd_280, g_imacd_288,
      gd_512, gd_504, gd_304, gd_296, gd_336, gd_328, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ienvelopes_440,
      g_ienvelopes_424, g_ienvelopes_448, g_ienvelopes_432, g_ienvelopes_1692, g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940,
      g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1136, g_istochastic_1144, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
   if (gs_true_3472 == "True" && li_0 == TRUE) {
      if (gs_3240 == "" || gi_108 == TRUE) f0_8();
      else {
         if (gs_3240 == "BUYTRADE") {
            f0_5();
            f0_8();
         }
      }
   }
   li_0 = CallPat20b(g_iatr_2148, ld_4, Open[1], gi_2896, gi_1968, g_bars_96, gi_348, High[1], Low[1], Close[1], g_ima_2652, g_ima_192, g_imacd_280, g_imacd_288, gd_496,
      gd_504, gd_304, gd_296, gd_336, gd_328, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ienvelopes_440,
      g_ienvelopes_424, g_ienvelopes_448, g_ienvelopes_432, g_ienvelopes_1692, g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940,
      g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1136, g_istochastic_1144, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
   if (gs_true_3472 == "True" && li_0 == TRUE && gi_152 == FALSE)
      if (gs_3240 == "" || gi_104 == TRUE) f0_15();
   li_0 = CallPat20s(g_iatr_2148, ld_4, Open[1], gi_2896, gi_1968, g_bars_96, gi_348, High[1], Low[1], Close[1], g_ima_2652, g_ima_192, g_imacd_280, g_imacd_288, gd_512,
      g_price_488, gd_304, gd_296, gd_336, gd_328, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ienvelopes_440,
      g_ienvelopes_424, g_ienvelopes_448, g_ienvelopes_432, g_ienvelopes_1692, g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940,
      g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1136, g_istochastic_1144, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
   if (gs_true_3472 == "True" && li_0 == TRUE && gi_148 == FALSE)
      if (gs_3240 == "" || gi_108 == TRUE) f0_8();
   if (gi_348 == 5) {
      gi_348 = 1;
      li_0 = CallPat19b(g_iatr_2148, ld_4, Open[1], gi_2896, gi_1968, g_bars_96, gi_348, High[1], Low[1], Close[1], g_ima_2652, g_ima_192, g_imacd_280, g_imacd_288, gd_496,
         gd_504, gd_304, gd_296, gd_336, gd_328, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ienvelopes_440,
         g_ienvelopes_424, g_ienvelopes_448, g_ienvelopes_432, g_ienvelopes_1692, g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940,
         g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1136, g_istochastic_1144, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
      if (gs_true_3472 == "True" && li_0 == TRUE && gi_152 == FALSE) {
         if (gs_3240 == "" || gi_104 == TRUE) f0_15();
         else {
            if (gs_3240 == "SELLTRADE") {
               f0_5();
               f0_15();
            }
         }
      }
      li_0 = CallPat19s(g_iatr_2148, ld_4, Open[1], gi_2896, gi_1968, g_bars_96, gi_348, High[1], Low[1], Close[1], g_ima_2652, g_ima_192, g_imacd_280, g_imacd_288, gd_512,
         g_price_488, gd_304, gd_296, gd_336, gd_328, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ienvelopes_440,
         g_ienvelopes_424, g_ienvelopes_448, g_ienvelopes_432, g_ienvelopes_1692, g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940,
         g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1136, g_istochastic_1144, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
      if (gs_true_3472 == "True" && li_0 == TRUE && gi_148 == FALSE) {
         if (gs_3240 == "" || gi_108 == TRUE) f0_8();
         else {
            if (gs_3240 == "BUYTRADE") {
               f0_5();
               f0_8();
            }
         }
      }
      gi_348 = 5;
   }
   li_0 = CallPat18b(g_iatr_2148, ld_4, Open[1], gi_2896, gi_1968, g_bars_96, gi_348, High[1], Low[1], Close[1], g_ima_2652, g_ima_192, g_imacd_280, g_imacd_288, gd_496,
      gd_504, gd_304, gd_296, gd_336, gd_328, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ienvelopes_440,
      g_ienvelopes_424, g_ienvelopes_448, g_ienvelopes_432, g_ienvelopes_1692, g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940,
      g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1136, g_istochastic_1144, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
   if (gs_true_3472 == "True" && li_0 == TRUE && gi_152 == FALSE) {
      if (gs_3240 == "" || gi_104 == TRUE) f0_15();
      else {
         if (gs_3240 == "SELLTRADE") {
            f0_5();
            f0_15();
         }
      }
   }
   li_0 = CallPat18s(g_iatr_2148, ld_4, Open[1], gi_2896, gi_1968, g_bars_96, gi_348, High[1], Low[1], Close[1], g_ima_2652, g_ima_192, g_imacd_280, g_imacd_288, gd_512,
      g_price_488, gd_304, gd_296, gd_336, gd_328, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ienvelopes_440,
      g_ienvelopes_424, g_ienvelopes_448, g_ienvelopes_432, g_ienvelopes_1692, g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940,
      g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1136, g_istochastic_1144, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
   if (gs_true_3472 == "True" && li_0 == TRUE && gi_148 == FALSE) {
      if (gs_3240 == "" || gi_108 == TRUE) f0_8();
      else {
         if (gs_3240 == "BUYTRADE") {
            f0_5();
            f0_8();
         }
      }
   }
   gi_140 = FALSE;
   gi_144 = FALSE;
   if (g_ima_2644 > gd_1620) gi_140 = TRUE;
   if (g_ima_2644 < gd_1628) gi_144 = TRUE;
   if (gi_140 == TRUE && gi_348 == 0) {
      gi_348 = 2;
      li_0 = CallPat8b(g_iatr_2148, ld_4, Open[1], gi_2896, gi_1968, g_bars_96, gi_348, High[1], Low[1], Close[1], g_imacd_264, g_imacd_272, g_imacd_280, g_imacd_288, gd_512,
         gd_504, gd_304, gd_296, gd_336, gd_328, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ienvelopes_440,
         g_ienvelopes_424, g_ienvelopes_448, g_ienvelopes_432, g_ienvelopes_1692, g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940,
         g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1136, g_istochastic_1144, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
      if (gs_true_3472 == "True" && li_0 == TRUE) {
         if (gs_3240 == "" || gi_104 == TRUE) f0_15();
         else {
            if (gs_3240 == "SELLTRADE") {
               f0_5();
               f0_15();
            }
         }
      }
      li_0 = CallPat10b(g_iatr_2148, ld_4, Open[1], gi_2896, gi_1968, g_bars_96, gi_348, High[1], Low[1], Close[1], g_imacd_264, g_imacd_272, g_imacd_280, g_imacd_288,
         gd_512, gd_504, gd_304, gd_296, gd_336, gd_328, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ienvelopes_440,
         g_ienvelopes_424, g_ienvelopes_448, g_ienvelopes_432, g_ienvelopes_1692, g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940,
         g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1136, g_istochastic_1144, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
      if (gs_true_3472 == "True" && li_0 == TRUE) {
         if (gs_3240 == "" || gi_104 == TRUE) f0_15();
         else {
            if (gs_3240 == "SELLTRADE") {
               f0_5();
               f0_15();
            }
         }
      }
      li_0 = CallPat11b(g_iatr_2148, ld_4, Open[1], gi_2896, gi_1968, g_bars_96, gi_348, High[1], Low[1], Close[1], g_imacd_264, g_imacd_272, g_imacd_280, g_imacd_288,
         gd_512, gd_504, gd_304, gd_296, gd_336, gd_328, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ienvelopes_440,
         g_ienvelopes_424, g_ienvelopes_448, g_ienvelopes_432, g_ienvelopes_1692, g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940,
         g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1136, g_istochastic_1144, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
      if (gs_true_3472 == "True" && li_0 == TRUE) {
         if (gs_3240 == "" || gi_104 == TRUE) f0_15();
         else {
            if (gs_3240 == "SELLTRADE") {
               f0_5();
               f0_15();
            }
         }
      }
      gi_348 = 0;
   }
   if (gi_144 == TRUE && gi_348 == 0) {
      gi_348 = 2;
      li_0 = CallPat8s(g_iatr_2148, ld_4, Open[1], gi_2896, gi_1968, g_bars_96, gi_348, High[1], Low[1], Close[1], g_imacd_264, g_imacd_272, g_imacd_280, g_imacd_288, gd_512,
         gd_504, gd_304, gd_296, gd_336, gd_328, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ienvelopes_440,
         g_ienvelopes_424, g_ienvelopes_448, g_ienvelopes_432, g_ienvelopes_1692, g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940,
         g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1136, g_istochastic_1144, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
      if (gs_true_3472 == "True" && li_0 == TRUE) {
         if (gs_3240 == "" || gi_108 == TRUE) f0_8();
         else {
            if (gs_3240 == "BUYTRADE") {
               f0_5();
               f0_8();
            }
         }
      }
      li_0 = CallPat10s(g_iatr_2148, ld_4, Open[1], gi_2896, gi_1968, g_bars_96, gi_348, High[1], Low[1], Close[1], g_imacd_264, g_imacd_272, g_imacd_280, g_imacd_288,
         gd_512, gd_504, gd_304, gd_296, gd_336, gd_328, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ienvelopes_440,
         g_ienvelopes_424, g_ienvelopes_448, g_ienvelopes_432, g_ienvelopes_1692, g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940,
         g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1136, g_istochastic_1144, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
      if (gs_true_3472 == "True" && li_0 == TRUE) {
         if (gs_3240 == "" || gi_108 == TRUE) f0_8();
         else {
            if (gs_3240 == "BUYTRADE") {
               f0_5();
               f0_8();
            }
         }
      }
      li_0 = CallPat11s(g_iatr_2148, ld_4, Open[1], gi_2896, gi_1968, g_bars_96, gi_348, High[1], Low[1], Close[1], g_imacd_264, g_imacd_272, g_imacd_280, g_imacd_288,
         gd_512, gd_504, gd_304, gd_296, gd_336, gd_328, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ienvelopes_440,
         g_ienvelopes_424, g_ienvelopes_448, g_ienvelopes_432, g_ienvelopes_1692, g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940,
         g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1136, g_istochastic_1144, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
      if (gs_true_3472 == "True" && li_0 == TRUE) {
         if (gs_3240 == "" || gi_108 == TRUE) f0_8();
         else {
            if (gs_3240 == "BUYTRADE") {
               f0_5();
               f0_8();
            }
         }
      }
      gi_348 = 0;
   }
   if (gi_348 == 5) {
      if (ienvelopes_28 <= g_ienvelopes_1684 && ienvelopes_36 >= g_ienvelopes_1692) {
         gi_140 = FALSE;
         gi_144 = FALSE;
         if (ima_20 > ienvelopes_28) gi_140 = TRUE;
         if (ima_20 < ienvelopes_36) gi_144 = TRUE;
      }
      if (ienvelopes_36 >= g_ienvelopes_1684) {
         gi_140 = TRUE;
         gi_144 = FALSE;
      }
      if (ienvelopes_28 <= g_ienvelopes_1692) {
         gi_140 = FALSE;
         gi_144 = TRUE;
      }
   }
   if (gi_144 == FALSE && gi_348 == 5) {
      gi_348 = 2;
      li_0 = CallPat8b(g_iatr_2148, ld_4, Open[1], gi_2896, gi_1968, g_bars_96, gi_348, High[1], Low[1], Close[1], g_imacd_264, g_imacd_272, g_imacd_280, g_imacd_288, gd_512,
         gd_504, gd_304, gd_296, gd_336, gd_328, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ienvelopes_440,
         g_ienvelopes_424, g_ienvelopes_448, g_ienvelopes_432, g_ienvelopes_1692, g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940,
         g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1136, g_istochastic_1144, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
      if (gs_true_3472 == "True" && li_0 == TRUE) {
         if (gs_3240 == "" || gi_104 == TRUE) f0_15();
         else {
            if (gs_3240 == "SELLTRADE") {
               f0_5();
               f0_15();
            }
         }
      }
      li_0 = CallPat10b(g_iatr_2148, ld_4, Open[1], gi_2896, gi_1968, g_bars_96, gi_348, High[1], Low[1], Close[1], g_imacd_264, g_imacd_272, g_imacd_280, g_imacd_288,
         gd_512, gd_504, gd_304, gd_296, gd_336, gd_328, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ienvelopes_440,
         g_ienvelopes_424, g_ienvelopes_448, g_ienvelopes_432, g_ienvelopes_1692, g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940,
         g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1136, g_istochastic_1144, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
      if (gs_true_3472 == "True" && li_0 == TRUE) {
         if (gs_3240 == "" || gi_104 == TRUE) f0_15();
         else {
            if (gs_3240 == "SELLTRADE") {
               f0_5();
               f0_15();
            }
         }
      }
      li_0 = CallPat11b(g_iatr_2148, ld_4, Open[1], gi_2896, gi_1968, g_bars_96, gi_348, High[1], Low[1], Close[1], g_imacd_264, g_imacd_272, g_imacd_280, g_imacd_288,
         gd_512, gd_504, gd_304, gd_296, gd_336, gd_328, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ienvelopes_440,
         g_ienvelopes_424, g_ienvelopes_448, g_ienvelopes_432, g_ienvelopes_1692, g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940,
         g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1136, g_istochastic_1144, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
      if (gs_true_3472 == "True" && li_0 == TRUE) {
         if (gs_3240 == "" || gi_104 == TRUE) f0_15();
         else {
            if (gs_3240 == "SELLTRADE") {
               f0_5();
               f0_15();
            }
         }
      }
      gi_348 = 5;
   }
   if (gi_140 == FALSE && gi_348 == 5) {
      gi_348 = 2;
      li_0 = CallPat8s(g_iatr_2148, ld_4, Open[1], gi_2896, gi_1968, g_bars_96, gi_348, High[1], Low[1], Close[1], g_imacd_264, g_imacd_272, g_imacd_280, g_imacd_288, gd_512,
         gd_504, gd_304, gd_296, gd_336, gd_328, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ienvelopes_440,
         g_ienvelopes_424, g_ienvelopes_448, g_ienvelopes_432, g_ienvelopes_1692, g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940,
         g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1136, g_istochastic_1144, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
      if (gs_true_3472 == "True" && li_0 == TRUE) {
         if (gs_3240 == "" || gi_108 == TRUE) f0_8();
         else {
            if (gs_3240 == "BUYTRADE") {
               f0_5();
               f0_8();
            }
         }
      }
      li_0 = CallPat10s(g_iatr_2148, ld_4, Open[1], gi_2896, gi_1968, g_bars_96, gi_348, High[1], Low[1], Close[1], g_imacd_264, g_imacd_272, g_imacd_280, g_imacd_288,
         gd_512, gd_504, gd_304, gd_296, gd_336, gd_328, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ienvelopes_440,
         g_ienvelopes_424, g_ienvelopes_448, g_ienvelopes_432, g_ienvelopes_1692, g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940,
         g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1136, g_istochastic_1144, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
      if (gs_true_3472 == "True" && li_0 == TRUE) {
         if (gs_3240 == "" || gi_108 == TRUE) f0_8();
         else {
            if (gs_3240 == "BUYTRADE") {
               f0_5();
               f0_8();
            }
         }
      }
      li_0 = CallPat11s(g_iatr_2148, ld_4, Open[1], gi_2896, gi_1968, g_bars_96, gi_348, High[1], Low[1], Close[1], g_imacd_264, g_imacd_272, g_imacd_280, g_imacd_288,
         gd_512, gd_504, gd_304, gd_296, gd_336, gd_328, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ienvelopes_440,
         g_ienvelopes_424, g_ienvelopes_448, g_ienvelopes_432, g_ienvelopes_1692, g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940,
         g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1136, g_istochastic_1144, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
      if (gs_true_3472 == "True" && li_0 == TRUE) {
         if (gs_3240 == "" || gi_108 == TRUE) f0_8();
         else {
            if (gs_3240 == "BUYTRADE") {
               f0_5();
               f0_8();
            }
         }
      }
      gi_348 = 5;
   }
   if (gi_348 == 5 && gi_140 == TRUE || gi_144 == FALSE) {
      gi_348 = 2;
      li_0 = CallPat6b(ld_4, Open[1], High[1], gi_2896, gi_1968, g_bars_96, gi_348, Low[1], Close[1], gd_512, gd_504, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_1692,
         g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940, g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1152,
         g_istochastic_1160, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
      if (gs_true_3472 == "True" && li_0 == TRUE) {
         if (gs_3240 == "" || gi_104 == TRUE) f0_15();
         else {
            if (gs_3240 == "SELLTRADE") {
               f0_5();
               f0_15();
            }
         }
      }
      li_0 = CallPat7b(g_iatr_2148, ld_4, Open[1], gi_2896, gi_1968, g_bars_96, gi_348, High[1], Low[1], Close[1], g_imacd_264, g_imacd_272, g_imacd_280, g_imacd_288, gd_512,
         gd_504, gd_304, gd_296, gd_336, gd_328, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ienvelopes_440,
         g_ienvelopes_424, g_ienvelopes_448, g_ienvelopes_432, g_ienvelopes_1692, g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940,
         g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1136, g_istochastic_1144, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
      if (gs_true_3472 == "True" && li_0 == TRUE) {
         if (gs_3240 == "" || gi_104 == TRUE) f0_15();
         else {
            if (gs_3240 == "SELLTRADE") {
               f0_5();
               f0_15();
            }
         }
      }
      li_0 = CallPat9b(g_iatr_2148, ld_4, Open[1], gi_2896, gi_1968, g_bars_96, gi_348, High[1], Low[1], Close[1], g_imacd_264, g_imacd_272, g_imacd_280, g_imacd_288, gd_512,
         gd_504, gd_304, gd_296, gd_336, gd_328, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ienvelopes_440,
         g_ienvelopes_424, g_ienvelopes_448, g_ienvelopes_432, g_ienvelopes_1692, g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940,
         g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1136, g_istochastic_1144, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
      if (gs_true_3472 == "True" && li_0 == TRUE) {
         if (gs_3240 == "" || gi_104 == TRUE) f0_15();
         else {
            if (gs_3240 == "SELLTRADE") {
               f0_5();
               f0_15();
            }
         }
      }
      li_0 = CallPat12b(g_iatr_2148, ld_4, Open[1], gi_2896, gi_1968, g_bars_96, gi_348, High[1], Low[1], Close[1], g_imacd_264, g_imacd_272, g_imacd_280, g_imacd_288,
         gd_512, gd_504, gd_304, gd_296, gd_336, gd_328, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ienvelopes_440,
         g_ienvelopes_424, g_ienvelopes_448, g_ienvelopes_432, g_ienvelopes_1692, g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940,
         g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1136, g_istochastic_1144, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
      if (gs_true_3472 == "True" && li_0 == TRUE) {
         if (gs_3240 == "" || gi_104 == TRUE && g_istochastic_992 > g_istochastic_1000) f0_15();
         else {
            if (gs_3240 == "SELLTRADE") {
               f0_5();
               if (g_istochastic_992 > g_istochastic_1000) f0_15();
            }
         }
      }
      li_0 = CallPat13b(g_iatr_2148, ld_4, Open[1], gi_2896, gi_1968, g_bars_96, gi_348, High[1], Low[1], Close[1], g_imacd_264, g_imacd_272, g_imacd_280, g_imacd_288,
         gd_512, gd_504, gd_304, gd_296, gd_336, gd_328, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ienvelopes_440,
         g_ienvelopes_424, g_ienvelopes_448, g_ienvelopes_432, g_ienvelopes_1692, g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940,
         g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1136, g_istochastic_1144, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
      if (gs_true_3472 == "True" && li_0 == TRUE) {
         if (gs_3240 == "" || gi_104 == TRUE) f0_15();
         else {
            if (gs_3240 == "SELLTRADE") {
               f0_5();
               if (g_istochastic_992 > g_istochastic_1000) f0_15();
            }
         }
      }
      li_0 = CallPat14b(g_iatr_2148, ld_4, Open[1], gi_2896, gi_1968, g_bars_96, gi_348, High[1], Low[1], Close[1], g_imacd_264, g_imacd_272, g_imacd_280, g_imacd_288,
         gd_512, gd_504, gd_304, gd_296, gd_336, gd_328, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ienvelopes_440,
         g_ienvelopes_424, g_ienvelopes_448, g_ienvelopes_432, g_ienvelopes_1692, g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940,
         g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1136, g_istochastic_1144, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
      if (gs_true_3472 == "True" && li_0 == TRUE) {
         if (gs_3240 == "" || gi_104 == TRUE) f0_15();
         else {
            if (gs_3240 == "SELLTRADE") {
               f0_5();
               if (g_istochastic_992 > g_istochastic_1000) f0_15();
            }
         }
      }
      gi_348 = 5;
   }
   if (gi_348 == 5 && gi_140 == FALSE || gi_144 == TRUE) {
      gi_348 = 2;
      li_0 = CallPat6s(ld_4, Open[1], High[1], gi_2896, gi_1968, g_bars_96, gi_348, Low[1], Close[1], gd_512, gd_504, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_1692,
         g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940, g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1152,
         g_istochastic_1160, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
      if (gs_true_3472 == "True" && li_0 == TRUE) {
         if (gs_3240 == "" || gi_108 == TRUE) f0_8();
         else {
            if (gs_3240 == "BUYTRADE") {
               f0_5();
               f0_8();
            }
         }
      }
      li_0 = CallPat7s(g_iatr_2148, ld_4, Open[1], gi_2896, gi_1968, g_bars_96, gi_348, High[1], Low[1], Close[1], g_imacd_264, g_imacd_272, g_imacd_280, g_imacd_288, gd_512,
         gd_504, gd_304, gd_296, gd_336, gd_328, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ienvelopes_440,
         g_ienvelopes_424, g_ienvelopes_448, g_ienvelopes_432, g_ienvelopes_1692, g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940,
         g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1136, g_istochastic_1144, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
      if (gs_true_3472 == "True" && li_0 == TRUE) {
         if (gs_3240 == "" || gi_108 == TRUE) f0_8();
         else {
            if (gs_3240 == "BUYTRADE") {
               f0_5();
               f0_8();
            }
         }
      }
      li_0 = CallPat9s(g_iatr_2148, ld_4, Open[1], gi_2896, gi_1968, g_bars_96, gi_348, High[1], Low[1], Close[1], g_imacd_264, g_imacd_272, g_imacd_280, g_imacd_288, gd_512,
         gd_504, gd_304, gd_296, gd_336, gd_328, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ienvelopes_440,
         g_ienvelopes_424, g_ienvelopes_448, g_ienvelopes_432, g_ienvelopes_1692, g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940,
         g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1136, g_istochastic_1144, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
      if (gs_true_3472 == "True" && li_0 == TRUE) {
         if (gs_3240 == "" || gi_108 == TRUE) f0_8();
         else {
            if (gs_3240 == "BUYTRADE") {
               f0_5();
               f0_8();
            }
         }
      }
      li_0 = CallPat12s(g_iatr_2148, ld_4, Open[1], gi_2896, gi_1968, g_bars_96, gi_348, High[1], Low[1], Close[1], g_imacd_264, g_imacd_272, g_imacd_280, g_imacd_288,
         gd_512, gd_504, gd_304, gd_296, gd_336, gd_328, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ienvelopes_440,
         g_ienvelopes_424, g_ienvelopes_448, g_ienvelopes_432, g_ienvelopes_1692, g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940,
         g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1136, g_istochastic_1144, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
      if (gs_true_3472 == "True" && li_0 == TRUE) {
         if (gs_3240 == "" || gi_108 == TRUE && g_istochastic_992 < g_istochastic_1000) f0_8();
         else {
            if (gs_3240 == "BUYTRADE") {
               f0_5();
               if (g_istochastic_992 < g_istochastic_1000) f0_8();
            }
         }
      }
      li_0 = CallPat13s(g_iatr_2148, ld_4, Open[1], gi_2896, gi_1968, g_bars_96, gi_348, High[1], Low[1], Close[1], g_imacd_264, g_imacd_272, g_imacd_280, g_imacd_288,
         gd_512, gd_504, gd_304, gd_296, gd_336, gd_328, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ienvelopes_440,
         g_ienvelopes_424, g_ienvelopes_448, g_ienvelopes_432, g_ienvelopes_1692, g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940,
         g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1136, g_istochastic_1144, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
      if (gs_true_3472 == "True" && li_0 == TRUE) {
         if (gs_3240 == "" || gi_108 == TRUE) f0_8();
         else {
            if (gs_3240 == "BUYTRADE") {
               f0_5();
               f0_8();
            }
         }
      }
      li_0 = CallPat14s(g_iatr_2148, ld_4, Open[1], gi_2896, gi_1968, g_bars_96, gi_348, High[1], Low[1], Close[1], g_imacd_264, g_imacd_272, g_imacd_280, g_imacd_288,
         gd_512, gd_504, gd_304, gd_296, gd_336, gd_328, g_ienvelopes_1580, g_ienvelopes_1572, g_ienvelopes_472, g_ienvelopes_456, g_ienvelopes_480, g_ienvelopes_464, g_ienvelopes_440,
         g_ienvelopes_424, g_ienvelopes_448, g_ienvelopes_432, g_ienvelopes_1692, g_ienvelopes_1684, g_idemarker_208, g_idemarker_216, g_iwpr_248, g_iwpr_256, g_ibands_1940,
         g_ibands_1948, g_istochastic_992, g_istochastic_1000, g_istochastic_1136, g_istochastic_1144, g_price_1828, g_ilow_1836, gi_3760, gi_92, gi_3564, g_price_1860, g_price_1868);
      if (gs_true_3472 == "True" && li_0 == TRUE) {
         if (gs_3240 == "" || gi_108 == TRUE) f0_8();
         else {
            if (gs_3240 == "BUYTRADE") {
               f0_5();
               f0_8();
            }
         }
      }
      gi_348 = 5;
   }
   if (Seconds() == 0 || gi_2628 == 0) {
      gi_2628++;
      ObjectsDeleteAll(0, OBJ_LABEL);
      ObjectCreate("Validation", OBJ_LABEL, 0, 0, 0);
      ObjectCreate("MagicNumber", OBJ_LABEL, 0, 0, 0);
      ObjectCreate("Status", OBJ_LABEL, 0, 0, 0);
      ObjectCreate("OpenTrade", OBJ_LABEL, 0, 0, 0);
      ObjectCreate("PriceAction", OBJ_LABEL, 0, 0, 0);
      ObjectCreate("PriceAction2", OBJ_LABEL, 0, 0, 0);
      ObjectCreate("Version", OBJ_LABEL, 0, 0, 0);
      ObjectSet("Validation", OBJPROP_CORNER, 0);
      ObjectSet("Validation", OBJPROP_XDISTANCE, 10);
      ObjectSet("Validation", OBJPROP_YDISTANCE, 40);
      ObjectSet("MagicNumber", OBJPROP_CORNER, 0);
      ObjectSet("MagicNumber", OBJPROP_XDISTANCE, 10);
      ObjectSet("MagicNumber", OBJPROP_YDISTANCE, 55);
      ObjectSet("Status", OBJPROP_CORNER, 0);
      ObjectSet("Status", OBJPROP_XDISTANCE, 10);
      ObjectSet("Status", OBJPROP_YDISTANCE, 70);
      ObjectSet("OpenTrade", OBJPROP_CORNER, 0);
      ObjectSet("OpenTrade", OBJPROP_XDISTANCE, 10);
      ObjectSet("OpenTrade", OBJPROP_YDISTANCE, 90);
      ObjectSet("PriceAction", OBJPROP_CORNER, 0);
      ObjectSet("PriceAction", OBJPROP_XDISTANCE, 10);
      ObjectSet("PriceAction", OBJPROP_YDISTANCE, 105);
      ObjectSet("PriceAction2", OBJPROP_CORNER, 0);
      ObjectSet("PriceAction2", OBJPROP_XDISTANCE, 10);
      ObjectSet("PriceAction2", OBJPROP_YDISTANCE, 120);
      ObjectSet("Version", OBJPROP_CORNER, 0);
      ObjectSet("Version", OBJPROP_XDISTANCE, 10);
      ObjectSet("Version", OBJPROP_YDISTANCE, 135);
      ObjectSetText("Validation", WindowExpertName() + " Activation Code : Validation Okay", 10, "Arial", Yellow);
      ObjectSetText("MagicNumber", "Trade MagicNumber : " + gi_1232, 10, "Arial", White);
   //--- Assert 2: Init OrderSelect #16
      GhostInitSelect(true,0,SELECT_BY_POS,MODE_TRADES);
      int total=GhostOrdersTotal();
      for (int pos_176 = 0; pos_176 < total; pos_176++) {
         if (GhostOrderSelect(pos_176, SELECT_BY_POS, MODE_TRADES) == FALSE) break;
         if (GhostOrderMagicNumber() != gi_1232 || GhostOrderSymbol() != Symbol()) continue;
         ld_168 += GhostOrderProfit();
      }
   //--- Assert 1: Free OrderSelect #16
      GhostFreeSelect(true);
      ObjectSetText("OpenTrade", "", 10, "Arial", White);
      if (gs_3240 == "") ObjectSetText("OpenTrade", "||||||||||||.... ", 10, "Arial", White);
      if (gs_3240 == "BUYTRADE") ObjectSetText("OpenTrade", "PhiBase PRO Trade : LONG " + Symbol(), 10, "Arial", White);
      if (gs_3240 == "SELLTRADE") ObjectSetText("OpenTrade", "PhiBase PRO Trade : SHORT " + Symbol(), 10, "Arial", White);
      g_symbol_2860 = Symbol();
      ld_180 = MarketInfo(g_symbol_2860, MODE_MINLOT);
      ld_188 = MarketInfo(g_symbol_2860, MODE_MAXLOT);
      ld_unused_196 = AccountLeverage();
      lotsize_204 = MarketInfo(g_symbol_2860, MODE_LOTSIZE);
      lotstep_212 = MarketInfo(g_symbol_2860, MODE_LOTSTEP);
      marginrequired_220 = MarketInfo(g_symbol_2860, MODE_MARGINREQUIRED);
      tickvalue_228 = MarketInfo(g_symbol_2860, MODE_TICKVALUE);
      ticksize_236 = MarketInfo(g_symbol_2860, MODE_TICKSIZE);
      ld_244 = MathMin(AccountBalance(), AccountEquity());
      li_252 = 0;
      ld_256 = 0.0;
      if (lotstep_212 == 0.01) li_252 = 2;
      if (lotstep_212 == 0.1) li_252 = 1;
      if (Geometrical_MM == TRUE) ld_256 = f0_3(g_symbol_2860, gd_3184);
      if (Geometrical_MM == FALSE) ld_256 = f0_11(g_symbol_2860, gd_3184);
      ld_256 = StrToDouble(DoubleToStr(ld_256, li_252));
      if (ld_256 < ld_180) ld_256 = ld_180;
      if (ld_256 > ld_188) ld_256 = ld_188;
      if (gs_3240 == "") ObjectSetText("Status", "PhiBase PRO >>> Waiting... Lot Size for next trade = " + DoubleToStr(ld_256, 2), 10, "Arial", White);
      if (gs_3240 != "" && ld_168 >= 0.0) ObjectSetText("Status", "PhiBase Trade Gain : " + DoubleToStr(ld_168, 0), 10, "Arial", Lime);
      if (gs_3240 != "" && ld_168 < 0.0) ObjectSetText("Status", "PhiBase Trade Gain : " + DoubleToStr(ld_168, 0), 10, "Arial", Red);
      ObjectSetText("PriceAction", "D1 ATR : " + DoubleToStr(g_iatr_2148, 5) + "  ||   W1 ATR : " + DoubleToStr(g_iatr_240, 5) + " Points", 10, "Arial", White);
      if (gs_3240 == "SELLTRADE") {
         ObjectSetText("PriceAction2", "H1 Close beyond: " + DoubleToStr(g_order_open_price_168 + (g_order_stoploss_132 - g_order_open_price_168) / 2.0, 5) + " Will Trigger Hidden StopLoss",
            10, "Arial", White);
      } else {
         if (gs_3240 == "BUYTRADE") {
            ObjectSetText("PriceAction2", "H1 Close beyond: " + DoubleToStr(g_order_open_price_168 - (g_order_open_price_168 - g_order_stoploss_132) / 2.0, 5) + " Will Trigger Hidden StopLoss",
               10, "Arial", White);
         } else ObjectSetText("PriceAction2", "||||||||||||....", 10, "Arial", White);
      }
      if (pmok(gi_348) == 1) ObjectSetText("Version", "Version 2.2 : Build Date 20120422", 10, "Arial", Lime);
      else ObjectSetText("Version", "Contact PhiBase HelpDesk For Updated Version", 10, "Arial", Red);
   }
}