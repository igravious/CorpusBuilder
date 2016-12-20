#!/usr/bin/env ruby

def nuke msg, idx, term
	STDERR.print ARGF.filename, ': ', msg, ': ', idx, '; ', "#{term}\n"
end

ARGF.each_with_index do |line, idx|
	#STDERR.print ARGF.filename, ': ', idx, '; ', line
	begin
		totes, term, pattern = line.split(', ')
		term.gsub!('ﬀ','ff') # or match them
		term.gsub!('ﬁ','fi')
		term.gsub!('æ','ae')
		term.gsub!('œ','oe')
		pattern.strip!
		the_sub_terms = term.split(' ')
		if 1 < the_sub_terms.length
			if (2 == the_sub_terms.length and pattern =~ /JJ NN[SP]?$/)
				# the qualifier of a term is rarely a term
				# STDOUT.puts "#{the_sub_terms[0]}"
				# but the head of a phrase is (i think)
				STDOUT.puts "#{the_sub_terms[1]}"
				STDOUT.puts "#{the_sub_terms[1]}, #{the_sub_terms[0]}"
			elsif (3 == the_sub_terms.length and "JJ JJ NN" == pattern) or (2 == the_sub_terms.length and "JJ JJ NNS" == pattern)
				STDOUT.puts "#{the_sub_terms[2]}"
				STDOUT.puts "#{the_sub_terms[2]}, #{the_sub_terms[0]} #{the_sub_terms[1]}"
			elsif (2 == the_sub_terms.length and pattern =~ /NN NN[SP]?$/)
				# the qualifier of a term is rarely a term
				# STDOUT.puts "#{the_sub_terms[0]}"
				# but the head of a phrase is (I think)
				STDOUT.puts "#{the_sub_terms[1]}"
				STDOUT.puts "#{the_sub_terms[1]}, #{the_sub_terms[0]}"
			elsif (2 == the_sub_terms.length and pattern =~ /NNP NN[SP]?$/)
				STDOUT.puts "#{the_sub_terms[1]}"
				STDOUT.puts "#{the_sub_terms[1]}, #{the_sub_terms[0]}"
			elsif (pattern =~ /.+IN NN[SP]?$/)
				STDOUT.puts "#{the_sub_terms.last}, #{the_sub_terms[0..-2].join(' ')}"
			elsif (3 == the_sub_terms.length and "NN CC NN" == pattern)
				STDOUT.puts "#{the_sub_terms[0]}"
				STDOUT.puts "#{the_sub_terms[0]}, #{the_sub_terms[0]} #{the_sub_terms[1]} #{the_sub_terms[2]}"
				STDOUT.puts "#{the_sub_terms[2]}"
				STDOUT.puts "#{the_sub_terms[2]}, #{the_sub_terms[2]} #{the_sub_terms[1]} #{the_sub_terms[0]}"
			else
				# for the moment :)
				nuke "PATTERN #{pattern}", idx, term
			end
		else # pick all 1 word
			STDOUT.puts term
		end
	rescue => e
		nuke "#{e.message}", idx, term
	end
end
