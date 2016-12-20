namespace :corpus do
	def foo
		begin
		rescue
		end
	end

		# client.transport.reload_connections!
		# client.cluster.health
		# client.search q: 'test'
		# client.search index: 'corpus', body: { query: { match: { snapshot: um? } } }
	
	def count_snapshots
		query = Elasticsearch::Client.new log: true
		begin
			res = query.search(index: 'corpus', type: 'snapshot', search_type: 'count') {}
			return res['hits']['total']
		rescue Elasticsearch::Transport::Transport::Errors::NotFound => e
			return 0
		end
	end

  desc "Show a list of snapshots"
  task :list, [:type] => :environment  do |t, args|
		require 'elasticsearch'
		begin
			count = count_snapshots
			if 0 == count
				STDOUT.puts "There are no snapshots"
			else
				STDOUT.puts "Number of snapshots: #{count}"
				case args.type
				when 'label'
				else
				end
			end
		rescue Exception => msg
			STDERR.puts "Very bad juju in list: #{msg}"
		end
  end

	desc "Find term within a snapshot"
	task :find, [:term] => :environment do |t, args|
		require 'elasticsearch'
		begin
			count = count_snapshots
			if 0 == count
				STDOUT.puts "There are no snapshots"
			else
				STDOUT.puts "Searching for #{args.term} within snapshot #{count}"
				query = Elasticsearch::Client.new log: false
				# res = query.search(index: 'corpus', type: 'snapshot', id: { query: { match: { content: args.term } } })
				# res = query.search(index: 'corpus', type: 'snapshot', query: { query_string: { query: args.term}})
				p res.keys
			end
		rescue Exception => msg
			STDERR.puts "Very bad juju in find: #{msg}"
		end
	end

  desc "Take a snapshot"
  task :take, [:url, :year] => :environment do |t, args|
		require 'elasticsearch'
		begin
			next_id = count_snapshots + 1
			client = Elasticsearch::Client.new log: false
			@event = OpenStruct.new(url: args.url, year: args.year)
			@files = Fyle.all
			@papers = []
			@files.each do |file|
				text = file.text
				if !text.nil?
					if !text.include
						next
					end
					# content = Base64.encode64(file.snarf)
					paper = OpenStruct.new(content: file.snarf, year: text.original_year, title: text.name_in_english)
					paper.authors = []
					text.authors.each do |author|
						wrote = text.the_writing(author)
						# if the role field is not explicitly set assume that the author is the author
						if wrote.role.nil? or wrote.role == Writing::AUTHOR
							author = OpenStruct.new(name: author.english_name)
							paper.authors.push(author)
						end
					end
					@papers.push(paper)
				end
			end
			body = Jbuilder.encode do |json|
				json.events do 
					json.event do
						json.url @event.url
						json.year @event.year
						n = 0
						json.array @papers do |paper| json.paper do
							json.content paper.content
							json.year paper.year
							json.title paper.title
							json.authors do json.array paper.authors do |author|
								json.author author.name
							end
							end
							n += 1
						end
						end
					end
				end
			end
			client.index(index: 'corpus', type: 'snapshot', id: next_id, body: body)
			STDOUT.puts "Created snapshot with id #{next_id} with #{n} paper(s)"
		rescue Exception => msg
			STDERR.puts "Very bad juju in take: #{msg}"
		end
	end

	# that's not a nuke, _this_ is a nuke
	# curl -XDELETE 'http://localhost:9200/corpus/'
  desc "Nuke a snapshot"
  task nuke: :environment do
		require 'elasticsearch'
		begin
			the_id = count_snapshots
			client = Elasticsearch::Client.new log: true
			if 0 == the_id
				STDOUT.puts "There are no snapshots to delete"
			else
				client.delete(index: 'corpus', type: 'snapshot', id: the_id)
				STDOUT.puts "Deleted snapshot with id #{the_id}"
			end
		rescue Exception => msg
			STDERR.puts "Very bad juju in nuke: #{msg}"
		end
	end

	#
	# TRY AGAIN !
	#
	
	DOC_TYPE = 'philosophical text'.freeze
	METADATA = 'metadata'.freeze

	def elastic(log_switch)
		begin
			name = caller[0]
			# STDOUT.puts "called from #{name}"
			ec = Elasticsearch::Client.new log: log_switch
			yield ec
		rescue Exception => msg
			STDERR.puts "Very bad juju in #{name}: #{msg}"
		end
	end

	def count_docs snap
		query = Elasticsearch::Client.new log: false
		begin
			res = query.search(index: snap, type: DOC_TYPE, search_type: 'count') {}
			return res['hits']['total'].to_i
		rescue Elasticsearch::Transport::Transport::Errors::NotFound => e
			return 0
		end
	end

	def args_to_snap args
		return 'snapshot'+(args.snap.to_i).to_s
	end

	desc "PUT"
	# task PUT: :environment
  # task :PUT, [:snap, :text] => :environment do |t, args|
  task :PUT, [:snap, :text] => :environment do |t, args|
		elastic(true) do |client|
			snap = args_to_snap args
			text_id = count_docs(snap) + 1
			client.index(index: snap, type: DOC_TYPE, id: text_id, body: { content: args.text })
		end
	end

	def count_snaps
		query = Elasticsearch::Client.new log: false
		begin
			res = query.get(index: 'corpus', type: 'snapshots', id: 0) {}
			counter = res['_source']['counter']
			return counter.to_i
		rescue Elasticsearch::Transport::Transport::Errors::NotFound => e
			return 0
		end
	end

	def latest_snap
		'snapshot'+(count_snaps.to_s)
	end

	desc "TAKE"
	task :TAKE, [:url, :year] => :environment do |t, args|
		elastic(false) do |client|
			counter = count_snaps+1
			next_snap = 'snapshot'+(counter.to_s)
			@event = OpenStruct.new(url: args.url, year: args.year)
			@files = Fyle.all
			@papers = []
			@files.each do |file|
				text = file.text
				if !text.nil?
					if !text.include
						next
					end
					# content = Base64.encode64(file.snarf)
					paper = OpenStruct.new(uid: file.id, content: file.snarf, year: text.original_year, title: text.name_in_english)
					paper.authors = []
					text.authors.each do |author|
						wrote = text.the_writing(author)
						# if the role field is not explicitly set assume that the author is the author
						if wrote.role.nil? or wrote.role == Writing::AUTHOR
							author = OpenStruct.new(name: author.english_name)
							paper.authors.push(author)
						end
					end
					@papers.push(paper)
				end
			end

			client.index(index: next_snap, type: METADATA, id: 0, body: { url: @event.url, year: @event.year })
			STDOUT.puts "Stored metadata for snapshot #{next_snap}"
			n = 0
			@papers.each do |paper|
				body = Jbuilder.encode do |json|
					json.uid paper.uid
					json.content paper.content
					json.year paper.year
					json.title paper.title
					json.authors do json.array paper.authors do |author|
						json.author author.name
					end
					end
				end
				client.index(index: next_snap, type: DOC_TYPE, id: n, body: body)
				n += 1
			end
			STDOUT.puts "Created indexed snapshot #{next_snap} with #{n} paper(s)"
			client.index(index: 'corpus', type: 'snapshots', id: 0, body: { counter: counter })
		end
	end

	desc "MAP"
	task MAP: :environment do
		elastic(true) do |client|
			# curl -XGET 'http://localhost:9200/_mapping?pretty'
			client.indices.get_mapping
		end
	end

	desc "LOOK"
	task :LOOK, [:snap, :text] => :environment do |t, args|
		elastic(false) do |client|
			snap = args_to_snap args
			res = client.search(index: snap, body: { query: { match_phrase: { content: args.text } }, highlight: { fields: { content: {} } } })
			# p res.keys
			# ["took", "timed_out", "_shards", "hits"]
			# p res["hits"].keys
			# ["total", "max_score", "hits"]
			p res["hits"]["total"]
			res["hits"]["hits"].each do |h|
				# ["_index", "_type", "_id", "_score", "_source", "highlight"]
				# p h.keys
				p h['_id']
				p h["_score"]
				p h["highlight"]
				# p h['_source'].keys
				# ["content", "year", "title", "authors"]
				p h['_source']['title']
				p h['_source']['year']
			end
		end
	end

	desc "NUKE"
	task :NUKE, [:snap] => :environment do |t, args|
		elastic(true) do |client|
			snap = args_to_snap args
			client.indices.delete(index: snap)
		end
	end


	desc "WIBBLE"
	task WIBBLE: :environment do |t, args|
		Rails.logger.info "groobiest"
	end

end
