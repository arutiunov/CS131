(* general helper functions*)
let rec contains a b =
	match b with
	[] -> false
	| h::t -> if h=a then true
			  else
			  	(contains a t);;

type ('nonterminal, 'terminal) symbol =
  | N of 'nonterminal
  | T of 'terminal
;;

(*
PROBLEM #1 -- complete
*)
let rec subset a b =
	match a with
	[] -> true
	| h::t -> if contains h b then
					subset t b
				else
					false
;;

(*
PROBLEM #2 -- complete
*)
let rec equal_sets a b = 
	if subset a b && subset b a then true
else
	false;;

(*
PROBLEM #3 -- complete
*)
let rec set_union a b =
	match a with
	[] -> b
	| h::t -> if contains h b then
				(set_union t b)
			else h::(set_union t b);;

(*
PROBLEM #4 -- complete
*)
let rec set_intersection a b =
	match a with
	[] -> []
	| h::t -> if contains h b then
				h::(set_intersection t b)
			else
				(set_intersection t b);;

(*
PROBLEM #5 -- complete
*)

let rec set_diff a b = match a with
	[] -> []
	| h::t -> if contains h b then set_diff t b
			else
				h::set_diff t b;;

(*
PROBLEM #6 -- complete
*)
let rec computed_fixed_point eq f x =
	if eq(f x) x then x
else
	computed_fixed_point eq f (f x);;

(*
PROBLEM #7 -- complete
*)
let rec computed_periodic_point eq f p x =
	if p = 0 then x
	else if (eq (f(computed_periodic_point eq f (p-1) (f x))) x) then x
	else computed_periodic_point eq f p (f x);;

(*
PROBLEM #8 -- complete
*)
let rec while_away s p x = 
	if (p x = false) then []
	else 
		x::while_away s p (s x);;

(*
PROBLEM #9 -- COMPLETE
*)

let rec rle_decode_helper lp =
	match lp with
		| (0, b) -> []
		| (a, b) -> b::rle_decode_helper(a-1, b);;

let rec rle_decode lp =
	match lp with
	[] -> []
	| h::t -> 
		match h with
			| (0, b) -> rle_decode t
			| (a, b) -> (rle_decode_helper(a, b)) @ rle_decode t;;

(*
PROBLEM #10
*)

(* given list of rules on the rhs, is at least one of them nonterminal *)
let rec at_least_one_nonterminal rules =
	match rules with
	[] -> false
	| h::t ->
		if nonterminal_determiner_helper h then
			true
		else
			at_least_one_nonterminal t
;;

(* returns true if nonterminal rule, false if terminal *)
let nonterminal_determiner_helper rule =
	match rule with
	| T x -> false
	| N x -> true
;;

(* returns left-hand side of a tuple with 2 components (0 index)*)
let rec flatten_helper_function tuple = 
	match tuple with
	| [] -> []
	| h::t -> 
		(N(extract_left_hand_side_from_rule_helper h))::(flatten_helper_function t)
	;;

(* REVISED *)
let rec at_least_one_nonterminal rules =
	match rules with
	[] -> false
	| h::t ->
		match h with
		| N x -> true
		| T x -> at_least_one_nonterminal t
;;


(* remove list of all terminal functions *)
let rec remove_terminal_functions_helper rightHand = 
	match rightHand with 
	[] -> []
	| h::t -> 
		if not(nonterminal_determiner_helper h) then
			remove_terminal_functions_helper t
		else
			h::remove_terminal_functions_helper t
;;

let rec grammar_parser_helper grammar = 
	match grammar with
		[] -> grammar
		| (leftHand, rightHand)::t ->
			if not(at_least_one_nonterminal rightHand) then (leftHand,rightHand)::(grammar_parser_helper t)
			else grammar_parser_helper t
;;

let rec derived_terminal_rules_helper dRules tRules = 
	match dRules with
	[] -> tRules
	| (leftHand, rightHand)::t ->
		if subset (remove_terminal_functions_helper rightHand) (flatten_helper_function tRules)
		&& (not (contains (leftHand, rightHand) tRules)) then
		derived_terminal_rules_helper t ((leftHand, rightHand)::tRules)
	else derived_terminal_rules_helper t tRules
;;

let rec repeated_derived_terminal_rules_helper dRules tRules = 
	let derivedListOfTerminals = derived_terminal_rules_helper dRules tRules in
	if (List.length derivedListOfTerminals) = (List.length tRules) then
		derivedListOfTerminals
	else
		repeated_derived_terminal_rules_helper dRules derivedListOfTerminals
	;;

(* WORKS!!! *)
let rec reorder_rules_helper givenRules derivedTerminatingRules = 
	match givenRules with
	| [] -> []
	| h::t ->
		if contains h derivedTerminatingRules then
			h::(reorder_rules_helper t derivedTerminatingRules)
		else
			reorder_rules_helper t derivedTerminatingRules
;;

(* WORKS!!! *)
let filter_blind_alleys g = 
  let rightHandRules = extract_right_hand_side_from_rule_helper g in
  let derivedTerminals = grammar_parser_helper rightHandRules in
  extract_left_hand_side_from_rule_helper g, (reorder_rules_helper rightHandRules (repeated_derived_terminal_rules_helper 
    (set_diff rightHandRules derivedTerminals) derivedTerminals))
;;