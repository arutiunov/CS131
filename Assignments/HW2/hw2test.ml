(*defining nonterminals*)
type test_1_nonterminals = 
    | Sentence | PrepositionalPhrase |  Preposition | Noun | Verb | Determiner | NounPhrase | VerbPhrase
 
(*defining acceptor functions*)
let accept_all derivation string = Some (derivation, string)

(*acceptor that looks for verbs in the fragment*)
let rec contains_verbs = function
   | [] -> false
   | (Verb,_)::_ -> true
   | _::restOfRules -> contains_verbs restOfRules
let accept_verbs rules fragment = 
	if (contains_verbs rules) then Some(rules, fragment)
	else None

(*defining the grammar for test_1 and test_2*)
let test_grammar =
    (Sentence, function
        | Sentence -> [[N NounPhrase]; [N VerbPhrase]]
        | PrepositionalPhrase -> [[N Preposition; N NounPhrase]]
        | Preposition -> [[T"below"]; [T"along"]; [T"after"]; [T"in"]]
        | Noun -> [[T"wombat"]; [T"dog"]; [T"cat"]; [T "armadillo"]; [T"kangaroo"]; [T"mouse"]; [T"tree"]]
        | Verb -> [[T"run"]; [T"sleep"]; [T"eat"]; [T"dance"]]
        | Determiner -> [[T"the"]; [T"this"]; [T"which"]; [T"a"]; [T"any"]]
        | NounPhrase -> [[N Noun]; [N Determiner; N Noun]]
        | VerbPhrase -> [[N Verb; N NounPhrase; N PrepositionalPhrase]; [N Verb; N PrepositionalPhrase]; [N Verb]]
    )

(*test_1*)
let test_1 = parse_prefix test_grammar accept_all ["kangaroo"; "eat"; "dog";
             "below"; "the"; "cat"; "after"; "armadillo"; "along"; "wombat"; "sleep"; "in"; "tree"] = Some
 ([(Sentence, [N NounPhrase]); (NounPhrase, [N Noun]);
   (Noun, [T "kangaroo"])],
  ["eat"; "dog"; "below"; "the"; "cat"; "after"; "armadillo"; "along";
   "wombat"; "sleep"; "in"; "tree"])
              
(*test_2*)
let test_2 = parse_prefix test_grammar accept_verbs ["run"; "sleep"; "eat"; "dance"] =
    Some ([(Sentence, [N VerbPhrase]); (VerbPhrase, [N Verb]); (Verb, [T "run"])],
           ["sleep"; "eat"; "dance"])