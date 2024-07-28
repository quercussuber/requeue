exchs:`NYSE`NASDAQ`AMEX;

sides:`u?`B`S;

syms:10#`$'read0`:common/sp500.txt;

// Carry price movements across restarts
sym_px:@[get;`:sym_px;{`sym`px!(syms;count[syms]?100.)}];
`:sym_px set sym_px;

// order
genOrders:{[n;start]
    sims:n?flip sym_px;
    sds:n?sides;
    // Generating integers up to 1000 and then dividing by 100 to get floats of set precision
    // also forcing BUY prices to be generally smaller than SELL prices (can still be crossed)
    (asc start+0D00:00:01*til n;n?exchs;sims`sym;sims[`px]+(-1 1)[sds]*(n?1+1000)%100;n?10.;sds;neg[n]?0Ng)};