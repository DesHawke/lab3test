%%%-------------------------------------------------------------------
%%% @author user
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 18. дек. 2019 11:25
%%%-------------------------------------------------------------------
-module(quote).
-author("user").

%% API
%-export([consumer/2, loanBroker/0, creditAgencyGateaway/0, bankQuoteGateaway/0, lenderGateaway/0, bank2/0, bank3/0, bank1/0]).

-compile(export_all).

consumer(0, _) ->
  io:format("Consumer: finally done!"),
  pingLoop(pang, 'pidLoanBroker'),
  resolvePid(pidLoanBroker) ! done,

  pingLoop(pang, 'pidCreditAgencyGateaway'),
  resolvePid(pidCreditAgencyGateaway) ! done,

  pingLoop(pang, 'pidBankQuoteGateaway'),
  resolvePid(pidBankQuoteGateaway) ! done,

  pingLoop(pang, 'pidLenderGateaway'),
  resolvePid(pidLenderGateaway) ! done,

  pingLoop(pang, 'pidBank1'),
  resolvePid(pidBank1) ! done,
  pingLoop(pang, 'pidBank2'),
  resolvePid(pidBank2) ! done,
  pingLoop(pang, 'pidBank3'),
  resolvePid(pidBank3) ! done;
consumer(Index, 0) ->
  pingLoop(pang, 'pidLoanBroker'),
  io:format("Consumer: getLoanQuote!"),
  resolvePid(pidLoanBroker) ! getloanQuote,
  consumer(Index, 1);
consumer(Index, 1) ->
  receive
    bestQuoteReport ->
      io:format("Consumer: bestQuoteReport"),
      consumer(Index - 1, 0)
  end.

loanBroker() ->
  receive
    done ->
      io:format("LoanBroker: done~n");
    getloanQuote ->
      pingLoop(pang, 'pidConsumer'),
      io:format("LoanBroker: received loanquote => getLoanQuotesWithScores!"),
      resolvePid(pidCreditAgencyGateaway) ! getLoanQuotesWithScores,
      loanBroker();
    creditProfile ->
      pingLoop(pang, 'pidCreditAgencyGateaway'),
      io:format("LoanBroker: received creditprofile => getLenderList!"),
      resolvePid(pidLenderGateaway) ! getLenderList,
      loanBroker();
    lenderList ->
      pingLoop(pang, 'pidLenderGateaway'),
      io:format("LoanBroker: received lenderList => getBestQuote!"),
      resolvePid(pidBankQuoteGateaway) ! getBestQuote,
      loanBroker();
    bestQuote ->
      pingLoop(pang, 'pidBankQuoteGateaway'),
      io:format("LoanBroker: bestQuote recieved => formalreport"),
      resolvePid(pidLoanBroker) ! formalReport,
      loanBroker();
    formalReport ->
      io:format("LoanBroker: formalReport to consumer"),
      resolvePid(pidConsumer) ! bestQuoteReport,
      loanBroker()
  end.

creditAgencyGateaway() ->
  receive
    done ->
      io:format("CreditAgencyGateaway: done~n");
    getLoanQuotesWithScores ->
      pingLoop(pang, 'pidLoanBroker'),
      io:format("CreditAgencyGateaway: return creditprofile!"),
      resolvePid(pidLoanBroker) ! creditProfile,
      creditAgencyGateaway()
  end.

lenderGateaway() ->
  receive
    done ->
      io:format("LenderGateaway: done~n");
    getLenderList ->
      pingLoop(pang, 'pidLoanBroker'),
      io:format("LenderGateaway: new consumer!"),
      resolvePid(pidLoanBroker) ! lenderList,
      lenderGateaway()
  end.

bankQuoteGateaway() ->
  receive
    done ->
      io:format("BankQuoteGateaway: done~n");
    getBestQuote ->
      pingLoop(pang, 'pidLoanBroker'),
      io:format("BankQuoteGateaway: getBestQuote!"),
      resolvePid(pidBank1) ! getBankQuote,
      resolvePid(pidBank2) ! getBankQuote,
      resolvePid(pidBank3) ! getBankQuote,
      bankQuoteGateaway();
    bankQuote ->
      pingLoop(pang, 'pidBank1'),
      pingLoop(pang, 'pidBank2'),
      pingLoop(pang, 'pidBank3'),
      io:format("BankQuoteGateaway: getBankQuote!"),
      resolvePid(pidBankQouteGateaway) ! getBestBankQuote,
      bankQuoteGateaway();
    getBestBankQuote ->
      io:format("BankQuoteGateaway: getBestQuote!"),
      resolvePid(pidLoanBroker) ! bestQuote,
      loanBroker()
  end.

bank1() ->
  receive
    done ->
      io:format("Bank1: done~n");
    getBankQuote ->
      pingLoop(pang, 'pidBankQuoteGateaway'),
      io:format("Bank1: getBankQuote!"),
      resolvePid(pidBankQuoteGateaway) ! getBankQuote
  end,
  bank1().

bank2() ->
  receive
    done ->
      io:format("Bank2: done~n");
    getBankQuote ->
      pingLoop(pang, 'pidBankQuoteGateaway'),
      io:format("Bank2: getBankQuote!"),
      resolvePid(pidBankQuoteGateaway) ! getBankQuote
  end,
  bank2().

bank3() ->
  receive
    done ->
      io:format("Bank3: done~n");
    getBankQuote ->
      pingLoop(pang, 'pidBankQuoteGateaway'),
      io:format("Bank3: getBankQuote!"),
      resolvePid(pidBankQuoteGateaway) ! getBankQuote
  end,
  bank3().

runConsumerNode(N) ->
  global:register_name(pidConsumer, spawn(quote, consumer, [N,0])).

runLoanBrokerNode() ->
  global:register_name(pidLoanBroker, spawn(quote, loanBroker,[])).

runCreditAgencyGateaway() ->
  global:register_name(pidCreditAgencyGateaway, spawn(quote,creditAgencyGateaway, [])).

runLenderGateAway() ->
  global:register_name(pidLenderGateaway, spawn(quote, lenderGateaway,[])).

runBankQuoteGateaway() ->
  global:register_name(pidBankQuoteGateaway, spawn(quote, bankQuoteGateaway, [])).

runBank1Node() ->
  global:register_name(pidBank1, spawn(quote, bank1, [])).
runBank2Node() ->
  global:register_name(pidBank2, spawn(quote, bank2, [])).
runBank3Node() ->
  global:register_name(pidBank3, spawn(quote, bank3, [])).

%% ==============================================
%% Internal functions
%% =================================================
resolvePid(Atom) ->
  %io:format("Pid  ~n",[string:concat(erlang:atom_to_list(Atom),"@127.0.0.1")]),
  global:whereis_name(Atom).
buildNodeAddress(Atom) ->
  list_to_atom(string:concat(erlang:atom_to_list(Atom), "@mypc")).

pingLoop(pong, NodeName) ->
  %io:format("node ~s registered ~n",[NodeName]),
  checkNodeByName(resolvePid(NodeName), NodeName),
  pingOK;
pingLoop(pang, NodeName) ->
  timer:sleep(3333),

  pingLoop(net_adm:ping(buildNodeAddress(NodeName)), NodeName).

checkNodeByName(undefined, NodeName) ->
  pingLoop(pang, NodeName);
checkNodeByName(_, _) ->
  %io:format("node ~s registered ~n",[NodeName]),
  checkOK.

