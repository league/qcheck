structure StringMap = 
  SplayMapFn(type ord_key = string val compare = String.compare)
structure StringBag = 
  BagFromMap(type key = string open StringMap)
