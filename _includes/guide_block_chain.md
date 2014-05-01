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

~~~
       ABCDEEEE .......Merkle root
      /        \
   ABCD        EEEE
  /    \      /
 AB    CD    EE .......E is paired with itself
/  \  /  \  /
A  B  C  D  E .........Transactions
~~~

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
