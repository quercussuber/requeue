trade:([]time:`timestamp$();exch:`symbol$();sym:`symbol$();price:`float$();size:`float$();side:`symbol$(); tradeid:`guid$());

quote:([]time:`timestamp$();exch:`symbol$();sym:`symbol$();bprice:`float$();bsize:`float$();asize:`float$();aprice:`float$());

order:([]time:`timestamp$();exch:`symbol$();sym:`symbol$();price:`float$();size:`float$();side:`symbol$();orderid:`guid$());

syms:10#`$'read0`:common/sp500.txt;

exchs:1#`NYSE; // `NASDAQ`AMEX;

sides:`u?`B`S;

//generate random data
genTrades:{[n;start] (asc start+0D00:00:01*til n;n?exchs;n?syms;n?10.;n?10.;n?sides;neg[n]?0Ng)};

// //quote
genQuotes:{[n;start] (asc start+0D00:00:01*til n;n?exchs;n?syms;n?10.;n?10.;n?10.;n?10.)};


// order
// fixed floor price to avoid market crosses for now
genOrders:{[n;start] sds:n?sides; (asc start+0D00:00:01*til n;n?exchs;n?syms;(0 9)[sds]+n?10.;n?10.;sds;neg[n]?0Ng)};