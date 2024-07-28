system"l tick/r.q"
system"l orderbook/schema.q"
.u.end:{'implementme}

upd:{
    if[not x=`order; `nop];
    // stamp
    y:update oid:neg[count y]?0Ng,rcvtime:.z.p from y;
    `order_ask insert delete side from (y where y[`side]=`S);
    `order_bid insert delete side from (y where y[`side]=`B);
    }

.u.conn[`tick]"(.u.sub[`order;`];`.u `i`L)";

.orderbook.buildl2:{r:0!(`sym`exch`bpx xdesc `bypx_norm "b") uj (`sym`exch`apx xasc bypx_norm "a");.orderbook.l2cols xcols r}
bypx:{`sym`exch xkey select max time,sum size, tot_orders:count i by sym,exch,price from x}
bypx_norm:{(`sym`exch,`$'x,/:("px";"time";"sz";"tot_orders")) xcol bypx $["a"~x;`order_ask;order_bid]}



// find matchs for order x passed as arg
// match `sym`exch`time`price`size`side`orderid!(`A.N;`NYSE;.z.P;10;1;`S;"G"$"5ae7962d-49f2-404d-5aec-f7c8abbae288")
.orderbook.match:{[x]
    // find all orders that can fill x
    as:last 1?`S`B;
    x[`side]:as;
    // this can be refactored
    rside:$[as=`S;`order_bid;`order_ask];
    aside:$[as=`S;`order_ask;`order_bid];
    // TODO nit make this functional
    
    o:`price xdesc $[`S=as; select from rside where sym=x`sym, exch=x`exch, price>=x`price; select from rside where sym=x`sym, exch=x`exch, price<=x`price];
    if[0=count o; :(0b)];
    // HANDLE INCOMING ORDER ID
    ro:first o;
    qty:ro[`size] - x`size;
    x[`price]:ro`price;
    // borrowing some GOLANG verbosity....
    // NIT - not a fan of using cascade ifs, and rather use $ then else, but this is more readable since there is no inherent return value and only used for side effects
    // if both aggressor and resting are filled, remove and send Execution report
    if[qty=0;
        delete from rside where orderid=ro`orderid;
        delete from aside where orderid=x`orderid;
        // .orderbook.reportExecution each (x;ro);
        .orderbook.reportTrade x;
        :(1b)
        ];
    
    if[qty<0;
        // If resting fully filled, and aggressor partially filled, send Execution report to both, remove the resting order and update the aggressor
        delete from rside where orderid=ro`orderid;
        x[`size]:neg qty;
        ro[`side]:as;
        // should this be an upsert?
        update size:x`size from aside where orderid=x`orderid;
        // .orderbook.reportExecution each (x;ro);
        .orderbook.reportTrade ro;
        :(1b)
        ];
    
    if[qty>0;
        // If aggressor fully filled, and resting order partially filled, send Execution report to both, remove the aggressor and update the resting order
        delete from aside where orderid=x`orderid;
        ro[`size]-:x[`size];
        // .orderbook.reportExecution each (x;ro);
        .orderbook.reportTrade x;
        :(1b)
        ];
    }

// whatever approach used here, will an amendat do best if used properly?
.orderbook.reportTrade:{
    // send execution report
    .log.logInfo"Sending Trade Report for trade=",.Q.s1 x;
    x[`time]:.z.p;
    x[`tradeid]:last -1?0Ng;
    .u.conn[`tick](`.u.upd;`trade;`time`sym`exch`price`size`side`tradeid#x);
    }

// Tells the trader that there is an execution
.orderbook.reportExecution:{'implement_me}

.z.ts:{
    .log.logInfo"Running OrderBook ts";
    .u.ts[];
    // .orderbook.buildl2[]; // send this to subs?
    // nit - find a better way to do this
    offers: 0!select by sym,exch from order_ask where price=(min;price)fby([]sym;exch);
    bids: 0!select by sym,exch from order_bid where price=(max;price)fby([]sym;exch);
    // TODO consider different approach where the two top of books are matched against
    // each other instead of doing ToB for each side vs rest
    // It should save on one query to order_asks and order_bids
    .orderbook.match each offers,bids;
    }

.log.setLogLevel`info;