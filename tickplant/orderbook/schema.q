// side bid - aggressing, means selling
.orderbook.order_bid:update `g#sym from ([]time:`timestamp$(); exch:`symbol$(); sym:`symbol$(); price:`float$(); size:`float$();side:`symbol$(); orderid:`guid$(); rcvtime:`timestamp$(); oid:`guid$());
// side offer - aggressing means buying
.orderbook.order_ask: .orderbook.order_bid

.orderbook.l2cols: `sym`exch`ind`btime`btot_orders`bsz`bpx`apx`asz`atot_orders`atime; 

executions:([]time:`timestamp$();exch:`symbol$();sym:`symbol$();price:`float$();size:`float$();side:`symbol$(); tradeid:`guid$(); roid:`guid$(); aoid:`guid$());
