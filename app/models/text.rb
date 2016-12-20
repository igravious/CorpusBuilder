class Text < ActiveRecord::Base
	has_many :writings
	has_many :authors, :through => :writings
	accepts_nested_attributes_for :authors, :reject_if => :all_blank
	accepts_nested_attributes_for :writings, :reject_if => :all_blank, :allow_destroy => true

	# TODO you know you're doing something dumb when you are enumerating an index
	ORIGINAL_LANGUAGE=[
		["Ancient Greek",1],
		["Ancient Chinese",2],
		["Early Latin",3],
		["Modern French",4],
		["Modern German",5],
		["Moderm English",6],
		["Classical Latin",7],
		["Late Latin",8],
		["Medieval Latin",9],
		["Renaissance Latin",10],
		["New Latin",11],
		["Old English",12],
		["Middle English",13],
		["Early Modern English",14],
		["Old French (Langue d'oïl)"],
		["Middle French (1300-1650)"],
		["Danish"]
	]

	def author_names
		authors.map{ |a|
			a.english_name
		}.join(", ")
	end

	def edit_author_names
		authors.map{ |a|
			eng = a.english_name
			url = Rails.application.routes.url_helpers.edit_author_path(a)
			# Rails.logger.info "eng #{eng}: url #{url}"
			ActionController::Base.helpers.link_to(eng, url)
		}.join(", ")
	end

	def author_id
	end

	def the_writing(author)
		if (author.id).nil?
			foo = Writing.new
		else
			foo = writings.find_by_author_id(author.id)
		end
		# Rails.logger.info "Writing #{foo}"
		# Rails.logger.info "Writing #{foo.inspect}"
		foo
		# return (foo?bar:baz)
	end

	def gen_cache_name
		File.basename(Tempfile.new([name_in_english, '.txt']).path)
	end

	# returns a URL
	def local_file
		Fyle.find(fyle_id).local
	end

	# returns a URL
	def strip_file
		Fyle.find(fyle_id).strip_path
	end

	# returns a URL
	def plain_file
		Fyle.find(fyle_id).plain_path
	end
end
