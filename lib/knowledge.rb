
module Knowledge

	module DBpedia
		# hmm, http://www.semantic-web-journal.net/system/files/swj1141.pdf
		
		def self.is_a_person? name
			key = "people,#{name}"
			require 'dalli'
			dc = Dalli::Client.new('localhost:11211')
			res = dc.get(key)
			if (!res.nil?)
				Rails.logger.info "Using cached #{entity}"
				return res
			end
			res = is_a_specific_subject? 'people', name
			id = dc.set(key, res)
			Rails.logger.info "Caching #{key} as #{id}"
			res
		end

		def self.is_a_philosopher? name
			key = "philosophers,#{name}"
			require 'dalli'
			dc = Dalli::Client.new('localhost:11211')
			res = dc.get(key)
			if (!res.nil?)
				Rails.logger.info "Using cached #{entity}"
				return res
			end
			res = is_a_specific_subject? 'philosophers', name
			id = dc.set(key, res)
			Rails.logger.info "Caching #{key} as #{id}"
			res
		end

		def self.is_a_specific_subject? subject, name
			require 'sparql/client'
			sparql = SPARQL::Client.new("http://dbpedia.org/sparql")
			# SELECT DISTINCT ?resource ?cont
			# should use HERE DOC
			query =
			"
			PREFIX db-prop: <http://dbpedia.org/property/>
			PREFIX db-ont: <http://dbpedia.org/ontology/>
			PREFIX dc-term: <http://purl.org/dc/terms/>
			SELECT DISTINCT ?resource
			WHERE {
				?resource dc-term:subject ?cont .
				?resource <http://dbpedia.org/property/name> ?name .
				FILTER regex(?name, \"#{name}\", \"i\") .
				FILTER regex(?cont, \"#{subject}\", \"i\") .
			}
			ORDER BY ?resource
			"
			result_set = sparql.query(query)
			Rails.logger.info "DBpedia result #{result_set.inspect}"
			result_set
		end

	end # module DBpedia

	module Google

		def self.entity_search entity
			key = "KG,#{entity}"
			require 'dalli'
			dc = Dalli::Client.new('localhost:11211')
			res = dc.get(key)
			if (!res.nil?)
				Rails.logger.info "Using cached #{entity}"
				return res
			end
			api_key = IO.read("#{Rails.root}/.google_api_key").strip
			service_url = 'https://kgsearch.googleapis.com/v1/entities:search'
			http_params = {
				query: entity,
				limit: 1,
				indent: true,
				key: api_key,
			}
			url = service_url + '?' + http_params.to_query
			require 'open-uri'
			json_resp = open(url)
			if json_resp.status[0] == '200'
				resp = JSON.parse json_resp.read
				res = resp['itemListElement'][0]['result']
				Rails.logger.info "KG result #{res.inspect}"
				id = dc.set(key, res)
				Rails.logger.info "Caching #{key}  as #{id}"
				return res
			else
				raise "Google Knowledge Graph HTTP status #{json_resp.status}"
			end
		end

	end # module Google

	module LanguageLayer

		def self.detect phrase
			key = "LL,#{phrase}"
			require 'dalli'
			dc = Dalli::Client.new('localhost:11211')
			res = dc.get(key)
			if (!res.nil?)
				Rails.logger.info "Using cached #{entity}"
				return res
			end
			api_key = IO.read("#{Rails.root}/.languagelayer_api_key").strip
			service_url = 'http://apilayer.net/api/detect'
			http_params = { access_key: api_key, query: phrase, show_query: 1 }
			url = service_url + '?' + http_params.to_query
			require 'open-uri'
			require 'dalli'
			json_resp = open(url)
			if json_resp.status[0] == '200'
				resp = JSON.parse json_resp.read
				if resp['success'] == true
					res = resp['results']
					Rails.logger.info "KG result #{res.inspect}"
					id = dc.set(key, res)
					Rails.logger.info "Caching #{key}  as #{id}"
					return res
				else
					raise "Language Layer unsuccessful #{resp['error']}"
				end
			else
				raise "Language Layer HTTP status #{json_resp.status}"
			end
		end

	end # model LanguageLayer

end # module Knowledge
