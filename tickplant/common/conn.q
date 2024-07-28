/ get the ticker plant and history ports, defaults are 5010,5012
.u.x:`tick`hdb!.z.x,(count .z.x)_(":5010";":5012");

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