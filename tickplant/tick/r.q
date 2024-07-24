/q tick/r.q [host]:port[:usr:pwd] [host]:port[:usr:pwd]
/2008.09.09 .k ->.q
system"l common/schema.q"

if[not "w"=first string .z.o;system "sleep 1"];

upd:insert;


/ get the ticker plant and history ports, defaults are 5010,5012
.u.x:`tick`hdb!.z.x,(count .z.x)_(":5010";":5012");
.u.conn:{hopen `$":",x}each .u.x;

/ end of day: save, clear, hdb reload
.u.end:{t:tables`.;t@:where `g=attr each t@\:`sym;.Q.hdpf[.u.x `hdb;`:.;x;`sym];@[;`sym;`g#] each t;};

/ init schema and sync up from log file;cd to hdb(so client save can run)
// TODO TP SHOULD pass logfile path
.u.rep:{(.[;();:;].)each x;if[null first y;:()];-11!y;}; //system "cd ",1_first "/" vs string last y;};
/ HARDCODE \cd if other than logdir/db

/ connect to ticker plant for (schema;(logcount;log))
// All syms, all tables
// .u.x 0 -> ticker
.u.rep .(.u.conn`tick)"(.u.sub[`;`];`.u `i`L)";

.z.pc:{show "Process at handle ",string[p:.u.conn ? x]," disconnected"; .u.pc p}

.u.pc:{.u.conn[x]:0Ni; show .u.conn}

.u.ts:{
    if[ null .u.conn`tick;
        show "Retrying tickerplant connection ...";
        h:@[hopen;`$":",.u.x`tick;{show "Cannot establish tickerplant connection with ",x; 0Ni}];
        .u.conn[`tick]: h;
        if[ not null .u.conn`tick; .u.rep .(.u.conn`tick)"(.u.sub[`;`];`.u `i`L)"];
    ];
  }
  