/q tick/r.q [host]:port[:usr:pwd] [host]:port[:usr:pwd]
/2008.09.09 .k ->.q
system"l common/schema.q"
system"l common/log.q"

if[not "w"=first string .z.o;system "sleep 1"];

upd:insert;

/ end of day: save, clear, hdb reload
HDBROOT:`$":../db"
.u.end:{t:tables`.;t@:where `g=attr each t@\:`sym;.Q.hdpf[.u.x `hdb;HDBROOT;x;`sym];@[;`sym;`g#] each t;};

/ init schema and sync up from log file;cd to hdb(so client save can run)
// log file path comes from .u.L in the ticker
.u.rep:{(.[;();:;].)each x;if[null first y;:()];-11!y;};


// remember to call .u.rep in the client
// this is so clients can choose to override upd before 
// calling .u.rep