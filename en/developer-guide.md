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
<a href="https://github.com/saivann/bitcoin.org/issues">open an issue</a>. If you want to write or edit a section, please read and comment on our <a href="https://bitcointalk.org/index.php?topic=511876">forum thread</a> or sign up for our <a href="https://groups.google.com/forum/?hl=en#!forum/bitcoin-documentation">mailing list</a>. This live preview is temporary and should eventually be merged on bitcoin.org .</p>

{% autocrossref %}

The Developer Guide aims to provide the information you need to start
building Bitcoin-based applications. To make the best use of this guide,
you may want to install the current version of Bitcoin Core, either from
[source][core git] or from a [pre-compiled executable][core executable].

Once installed, you'll have access to three programs: `bitcoind`,
`bitcoin-qt`, and `bitcoin-cli`.  When run with no arguments, all three
programs default to Bitcoin's main network (mainnet) which will require
you purchase satoshis in order to generate transactions.

However, for development, it's safer and cheaper to use Bitcoin's test
network (testnet) where the satoshis spent have no real-world value.
Testnet also relaxes some restrictions (such as standard transaction
checks) so you can test functions which might currently be disabled by
default on mainnet.  

To use testnet, use the argument `-testnet`<!--noref--> with each program or add
`testnet=1`<!--noref--> to your `bitcoin.conf` file.  To get
free satoshis for testing, use [Piotr Piasecki's testnet faucet][].
Testnet is a public resource provided for free by members of the
community, so please don't abuse it.  

You can speed up development further using the [regression test mode][]
which creates a new testnet local to your computer. This regtest mode
will let you generate blocks almost instantly with a RPC command so you
can generate your own satoshis and add transactions to the block chain
immediately.

* `bitcoin-qt` provides a combination full Bitcoin peer and wallet
  frontend. From the Help menu, you can access a console where you can
  enter the RPC commands used throughout this document.

* `bitcoind` is more useful for programming: it provides a full peer
  which you can interact with through RPCs to port 8332 (or 18332
  for testnet).

* `bitcoin-cli` allows you to send RPC commands to `bitcoind` from the
  command line.  For example, `bitcoin-cli getinfo`

All three programs get settings from `bitcoin.conf` in the `Bitcoin`
application directiory:

* Windows: `%APPDATA%\Bitcoin\`

* OSX: `$HOME/Library/Application Support/Bitcoin/`

* Linux: `$HOME/.bitcoin/`

Questions about Bitcoin development are best sent to the Bitcoin [Forum][forum
tech support] and [IRC channels][]. Errors or suggestions related to
documentation on Bitcoin.org can be [submitted as an issue][docs issue]
or posted to the [bitcoin-documentation mailing list][].

In the following guide, 
some strings have been shortened or wrapped: "[...]" indicates extra data was removed, and lines ending in a single backslash "\\" are continued below.
If you hover your mouse over a paragraph, cross-reference links will be
shown in blue.  If you hover over a cross-reference link, a brief
definition of the term will be displayed in a tooltip.

{% endautocrossref %}


## Block Chain

{% autocrossref %}
The block chain provides Bitcoin's public ledger, a timestamped record
of all confirmed transactions. This system is used to protect against double spending
and modification of previous transaction records, using proof of
work verified by the peer-to-peer network to maintain a global consensus.

This document provides detailed explanations about the functioning of
this system along with security advice for risk assessment and tools for
using block chain data.
{% endautocrossref %}

### Block Chain Overview
{% autocrossref %}

![Block Chain Overview](/img/dev/en-blockchain-overview.svg)

The figure above shows a simplified version of a three-block block chain.
A [block][]{:#term-block}{:.term} of new transactions, which can vary from one transaction to
over a thousand, is collected into the transaction data part of a block.
Copies of each transaction are hashed, and the hashes are then paired,
hashed, paired again, and hashed again until a single hash remains, the
[Merkle root][]{:#term-merkle-root}{:.term} of a Merkle tree.

The Merkle root is stored in the block header. Each block also
stores the hash of the previous block's header, chaining the blocks
together. This ensures a transaction cannot be modified without
modifying the block that records it and all following blocks.

Transactions are also chained together. Bitcoin wallet software gives
the impression that satoshis are sent from and to addresses, but
bitcoins really move from transaction to transaction. Each standard
transaction spends the satoshis previously spent in one or more earlier
transactions, so the input of one transaction is the output of a
previous transaction.

![Transaction Propagation](/img/dev/en-transaction-propagation.svg)

A single transaction can spend bitcoins to multiple outputs, as would be
the case when sending satoshis to multiple addresses, but each output of
a particular transaction can only be used as an input once in the
block chain. Any subsequent reference is a forbidden double
spend---an attempt to spend the same satoshis twice.

Outputs are not the same as Bitcoin addresses. You can use the same
address in multiple transactions, but you can only use each output once.
Outputs are tied to [transaction identifiers (TXIDs)][txid]{:#term-txid}{:.term}, which are the hashes
of complete transactions.

Because each output of a particular transaction can only be spent once,
all transactions included in the block chain can be categorized as either
[Unspent Transaction Outputs (UTXOs)][utxo]{:#term-utxo}{:.term} or spent transaction outputs. For a
payment to be valid, it must only use UTXOs as inputs.

Satoshis cannot be left in a UTXO after a transaction: they will be
irretrievably lost. So any difference between the number of bitcoins in a
transaction's inputs and outputs is given as a [transaction fee][]{:#term-transaction-fee}{:.term} to 
the Bitcoin [miner][]{:#term-miner}{:.term} who creates the block containing that transaction. 
For example, in the figure above, each transaction spends 10,000 satoshis (0.01 millibits)
fewer than it receives from its combined inputs, effectively paying a 10,000
satoshi transaction fee.

The spenders propose a transaction fee with each transaction; miners
decide whether the amount proposed is adequate, and only accept
transactions that pass their threshold. Therefore, transactions with a
higher proposed transaction fee are likely to be processed faster.
{% endautocrossref %}

#### Proof Of Work
{% autocrossref %}

The block chain is collaboratively maintained on a peer-to-peer network, so
Bitcoin requires each block prove a significant amount of work was invested in
its creation to ensure that untrustworthy peers who want to modify past blocks have
to work harder than trustworthy peers who only want to add new blocks to the
block chain.

The block chain magnifies the effect of this proof of work.
Chaining blocks together makes it impossible to modify transactions included
in any block without modifying all following blocks. As a
result, the cost to modify a particular block increases with every new block
added to the block chain.

The [proof of work][]{:#term-proof-of-work}{:.term} used in Bitcoin
takes advantage of the apparently random nature of cryptographic hashes.
A good cryptographic hash algorithm converts arbitrary data into a
seemingly-random number. If the data is modified in any way and
the hash re-run, a new seemingly-random number is produced, so there is
no way to modify the data to make the hash number predictable.

To prove you did some extra work to create a block, you must create a
hash of the block header which does not exceed a certain value. For
example, if the maximum possible hash value is <span
class="math">2<sup>256</sup> − 1</span>, you can prove that you
tried up to two combinations by producing a hash value less than <span
class="math">2<sup>256</sup> − 1</span>.

In the example given above, you will almost certainly produce a
successful hash on your first try. You can even estimate the probability
that a given hash attempt will generate a number below the [target][]{:#term-target}{:.term}
threshold. Bitcoin itself does not track probabilities but instead
simply assumes that the lower it makes the target threshold, the more
hash attempts, on average, will need to be tried.

New blocks will only be added to the block chain if their hash is at
least as challenging as a [difficulty][]{:#term-difficulty}{:.term} value expected by the peer-to-peer
network. Every 2,016 blocks, the network uses [timestamps][block time] stored in each
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

(Note: an off-by-one error in the Bitcoin Core implementation causes the
difficulty to be updated every 2,01*6* blocks using timestamps from only
2,01*5* blocks, creating a slight skew.)

Because each block header must hash to a value below the target
threshold, and because each block is linked to the block that
preceded it, it requires (on average) as much hashing power to
propagate a modified block as the entire Bitcoin network expended
between the time the original block was created and the present time.
Only if you acquired a majority of the network's hashing power
could you reliably execute such a [51 percent attack][]{:#term-51-attack}{:.term} against
transaction history.

The block header provides several easy-to-modify fields, such as a
dedicated [nonce field][header nonce], so obtaining new hashes doesn't require waiting
for new transactions. Also, only the 80-byte block header is hashed for
proof-of-work, so adding more bytes of transaction data to
a block does not slow down hashing with extra I/O.
{% endautocrossref %}

#### Block Height And Forking
{% autocrossref %}

Any Bitcoin miner who successfully hashes a block header to a value
below the target can add the entire block to the block chain.
(Assuming the block is otherwise valid.) These blocks are commonly addressed
by their [block height][]{:#term-block-height}{:.term}---the number of blocks between them and the first Bitcoin
block (block 0, most commonly known as the [genesis block]{:#term-genesis-block}{:.term}). For example,
block 2016 is where difficulty could have been first adjusted.

![Common And Uncommon Block Chain Forks](/img/dev/en-blockchain-fork.svg)

Multiple blocks can all have the same block height, as is common when
two or more miners each produce a block at roughly the same time. This
creates an apparent [fork][accidental fork]{:#term-accidental-fork}{:.term} in the block chain, as shown in the
figure above.

When miners produce simultaneous blocks at the end of the block chain, each
peer individually chooses which block to trust. (In the absence of
other considerations, discussed below, peers usually trust the first
block they see.)

Eventually miners produce another block which attaches to only one of
the competing simultaneously-mined blocks. This makes that side of
the fork longer than the other side. Assuming a fork only contains valid
blocks, normal peers always follow the longest fork (the most difficult chain
to recreate) and throw away ([orphan][]{:#term-orphan}{:.term}) blocks belonging to shorter forks.

[Long-term forks][long-term fork]{:#term-long-term-fork}{:.term} are possible if different miners work at cross-purposes,
such as some miners diligently working to extend the block chain at the
same time other miners are attempting a 51 percent attack to revise
transaction history.
{% endautocrossref %}

### Block Contents
{% autocrossref %}

This section describes [version 2 blocks][v2 block]{:#term-v2-block}{:.term}, which are any blocks with a
block height greater than 227,835. (Version 1 and version 2 blocks were
intermingled for some time before that point.) Future block versions may
break compatibility with the information in this section. You can determine
the version of any block by checking its `version` field using
bitcoind RPC calls.

As of version 2 blocks, each block consists of four root elements:

1. A [magic number][block header magic]{:#term-block-header-magic}{:.term} (0xd9b4bef9).

2. A 4-byte unsigned integer indicating how many bytes follow until the
   end of the block. Although this field would suggest maximum block
   sizes of 4 GiB, max block size is currently capped at 1 MiB and the
   default max block size (used by most miners) is 350 KiB (although
   this will likely increase over time).

3. An 80-byte block header described in the section below.

4. One or more [transactions][].

Blocks are usually referenced by the SHA256(SHA256()) hash of their header, but
because this hash must be below the target threshold, there exists an
increased (but still minuscule) chance of eventual hash collision.

Blocks can also be referenced by their block height, but multiple blocks
can have the same height during a block chain fork, so block height
should not be used as a globally unique identifier. In version 2 blocks,
each block must place its height as the first parameter in the coinbase
field of the coinbase transaction (described below), so block height
can be determined without access to previous blocks.
{% endautocrossref %}

#### Block Header
{% autocrossref %}

The 80-byte block header contains the following six fields:

| Field             | Bytes  | Format                         |
|-------------------|--------|--------------------------------|
| 1. Version        | 4      | Unsigned Int                   |
| 2. hashPrevBlock  | 32     | Unsigned Int (SHA256 Hash)     |
| 3. hashMerkleRoot | 32     | Unsigned Int (SHA256 Hash)     |
| 4. Time           | 4      | Unsigned Int (Epoch Time)      |
| 5. Bits           | 4      | Internal Bitcoin Target Format |
| 6. Nonce          | 4      | (Arbitrary Data)               |

1. The *[block version][]{:#term-block-version}{:.term}* number indicates which set of block validation rules
   to follow so Bitcoin Core developers can add features or
   fix bugs. As of block height 227,836, all blocks use version number
   2.

2. The *hash of the previous block header* puts this block on the
   block chain and ensures no previous block can be changed without also
   changing this block's header.

3. The *Merkle root* is a hash derived from hashes of all the
   transactions included in this block. It ensures no transactions can
   be modified in this block without changing the block header.

4. The *[block time][]{:#term-block-time}{:.term}* is the approximate time when this block was created in
   Unix Epoch time format (number of seconds elapsed since
   1970-01-01T00:00 UTC). The time value must be greater than the
   time of the previous block. No peer will accept a block with a
   time currently more than two hours in the future according to the
   peer's clock.

5. *Bits* translates into the target threshold value -- the maximum allowed
   value for this block's hash. The bits value must match the network
   difficulty at the time the block was mined.

6. The *[header nonce][]{:#term-header-nonce}{:.term}* is an arbitrary input that miners can change to test different
   hash values for the header until they find a hash value less than or
   equal to the target threshold. If all values within the nonce's four
   bytes are tested, the time can be updated or the
   coinbase transaction (described below) can be changed and the Merkle
   root updated.
{% endautocrossref %}

#### Transaction Data
{% autocrossref %}

Every block must include one or more [transactions][]. Exactly one of these
transactions must be a coinbase transaction which should collect and
spend any transaction fees paid by transactions included in this block.
All blocks with a block height less than 6,930,000 are entitled to
receive a [block reward][]{:#term-block-reward}{:.term} of newly created bitcoin value, which also
should be spent in the coinbase transaction. (The block reward started
at 50 bitcoins and is being halved approximately every four years. As of
april 2014, it's 25 bitcoins.) A coinbase transaction is invalid if it 
tries to spend more value than is available from the transaction 
fees and block reward.

The [coinbase transaction][]{:#term-coinbase-tx}{:.term} has the same basic format as any other
transaction, but it references a single non-existent UTXO and a special
[coinbase field][]{:#term-coinbase-field}{:.term} replaces the field that would normally hold a scriptSig and
signature. In version 2 blocks, the coinbase parameter must begin with
the current block's block height and may contain additional arbitrary
data or a script up to a maximum total of 100 bytes.

The UTXO of a coinbase transaction has the special condition that it
cannot be spent (used as an input) for at least 100 blocks. This
helps prevent a miner from spending the transaction fees and block
reward from a block that will later be orphaned (destroyed) after a
block chain fork.

Blocks are not required to include any non-coinbase transactions, but
miners almost always do include additional transactions in order to
collect their transaction fees.

All transactions, including the coinbase transaction, are encoded into
blocks in binary rawtransaction format prefixed by a block transaction
sequence number.

The rawtransaction format is hashed to create the transaction
identifier (txid). From these txids, the [Merkle tree][]{:#term-merkle-tree}{:.term} is constructed by pairing each
txid with one other txid and then hashing them together. If there are
an odd number of txids, the txid without a partner is hashed with a
copy of itself.

The resulting hashes themselves are each paired with one other hash and
hashed together. Any hash without a partner is hashed with itself. The
process repeats until only one hash remains, the Merkle root.

For example, if transactions were merely joined (not hashed), a
five-transaction Merkle tree would look like the following text diagram:
{% endautocrossref %}

           ABCDEEEE .......Merkle root
          /        \
       ABCD        EEEE
      /    \      /
     AB    CD    EE .......E is paired with itself
    /  \  /  \  /
    A  B  C  D  E .........Transactions

{% autocrossref %}
As discussed in the [Simplified Payment Verification (SPV)][spv] subsection,
<!-- not written yet --> the Merkle tree allows clients to verify for
themselves that a transaction was included in a block by obtaining the
Merkle root from a block header and a list of the intermediate hashes
from a full peer. The full peer does not need to be trusted: it is
expensive to fake blocks and the intermediate hashes cannot be faked or
the verification will fail.

For example, a peer who wants to verify transaction D was added to the
block only needs a copy of the C, AB, and EEEE hashes in addition to the
Merkle root; the peer doesn't need to know anything about any of the
other transactions. If the five transactions in this block were all at
the maximum size, downloading the entire block would require over
500,000 bytes---but downloading three hashes plus the block header
requires only 140 bytes.
{% endautocrossref %}


#### Example Block And Coinbase Transaction

{% autocrossref %}
The first block with more than one transaction is at [block height 170][block170].
We can get the hash of block 170's header with the `getblockhash` RPC:
{% endautocrossref %}

    > getblockhash 170

    00000000d1145790a8694403d4063f323d499e655c83426834d4ce2f8dd4a2ee

{% autocrossref %}
We can then get a decoded version of that block with the `getblock` RPC:
{% endautocrossref %}

    > getblock 00000000d1145790a8694403d4063f323d499e655c83\
      426834d4ce2f8dd4a2ee

{% highlight json %}
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
{% endhighlight %}

{% autocrossref %}
Note: the only values above which are actually part of the block are size,
version, [merkleroot][merkle root], [time][block time], [nonce][header nonce], and bits. All other values shown
are computed.

The first transaction identifier (txid) listed in the tx array is
the coinbase transaction. The txid is a hash of the raw
transaction. We can get the actual raw transaction in hexadecimal format
from the block chain using the `getrawtransaction` RPC with the txid:
{% endautocrossref %}

    > getrawtransaction b1fea52486ce0c62bb442b530a3f0132b82\
      6c74e473d1f2c220bfa78111c5082

    01000000[...]00000000

{% autocrossref %}
We can expand the raw transaction hex into a human-readable format by
passing the raw transaction to the `decoderawtransaction` RPC:
{% endautocrossref %}

    > decoderawtransaction 01000000010000000000000000000000\
      000000000000000000000000000000000000000000ffffffff070\
      4ffff001d0102ffffffff0100f2052a01000000434104d46c4968\
      bde02899d2aa0963367c7a6ce34eec332b32e42e5f3407e052d64\
      ac625da6f0718e7b302140434bd725706957c092db53805b821a8\
      5b23a7ac61725bac00000000

{% highlight json %}
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
{% endhighlight %}

{% autocrossref %}
Note the vin (input) array includes a single transaction shown with a
coinbase field and the vout (output) spends the block reward of 50
bitcoins to a public key (not a standard hashed Bitcoin address).
{% endautocrossref %}

## Transactions
{% autocrossref %}

<!-- reference tx (made by Satoshi in block 170): 
    bitcoind decoderawtransaction $( bitcoind getrawtransaction f4184fc596403b9d638783cf57adfe4c75c605f6356fbc91338530e9831e9e16 )
-->

<!-- SOMEDAY: we need more terms than just output/input to denote the
various ways the outputs/inputs are used, such as "prevout", "nextout",
"curout", "curin", "nextin".  (Is there any use for "previn"?)  Someday,
when I'm terribly bored, I should rewrite this whole transaction section
to use those terms and then get feedback to see if it actually helps. -harding -->

Transactions let users spend satoshis. Each transaction is constructed
out of several parts which enable both simple direct payments and complex
transactions. This section will describe each part and
demonstrate how to use them together to build complete transactions.

To keep things simple, this section pretends coinbase transactions do
not exist. Coinbase transactions can only be created by Bitcoin miners
and they're an exception to many of the rules listed below. Instead of
pointing out the coinbase exception to each rule, we invite you to read
about coinbase transactions in the block chain section of this guide.

![The Parts Of A Transaction](/img/dev/en-tx-overview.svg)

The figure above shows the core parts of a Bitcoin transaction. Each
transaction has at least one input and one output. Each [input][]{:#term-input}{:.term} spends the
satoshis paid to a previous output. Each [output][]{:#term-output}{:.term} then waits as an Unspent
Transaction Output (UTXO) until a later input spends it. When your
Bitcoin wallet tells you that you have a 10,000 satoshi balance, it really
means that you have 10,000 satoshis waiting in one or more UTXOs.

Each transaction is prefixed by a four-byte [transaction version number][]{:#term-transaction-version-number}{:.term} which tells
Bitcoin peers and miners which set of rules to use to validate it.  This
lets developers create new rules for future transactions without
invalidating previous transactions.

The figure below helps illustrate the other transaction features by
showing the workflow Alice uses to send Bob a transaction and which Bob
later uses to spend that transaction. Both Alice and Bob will use the
most common form of the standard Pay-To-Pubkey-Hash (P2PH) transaction
type. [P2PH][]{:#term-p2ph}{:.term} lets Alice spend satoshis to a typical Bitcoin address,
and then lets Bob further spend those satoshis using a simple
cryptographic key pair.

![P2PH Transaction Workflow](/img/dev/en-p2ph-workflow.svg)

Bob must generate a private/public [key pair][]{:#term-key-pair}{:.term} before Alice can create the
first transaction. Standard Bitcoin [private keys][private
key]{:#term-private-key}{:.term} are 256 bits of random
data. A copy of that data is deterministically transformed into a [public
key][]{:#term-public-key}{:.term}. Because the transformation can be reliably repeated later, the
public key does not need to be stored.

The public key is then cryptographically hashed. This pubkey hash can
also be reliably repeated later, so it also does not need to be stored.
The hash shortens and obfuscates the public key, making manual
transcription easier and providing security against
unanticipated problems which might allow reconstruction of private keys
from public key data at some later point.


<!-- Editors: from here on I will typically use the terms "pubkey hash"
and "full public key" to provide quick differentiation between the
different states of a public key and to help the text better match the
space-constrained diagrams where "public-key hash" wouldn't fit. -harding -->


Bob provides the [pubkey hash][]{:#term-pubkey-hash}{:.term} to Alice. Pubkey hashes are almost always
sent encoded as Bitcoin [addresses][]{:#term-address}{:.term}, which are [base-58 encoded][base58check] strings
containing an address version number, the hash, and an error-detection
checksum to catch typos. The address can be transmitted
through any medium, including one-way mediums which prevent the spender
from communicating with the receiver, and it can be further encoded
into another format, such as a QR code containg a `bitcoin:`
URI.

Once Alice has the address and decodes it back into a standard hash, she
can create the first transaction. She creates a standard P2PH
transaction output containing instructions which allow anyone to spend that
output if they can prove they control the private key corresponding to
Bob's hashed public key. These instructions are called the output [script][]{:#term-script}{:.term}.

Alice broadcasts the transaction and it is added to the block chain.
The network categorizes it as an Unspent Transaction Output (UTXO), and Bob's
wallet software displays it as a spendable balance.

When, some time later, Bob decides to spend the UTXO, he must create an
input which references the transaction Alice created by its hash, called
a Transaction Identifier (txid), and the specific output she used by its
index number ([output index][]{:#term-output-index}{:.term}). He must then create a [scriptSig][]{:#term-scriptsig}{:.term}---a
collection of data parameters which satisfy the conditions Alice placed
in the previous output's script.

Bob does not need to communicate with Alice to do this; he must simply
prove to the Bitcoin peer-to-peer network that he can satisfy the
[script's][script] conditions.  For a P2PH-style output, Bob's scriptSig will
contain the following two pieces of data:

1. His full (unhashed) public key, so the script can check that it
   hashes to the same value as the [hashed pubkey][pubkey hash] provided by Alice.

2. A [signature][]{:#term-signature}{:.term} made by using the ECDSA cryptographic formula to combine
   certain transaction data (described below) with Bob's private key.
   This lets the script verify that Bob owns the private key which
   created the public key.

Bob's signature doesn't just prove Bob controls his private key; it also
makes the rest of his transaction tamper-proof so Bob can safely
broadcast it over the peer-to-peer network.

<!-- Editors: please keep "amount of bitcoins" (instead of "number of
bitcoins") in the paragraph below to match the text in the figure above.  -harding -->

As illustrated in the figure above, the data Bob [signs][signature] includes the
txid and output index of the previous transaction, the previous
output's script, the script Bob creates which will let the next
recipient spend this transaction's output, and the amount of satoshis to
spend to the next recipient. In essence, the entire transaction is
signed except for any scriptSigs, which hold the full public keys and
signatures.

After putting his signature and public key in the scriptSig, Bob
broadcasts the transaction to Bitcoin miners through the peer-to-peer
network. Each peer and miner independently validates the transaction
before broadcasting it further or attempting to include it in a new block of
transactions.
{% endautocrossref %}

### P2PH Script Validation
{% autocrossref %}

The validation procedure requires evaluation of the script.  In a P2PH
script, the script is:
{% endautocrossref %}

    OP_DUP OP_HASH160 <PubkeyHash> OP_EQUALVERIFY OP_CHECKSIG

{% autocrossref %}
The spender's scriptSig is evaluated and prefixed to the beginning of the
script. In a P2PH transaction, the scriptSig contains a signature (sig)
and full public key (pubkey), creating the following concatenation:
{% endautocrossref %}

    <Sig> <PubKey> OP_DUP OP_HASH160 <PubkeyHash> OP_EQUALVERIFY OP_CHECKSIG

{% autocrossref %}
The script language is a
[Forth-like](https://en.wikipedia.org/wiki/Forth_%28programming_language%29)
[stack][]{:#term-stack}{:.term}-based language deliberately designed to be stateless and not
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

{% endautocrossref %}

### P2SH Scripts
{% autocrossref %}

Output scripts are created by spenders who have little interest in the
long-term security or usefulness of the particular satoshis they're
currently spending. Receivers do care about the conditions imposed on
the satoshis by the output script and, if they want, they can ask
spenders to use a particular script. Unfortunately, custom scripts are
less convenient than short Bitcoin addresses and more difficult to
secure than P2PH pubkey hashes.

To solve these problems, pay-to-script-hash
([P2SH][]{:#term-p2sh}{:.term}) transactions were created in 2012 to let
a spender create an output script containing a [hash of a second
script][script hash]{:#term-script-hash}{:.term}, the
[redeemScript][]{:#term-redeemscript}{:.term}.

The basic P2SH workflow, illustrated below, looks almost identical to
the P2PH workflow. Bob creates a redeemScript with whatever script he
wants, hashes the redeemScript, and provides the [redeemScript
hash][script hash] to Alice. Alice creates a P2SH-style output containing
Bob's redeemScript hash.

![P2SH Transaction Workflow](/img/dev/en-p2sh-workflow.svg)

When Bob wants to spend the output, he provides his signature along with
the full (serialized) redeemScript in the input scriptSig. The
peer-to-peer network ensures the full redeemScript hashes to the same
value as the script hash Alice put in her output; it then processes the
redeemScript exactly as it would if it were the primary script, letting
Bob spend the output if the redeemScript returns true.

The hash of the redeemScript has the same properties as a pubkey
hash---so it can be transformed into the standard Bitcoin address format
with only one small change to differentiate it from a standard address.
This makes collecting a P2SH-style address as simple as collecting a
P2PH-style address. The hash also obfuscates any public keys in the
redeemScript, so P2SH scripts are as secure as P2PH pubkey hashes.
{% endautocrossref %}

### Standard Transactions
{% autocrossref %}

Care must be taken to avoid non-standard output scripts. As of Bitcoin Core
0.9, the [standard output script][standard script] types are:


**Pubkey hash (P2PH)**

P2PH is the most common form of script used to send a transaction to one
or multiple Bitcoin addresses.
{% endautocrossref %}

~~~
script: OP_DUP OP_HASH160 <PubKeyHash> OP_EQUALVERIFY OP_CHECKSIG
scriptSig: <sig> <pubkey> 
~~~

{% autocrossref %}
**Script hash (P2SH)**

P2SH is used to send a transaction to a script hash. Each of the standard
scripts can be used inside a P2SH redeemScript, but in practice only the
multisig script makes sense until more transaction types are made standard.
{% endautocrossref %}

~~~
script: OP_HASH160 <redeemscripthash> OP_EQUAL
scriptSig: <sig> [sig] [sig...] <redeemscript>
~~~

{% autocrossref %}
**Multisig**

Although P2SH is now generally used for multisig transactions, this script
can be used to require multiple signatures before a UTXO can be spent.

In multisig scripts, called m-of-n, *m* is the *minimum* number of signatures
which must match a public key; *n* is the *number* of public keys being
provided. Both *m* and *n* should be op codes `OP_1` through `OP_16`,
corresponding to the number desired.

Because of an off-by-one error in the original Bitcoin implementation
which must be preserved for compatibility, `OP_CHECKMULTISIG`
consumes one more value from the stack than indicated by *m*, so the
list of signatures in the scriptSig must be prefaced with an extra value
(`OP_0`) which will be consumed but not used.

{% endautocrossref %}

~~~
script: <m> <pubkey> [pubkey] [pubkey...] <n> OP_CHECKMULTISIG
scriptSig: OP_0 <sig> [sig] [sig...]
~~~

{% autocrossref %}
Although it’s not a separate transaction type, this is a P2SH multisig with 2-of-3:
{% endautocrossref %}

~~~
script: OP_HASH160 <redeemscripthash> OP_EQUAL
redeemScript: <OP_2> <pubkey> <pubkey> <pubkey> <OP_3> OP_CHECKMULTISIG
scriptSig: OP_0 <sig> <sig> <redeemscript>
~~~


{% autocrossref %}
**Pubkey**

[Pubkey][]{:#term-pubkey}{:.term} scripts are a simplified form of the P2PH script; they’re used in all
coinbase transactions, but they aren’t as convenient
or secure as P2PH, so they generally
aren’t used elsewhere.
{% endautocrossref %}

~~~
script: <pubkey> OP_CHECKSIG
scriptSig: <sig>
~~~

{% autocrossref %}
**Null Data**

[Null data][]{:#term-null-data}{:.term} scripts let you add a small amount of arbitrary data to the block
chain in exchange for paying a transaction fee, but doing so is discouraged.
(Null data is a standard script type only because some people were adding data
to the block chain in more harmful ways.)
{% endautocrossref %}

~~~
script: OP_RETURN <data>
(Null data scripts cannot be spent, so there's no scriptSig)
~~~

#### Non-Standard Transactions

{% autocrossref %}
If you use anything besides a standard script in an output, peers
and miners using the default Bitcoin Core settings will neither
accept, broadcast, nor mine your transaction. When you try to broadcast
your transaction to a peer running the default settings, you will
receive an error.

But if you create a non-standard redeemScript, hash it, and use the hash
in a P2SH output, the network sees only the hash, so it will accept the
output as valid no matter what the redeemScript says. When you go to
spend that output, however, peers and miners using the default settings
will see the non-standard redeemScript and reject it. It will be
impossible to spend that output until you find a miner who disables the
default settings.

As of Bitcoin Core 0.9, standard transactions must also meet the following
conditions:

* The transaction must be finalized: either its locktime must be in the
  past (or equal to the current block height), or all of its sequence
  numbers must be 0xffffffff.

* The transaction must be smaller than 100,000 bytes. That's around 200
  times larger than a typical single-input, single-output P2PH
  transaction.

* Each of the transaction's inputs must be smaller than 500 bytes.
  That's large enough to allow 3-of-3 multisig transactions in P2SH.
  Multisig transactions which require more than 3 public keys are
  currently non-[standard][standard script].

* The transaction's scriptSig must only push data to the script
  evaluation stack. It cannot push new OP codes, with the exception of
  OP codes which solely push data to the stack.

* If any of the transaction's outputs spend less than a minimal value
  (currently 546 satoshis---0.005 millibits), the transaction must pay
  a minimum transaction fee (currently 0.1 millibits).

{% endautocrossref %}

### Signature Hash Types
{% autocrossref %}

`OP_CHECKSIG` extracts a non-stack argument from each signature it
evaluates, allowing the signer to decide which parts of the transaction
to [sign][signature]. Since the signature protects those parts of the transaction
from modification, this lets signers selectively choose to let other
people modify their transactions.

The various options for what to sign are
called [signature hash][]{:#term-signature-hash}{:.term} types. There are three base SIGHASH types
currently available:

* [`SIGHASH_ALL`][sighash_all]{:#term-sighash-all}{:.term}, the default, signs all the inputs and outputs,
  protecting everything except the scriptSigs against modification.

* [`SIGHASH_NONE`][sighash_none]{:#term-sighash-none}{:.term} signs all of the inputs but none of the outputs,
  allowing anyone to change where the satoshis are going unless other
  signatures using other signature hash flags protect the outputs.

* [`SIGHASH_SINGLE`][sighash_single]{:#term-sighash-single}{:.term} signs only this input and only one corresponding
  output (the output with the same output index number as the input), ensuring
  nobody can change your part of the transaction but allowing other
  signers to change their part of the transaction. The corresponding
  output must exist or the value "1" will be signed, breaking the security
  scheme.

The base types can be modified with the [`SIGHASH_ANYONECANPAY`][shacp]{:#term-sighash-anyonecanpay}{:.term} (anyone can
pay) flag, creating three new combined types:

* [`SIGHASH_ALL|SIGHASH_ANYONECANPAY`][sha_shacp]{:#term-sighash-all-sighash-anyonecanpay}{:.term} signs all of the outputs but only
  this one input, and it also allows anyone to add or remove other
  inputs, so anyone can contribute additional satoshis but they cannot
  change how many satoshis are sent nor where they go.

* [`SIGHASH_NONE|SIGHASH_ANYONECANPAY`][shn_shacp]{:#term-sighash-none-sighash-anyonecanpay}{:.term} signs only this one input and
  allows anyone to add or remove other inputs or outputs, so anyone who
  gets a copy of this input can spend it however they'd like.

* [`SIGHASH_SINGLE|SIGHASH_ANYONECANPAY`][shs_shacp]{:#term-sighash-single-sighash-anyonecanpay}{:.term} signs only this input and only
  one corresponding output, but it also allows anyone to add or remove
  other inputs.

Because each input is signed, a transaction with multiple inputs can
have multiple signature hash types signing different parts of the transaction. For
example, a single-input transaction signed with [`NONE`][sighash_none] could have its
output changed by the miner who adds it to the block chain. On the other
hand, if a two-input transaction has one input signed with [`NONE`][sighash_none] and
one input signed with [`ALL`][sighash_all], the `ALL` signer can choose where to spend
the satoshis without consulting the `NONE` signer---but nobody else can
modify the transaction.

<!-- TODO: describe useful combinations maybe using a 3x3 grid;
do something similar for the multisig section with different hashtypes
between different sigs -->

<!-- TODO: add to the technical section details about what the different
hash types sign, including the procedure for inserting the subscript -->
{% endautocrossref %}

### Locktime And Sequence Number
{% autocrossref %}

One thing all signature hash types [sign][signature] is the transaction's [locktime][]{:#term-locktime}{:.term}.
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
network allows [times][block time] on the block chain to be up to two hours ahead of
real time, so a locktime transaction can be added to the block chain up
to two hours before its time lock officially expires. Also, blocks are
not created at guaranteed intervals, so any attempt to cancel a valuable
transaction should be made a few hours before the time lock expires.

Previous versions of Bitcoin Core provided a feature which prevented
transaction signers from using the method described above to cancel a
time-locked transaction, but a necessary part of this feature was
disabled to prevent DOS attacks. A legacy of this system are four-byte
[sequence numbers][sequence number]{:#term-sequence-number}{:.term} in every input. Sequence numbers were meant to allow
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
  can be added to any block whose block header's [time][block time] field is greater
  than the locktime.
{% endautocrossref %}

### Transaction Fees And Change
{% autocrossref %}

Transactions typically pay transaction fees based on the total byte size
of the signed transaction.  The transaction fee is given to the
Bitcoin miner, as explained in the [block chain section][block chain], and so it is
ultimately up to each miner to choose the minimum transaction fee they
will accept.

<!-- TODO: check: 50 KB or 50 KiB?  Not that transactors care... -->

By default, miners reserve 50 KB of each block for [high-priority
transactions][]{:#term-high-priority-transactions}{:.term} which spend satoshis that haven't been spent for a long
time.  The remaining space in each block is allocated to transactions
based on their fee per byte, with higher-paying transactions being added
in sequence until all of the available space is filled.

As of Bitcoin Core 0.9, transactions which do not count as [high priority][high-priority transactions]
need to pay a [minimum fee][]{:#term-minimum-fee}{:.term} of 10,000 satoshis (0.01 millibits) to be
broadcast across the network. Any transaction paying the minimum fee
should be prepared to wait a long time before there's enough spare space
in a block to include it. Please see the [block chain section][block chain] about
confirmations for why this could be important.

Since each transaction spends Unspent Transaction Outputs (UTXOs) and
because a UTXO can only be spent once, the full value of the included
UTXOs must be spent or given to a miner as a transaction fee.  Few
people will have UTXOs that exactly match the amount they want to pay,
so most transactions include a change output.

[Change outputs][change output]{:#term-change-output} are regular outputs which spend the surplus satoshis
from the UTXOs back to the spender.  They can reuse the same P2PH pubkey hash
or P2SH script hash as was used in the UTXO, but for the reasons
described in the [next section](#avoiding-key-reuse), it is highly recommended that change
outputs be sent to a new P2PH or P2SH address.
{% endautocrossref %}

### Avoiding Key Reuse
{% autocrossref %}

In a transaction, the spender and receiver each reveal to each other all
public keys or addresses used in the transaction. This allows either
person to use the public block chain to track past and future
transactions involving the other person's same public keys or addresses.

If the same public key is reused often, as happens when people use
Bitcoin addresses (hashed public keys) as static payment addresses,
other people can easily track the receiving and spending habits of that
person, including how many satoshis they control in known addresses.

It doesn't have to be that way. If each public key is used exactly
twice---once to receive a payment and once to spend that payment---the
user can gain a significant amount of financial privacy.

Even better, using new public keys or [unique
addresses][]{:#term-unique-address} when accepting payments or creating
change outputs can be combined with other techniques discussed later,
such as CoinJoin or merge avoidance, to make it extremely difficult to
use the block chain by itself to reliably track how users receive and
spend their satoshis.

Avoiding key reuse in combination with P2PH or P2SH addresses also
prevents anyone from seeing the user's ECDSA public key until he spends
the satoshis sent to those addresses. This, combined with the block
chain, provides security against hypothetical future attacks which may
allow reconstruction of private keys from public keys in a matter of
hours, days, months, or years (but not any faster).

So, for both privacy and security, we encourage you to build your
applications to avoid public key reuse and, when possible, to discourage
users from reusing addresses. If your application needs to provide a
fixed URI to which payments should be sent, please see Bitcoin the
[`Bitcoin:` URI section][section bitcoin URI] below.

{% endautocrossref %}

### Transaction Malleability
{% autocrossref %}

None of Bitcoin's signature hash types protect the scriptSig, leaving
the door open for a limited DOS attack called [transaction
malleability][]{:.term}{:#term-transaction-malleability}. The scriptSig
contains the signature, which can't sign itself, allowing attackers to
make non-functional modifications to a transaction without rendering it
invalid. For example, an attacker can add some data to the scriptSig
which will be dropped before the previous output script is processed.

Although the modifications are non-functional---so they do not change
what inputs the transaction uses nor what outputs it pays---they do
change the computed hash of the transaction. Since each transaction
links to previous transactions using hashes as a transaction
identifier (txid), a modified transaction will not have the txid its
creator expected.

This isn't a problem for most Bitcoin transactions which are designed to
be added to the block chain immediately. But it does become a problem
when the output from a transaction is spent before that transaction is
added to the block chain.

Bitcoin developers have been working to reduce transaction malleability
among standard transaction types, but a complete fix is still only in
the planning stages. At present, new transactions should not depend on
previous transactions which have not been added to the block chain yet,
especially if large amounts of satoshis are at stake.

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
{% endautocrossref %}

### Transaction Reference

The following subsections briefly document core transaction details.

#### OP Codes
{% autocrossref %}

The op codes used in standard transactions are,

* Various data pushing op codes from 0x00 to 0x4e (1--78). These haven't
  been shown in the examples above, but they must be used to push
  signatures and public keys onto the stack. See the link below this list
  for a description.

* `OP_1NEGATE` (0x4f), `OP_TRUE`/`OP_1` (0x51), and `OP_2` through
  `OP_16` (0x52--0x60), which (respectively) push the values -1, 1, and
  2--16 to the stack.

* [`OP_CHECKSIG`][op_checksig]{:#term-op-checksig}{:.term} consumes a signature and a full public key, and returns
  true if the the transaction data specified by the SIGHASH flag was
  converted into the signature using the same ECDSA private key that
  generated the public key.  Otherwise, it returns false.

* [`OP_DUP`][op_dup]{:#term-op-dup}{:.term} returns a copy of the item on the stack below it.

* [`OP_HASH160`][op_hash160]{:#term-op-hash160}{:.term} consumes the item on the stack below it and returns with
  a RIPEMD-160(SHA256()) hash of that item.

* [`OP_EQUAL`][op_equal]{:#term-op-equal}{:.term} consumes the two items on the stack below it and returns
  true if they are the same.  Otherwise, it returns false.

* [`OP_VERIFY`][op_verify]{:#term-op-verify}{:.term} consumes one value and returns nothing, but it will
  terminate the script in failure if the value consumed is zero (false).

* [`OP_EQUALVERIFY`][op_equalverify]{:#term-op-equalverify}{:.term} runs `OP_EQUAL` and then `OP_VERIFY` in sequence.

* [`OP_CHECKMULTISIG`][op_checkmultisig]{:#term-op-checkmultisig}{:.term} consumes the value (n) at the top of the stack,
  consumes that many of the next stack levels (public keys), consumes
  the value (m) now at the top of the stack, and consumes that many of
  the next values (signatures) plus one extra value. Then it compares
  each of public keys against each of the signatures looking for ECDSA
  matches; if n of the public keys match signatures, it returns true.
  Otherwise, it returns false.

    The "one extra value" it consumes is the result of an off-by-one
    error in the Bitcoin Core implementation. This value is not used, so
    scriptSigs prefix the signatures with a single OP_0 (0x00).

* [`OP_RETURN`][op_return]{:#term-op-return}{:.term} terminates the script in failure. However, this will not
  invalidate a [null-data-type][null data] transaction which contains no more than 40
  bytes following `OP_RETURN` no more than once per transaction.

A complete list of OP codes can be found on the Bitcoin Wiki [Script
Page][wiki script], with an authoritative list in the `opcodetype` enum
of the Bitcoin Core [script header file][core script.h]

Note: non-standard transactions can add non-data-pushing op codes to
their scriptSig, but scriptSig is run separately from the script (with a
shared stack), so scriptSig can't use arguments such as `OP_RETURN` to
prevent the script from working as expected.
{% endautocrossref %}

#### Address Conversion
{% autocrossref %}

The hashes used in P2PH and P2SH outputs are commonly encoded as Bitcoin
addresses.  This is the procedure to encode those hashes and decode the
addresses.

First, get your hash.  For P2PH, you RIPEMD-160(SHA256()) hash a ECDSA
public key derived from your 256-bit ECDSA private key (random data).
For P2SH, you RIPEMD-160(SHA256()) hash a redeemScript serialized in the
format used in raw transactions (described in a [following
sub-section][raw transaction format]).  Taking the resulting hash:

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
   string: <!--[-->`BASE58(version . hash . checksum)`<!--]-->
 
Bitcoin's base58 encoding, called [Base58Check][]{:#term-base58check}{:.term} may not match other implementations. Tier
Nolan provided the following example encoding algorithm to the Bitcoin
Wiki [Base58Check
encoding](https://en.bitcoin.it/wiki/Base58Check_encoding) page:

{% endautocrossref %}

{% highlight c %}
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
{% endhighlight %}

{% autocrossref %}
Bitcoin's own code can be traced using the [base58 header
file][core base58.h].

To convert addresses back into hashes, reverse the base58 encoding, extract
the checksum, repeat the steps to create the checksum and compare it
against the extracted checksum, and then remove the version byte.
{% endautocrossref %}

#### Raw Transaction Format
{% autocrossref %}

Bitcoin transactions are broadcast between peers and stored in the
block chain in a serialized byte format, called [raw format][]{:#term-raw-format}{:.term}. Bitcoin Core
and many other tools print and accept raw transactions encoded as hex.

A sample raw transaction is the first non-coinbase transaction, made in
[block 170][block170].  To get the transaction, use the `getrawtransaction` RPC with
that transaction's txid (provided below):
{% endautocrossref %}

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

## Contracts
{% autocrossref %}

By making the system hard to understand, the complexity of transactions
has so far worked against you. That changes with contracts. Contracts are
transactions which use the decentralized Bitcoin system to enforce financial
agreements.

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
transactions, they are framed below in story format.

Besides the contract types described below, many other contract types
have been proposed. Several of them are collected on the [Contracts
page](https://en.bitcoin.it/wiki/Contracts) of the Bitcoin Wiki.
{% endautocrossref %}

### Escrow And Arbitration
{% autocrossref %}

Charlie-the-customer wants to buy a product from Bob-the-businessman,
but neither of them trusts the other person, so they use a contract to
help ensure Charlie gets his merchandise and Bob gets his payment.

A simple contract could say that Charlie will spend satoshis to an
output which can only be spent if Charlie and Bob both sign the input
spending it. That means Bob won't get paid unless Charlie gets his
merchandise, but Charlie can't get the merchandise and keep his payment.

This simple contract isn't much help if there's a dispute, so Bob and
Charlie enlist the help of Alice-the-arbitrator to create an [escrow
contract][]{:#term-escrow-contract}{:.term}. Charlie spends his satoshis
to an output which can only be spent if two of the three people sign the
input. Now Charlie can pay Bob if everything is ok, Bob can refund
Charlie's money if there's a problem, or Alice can arbitrate and decide
who should get the satoshis if there's a dispute.

To create a multiple-signature ([multisig][]{:#term-multisig}{:.term})
output, they each give the others a public key. Then Bob creates the
following [P2SH multisig][]{:#term-p2sh-multisig}{:.term} redeemScript:

    OP_2 [A's pubkey] [B's pubkey] [C's pubkey] OP_3 OP_CHECKMULTISIG

(Op codes to push the public keys onto the stack are not shown.)

`OP_2` and `OP_3` push the actual numbers 2 and 3 onto the
stack. `OP_2`
specifies that 2 signatures are required to sign; `OP_3` specifies that
3 public keys (unhashed) are being provided. This is a 2-of-3 multisig
script, more generically called a m-of-n script (where *m* is the
*minimum* matching signatures required and *n* in the *number* of public
keys provided).

Bob gives the redeemScript to Charlie, who checks to make sure his
public key and Alice's public key are included. Then he hashes the
redeemScript, puts it in a P2SH output, and pays the satoshis to it. Bob
sees the payment get added to the block chain and ships the merchandise.

Unfortunately, the merchandise gets slightly damaged in transit. Charlie
wants a full refund, but Bob thinks a 10% refund is sufficient. They
turn to Alice to resolve the issue. Alice asks for photo evidence from
Charlie along with a copy of the unhashed redeemScript Bob created and
Charlie checked. 

After looking at the evidence, Alice thinks a 40% refund is sufficient,
so she creates and signs a transaction with two outputs, one that spends 60%
of the satoshis to Bob's public key and one that spends the remaining
40% to Charlie's public key.

In the input section of the script, Alice puts her signature, a 0x00
placeholder byte, and a copy of the unhashed serialized redeemScript
that Bob created.  She gives a copy of the incomplete transaction to
both Bob and Charlie.  Either one of them can complete it by replacing
the placeholder byte with his signature, creating the following input
script:

    OP_0 [A's signature] [B's or C's signature] [serialized redeemScript]

(Op codes to push the signatures and redeemScript onto the stack are
not shown. `OP_0` is a workaround for an off-by-one error in the original
implementation which must be preserved for compatibility.)

When the transaction is broadcast to the network, each peer checks the
input script against the P2SH output Charlie previously created,
ensuring that the redeemScript matches the redeemScript hash previously
provided. Then the redeemScript is evaluated, with the two signatures
being used as input<!--noref--> data. Assuming the redeemScript
validates, the two transaction outputs show up in Bob's and Charlie's
wallets as spendable balances.

However, if Alice created and signed a transaction neither of them would
agree to, such as spending all the satoshis to herself, Bob and Charlie
can find a new arbitrator and sign a transaction spending the satoshis
to another 2-of-3 multisig redeemScript hash, this one including public
key from that second arbitrator. This means that Bob and Charlie never
need to worry about their arbitrator stealing their money.

**Resource:** [BitRated](https://www.bitrated.com/) provides a multisig arbitration
service interface using HTML/JavaScript on a GNU AGPL-licensed website.
{% endautocrossref %}


### Micropayment Channel
{% autocrossref %}

<!-- SOMEDAY: try to rewrite using a more likely real-world example without
making the text or illustration more complicated --> 

Alice also works part-time moderating forum posts for Bob. Every time
someone posts to Bob's busy forum, Alice skims the post to make sure it
isn't offensive or spam. Alas, Bob often forgets to pay her, so Alice
demands to be paid immediately after each post she approves or rejects.
Bob says he can't do that because hundreds of small payments will cost
him thousands of satoshis in transaction fees, so Alice suggests they use a
[micropayment channel][]{:#term-micropayment-channel}{:.term}.

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

Transaction malleability, discussed above in the Payment Security section,
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
{% endautocrossref %}

### CoinJoin
{% autocrossref %}

Alice is concerned about her privacy.  She knows every transaction gets
added to the public block chain, so when Bob and Charlie pay her, they
can each easily track those satoshis to learn what Bitcoin
addresses she pays, how much she pays them, and possibly how many
satoshis she has left.

Because Alice isn't a criminal, she doesn't want to use some shady
Bitcoin laundering service; she just wants plausible deniability about
where she has spent her satoshis and how many she has left, so she
starts up the Tor anonymity service on her computer and logs into an
IRC chatroom as "AnonGirl."

Also in the chatroom are "Nemo" and "Neminem."  They collectively
agree to transfer satoshis between each other so no one besides them
can reliably determine who controls which satoshis.  But they're faced
with a dilemma: who transfers their satoshis to one of the other two
pseudonymous persons first? The CoinJoin-style contract, shown in the
illustration below, makes this decision easy: they create a single
transaction which does all of the spending simultaneously, ensuring none
of them can steal the others' satoshis.

![Example CoinJoin Transaction](/img/dev/en-coinjoin.svg)

Each contributor looks through their collection of Unspent Transaction
Outputs (UTXOs) for 100 millibits they can spend. They then each generate
a brand new public key and give UTXO details and pubkey hashes to the
facilitator.  In this case, the facilitator is AnonGirl; she creates
a transaction spending each of the UTXOs to three equally-sized [outputs].
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

The complete history of Alice's satoshis is still in the block chain,
so a determined investigator could talk to the people AnonGirl
CoinJoined with to find out the ultimate origin of her satoshis and
possibly reveal AnonGirl as Alice. But against anyone casually browsing
block chain history, Alice gains plausible deniability.

The CoinJoin technique described above costs the participants a small
amount of satoshis to pay the transaction fee.  An alternative
technique, purchaser CoinJoin, can actually save them satoshis and
improve their privacy at the same time.

AnonGirl waits in the IRC chatroom until she wants to make a purchase.
She announces her intention to spend satoshis and waits until someone
else wants to make a purchase, likely from a different merchant. Then
they combine their inputs the same way as before but set the outputs
to the separate merchant addresses so nobody will be able to figure
out solely from block chain history which one of them bought what from
the merchant.

Since they would've had to pay a transaction fee to make their purchases
anyway, AnonGirl and her co-spenders don't pay anything extra---but
because they reduced overhead by combining multiple transactions, saving
bytes, they may be able to pay a smaller aggregate transaction fee,
saving each one of them a tiny amount of satoshis.

**Resource:** An alpha-quality (as of this writing) implementation of decentralized
CoinJoin is [CoinMux](http://coinmux.com/), available under the Apache
license. A centralized version of purchaser CoinJoin is available at the
[SharedCoin](https://sharedcoin.com/) website (part of Blockchain.info),
whose [implementation](https://github.com/blockchain/Sharedcoin) is
available under the 4-clause BSD license.
{% endautocrossref %}

## Wallets
{% autocrossref %}

Bitcoin wallets at their core are a collection of private keys. These collections are stored digitally in a file, or can even be physically stored on pieces of paper. 
{% endautocrossref %}

### Private key formats
{% autocrossref %}

Private keys are what are used to unlock satoshis from a particular address. In Bitcoin, a private key in standard format is simply a 256-bit number, between the values:

0x1 and 0xFFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFE BAAE DCE6 AF48 A03B BFD2 5E8C D036 4141, effectively representing the entire range of 2<sup>256</sup>-1 values. The range is governed by the secp256k1 ECDSA encryption standard used by Bitcoin. 
{% endautocrossref %}

#### Wallet Import Format (WIF)
{% autocrossref %}

In order to make copying of private keys less prone to error, [Wallet Import Format][]{:#term-wallet-import-format}{:.term} may be utilized. WIF uses base58Check encoding on an private key, greatly decreasing the chance of copying error, much like standard Bitcoin addresses.

1. Take a private key.

2. Add a 0x80 byte in front of it for mainnet addresses or 0xef for testnet addresses.

3. Perform a SHA-256 hash on the extended&nbsp;key.

4. Performa SHA-256 hash on result of SHA-256 hash.

5. Take the first 4 bytes of the second SHA-256 hash; this is the checksum.

6. Add the 4 checksum bytes from point 5 at the end of the extended&nbsp;key from point 2.

7. Convert the result from a byte string into a Base58 string using Base58Check encoding.

The process is easily reversible, using the Base58 decoding function, and removing the padding.
{% endautocrossref %}

#### Mini Private Key Format
{% autocrossref %}

Mini private key format is a method for encoding a private key in under 30 characters, enabling keys to be embedded in a small physical space, such as physical bitcoin tokens, and more damage-resistant QR codes. 

1. The first character of mini keys is 'S'. 

2. In order to determine if a mini private key is well-formatted, a question mark is added to the private key.

3. The SHA256 hash calculated. If the first byte produced is a `00’, it is well-formatted. This key restriction acts as a typo-checking mechanism. A user brute forces the process using random numbers until a well-formatted mini private key is produced. 

4. In order to derive the full private key, the user simply takes a single SHA256 hash of the original mini private key. This process is one-way: it is intractible to compute the mini private key format from the derived key.

Many implementations disallow the character '1' in the mini private key due to its visual similarity to 'l'.

**Resource:** A common tool to create and redeem these keys is the [Casascius Bitcoin Address Utility][casascius
address utility].

{% endautocrossref %}




### Deterministic wallets formats
{% autocrossref %}

Deterministic wallets are the recommended method of generating and storing private keys, as they allow a simple one-time backup of wallets via mnemonic pass-phrase of a number of short, common English words.

{% endautocrossref %}



#### Type 1: Single Chain Wallets
{% autocrossref %}

Type 1 deterministic wallets are the simpler of the two, which can create a single series of keys from a single seed. A primary weakness is that if the seed is leaked, all funds are compromised, and wallet sharing is extremely limited.
{% endautocrossref %}

#### Type 2: Hierarchical Deterministic (HD) Wallets
{% autocrossref %}

Type 2 wallets, specified in BIP32, are the currently favored format for generating, storing and managing private keys. Hierarchical deterministic wallets allow selective sharing by supporting multiple key-pair chains in a tree structure, derived from a single root. This selective sharing enables many advanced arrangements. An additional goal of the BIP32 standard is to encourage interoperability between wallet software using the same wallet format, rather than having to manually convert wallet types. The suggested minimal interoperability is the ability to import extended [public][public key] and private keys, to give access to the descendants as wallet keys. 

_Seamless interoperability is still a work in progress. It is possible for another implementation to not see non-zero valued addresses, depending on wallet parameters. For safe recovery of wallets, it is recommended to use the same wallet software. Another concern is the saving of HD wallet meta-data such as transaction notes and [labels][label], which has not been standardized._  

<!-- BEGIN The following text largely taken from the BIP0032 specification --> 

Here are a select number of use cases:

1. Audits: In case an auditor needs full access to the list of incoming and outgoing payments, one can share all account public extended keys. This will allow the auditor to see all [transactions][] from and to the wallet, in all accounts, but not a single private key.

2. When a business has several independent offices, they can all use wallets derived from a single seed. This will allow the headquarters to maintain a super-wallet that sees all incoming and outgoing transactions of all offices, and even permit moving money between the offices.

3. In case two business partners often transfer money, one can use the extended public key for the external chain of a specific account as a sort of "super address", allowing frequent transactions that cannot (easily) be associated, but without needing to request a new address for each payment. Such a mechanism could also be used by mining pool operators as variable payout address.

With many more arrangements possible. The following section is an in-depth technical discussion of HD wallets.
{% endautocrossref %}

#### Conventions
{% autocrossref %}

In the rest of this text we will assume the public key cryptography used in Bitcoin, namely elliptic curve cryptography using the field and curve parameters defined by secp256k1. Variables below are either:

* Integers modulo the order of the curve (referred to as n).

* Coordinates of points on the curve.

* Byte sequences.

Addition (+) of two coordinate pair is defined as application of the EC group operation.

Concatenation (\|\|) is the operation of appending one byte sequence onto another.

As standard conversion functions, we assume:

* point(p): returns the coordinate pair resulting from EC point multiplication (repeated application of the EC group operation) of the secp256k1 base point with the integer p.

* ser<sub>32</sub>(i): serialize a 32-bit unsigned integer i as a 4-byte sequence, most significant byte first.

* ser<sub>256</sub>(p): serializes the integer p as a 32-byte sequence, most significant byte first.

* ser<sub>P</sub>(P): serializes the coordinate pair P = (x,y) as a byte sequence using SEC1's compressed form: (0x02 or 0x03) \|\| ser<sub>256</sub>(x), where the header byte depends on the parity of the omitted y coordinate.

* parse<sub>256</sub>(p): interprets a 32-byte sequence as a 256-bit number, most significant byte first.
{% endautocrossref %}


#### Extended keys
{% autocrossref %}

In what follows, we will define a function that derives a number of [child keys][child key]{:#term-child-key}{:.term} from a [parent key][]{:#term-parent-key}{:.term}. In order to prevent these from depending solely on the key itself, we extend both [private][private keys] and public keys first with an extra 256 bits of entropy. This extension, called the [chain code][]{:#term-chain-code}{:.term}, is identical for corresponding private and public keys, and consists of 32 bytes.

We represent an [extended private key][]{:#term-extended-private-key}{:.term} as (k, c), with k the normal private key, and c the chain code. An [extended public key][]{:#term-extended-public-key}{:.term} is represented as (K, c), with K = point(k) and c the chain code.

Each [extended key][]{:#term-extended-key}{:.term} has 2<sup>31</sup> [normal child keys][normal child key]{:#term-normal-child-key}{:.term}, and 2<sup>31</sup> [hardened child keys][hardened child key]{:#term-hardened-child-key}{:.term}. Each of these child keys has an [index][key index]{:#term-key-index}{:.term}. The normal child keys use indices 0 through 2<sup>31</sup>-1. The hardened child keys use indices 2<sup>31</sup> through 2<sup>32</sup>-1. To ease notation for hardened key indices, a number i<sub>H</sub> represents i+2<sup>31</sup>.
{% endautocrossref %}

#### Child key derivation (CKD) functions
{% autocrossref %}

Given a parent extended key and an index i, it is possible to compute the corresponding [child extended key][]{:#term-child-extended-key}{:.term}. The algorithm to do so depends on whether the child is a hardened key or not (or, equivalently, whether i ≥ 2<sup>31</sup>), and whether we're talking about [private][private key] or public keys.
{% endautocrossref %}

##### Private parent key &rarr; private child key
{% autocrossref %}

The function CKDpriv((k<sub>par</sub>, c<sub>par</sub>), i) &rarr; (k<sub>i</sub>, c<sub>i</sub>) computes a child extended private key from the parent extended private key:

* Check whether i ≥ 2<sup>31</sup> (whether the child is a hardened key).

    * If so (hardened child): let I = HMAC-SHA512(Key = c<sub>par</sub>, Data = 0x00 \|\| ser<sub>256</sub>(k<sub>par</sub>) \|\| ser<sub>32</sub>(i)). (Note: The 0x00 pads the private key to make it 33 bytes long.)

    * If not (normal child): let I = HMAC-SHA512(Key = c<sub>par</sub>, Data = ser<sub>P</sub>(point(k<sub>par</sub>)) \|\| ser<sub>32</sub>(i)).

* Split I into two 32-byte sequences, I<sub>L</sub> and I<sub>R</sub>.

* The returned child key k<sub>i</sub> is parse<sub>256</sub>(I<sub>L</sub>) + k<sub>par</sub> (mod n).

* The returned chain code c<sub>i</sub> is I<sub>R</sub>.

* In case parse<sub>256</sub>(I<sub>L</sub>) ≥ n or k<sub>i</sub> = 0, the resulting key is invalid, and one should proceed with the next value for i. (Note: this has probability lower than 1 in 2<sup>127</sup>.)

The HMAC-SHA512 function is specified in [RFC 4231](http://tools.ietf.org/html/rfc4231).
{% endautocrossref %}

##### Public parent key &rarr; public child key
{% autocrossref %}

The function CKDpub((K<sub>par</sub>, c<sub>par</sub>), i) &rarr; (K<sub>i</sub>, c<sub>i</sub>) computes a child extended public key from the parent extended public key. It is only defined for non-hardened child keys.

* Check whether i ≥ 2<sup>31</sup> (whether the child is a hardened key).

    * If so (hardened child): return failure

    * If not (normal child): let I = HMAC-SHA512(Key = c<sub>par</sub>, Data = ser<sub>P</sub>(K<sub>par</sub>) \|\| ser<sub>32</sub>(i)).

* Split I into two 32-byte sequences, I<sub>L</sub> and I<sub>R</sub>.

* The returned child key K<sub>i</sub> is point(parse<sub>256</sub>(I<sub>L</sub>)) + K<sub>par</sub>.

* The returned chain code c<sub>i</sub> is I<sub>R</sub>.

* In case parse<sub>256</sub>(I<sub>L</sub>) ≥ n or K<sub>i</sub> is the point at infinity, the resulting key is invalid, and one should proceed with the next value for i.
{% endautocrossref %}

##### Private parent key &rarr; public child key
{% autocrossref %}

The function N((k, c)) &rarr; (K, c) computes the extended public key corresponding to an extended private key (the "neutered" version, as it removes the ability to sign transactions).

* The returned key K is point(k).

* The returned chain code c is just the passed chain code.

To compute the public child key of a parent private key:

* N(CKDpriv((k<sub>par</sub>, c<sub>par</sub>), i)) (works always).

* CKDpub(N(k<sub>par</sub>, c<sub>par</sub>), i) (works only for non-hardened child keys).

The fact that they are equivalent is what makes non-hardened keys useful (one can derive [child public keys][child public key]{:#term-child-public-key}{:.term} of a given parent key without knowing any private key), and also what distinguishes them from hardened keys. The reason for not always using non-hardened keys (which are more useful) is security; see further for more information.
{% endautocrossref %}

##### Public parent key &rarr; private child key

This is not possible, as is expected.

#### The key tree
{% autocrossref %}

The next step is cascading several CKD constructions to build a tree. We start with one root, the master extended key m. By evaluating CKDpriv(m,i) for several values of i, we get a number of level-1 derived nodes. As each of these is again an extended key, CKDpriv can be applied to those as well.

To shorten notation, we will write CKDpriv(CKDpriv(CKDpriv(m,3<sub>H</sub>),2),5) as m/3<sub>H</sub>/2/5. Equivalently for public keys, we write CKDpub(CKDpub(CKDpub(M,3),2,5) as M/3/2/5. This results in the following identities:

* N(m/a/b/c) = N(m/a/b)/c = N(m/a)/b/c = N(m)/a/b/c = M/a/b/c.

* N(m/a<sub>H</sub>/b/c) = N(m/a<sub>H</sub>/b)/c = N(m/a<sub>H</sub>)/b/c.

However, N(m/a<sub>H</sub>) cannot be rewritten as N(m)/a<sub>H</sub>, as the latter is not possible.

Each leaf node in the tree corresponds to an actual key, while the internal nodes correspond to the collections of keys that descend from them. The chain codes of the leaf nodes are ignored, and only their embedded private or public key is relevant. Because of this construction, knowing an extended private key allows reconstruction of all descendant private keys and public keys, and knowing an extended public keys allows reconstruction of all descendant non-hardened public keys.
{% endautocrossref %}

#### Key identifiers
{% autocrossref %}

Extended keys can be identified by the Hash160 (RIPEMD160 after SHA256) of the serialized public key, ignoring the chain code. This corresponds exactly to the data used in traditional Bitcoin addresses. It is not advised to represent this data in base58 format though, as it may be interpreted as an address that way (and wallet software is not required to accept payment to the chain key itself).

The first 32 bits of the identifier are called the [key fingerprint][]{:#term-key-fingerprint}{:.term}.
{% endautocrossref %}

#### Serialization format
{% autocrossref %}

Extended public and private keys are serialized as follows:

* 4 byte: version bytes (mainnet: 0x0488B21E public, 0x0488ADE4 private; testnet: 0x043587CF public, 0x04358394 private)

* 1 byte: depth: 0x00 for master nodes, 0x01 for level-1 derived keys, ....

* 4 bytes: the fingerprint of the parent's key (0x00000000 if master key)

* 4 bytes: child number. This is ser<sub>32</sub>(i) for i in x<sub>i</sub> = x<sub>par</sub>/i, with x<sub>i</sub> the key being serialized. (0x00000000 if master key)

* 32 bytes: the chain code

* 33 bytes: the public key or private key data (ser<sub>P</sub>(K) for public keys, 0x00 \|\| ser<sub>256</sub>(k) for private keys)

This 78 byte structure can be encoded like other Bitcoin data in Base58, by first adding 32 checksum bits (derived from the double SHA-256 checksum), and then converting to the Base58 representation. This results in a Base58-encoded string of up to 112 characters. Because of the choice of the version bytes, the Base58 representation will start with "xprv" or "xpub" on mainnet, "tprv" or "tpub" on testnet.

Note that the fingerprint of the parent only serves as a fast way to detect parent and child nodes in software, and software must be willing to deal with collisions. Internally, the full 160-bit identifier could be used.

When importing a serialized extended public key, implementations must verify whether the X coordinate in the public key data corresponds to a point on the curve. If not, the extended public key is invalid.
{% endautocrossref %}

#### Master key generation
{% autocrossref %}

The total number of possible extended keypairs is almost 2<sup>512</sup>, but the produced keys are only 256 bits long, and offer about half of that in terms of security. Therefore, [master keys][master key]{:#term-master-key}{:.term} are not generated directly, but instead from a potentially short seed value.

* Generate a [seed][]{:#term-master-key-seed}{:.term} byte sequence S of a chosen length (between 128 and 512 bits; 256 bits is advised) from a (P)RNG.

* Calculate I = HMAC-SHA512(Key = "Bitcoin seed", Data = S)

* Split I into two 32-byte sequences, I<sub>L</sub> and I<sub>R</sub>.

* Use parse<sub>256</sub>(I<sub>L</sub>) as master secret key, and I<sub>R</sub> as master chain code.

In case I<sub>L</sub> is 0 or ≥n, the master key is invalid.

![Example](/img/dev/derivation.png)

{% endautocrossref %}

#### Specification: Wallet structure
{% autocrossref %}

The previous sections specified key trees and their nodes. The next step is imposing a wallet structure on this tree. The layout defined in this section is a default only, though clients are encouraged to mimick it for compatibility, even if not all features are supported.

{% endautocrossref %}

#### The default wallet layout
{% autocrossref %}

An HDW is organized as several [accounts][HD account]{:#term-hd-account}{:.term}. Accounts are numbered, the default account ("") being number 0. Clients are not required to support more than one account - if not, they only use the default account.

Each account is composed of two keypair chains: an [internal chain][]{:#term-internal-chain}{:.term} and an [external chain][]{:#term-external-chain}{:.term}. The external keychain is used to generate new public addresses, while the internal keychain is used for all other operations (change addresses, [coinbase addresses][coinbase transaction], and anything else that doesn't need to be communicated). Clients that do not support separate keychains for these should use the external one for everything.

* m/i<sub>H</sub>/0/k corresponds to the k'th keypair of the external chain of account number i of the HDW derived from master m.

* m/i<sub>H</sub>/1/k corresponds to the k'th keypair of the internal chain of account number i of the HDW derived from master m.
{% endautocrossref %}

#### Security Considerations
{% autocrossref %}

Most of the standard security guarantees afforded the standard key setups such as Type 1 wallets are still in place. 

Note however that the following properties does not exist:

* Given a parent extended public key (K<sub>par</sub>,c<sub>par</sub>) and a child public key (K<sub>i</sub>), it is hard to find child key index (i).

* Given a parent extended public key (K<sub>par</sub>,c<sub>par</sub>) and a non-hardened child private key
(k<sub>i</sub>), it is hard to find the parent private key (k<sub>par</sub>).

Consequently:

1. Private and public keys must be kept safe as usual. Leaking a private key means access to coins - leaking a public key can mean loss of privacy.

2. Somewhat more care must be taken regarding extended keys, as these correspond to an entire (sub)tree of keys.

3. One weakness that may not be immediately obvious, is that knowledge of the extended public key plus any non-[hardened private key][hardened child key] descending from it is equivalent to knowing the extended private key (and thus every private and public key descending from it). This means that extended public keys must be treated more carefully than regular public keys.

*It is also the reason for the existence of hardened keys, and why they are used for the [account][HD account] level in the tree. This way, a leak of account-specific (or below) private key never risks compromising the master key or other accounts.*

<!-- END extended quote from BIP0032 spec --> 

**Resources:** Refer to BIP32 for the full HD Wallet specification.

{% endautocrossref %}



### JBOK (Just a bunch of keys) wallets formats (deprecated)
{% autocrossref %}

JBOK-style wallets are a deprecated form of wallet that originated from the Bitcoin Core client wallet. Bitcoin Core client wallet would create 100 private key/public key pairs automatically via a Psuedo-Random-Number Generator (PRNG) for use. Once all these keys are consumed or the RPC call `keypoolrefill` is run, another 100 key pairs would be created. This created considerable difficulty in backing up one’s keys, considering backups have to be run manually to save the newly generated private keys. If a new key pair set had been generated, used, then lost prior to a backup, the stored satoshis are likely lost forever. Many older-style mobile wallets followed a similar format, but only generated a new private key upon user demand.

This wallet type is being actively phased out and strongly discouraged from being used to store significant amounts of satoshis due to the security and backup hassle.

{% endautocrossref %}




## Payment Processing
{% autocrossref %}

Payment processing encompasses the steps spenders and receivers perform
to make and accept payments in exchange for products or services. The
basic steps have not changed since the dawn of commerce, but the
technology has. This section will explain how how receivers and spenders
can, respectively, request and make payments using Bitcoin---and how
they can deal with complications such as refunds and recurrent
rebilling.

Bitcoin payment processing is being actively developed at the moment, so
each subsection below attempts to describe what's widely deployed now,
what's new, and what might be coming before the end of 2014.

![Bitcoin Payment Processing](/img/dev/en-payment-processing.svg)

The figure above illustrates payment processing using Bitcoin from a
receiver's perspective, starting with a new order. The following
subsections will each address the three common steps and the three
occasional or optional steps.
{% endautocrossref %}

### Calculating Order Totals In Satoshis
{% autocrossref %}

Because of exchange rate variability between satoshis and national
currencies ([fiat][]{:#term-fiat}{:.term}), many Bitcoin orders are priced in fiat but paid
in satoshis, necessitating a price conversion.

Exchange rate data is widely available through HTTP-based APIs provided
by currency exchanges. Several organizations also aggregate data from
multiple exchanges to create index prices which are also available using
HTTP-based APIs.

Any applications which automatically calculate order totals using exchange
rate data must take steps to ensure the price quoted reflects the
current general market value of satoshis, or your applications could
accept too few satoshis for the product or service being sold.
Alternatively, they could ask for too many satoshis, driving potential
spenders away.

To minimize problems, you applications may want to collect data from at
least two separate sources and compare them to see how much they differ.
If the difference is substantial, your applications can enter a safe mode
until a human is able to evaluate the situation.

You may also want to program your applications to enter a safe mode if
exchange rates are rapidly increasing or decreasing, indicating a
possible problem in the Bitcoin market which could make it difficult to
spend any satoshis received today.

Exchange rates lie outside the control of Bitcoin and related
technologies, so there are no new or planned technologies which
will make it significantly easier for your program to correctly convert
order totals from fiat into satoshis.

{% endautocrossref %}




#### Expiring Old Order Totals
{% autocrossref %}

Because the exchange rate fluctuates over time, order totals pegged to
fiat must expire to prevent spenders from delaying payment in the hope
that satoshis will drop in price. Most widely-used payment processing
systems currently expire their invoices after 10 minutes.

Shorter expiration periods increase the chance the invoice will expire
before payment is received, possibly necessitating manual intervention
to request an additional payment or to issue a refund.   Longer
expiration periods increase the chance that the exchange rate will
fluctuate a significant amount before payment is received.

{% endautocrossref %}




### Requesting Payments Using Bitcoin
{% autocrossref %}

Before requesting payment, your application must create a Bitcoin
address, or acquire an address from another program such as
Bitcoin Core.  Bitcoin addresses are described in detail in the
[Transactions](#transactions) section. Also described in that section
are two important reasons to [avoid using an address more than
once](#avoiding-key-reuse)---but a third reason applies especially to
payment requests:

Using a separate address for each incoming payment makes it trivial to
determine which customers have paid their payment requests.  Your
applications need only track the association between a particular payment
request and the address used in it, and then scan the block chain for
transactions matching that address.

The next subsections will describe in detail the following three
compatible ways to give the spender the address and amount to be paid:

1. All wallet software lets its users paste in or manually enter an
   address and amount into a payment screen. This is, of course,
   inconvenient---but it makes an effective fallback option.

2. Almost all desktop wallets can associate with `bitcoin:` URIs, so
   spenders can click a link to pre-fill the payment screen. This also
   works with many mobile wallets, but it generally does not work with
   web-based wallets unless the spender installs a browser extension or
   manually configures a URI handler.

3. Some desktop wallets and most mobile wallets support `bitcoin:` URIs
   encoded in a [QR code][URI QR Code]. Most web-based wallets do not support reading
   QR codes directly, although they do often generate QR codes for
   accepting payment.

{% endautocrossref %}




#### Plain Text
{% autocrossref %}

To specify an amount directly for copying and pasting, you must provide
the address, the amount, and the denomination. An expiration time for
the offer may also be specified.  For example:

(Note: all examples in this section use Testnet addresses.)
{% endautocrossref %}

    Pay: mjSk1Ny9spzU2fouzYgLqGUD8U41iR35QN
    Amount: 100 BTC
    You must pay by: 2014-04-01 at 23:00 UTC

{% autocrossref %}
Indicating the [denomination][]{:#term-denomination}{:.term} is critical. As of this writing, all popular
Bitcoin wallet software defaults to denominating amounts in either [bitcoins][]{:#term-bitcoins}{:.term} (BTC)
or [millibits][]{:#term-millibits}{:.term} (mBTC). Choosing between BTC and mBTC is widely supported,
but other software also lets its users select denomination amounts from
some or all of the following options:
{% endautocrossref %}

| Bitcoins    | Unit (Abbreviation) |
|-------------|---------------------|
| 1.0         | bitcoin (BTC)       |
| 0.01        | bitcent (cBTC)      |
| 0.001       | millibit (mBTC)     |
| 0.000001    | microbit (uBTC)     |
| 0.00000001  | [satoshi][]{:#term-satoshi}{:.term}             |


{% autocrossref %}
Because of the widespread popularity of BTC and mBTC, it may be more
useful to specify the amount in both denominations when the text is
meant to be copied and pasted. For example:
{% endautocrossref %}

    Pay: mjSk1Ny9spzU2fouzYgLqGUD8U41iR35QN
    Amount: 100 BTC  (100000 mBTC)
    You must pay by: 2014-04-01 at 23:00 UTC

{% autocrossref %}
Plain-text payment requests should, whenever possible, be sent over
secure medium (such as HTTPS) to prevent a man-in-the-middle attack from
replacing your application's addresses with some other addresses.
{% endautocrossref %}




#### `bitcoin:` URI
{% autocrossref %}

The [`bitcoin:` URI][bitcoin URI]{:#term-bitcoin-uri}{:.term} scheme defined in BIP21 eliminates denomination
confusion and saves the spender from copying and pasting two separate
values. It also lets the payment request provide some additional
information to the spender. An example:

{% endautocrossref %}

    bitcoin:mjSk1Ny9spzU2fouzYgLqGUD8U41iR35QN?amount=100

{% autocrossref %}

Only the address is required, and if it is the only thing specified,
wallets will pre-fill a payment request with it and let the spender enter
an amount.

The amount specified is always in decimal bitcoins (BTC), although requests
only for whole bitcoins (as in the example above), may omit the decimal
point. The amount field must not contain any commas. Fractional bitcoins
may be specified with or without a leading zero; for example, either of
the URIs below requesting one millibit are valid:
{% endautocrossref %}

    bitcoin:mjSk1Ny9spzU2fouzYgLqGUD8U41iR35QN?amount=.001
    bitcoin:mjSk1Ny9spzU2fouzYgLqGUD8U41iR35QN?amount=0.001

{% autocrossref %}
Two other parameters are widely supported. The [`label`][label]{:#term-label}{:.term} parameter is
generally used to provide wallet software with the recipient's name. The
[`message`][message]{:#term-message}{:.term} parameter is generally used to describe the payment request to
the spender. Both the label and the message are commonly stored by the
spender's wallet software---but they are never added to the actual
transaction, so other Bitcoin users cannot see them. Both the label and
the message must be [URI encoded][].

All four parameters used together, with appropriate URI encoding, can be
seen in the line-wrapped example below.

{% endautocrossref %}

    bitcoin:mjSk1Ny9spzU2fouzYgLqGUD8U41iR35QN\
    ?amount=0.10\
    &label=Example+Merchant\
    &message=Order+of+flowers+%26+chocolates

The URI above could be encoded in HTML as follows, providing compatibility
with wallet software which can't accept URI links and allowing you to
specify an expiration date to the spender.

    <a href="bitcoin:mjSk1Ny9spzU2fouzYgLqGUD8U41iR35QN\
    ?amount=0.10\
    &label=Example+Merchant\
    &message=Order+of+flowers+%26+chocolates"
    >Order flowers & chocolate using Bitcoin</a>
    (Pay 0.10 BTC [100 mBTC] to mjSk1Ny9spzU2fouzYgLqGUD8U41iR35QN by 2014-04-01 at 23:00 UTC)

Which produces:

> <a href="bitcoin:mjSk1Ny9spzU2fouzYgLqGUD8U41iR35QN?amount=0.10&label=Example+Merchant&message=Order+of+flowers+%26+chocolates">Order flowers & chocolates using Bitcoin</a> (Pay 0.10 BTC [100 mBTC] to mjSk1Ny9spzU2fouzYgLqGUD8U41iR35QN by 2014-04-01 at 23:00 UTC)

{% autocrossref %}

Some payment processors use Javascript to display countdown timers
indicating the number of minutes and seconds until the offer expires.

The URI scheme can be extended, as will be seen in the payment protocol
section below, with both new optional and required parameters. As of this
writing, the only widely-used parameter besides the four described above
is the payment protocol's `r` parameter.

Programs accepting URIs in any form must ask the user for permission
before paying unless the user has explicitly disabled prompting (as
might be the case for micropayments).

Like pain-text payment requests, URI payment requests should, whenever
possible, be sent over secure medium (such as HTTPS) to prevent a
man-in-the-middle attack from replacing your application's addresses
with some other addresses.

{% endautocrossref %}

#### QR Codes
{% autocrossref %}

QR codes are a popular way to exchange `bitcoin:` URIs in person, in
images, or in videos. Most mobile Bitcoin wallet apps, and some desktop
wallets, support scanning QR codes to pre-fill their payment screens.

The figure below shows the same `bitcoin:` URI code encoded as four
different [Bitcoin QR codes][URI QR code]{:#term-uri-qr-code}{:.term} at different error correction levels (described
below the image). The QR code can include the `label` and `message`
parameters---and any other optional parameters---but they were
omitted here to keep the QR code small and easy to scan with unsteady
or low-resolution mobile cameras.

![Bitcoin QR Codes](/img/dev/en-qr-code.svg)

QR encoders offer four possible levels of error correction: 

1. Low: corrects up to 7% damage

2. Medium: corrects up to 15% damage but results in approximately 8%
   larger images over low-level damage correction.

3. Quartile: corrects corrects up to 25% damage but results in
   approximately 20% larger images over low-level damage correction.

4. High: corrects up to 30% damage but results in approximately 26%
   larger images over low-level damage correction.

The error correction is combined with a checksum to ensure the Bitcoin QR code
cannot be successfully decoded with data missing or accidentally altered,
so your applications should choose the appropriate level of error
correction based on the space you have available to display the code.
Low-level damage correction works well when space is limited, and
quartile-level damage correction helps ensure fast scanning when
displayed on high-resolution screens.

To the degree possible, your applications should discourage the
transmission of Bitcoin QR codes via images or videos which could be modified to
replace the intended QR code with an alternative QR code.

{% endautocrossref %}


#### Requesting Payment With The Payment Protocol
{% autocrossref %}

Bitcoin Core 0.9 supports the new [payment protocol][]{:#term-payment-protocol}{:.term}. The payment protocol
lets receivers provide more detail about the requested payment to
spenders. It also lets them use X.509 certificates and SSL encryption to
verify their identity to spenders and help prevent man-in-the-middle attacks.

Instead of being asked to pay a meaningless address, such as
"mjSk1Ny9spzU2fouzYgLqGUD8U41iR35QN", spenders are asked to pay the
Common Name (CN) description from the receiver's X.509 certificate, such
as "www.bitcoin.org".

To request payment using the payment protocol, you use an extended (but
backwards-compatible) `bitcoin:` URI.  For example:
{% endautocrossref %}

    bitcoin:mjSk1Ny9spzU2fouzYgLqGUD8U41iR35QN\
    ?amount=0.10\
    &label=Example+Merchant\
    &message=Order+of+flowers+%26+chocolates\
    &r=http://example.com/pay.php/invoice%3Dda39a3ee

{% autocrossref %}
None of the parameters provided above, except `r`, are required for the
payment protocol---but your applications may include them for backwards
compatibility with wallet programs which don't yet handle the payment
protocol. 

The [`r`][r]{:#term-r-parameter}{:.term} parameter tells payment-protocol-aware wallet programs to ignore
the other parameters and fetch a PaymentRequest from the URL provided.  If the
request will be signed, which is recommended but not required, it can be
fetched from an HTTP server---although fetching it from an HTTPS server
would still be preferable.

The browser, QR code reader, or other program processing the URI opens
the spender's Bitcoin wallet program on the URI. If the wallet program is
aware of the payment protocol, it accesses the URL specified in the `r`
parameter, which should provide it with a serialized PaymentRequest
served with the [MIME][] type {% endautocrossref %} `application/bitcoin-paymentrequest`.




##### PaymentRequest & PaymentDetails
{% autocrossref %}

The [PaymentRequest][]{:#term-paymentrequest}{:.term} is created with data structures built using
Google's Protocol Buffers. BIP70 describes these data
structures in the non-sequential way they're defined in the payment
request protocol buffer code, but the text below will describe them in
a more linear order using a simple (but functional) Python CGI
program. (For brevity and clarity, many normal CGI best practices are
not used in this program.)

The full sequence of events is illustrated below, starting with the
spender clicking a `bitcoin:` URI or scanning a `bitcoin:` QR code.

![BIP70 Payment Protocol](/img/dev/en-payment-protocol.svg)

For the script to use the protocol buffer, you will need a copy of
Google's Protocol Buffer compiler (`protoc`), which is available in most
modern Linux package managers and [directly from Google.][protobuf] Non-Google
protocol buffer compilers are also available for a variety of other
programming languages. You will also need a copy of the PaymentRequest
[Protocol Buffer description][core paymentrequest.proto] in the Bitcoin Core source code.

###### Initialization Code

With the Python code generated by `protoc`, we can start our simple
CGI program.

{% endautocrossref %}

{% highlight python %}
#!/usr/bin/env python

## This is the code generated by protoc --python_out=./ paymentrequest.proto
from paymentrequest_pb2 import *

## Load some functions
from time import time
from sys import stdout
from OpenSSL.crypto import FILETYPE_PEM, load_privatekey, sign

## Copy three of the classes created by protoc into objects we can use
details = PaymentDetails()
request = PaymentRequest()
x509 = X509Certificates()
{% endhighlight %}

{% autocrossref %}
The startup code above is quite simple, requiring nothing but the epoch
(Unix date) time function, the standard out file descriptor, a few
functions from the OpenSSL library, and the data structures and
functions created by `protoc`.
{% endautocrossref %}

###### Configuration Code

{% autocrossref %}
Next, we'll set configuration settings which will typically only change
when the receiver wants to do something differently. The code pushes a
few settings into the `request` (PaymentRequest) and `details`
(PaymentDetails) objects. When we serialize them,
[PaymentDetails][]{:#term-paymentdetails}{:.term} will be contained
within the PaymentRequest.
{% endautocrossref %}

{% highlight python %}
## SSL Signature method
request.pki_type = "x509+sha256"  ## Default: none

## Mainnet or Testnet?
details.network = "test"  ## Default: main

## Postback URL
details.payment_url = "https://example.com/pay.py"

## PaymentDetails version number
request.payment_details_version = 1  ## Default: 1

## Certificate chain
x509.certificate.append(file("/etc/apache2/example.com-cert.der", "r").read())
#x509.certificate.append(file("/some/intermediate/cert.der", "r").read())

## Load private SSL key into memory for signing later
priv_key = "/etc/apache2/example.com-key.pem"
pw = "test"  ## Key password
private_key = load_privatekey(FILETYPE_PEM, file(priv_key, "r").read(), pw)
{% endhighlight %}

Each line is described below.

{% highlight python %}
request.pki_type = "x509+sha256"  ## Default: none
{% endhighlight %}

{% autocrossref %}
`pki_type`: (optional) tell the receiving wallet program what [Public-Key
Infrastructure][PKI]{:#term-pki}{:.term} (PKI) type you're using to
cryptographically sign your PaymentRequest so that it can't be modified
by a man-in-the-middle attack. 

If you don't want to sign the PaymentRequest, you can choose a
[`pki_type`][pp pki type]{:#term-pp-pki-type}{:.term} of `none`
(the default).

If you do choose the sign the PaymentRequest, you currently have two
options defined by BIP70: `x509+sha1` and `x509+sha256`.  Both options
use the X.509 certificate system, the same system used for HTTP Secure
(HTTPS).  To use either option, you will need a certificate signed by a
certificate authority or one of their intermediaries. (A self-signed
certificate will not work.)

Each wallet program may choose which certificate authorities to trust,
but it's likely that they'll trust whatever certificate authorities their
operating system trusts.  If the wallet program doesn't have a full
operating system, as might be the case for small hardware wallets, BIP70
suggests they use the [Mozilla Root Certificate Store][mozrootstore]. In
general, if a certificate works in your web browser when you connect to
your webserver, it will work for your PaymentRequests.
{% endautocrossref %}



{% highlight python %}
details.network = "test"  ## Default: main
{% endhighlight %}

{% autocrossref %}
`network`:<!--noref--> (optional) tell the spender's wallet program what Bitcoin network you're
using; BIP70 defines "main" for mainnet (actual payments) and "test" for
testnet (like mainnet, but fake satoshis are used). If the wallet
program doesn't run on the network you indicate, it will reject the
PaymentRequest.
{% endautocrossref %}


{% highlight python %}
details.payment_url = "https://example.com/pay.py"
{% endhighlight %}

{% autocrossref %}
`payment_url`: (required) tell the spender's wallet program where to send the Payment
message (described later). This can be a static URL, as in this example,
or a variable URL such as `https://example.com/pay.py?invoice=123.`
It should usually be an HTTPS address to prevent man-in-the-middle
attacks from modifying the message.
{% endautocrossref %}


{% highlight python %}
request.payment_details_version = 1  ## Default: 1
{% endhighlight %}

{% autocrossref %}
`payment_details_version`: (optional) tell the spender's wallet program what version of the
PaymentDetails you're using. As of this writing, the only version is
version 1.
{% endautocrossref %}




{% highlight python %}
## This is the pubkey/certificate corresponding to the private SSL key
## that we'll use to sign:
x509.certificate.append(file("/etc/apache2/example.com-cert.der", "r").read())
{% endhighlight %}

{% autocrossref %}
`x509certificates`<!--noref--> (required for signed PaymentRequests) you must
provide the public SSL key/certificate corresponding to the private SSL
key you'll use to sign the PaymentRequest. The certificate must be in
ASN.1/DER format.
{% endautocrossref %}



{% highlight python %}
## If the pubkey/cert above didn't have the signature of a root
## certificate authority, we'd then append the intermediate certificate
## which signed it:
#x509.certificate.append(file("/some/intermediate/cert.der", "r").read())
{% endhighlight %}

{% autocrossref %}
You must also provide any intermediate certificates necessary to link
your certificate to the root certificate of a certificate authority
trusted by the spender's software, such as a certificate from the
Mozilla root store.

The certificates must be provided in a specific order---the same order
used by Apache's `SSLCertificateFile` directive and other server
software.   The figure below shows the signature<!--noref--> chain of the
www.bitcoin.org X.509 certificate and how each certificate (except the
root certificate) would be loaded into the [X509Certificates][]{:#term-x509certificates}{:.term} protocol
buffer message.

![X509Certificates Loading Order](/img/dev/en-cert-order.svg)

To be specific, the first certificate provided must be the
X.509 certificate corresponding to the private SSL key which will make the
signature<!--noref-->, called the [leaf certificate][]{:#term-leaf-certificate}{:.term}. Any [intermediate
certificates][intermediate certificate]{:#term-intermediate-certificate}{:.term} necessary to link that signed public SSL
key to the [root
certificate][]{:#term-root-certificate}{:.term} (the certificate authority) are attached separately, with each
certificate in DER format bearing the signature<!--noref--> of the certificate that
follows it all the way to (but not including) the root certificate.

<!-- (Commenting out following paragraph; it doesn't seem necessary;
--    will remove in a later commit if nobody complains.)
-- If you accidentally include the root certificate, no known X.509
-- implementation will invalidate your [certificate chain][]{:#term-certificate-chain}{:.term}. However,
-- including the root certificate will waste space (PaymentRequests must be
-- less than 50 KB) and bandwidth for no good reason---if the spender's
-- software does not already have a copy of the root certificate, it will
-- never consider your certificate chain valid.
-->
{% endautocrossref %}



{% highlight python %}
priv_key = "/etc/apache2/example.com-key.pem"
pw = "test"  ## Key password
private_key = load_privatekey(FILETYPE_PEM, file(priv_key, "r").read(), pw)
{% endhighlight %}

{% autocrossref %}
(Required for signed PaymentRequests) you will need a private SSL key in
a format your SSL library supports (DER format is not required). In this
program, we'll load it from a PEM file. (Embedding your passphrase in
your CGI code, as done here, is obviously a bad idea in real life.)

The private SSL key will not be transmitted with your request. We're
only loading it into memory here so we can use it to sign the request
later.

{% endautocrossref %}



###### Code Variables
{% autocrossref %}

Now let's look at the variables your CGI program will likely set for
each payment.
{% endautocrossref %}

{% highlight python %}
## Amount of the request
amount = 10000000  ## In satoshis (=100 mBTC)

## P2PH pubkey hash
pubkey_hash = "2b14950b8d31620c6cc923c5408a701b1ec0a020"
## P2PH output script entered as hex and converted to binary
# OP_DUP OP_HASH160 <push 20 bytes> <pubKey hash> OP_EQUALVERIFY OP_CHECKSIG
#   76       a9            14       <pubKey hash>        88          ac
hex_script = "76" + "a9" + "14" + pubkey_hash + "88" + "ac"
serialized_script = hex_script.decode("hex")

## Load amount and script into PaymentDetails
details.outputs.add(amount = amount, script = serialized_script)

## Memo to display to the spender
details.memo = "Flowers & chocolates"

## Data which should be returned to you with the payment
details.merchant_data = "Invoice #123"
{% endhighlight python %}

Each line is described below.

{% highlight python %}
amount = 10000000  ## In satoshis (=100 mBTC)
{% endhighlight %}

{% autocrossref %}
`amount`: (optional) the [amount][pp amount]{:#term-pp-amount}{:.term} you want the spender to pay. You'll probably get
  this value from your shopping cart application or fiat-to-BTC exchange
  rate conversion tool. If you leave the amount blank, the wallet
  program will prompt the spender how much to pay (which can be useful
  for donations).
{% endautocrossref %}




{% highlight python %}
pubkey_hash = "2b14950b8d31620c6cc923c5408a701b1ec0a020"
# OP_DUP OP_HASH160 <push 20 bytes> <pubKey hash> OP_EQUALVERIFY OP_CHECKSIG
#   76       a9            14       <pubKey hash>        88          ac
hex_script = "76" + "a9" + "14" + pubkey_hash + "88" + "ac"
serialized_script = hex_script.decode("hex")
{% endhighlight %}

{% autocrossref %}
`script`: (required) You must specify the output script you want the spender to
pay---any valid script is acceptable. In this example, we'll request
payment to a P2SH output script.  

First we get a pubkey hash. The hash above is the hash form of the
address used in the URI examples throughout this section,
mjSk1Ny9spzU2fouzYgLqGUD8U41iR35QN.

Next, we plug that hash into the standard P2PH output script using hex,
as illustrated by the code comments.

Finally, we convert the output script from hex into its serialized form.
{% endautocrossref %}




{% highlight python %}
details.outputs.add(amount = amount, script = serialized_script)
{% endhighlight %}

{% autocrossref %}
`outputs`:<!--noref--> (required) add the output script and (optional) amount to the
PaymentDetails outputs<!--noref--> array. 

It's possible to specify multiple [`scripts`][pp
script]{:#term-pp-script}{:.term} and `amounts` as part of a merge
avoidance strategy, described later in the [Merge Avoidance
subsection][]. However, effective merge avoidance is not possible under
the base BIP70 rules in which the spender pays each `script` the exact
amount specified by its paired `amount`. If the amounts are omitted from
all `amount`/`script` pairs, the spender will be prompted to choose an
amount to pay.
{% endautocrossref %}




{% highlight python %}
details.memo = "Flowers & chocolates"
{% endhighlight %}

{% autocrossref %}
`memo` (optional) add a memo which will be displayed to the spender as
plain UTF-8 text. Embedded HTML or other markup will not be processed.
{% endautocrossref %}



{% highlight python %}
details.merchant_data = "Invoice #123"
{% endhighlight %}

{% autocrossref %}
`merchant_data` (optional) add arbitrary data which will be sent back to the
receiver when the invoice is paid. You can use this to track your
invoices, although you can more reliably track payments by generating a
unique address for each payment and then tracking when it gets paid. 

The [`memo`][pp memo]{:#term-pp-memo}{:.term} field and the [`merchant_data`][pp merchant data]{:#term-pp-merchant-data}{:.term} field can be arbitrarily long,
but if you make them too long, you'll run into the 50,000 byte limit on
the entire PaymentRequest, which includes the often several kilobytes
given over to storing the certificate chain. As will be described in a
later subsection, the `memo` field can be used by the spender after
payment as part of a cryptographically-proven receipt.
{% endautocrossref %}




###### Derivable Data
{% autocrossref %}

Next, let's look at some information your CGI program can
automatically derive.
{% endautocrossref %}

{% highlight python %}
## Request creation time
details.time = int(time()) ## Current epoch (Unix) time

## Request expiration time
details.expires = int(time()) + 60 * 10  ## 10 minutes from now

## PaymentDetails complete; serialize it and store it in PaymentRequest
request.serialized_payment_details = details.SerializeToString()

## Serialized certificate chain
request.pki_data = x509.SerializeToString()

## Initialize signature field so we can sign the full PaymentRequest
request.signature = ""

## Sign PaymentRequest
request.signature = sign(private_key, request.SerializeToString(), "sha256")
{% endhighlight %}

Each line is described below.

{% highlight python %}
details.time = int(time()) ## Current epoch (Unix) time
{% endhighlight %}

{% autocrossref %}
`time`: (required) PaymentRequests must indicate when they were created
in number of seconds elapsed since 1970-01-01T00:00 UTC (Unix
epoch time format).
{% endautocrossref %}



{% highlight python %}
details.expires = int(time()) + 60 * 10  ## 10 minutes from now
{% endhighlight %}

{% autocrossref %}
`expires`: (optional) the PaymentRequest may also set an [`expires`][pp
expires]{:#term-pp-expires}{:.term} time after
which they're no longer valid. You probably want to give receivers
the ability to configure the expiration time delta; here we used the
reasonable choice of 10 minutes. If this request is tied to an order
total based on a fiat-to-satoshis exchange rate, you probably want to
base this on a delta from the time you got the exchange rate. 
{% endautocrossref %}



{% highlight python %}
request.serialized_payment_details = details.SerializeToString()
{% endhighlight %}

{% autocrossref %}
`serialized_payment_details`: (required) we've now set everything we need to create the
PaymentDetails, so we'll use the SerializeToString function from the
protocol buffer code to store the PaymentDetails in the appropriate
field of the PaymentRequest.
{% endautocrossref %}



{% highlight python %}
request.pki_data = x509.SerializeToString()
{% endhighlight %}

{% autocrossref %}
`pki_data` (required for signed PaymentRequests) serialize the certificate chain
[PKI data][pp PKI data]{:#term-pp-pki-data}{:.term} and store it in the
PaymentRequest
{% endautocrossref %}



{% highlight python %}
request.signature = ""
{% endhighlight %}

{% autocrossref %}
We've filled out everything in the PaymentRequest except the signature,
but before we sign it, we have to initialize the signature field by
setting it to a zero-byte placeholder.
{% endautocrossref %}




{% highlight python %}
request.signature = sign(private_key, request.SerializeToString(), "sha256")
{% endhighlight %}

{% autocrossref %}
`signature`:<!--noref--> (required for signed PaymentRequests) now we
make the [signature][ssl signature]{:#term-ssl-signature}{:.term} by
signing the completed and serialized PaymentRequest. We'll use the
private key we stored in memory in the configuration section and the
same hashing formula we specified in `pki_type` (sha256 in this case) 
{% endautocrossref %}




###### Output Code
{% autocrossref %}

Now that we have PaymentRequest all filled out, we can serialize it and
send it along with the HTTP headers, as shown in the code below.
{% endautocrossref %}

{% highlight python %}
print "Content-Type: application/bitcoin-paymentrequest"
print "Content-Transfer-Encoding: binary"
print ""
{% endhighlight %}

{% autocrossref %}
(Required) BIP71 defines the content types for PaymentRequests,
Payments, and PaymentACKs.
{% endautocrossref %}



{% highlight python %}
file.write(stdout, request.SerializeToString())
{% endhighlight %}

{% autocrossref %}
`request`: (required) now, to finish, we just dump out the serialized
PaymentRequest (which contains the serialized PaymentDetails). The
serialized data is in binary, so we can't use Python's print()
because it would add an extraneous newline.

The following screenshot shows how the authenticated PaymentDetails
created by the program above appears in the GUI from Bitcoin Core 0.9.

![Bitcoin Core Showing Validated Payment Request](/img/dev/en-btcc-payment-request.png)
{% endautocrossref %}




##### Payment
{% autocrossref %}

If the spender declines to pay, the wallet program will not send any
further messages to the receiver's server unless the spender clicks
another [URI][bitcoin uri] pointing to that server.  If the spender does decide to pay,
the wallet program will create at least one transaction paying each of
the outputs in the PaymentDetails section. The wallet may broadcast
the transaction or transactions, as Bitcoin Core 0.9 does, but it
doesn't need to.

Whether or not it broadcasts the transaction or transactions, the wallet
program composes a reply to the PaymentRequest; the reply is called the
Payment. [Payment][pp payment]{:#term-pp-payment}{:.term} contains four fields:

* `merchant_data`: (optional) an exact copy of the
  `merchant_data` from the PaymentDetails. This is
  optional in the case that the PaymentDetails doesn't provide
  `merchant_data`. Receivers should be aware that malicious spenders can
  modify the merchant data before sending it back, so receivers may wish to
  cryptographically sign it before giving it to the spender and then
  validate it before relying on it.

* [`transactions`][pp transactions]{:#term-pp-transactions}{:.term}: (required) one or more signed transactions which pay the outputs
  specified in the PaymentDetails.

<!-- BIP70 implies that refund_to is required (i.e. "one or more..."),
but Mike Hearn implied on bitcoin-devel that it's optional (i.e. "wallets have
to either never submit refund data, or always submit it"). 
I'll use the BIP70 version here until I hear differently. -harding -->

* [`refund_to`][pp refund to]{:#term-pp-refund-to}{:.term}: (required) one or more output scripts to which the
  receiver can send a partial or complete refund. As of this writing, a
  proposal is gaining traction to expire refund output scripts after a
  certain amount of time (not defined yet) so spenders don't need to
  worry about receiving refunds to addresses they no longer monitor.

* `memo`: (optional) a plain UTF-8 text memo sent to the receiver. It
  should not contain HTML or any other markup. Spenders should not depend
  on receivers reading their memos.

The Payment is sent to the [`payment_url`][pp payment
url]{:#term-pp-payment-url}{:.term} provided in the PaymentDetails.
The URL should be a HTTPS address to prevent a man-in-the-middle attack
from modifying the spender's `refund_to` output scripts. When sending the
Payment, the wallet program must set the following HTTP client headers:

{% endautocrossref %}

    Content-Type: application/bitcoin-payment
    Accept: application/bitcoin-paymentack

##### PaymentACK
{% autocrossref %}

The receiver's CGI program at the `payment_url` receives the [Payment][pp payment] and
decodes it using its Protocol Buffers code. The `transactions` are
checked to see if they pay the output scripts the receiver requested in
PaymentDetails and are then broadcast to the network (unless the network
already has them).

The CGI program checks the `merchant_data` parameter if necessary and issues
a [PaymentACK][]{:#term-paymentack}{:.term} (acknowledgment) with the following HTTP headers:
{% endautocrossref %}

    Content-Type: application/bitcoin-paymentack
    Content-Transfer-Encoding: binary

{% autocrossref %}
Then it sends another Protocol-Buffers-encoded message with one or two
fields:

* `payment`: (required) A copy of the the entire [Payment][pp payment] message (in
  serialized form) which is being acknowledged.

* `memo`: (optional) A plain UTF-8 text memo displayed to the spender
  informing them about the status of their payment.  It should not
  contain HTML or any other markup.  Receivers should not depend on
  spenders reading their memos.

The PaymentACK does not mean that the payment is final; it just means
that everything seems to be correct. The payment is final once the
payment transactions are block-chain confirmed to the receiver's
satisfaction.

However, the spender's wallet program should indicate to the spender that
the payment was accepted for processing so the spender can direct his or
her attention elsewhere.

{% endautocrossref %}



##### Receipts

{% autocrossref %}

Unlike PaymentRequest, PaymentDetails, [Payment][pp payment], and PaymentACK, there is
no specific [receipt][]{:#term-receipt}{:.term} object.  However, a cryptographically-verifyable
receipt can be derived from a signed PaymentDetails and one or more confirmed
transactions.

The PaymentDetails indicates what output scripts should be paid
(`script`), how much they should be paid (`amount`), and by when
(`expires`). The Bitcoin block chain indicates whether those outputs
were paid the requested amount and can provide a rough idea of when the
transactions were generated.  Together, this information provides
verifiable proof that the spender paid somebody with the
receiver's private SSL key.

{% endautocrossref %}


### Verifying Payment
{% autocrossref %}

As explained in the [Transactions][] and [Block Chain][] sections, broadcasting
a transaction to the network doesn't ensure that the receiver gets
paid. A malicious spender can create one transaction that pays the
receiver and a second one that pays the same input back to himself. Only
one of these transactions will be added to the block chain, and nobody
can say for sure which one it will be.

Two or more transactions spending the same input are commonly referred
to as a [double spend][]{:#term-double-spend}{:.term}.

Once the transaction is included in a block, double spends are
impossible without modifying block chain history to replace the
transaction, which is quite difficult. Using this system,
the Bitcoin protocol can give each of your transactions an updating confidence 
score based on the number of blocks which would need to be modified to replace 
a transaction. For each block, the transaction gains one [confirmation][]{:#term-confirmation}{:.term}. Since 
modifying blocks is quite difficult, higher confirmation scores indicate 
greater protection.

**0 confirmations**: The transaction has been broadcast but is still not 
included in any block. Zero confirmation transactions ([unconfirmed
transactions][]{:#term-unconfirmed-transactions}{:.term}) should generally not be 
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
For example, the `listunspent` RPC provides an array of every satoshi you can 
spend along with its confirmation score.

Although confirmations provide excellent double-spend protection most of the 
time, there are at least three cases where double-spend risk analysis can be 
required:

1. In the case when the program or its user cannot wait for a confirmation and 
wants to accept unconfirmed payments.

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

{% endautocrossref %}


### Issuing Refunds
{% autocrossref %}

Occasionally receivers using your applications will need to issue
refunds. The obvious way to do that, which is very unsafe, is simply
to return the satoshis to the output script from which they came.
For example:

* Alice wants to buy a widget from Bob, so Bob gives Alice a price and
  Bitcoin address. 

* Alice opens her wallet program and sends some satoshis to that
  address. Her wallet program automatically chooses to spend those
  satoshis from one of its [unspent outputs][utxo], an output corresponding to
  the Bitcoin address mjSk1Ny9spzU2fouzYgLqGUD8U41iR35QN.

* Bob discovers Alice paid too many satoshis. Being an honest fellow,
  Bob refunds the extra satoshis to the mjSk[...] address.

This seems like it should work, but Alice is using a centralized
multi-user web wallet which doesn't give unique addresses to each user,
so it has no way to know that Bob's refund is meant for Alice.  Now the
refund is a unintentional donation to the company behind the centralized
wallet, unless Alice opens a support ticket and proves those satoshis
were meant for her.

This leaves receivers only two correct ways to issue refunds:

* If an address was copy-and-pasted or a basic `bitcoin:` URI was used,
  contact the spender directly and ask them to provide a refund address.

* If a payment request was used, send the refund to the output
  listed in the `refund_to` field of the Payment message.

As discussed in the Payment section, `refund_to` addresses may come with
implicit expiration dates, so you may need to revert to contacting the
spender directly if the refund is being issued a long time after the
original payment was made.


{% endautocrossref %}


### Disbursing Income (Limiting Forex Risk)
{% autocrossref %}

Many receivers worry that their satoshis will be less valuable in the
future than they are now, called foreign exchange (forex) risk. To limit
forex risk, many receivers choose to disburse newly-acquired payments
soon after they're received.

If your application provides this business logic, it will need to choose
which outputs to spend first.  There are a few different algorithms
which can lead to different results.

* A merge avoidance algorithm makes it harder for outsiders looking
  at block chain data to figure out how many satoshis the receiver has
  earned, spent, and saved.

* A last-in-first-out (LIFO) algorithm spends newly acquired satoshis
  while there's still double spend risk, possibly pushing that risk on
  to others. This can be good for the receiver's balance sheet but
  possibly bad for their reputation.

* A first-in-first-out (FIFO) algorithm spends the oldest satoshis
  first, which can help ensure that the receiver's payments always
  confirm, although this has utility only in a few edge cases.

{% endautocrossref %}




#### Merge Avoidance
{% autocrossref %}

When a receiver receives satoshis in an output, the spender can track
(in a crude way) how the receiver spends those satoshis. But the spender
can't automatically see other satoshis paid to the receiver by other
spenders as long as the receiver uses unique addresses for each
transaction.

However, if the receiver spends satoshis from two different spenders in
the same transaction, each of those spenders can see the other spender's
payment.  This is called a [merge][]{:#term-merge}{:.term}, and the more a receiver merges
outputs, the easier it is for an outsider to track how many satoshis the
receiver has earned, spent, and saved.

[Merge avoidance][]{:#term-merge-avoidance}{:.term} means trying to avoid spending unrelated outputs in the
same transaction. For persons and businesses which want to keep their
transaction data secret from other people and competitors to the
greatest degree possible, it can be an important strategy.

A crude merge avoidance strategy is to try to always pay with the
smallest output you have which is larger than the amount being
requested. For example, if you have four outputs holding, respectively,
100, 200, 500, and 900 satoshis, you would pay a bill for 300 satoshis
with the 500-satoshi output. This way, as long as you have outputs
larger than your bills, you avoid merging.

More advanced merge avoidance strategies largely depend on enhancements
to the payment protocol which will allow payers to avoid merging by
intelligently distributing their payments among multiple outputs
provided by the receiver.

{% endautocrossref %}





#### Last In, First Out (LIFO)
{% autocrossref %}

Outputs can be spent as soon as they're received---even before they're
confirmed. Since recent outputs are at the greatest risk of being
double-spent, spending them before older outputs allows the spender to
hold on to older confirmed outputs which are much less likely to be
double-spent.

There are two closely-related downsides to LIFO:

* If you spend an output from one unconfirmed transaction in a second
  transaction, the second transaction becomes invalid if transaction
  malleability changes the first transaction. 

* If you spend an output from one unconfirmed transaction in a second
  transaction and the first transaction's output is successfully double
  spent to another output, the second transaction becomes invalid.

In either of the above cases, the receiver of the second transaction
will see the incoming transaction notification disappear or turn into an
error message.

Because LIFO puts the recipient of secondary transactions in as much
double-spend risk as the recipient of the primary transaction, they're
best used when the secondary recipient doesn't care about the
risk---such as an exchange or other service which is going to wait for
six confirmations whether you spend old outputs or new outputs.

LIFO should not be used when the primary transaction recipient's
reputation might be at stake, such as when paying employees. In these
cases, it's better to wait for transactions to be fully verified (see
the [Verification subsection][] above) before using them to make payments.

{% endautocrossref %}


#### First In, First Out (FIFO)
{% autocrossref %}

The oldest outputs are the most reliable, as the longer it's been since
they were received, the more blocks would need to be modified to double
spend them. However, after just a few blocks, a point of rapidly
diminishing returns is reached. The [original Bitcoin paper][bitcoinpdf]
predicts the chance of an attacker being able to modify old blocks,
assuming the attacker has 30% of the total network hashing power:

| Blocks | Chance of successful modification |
|--------|----------------------------------|
| 5      | 17.73523%                        |
| 10     | 4.16605%                         |
| 15     | 1.01008%                         |
| 20     | 0.24804%                         |
| 25     | 0.06132%                         |
| 30     | 0.01522%                         |
| 35     | 0.00379%                         |
| 40     | 0.00095%                         |
| 45     | 0.00024%                         |
| 50     | 0.00006%                         |

FIFO does have a small advantage when it comes to transaction fees, as
older outputs may be eligible for inclusion in the 50,000 bytes set
aside for no-fee-required high-priority transactions by miners running the default Bitcoin Core
codebase.  However, with transaction fees being so low, this is not a
significant advantage.

The only practical use of FIFO is by receivers who spend all or most
of their income within a few blocks, and who want to reduce the
chance of their payments becoming accidentally invalid. For example,
a receiver who holds each payment for six confirmations, and then
spends 100% of verified payments to vendors and a savings account on
a bi-hourly schedule.

{% endautocrossref %}


### Rebilling Recurring Payments
{% autocrossref %}

Automated recurring payments are not possible with decentralized Bitcoin
wallets. Even if a wallet supported automatically sending non-reversible
payments on a regular schedule, the user would still need to start the
program at the appointed time, or leave it running all the time
unprotected by encryption.

This means automated recurring Bitcoin payments can only be made from a
centralized server which handles satoshis on behalf of its spenders. In
practice, receivers who want to set prices in fiat terms must also let
the same centralized server choose the appropriate exchange rate.

Non-automated rebilling can be managed by the same mechanism used before
credit-card recurring payments became common: contact the spender and
ask them to pay again---for example, by sending them a PaymentRequest
`bitcoin:` URI in an HTML email.

In the future, extensions to the payment protocol and new wallet
features may allow some wallet programs to manage a list of recurring
transactions. The spender will still need to start the program on a
regular basis and authorize payment---but it should be easier and more
secure for the spender than clicking an emailed invoice, increasing the
chance receivers get paid on time.

{% endautocrossref %}


## Operating modes
{% autocrossref %}

Currently there are two primary methods of validating the block chain as a client: Full nodes, and SPV clients. Other methods, such as server-trusting methods, are not discussed as they are not recommended.
{% endautocrossref %}

### Full Node
{% autocrossref %}

The first and most secure model is the one followed by Bitcoin Core, also known as a “thick” or “full chain” client. This security model assures the validity of the ledger by downloading and validating blocks from the genesis block all the way to the most recently discovered block. This is known as using the *height* of a particular block to verify the client’s view of the network. 

For a client to be fooled, an adversary would have had to give a complete alternate block chain history that is of greater difficulty than the current “true” chain, which is impossible due to the fact that the longest chain is by definition the true chain. After the suggested 6 confirmations the ability to fool the client become intractable, as only a single honest network node is needed to have the complete state of the ledger. 

![Block Height Compared To Block Depth](/img/dev/en-block-height-vs-depth.svg)

{% endautocrossref %}

### Simplified Payment Verification (SPV) 
{% autocrossref %}

An alternative approach detailed in the [original Bitcoin paper][bitcoinpdf] is a client that only downloads the headers of blocks during the initial syncing process, and requesting transactions from full nodes as needed. This scales linearly with the height of the block chain, but at only 80 bytes per block header, or up to 4.2MB per year, regardless of total block size. 

As described in the white paper, the Merkle root in the block header along with a Merkle branch can prove to the SPV client that the transaction in question is embedded in a block in the block chain. This does not guarantee validity of the transactions that are embedded. Instead it demonstrates the amount of work required to perform a double-spend attack. 

The block's depth in the block chain corresponds to the cumulative difficulty that has been performed to build on top of that particular block. The SPV client knows the Merkle root and associated transaction information, and requests the respective Merkle branch from a full node. Once the Merkle branch has been retrieved, proving the existance of the transaction in the block, the SPV client can then look to block *depth* for the security of the transaction.

{% endautocrossref %}

#### Potential SPV Weaknesses
{% autocrossref %}

If implemented naively, an SPV client has a few important weaknesses. 

First, while the SPV client can not be easily fooled into thinking a transaction is in a block when it is not, the reverse is not true. A full node can simply lie by omission, leading an SPV client to believe a transaction has not occurred. This can be considered a form of Denial of Service. One mitigation strategy is to connect to a number of full nodes, and send the requests to each node. However this can be defeated by network partitioning or Sybil attacks, since identities are essentially free, and can be bandwidth intensive. Care must be taken to ensure the client is not cut off from honest nodes.

Second, the SPV client only requests transactions from full nodes corresponding to keys it owns. If the SPV client downloads all blocks then discards unneeded ones, this can be extremely bandwidth intensive. If they simply ask full nodes for blocks with specific transactions, this allows full nodes a complete view of the public addresses that correspond to the user. This is a large privacy leak, and allows for tactics such as denial of service for clients, users, or addresses that are disfavored by those running full nodes, as well as trivial linking of funds. A client could simply spam many fake transaction requests, but this creates a large strain on the SPV client, and can end up defeating the purpose of thin clients altogether. 

To mitigate the latter issue, Bloom filters have been implemented as a method of obfuscation and compression of block requests. 
{% endautocrossref %}

#### Bloom Filters
{% autocrossref %}

A Bloom filter is a space-efficient probabilistic data structure that is used to test membership of an element. The data structure achieves great data compression at the expense of a prescribed false positive rate. 

A Bloom filter starts out as an array of n bits all set to 0. A set of k random hash functions are chosen, each of which output<!--noref--> a single integer between the range of 1 and n.

When adding an element to the Bloom filter, the element is hashed k times separately, and for each of the k outputs<!--noref-->, the corresponding Bloom filter bit at that index are set to 1. 

<!-- Add picture here from wikipedia to explain the bits -->

Querying of the Bloom filter is done by using the same hash functions as before. If all k bits accessed in the bloom filter are set to 1, this demonstrates with high probability that the element lies in the set. Clearly, the k indices could have been set to 1 by the addition of a combination of other elements in the domain, but the parameters allow the user to choose the acceptable false positive rate. 

Removal of elements can only be done by scrapping the bloom filter and re-creating it from scratch.

{% endautocrossref %}

#### Application of Bloom Filters 
{% autocrossref %}

Rather than viewing the false positive rates as a liability, it is used to create a tunable parameter that represents the desired privacy level and bandwidth tradeoff. A SPV client creates their Bloom filter, and sends it to a full node using the message `filterload`, which sets the filter for which transactions are desired. The command `filteradd` allows addition of desired data to the filter without needing to send a totally new Bloom filter, and `filterclear` allows the connection to revert to standard block discovery mechanisms. If the filter has been loaded, then full nodes will send a modified form of blocks, called a merkleblock. The merkleblock is simply the block header with the merkle branch associated with the set Bloom filter. 

An SPV client can not only add transactions as elements to the filter, but also public keys, data from input and outputs scripts, and more. This enables P2SH transaction finding.

If a user is more private-conscious, he can set the Bloom filter to include more false positives, at the expense of extra bandwidth used for transaction discovery. If a user is on a tight bandwidth budget, he can set the false-positive rate to low, knowing that this will allow full nodes a clear view of what transactions are associated with that client. 

**Resources:** [BitcoinJ](http://bitcoinj.org), a Java implementation of Bitcoin that is based on the SPV security model and Bloom filters. Used in most Android wallets.

Bloom filters were standardized for use via [BIP0037](https://github.com/bitcoin/bips/blob/master/bip-0037.mediawiki). Review the BIP for implementation details.

{% endautocrossref %}


<!-- As mentioned before, this could certainly be cut as it's still future work -->

### Future Proposals 
{% autocrossref %}

There are future proposals such as Unused Output Tree in the block chain (UOT) to find a more satisfactory middle-ground for clients between needing a complete copy of the block chain, or trusting that a majority of your connected peers are not lying. UOT would enable a very secure client using a finite amount of storage using a data structure that is authenticated in the block chain. These type of proposals are however in very early stages, and will require soft forks in the network. 

Until these types of operating modes are implemented, modes should be chosen based on the likely threat model, computing and bandwidth constraints, and liability in bitcoin value.  

**Resources:** [Original Thread on UOT](https://bitcointalk.org/index.php?topic=88208.0), [UOT Prefix Tree BIP Proposal](https://github.com/maaku/bips/blob/master/drafts/auth-trie.mediawiki)
{% endautocrossref %}

## P2P Network

{% autocrossref %}

The Bitcoin network uses simple methods to communicate between nodes, as well as perform peer discovery. The following section applies to both full nodes and SPV clients, with the caveat of SPV's Bloom filters taking the role of block discovery.

{% endautocrossref %}

### Peer Discovery

{% autocrossref %}

Bitcoin Core maintains a list of peers to connect to on startup. When a full node is started for the first time, it must be bootstrapped to the network. This is done automatically today in Bitcoin Core by a short list of trusted DNS seeds. The option `-dnsseed` can be set to define this behavior, though the default is `1`. DNS requests return a list of IP addresses that can be connected to. From there, the client can start connecting the Bitcoin network.

Alternatively, bootstrapping can be done by using the option `-seednode=<ip>`, allowing the user to predefine what seed server to connect to, then disconnect after building a peer list. Another method is starting Bitcoin Core with `-connect=<ip>` which disallows the node from connecting to any peers except those specified. Lastly, the argument `-addnode=<ip>` simply allows the user to add a single node to his peer list.

After bootstrapping, nodes send out a `addr` message containing their own IP to peers. Each peer of that node then forwards this message to a couple of their own peers to expand the possible pool of connections.  

To see which peers one is connected with and associated data, use the `getpeerinfo` RPC.

{% endautocrossref %}

### Connecting to Peers

{% autocrossref %}

Connecting to a peer is done by sending a `version` message, which contains your version number, block, and current time to the remote node. Once the message is received by the remote node, it must respond with a `verack` message, which may be followed by its own `version` message if the node desires to peer. 

Once connected, the client can send the remote node `getaddr` and `addr` messages to gather additional peers.

In order to maintain a connection with a peer, nodes by default will send a message to peers before 30 minutes of inactivity. If 90 minutes passes without a message being received by a peer, the client will assume that connection has closed.

{% endautocrossref %}

### Block Broadcasting

{% autocrossref %}

At the start of a connection with a peer, both nodes send `getblocks` messages containing the hash of the latest known block. If a peer believes they have newer blocks or a longer chain, that peer will send an `inv` message which includes a list of up to 500 hashes of newer blocks, stating that it has the longer chain. The receiving node would then request these blocks using the command `getdata`, and the remote peer would send via `block`<!--noref--> messages. After all 500 blocks have been processed, the node can request another set with `getblocks`, until the node is caught up with the network. Blocks are only accepted when validated by the receiving node.

New blocks are also discovered as miners publish their found blocks, and these messages are propogated in a similar manner. Through previously established connections, an `inv` message is sent with the new block hashed, and the receiving node requests the block via the `getdata` message. 

{% endautocrossref %}

### Transaction Broadcasting

{% autocrossref %}

In order to send a transaction to a peer, an `inv` message is sent. If a `getdata` response message is received, the transaction is sent using `tx`. The peer receiving this transaction also forwards the transaction in the same manner, given that it is a valid transaction. If the transaction is not put into a block for an extended period of time, it will be dropped from mempool, and the client of origin will have to re-broadcast the message. 

{% endautocrossref %}

### Misbehaving Nodes

{% autocrossref %}

Take note that for both types of broadcasting, mechanisms are in place to punish misbehaving peers who take up bandwidth and computing resources by sending false information. If a peer gets a banscore above the `-banscore=<n>` threshold, he will be banned for the number of seconds defined by `-bantime=<n>`, which is 86,400 by default.

{% endautocrossref %}

### Alerts

{% autocrossref %}

In case of a bug or attack,
the Bitcoin Core deverlopers provide a
[Bitcoin alert service](https://bitcoin.org/en/alerts) with an RSS feed
and users of Bitcoin Core can check the error field of the `getinfo` RPC
results to get currently active alerts for their specific version of
Bitcoin Core.

These messages are aggressively broadcasted using the `alert` message, being sent to each peer upon connect for the duration of the alert. 

These messages are signed by a specific ECDSA private key that only a small number of active developers control. 

**Resource:** More details about the structure of messages and a complete list of message types can be found at the [Protocol Specification](https://en.bitcoin.it/wiki/Protocol_specification) page of the Bitcoin Wiki.

{% endautocrossref %}

## Mining
{% autocrossref %}

Mining adds new blocks to the block chain, making transaction history
hard to modify.  Mining today takes on two forms:

* Solo mining, where the miner attempts to generate new blocks on his
  own, with the proceeds from the block reward and transaction fees
  going entirely to himself, allowing him to receive large payments with
  a higher variance (longer time between payments)

* Pooled mining, where the miner pools resources with other miners to
  find blocks more often, with the proceeds being shared among the pool
  miners in rough correlation to the amount of hashing power
  they each contributed, allowing the miner to receive small
  payments with a lower variance (shorter time between payments).

{% endautocrossref %}

### Solo Mining
{% autocrossref %}

As illustrated below, solo miners typically use `bitcoind` to get new
transactions from the network. Their mining software periodically polls
`bitcoind` for new transactions using the `getblocktemplate` RPC, which
provides the list of new transactions plus the public key to which the
coinbase transaction should be sent.

![Solo Bitcoin Mining](/img/dev/en-solo-mining-overview.svg)

The mining software constructs a block using the template (described below) and creates a
block header. It then sends the 80-byte block header to its mining
hardware (an ASIC) along with a target threshold (difficulty setting).
The mining hardware iterates through every possible value for the block
header nonce and generates the corresponding hash.

If none of the hashes are below the threshold, the mining hardware gets
an updated block header with a new Merkle root from the mining software;
this new block header is created by adding extra nonce data to the
coinbase field of the coinbase transaction.

On the other hand, if a hash is found below the target threshold, the
mining hardware returns the block header with the successful nonce to
the mining software. The mining software combines the header with the
block and sends the completed block to the network for addition to the
block chain.

{% endautocrossref %}

### Pool Mining
{% autocrossref %}

Pool miners follow a similar workflow, illustrated below, which allows
mining pool operators to pay miners based on their share of the work
done. The mining pool gets new transactions from the network using
`bitcoind`. Using one of the method discussed later, the miner's mining
software connects to the pool and requests the information it needs to
construct block headers.

![Pooled Bitcoin Mining](/img/dev/en-pooled-mining-overview.svg)

In pooled mining, the mining pool sets the target threshold a few orders
of magnitude higher (less [difficult][difficulty]) that the network
difficulty. This causes the mining hardware to return many block headers
which don't hash to a value eligible for inclusion on the block chain
but which do hash below the pool's target, proving (on average) that the
miner checked a percentage of the possible hash values.

The miner then sends to the pool a copy of the information the pool
needs to validate that the header will hash below the target and that
the the block of transactions referred to by the header Merkle root field
is valid for the pool's purposes. (This usually means that the coinbase
transaction must pay the pool.)

The information the miner sends to the pool is called a share because it
proves the miner did a share of the work. By chance, some shares the
pool receives will also be below the network target---the mining pool
sends these to the network to be added to the block chain.

The block reward and transaction fees that come from mining that block
are paid to the mining pool. The mining pool pays out a portion of
these proceeds to individual miners based on how many shares they generated. For
example, if the mining pool's target threshold is 100 times lower than
the network target threshold, 100 shares will need to be generated on
average to create a successful block, so the mining pool can pay 1/100th
of its payout for each share received.  Different mining pools use
different reward distribution systems based on this basic share system.
{% endautocrossref %}

### Block Prototypes
{% autocrossref %}

In both solo and pool mining, the mining software needs to get the
information necessary to construct block headers. This subsection
describes, in a linear way, how that information is transmitted and
used. However, in actual implementations, parallel threads and queuing
are used to keep ASIC hashers working at maximum capacity,

{% endautocrossref %}

#### `getwork` RPC
{% autocrossref %}

The simplest and earliest method was the now-deprecated Bitcoin Core
`getwork` RPC, which constructs a header for the miner directly. Since a
header only contains a single 4-byte nonce good for about 4 gigahashes,
many modern miners need to make dozens or hundreds of `getwork` requests
a second. Solo miners may still use `getwork`, but most pools today
discourage or disallow its use.
{% endautocrossref %}

#### `getblocktemplate` RPC
{% autocrossref %}

An improved method is the Bitcoin Core `getblocktemplate` RPC. This
provides the mining software with much more information:

1. The information necessary to construct a coinbase transaction
   paying the pool or the solo miner's `bitcoind` wallet.

2. A complete dump of the transactions `bitcoind` or the mining pool
   suggests including in the block, allowing the mining software to
   inspect the transactions, optionally add additional transactions, and
   optionally remove non-required transactions.

3. Other information necessary to construct a block header for the next
   block: the block version, previous block hash, and bits (target).

4. The mining pool's current target threshold for accepting shares. (For
   solo miners, this is the network target.)

Using the transactions received, the mining software adds a nonce to the
coinbase extra nonce field and then converts all the transactions into a
Merkle tree to derive a Merkle root it can use in a block header.
Whenever the extra nonce field needs to be changed, the mining software
rebuilds the necessary parts of the Merkle tree and updates the time and
Merkle root fields in the block header.

Like all `bitcoind` RPCs, `getblocktemplate` is sent over HTTP. To
ensure they get the most recent work, most miners use [HTTP longpoll][] to
leave a `getblocktemplate` request open at all times. This allows the
mining pool to push a new `getblocktemplate` to the miner as soon as any
miner on the peer-to-peer network publishes a new block or the pool
wants to send more transactions to the mining software.
{% endautocrossref %}

#### Stratum
{% autocrossref %}

A widely used alternative to `getblocktemplate` is the [Stratum mining
protocol][]. Stratum focuses on giving miners the minimal information they
need to construct block headers on their own:

1. The information necessary to construct a coinbase transaction
   paying the pool.

2. The parts of the Merkle tree which need to be re-hashed to
   create a new Merkle root when the coinbase transaction is
   updated with a new extra nonce. The other parts of the Merkle
   tree, if any, are not sent, limiting the amount of data which needs
   to be sent to (at most) about a kilobyte at current transaction
   volume.

3. All of the other non-Merkle root information necessary to construct a
   block header for the next block.

4. The mining pool's current target threshold for accepting shares.

Using the coinbase transaction received, the mining software adds a
nonce to the coinbase extra nonce field, hashes the coinbase
transaction, and adds the hash to the received parts of the Merkle tree.
The tree is hashed as necessary to create a Merkle root, which is added
to the block header information received. Whenever the extra nonce field
needs to be changed, the mining software updates and re-hashes the
coinbase transaction, rebuilds the Merkle root, and updates the header
Merkle root field.

Unlike `getblocktemplate`, miners using Stratum cannot inspect or add
transactions to the block they're currently mining. Also unlike
`getblocktemplate`, the Stratum protocol uses a two-way TCP socket which
stays open, so miners don't need to use longpoll to ensure they receive
immediate updates from mining pools when a new block is broadcast to the
peer-to-peer network.

<!-- SOMEDAY: describe p2pool -->

**Resources:** For more information, please see the [BFGMiner][] mining
software licensed under GPLv3 or the [Eloipool][] mining pool software
licensed under AGPLv3. A number of other mining and pool programs
exist, although many are forks of BFGMiner or Eloipool.

{% endautocrossref %}



{% include references.md %}





<!--#md#</div>#md#-->

<script>updateToc();</script>
