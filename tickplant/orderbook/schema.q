// side bid - aggressing, means selling
order_bid:update `g#sym from ([]time:`timestamp$(); exch:`symbol$(); sym:`symbol$(); price:`float$(); size:`float$(); orderid:`guid$(); rcvtime:`timestamp$(); oid:`guid$());
// side offer - aggressing means buying
order_ask: order_bid

.orderbook.l2cols: `sym`exch`btime`btot_orders`bsz`bpx`apx`asz`atot_orders`atime; 