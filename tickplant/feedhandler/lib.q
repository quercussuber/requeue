exchs:enlist`MYX;

sides:`u?`B`S;

syms:1#`$'read0`:common/sp500.txt;

// Carry price movements across restarts
sym_px:@[get;`:sym_px;{px:(count[syms]?1+100);([sym:syms]px:px;sz:px%10)}];
`:sym_px set sym_px;