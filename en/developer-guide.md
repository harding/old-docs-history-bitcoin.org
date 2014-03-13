---
layout: base
lang: en
id: developer-guide
title: "Developer Guide - Bitcoin"
---

# Bitcoin Developer Guide

<p class="summary">Find detailed information about the Bitcoin protocol and related specifications.</p>

<div markdown="1" class="index">

* Table of content
{:toc}

</div>



## The Bitcoin Block Chain

The block chain provides Bitcoin's ledger, a timestamped record of all
confirmed transactions.  Under normal conditions, a new block of
transactions is added to the block chain approximately every 10 minutes
and historic blocks are left unchanged.

This document will describe for developers this normal operating
condition and then describe both common and uncommon non-normal
operating conditions where recent block chain history becomes mutable.
Tools for retrieving and using block chain data are provided throughout.

### Block Chain Overview

![Block Chain Overview](/img/dev/blockchain-overview.png)

Figure 1 shows a simplified version of a three-block block chain.
Each **block** of transactions is hashed to create a **Merkle root**, which is
stored in the **block header**.  Each block then stores the hash of the
previous block's header, chaining the blocks together.  This ensures a
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
spend**---an attempt to spend the same bitcoins twice.

Outputs are not the same as Bitcoin addresses. You can use the same
address in multiple transactions, but you can only use each output once.
Outputs are tied to **transaction identifiers (TXIDs)**, which are the hashes
of complete transactions.

Because each output of a particular transaction can only be spent once,
all transactions included in the block chain can be categorized as either
**Unspent Transaction Outputs (UTXOs)** or spent transaction outputs. For a
payment to be valid, it must only use UTXOs as inputs.

Bitcoins cannot be left in a UTXO after it is spent or they will be
irretrievably lost, so any difference between the number of bitcoins in a
transaction's inputs and outputs is given as a
**transaction fee** to the Bitcoin **miner** who creates the block
containing that transaction. For example, in Figure 2 each transaction
spends 10 millibits fewer than it receives from its combined inputs,
effectively paying a 10 millibit transaction fee.

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

Each block can set its own target, but new blocks will only be added to
the block chain if their target is at least as challenging as a
**difficulty** value expected by the peer-to-peer network. Every 2,016
blocks, the network uses timestamps stored in each block header to
calculate the number of seconds elapsed between generation of the first
and last of those last 2,016 blocks. The ideal value is 1,209,600
seconds (two weeks).

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
by their **block height**---the number of blocks between them and the first Bitcoin
block (block 0, most commonly known as the **genesis block**). For example,
block 2016 is where difficulty could have been first adjusted.

![Common And Uncommon Block Chain Forks](/img/dev/blockchain-fork.png)

Multiple blocks can all have the same block height, as is common when
two or more miners each produce a block at roughly the same time.  This
creates an apparent **fork** in the block chain, as shown in figure 3.

