/q cep/cep.q SRC :5010
system"l tick/r.q"
system"l common/sim.q"
system"l common/log.q"
system"l cep/lib.q"

uend:{
    if[null x;'daycantbenull];
    // t:tables`.;
    t:`trade`order;
    t@:where `g=attr each t@\:`sym;
    .Q.hdpf[.u.x `hdb;HDBROOT;x;`sym];
    @[;`sym;`g#] each t;
    };

/ connect to ticker plant for (schema;(logcount;log))
// All syms, all tables
// .u.x 0 -> ticker
.cep.replay:1b;
.u.rep .(.u.conn`tick)"(.u.sub[`;`];`.u `i`L)";
.cep.replay:0b;


k).Q.hdpf:{[h;d;p;f](@[`.;;0#]dpft[d;p;f]@)'t@>(#.:)'t:`trade`order;if[h:@[hopen;h;0];h"\\l .";>h]}
.u.end:{
    if[null x;'daycantbenull];
    .cep.end x;
    uend x;
    }

SIM_TRADE:10; 
"kdb+tick CEP SIM date:",string[.z.P]," version:",string[.z.K],"_",string .z.k
.z.ts:{
    .log.logInfo"Running CEP ts";
    .u.ts[];
    .sim.ts mod[;SIM_TRADE]`int$`second$x;
    .cep.ts[];
  }

