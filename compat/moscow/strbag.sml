structure StringBag = BagFromMap
  (struct 
     type key = string 
     type 'a map = (string, 'a) Splaymap.dict 
     val empty = Splaymap.mkDict String.compare 
     val insert = Splaymap.insert 
     val find = Splaymap.peek
     val foldli = Splaymap.foldl 
   end)
