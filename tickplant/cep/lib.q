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

last_ts:.z.P;

.cep.ts:{
    if[.z.P-last_ts>=00:01:00.000; ohlcvv_1m:: calcOHLCVV_1m[]];
    }

.cep.end:{ohlcvv_1m::calcOHLCVV_1m[]; ohlcvv_1d::calcOHLCVV_1d[];}