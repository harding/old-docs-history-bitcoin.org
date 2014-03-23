---
layout: base
lang: en
id: developer-guide
title: "Developer Guide - Bitcoin"
---

# Bitcoin Developer Guide

<p class="summary">Find detailed information about the Bitcoin protocol and related specifications.</p>

<div markdown="1" id="toc" class="toc"><div markdown="1">

* Table of contents
{:toc}

</div></div>


<!--#md#<div markdown="1" class="toccontent">#md#-->

<p style="padding:10px;background-color:rgb(255, 242, 202);"><b>Contribute</b>: This document is still being written; if you find a mistake, please
<a href="https://github.com/saivann/bitcoin.org/issues">open an issue</a>. If you want to write or edit a section, please read and comment on our <a href="https://bitcointalk.org/index.php?topic=511876">forum thread</a> or sign up for our <a href="https://groups.google.com/forum/?hl=en#!forum/bitcoin-documentation">mailing list</a>.</p>

**Note**: Some strings are shortened or wrapped: "[...]" indicates extra data was removed, and lines ending in a single backslash "\\" are continued below.

## The Bitcoin Block Chain

The block chain provides Bitcoin's public ledger, a timestamped record
of all confirmed transactions. This system is used to protect against double
spending and modification of previous transaction records, using proofs of
work verified by the peer-to-peer network to maintain a global consensus.

This document provides detailed explanations about the functionning of
this system along with security advices for risk assessment and tools for
using block chain data.

### Block Chain Overview

![Block Chain Overview](/img/dev/blockchain-overview.png)

<!-- DAH TODO provide merkle tree description; see mikehearn email -->

Figure 1 shows a simplified version of a three-block block chain.
Each **block**, which is typically a few hundred transactions,
is hashed to create a **Merkle root** -- essentially, a hash of hashes.
This is stored in the **block header**. Each block then stores the hash of the
previous block's header, chaining the blocks together. This ensures a
transaction cannot be modified without modifying the block that records
it and all following blocks.

Transactions are also chained together. Bitcoin wallet software gives
the impression that bitcoins are sent from and to addresses, but
bitcoins really move from transaction to transaction. Each standard
transaction spends the bitcoins previously spent in one or more earlier
transactions, so the **input** of one transaction is the **output** of a
previous transaction.

![Transaction Propagation](/img/dev/transaction-propagation.png)

A single transaction can spend bitcoins to multiple outputs, as would be
the case when sending bitcoins to multiple addresses, but each output of
a particular transaction can only be used as an input once in the
block chain. Any subsequent reference is a forbidden **double
spend** -- an attempt to spend the same bitcoins twice.

Outputs are not the same as Bitcoin addresses. You can use the same
address in multiple transactions, but you can only use each output once.
Outputs are tied to **transaction identifiers (TXIDs)**, which are the hashes
of complete transactions.

Because each output of a particular transaction can only be spent once,
all transactions included in the block chain can be categorized as either
**Unspent Transaction Outputs (UTXOs)** or spent transaction outputs. For a
payment to be valid, it must only use UTXOs as inputs.

Bitcoins cannot be left in a UTXO after a transaction: they will be
irretrievably lost. So any difference between the number of bitcoins in a
transaction's inputs and outputs is given as a **transaction fee** to 
the Bitcoin **miner** who creates the block containing that transaction. 
For example, in Figure 2 each transaction spends 10 millibits fewer than 
it receives from its combined inputs, effectively paying a 10 millibit 
transaction fee. 

The spenders propose a transaction fee with each 
transaction; miners decide whether the amount proposed is adequate,
and only accept transactions that pass their threshold. Therefore,
transactions with a higher proposed transaction fee are likely to be
processed faster.

#### Proof Of Work

Although chaining blocks together makes it impossible to modify
transactions included in any block without modifying all following block
headers, the cost of modification is only two hashes for the first block
modified plus one hash for every subsequent block until the current end
of the block chain.

Since the block chain is collaboratively maintained on a peer-to-peer
network which may contain untrustworthy peers, Bitcoin requires each
block prove a significant amount of work was invested in its creation so
that untrustworthy peers who want to modify past blocks have to work harder
than trustworthy peers who only want to add new blocks to the
block chain.

The **proof of work** used in Bitcoin takes advantage of the apparently
random output of cryptographic hashes. A good cryptographic hash
algorithm converts arbitrary input data into a seemingly-random number.
If the input data is modified in any way and the hash re-run, a new
seemingly-random number is produced, so there is no way to modify the
input data to make the hash number predictable.

To prove you did some extra work to create a block, you must create a
hash of the block header which does not exceed a certain value. For
example, if the maximum possible hash value is <span
class="math">2<sup>256</sup> − 1</span>, you can prove that you
tried up to two combinations by producing a hash value less than <span
class="math">2<sup>256</sup> − 1</span>.

In the example given above, you will almost certainly produce a
successful hash on your first try. You can even estimate the probability
that a given hash attempt will generate a number below the **target**
threshold. Bitcoin itself does not track probabilities but instead
simply assumes that the lower it makes the target threshold, the more
hash attempts, on average, will need to be tried.

New blocks will only be added to the block chain if their hash is at
least as challenging as a **difficulty** value expected by the peer-to-peer
network. Every 2,016 blocks, the network uses timestamps stored in each
block header to calculate the number of seconds elapsed between generation
of the first and last of those last 2,016 blocks. The ideal value is
1,209,600 seconds (two weeks).

* If it took fewer than two weeks to generate the 2,016 blocks,
  the expected difficulty value is increased proportionally (by as much
  as 300%) so that the next 2,016 blocks should take exactly two weeks
  to generate if hashes are checked at the same rate.

* If it took more than two weeks to generate the blocks, the expected
  difficulty value is decreased proportionally (by as much as 75%) for
  the same reason.

(Note: an off-by-one error in the implementation causes the difficulty
to be updated every 2,01*6* blocks using timestamps from only
2,01*5* blocks, creating a slight skew.)

Because each block header must hash to a value below the target
threshold, and because each block is linked to the block that
preceded it, it requires (on average) as much hashing power to
propagate a modified block as the entire Bitcoin network expended
between the time the original block was created and the present time.
Only if you acquired a majority of the network's hashing power
could you reliably execute such a **51 percent attack** against
transaction history.

The block header provides several easy-to-modify fields, such as a
dedicated nonce field, so obtaining new hashes doesn't require waiting
for new transactions. Also, only the 80-byte block header is hashed for
proof-of-work, so adding more transactions to a block does not slow
down hashing with extra I/O.

#### Block Height And Forking

Any Bitcoin miner who successfully hashes a block header to a value
below the target can add the entire block to the block chain.
(Assuming the block is otherwise valid.) These blocks are commonly addressed
by their **block height** -- the number of blocks between them and the first Bitcoin
block (block 0, most commonly known as the **genesis block**). For example,
block 2016 is where difficulty could have been first adjusted.

![Common And Uncommon Block Chain Forks](/img/dev/blockchain-fork.png)

Multiple blocks can all have the same block height, as is common when
two or more miners each produce a block at roughly the same time. This
creates an apparent **fork** in the block chain, as shown in figure 3.

When miners produce simultaneous blocks at the end of the block chain, each
peer individually chooses which block to trust. (In the absence of
other considerations, discussed below, peers usually trust the first
block they see.)

Eventually miners produce another block which attaches to only one of
the competing simultaneously-mined blocks. This makes that side of
the fork longer than the other side. Assuming a fork only contains
valid blocks, normal peers always follow the longest fork to the end
of the block chain and throw away (**orphan**) blocks belonging to
shorter forks.

(Technically peers follow whichever fork would be the most difficult to
recreate. In practice, the most difficult to recreate fork is almost
always the longest fork.)

Long-term forks are possible if different miners work at cross-purposes,
such as some miners diligently working to extend the block chain at the
same time other miners are attempting a 51 percent attack to revise
transaction history.

#### Double-Spend Risk Analysis

The properties of the block chain ensure that transaction history is more 
difficult to modify the older it gets. For the very same reason, recent 
transactions cannot be considered irreversible and often require additional 
risk analysis. Your programs should be designed to discourage or avoid 
performing any costly actions as long as a payment can potentially be reversed.

More specifically, an attacker can create one transaction that pays a merchant 
and a second one that pays the same UTXO back to himself. This is commonly 
referred to as a **double spend**. In this example, only one of these transactions 
can be included in the block chain, and once included in a block, the cost of 
replacing a transaction is to modify the block and all following blocks until 
the current end of the block chain.

The Bitcoin protocol can give each of your transactions an updating confidence 
score based on the number of blocks which would need to be modified to replace 
a transaction. For each block, the transaction gains one **confirmation**. Since 
modifying blocks is quite difficult, higher confirmation scores indicate 
greater protection.

