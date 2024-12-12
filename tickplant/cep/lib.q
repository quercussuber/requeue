calcOHLCVV_1m:{
    select
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
    select
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
calcTickMID:{select mid_price:avg price by exch, sym, minute: 1 xbar time.minute from order}

calcVWAP:{[s;e;r]
    $[r=1; select sym, exch, second, vwap,res:r from vwap_1s where sym=s,exch=e;
           select vwap: sum[wsp]%sum ws, sum num_trade by sym,exch,r xbar second from vwap_1s where sym=s,exch=e]
    };

last_ts:.z.P;



// .cep.end:{.cep.ts[]; ohlcvv_1d::calcOHLCVV_1d[];}

upd:{
    .[insert;(x;y);{.log.logError"Insert failed for table=",string[y]," with error=",x}[;x]];
    if[`trade=x; 
        if[not .cep.replay; lastTrade,:y];
        // having this separate table is questionable - native wavg performs well compared to running sum x*y%sum y
        // but it feels like there is a scale point at which it will be faster to use the running sum when calculating
        // multiple vwap horizons instead of recalculating the wavg for each horizon
        // We shall see...
        // leaving vwap here to compare results with the native wavg
        // if[99h=type y; y:enlist y];
       // vwap_1s+: select wsp:size wsum price, ws:sum size, vwap:size wavg price, num_trade:count i by exch,sym,time.second from trade
         //   where ([]time.second;sym;exch) in select time.second,sym,exch from y
        ];
    if[`order=x;  if[not .cep.replay; lastOrder,:y]];
    };

// MACD
ema12:ema[2%13;]
ema26:ema[2%17;]
macd: {ema12[x] - ema26 x}
signal:{ema[2%10;macd x]}

calcMACD:{[s;e]
    select minute, exch, ema12 close, ema26 close, macd close, signal macd close by sym from calcOHLCVV_1m[]
    }