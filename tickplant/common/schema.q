trade:([]time:`timestamp$();exch:`symbol$();sym:`symbol$();price:`float$();size:`float$();side:`symbol$(); tradeid:`guid$());

quote:([]time:`timestamp$();exch:`symbol$();sym:`symbol$();bprice:`float$();bsize:`float$();asize:`float$();aprice:`float$());

order:([]time:`timestamp$();exch:`symbol$();sym:`symbol$();price:`float$();size:`float$();side:`symbol$();orderid:`guid$());

syms:10#`$'read0`:common/sp500.txt;

sym_px:`sym`px!(syms;count[syms]?100.);

exchs:1#`NYSE; // `NASDAQ`AMEX;

sides:`u?`B`S;

//generate random data
genTrades:{[n;start] (asc start+0D00:00:01*til n;n?exchs;n?syms;n?10.;n?10.;n?sides;neg[n]?0Ng)};

// //quote
genQuotes:{[n;start] (asc start+0D00:00:01*til n;n?exchs;n?syms;n?10.;n?10.;n?10.;n?10.)};


// order
// fixed floor price to avoid market crosses for now
genOrders:{[n;start]
    sims:n?flip sym_px;
    sds:n?sides;
    (asc start+0D00:00:01*til n;n?exchs;sims`sym;sims[`px]+(-1 1)[sds]*(n?1+1000)%100;n?10.;sds;neg[n]?0Ng)};