**0 confirmations**: The transaction has been broadcast but is still not 
included in any block. Zero confirmation transactions should generally not be 
trusted without risk analysis. Although miners usually confirm the first 
transaction they receive, fraudsters may be able to manipulate the
network into including their version of a transaction.

**1 confirmation**: The transaction is included in the latest block and 
double-spend risk decreases dramatically. Transactions which pay
sufficient transaction fees need 10 minutes on average to receive one
confirmation. However, the most recent block gets replaced fairly often by
accident, so a double spend is still a real possibility.

**2 confirmations**: The most recent block was chained to the block which 
includes the transaction. As of March 2014, two block replacements were 
exceedingly rare, and a two block replacement attack was unpractical without 
expensive mining equipment.

**6 confirmations**: The network has spent about an hour working to protect 
your transaction against double spends and the transaction is buried under six 
blocks. Even a reasonably lucky attacker would require a large percentage of 
the total network hashing power to replace six blocks. Although this number is 
somewhat arbitrary, software handling high-value transactions, or otherwise at 
risk for fraud, should wait for at least six confirmations before treating a 
payment as accepted.

Bitcoin Core provides several RPCs which can provide your program with the 
confirmation score for transactions in your wallet or arbitrary transactions. 
For example, the `listunspent` RPC provides an array of every bitcoin you can 
spend along with its confirmation score.

Although confirmations provide excellent double-spend protection most of the 
time, there are at least three cases where double-spend risk analysis can be 
required:

1. In the case when the program or its user cannot wait for a confirmation and 
wants to accept zero confirmation payments.
2. In the case when the program or its user is accepting high value 
transactions and cannot wait for at least six confirmations or more.
3. In the case of an implementation bug or prolonged attack against Bitcoin 
which makes the system less reliable than expected.

An interesting source of double-spend risk analysis can be acquired by 
connecting to large numbers of Bitcoin peers to track how transactions and 
blocks differ from each other. Some third-party APIs can provide you with this 
type of service.

<!-- TODO Example of double spend risk analysis using bitcoinj, eventually? -->

For example, unconfirmed transactions can be compared among all connected peers 
to see if any UTXO is used in multiple unconfirmed transactions, indicating a 
double-spend attempt, in which case the payment can be refused until it is 
confirmed. Transactions can also be ranked by their transaction fee to
estimate the amount of time until they're added to a block.

Another example could be to detect a fork when multiple peers report differing 
block header hashes at the same block height. Your program can go into a safe mode if the 
fork extends for more than two blocks, indicating a possible problem with the 
block chain.

Another good source of double-spend protection can be human intelligence. For 
example, fraudsters may act differently from legitimate customers, letting 
savvy merchants manually flag them as high risk. Your program can provide a 
safe mode which stops automatic payment acceptance on a global or per-customer 
basis.

### Implementation Details: Block Contents

