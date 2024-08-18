trade:([]time:`timestamp$();exch:`symbol$();sym:`symbol$();price:`float$();size:`float$();side:`symbol$(); tradeid:`guid$());

quote:([]time:`timestamp$();exch:`symbol$();sym:`symbol$();bprice:`float$();bsize:`float$();asize:`float$();aprice:`float$());

order:([]time:`timestamp$();exch:`symbol$();sym:`symbol$();price:`float$();size:`float$();side:`symbol$();orderid:`guid$());

orderbookl2:([]time:`timestamp$(); exch:`symbol$(); sym:`symbol$(); ind:`int$(); btime:`timestamp$();btot_orders:`int$();bsz:`float$();bpx:`float$();apx:`float$();asz:`float$();atot_orders:`int$();atime:`timestamp$());