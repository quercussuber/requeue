system"l tick/r.q"

.u.end:{'implementme}

// side bid - aggressing, means selling
order_bid:update `g#sym from ([]time:`timestamp$(); exch:`symbol$(); sym:`symbol$(); price:`float$(); size:`float$(); orderid:`guid$(); rcvtime:`timestamp$(); oid:`guid$());
// side offer - aggressing means buying
order_ask: order_bid


upd:{
    if[not x=`order; `nop];
    // stamp
    y:update oid:neg[count y]?0Ng,rcvtime:.z.p from y;
    `order_ask insert delete side from (y where y[`side]=`S);
    `order_bid insert delete side from (y where y[`side]=`B);
    }

.u.conn[`tick]"(.u.sub[`order;`];`.u `i`L)";

// TODO nit be functional
.orderbook.buildl2:{`sym`exch`btime`bsize`bprice`aprice`asize`atime xcols `sym`exch xasc 0!(`sym`exch xkey `bprice xdesc select  btime:max time, bsize:sum size, btot_orders:count i by sym, exch, bprice:price from order_bid) uj (`sym`exch xkey `aprice xasc select atot_orders:count i, asize:sum size, atime:max time by sym, exch, aprice:price from order_ask)}


// find matchs for order x passed as arg
// match `sym`exch`time`price`size`side`orderid!(`A.N;`NYSE;.z.P;10;1;`S;"G"$"5ae7962d-49f2-404d-5aec-f7c8abbae288")
.orderbook.match:{[x]
    // find all orders that can fill x
    as:`S;
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

// whatever approach used here, an amend at, will do best if used properly!
.orderbook.reportTrade:{
    // send execution report
    .log.logInfo"Sending Execution Report for orderid=",.Q.s1 x;
    x[`time]:.z.p;
    x[`tradeid]:last -1?0Ng;
    .u.conn[`tick](`.u.upd;`trade;`time`sym`exch`price`size`side`tradeid#x);
    }

.z.ts:{
    .log.logInfo"Running OrderBook ts";
    .u.ts[];
    .orderbook.buildl2[]; // send this to subs?
    .orderbook.match each 0!select by sym,exch from order_ask where  price=(min;price)fby([]sym;exch);
    }

.log.setLogLevel`info;