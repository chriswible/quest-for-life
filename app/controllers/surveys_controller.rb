# Copyright (c) 2009 Steven Hammond, Cris Necochea, Joe Lind, Jeremy Weiskotten
# 
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following
# conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.

class SurveysController < ApplicationController
  before_filter :current_object, :except => :index
  before_filter :current_objects, :only => :index
  before_filter :find_parameter, :only => [:index,:edit]
  before_filter :only_show_if_completed, :only => :show
  before_filter :authorize, :only => [:edit, :update]
  
  def index
    @options = Survey.options_for("#{@parameter}")
    if(session[:survey_id].present?)
      @current_object = Survey.find_by_id(session[:survey_id]) || Survey.new
    else
      if(params[:survey_group_id].present?)
        @current_object = Survey.new
        @current_object.survey_group_id = params[:survey_group_id]
      else
        @current_object = Survey.new
      end
    end
    
    @gender = @current_object.gender.nil? ? 'Male' : @current_object.gender
    @age_group = @current_object.gender.nil? ? AgeGroup.find(1) : AgeGroup.find(@current_object.age_group_id)

    if params[:survey] 
      if params[:survey][:age_group_id]
        @age_group = AgeGroup.find(params[:survey][:age_group_id])
      end
      if params[:survey][:gender]
        @gender = params[:survey][:gender]
      end
    else
      if session[:survey_id]
        if session[:survey_id][:gender] != 0
          @gender = session[:survey_id][:gender]
        end
        if session[:survey_id][:gender] != 0
          @gender = session[:survey_id][:gender]
        end
      end
    end    
    if request.xhr?
      if params[:display] != 'page'
        render :partial => "chart_table_all"
      else
        render :partial => "parameter_results"
      end
    end
  end
  
  def show
    @parameter = 'n' 
  end

  def new
    @current_object = Survey.new()
  end
  
  def create
    @current_object = Survey.create(params[:post])
    session[:survey_id] = current_object.id
    if params[:survey_group_id]
      @current_object.survey_group_id = params[:survey_group_id]
      @current_object.save
    end
    redirect_to edit_survey_path(@current_object)
  end
  
  def edit
    if @parameter == 'n'
      redirect_to :action => :show, :id => params[:id]
    end
  end
  
  def update
    logger.warn params[:activity_id]
    current_object.update_attributes(params[:survey])
    if params[:demographics].present?
      # just asked for demographic data, show results
      redirect_to(current_object)
    else
      n = next_parameter
      if n
        redirect_to survey_parameter_path(current_object, n)
      else
        # no more parameters... need to ask for demographic data
        redirect_to survey_demographics_path(current_object)
      end
    end
  end

  def current_objects
    if params[:survey_group_id]
      @current_objects ||= Survey.find_all_by_survey_group_id(params[:survey_group_id], :conditions => "n is not null")
    else
      @current_objects ||= Survey.n_not_null
    end   
  end
  
  
  def current_object
    @current_object ||= Survey.find_by_slug(params[:id]) if params[:id].present?
    return @current_object
  end

  private

  
  def next_parameter
    current = params[:survey].keys.map{|k| k.sub(/_rational_id$/, '')}.find{|k| Survey.parameter_columns.include? k.to_sym }
    Survey.next_parameter(current)
  end
  
  def find_parameter
    @parameter = params[:p] ? params[:p] : params[:parameter] || Survey.parameter_columns.first.to_s
  end
  
  def authorize
    return if current_object.nil?
    unless @current_object.id == session[:survey_id]
      if current_object.completed?
        redirect_to [@current_object.survey_group, @current_object].flatten # show survey
      else
        redirect_to !@current_object.survey_group.nil? ? survey_group_surveys_path : surveys_path
      end
    end
  end
  
  def only_show_if_completed
    redirect_to surveys_path if @current_object.nil? || !@current_object.completed?
  end
end
