type point =
	Cartesian of (float * float)
	| Polar of (float * float);;

(*
Takes a type point, and returns the negative
e.g. (x,y) --> (r, theat+pi_)
*)

negate value of point (x,y)->(-x,-y)
let negate p =
	match p with
		Cartesian(x,y) -> Cartesian(-.x, -.y)
		| Polar(r, theta) -> Polar(r, theta + .180.0);;

(*
* take a point p and covert it to a polar point
* (x,y) -> (r,theta)
* (r, theta) -> (r,theta)
*)

let toPolar p =
	match p with
	Polar(_,_)->p
	| Cartesian(x,y) -> Polar( sqrt( x *. x + y*)) (* not finished! *)
;;

(* recursive types *)

type intList = Nil | Cons of int * intlist;;

let rec length l =
	match l with
		Nil -> 0
		| Cons(head,tail) -> 1 + (length tail)

(* recursive types - examples*)
(* data only at internal nodes *)
type binaryTree = Nil | Node of int * binaryTree * binaryTree;;

(* return a listof the traversal *)

let rec preoder tree =
	match tree with
		Nil -> []
		| Node(value, right) -> 
			value :: ((preoder left) @ (preoder right));;

let rec inorder tree =
	match tree with
		Nil -> []
		| Node(value, right) -> 
			(inorder left) @ [value] @ (inorder right);;

List.map (fun x -> x+1) [1;2;3;4];;

(*how do I define add_user_defined*)

let add_user_defined e = 
	e + 1;;

(*Practice questions*)

(*
list l = [x0, x1, x2...]
return indexed list - [(0,x0);(1,x1);(2,x2);...]
*)

let indexed_list l =
	List.mapi (fun idx x -> (idx, x)) l;;

(* idx comes from mapi, implementation of it below*)

let rec mapi f l =
	let rec mapi_helper = (*helper function defined inside*)
		match l with
		[] -> []
		| h::t -> (f idx h) :: (mapi_helper f t (idx+1))
	in
	mapi_helper f l 0 (*this is what calls the helper function above (remember, only last line gets executed in Ocamllet extract_left_hand_side_helper symbol (x,_) = x;;
*)

