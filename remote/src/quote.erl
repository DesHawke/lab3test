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
%-export([consumer/2, loanBroker/0, creditAgencyGateway/0, bankQuoteGateway/0, lenderGateway/0, bank2/0, bank3/0, bank1/0]).

-compile(export_all).

consumer(0, _) ->
  io:format("~nConsumer: finally done!~n"),

  pingLoop(pang, 'pidLoanBroker'),
  resolvePid(pidLoanBroker) ! done,

  pingLoop(pang, 'pidCreditAgencyGateway'),
  resolvePid(pidCreditAgencyGateway) ! done,

  pingLoop(pang, 'pidBankQuoteGateway'),
  resolvePid(pidBankQuoteGateway) ! done,

  pingLoop(pang, 'pidLenderGateway'),
  resolvePid(pidLenderGateway) ! done,

  pingLoop(pang, 'pidBank1'),
  resolvePid(pidBank1) ! done,

  pingLoop(pang, 'pidBank2'),
  resolvePid(pidBank2) ! done,

  pingLoop(pang, 'pidBank3'),
  resolvePid(pidBank3) ! done;

consumer(Index, 0) ->
  io:format("Consumer: getLoanQuote!~n"),

  pingLoop(pang, 'pidLoanBroker'),
  resolvePid(pidLoanBroker) ! getloanQuote,

  consumer(Index, 1);

consumer(Index, 1) ->
  receive
    bestQuoteReport ->
      io:format("Consumer: received bestQuote~n~n"),
      consumer(Index - 1, 0)
  end.


loanBroker() ->
  receive
    done ->
      io:format("LoanBroker: done~n");
    getloanQuote ->
      io:format("LoanBroker: received loanquote => getLoanQuotesWithScores!~n"),

      pingLoop(pang, 'pidCreditAgencyGateway'),
      resolvePid(pidCreditAgencyGateway) ! getLoanQuotesWithScores,

      loanBroker();
    creditProfile ->
      io:format("LoanBroker: received creditprofile => getLenderList!~n"),

      pingLoop(pang, 'pidLenderGateway'),
      resolvePid(pidLenderGateway) ! getLenderList,

      loanBroker();
    lenderList ->
      io:format("LoanBroker: received lenderList => getBestQuote!~n"),

      pingLoop(pang, 'pidBankQuoteGateway'),
      resolvePid(pidBankQuoteGateway) ! getBestQuote,

      loanBroker();
    bestQuote ->

      io:format("LoanBroker: bestQuote recieved => formalreport~n"),

      %pingLoop(pang, 'pidLoanBroker'),
      resolvePid(pidLoanBroker) ! formalReport,

      loanBroker();
    formalReport ->
      io:format("LoanBroker: formalReport to consumer~n~n"),

      pingLoop(pang, 'pidConsumer'),
      resolvePid(pidConsumer) ! bestQuoteReport,

      loanBroker()
  end.

creditAgencyGateway() ->
  receive
    done ->
      io:format("CreditAgencyGateway: done~n");
    getLoanQuotesWithScores ->
      io:format("CreditAgencyGateway: getLoanQuotesWithScores => return creditprofile!~n~n"),

      pingLoop(pang, 'pidLoanBroker'),
      resolvePid(pidLoanBroker) ! creditProfile,

      creditAgencyGateway()
  end.

lenderGateway() ->
  receive
    done ->
      io:format("LenderGateway: done~n");
    getLenderList ->
      io:format("LenderGateway: getLenderList => return lenderList!~n~n"),

      pingLoop(pang, 'pidLoanBroker'),
      resolvePid(pidLoanBroker) ! lenderList,

      lenderGateway()
  end.

