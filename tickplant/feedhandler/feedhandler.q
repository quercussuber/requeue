// q feedhandler/feedhandler.q :5010 -c 13 317 -t 100
// This process simulates a number of orders coming in from the market
// and sends them to the TICKER process
system"l tick/r.q"
system"l common/conn.q"
system"l feedhandler/lib.q"

.u.end:{'implementme}

.u.conn:{hopen `$":",x}each enlist[`tick]#.u.x;

upd:{'implementme}

SIM_ORDERS:1000

.fh.i:0;

.fh.ts:{
    batch:genOrders[SIM_ORDERS;.z.p];
    .fh.i+:SIM_ORDERS;
    // TODO trap errors like ticker being down
    .u.conn[`tick](`.u.upd;`order;batch);
    // Moving the market by symbol either up/down by a random amount so prices look like they are moving
    // NIT could have used the prices already generated for batch[`price] but that doenst generate
    // the same price movement for all symbols
    sym_px[`px]+:@[;(last 1?count sym_px[`px])? count sym_px[`px];neg] %[;1000]count[sym_px`px]?100;
    };

.z.ts:{
    .log.logInfo"Running Fedhandler ts";
    .u.ts[];
    .fh.ts[];
    }