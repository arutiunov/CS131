(* general helper functions*)
let rec contains a b =
	match b with
	[] -> false
	| h::t -> if h=a then true
			  else
			  	(contains a t)

type ('nonterminal, 'terminal) symbol =
  | N of 'nonterminal
  | T of 'terminal

(*
PROBLEM #1
*)
let rec subset a b =
	match a with
	[] -> true
	| h::t -> if contains h b then
					subset t b
				else
					false

(*
PROBLEM #2
*)
let rec equal_sets a b = 
	if subset a b && subset b a then true
else
	false

(*
PROBLEM #3
*)
let rec set_union a b =
	match a with
	[] -> b
	| h::t -> if contains h b then
				(set_union t b)
			else h::(set_union t b)

(*
PROBLEM #4
*)
let rec set_intersection a b =
	match a with
	[] -> []
	| h::t -> if contains h b then
				h::(set_intersection t b)
			else
				(set_intersection t b)

(*
PROBLEM #5
*)

let rec set_diff a b = match a with
	[] -> []
	| h::t -> if contains h b then set_diff t b
			else
				h::set_diff t b

(*
PROBLEM #6
*)
let rec computed_fixed_point eq f x =
	if eq(f x) x then x
else
	computed_fixed_point eq f (f x)

(*
PROBLEM #7
*)
let rec computed_periodic_point eq f p x =
	if p = 0 then x
	else if (eq (f(computed_periodic_point eq f (p-1) (f x))) x) then x
	else computed_periodic_point eq f p (f x)

(*
PROBLEM #8
*)
let rec while_away s p x = 
	if (p x = false) then []
	else 
		x::while_away s p (s x)

(*
PROBLEM #9
*)

let rec rle_decode_helper lp =
	match lp with
		| (0, b) -> []
		| (a, b) -> b::rle_decode_helper(a-1, b)

let rec rle_decode lp =
	match lp with
	[] -> []
	| h::t -> 
		match h with
			| (0, b) -> rle_decode t
			| (a, b) -> (rle_decode_helper(a, b)) @ rle_decode t