// q feedhandler/feedhandler.q :5010 -c 13 317 -t 100
// This process simulates a number of orders coming in from the market
// and sends them to the TICKER process
system"l tick/r.q"
system"l common/conn.q"
system"l feedhandler/lib.q"

.u.end:{'implementme}

.u.conn:{hopen `$":",x}each enlist[`tick]#.u.x;

upd:{'implementme}

SIM_ORDERS:100

.fh.i:0;

.fh.genOrders:{[n;start]
    sims:n?0!sym_px;
    sds:n?sides;
    // Generating integers then dividing to get floats of set precision
    // also forcing BUY prices to be generally smaller than SELL prices (can still be crossed)
    px:abs sims[`px]+(-1 1)[sds]*floor[sims`px]%100;
    sz:0.01|(n?100)%sims`px;
    batch:(n#start;n?exchs;sims`sym;px;sz;sds;neg[n]?0Ng);
    batch
    }

.fh.ts:{
    n:SIM_ORDERS;
    batch:.fh.genOrders[n;.z.p];
    .fh.i+:SIM_ORDERS;
    // TODO trap errors like ticker being down
    .u.conn[`tick](`.u.upd;`order;batch);
    // Simulating market movements
    `sym_px set select px:med price,sz:med size by sym from flip cols[order]!batch;
    };

.z.exit:{`:sym_px set sym_px;}

.z.ts:{
    .log.logInfo"Running Fedhandler ts";
    .u.ts[];
    .fh.ts[];
    }