bankQuoteGateway() ->
  receive
    done ->
      io:format("BankQuoteGateway: done~n");
    getBestQuote ->
      io:format("BankQuoteGateway: getBestQuote! => getBankQuote~n"),

      pingLoop(pang, 'pidBank1'),
      resolvePid(pidBank1) ! getBankQuote,

      %pingLoop(pang, 'pidBank2'),
      %resolvePid(pidBank2) ! getBankQuote,

      %pingLoop(pang, 'pidBank3'),
      %resolvePid(pidBank3) ! getBankQuote,

      bankQuoteGateway();
    bankQuote ->
      %pingLoop(pang, 'pidBank1'),
      %pingLoop(pang, 'pidBank2'),
      %pingLoop(pang, 'pidBank3'),
      io:format("BankQuoteGateway: countingBest!~n"),

      resolvePid(pidBankQuoteGateway) ! getBestBankQuote,

      bankQuoteGateway();
    getBestBankQuote ->
      io:format("BankQuoteGateway: getBestBankQuote! => return bestQuote~n~n"),

      pingLoop(pang, 'pidLoanBroker'),
      resolvePid(pidLoanBroker) ! bestQuote,

      bankQuoteGateway()
  end.

bank1() ->
  receive
    done ->
      io:format("Bank1: done~n"),
      "Bank1: done~n";
    getBankQuote ->
      io:format("Bank1: getBankQuote! => return bankQuote~n~n"),

      pingLoop(pang, 'pidBankQuoteGateway'),
      resolvePid(pidBankQuoteGateway) ! bankQuote,
      bank1()
  end.

%bank2() ->
%  receive
%    done ->
%      io:format("Bank2: done~n");
%    getBankQuote ->
%      pingLoop(pang, 'pidBankQuoteGateway'),
%      io:format("Bank2: getBankQuote!~n"),
%      resolvePid(pidBankQuoteGateway) ! getBankQuote
%  end,
%  bank2().

%bank3() ->
%  receive
%    done ->
%      io:format("Bank3: done~n");
%    getBankQuote ->
%      pingLoop(pang, 'pidBankQuoteGateway'),
%      io:format("Bank3: getBankQuote!~n"),
%      resolvePid(pidBankQuoteGateway) ! getBankQuote
%  end,
%  bank3().

runConsumerNode(N) ->
  global:unregister_name(pidConsumer),
  global:register_name(pidConsumer, spawn(quote, consumer, [N, 0])).

runLoanBrokerNode() ->
  global:unregister_name(pidLoanBroker),
  global:register_name(pidLoanBroker, spawn(quote, loanBroker, [])).

runCreditAgencyGateway() ->
  global:unregister_name(pidCreditAgencyGateway),
  global:register_name(pidCreditAgencyGateway, spawn(quote, creditAgencyGateway, [])).

runLenderGateway() ->
  global:unregister_name(pidLenderGateway),
  global:register_name(pidLenderGateway, spawn(quote, lenderGateway, [])).

runBankQuoteGateway() ->
  global:unregister_name(pidBankQuoteGateway),
  global:register_name(pidBankQuoteGateway, spawn(quote, bankQuoteGateway, [])).

runBank1Node() ->
  global:unregister_name(pidBank1),
  global:register_name(pidBank1, spawn(quote, bank1, [])).


%% ==============================================
%% Internal functions
%% =================================================
resolvePid(Atom) ->
  %io:format("Pid  ~n",[string:concat(erlang:atom_to_list(Atom),"@127.0.0.1")]),
  global:whereis_name(Atom).
buildNodeAddress(Atom) ->
  list_to_atom(string:concat(erlang:atom_to_list(Atom), "@developer")).

pingLoop(pong, NodeName) ->
  %io:format("node ~s registered ~n",[NodeName]),
  checkNodeByName(resolvePid(NodeName), NodeName),
  pingOK;
pingLoop(pang, NodeName) ->
  timer:sleep(1),

  pingLoop(net_adm:ping(buildNodeAddress(NodeName)), NodeName).

checkNodeByName(undefined, NodeName) ->
  pingLoop(pang, NodeName);
checkNodeByName(_, _) ->
  %io:format("node ~s registered ~n",[NodeName]),
  checkOK.

