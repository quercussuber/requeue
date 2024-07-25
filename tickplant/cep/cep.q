/q cep/cep.q SRC :5010
system"l tick/r.q"
system"l common/sim.q"
system"l common/log.q"
system"l cep/lib.q"

uend:.u.end;

.u.end:{
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