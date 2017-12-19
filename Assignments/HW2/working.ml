type ('nonterminal, 'terminal) symbol =
  | N of 'nonterminal
  | T of 'terminal

let rec ruleMatcher startSymbol rules firstRuleList acceptor derivation fragment = match firstRuleList with
        | [] -> None
        | firstRule::remainingRules -> 
            let validMatch = (fragMatcher rules firstRule acceptor (derivation@[startSymbol, firstRule]) fragment) in
                match validMatch with 
                    | None -> ruleMatcher startSymbol rules remainingRules acceptor derivation fragment
                    | x -> x

and fragMatcher rules currentRuleChecked acceptor derivation fragment = match currentRuleChecked with
        | [] -> acceptor derivation fragment
        | _ -> match fragment with
            | [] -> None
            | pref::suff -> match currentRuleChecked with
                | (N expression)::rhs -> let recurseFirstRuleList = (rules expression) in
                    ruleMatcher expression rules recurseFirstRuleList (fragMatcher rules rhs acceptor) derivation fragment
                | (T expression)::rhs -> if pref = expression then (fragMatcher rules rhs acceptor derivation suff) else None
                | [] -> None

let parse_prefix gram acceptor fragment = match gram with
        | (startSymbol, rules) -> 
            let derivation = [] in
                let firstRuleList = rules startSymbol in 
                    ruleMatcher startSymbol rules firstRuleList acceptor derivation fragment 







let rec ruleMatcher startSymbol rules firstRuleList acceptor derivation fragment = match firstRuleList with
        | [] -> None
        | (firstRule::remainingRules) -> match (fragMatcher rules firstRule acceptor (derivation@[startSymbol, firstRule]) fragment) with
            | None -> ruleMatcher startSymbol rules remainingRules acceptor derivation fragment
            | x -> x

and fragMatcher rules currentRuleChecked acceptor derivation fragment = match currentRuleChecked with
        | [] -> acceptor derivation fragment
        | _ -> match fragment with
            | [] -> None
            | pref::suff -> match currentRuleChecked with
                | [] -> None
                | (T term)::rhs -> if pref = term then (fragMatcher rules rhs acceptor derivation suff) else None
                | (N nterm)::rhs -> (ruleMatcher nterm rules (rules nterm) (fragMatcher rules rhs acceptor) derivation fragment)

let parse_prefix gram acceptor fragment = match gram with
        | (startSymbol, rules) -> 
            let derivation = [] in
                let firstRuleList = rules startSymbol in 
                    ruleMatcher startSymbol rules firstRuleList acceptor derivation fragment 