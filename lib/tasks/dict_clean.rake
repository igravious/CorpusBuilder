#
# useful methods for cleaning the _ dictionary terms
#

namespace :dictionary do
	namespace :clean do

		def argf_file
			begin
				STDERR.puts "Found file - #{ARGF.filename}"
			rescue
				STDERR.puts $!
			end
		end

		def skip
			argf_file
			ARGF.skip # skip clean:proper param
			argf_file
		end

		desc "John Smith -> Smith, John | John Smith"
		task proper: :environment do
			skip
			ARGF.each_with_index do |line, idx|
				# print ARGF.filename, ":", idx, ";", line
				words = line.split(' ')
				all_caps = true
				words.each do |word|
					if /[[:upper:]]/.match(word[0]).nil?
						all_caps = false
					end
				end
				if all_caps and words.length > 1
					entry = words.dup
					last = "#{entry.pop},"
					entry.unshift last
					entry = entry.join(' ')
					puts "#{entry} | #{line}"
				else
					puts line
				end
			end
		end

		# do they handle accented characters and non-latin scripts?
		desc "αδιαφορα [adiaphora] -> adiaphora | αδιαφορα [adiaphora]"
		task brackets: :environment do
			skip
			ARGF.each_with_index do |line, idx|
				# print ARGF.filename, ":", idx, ";", line
				if /(\p{Greek}+) \[(\X+)\]/.match(line).nil?
					puts line
				else
					puts "#{$~[2]} | #{line}"
				end
			end
		end

		desc "adiaphora | αδιαφορα [adiaphora] -> adiaphora"
		task strip: :environment do
			skip
			ARGF.each_with_index do |line, idx|
				# print ARGF.filename, ":", idx, ";", line
				if /(\X+) \| (\X+)/.match(line).nil?
					puts line
				else
					puts "#{$~[1]}"
				end
			end
		end

		# i fixed up the file
		# abbrv. -> abbreviation
		desc "Absorption (Abs.) -> Absorption"
		task parens: :environment do
			skip
			ARGF.each_with_index do |line, idx|
				# print ARGF.filename, ":", idx, ";", line
				if /(\X+) \(\X+\)/.match(line).nil?
					puts line
				else
					puts "#{$~[1]} | #{line}"
				end
			end
		end

		# i fixed up the file, could have done it programmatically
		# foo /bar -> foo / bar
		# foo / bar baz -> foo baz / foo bar
		desc "continence / incontinence -> continence"
		task remove_slash: :environment do
			skip
			ARGF.each_with_index do |line, idx|
				# print ARGF.filename, ":", idx, ";", line
				if /(\X+?) \/ (\X+) \| (\X+)/.match(line).nil?
					if /(\X+?) \/ (\X+)/.match(line).nil?
						puts line
					else
						puts "#{$~[1]} | #{line}"
					end
				else
					puts "#{$~[1]} | #{$~[3]}"
				end
			end
		end

		desc "continence/incontinence -> continence / incontinence"
		task align_slash: :environment do
			skip
			ARGF.each_with_index do |line, idx|
				# print ARGF.filename, ":", idx, ";", line
				if /(.+\w)\/(\w.+)/.match(line).nil?
					puts line
				else
					puts line
				end
			end
		end

	end # namespace :clean
end # namespace :dictionary