This section describes version 2 blocks, which are any blocks with a
block height greater than 227,835. (Version 1 and version 2 blocks were
intermingled for some time before that point.) Future block versions may
break compatibility with the information in this section. You can determine
the version of any block by checking its ``version`` field using
[bitcoind RPC calls](#example-block-and-coinbase-transaction).

As of version 2 blocks, each block consists of four root elements:

1. A magic number (0xd9b4bef9).

2. A 4-byte unsigned integer indicating how many bytes follow until the
   end of the block. Although this field would suggest maximum block
   sizes of 4 GiB, max block size is currently capped at 1 MiB and the
   default max block size (used by most miners) is 350 KiB (although
   this will likely increase over time).

3. An 80-byte header described in the section below.

4. One or more transactions. 

Blocks are usually referenced by the SHA256(SHA256()) hash of their header, but
because this hash must be below the target threshold, there exists an
increased (but still minuscule) chance of eventual hash collision.

Blocks can also be referenced by their block height, but multiple blocks
can have the same height during a block chain fork, so block height
should not be used as a globally unique identifier. In version 2 blocks,
each block must place its height as the first parameter in the coinbase
field of the coinbase transaction (described below), so block height
can be determined without access to previous blocks.

#### Block Header

The 80-byte block header contains the following six fields:

<table>
<thead>
<tr class="header">
<th align="left">Field</th>
<th align="left">Bytes</th>
<th align="left">Format</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left">Version</td>
<td align="left">4</td>
<td align="left">Unsigned Int</td>
</tr>
<tr class="even">
<td align="left">hashPrevBlock</td>
<td align="left">32</td>
<td align="left">Unsigned Int (SHA256 Hash)</td>
</tr>
<tr class="odd">
<td align="left">hashMerkleRoot</td>
<td align="left">32</td>
<td align="left">Unsigned Int (SHA256 Hash)</td>
</tr>
<tr class="even">
<td align="left">Time</td>
<td align="left">4</td>
<td align="left">Unsigned Int (Epoch Time)</td>
</tr>
<tr class="odd">
<td align="left">Bits</td>
<td align="left">4</td>
<td align="left">Internal Bitcoin Target Format</td>
</tr>
<tr class="even">
<td align="left">Nonce</td>
<td align="left">4</td>
<td align="left">(Arbitrary Data)</td>
</tr>
</tbody>
</table>


1. The *version* number indicates which set of block validation rules
   to follow so Bitcoin Core developers can add features or
   fix bugs. As of block height 227,836, all blocks use version number
   2.

2. The *hash of the previous block header* puts this block on the
   block chain and ensures no previous block can be changed without also
   changing this block's header.

3. The *Merkle root* is a hash of all the transactions included
   in this block. It ensures no transactions can be modified in this
   block without changing the block header.

4. The *time* is the approximate time when this block was created in
   Unix Epoch time format (number of seconds elapsed since
   1970-01-01T00:00 UTC). The time value must be greater than the
   time of the previous block. No peer will accept a block with a
   time currently more than two hours in the future according to the
   peer's clock.

5. *Bits* translates into the target threshold value -- the maximum allowed
   value for this block's hash. The bits value must match the network
   difficulty at the time the block was mined.

6. The *nonce* is an arbitrary input that miners can change to test different
   hash values for the header until they find a hash value less than or
   equal to the target threshold. If all values within the nonce's four
   bytes are tested, the time can be changed by one second or the
   coinbase transaction (described below) can be changed and the Merkle
   root updated.

#### Transaction Data

Every block must include one or more transactions. Exactly one of these
transactions must be a coinbase transaction which should collect and
spend any transaction fees paid by transactions included in this block.
All blocks with a block height less than 6,930,000 are entitled to
receive a block reward of newly created bitcoin value, which also
should be spent in the coinbase transaction. (The block reward started
at 50 bitcoins and is being halved approximately every four years: as of
March 2014, it's 25 bitcoins.) A coinbase transaction is invalid if it 
tries to spend more value than is available from the transaction 
fees and block reward.

The coinbase transaction has the same basic format as any other
transaction, but it references a single non-existent UTXO and a special
coinbase field replaces the field that would normally hold a script and
signature. In version 2 blocks, the coinbase parameter must begin with
the current block's block height and may contain additional arbitrary
data or a script up to a maximum total of 100 bytes.

The UTXO of a coinbase transaction has the special condition that it
cannot be spent (used as an input) for at least 100 blocks. This
helps prevent a miner from spending the transaction fees and block
reward from a block that will later be orphaned (destroyed) after a
block fork.

Blocks are not required to include any non-coinbase transactions, but
miners almost always do include additional transactions in order to
collect their transaction fees.

All transactions, including the coinbase transaction, are encoded into
blocks in binary rawtransaction format prefixed by a block transaction
sequence number.

#### Example Block And Coinbase Transaction

The first block with more than one transaction is at block height 170.
We can get the hash of block 170's header with the `getblockhash` RPC:

    > getblockhash 170

    00000000d1145790a8694403d4063f323d499e655c83426834d4ce2f8dd4a2ee

We can then get a decoded version of that block with the `getblock` RPC:

    > getblock 00000000d1145790a8694403d4063f323d499e655c83\
      426834d4ce2f8dd4a2ee

    {
        "hash" : "0000[...]a2ee",
        "confirmations" : 289424,
        "size" : 490,
        "height" : 170,
        "version" : 1,
        "merkleroot" : "7dac[...]10ff",
        "tx" : [
            "b1fe[...]5082",
            "f418[...]9e16"
        ],
        "time" : 1231731025,
        "nonce" : 1889418792,
        "bits" : "1d00ffff",
        "difficulty" : 1.00000000,
        "previousblockhash" : "0000[...]bd55",
        "nextblockhash" : "0000[...]b4e0"
    }

Note: the only values above which are actually part of the block are size,
version, merkleroot, time, nonce, and bits. All other values shown
are computed.

The first transaction identifier (txid) listed in the tx array is, in
this case, the coinbase transaction. The txid is a hash of the raw
transaction. We can get the actual raw transaction in hexadecimal format
from the block chain using the `getrawtransaction` RPC with the txid:

    > getrawtransaction b1fea52486ce0c62bb442b530a3f0132b82\
      6c74e473d1f2c220bfa78111c5082

    01000000[...]00000000

We can expand the raw transaction hex into a human-readable format by
passing the raw transaction to the `decoderawtransaction` RPC:

    > decoderawtransaction 01000000010000000000000000000000\
      000000000000000000000000000000000000000000ffffffff070\
      4ffff001d0102ffffffff0100f2052a01000000434104d46c4968\
      bde02899d2aa0963367c7a6ce34eec332b32e42e5f3407e052d64\
      ac625da6f0718e7b302140434bd725706957c092db53805b821a8\
      5b23a7ac61725bac00000000

    {
        "txid" : "b1fea[...]5082",
        "version" : 1,
        "locktime" : 0,
        "vin" : [
            {
                "coinbase" : "04ffff001d0102",
                "sequence" : 4294967295
            }
        ],
        "vout" : [
            {
                "value" : 50.00000000,
                "n" : 0,
                "scriptPubKey" : {
                    "asm" : "04d4[...]725b OP_CHECKSIG",
                    "hex" : "4104[...]5bac",
                    "reqSigs" : 1,
                    "type" : "pubkey",
                    "addresses" : [
                        "1PSSGeFHDnKNxiEyFrD1wcEaHr9hrQDDWc"
                    ]
                }
            }
        ]
    }

Note the vin (input) array includes a single transaction shown with a
coinbase parameter and the vout (output) spends the block reward of 50
bitcoins to a public key (not a standard hashed Bitcoin address).

## Transactions

<!-- reference tx (made by Satoshi in block 170): 
    bitcoind decoderawtransaction $( bitcoind getrawtransaction f4184fc596403b9d638783cf57adfe4c75c605f6356fbc91338530e9831e9e16 )
-->

<!-- SOMEDAY: we need more terms than just output/input to denote the
various ways the outputs/inputs are used, such as "prevout", "nextout",
"curout", "curin", "nextin".  (Is there any use for "previn"?)  Someday,
when I'm terribly bored, I should rewrite this whole transaction section
to use those terms and then get feedback to see if it actually helps. -harding -->

Transactions let users send bitcoins. Each transaction is constructed
out of several parts which enable both simple direct payments and
multiperson collaborations. This section will describe each part and
demonstrate how to use them together to build complete transactions.

To keep things simple, this section pretends coinbase transactions do
not exist. Coinbase transactions can only be created by Bitcoin miners
and they're an exception to many of the rules listed below. Instead of
pointing out the coinbase exception to each rule, we invite you to read
about coinbase transactions in the block chain section of this guide.

![The Parts Of A Transaction](/img/dev/en-tx-overview.svg)

The figure above shows the core parts of a Bitcoin transaction. Each
transaction has at least one input and one output. Each input spends the
bitcoins paid to a previous output. Each output then waits as an Unspent
Transaction Output (UTXO) until a later input spends it. When your
Bitcoin wallet tells you that you have a 100 millibit balance, it really
means that you have 100 millibits waiting in one or more UTXOs.

Each transaction is prefixed by a four-byte version number which tells
Bitcoin peers and miners which set of rules to use to validate it.  This
lets developers create new rules for future transactions without
invalidating previous transactions.

The figure below helps illustrate the other transaction features by
showing the workflow Alice uses to send Bob a transaction and which Bob
later uses to spend that transaction. Both Alice and Bob will use the
most common form of the standard Pay-To-Pubkey-Hash (P2PH) transaction
type. P2PH lets Alice spend millibits to a typical Bitcoin address,
and then lets Bob further spend those millibits using a simple
cryptographic key pair.

![P2PH Transaction Workflow](/img/dev/en-p2ph-workflow.svg)

Bob must generate a private/public key pair before Alice can create the
first transaction. Standard Bitcoin private keys are 256 bits of random
data. A copy of that data is deterministically transformed into a public
key. Because the transformation can be reliably repeated later, the
public key does not need to be stored.

The public key is then cryptographically hashed. This pubkey hash can
also be reliably repeated later, so it also does not need to be stored.
The hash obfuscates the public key, providing security against
unanticipated problems which might allow reconstruction of private keys
from public key data at some later point.


<!-- Editors: from here on I will typically use the terms "pubkey hash"
and "full public key" to provide quick differentiation between the
different states of a public key and to help the text better match the
space-constrained diagrams where "public-key hash" wouldn't fit. -harding -->


Bob provides the pubkey hash to Alice. Pubkey hashes are almost always
sent encoded as Bitcoin addresses, which are base-58 encoded strings
containing an address version number, the hash, and an error-correction
checksum to ensure accurate transmission. The address can be transmitted
through any medium, including one-way mediums which prevent the spender
from communicating with the recipient, and it can be further encoded
into another format, such as a QR code.

Once Alice has the address and decodes it back into a standard hash, she
can create the first transaction. She creates a standard P2PH
transaction output containing instructions which allow anyone to spend that
output if they can prove they control the private key corresponding to
Bob's hashed public key. These instructions are called the script.

Alice transmits the transaction and it is added to the block chain.
It becomes, for a time, an Unspent Transaction Output (UTXO) displayed
in the recipient's Bitcoin wallet software as a spendable balance.

When, some time later, Bob decides to spend the UTXO, he must create an
input which references the transaction Alice created by its hash, called
a Transaction Identifier (txid), and the specific output she used by its
index number (output index).  He must then create a scriptSig which
satisfies the conditions Alice placed in the previous output's script.

Bob does not need to communicate with Alice to do this; he must simply
prove to the Bitcoin peer-to-peer network that he can satisfy the
script's conditions.  For a P2PH-style output, Bob's scriptSig will
contain the following two pieces of data:

1. His full (unhashed) public key, so the script can check that it
   hashes to the same value as the hashed pubkey provided by Alice.

2. Data signed by his private key, called a signature, so the script can
   verify that Bob owns the private key which created the public key.

Bob's signature doesn't just prove Bob controls his private key; it also
makes the rest of his transaction tamper-proof so Bob can safely
transmit it over the peer-to-peer network.

<!-- Editors: please keep "amount of bitcoins" (instead of "number of
bitcoins") in the text below to match the text in the figure above.  -harding -->

As illustrated in the figure above, the data Bob signs includes the
txid and output index of the previous transaction, the previous
output's script, the script Bob creates which will let the next
recipient spend this transaction's output, and the amount of millibits to
spend to the next recipient. In essence, the entire transaction is
signed except for the scriptSig, which holds the full public key and the
signature itself.

After putting his signature and public key in the scriptSig, Bob
transmits the transaction to Bitcoin miners through the peer-to-peer
network. Each peer and miner independently validates the transaction
before relaying it further or attempting to include it in a new block of
transactions.

### P2PH Script Validation

The validation procedure requires evaluation of the script.  In a P2PH
script, the script is:

    OP_DUP OP_HASH160 <PubkeyHash> OP_EQUALVERIFY OP_CHECKSIG

The spender's input scriptSig is prefixed to the beginning of the
script. In a P2PH transaction, the scriptSig contains a signature (sig)
and full public key (pubkey), creating the following concatenation:

    <Sig> <PubKey> OP_DUP OP_HASH160 <PubkeyHash> OP_EQUALVERIFY OP_CHECKSIG

The script language is a
[Forth-derived](https://en.wikipedia.org/wiki/Forth_%28programming_language%29)
stack-based language deliberately designed to be stateless and not
Turing complete. Statelessness ensures that once a transaction is added
to the block chain, there is no condition which renders it permanently
unspendable. Turing-incompleteness (specifically, a lack of loops or
gotos) makes the script language less flexible and more predictable,
greatly simplifying the security model.

<!-- Editors: please do not substitute for the words push or pop in
sections about stacks. These are programming terms. Also "above",
"below", "top", and "bottom" are commonly used relative directions or
locations in stack descriptions. -harding -->

To test whether the transaction is valid, scriptSig and script arguments
are pushed to the stack one item at a time, starting with Bob's scriptSig
and continuing to the end of Alice's script. The figure below shows the
evaluation of a standard P2PH script; below the figure is a description
of the process.

![P2PH Stack Evaluation](/img/dev/en-p2ph-stack.svg)

* The signature (from Bob's scriptSig) is added (pushed) to an empty stack.
  Because it's just data, nothing is done except adding it to the stack.
  The public key (also from the scriptSig) is pushed on top of the signature.

* From Alice's script, the `OP_DUP` operation is pushed. `OP_DUP` replaces
  itself with a copy of the data from one level below it---in this
  case creating a copy of the public key Bob provided.

* The operation pushed next, `OP_HASH160`, replaces itself with a hash
  of the data from one level below it---in this case, Bob's public key.
  This creates a hash of Bob's public key.

* Alice's script then pushes the pubkey hash that Bob gave her for the
  first transaction.  At this point, there should be two copies of Bob's
  pubkey hash at the top of the stack.

* Now it gets interesting: Alice's script adds `OP_EQUALVERIFY` to the
  stack. `OP_EQUALVERIFY` expands to `OP_EQUAL` and `OP_VERIFY` (not shown).

    `OP_EQUAL` (not shown) checks the two values below it; in this
    case, it checks whether the pubkey hash generated from the full
    public key Bob provided equals the pubkey hash Alice provided when
    she created transaction #1. `OP_EQUAL` then replaces itself and
    the two values it compared with the result of that comparison:
    zero (*false*) or one (*true*).

    `OP_VERIFY` (not shown) checks the value immediately below it. If
    the value is *false* it immediately terminates stack evaluation and
    the transaction validation fails. Otherwise it pops both itself and
    the *true* value off the stack.

* Finally, Alice's script pushes `OP_CHECKSIG`, which checks the
  signature Bob provided against the now-authenticated public key he
  also provided. If the signature matches the public key and was
  generated using all of the data required to be signed, `OP_CHECKSIG`
  replaces itself with *true.*

If *true* is at the top of the stack after the script has been
evaluated, the transaction is valid (provided there are no other
problems with it).

### Signature Hash Types

`OP_CHECKSIG` extracts a non-stack argument from each signature it
evaluates, allowing the signer to decide which parts of the transaction
to sign. Since the signature protects those parts of the transaction
from modification, this lets signers selectively choose to let other
people modify their transactions.

Because signatures are hashes, the various options for what to sign are
called signature hash types. There are three base SIGHASH types
currently available:

* `SIGHASH_ALL`, the default, signs all the inputs and outputs,
  protecting everything except the scriptSig against modification.

* `SIGHASH_NONE` signs all of the inputs but none of the outputs,
  allowing signers of other inputs to change where the bitcoins
  are going.

* `SIGHASH_SINGLE` signs only this input and only one corresponding
  output, ensuring nobody can change your part of the transaction but
  allowing other signers to change their part of the transaction.

The base types can be modified with the SIGHASH_ANYONECANPAY (anyone can
pay) flag, creating three new combined types:

* `SIGHASH_ALL|SIGHASH_ANYONECANPAY` signs all of the outputs but only
  this one input, and it also allows anyone to add or remove other
  inputs, so anyone can contribute additional payments but they cannot
  change how many millibits are sent nor where they go.

* `SIGHASH_NONE|SIGHASH_ANYONECANPAY` signs only this one input and
  allows anyone to add or remove other inputs or outputs, so anyone who
  gets a copy of this input can spend it however they'd like.

* `SIGHASH_SINGLE|SIGHASH_ANYONECANPAY` signs only this input and only
  one corresponding output, but it also allows anyone to add or remove
  other inputs.

Because each input is signed, a transaction with multiple inputs can
have multiple hash types signing different parts of the transaction. For
example, a single-input transaction signed with `NONE` could have its
output changed by the miner who adds it to the block chain. On the other
hand, if a two-input transaction has one input signed with `NONE` and
one input signed with `ALL`, the `ALL` signer can choose where to spend
the bitcoins without consulting the `NONE` signer---but nobody else can
modify the transaction.

<!-- TODO: describe useful combinations maybe using a 3x3 grid;
do something similar for the multisig section with different hashtypes
between different sigs -->

<!-- TODO: add to the technical section details about what the different
hash types sign, including the procedure for inserting the subscript -->

### Locktime And Sequence Number

One thing all signature hash types sign is the transaction's locktime.
The locktime indicates the earliest time a transaction can be added to
the block chain.  

Locktime allows signers to create time-locked transactions which will
only become valid in the future, giving the signers a chance to change
their minds.

If any of the signers change their mind, they can create a new
non-locktime transaction. The new transaction will use, as one of
its inputs, one of the same outputs which was used as an input to
the locktime transaction. This makes the locktime transaction
invalid if the new transaction is added to the block chain before
the time lock expires.

Care must be taken near the expiry time of a time lock. The peer-to-peer
network allows times on the block chain to be up to two hours ahead of
real time, so a locktime transaction can be added to the block chain up
to two hours before its time lock officially expires. Also, blocks are
not created at guaranteed intervals, so any attempt to cancel a valuable
transaction should be made a few hours before the time lock expires.

Previous versions of Bitcoin Core provided a feature which prevented
transaction signers from using the method described above to cancel a
time-locked transaction, but a necessary part of this feature was
disabled to prevent DOS attacks. A legacy of this system are four-byte
sequence numbers in every input. Sequence numbers were meant to allow
multiple signers to agree to update a transaction; when they finished
updating the transaction, they could agree to set every input's
sequence number to the four-byte unsigned maximum (0xffffffff),
allowing the transaction to be added to a block even if its time lock
had not expired.

Even today, setting all sequence numbers to 0xffffffff (the default in
Bitcoin Core) can still disable the time lock, so if you want to use
locktime, at least one input must have a sequence number below the
maximum. Since sequence numbers are not used by the network for any
other purpose, setting any sequence number to zero is sufficient to
enable locktime.

Locktime itself is an unsigned 4-byte number which can be parsed two ways:

* If less than 500 million, locktime is parsed as a block height. The
  transaction can be added to any block which has this height or higher.

* If greater than or equal to 500 million, locktime is parsed using the
  Unix epoch time format (the number of seconds elapsed since
  1970-01-01T00:00 UTC---currently over 1.395 billion). The transaction
  can be added to any block whose block header's *time* field is greater
  than the locktime.

### Multisig And Pay-To-Script-Hash (P2SH)

Outputs can use their script to require signatures from more than one
private key, called multi-signature or multisig.  A multisig script
provides a list of public keys and indicates how many of those public keys 
must match signatures in the input's scriptSig.  

A standard multisig transaction looks similar to the pay-to-pubkey-hash
shown above, except that full public keys (not hashes) are provided and
`OP_CHECKMULTISIG` is used instead plain checksig.
`OP_CHECKMULTISIG` takes multiple public keys and multiple
signatures, so it's necessary to tell it how many public keys are
being provided (n) and how many signatures are required (m). See the
prototype script below for an example:

    m [pubkey] [pubkey...] n OP_CHECKMULTISIG

The values m and n would be replaced with numbers, such as 2 and 2 for
an output which could only be spent if two key pairs were used, or 2
and 3 for an output which requires signatures from only two of the
public keys listed. For example, a 2-of-3 script:

    2 [pubkey] [pubkey] [pubkey] 3 OP_CHECKMULTISIG

Recipients who want their bitcoins to be secured with multiple
signatures outputs must get the spender to create a multisig script.
This creates several problems:

1. The spender must collect each of the full public keys to be used,
   which is more complicated than collecting a single Bitcoin address.
   Almost none of the existing add-on Bitcoin payment tools, such as QR
   encoded addresses, currently work with multisig.

2. The spender must pay the transaction fee, which is partly based on
   the number of bytes in a transaction.  Each additional public key in
   a multisig script increases the size of that transaction by at least 65 bytes,
   possibly costing the spender more millibits but providing all the
   benefit to the recipient.

3. Including full public keys in a script is not as secure as including
   public keys protected by a hash. As mentioned earlier, the hash
   obfuscates the public key, providing security against unanticipated
   problems which might allow reconstruction of private keys from public
   key data at some later point.

To solve these problems, pay-to-script-hash (P2SH) transactions were
created in 2012 to let a spender create an output script containing a
hash of a second script, the redeemScript. This solves each of the
problems quite handily:

1. The hash of the redeemScript is identical to a pubkey hash---so it
   can be transformed into the standard Bitcoin address format with only
   one small change to differentiate it from a standard address. This
   makes collecting a P2SH-style address as simple as collecting a
   P2PH-style address.

2. The hash of the redeemScript is the exact same size as a pubkey
   hash, so the spender won't need to increase the transaction fee no
   matter how many public keys are required.

3. The hash of the redeemScript obfuscates the public keys, so
   P2SH scripts are as secure as P2PH scripts.

The basic P2SH workflow, illustrated below, looks almost identical to
the P2PH workflow.  Bob no longer provides a pubkey hash to Alice;
instead he embeds his public key in a redeemScript, hashes
the redeemScript, and provides the redeemScript hash to Alice.  Alice creates
a P2SH-style output containing Bob's redeemScript hash.

![P2SH Transaction Workflow](/img/dev/en-p2sh-workflow.svg)

When Bob wants to spend the output, he provides the full redeemScript
along with his signature in the normal input scriptSig. The
peer-to-peer network ensures the full redeemScript hashes to the
same value as the script hash Alice put in her output; it then processes the
redeemScript exactly as it would if it were the primary script, letting
Bob spend the output if the redeemScript returns true.

The extra steps seen in the example above don't really help Bob when he
could just create a P2PH script instead. But when Bob's business
partner, Charlie, decides he wants all of their business income to
require two signatures to spend, P2SH-style outputs become quite handy.

As seen in the figure below, Bob and Charlie each create separate
private and public keys on their own computers, and Charlie gives a copy
of his public key to Bob. Bob then creates a multisig redeemScript
using the both his and Charlie's public keys.  When Alice, one their
clients, wants to pay an invoice, Bob gives her a hash of the redeemScript.

![P2SH 2-of-2 Multisig Transaction Workflow](/img/dev/en-p2sh-multisig-workflow.svg)

Because it's just a hash, Alice can't see what the script says.  But she
doesn't care---she just knows that Bob and Charlie will mark her invoice
as paid if she pays to that hash.

When Bob and Charlie want to spend Alice's output, Bob creates
transaction #2. He fills in the output details and creates a scriptSig
containing his signature, a placeholder byte, and the redeemScript. Bob
gives this incomplete transaction to Charlie, who checks the output
details and replaces the placeholder byte with his own signature,
completing the signature. Either Bob or Charlie can transmit this
fully-signed transaction to the peer-to-peer network.

Previous P2PH and P2SH illustrations showed Bob signing using the
`SIGHASH_ALL` procedure, but this multisig P2SH figure does not
illustrate any particular hash type procedure. Bob and Charlie can each
independently choose their own signature types. For example, if the
output created by Alice contains only a few millibits and Charlie
doesn't care how Bob spends it, Charlie can sign the second
transaction's input with `SIGHASH_NONE` and give it back to Bob. Bob can
now change the output script to anything he wants without further
consulting Charlie.

A lone NONE hash type would usually allow unscrupulous miners to modify
the output to pay themselves.  But because the multisig input requires
both Charlie and Bob's signatures, Bob can sign his signature with
`SIGHASH_ALL` to fully protect the transaction.

### Standard Transactions

Although you can put any output script inside a redeemScript and
then pay millibits to the corresponding redeeemScript hash, care must be
taken to avoid non-standard output scripts. As of Bitcoin Core 0.9, the
standard output script types are:

* Pubkey
* Pubkey hash (P2PH)
* Script hash (P2SH)
* Multisig
* Null Data

Pubkey scripts are a simplified form of the P2PH script; they're used in
all coinbase transactions, but they aren't as secure as P2PH, so they
generally aren't used elsewhere.  Null data scripts let you add
a small amount of arbitrary data to the block chain in exchange for
paying a transaction fee, but doing so is officially discouraged by the
Bitcoin Core Developers.  (Null data is a standard script type only
because some people were adding data to the block chain in more harmful
ways.)

If you use anything besides a standard script in an output, peers
and miners using the default Bitcoin Core settings will neither
accept, relay, nor mine your transaction. When you try to transmit
your transaction to a peer running the default settings, you will
receive an error.

<!-- TODO: I've received errors when I tried to do something stupid, but
are there any cases where default peers accept a non-standard tx and then
silently drop it? -harding -->

But if you create a non-standard redeemScript, hash it, and use the hash
in a P2SH output, the network sees only the hash, so it will accept the
output as valid no matter what the redeemScript says. When you go to
spend that output, however, peers and miners using the default settings
will see the non-standard redeemScript and reject it. It will be
impossible to spend that output until you find a miner who disables the
default settings.

As of Bitcoin 0.9, standard transactions must also meet the following
conditions:

* The transaction must be finalized: either its locktime must be in the
  past (or equal to the current block height), or all of its sequence
  numbers must be 0xffffffff.

* The transaction must be smaller than 100,000 bytes. That's around 200
  times larger than a typical single-input, single-output P2PH
  transaction.

* Each of the transaction's inputs must be smaller than 500 bytes.
  That's large enough to allow 3-of-3 multisig transactions in P2SH.
  Multisig transactions which require more than 3 key pairs are
  currently non-standard.

* The transaction's scriptSig must only push data to the script
  evaluation stack. It cannot push new OP codes, with the exception of
  OP codes which solely push data to the stack.

<!-- what's a canonical push?  It's forbidden:
https://github.com/bitcoin/bitcoin/blob/acfe60677c9bb4e75cf2e139b2dee4b642ee6a0c/src/main.cpp#L527
-->

<!-- I don't understand what this is testing:
https://github.com/bitcoin/bitcoin/blob/acfe60677c9bb4e75cf2e139b2dee4b642ee6a0c/src/main.cpp#L536
-->

* If any of the transaction's outputs spend less than a minimal value
  (currently 5,430 satoshis---0.05 millibits), the transaction must pay
  a minimum transaction fee (currently 0.1 millibits).

### Transaction Fees And Change

Transactions typically pay transaction fees based on the total byte size
of the signed transaction.  The transaction fee is given to the
Bitcoin miner, as explained in the block chain section, and so it is
ultimately up to each miner to choose the minimum transaction fee they
will accept.

<!-- TODO: check: 50 KB or 50 KiB?  Not that transactors care... -->

By default, miners reserve 50 KB of each block for high-priority
transactions which spend millibits that haven't been spent for a long
time.  The remaining space in each block is allocated to transactions
based on their fee per byte, with higher-paying transactions being added
in sequence until all of the available space is filled.

As of Bitcoin Core 0.9, transactions which do not count as high priority
need to pay a minimum fee of 0.01 millibits to be relayed across the
network.  Any transaction paying the minimum fee should be prepared to
wait a long time before there's enough spare space in a block to include
it.  Please see the block chain section about confirmations for why this
could be important.

Since each transaction spends Unspent Transaction Outputs (UTXOs) and
because a UTXO can only be spent once, the full value of the included
UTXOs must be spent or given to a miner as a transaction fee.  Few
people will have UTXOs that exactly match the amount they want to pay,
so most transactions include a change output.

Change outputs are regular outputs which spend the surplus millibits
from the UTXOs back to the spender.  They can reuse the same P2PH pubkey hash
or P2SH script hash as was used in the UTXO, but for the reasons
described in the next section, it is highly recommended that change be
sent to a new P2PH or P2SH address.

### Key Pair Reuse

When possible, you should avoid signing more than one transaction with
the same private key. Although the theory behind the signing system
Bitcoin uses, ECDSA, has been widely peer reviewed without any
real-world problems being found, actual implementations (such as
the one used by Bitcoin Core) are occasionally found vulnerable to
various attacks.

Bitcoin was designed to anticipate these possible vulnerabilities by
letting you obfuscate ECDSA public keys with a SHA256 hash in either the
P2PH or P2SH transaction types. SHA256 has been as widely peer reviewed
as ECDSA and is based on different principles, nearly eliminating the
chance of both ECDSA and SHA256 becoming vulnerable at the same time.

However, when you sign a transaction, you reveal your full public key
without any SHA256 protection.  Worse, you provide a signature made by
running data known to the attacker (the signed parts of the transaction)
through your ECDSA implementation along with your private key, which
could leak information about your private key.

According to the ECDSA theory, this doesn't matter much. But in a world
where researchers occasionally find flaws in ECDSA implementations and
the random number generators used to produce private keys, signing a
transaction puts you in a more exposed position than before you created
the signature.

Again, Bitcoin was designed to anticipate this situation.  There is no
technical reason you should ever need to use the same private key in
more than one transaction.  Creating a new private key costs you nothing
but some bits from your computer's pool of randomness.

There is, however, one major non-technical reason which may drive you
into using the same private key more than once: reusable Bitcoin
addresses. As explained previously, each Bitcoin address is the hash of
a public key derived from your private key. If you paste your address
on your website, give it to your clients, or put it in a QR code
printed on your shirt, you will likely end up using your private key
multiple times.

Millibits sent to those previously-spent addresses are less safe than
millibits sent to a brand new address, so we encourage you to build your
applications to avoid address reuse and, when possible, to discourage
users from reusing addresses. If your application needs to provide a
fixed URI to which payments should be sent, please see Bitcoin
Improvement Protocol (BIP) #72, the [URI Extensions For Payment
Protocol](https://github.com/bitcoin/bips/blob/master/bip-0072.mediawiki)
(still in draft as of this writing).

<!-- TODO: stealth addresses should be mentioned somewhere too. -->

### Contracts

By making the system hard to understand, the complexity of transactions
has so far worked against you. That changes with contracts. Contracts are
transactions built out of the tools described above which use the
decentralized Bitcoin system to enforce financial agreements.

In the multisig section, you saw an example of a contract. Bob and
Charlie received millibits to an output which required both of their
signatures to spend. Spending those millibits without both Bob and
Charlie's private keys is impossible.

Bitcoin contracts can often be crafted to minimize dependency on outside
agents, such as the court system, which significantly decreases the risk
of dealing with unknown entities in financial transactions. For example,
Bob and Charlie might only know each other casually over the Internet;
they would never open a checking account together---one of them could
pass bad checks, leaving the other on the hook. But with Bitcoin
contracts, they can nearly eliminate the risk from their relationship
and start a business even though they hardly know each other.

The following subsections will describe a variety of Bitcoin contracts
already in use. Because contracts deal with real people, not just
transactions, they are framed in story format.

Besides the contract types described below, many other contract types
have been proposed. Several of them are collected on the [Contracts
page](https://en.bitcoin.it/wiki/Contracts) of the Bitcoin Wiki.

#### Escrow And Arbitration Contracts

Bob and Charlie have a nasty falling out and want to terminate their
business, but they can't agree how to split their saved millibits, which
are stored in 2-of-2 multisig outputs. They both trust Alice The Arbitrator
to sort the issue out---but they're each worried that the other person
won't abide by any ruling Alice makes. The losing party might even
delete his private key out of spite so the millibits are lost forever.

The common escrow contract fixes this mess. Alice creates a new 2-of-3
multisig redeemScript and sends it to both Bob and Charlie for
examination. The redeemScript requires Alice, Bob, and Charlie each
provide a public key, with signatures from any two of those public keys
satisfying the redeemScript conditions.

Bob and Charlie each understands the implication: Alice will be able to
sign a transaction which will be valid if either Bob or Charlie also
signs it. Alice can't steal their millibits, so there's no new risk, but she
can give the winning party the ability to enforce her ruling.

All three of them then give their public keys to each other and
independently hash the redeemScript, creating a P2SH address. Then Bob
and Charlie together sign a transaction spending all of their shared
millibits to that P2SH address.

Alice looks at the business's books and makes a ruling. She creates and
signs a transaction that spends 60% of the millibits to Bob's public key
and 40% to Charlie's public key. 

Either Bob and Charlie can sign the transaction and transmit it to the
peer-to-peer network, actually spending the millibits, or they can both
decide they don't like Alice's ruling, find a new arbitrator, and
repeat the procedure.

Merchants can use the 2-of-3 escrow contract to get customers to trust
them. Customers choose what they want to buy, but instead of paying
the merchant directly, they spend their millibits to a 2-of-3 P2SH
multisig output using one public key each from the customer, the
merchant, and an arbitrator both the customer and merchant trust.

If the product or service is provided as expected, the customer and the
merchant work together to release the payment to the merchant.  If the
merchant needs to offer a refund, he and the customer work together to
release the payment to the customer.  If there's a dispute, the
arbitrator makes a ruling and either the customer or the merchant signs
it to release the payment according to the ruling.

**Resource:** [BitRated](https://www.bitrated.com/) provides a multisig arbitration
service interface using HTML/JavaScript on a GNU AGPL-licensed website.


#### Micropayment Channel Contracts

Alice also works part-time moderating forum posts for Bob. Every time
someone posts to Bob's busy forum, Alice skims the post to make sure it
isn't offensive or spam. Alas, Bob often forgets to pay her, so Alice
demands to be paid immediately after each post she approves or rejects.
Bob says he can't do that because hundreds of small payments will cost
him dozens of millibits in transaction fees, so Alice suggests they use a
micropayment channel.

Bob asks Alice for her public key and then creates two transactions.
The first transaction pays 100 millibits to a P2SH output whose
2-of-2 multisig redeemScript requires signatures from both Alice and Bob.
Broadcasting this transaction would let Alice hold the millibits
hostage, so Bob keeps this transaction private for now and creates a
second transaction.

The second transaction spends all of the first transaction's millibits
(minus a transaction fee) back to Bob after a 24 hour delay enforced
by locktime. Bob can't sign the transaction by himself, so he gives
the second transaction to Alice to sign, as shown in the
illustration below.

![Micropayment Channel Example](/img/dev/en-micropayment-channel.svg)

Alice checks that the second transaction's locktime is 24 hours in the
future, signs it, and gives a copy of it back to Bob. She then asks Bob
for the first transaction and checks that the second transaction spends
the output of the first transaction. She can now broadcast the first
transaction to the network to ensure Bob has to wait for the time lock
to expire before further spending his millibits. Bob hasn't actually
spent anything so far, except possibly a small transaction fee, and
he'll be able to broadcast the second transaction in 24 hours for a
full refund.

Now, when Alice does some work worth 1 millibit, she asks Bob to create
and sign a new version of the second transaction.  Version two of the
transaction spends 1 millibit to Alice and the other 99 back to Bob; it does
not have a locktime, so Alice can sign it and spend it whenever she
wants.  (But she doesn't do that immediately.)

Alice and Bob repeat these work-and-pay steps until Alice finishes for
the day, or until the time lock is about to expire.  Alice signs the
final version of the second transaction and broadcasts it, paying
herself and refunding any remaining balance to Bob.  The next day, when
Alice starts work, they create a new micropayment channel.

If Alice fails to broadcast a version of the second transaction before
its time lock expires, Bob can broadcast the first version and receive a
full refund. This is one reason micropayment channels are best suited to
small payments---if Alice's Internet service goes out for a few hours
near the time lock expiry, she could be cheated out of her payment.

Transaction malleability, discussed below in the Payment Security section,
is another reason to limit the value of micropayment channels.
If someone uses transaction malleability to break the link between the
two payments, Alice could hold Bob's 100 millibits hostage even if she
hadn't done any work.

For larger payments, Bitcoin transaction fees are very low as a
percentage of the total transaction value, so it makes more sense to
protect payments with immediately-broadcast separate transactions.

**Resource:** The [bitcoinj](https://code.google.com/p/bitcoinj/) Java library
provides a complete set of micropayment functions, an example
implementation, and [a
tutorial](https://code.google.com/p/bitcoinj/wiki/WorkingWithMicropayments)
all under an Apache license.

#### CoinJoin Contracts 

Alice is concerned about her privacy.  She knows every transaction gets
added to the public block chain, so when Bob and Charlie pay her, they
can each easily track those millibits to learn what Bitcoin
addresses she pays, how much she pays them, and possibly how many
millibits she has left.

Because Alice isn't a criminal, she doesn't want to use some shady
Bitcoin laundering service; she just wants plausible deniability about
where she has spent her bitcoins and how many she has left, so she
starts up the Tor anonymity service on her computer and logs into an
IRC chatroom as "AnonGirl."

Also in the chatroom are "Nemo" and "Neminem."  They collectively
agree to transfer millibits between each other so no one besides them
can reliably determine who controls which millibits.  But they're faced
with a dilemma: who transfers their millibits to one of the other two
pseudonymous persons first? The CoinJoin-style contract, shown in the
illustration below, makes this decision easy: they create a single
transaction which does all of the spending simultaneously, ensuring none
of them can steal the others' millibits.

![Example CoinJoin Transaction](/img/dev/en-coinjoin.svg)

Each contributor looks through their collection of Unspent Transaction
Outputs (UTXOs) for 100 millibits they can spend. They then each generate
a brand new public key and give UTXO details and pubkey hashes to the
facilitator.  In this case, the facilitator is AnonGirl; she creates
a transaction spending each of the UTXOs to three equally-sized outputs.
One output goes to each of the contributors' pubkey hashes.

AnonGirl then signs her inputs using `SIGHASH_ALL` to ensure nobody can
change the input or output details.  She gives the partially-signed
transaction to Nemo who signs his inputs the same way and passes it
to Neminem, who also signs it the same way.  Neminem then broadcasts
the transaction to the peer-to-peer network, mixing all of the millibits in
a single transaction.

As you can see in the illustration, there's no way for anyone besides
AnonGirl, Nemo, and Neminem to confidently determine who received
which output, so they can each spend their output with plausible
deniability.

Now when Bob or Charlie try to track Alice's transactions through the
block chain, they'll also see transactions made by Nemo and
Neminem.  If Alice does a few more CoinJoins, Bob and Charlie might
have to guess which transactions made by dozens or hundreds of people
were actually made by Alice.

The complete history of Alice's millibits is still in the block chain,
so a determined investigator could talk to the people AnonGirl
CoinJoined with to find out the ultimate origin of her millibits and
possibly reveal AnonGirl as Alice. But against anyone casually browsing
block chain history, Alice gains plausible deniability.

The CoinJoin technique described above costs the participants a small
amount of millibits to pay the transaction fee.  An alternative
technique, purchaser CoinJoin, can actually save them millibits and
improve their privacy at the same time.

AnonGirl waits in the IRC chatroom until she wants to make a purchase.
She announces her intention to spend millibits and waits until someone
else wants to make a purchase, likely from a different merchant. Then
they combine their inputs the same way as before but set the outputs
to the separate merchant addresses so nobody will be able to figure
out solely from block chain history which one of them bought what from
the merchant.

Since they would've had to pay a transaction fee to make their purchases
anyway, AnonGirl and her co-spenders don't pay anything extra---but
because they reduced overhead by combining multiple transactions, saving
bytes, they may be able to pay a smaller aggregate transaction fee,
saving each one of them a tiny amount of millibits.

**Resource:** An alpha-quality (as of this writing) implementation of decentralized
CoinJoin is [CoinMux](http://coinmux.com/), available under the Apache
license. A centralized version of purchaser CoinJoin is available at the
[SharedCoin](https://sharedcoin.com/) website (part of Blockchain.info),
whose [implementation](https://github.com/blockchain/Sharedcoin) is
available under the 4-clause BSD license.


### Transaction Malleability

Some contracts are especially susceptible to transaction malleability,
the ability to modify a transaction without making it invalid. The
issue also affects block-chain-based accounting systems which need to
track payments.

None of Bitcoin's signature hash types protect the scriptSig. The
scriptSig contains the signature, which can't sign itself. This allows
attackers to make non-functional modifications to a transaction without
rendering it invalid. For example, an attacker can add some data to the
scriptSig which will be dropped before the previous output script is
processed.

Although the modifications are non-functional---so they do not change
what inputs the transaction uses nor what outputs it pays---they do
change the computed hash of the transaction. Since each transaction
links to previous transactions using hashes as a transaction
identifier (txid), a modified transaction will not have the txid its
creator expected.

This isn't a problem for most Bitcoin transactions which are designed to
be added to the block chain immediately. But it does become a problem
for multi-transaction contracts, such as the micropayment channel
contract, which depend on transactions that have not yet been added to
the block chain.

Bitcoin developers have been working to reduce transaction malleability
among standard transaction types, and improvements incorporated in
Bitcoin Core 0.9 should make malleability only a minor concern. At
present, contracts should be designed to minimize malleability risk, and
high-value (or otherwise high-risk) agreements should not use
multi-transaction contracts.

Transaction malleability also affects payment tracking.  Bitcoin Core's
RPC interface lets you track transactions by their txid---but if that
txid changes because the transaction was modified, it may appear that
the transaction has disappeared from the network.

Current best practices for transaction tracking dictate that a
transaction should be tracked by the transaction outputs (UTXOs) it
spends as inputs, as they cannot be changed without invalidating the
transaction.

<!-- TODO/harding: The paragraph above needs practical advice about how
to do that. I'll need to find some time to look at somebody's wallet
code. -harding -->

Best practices further dictate that if a transaction does seem to
disappear from the network and needs to be reissued, that it be reissued
in a way that invalidates the lost transaction. One method which will
always work is to ensure the reissued payment spends all of the same
outputs that the lost transaction used as inputs.

### Transaction Reference

The following subsections briefly document core transaction details.

#### Standard Transactions

The standard transactions use the following scripts and scriptSigs.  Each of the
standard scripts can also be used inside a P2SH redeemScript, but in practice
only the multisig script makes sense inside P2SH until more transactions
types are made standard.

* Pay To PubKey (used in coinbase transactions):

        script: <pubkey> OP_CHECKSIG
        scriptSig: <sig>

* Pay To PubKey Hash (P2PH):

        script: OP_DUP OP_HASH160 <PubKeyHash> OP_EQUALVERIFY OP_CHECKSIG
        scriptSig: <sig> <pubkey> 

* Pay To Script Hash (P2SH)

        script: OP_HASH160 <redeemscripthash> OP_EQUAL
        scriptSig: <sig> [sig] [sig...] <redeemscript>

* Multisig (*m* is the number of pubkeys which must match a signature;
  *n* is how many pubkeys are being provided)

        script: <m> <pubkey> [pubkey] [pubkey...] <n> OP_CHECKMULTISIG
        scriptSig: OP_0 <sig> [sig] [sig...]

* Null data

        script: OP_RETURN <data>
        (Null data scripts cannot be spent, so there's no scriptSig)

Although it's not a separate transaction type, this is a P2SH multisig
with 2-of-3:

        script: OP_HASH160 <redeemscripthash> OP_EQUAL
        scriptSig: <sig> <sig> <redeemscript>
        redeemScript: OP_0 <2> <pubkey> <pubkey> <pubkey> <3> OP_CHECKMULTISIG

**OP Codes**

The op codes used in standard transactions are,

* Various data pushing op codes from 0x00 to 0x60 (1--96). These haven't
  been shown in the examples above, but they must be used to push
  signatures and pubkeys onto the stack. See the link below this list
  for a description.

* `OP_CHECKSIG` consumes a signature and a full public key, and
  returns true if they were both made by the same ECDSA private key.
  Otherwise, it returns false.

* `OP_DUP` returns a copy of the item on the stack below it.

* `OP_HASH160` consumes the item on the stack below it and returns with
  a RIPEMD-160(SHA256()) hash of that item.

* `OP_EQUAL` consumes the two items on the stack below it and returns
  true if they are the same.  Otherwise, it returns false.

* `OP_VERIFY` consumes one value and returns nothing, but it will
  terminate the script in failure if the value consumed is zero (false).

* `OP_EQUALVERIFY` runs `OP_EQUAL` and then `OP_VERIFY` in sequence.

* `OP_CHECKMULTISIG` consumes the value (n) at the top of the stack,
  consumes that many of the next stack levels (public keys), consumes
  the value (m) now at the top of the stack, and consumes that many of
  the next values (signatures) plus one extra value. Then it compares
  each of public keys against each of the signatures looking for ECDSA
  matches; if n of the public keys match signatures, it returns true.
  Otherwise, it returns false.

    The "one extra value" it consumes is the result of an off-by-one
    error in the implementation. This value is not used, so standard
    scriptSigs prefix the signatures with a single OP_0 (0x00, an empty
    array of bytes).

* `OP_RETURN` terminates the script in failure. However, this will not
  invalidate a null-data-type transaction which contains no more than 40
  bytes following `OP_RETURN` no more than once per transaction.

A complete list of OP codes can be found on the Bitcoin Wiki [Script
Page](https://en.bitcoin.it/wiki/Script), with an authoritative list in the `opcodetype` enum of the
Bitcoin Core [script header
file](https://github.com/bitcoin/bitcoin/blob/master/src/script.h).

#### Conversion Of Hashes To Addresses And Vice-Versa

The hashes used in P2PH and P2SH outputs are commonly encoded as Bitcoin
addresses.  This is the procedure to encode those hashes and decode the
addresses.

First, get your hash.  For P2PH, you RIPEMD-160(SHA256()) hash a ECDSA
public key derived from your 256-bit ECDSA private key (random data).
For P2SH, you RIPEMD-160(SHA256()) hash a redeemScript serialized in the
format used in raw transactions (described in a following
sub-section).  Taking the resulting hash:

1. Add an address version byte in front of the hash.  The version
bytes commonly used by Bitcoin are:

    * 0x00 for P2PH addresses on the main Bitcoin network (mainnet)

    * 0x6f for P2PH addresses on the Bitcoin testing network (testnet)

    * 0x05 for P2SH addresses on mainnet

    * 0xc4 for P2SH addresses on testnet

2. Create a copy of the version and hash; then hash that twice with SHA256: `SHA256(SHA256(version . hash))`

3. Extract the four most significant bytes from the double-hashed copy.
   These are used as a checksum to ensure the base hash gets transmitted
   correctly.

4. Append the checksum to the version and hash, and encode it as a base58
   string: `BASE58(version . hash . checksum)`
 
Bitcoin's base58 encoding may not match other implementations. Tier
Nolan provided the following example encoding algorithm to the Bitcoin
Wiki [Base58Check
encoding](https://en.bitcoin.it/wiki/Base58Check_encoding) page:


    code_string = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
    x = convert_bytes_to_big_integer(hash_result)

    output_string = ""

    while(x > 0) 
       {
           (x, remainder) = divide(x, 58)
           output_string.append(code_string[remainder])
       }

    repeat(number_of_leading_zero_bytes_in_hash)
       {
       output_string.append(code_string[0]);
       }

    output_string.reverse();

Bitcoin's own code can be traced using the [base58 header
file](https://github.com/bitcoin/bitcoin/blob/master/src/base58.h).

To convert addresses back into hashes, reverse the base58 encoding, extract
the checksum, repeat the steps to create the checksum and compare it
against the extracted checksum, and then remove the version byte.

#### Raw Transaction Format

Bitcoin transactions are transmitted between peers and stored in the
block chain in a serialized byte format, called raw format. Bitcoin Core
and many other tools print and accept raw transactions encoded as hex.

A sample raw transaction is the first non-coinbase transaction, made in
block 170.  To get the transaction, use the `getrawtransaction` RPC with
that transaction's txid (provided below):

    > getrawtransaction \
      f4184fc596403b9d638783cf57adfe4c75c605f6356fbc91338530e9831e9e16

    0100000001c997a5e56e104102fa209c6a852dd90660a20b2d9c352423e\
    dce25857fcd3704000000004847304402204e45e16932b8af514961a1d3\
    a1a25fdf3f4f7732e9d624c6c61548ab5fb8cd410220181522ec8eca07d\
    e4860a4acdd12909d831cc56cbbac4622082221a8768d1d0901ffffffff\
    0200ca9a3b00000000434104ae1a62fe09c5f51b13905f07f06b99a2f71\
    59b2225f374cd378d71302fa28414e7aab37397f554a7df5f142c21c1b7\
    303b8a0626f1baded5c72a704f7e6cd84cac00286bee000000004341041\
    1db93e1dcdb8a016b49840f8c53bc1eb68a382e97b1482ecad7b148a690\
    9a5cb2e0eaddfb84ccf9744464f82e160bfa9b8b64f9d4c03f999b8643f\
    656b412a3ac00000000

A byte-by-byte analysis by Amir Taaki (Genjix) of this transaction is
provided below.  (Originally from the Bitcoin Wiki
[OP_CHECKSIG page](https://en.bitcoin.it/wiki/OP_CHECKSIG); Genjix's
text has been updated to use the terms used in this document.)

    01 00 00 00              version number
    01                       number of inputs (var_uint)

    input 0:
    c9 97 a5 e5 6e 10 41 02  previous tx hash (txid)
    fa 20 9c 6a 85 2d d9 06 
    60 a2 0b 2d 9c 35 24 23 
    ed ce 25 85 7f cd 37 04
    00 00 00 00              previous output index

    48                       size of script (var_uint)
    47                       push 71 bytes to stack
    30 44 02 20 4e 45 e1 69
    32 b8 af 51 49 61 a1 d3
    a1 a2 5f df 3f 4f 77 32
    e9 d6 24 c6 c6 15 48 ab
    5f b8 cd 41 02 20 18 15
    22 ec 8e ca 07 de 48 60
    a4 ac dd 12 90 9d 83 1c
    c5 6c bb ac 46 22 08 22
    21 a8 76 8d 1d 09 01
    ff ff ff ff              sequence number

    02                       number of outputs (var_uint)

    output 0:
    00 ca 9a 3b 00 00 00 00  amount = 10.00000000 BTC
    43                       size of script (var_uint)
    script for output 0:
    41                       push 65 bytes to stack
    04 ae 1a 62 fe 09 c5 f5 
    1b 13 90 5f 07 f0 6b 99 
    a2 f7 15 9b 22 25 f3 74 
    cd 37 8d 71 30 2f a2 84 
    14 e7 aa b3 73 97 f5 54 
    a7 df 5f 14 2c 21 c1 b7 
    30 3b 8a 06 26 f1 ba de 
    d5 c7 2a 70 4f 7e 6c d8 
    4c 
    ac                       OP_CHECKSIG

    output 1:
    00 28 6b ee 00 00 00 00  amount = 40.00000000 BTC
    43                       size of script (var_uint)
    script for output 1:
    41                       push 65 bytes to stack
    04 11 db 93 e1 dc db 8a  
    01 6b 49 84 0f 8c 53 bc 
    1e b6 8a 38 2e 97 b1 48 
    2e ca d7 b1 48 a6 90 9a
    5c b2 e0 ea dd fb 84 cc 
    f9 74 44 64 f8 2e 16 0b 
    fa 9b 8b 64 f9 d4 c0 3f 
    99 9b 86 43 f6 56 b4 12 
    a3                       
    ac                       OP_CHECKSIG

    00 00 00 00              locktime

#### Generating Transactions

Bitcoin Core's RPC interface provides a number of tools which help you
generate and sign transactions.  

TODO: this really needs to be it's own section (h2) which walks the developer
through creating basic wallet transactions, then creating raw P2PH txes
and P2SH multisig txes, then signing raw txes (including with
alternative hash types), then creating txes based on unbroadcast txes
for contracts, and then (finally) broadcasting raw txes and dealing with
possible errors.

<!--
TODO, Relevant links:

* [https://en.bitcoin.it/wiki/Transactions](https://en.bitcoin.it/wiki/Transactions)
* [https://en.bitcoin.it/wiki/Technical_background_of_Bitcoin_addresses](https://en.bitcoin.it/wiki/Technical_background_of_Bitcoin_addresses)
* [https://en.bitcoin.it/wiki/Script](https://en.bitcoin.it/wiki/Script)
* [https://en.bitcoin.it/wiki/Contracts](https://en.bitcoin.it/wiki/Contracts)
* [https://github.com/bitcoin/bips/blob/master/bip-0011.mediawiki (n of m transactions)](https://github.com/bitcoin/bips/blob/master/bip-0011.mediawiki)
* [https://github.com/bitcoin/bips/blob/master/bip-0013.mediawiki (P2SH)](https://github.com/bitcoin/bips/blob/master/bip-0013.mediawiki)
* [https://github.com/bitcoin/bips/blob/master/bip-0016.mediawiki (P2SH)](https://github.com/bitcoin/bips/blob/master/bip-0016.mediawiki)
-->

## Wallets

TODO, Relevant links:

* [https://en.bitcoin.it/wiki/Wallet](https://en.bitcoin.it/wiki/Wallet)
* [https://en.bitcoin.it/wiki/Wallet_import_format (private keys import format)](https://en.bitcoin.it/wiki/Wallet_import_format)
* [https://en.bitcoin.it/wiki/Private_key](https://en.bitcoin.it/wiki/Private_key)
* [https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki (HD / Deterministic wallets)](https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki)

### Private keys format

### Deterministic wallets formats

### JBOK (Just a bunch of keys) wallets formats (deprecated)

## Payment requests

TODO, Relevant links:

* [https://github.com/bitcoin/bips/blob/master/bip-0070.mediawiki (payment protocol)](https://github.com/bitcoin/bips/blob/master/bip-0070.mediawiki)
* [https://github.com/bitcoin/bips/blob/master/bip-0071.mediawiki (payment protocol MIME types)](https://github.com/bitcoin/bips/blob/master/bip-0071.mediawiki)

### Payment request API

### Scannable QR codes

### Clickable bitcoin: links

## Operating modes

TODO, Relevant links:

* [https://en.bitcoin.it/wiki/Thin_Client_Security (SPV / Simple Payment Verification)](https://en.bitcoin.it/wiki/Thin_Client_Security)
* [https://bitcointalk.org/index.php?topic=88208.0 (OUT / Unspent output tree)](https://bitcointalk.org/index.php?topic=88208.0)

### Full node

### SPV

### UOT (short overview?)

## P2P Network

TODO, Relevant links:

* [https://en.bitcoin.it/wiki/Network](https://en.bitcoin.it/wiki/Network)
* [https://github.com/bitcoin/bips/blob/master/bip-0037.mediawiki (Bloom filters)](https://github.com/bitcoin/bips/blob/master/bip-0037.mediawiki)

<!--

TODO, re-use relevant parts of this text

In the case of a bug or attack, bad news about Bitcoin spreads fast, so
merchants may hear about problems. The Bitcoin Foundation provides a
[Bitcoin alert service](https://bitcoin.org/en/alerts) with an RSS feed
and users of Bitcoin Core can check the error field of the `getinfo` RPC
results to get currently active alerts for their specific version of
Bitcoin Core.

-->

### Blocks broadcasting

### Transactions broadcasting

### Alerts

## Mining

TODO, Relevant links:

* [https://en.bitcoin.it/wiki/Getwork](https://en.bitcoin.it/wiki/Getwork)
* [https://github.com/bitcoin/bips/blob/master/bip-0022.mediawiki (getblocktemplate)](https://github.com/bitcoin/bips/blob/master/bip-0022.mediawiki)
* [https://github.com/bitcoin/bips/blob/master/bip-0023.mediawiki (getblocktemplate)](https://github.com/bitcoin/bips/blob/master/bip-0023.mediawiki)

### getblocktemplate

### getwork (deprecated, worth mentionning?)

Full block validation is best left to the Bitcoin Core software as any
failure by your program to validate blocks could make it reject blocks
accepted by the rest of the network, which may prevent your program from
detecting double spends -- and that means your program may accept double
spends as valid payment.

Simplified Payment Verification (SPV) is a greatly simplified form of
verification which can be reliably implemented by third-party Bitcoin
software because it operates mainly on block headers. It will be
described elsewhere in this guide.

<!--#md#</div>#md#-->

<script>updateToc();</script>
