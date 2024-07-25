calcOHLCVV_1m:{
    update `g#sym from 
    0!select
    open: first price,
    high: max price,
    low: min price,
    close: last price,
    volume: sum size,
    vwap: size wavg price
    by sym, 1 xbar time.minute
    from trade
    }

calcOHLCVV_1d:{
    update `g#sym from 
    0!select
    open: first price,
    high: max price,
    low: min price,
    close: last price,
    volume: sum size,
    vwap: size wavg price
    by sym
    from trade
    }

// For sampling purposes only - not a realistic calculation
calcMID_1m:{select mid_price:avg price by exch, sym, minute: 1 xbar time.minute from order}

last_ts:.z.P;

.cep.ts:{
    if[.z.P-last_ts>=00:01:00.000; ohlcvv_1m:: calcOHLCVV_1m[]];
    mid_1m::calcMID_1m[];
    }

.cep.end:{.cep.ts[]; ohlcvv_1d::calcOHLCVV_1d[];}

upd:{
    .[insert;(x;y);{.log.logError"Insert failed for table=",string[y]," with error=",x}[;x]];
    if[`trade=x; lastTrade,:y];
    if[`order=x; lastOrder,:y]
    };
