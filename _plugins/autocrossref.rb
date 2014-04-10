module Jekyll

  class AutoCrossRefBlock < Liquid::Block

    def initialize(tag_name, text, tokens)
      super
    end

    def render(context)
      output = super

      ## TODO: put term defs in a separate file 
      terms = { 
        ## "pattern to match in file" => "reference to give it",
        ## ^^^^ produces \/\/\/
        ## [pattern to match in file][reference to give it]

        ## Terms sorted alphabetically (for the sake of human editors)
        #
        ## Recommendation: use base ("") for singular; use references
        ## for plurals. E.g.: "block" => "", "blocks" => "block"
        #
        ## Mandatory: terms that will be used by themselves inside ``
        ## need to have their `` form defined. E.g.: "script" => "",
        ## "`script`" => "script"
        #
        ## Terms inside longer `` spans won't work. You'll have to stop
        ## using autocrossref mode to get them to work correctly. E.g.:
        ## `you can't put script here` unless you prefix it with 
        ## {% endautocrossref %}
        "addresses" => "address",
        "block" => "",
        "block chain" => "", 
        "block header" => "",
        "blocks" => "block",
        "confirmed transactions" => "",
        "double spend" => "",
        "double spending" => "double spend",
        "inputs" => "input",
        "input" => "",  ## This could be troublesome
        "merkle root" => "",
        "merkle tree" => "",
        "miner" => "",
        "outputs" => "output",
        "output" => "", ## This could be troublesome
        "peer-to-peer network" => "network",
        "proof of work" => "",
        #satoshi -- Recommend no autoxref so we can use Satoshi (name) without linking to satoshis (unit)
        "satoshis" => "",
        "standard transaction" => "standard script",
        #transaction -- Recommend we don't autocrossref this; it occurs to often
        "transaction fee" => "",
        "txid" => "",
        "txids" => "txid",
        "utxo" => "",
        "utxos" => "utxo",

      }

      ## Sort terms by reverse length, so longest matches get linked
      ## first (e.g. "block chain" before "block"). Otherwise short
      ## terms would get linked first and there'd be nothing for long
      ## terms to link to.
      terms.sort_by { |k, v| -k.length }.each { |term|
        term[0] = Regexp.escape(term[0])

        ## Replace literal space with \s to match across newlines. This
        ## can do weird things if you don't end sentences with a period,
        ## such as linking together "standard" and "transactions" in
        ## something like this:
        ### * RFC1234 is a standard
        ###
        ### Transactions are cool
        term[0].gsub!('\ ', '\s+')

        output.gsub!(/
            \b    ## Word boundry
            #{term[0]}  ## Find our key
            (?![^\[]*\])  ## No subst if key inside [brackets]
            (?![^\{]*\})  ## No subst if key inside {braces}
            (?![^\(]*(\.svg|\.png))  ## No subst if key inside an image name. This 
		     ## simple regex has the side effect that we can't
		     ## use .svg or .png in non-image base text; if that
		     ## becomes an issue, we can devise a more complex
		     ## regex
            \b   ## Word boundry
          /xmi, "[\\&][#{term[1]}]")
      }

      output
    end # terms.sort_by
  end # render(content)
end # AutoCrossRefBlock class 

Liquid::Template.register_tag('autocrossref', Jekyll::AutoCrossRefBlock)
