/q cep/cep.q SRC :5010

system"l tick/r.q"
system"l common/sim.q"
system"l cep/lib.q"

"kdb+tick CEP SIM date:",string[.z.P]," version:",string[.z.K],"_",string .z.k
.z.ts:{
    .u.ts[];
    .sim.ts mod[;10]`int$`second$x;
  }