trade:([]time:`timestamp$();exch:`symbol$();sym:`symbol$();price:`float$();size:`float$();side:`symbol$(); tradeid:`guid$());

quote:([]time:`timestamp$();exch:`symbol$();sym:`symbol$();bprice:`float$();bsize:`float$();asize:`float$();aprice:`float$());

order:([]time:`timestamp$();exch:`symbol$();sym:`symbol$();price:`float$();size:`float$();side:`symbol$();orderid:`guid$());

syms:`$'read0`:common/sp500.txt;

exchs:`NYSE`NASDAQ`AMEX;

sides:`B`S;

//generate random data
genTrades:{[n;start] (asc start+0D00:00:01*til n;n?exchs;n?syms;n?10.;n?10.;n?sides;neg[n]?0Ng)};

// //quote
genQuotes:{[n;start] (asc start+0D00:00:01*til n;n?exchs;n?syms;n?10.;n?10.;n?10.;n?10.)};

// order
genOrders:{[n;start] (asc start+0D00:00:01*til n;n?exchs;n?syms;n?10.;n?10.;n?sides;neg[n]?0Ng)};

// 
fillOrders:{`trade insert x}




// tradeOrders:{
//   if[not `order in tables[]; :(::)];
//   `tradeable upsert order;
//   tradeable: update traded:0b from tradeable;
//   tofill:neg[x]?tradeable
//   update traded:1b from `tradeable where orderid in tofill`orderid;
// }