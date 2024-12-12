// Stateful resumes from last known state
.orderbook.INSTANCE_PATH:`$":data/orderbook_",.orderbook.INSTANCE,"/"
// NIT - this should be refactored to minimize race conditions between the book timestamp and when it snapshots
// possibly do not snapshot a separate variable
.orderbook.writeSnapshot:{(` sv .orderbook.INSTANCE_PATH,x)set get x;`.orderbook.lastBook set max order_ask[`time],order_bid`time}
.orderbook.readSnapshot:{x set @[get;.orderbook.INSTANCE_PATH,x;{.orderbook[x]}[x]]}

.orderbook.toSnapshot:{system"x .z.zd";.orderbook.writeSnapshot each `order_ask`order_bid}
.orderbook.fromSnapshot:{.orderbook.readSnapshot each -2?`order_ask`order_bid; `.orderbook.lastBook set max order_ask[`time],order_bid`time}


.orderbook.upd:{[t;d]
    if[not t=`order; :(`nop)];
    // NIT - could skip messages if for some reason in the same batch there is message with the time before the last book
    // but never received from the book. TBC if this would happen in practice
    d:update oid:neg[count d]?0Ng,rcvtime:.z.p from d;
    `order_ask insert (d where d[`side]=`S); 
    `order_bid insert (d where d[`side]=`B);
    if[00:02:00 < .z.p-.orderbook.lastMatch; .log.logWarning "Nothing matched in over 2 minutes, but data incoming. Is timer on?"];
    }

// match `sym`exch`time`price`size`side`orderid!(`A.N;`NYSE;.z.P;10;1;`S;"G"$"5ae7962d-49f2-404d-5aec-f7c8abbae288")
// match tries to match an incoming order against the order book
// it will return a trade if the order is fully or partially filled
// it will return a null if there are no fills
// it can either allow for sweeping or not
.orderbook.match:{[x]
    // find all orders that can fill x
    as:x[`side];
    // this can be refactored
    rside:$[as=`S;`order_bid;`order_ask];
    aside:$[as=`S;`order_ask;`order_bid];   
    o:`price xdesc $[`S=as; 
        select from rside where sym=x`sym, exch=x`exch, price>=x`price;
        select from rside where sym=x`sym, exch=x`exch, price<=x`price];
    
    if[0=count o; :(0Np)];

    // if[1<count distinct o`price; break]; 
    ro:first o;
    qty:ro[`size] - x`size;
    x[`price]:ro`price;
    // If there are orders to match, create a trade
    trade:`time`sym`exch`price`size`side`tradeid`roid`aoid!(.z.p;x`sym;x`exch;x`price;qty;as;last -1?0Ng;ro`orderid;x`orderid);
    // NIT - not a fan of using cascade ifs, and rather use $ then else, but this is more readable since there is no inherent return value and only used for side effects
    if[qty=0;
        // if both aggressor and resting are filled, remove and send Execution report
        delete from rside where orderid=ro`orderid;
        delete from aside where orderid=x`orderid;
        ];
    
    if[qty<0;
        // If resting fully filled, and aggressor partially filled, send Execution report to both, remove the resting order and update the aggressor
        delete from rside where orderid=ro`orderid;
        trade[`size]:ro`size;
        update size:neg qty from aside where orderid=x`orderid;
        .log.logDebug"Partial fill, sweeping";
        if[.orderbook.allowSweep; .z.s x];
        ];
    
    if[qty>0;
        // If aggressor fully filled, and resting order partially filled, send Execution report to both, remove the aggressor and update the resting order
        delete from aside where orderid=x`orderid;
        trade[`size]:x`size;
        update size:qty from rside where orderid=ro`orderid;
        ];
    `executions insert trade;
    .z.p
    }


// `time`sym`exch`price`size`side`tradeid`roid`aoid!(.z.p;x`sym;x`exch;x`price;x`size;x`side;last -1?0Ng;x`orderid;last -1?0Ng)
// whatever approach used here, will an amendat do best if used properly?
.orderbook.reportTrade:{
    .log.logInfo"Sending Trade Report for trade=",.Q.s1 x;
    .u.conn[`tick](`.u.upd;`trade;x);
    }


bypx:{select max time,sum size, tot_orders:count i by sym,exch,price from x}
bypx_norm:{
    f:idesc; s:"b"; if[x~`order_ask;f:iasc;s:"a"];
    r:![bypx x;();{x!x}`sym`exch;enlist[`ind]!enlist(f;`price)];
    r:(`sym`exch`ind,`$'s,/:("px";"time";"sz";"tot_orders")) xcol `sym`exch`ind xkey  r
    }


.orderbook.buildl2:{
    r:`sym`exch`bpx xdesc bypx_norm[`order_bid] uj bypx_norm`order_ask;
    `time`exch`sym xcols update time:.z.p from .orderbook.l2cols xcols 0!r
    }
