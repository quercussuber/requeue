// q orderbook/orderbook.q :5010 -c 13 317 -t 100 -instance one
// This process simulates a bookbuilder/matching engine that 
// receives orders from the TICKER process and matches them against the order book
// sending execution reports back to the TICKER process
// It is meant to be run in conjunction with the TICKER process, and has ZERO
// state maintenance across restarts, nor recovery from crashes.. YET

system"l tick/r.q"
.log.setLogLevel`warning;


.orderbook.INSTANCE: "one"
system"l orderbook/lib.q"
system"l orderbook/schema.q"

system"l common/conn.q"
.u.conn:{hopen `$":",x}each enlist[`tick]#.u.x;


.u.end:{'implementme}
.u.rep:{(.[;();:;].)x;if[null first y;:()];-11!y;};

// TODO could refactor this?
upd:{ 
    if[not x=`order; :(`nop)];
    d:y;
    if[.orderbook.replay;
        d:$[1=count y;enlist;flip] cols[x]!y;
        if[.orderbook.lastBook>max d`time; :(`nop)]
        ];
    .orderbook.upd[x;d];
    if[not .orderbook.replay; .orderbook.toSnapshot[]];
    }
// When on, an aggressor order will sweep the book until it's fully filled or the book is empty
// When off, an aggressor order will only match against the top of the book
.orderbook.allowSweep:1b;
// Last time there was an execution
.orderbook.lastMatch:0Np;
// Last time .z.ts ran
.orderbook.lastTs:0Np;


// Should there be logic to snapshot trades that have been reported already?
// Maybe can change tradeid to be an hash of the trade itself to use as a key
// and keep state for it
.orderbook.start:{
    .log.logInfo "kdb+tick ORDERBOOK date:",string[.z.P]," version:",string[.z.K],"_",string .z.k;
    .orderbook.fromSnapshot[];
    .orderbook.replay:1b;
    .log.logDebug "Replaying from tpLogs";
    r:(.u.conn`tick)"(.u.sub[`order;`];`.u `i`L)";
    .u.rep . r;
    .orderbook.replay:0b;
    .log.logDebug "Replaying Done";
    }

.z.exit:{.log.logInfo"Running OrderBook zExit";.z.ts[];}
// should add a snapshot and replay from snapshot onward

.z.ts:{
    .log.logInfo"Running OrderBook ts";
    .u.ts[];
    .orderbook.lastTs:.z.p;
    // nit - find a better way to do this
    offers: 0!select by sym,exch from order_ask where price=(min;price)fby([]sym;exch);
    bids: 0!select by sym,exch from order_bid where price=(max;price)fby([]sym;exch);
    // This simulations assumes that a crossed book will uncross the next tick by way of trading the top of the book
    tomatch: offers,bids;
    if[0=count tomatch;:(`nop)];
    .orderbook.lastMatch:max .orderbook.match each tomatch;
    // Build after matches, otherwise it'll look like crossed books always
    .u.conn[`tick](`.u.upd; `orderbookl2; .orderbook.buildl2[]); // send this to subs?
    toReport:select from executions where time>=.orderbook.lastTs;
    if[count toReport; .orderbook.reportTrade delete roid,aoid from toReport];
    if[00:02:00 < .z.p-.orderbook.lastMatch; .log.logWarning "Nothing matched in over 2 minutes, is everything okay?"];
    }

.orderbook.start[]