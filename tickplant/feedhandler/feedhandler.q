// q feedhandler/feedhandler.q :5010 -c 13 317 -t 100
system"l tick/r.q"

.u.end:{'implementme}

upd:{
    if[not x=`order; `nop];
    // stamp
    y:update oid:neg[count y]?0Ng,rcvtime:.z.p from y;
    `order_ask insert delete side from (y where y[`side]=`S);
    `order_bid insert delete side from (y where y[`side]=`B);
    }

SIM_ORDERS:1000

.fh.i:0;

.fh.ts:{
    batch:genOrders[SIM_ORDERS;.z.p];
    .fh.i+:SIM_ORDERS;
    // TODO trap errors like ticker being down
    .u.conn[`tick](`.u.upd;`order;batch);
    sym_px[`px]+:@[;(last 1?count sym_px[`px])? count sym_px[`px];neg] %[;1000]count[sym_px`px]?100;
    };

.z.ts:{
    .log.logInfo"Running Fedhandler ts";
    .u.ts[];
    .fh.ts[];
    }