local
   (* from redblack-map-fn.sml in SML/NJ library *)
   structure Map =  
   struct
      type key = string
      datatype color = R | B
      and 'a tree
        = E
        | T of (color * 'a tree * key * 'a * 'a tree)
      datatype 'a map = MAP of (int * 'a tree)
    val empty = MAP(0, E)
    fun insert (MAP(nItems, m), xk, x) = let
	  val nItems' = ref nItems
	  fun ins E = (nItems' := nItems+1; T(R, E, xk, x, E))
            | ins (s as T(color, a, yk, y, b)) = (case String.compare(xk, yk)
		 of LESS => (case a
		       of T(R, c, zk, z, d) => (case String.compare(xk, zk)
			     of LESS => (case ins c
				   of T(R, e, wk, w, f) =>
					T(R, T(B,e,wk, w,f), zk, z, T(B,d,yk,y,b))
                		    | c => T(B, T(R,c,zk,z,d), yk, y, b)
				  (* end case *))
			      | EQUAL => T(color, T(R, c, xk, x, d), yk, y, b)
			      | GREATER => (case ins d
				   of T(R, e, wk, w, f) =>
					T(R, T(B,c,zk,z,e), wk, w, T(B,f,yk,y,b))
                		    | d => T(B, T(R,c,zk,z,d), yk, y, b)
				  (* end case *))
			    (* end case *))
			| _ => T(B, ins a, yk, y, b)
		      (* end case *))
		  | EQUAL => T(color, a, xk, x, b)
		  | GREATER => (case b
		       of T(R, c, zk, z, d) => (case String.compare(xk, zk)
			     of LESS => (case ins c
				   of T(R, e, wk, w, f) =>
					T(R, T(B,a,yk,y,e), wk, w, T(B,f,zk,z,d))
				    | c => T(B, a, yk, y, T(R,c,zk,z,d))
				  (* end case *))
			      | EQUAL => T(color, a, yk, y, T(R, c, xk, x, d))
			      | GREATER => (case ins d
				   of T(R, e, wk, w, f) =>
					T(R, T(B,a,yk,y,c), zk, z, T(B,e,wk,w,f))
				    | d => T(B, a, yk, y, T(R,c,zk,z,d))
				  (* end case *))
			    (* end case *))
			| _ => T(B, a, yk, y, ins b)
		      (* end case *))
		(* end case *))
	  val m = ins m
	  in
	    MAP(!nItems', m)
	  end
    fun find (MAP(_, t), k) = let
	  fun find' E = NONE
	    | find' (T(_, a, yk, y, b)) = (case String.compare(k, yk)
		 of LESS => find' a
		  | EQUAL => SOME y
		  | GREATER => find' b
		(* end case *))
	  in
	    find' t
	  end
    fun foldli f = let
	  fun foldf (E, accum) = accum
	    | foldf (T(_, a, xk, x, b), accum) =
		foldf(b, f(xk, x, foldf(a, accum)))
	  in
	    fn init => fn (MAP(_, m)) => foldf(m, init)
	  end
   end
in
   structure StringBag = BagFromMap(Map)
end
