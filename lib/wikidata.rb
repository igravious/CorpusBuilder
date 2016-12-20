
module Wikidata

	BOUND_URI = 's'.freeze
	BOUND_LABEL = 'sLabel'.freeze
	BOUND_PROP = 'p'.freeze
	BOUND_VALUE = 'v'.freeze

	LABEL_TO_ENTITIES = "
	PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
	SELECT ?#{BOUND_URI} WHERE {
		?#{BOUND_URI} rdfs:label '%{interpolated_label}'@en .
	}
	".freeze

	ENGLISH_VALUES = "
	PREFIX wd: <http://www.wikidata.org/entity/>
	SELECT ?#{BOUND_PROP} ?#{BOUND_VALUE} WHERE {
		wd:%{interpolated_entity} ?#{BOUND_PROP} ?#{BOUND_VALUE} FILTER (lang(?#{BOUND_VALUE}) = 'en') .
	}
	".freeze

	# {'A' => 'P31', 'B' => 'P279', 'C' => 'P361'}.each {|k,v| Object.const_set(k, "hello #{v}")}
	# this is why I ♥ Ruby
	{'INSTANCE_OF' => 'P31', 'SUBCLASS_OF' => 'P279', 'PART_OF' => 'P361'}.each {|konst,meros| Object.const_set(konst, "
	# P31=instance of, P279=subclass of, P361=part of
	# too much magic here
	SELECT (wd:%{interpolated_entity} as ?x) (p:#{meros} as ?y) ?#{BOUND_URI} ?#{BOUND_LABEL} WHERE {
		wd:%{interpolated_entity} p:#{meros} ?cn_stmt .
		?cn_stmt ps:#{meros} ?#{BOUND_URI} .
		SERVICE wikibase:label {
			bd:serviceParam wikibase:language 'en' .
		}
	}
	")}

	# {"Q3190382"=>"justice"} : subcategory of welfare economics
	# {"Q6316856"=>"justice"} : concept in research ethics concerning the fair selection of research participants
	# {"Q1078867"=>"nature"} : philosophical concept
	# {"Q21263961"=>"nature"} : character
	AVOIDED_ENTITIES = ["Q3190382", "Q6316856", "Q1078867", "Q21263961"]

	class Client

		def reset
			@entities = AVOIDED_ENTITIES.dup
			@meros = RDF::Graph.new
			# @labels = RDF::Graph.new
			@labels = Hash.new
		end

		def initialize(accumulate)
			@sparql = SPARQL::Client.new('https://query.wikidata.org/sparql', method: :get)
			@accumulate = accumulate
		end

		def recurse_query(label)
			the_grep_meister(label)
		end

		# private methods

		def meros(konst_str, n, entity)
			query = Object.const_get(konst_str) % {interpolated_entity: entity}
			res =  @sparql.query(query)
			property = res.first
			if !property.nil?
				m = res.length
				if res.length > 1
					STDOUT.printf "## "
					res.each {|r| STDOUT.printf(" #{(r.bindings[BOUND_LABEL.to_sym]).to_s.split('/').last}")}
					STDOUT.printf "\n"
				end
				new_entity_uri = property.bindings[BOUND_URI.to_sym]
				new_entity_str = new_entity_uri.to_s.split('/').last
				label_uri = property.bindings[BOUND_LABEL.to_sym]
				label = label_uri.to_s.split('/').last
				a = [property.bindings[:x], property.bindings[:y], new_entity_uri]
				@meros << a
				out = "#{entity} #{konst_str.downcase!} #{{new_entity_str => label}}"
				if @entities.include? new_entity_str
					STDOUT.puts ">> #{out}"
					return nil
				else
					# l = [new_entity_uri, RDF::RDFS.label, label]
					# @labels << l
					@labels[new_entity_str] = label
					@entities.push(new_entity_str)
					STDOUT.printf("%02d #{out}\n",n)
					return {new_entity_str => label}
				end
			else
				return nil
			end
		end

		def part_of(n, entity)
			meros('PART_OF', n, entity)
		end

		def subclass_of(n, entity)
			meros('SUBCLASS_OF', n, entity)
		end

		def instance_of(n, entity)
			meros('INSTANCE_OF', n, entity)
		end

		# WHERE THE FUCK DID THE REST OF IT GO?

		def recurse_grep(n, pair)
			# puts "#{n} #{pair}"
			if !pair.nil?
				entity,label = pair.first # {} -> [] -> _,_
				# puts "entity #{entity} : #{label}"
				# p = (n+1)*2
				if !recurse_grep(n+1, part_of(n, entity))
					if !recurse_grep(n+1, subclass_of(n, entity))
						recurse_grep(n+1, instance_of(n, entity))
					end
				end
			else
				return false
			end
			return true
		end

		def description(entity)
			# "G%{a}GLE" % {:a => 'OO'}
			query = ENGLISH_VALUES % {interpolated_entity: entity}
			properties = @sparql.query(query)
			# an array of rdf query solutions
			# [#<RDF::Query::Solution:0x35bd440({:prop=>#<RDF::URI:0x3635788 URI:http://schema.org/description>, :value=>#<RDF::Literal:0x35bd4f4("phenomena of the physical world, and also to life in general"@en)>})>, #<RDF::Query::Solution:0x35bd06c({:prop=>#<RDF::URI:0x35bd350 URI:http://www.w3.org/2000/01/rdf-schema#label>, :value=>#<RDF::Literal:0x35bd120("nature"@en)>})>]
			properties.each do |q_sol2|
				prop_uri = q_sol2.bindings[BOUND_PROP.to_sym]
				if 'http://schema.org/description' == prop_uri.to_s or 'http://www.w3.org/2004/02/skos/core#altLabel' == prop_uri.to_s
					prop_value = q_sol2.bindings[BOUND_VALUE.to_sym]
					return prop_value.to_s
				end
			end
			return ''
		end

		def label_to_entities(label)
			query = LABEL_TO_ENTITIES % {interpolated_label: label}
			@sparql.query(query)			
		end

		def the_grep_meister(label)
			result_set = label_to_entities(label)
			# p result_set
			reset if !@accumulate
			result_set.each do |q_sol1|
				entity_uri = q_sol1.bindings[BOUND_URI.to_sym]
				# puts entity_uri.to_s
				entity_str = entity_uri.to_s.split('/').last
				h = {entity_str => label}
				desc = description(entity_str)
				out = "#{h} : #{desc}"
				if @entities.include? entity_str
					STDOUT.puts "-- #{out}"
					next
				end
				@entities.push(entity_str)
				# puts entity_str
				# l = [entity_uri, RDF::RDFS.label, label]
				# @labels << l
				@labels[entity_str] = label
				puts "++ #{out}"
				recurse_grep(0, h)
			end
			[@meros, @labels]
		end

		private :the_grep_meister, :recurse_grep, :description, :instance_of, :subclass_of, :part_of, :meros

	end

end
