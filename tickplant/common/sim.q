// load the simulation context
// not switching namespace to avoid finangling with tables
if[not `conn in key`.u; 'udotqmissing]
// random X trades, doenst flip side or anything, just a way to 
// generate some trades that can be joined with order
.sim.aggressOrder:{.u.conn[`tick](`.u.ins;`trade;neg[x]?order)}

.sim.ts:{[n].sim.aggressOrder n};