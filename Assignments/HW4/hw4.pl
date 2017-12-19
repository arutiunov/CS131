% standard translation rules from signals to dihs and dahs
    fact([1],.) .
    fact([1,1,1],-) .
    fact([1,1,1,1|Tail],Result) :- \+(member(0,Tail)), fact([1,1,1],Result) . % if more than 4 1's in a row and no 0's, we default to [1,1,1]
    fact([0],dihdahsep) .
    fact([0,0,0],^) .
    fact([0,0,0,0,0,0,0],#) .                                                                                                                                                       
    fact([0,0,0,0],^) . % unambiguous - HAS to be [0,0,0]
    fact([0,0,0,0,0,0,0,0|Tail],Result) :- \+(member(1,Tail)), fact([0,0,0,0,0,0,0],Result) . % if more than 5 0's in a row and no 1's, we default to [0,0,0,0,0]

% ambiguous rules from signals to dihs and dahs
    fact([1,1],.) . % ambiguous rule - could be [1]
    fact([1,1],-) . % ambiguous rule - could be [1,1,1]
    fact([0,0],dihdahsep) . % ambiguous - could be [0]
    fact([0,0],^) . % ambiguous - could be [0,0,0]	 
    fact([0,0,0,0,0],^) . % ambiguous - could be [0,0,0]
    fact([0,0,0,0,0],#) . % ambiguous - could be [0,0,0,0,0,0,0]  
	 
% rules verifying separator ambiguity
    rule(Signal,[]) :- fact(Signal,dihdahsep) .
    rule(Signal,[^]) :- fact(Signal,^) .
    rule(Signal,[#]) :- fact(Signal,#) . 

% signal morse predicate implementation
signal_morse([],[]) . % base case - input signal is nothing so nothing is parsed
signal_morse(Signal,[Morse]) :- fact(Signal,Morse) . % base case - one signal (or series of) passed		 

% cases to break down one signal unit (dihdahs,letters, and words) and its corresponding separator within a larger group of signals		 
signal_morse(Signal,[Morse]) :- append(Word,Pattern,Signal), fact(Pattern,#), fact(Word,Morse) .                                                                                    
signal_morse(Signal,[Morse]) :- append(Word,Pattern,Signal), fact(Pattern,^), fact(Word,Morse) .
signal_morse(Signal,[Morse]) :- append(Word,Pattern,Signal), fact(Pattern,dihdahsep), fact(Word,Morse) .

% main signal_morse rule, broken down into smaller facts that must all be satisfied
signal_morse(Signal, Morse) :-
        % separate input signal into all possible combinations 
	append(Head, Tail, Signal),
        % check for signal chunk to be separateable 
        rule(Pattern, Sign),
	% separate tail-end of input into a sub-head and sub-tail (making sure sub-tail begins with a 1)							  
        append(Pattern, [1|PatternTail], Tail),
        % translate SignalHead to a morse symbol 
	fact(Head, Translate),
	% make sure MorseSymbol does not equal a dihdah separator							  
        Translate \= dihdahsep,
	append([Translate], Sign, TranslateHead),
	% recursive call with rest of signal							  
	signal_morse([1|PatternTail], TranslateTail),
	% concatenate the MorseHead and MorseTail to M							  
        append(TranslateHead, TranslateTail, Morse).

% Morse code table provided by the spec
morse(a, [.,-]).           % A
morse(b, [-,.,.,.]).	   % B
morse(c, [-,.,-,.]).	   % C
morse(d, [-,.,.]).	   % D
morse(e, [.]).		   % E
morse('e''', [.,.,-,.,.]). % É (accented E)
morse(f, [.,.,-,.]).	   % F
morse(g, [-,-,.]).	   % G
morse(h, [.,.,.,.]).	   % H
morse(i, [.,.]).	   % I
morse(j, [.,-,-,-]).	   % J
morse(k, [-,.,-]).	   % K or invitation to transmit
morse(l, [.,-,.,.]).	   % L
morse(m, [-,-]).	   % M
morse(n, [-,.]).	   % N
morse(o, [-,-,-]).	   % O
morse(p, [.,-,-,.]).	   % P
morse(q, [-,-,.,-]).	   % Q
morse(r, [.,-,.]).	   % R
morse(s, [.,.,.]).	   % S
morse(t, [-]).	 	   % T
morse(u, [.,.,-]).	   % U
morse(v, [.,.,.,-]).	   % V
morse(w, [.,-,-]).	   % W
morse(x, [-,.,.,-]).	   % X or multiplication sign
morse(y, [-,.,-,-]).	   % Y
morse(z, [-,-,.,.]).	   % Z
morse(0, [-,-,-,-,-]).	   % 0
morse(1, [.,-,-,-,-]).	   % 1
morse(2, [.,.,-,-,-]).	   % 2
morse(3, [.,.,.,-,-]).	   % 3
morse(4, [.,.,.,.,-]).	   % 4
morse(5, [.,.,.,.,.]).	   % 5
morse(6, [-,.,.,.,.]).	   % 6
morse(7, [-,-,.,.,.]).	   % 7
morse(8, [-,-,-,.,.]).	   % 8
morse(9, [-,-,-,-,.]).	   % 9
morse(., [.,-,.,-,.,-]).   % . (period)
morse(',', [-,-,.,.,-,-]). % , (comma)
morse(:, [-,-,-,.,.,.]).   % : (colon or division sign)
morse(?, [.,.,-,-,.,.]).   % ? (question mark)
morse('''',[.,-,-,-,-,.]). % ' (apostrophe)
morse(-, [-,.,.,.,.,-]).   % - (hyphen or dash or subtraction sign)
morse(/, [-,.,.,-,.]).     % / (fraction bar or division sign)
morse('(', [-,.,-,-,.]).   % ( (left-hand bracket or parenthesis)
morse(')', [-,.,-,-,.,-]). % ) (right-hand bracket or parenthesis)
morse('"', [.,-,.,.,-,.]). % " (inverted commas or quotation marks)
morse(=, [-,.,.,.,-]).     % = (double hyphen)
morse(+, [.,-,.,-,.]).     % + (cross or addition sign)
morse(@, [.,-,-,.,-,.]).   % @ (commercial at)

% Error.
morse(error, [.,.,.,.,.,.,.,.]). % error - see below

% Prosigns.
morse(as, [.,-,.,.,.]).          % AS (wait A Second)
morse(ct, [-,.,-,.,-]).          % CT (starting signal, Copy This)
morse(sk, [.,.,.,-,.,-]).        % SK (end of work, Silent Key)
morse(sn, [.,.,.,-,.]).          % SN (understood, Sho' 'Nuff)

% in implementing the signal_message rule, I used the definition of a word
% to be a sequence of Signals that is nonempty and does not contain the word
% boundary signal of #. Following this design pattern, I ommitted any sequences
% of signals that corresponded to an error as well. As mentioned in the spec, I ommitted
% any words that followed an error token.

	 
% rules for removing error tokens
removeErrorRule([],[]) . % base rule
removeErrorRule([error|errorTail],Morse) :- removeErrorRule(errorTail, Morse). % given an error in list, we take its tail
removeErrorRule([Head|Tail], [Head|MorseTail]) :- removeErrorRule(Tail, MorseTail). 

% rules for removing a word that precedes spaces and an error token
% the 'once' keyword in prolog ensures that call is not executable upon backtracking (making sure we only remove the word)	 
removeWordRule([], []). % base rule
removeWordRule(Signal, Morse) :- append(_, [#,error|Tail], Signal), removeWordRule(Tail, Morse).                                                                                    
removeWordRule(Signal, Morse) :-
	% separate word in signal from an error signal 				    
	once(append(Head, [error|Tail], Signal)),
	% add previous full word to head word				    
        once(append(PrevWord, [#|_], Head)),
        % remove the isolated word following erorr                                                                                                                                  
        removeWordRule(Tail, TailMessage),
        append(PrevWord, [#|TailMessage], Morse).                                                                                                                                   removeWordRule(Signal, Morse) :- once(append(_, [error|Tail], Signal)), removeWordRule(Tail, Morse).
removeWordRule(Signal, Signal).

% rules for converting a word to morse	 
signalWord([], []).
signalWord(Morse, [Letter]) :- morse(Letter, Morse).
signalWord(Morse, [LetterHead|LettersTail]) :- 
	append(MorseHead, [^|MorseTail], Morse), 
	morse(LetterHead, MorseHead),
	signalWord(MorseTail, LettersTail).
							 
% rules for converting a signal
signalRule([], []).
signalRule(Morse, Message) :- signalWord(Morse, Message).
signalRule(Morse, Message) :- 
	append(Word, [#|WordsTail], Morse), 
	signalWord(Word, WordMsg), 
	signalRule(WordsTail, WordsMsg), 
        append(WordMsg, [#|WordsMsg], Message).

% signal_message rule						      
signal_message(Signal, Morse) :- 
	signal_morse(Signal, MorseForm),
        signalRule(MorseForm, UnfilteredMorse), 
	once(removeWordRule(UnfilteredMorse, FilteredMessage)), 
        once(removeErrorRule(FilteredMessage, Morse)).

	 
