#!/usr/bin/env ruby

# has to be fed in reverse order, from least to most

# 37396 is a magic number, if you spot it, the number of lines in the dump

require 'pry'

CUTOFF=3

def nuke(msg, idx, term)
	STDERR.print ARGF.filename, ': ', msg, ': ', idx, '; ', "#{term}\n"
end

STOPWORDS=['edition', 'book', 'chapter', 'adelaide', 'texas']
# 'I' as a roman numeral was probably mis-parsed by Saffron
NUMERALS=['ii', 'iii', 'iv', 'v', 'vi', 'vii', 'viii', 'ix', 'x', 'xi', 'xii', 'xiii', 'xiv', 'xv', 'xvi', 'ch']
# 'thou art' :(
ARCHAISMS=['thy', 'thou', 'thine', 'thee', 'mine', 'hath', 'ye', 'nay', 'showeth']
# don't downcase
PROPER=['God']
# proabable hyphenated words
OK_HYPHENS=['pre-Darwinian',
						'ante-Christian',
            'Christian-Teutonic',
            'Graeco-Roman',
            'Ural-Altaic',
            'Psycho-Analytic',
            'Greatest-Happiness',
						'post-Kantian',
            'Anglo-North',
            'Gnostic-Theosophic',
            'Dalai-Lama',
            'Father-in-Law',
            'Vice-President',
            'Free-as-a-Bird',
            'Teutonico-Christian',
            'anti-Christian',
            'World-Cause',
            'Victoriously-Perfect',
            'Port-Royal',
            'pre-Aryan',
            'Anglo-American',
            'pre-Christian',
            'Kant-Fichteian',
            'States-General',
            'East-Indies',
            'Non-Contradiction',
            'Self-Surpassing',
            'Ass-Festival',
            'Non-Ego',
            'not-Self',
            'non-Ego']

# ﬁ → fi

# eventually must have _only_ text, or very light markup that topic modeller/inferer understands

master = []

ARGF.each_with_index do |line, idx|
	#STDERR.print ARGF.filename, ': ', idx, '; ', line
	begin
		totes, term, pattern = line.split(', ')
		the_sub_terms = term.split(' ')
		pattern.strip!
		the_sub_patterns = pattern.split(' ')
		# raise "pattern: #{pattern} doesn't match"
		if NUMERALS.any? {|num| the_sub_terms.map(&:downcase).include?(num) ? true : false}
			nuke "NUMERAL", idx, term
		elsif ARCHAISMS.any? {|arch| the_sub_terms.map(&:downcase).include?(arch) ? true : false}
			nuke "ARCHAISM", idx, term
		elsif !(term =~ /^[[:alpha:] -]+[[:alpha:]]+--[[:alpha:]][[:alpha:] -]+$/).nil?
		  nuke "DOUBLE --", idx, term
		elsif STOPWORDS.any? {|stop| !(term.downcase =~ /.*#{stop}.*/).nil? ? true : false}
			nuke "STOPWORD", idx, term
		elsif !(term =~ /\b[[:upper:]]+\b/).nil?
			nuke "ALL CAPS", idx, term
		elsif (the_sub_terms.length != the_sub_patterns.length) and !OK_HYPHENS.any? {|hype| the_sub_terms.include?(hype) ? true : false}
			nuke "BAD HYPHEN", idx, term
		else
			last = the_sub_patterns.last
			common = (last == 'NN' or last == 'NNS')
			upcase = term.scan(/[[:upper:]]/).length
			down = (PROPER.include?(term) ? term : term.downcase) 
			master[idx] = {totes: totes.to_i, term: term, down: down, pattern: pattern, common: common, upcase: upcase, processed: false}
		end
	rescue => e
		# STDERR.puts e.message
		# STDERR.puts e.backtrace
		nuke "OOF! #{e}", idx, term
		# binding.pry
	end
end

def output(totes, term, pattern)
	STDOUT.puts "#{totes}, #{term}, #{pattern}"
end

max = master.length
bump = []
new_totes = 0
old_bump_length = 0

master.each_with_index do |line, idx|
	# skip over holes created by STOPWORDS, ARCHAISMS, and NUMERALS
	if not line.nil?
		if bump.length != old_bump_length
			# binding.pry
			# STDERR.puts "#{line[:totes]}; index - #{idx}; bump length - #{bump.length}"
			old_bump_length = bump.length
		end
		# make sure new_totes tracks current totes
		if line[:totes] > new_totes
			new_totes = line[:totes]
		end
		del = 0
		bump.each do |b|
			if b[:totes] < new_totes
				output(b[:totes], b[:term], b[:pattern])
				del += 1
			else
				break
			end
		end
		bump.slice!(0,del)
		# ignore lines that have been processed
		if not line[:processed]
			line[:processed] = true
			j = idx+1
			matched = []
			while j < max
				if not master[j].nil? and (line[:down] == master[j][:down])
					master[j][:processed] = true
					matched << j
				end
				j += 1
			end
			if matched.length > 0
				matched << idx
				common = -1
				acc = 0
				matched.each do |i|
					acc += master[i][:totes]
					if master[i][:common]
						if 0 <= common
							# choose the one with the most lowercase
							if master[i][:upcase] < master[common][:upcase]
								common = i
							end
						else # first one
							common = i
						end
					end
				end
				# ignore the rest for the moment
				if acc >= CUTOFF
					if 0 > common
						matched.each do |i|
							nuke "UNCOMMON", i, "#{master[i][:totes]}, #{master[i][:term]}, #{master[i][:pattern]}"
						end
					else
						ins = 0
						bump.each_with_index do |b, i|
							if b[:totes] < acc
								ins = i+1
							else
								break
							end
						end
						# insert accumulated match in sequential order
						bump.insert(ins,master[common].dup)
						bump[ins][:totes] = acc
					end
				end
			else
				output(line[:totes], line[:term], line[:pattern]) if line[:totes] >= CUTOFF
			end
		end
	end
end

del = 0
bump.each_with_index do |b|
		output(b[:totes], b[:term], b[:pattern])
		del += 1
end
bump.slice!(0,del)