When miners produce simultaneous blocks at the end of the block chain, each
peer individually chooses which block to trust.  (In the absence of
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

#### Double Spend Risk Analysis

The properties of the block chain described above ensure that transaction
history is more difficult to modify the older it gets. But your programs
will likely be used to automatically provide valuable and
irrevocable services based on recent transactions where transaction
history is more malleable.

In particular, your programs should protect against attackers who get
your program to perform a costly action but who then use a double spend
to avoid paying for the value received.

The Bitcoin protocol can give each of your transactions an updating
confidence score based on the number of blocks which would need to be
modified to create a double spend. For each block that would need to be
modified, the transaction gains one **confirmation.** Since modifying
blocks is quite difficult, higher confirmation scores indicate greater
double spend protection.

New transactions start with zero confirmations because they are not
included in any blocks. A double spender who knows that your software
performs an action in response to an unconfirmed transaction can create
one transaction that pays you, wait for you to see the payment, and then
create a double spend with a higher transaction fee that pays the same
UTXO back to himself. Profit-motivated miners will attempt to put the
transaction with the higher fee in a block, confirming it and leaving
you without the bitcoins you thought you received.

We do not recommend that naïve programs trust **zero confirmation
transactions.** If you cannot wait for the next block to be mined before
performing a costly action, you may try one of the methods described in
the next section to acquire information about transaction reliability
from outside the Bitcoin protocol.

Double spend risk decreases dramatically once the transaction is
included in a block:

* One confirmation indicates the transaction was included in the most
  recent block. As explained in the forking section above, the most
  recent block gets replaced fairly often by accident, so a one
  confirmation double spend is still a real possibility, although
  a serial double spender would probably fail much more often than he
  would succeed.

* Two confirmations indicates the most recent block was chained to the
  block which includes the transaction. As of March 2014, accidental
  two block replacements were exceedingly rare, and a purposeful two
  block replacement attack would require very expensive equipment and a
  lot of luck.

* Six confirmations indicates the network has spent about an hour
  working to protect your transaction against double spends. Even a
  reasonably lucky attacker would require a large percentage of the
  total network hashing power to replace six blocks. Although the number
  six is somewhat arbitrary, we recommend that software handling
  high-value transactions, or otherwise at risk for fraud, wait for at
  least six confirmations before marking a payment as accepted.

Bitcoin Core provides several RPCs which can provide your program
with the confirmation score for transactions in your wallet or arbitrary
transactions. For example, the `listunspent` RPC provides an array of
every bitcoin you can spend along with its confirmation score.

#### Non-Protocol Double Spend Risk Analysis

Although the Bitcoin protocol provides excellent double spend protection
most of the time, there are at least two situations where programs may
want to look outside the protocol for special double spend risk analysis:

1. In the case of an implementation bug or prolonged attack against
   Bitcoin which makes the system less reliable than expected.

2. In the case when the program or its user wants to accept zero confirmation
   payments.

The best source for double spend protection outside Bitcoin is human
intelligence. 

In the case of a bug or attack, bad news about Bitcoin spreads fast, so
merchants may hear about problems. The Bitcoin Foundation provides a
[Bitcoin alert service](https://bitcoin.org/en/alerts) with an RSS feed
and users of Bitcoin Core can check the error field of the `getinfo` RPC
results to get currently active alerts for their specific version of
Bitcoin Core.

In the case of zero confirmation payments, fraudsters may act
differently than legitimate customers, letting savvy merchants manually
flag them as high risk before accepting payment.

To take advantage of human intelligence, your program should provide an
easy to trigger safe mode which stops automatic payment acceptance on a
global basis, a per-customer basis, or both.  Like the big-red-button
type of safety switches found in dangerous factories, you may want to
make the option easy to enable even by relatively unprivileged users of
your program.

Another source of double spend risk analysis can be acquired from
third-party services which aggregate information about the current
operation of the Bitcoin network, such as the website BlockChain.info.

These third-party services connect to large numbers of Bitcoin peers and
track how they differ from each other. For example, they can detect a
fork when different peers report a different block header hash at the
same block height; if the fork extends for more than one or two blocks,
indicating a possible attack, your program can go into a safe mode. 

The service can also compare unconfirmed transactions among all
connected peers to see if any UTXO is used in multiple unconfirmed
transactions, indicating a double spend attempt; if a double spend
attempt is detected, your program can refuse acceptance of the payment
until it is confirmed.

To use a third-party service for additional risk analysis, check the
service's API documentation.

### Implementation Details: Block Contents

This section describes version 2 blocks, which are any blocks with a
block height greater than 227,835. (Version 1 and version 2 blocks were
intermingled for some time before that point.) Future block versions may
break compatibility with the information in this section; to determine
the current block version number, find the current block height by
checking the blocks field of the `getinfo` RPC results:

    > getinfo
    ...
    "blocks" : 289802,
    ...

Then get the hash of that block using the `getblockhash` RPC:

    > getblockhash 289802
    0000000000000000fbff61fa45f4b218db7745c4d89990725c35dbdaa446bacb

Finally check the version field of that block using the `getblock` RPC:

    > getblock 0000000000000000fbff61fa45f4b218db7745c4d89990725c35dbdaa446bacb
    ...
    "version" : 2,
    ...

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
field of the generation transaction (described below), so block height
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
   fix bugs.  As of block height 227,836, all blocks use version number
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

5. *Bits* translates into the target threshold value---the maximum allowed value
   for this block's hash. The bit value must be at least as challenging
   as the network difficulty at the time the block was mined.

6. The *nonce* is an arbitrary input that miners can change to test different
   hash values for the header until they find a hash value less than or
   equal to the target threshold.  If all values within the nonce's four
   bytes are tested, the time can be changed by one second or the
   generation transaction (described below) can be changed and the Merkle
   root updated.

#### Transaction Data

Every block must include one or more transactions. Exactly one of these
transactions must be a generation transaction which should collect and
spend any transaction fees paid by transactions included in this block.
All blocks with a block height less than 6,930,000 are entitled to
receive a block reward of at least one newly-created satoshi, which also
should be spent in the generation transaction. A generation transaction
is invalid if it tries to spend more satoshis than are available from
the transaction fees and block reward.

The generation transaction has the same basic format as any other
transaction, but it references a single non-existent UTXO and a special
coinbase field replaces the field which would normally hold a script and
signature. In version 2 blocks, the coinbase parameter must begin with
the current block's block height and may contain additional arbitrary
data or a script up to a maximum total of 100 bytes.

Because they contain the special coinbase field, generation transactions
are commonly called coinbase transactions.

The UTXO of a generation transaction has the special condition that it
cannot be spent (used as an input) for at least 100 blocks.  This
helps prevent a miner from spending the transaction fees and block
reward from a block that will later be orphaned (destroyed) after a
block fork.

Blocks are not required to include any non-generation transactions, but
miners almost always do include additional transactions in order to
collect their transaction fees.

All transactions, including the generation transaction, are encoded into
blocks in binary rawtransaction format prefixed by a block transaction
sequence number.

#### Example Block And Generation Transaction

The first block with more than one transaction is at block height 170.
We can get the hash of block 170's header with the `getblockhash` RPC:

    > getblockhash 170
    00000000d1145790a8694403d4063f323d499e655c83426834d4ce2f8dd4a2ee

We can then get a decoded version of that block with the `getblock` RPC:

    > getblock 00000000d1145790a8694403d4063f323d499e655c83426834d4ce2f8dd4a2ee
    {
        "hash" : "00000000d1145790a8694403d4063f323d499e655c83426834d4ce2f8dd4a2ee",
        "confirmations" : 289424,
        "size" : 490,
        "height" : 170,
        "version" : 1,
        "merkleroot" : "7dac2c5666815c17a3b36427de37bb9d2e2c5ccec3f8633eb91a4205cb4c10ff",
        "tx" : [
            "b1fea52486ce0c62bb442b530a3f0132b826c74e473d1f2c220bfa78111c5082",
            "f4184fc596403b9d638783cf57adfe4c75c605f6356fbc91338530e9831e9e16"
        ],
        "time" : 1231731025,
        "nonce" : 1889418792,
        "bits" : "1d00ffff",
        "difficulty" : 1.00000000,
        "previousblockhash" : "000000002a22cfee1f2c846adbd12b3e183d4f97683f85dad08a79780a84bd55",
        "nextblockhash" : "00000000c9ec538cab7f38ef9c67a95742f56ab07b0a37c5be6b02808dbfb4e0"
    }

Note: the only values above which are actually part of the block are size,
version, merkleroot, time, nonce, and bits. All other values shown
are computed.

The first transaction identifier (txid) listed in the tx array is, in
this case, the generation transaction. The txid is a hash of the raw
transaction. We can get the actual raw transaction in hexadecimal format
from the block chain using the `getrawtransaction` RPC with the txid:

    > getrawtransaction b1fea52486ce0c62bb442b530a3f0132b826c74e473d1f2c220bfa78111c5082
    01000000...00000000  ### 130 bytes elided for readability

We can expand the raw transaction hex into a human-readable format by
passing the raw transaction to the `decoderawtransaction` RPC:

    > decoderawtransaction 01000000...00000000  ### 130 bytes elided
    {
        "txid" : "b1fea52486ce0c62bb442b530a3f0132b826c74e473d1f2c220bfa78111c5082",
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
                    "asm" : "04d46c4968bde02899d2aa0963367c7a6ce34eec332b32e42e5f3407e052d64ac625da6f0718e7b302140434bd725706957c092db53805b821a85b23a7ac61725b OP_CHECKSIG",
                    "hex" : "4104d46c4968bde02899d2aa0963367c7a6ce34eec332b32e42e5f3407e052d64ac625da6f0718e7b302140434bd725706957c092db53805b821a85b23a7ac61725bac",
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

TODO, Relevant links:

* [https://en.bitcoin.it/wiki/Transactions](https://en.bitcoin.it/wiki/Transactions)
* [https://en.bitcoin.it/wiki/Technical_background_of_Bitcoin_addresses](https://en.bitcoin.it/wiki/Technical_background_of_Bitcoin_addresses)
* [https://en.bitcoin.it/wiki/Script](https://en.bitcoin.it/wiki/Script)
* [https://en.bitcoin.it/wiki/Contracts](https://en.bitcoin.it/wiki/Contracts)
* [https://github.com/bitcoin/bips/blob/master/bip-0011.mediawiki (n of m transactions)](https://github.com/bitcoin/bips/blob/master/bip-0011.mediawiki)
* [https://github.com/bitcoin/bips/blob/master/bip-0013.mediawiki (P2SH)](https://github.com/bitcoin/bips/blob/master/bip-0013.mediawiki)
* [https://github.com/bitcoin/bips/blob/master/bip-0016.mediawiki (P2SH)](https://github.com/bitcoin/bips/blob/master/bip-0016.mediawiki)

### Basics

### Change addresses

### Complex contrats

### Transaction fees

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
