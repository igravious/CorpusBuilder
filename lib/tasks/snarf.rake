require 'watir-webdriver'
require 'headless'

namespace :snarf do
  desc "Slurp entries from Dictionary of Philosophy"
  task phil_dic: :environment do

		headless = Headless.new
		headless.start
		dic = Dictionary.find(1) # hard-coded, ugh
		uri = dic.URI
		uri = uri.split('/')
		uri.pop # get rid of index.htm
		uri = uri.join('/')
		BASE_URL = uri
		pages = {1 => ('a'..'e'), 2 => ('f'..'o'), 3 => ('p'..'z')}
		pages.each do |idx,letters|
			b = Watir::Browser.new
			letters.each do |letter|
				url = BASE_URL+'/ix'+(idx.to_s)+'.htm#'+letter
				STDERR.puts url
				b.goto url
				tables = b.tables
				tables.each do |t|
					begin
						if t.summary == letter.upcase
							t.as.each do |el|
								if el.parent.attribute_value('bgcolor').nil?
									if el.text != letter.upcase
										puts "#{el.text} - #{el.href}"
									else
										STDERR.puts "-- #{letter.upcase}"
									end
								else
									puts "#{el.parent.b.text}, #{el.text} - #{el.href}"
								end
							end
						end
					rescue
						abort($!)
						# probably should just exit
					end
				end
				# p b
			end
			b.quit
		end
  end

  desc "Slurp entries from Oxford Dictionary of Philosophy"
  task odp: :environment do

		headless = Headless.new
		headless.start
		dic = Dictionary.find(2)
		uri = dic.URI
		# page 1
		# ?btog=chap&hide=true&pageSize=100&sort=titlesort&source=%2F10.1093%2Facref%2F9780199541430.001.0001%2Facref-9780199541430
		# page 2
		# btog=chap&hide=true&page=2&pageSize=100&sort=titlesort&source=%2F10.1093%2Facref%2F9780199541430.001.0001%2Facref-9780199541430
		BASE_URL = uri
		pages = (1..34)
		pages.each do |number|
			b = Watir::Browser.new
			url = BASE_URL+"?btog=chap&hide=true#{(number==1?'':('&page='+number.to_s))}&pageSize=100&sort=titlesort&source=%2F10.1093%2Facref%2F9780199541430.001.0001%2Facref-9780199541430"
			STDERR.puts url
			b.goto url
			(b.h2s :class => "itemTitle").each do |h2|
				puts h2.text
			end
			b.quit
		end
  end

  desc "Slurp entries from Philosophy Dictionary, ed. Runes"
  task runes: :environment do

		headless = Headless.new
		headless.start
		dic = Dictionary.find(3) # hard-coded, ugh
		uri = dic.URI
		uri = uri.split('/')
		uri.pop # get rid of index.html
		uri = uri.join('/')
		BASE_URL = uri
		pages = ('a'..'z')
		pages.each do |letter|
			b = Watir::Browser.new
			url = BASE_URL+"/#{letter}.html"
			STDERR.puts url
			b.goto url
			b.as.each do |a|
				if !a.name.nil?
					puts a.name
				end
			end
			b.quit
		end
  end

  desc "Slurp entries from Routledge Encyclopedia of Philosophy"
  task rep: :environment do

		headless = Headless.new
		headless.start
		dic = Dictionary.find(4)
		uri = dic.URI
		BASE_URL = uri
		pages = (1..144)
		pages.each do |number|
			b = Watir::Browser.new
			url = BASE_URL+"browse/a-z?pageNo=#{number}"
			STDERR.puts url
			b.goto url
			(b.h4s :class => 'result-item__title').each do |h4|
				begin
					puts h4.a.text
				rescue
					puts h4.text
				end
			end
			b.quit
		end
  end

end
