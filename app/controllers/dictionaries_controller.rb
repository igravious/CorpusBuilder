class DictionariesController < ApplicationController
  before_action :set_dictionary, only: [:show, :edit, :update, :destroy, :entry]

	# Collections
	
  # GET /dictionaries
  # GET /dictionaries.json
  def index
    @dictionaries = Dictionary.all
  end

	# GET /dictionaries/compare
	def compare
		#@dictionaries = Dictionary.all
		@units = Unit.all
		@plucked_dicts = Unit.uniq.pluck(:dictionary_id)
		@dictionaries = Dictionary.where(id: @plucked_dicts) # only dictionaries with entries in the units table
	end

  # GET /dictionaries/1
  # GET /dictionaries/1.json
  def show
  end

	def entry
		# "#{Rails.application.config.relative_url_root}/comparison/#{params[:id]}.txt"
		send_file( "#{Rails.root}/public/comparison/#{params[:id]}.txt", :disposition => 'inline', :type => 'text/plain; charset=UTF-8', :x_sendfile => true)
	end

  # GET /dictionaries/new
  def new
    @dictionary = Dictionary.new
  end

  # GET /dictionaries/1/edit
  def edit
  end

  # POST /dictionaries
  # POST /dictionaries.json
  def create
    @dictionary = Dictionary.new(dictionary_params)

    respond_to do |format|
      if @dictionary.save
        format.html { redirect_to @dictionary, notice: 'Dictionary was successfully created.' }
        format.json { render action: 'show', status: :created, location: @dictionary }
      else
        format.html { render action: 'new' }
        format.json { render json: @dictionary.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /dictionaries/1
  # PATCH/PUT /dictionaries/1.json
  def update
    respond_to do |format|
      if @dictionary.update(dictionary_params)
        format.html { redirect_to @dictionary, notice: 'Dictionary was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @dictionary.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /dictionaries/1
  # DELETE /dictionaries/1.json
  def destroy
    @dictionary.destroy
    respond_to do |format|
      format.html { redirect_to dictionaries_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_dictionary
      @dictionary = Dictionary.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def dictionary_params
      params.require(:dictionary).permit(:title, :long_title, :URI, :current_editor, :contact, :organisation)
    end
end
