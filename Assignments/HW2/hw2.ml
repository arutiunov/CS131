(* --- typing provided for grammar parsing ---*)
type ('nonterminal, 'terminal) symbol =
  | N of 'nonterminal
  | T of 'terminal

(*helper functions to grab left and right hand side of tuple*)
let extract_rhs_helper (_, rightHand) = rightHand

let extract_lhs_helper (leftHand, _) = leftHand

(* --- helper function for problem #1 ---*)
let rec rules_parser_helper startingNonterminal rules = 
    match rules with 
        [] -> []
        | (h, t)::rest -> 
            if not(h = startingNonterminal) then
                rules_parser_helper startingNonterminal rest
            else
                t::(rules_parser_helper startingNonterminal rest)

(* --- implementation of convert_grammar function ---*)
let convert_grammar gram1 = 
    extract_lhs_helper gram1, (function newForm -> rules_parser_helper newForm (extract_rhs_helper gram1))

(* --- implementation of helper functions to parse_prefix function ---*)
(*ruleMatcher function takes list of rules, splits into individual rules, calls fragMatcher to see if match*)
let rec ruleMatcher startSymbol rules firstRuleList acceptor derivation fragment = match firstRuleList with
        | [] -> None
        | firstRule::remainingRules -> 
            let validMatch = (fragMatcher rules firstRule acceptor (derivation@[startSymbol, firstRule]) fragment) in
                match validMatch with 
                    | None -> ruleMatcher startSymbol rules remainingRules acceptor derivation fragment
                    | x -> x

(*fragMatcher function takes a current rule within a list of rules, checks if matches grammar*)
and fragMatcher rules currentRuleChecked acceptor derivation fragment = match currentRuleChecked with
        | [] -> acceptor derivation fragment
        | _ -> match fragment with
            | [] -> None
            | pref::suff -> match currentRuleChecked with
                | (N expression)::rhs -> let recurseFirstRuleList = (rules expression) in
                    ruleMatcher expression rules recurseFirstRuleList (fragMatcher rules rhs acceptor) derivation fragment
                | (T expression)::rhs -> if pref = expression then (fragMatcher rules rhs acceptor derivation suff) else None
                | [] -> None

(* --- implementation of parse_prefix function ---*)
let parse_prefix gram acceptor fragment = match gram with
        | (startSymbol, rules) -> (*grammar matches desired format*)
            let derivation = [] in (*start with a blank derivation*)
                let firstRuleList = rules startSymbol in (*initial rule from first start symbol*)
                    ruleMatcher startSymbol rules firstRuleList acceptor derivation fragment