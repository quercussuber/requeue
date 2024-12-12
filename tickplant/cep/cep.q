/q cep/cep.q SRC :5010

system"l tick/r.q"
system"l common/conn.q"
system"l cep/lib.q"

.u.conn:{hopen `$":",x}each enlist[`tick]#.u.x;

// uend:{
//     if[null x;'daycantbenull];
//     // t:tables`.;
//     t:`trade`order;
//     t@:where `g=attr each t@\:`sym;
//     .Q.hdpf[.u.x `hdb;HDBROOT;x;`sym];
//     @[;`sym;`g#] each t;
//     };

// k).Q.hdpf:{[h;d;p;f](@[`.;;0#]dpft[d;p;f]@)'t@>(#.:)'t:`trade`order;if[h:@[hopen;h;0];h"\\l .";>h]}
// .u.end:{
//     if[null x;'daycantbenull];
//     .cep.end x;
//     uend x;
//     }

.cep.start:{
    .log.logInfo "kdb+tick CEP date:",string[.z.P]," version:",string[.z.K],"_",string .z.k;
    .cep.replay::1b;
    .u.rep .(.u.conn`tick)"(.u.sub[`;`];`.u `i`L)";
    .cep.replay::0b;
    }

.cep.lastTs:.z.P;

.cep.ts:{
    // if[.z.P-.cep.lastTs>=00:01:00.000; ohlcvv_1m:: calcOHLCVV_1m[]];
    // mid_1m::calcMID_1m[];
    }

.z.ts:{
    .log.logInfo"Running CEP ts";
    .u.ts[];
    .cep.ts[];
  }

.cep.start[]