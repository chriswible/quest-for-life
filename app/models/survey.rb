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

class Survey < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
  
  class << self
    
    def parameter_columns
      [:r_star, :fp, :ne, :fl, :fi, :fc, :l]
    end

    def title_for_parameter(p)
      {
        :n      => 'Number of Civilizations',
        :r_star => 'Rate of Stellar Formation',
        :fp     => "Fraction of Stars that Develop Planets",
        :ne     => 'Number of Earthlike Planets',
        :fl     => 'Frequency of Life Developing',
        :fi     => 'Frequency of Intelligence Evolving',
        :fc     => 'Frequency of Intelligent Civilization Communicating',
        :l      => "Life Expectancy of an Advanced Society",
      }[p.to_sym]
    end
    
    def question_for_parameter(p)
      {
        :n      => 'How many civilizations that might communicate with us are there in our galaxy?',
        :r_star => 'How many stars form in our galaxy each year?',
        :fp     => "How many suitable stars actually form a solar system with planets in it?",
        :ne     => 'What\'s the average number of bodies in a solar system capable of supporting liquid water?',
        :fl     => 'How hard is it for life to start on a suitable planet?',
        :fi     => 'If life starts on a planet, how likely is intelligence to develop?',
        :fc     => 'Will an advanced civilization discover radio and choose to use it to communicate?',
        :l      => "How many years can an advanced society survive?"
      }[p.to_sym]
    end

    def next_parameter(requested_parameter)
      return parameter_columns.first if requested_parameter.nil?
      requested_parameter = requested_parameter.to_sym
      raise "Invalid parameter: #{requested_parameter}" unless parameter_columns.include?(requested_parameter)
      index = parameter_columns.index(requested_parameter)
      parameter_columns[index+1]
    end

    def options_for(parameter)
      send("#{parameter}_options")
    end
    
    def options_to_js_ary(parameter)
      options = options_for(parameter).collect! {|o| "#{o.chart_label(parameter)}"}
      options.to_json
    end
    
    def n_options
      # max estimate 1,000,000,000
      [
        [0,99],
        [100,999],
        [1000,9999],
        [10000,99999],
        [100000,999999],
        [1000000,1000000000]
      ]
    end
    
    def current_average
      n = 1
      parameter_columns.each do |p|
        n *= average(p)
      end
      n.to_i
    end
    
    def r_star_options
      RationalOption.integers.quotient_gte(0).quotient_lte(100)
    end

    def fp_options
      RationalOption.quotient_gte((10**-6).to_f).quotient_lte(1)
    end

    def ne_options
      RationalOption.quotient_gte((10**-2).to_f).quotient_lte(10)
    end

    alias fl_options :fp_options
    alias fi_options :fp_options
    alias fc_options :fp_options

    def l_options
      RationalOption.quotient_gte(1).quotient_lte(10**6).reject{|o| Math.log10(o.quotient) % 1 != 0}
    end
  end
  
  belongs_to :survey_group
  belongs_to :age_group

  validates_numericality_of parameter_columns, :n, :greater_than_or_equal_to => 0, :allow_nil => true
  validates_presence_of :slug
  validates_uniqueness_of :slug, :on => :create

  before_validation_on_create :set_slug
  before_validation :strip_at_from_twitter_username
  before_save :store_group_demographics
  before_save :calculate_quotients
  before_save :cleanup_empty_strings
  
  attr_accessible *(parameter_columns.map{|p| "#{p}_rational_id".to_sym })
  attr_accessible :city, :state, :country, :age_group_id, :gender, :activity_id, :lit_type_id, :twitter_username

  belongs_to :lit_type
  belongs_to :activity
  belongs_to :r_star_rational, :class_name => 'RationalOption'
  belongs_to :fp_rational, :class_name => 'RationalOption'
  belongs_to :ne_rational, :class_name => 'RationalOption'
  belongs_to :fl_rational, :class_name => 'RationalOption'
  belongs_to :fi_rational, :class_name => 'RationalOption'
  belongs_to :fc_rational, :class_name => 'RationalOption'
  belongs_to :l_rational, :class_name => 'RationalOption'

  def average_n
    n = 1
    Survey.parameter_columns.each do |p|
      n *= Survey.average(p)
    end
    n.to_i
  end
  
  def param_average_human(parameter)
    case parameter
      when 'r_star'
        number_with_delimiter(Survey.average(parameter).to_int)
      when 'fp'
        "1 in #{number_with_delimiter((Survey.average(parameter) * 100).to_int)}"
      when 'ne'
        num = Survey.average(parameter)
        if num >= 1
          number_with_delimiter(Survey.average(parameter).to_int)
        else
          "1 in #{number_with_delimiter((Survey.average(parameter) * 100).to_int)}"
        end 
      when 'fl'
        "1 in #{number_with_delimiter((Survey.average(parameter) * 100).to_int)}"
      when 'fi'
        "1 in #{number_with_delimiter((Survey.average(parameter) * 100).to_int)}"
      when 'fc'
        "1 in #{number_with_delimiter((Survey.average(parameter) * 100).to_int)}"
      when 'l'
        number_with_delimiter(Survey.average(parameter).to_int)
      else     
        number_with_delimiter(average_n)
    end
  end

  def param_average_data(parameter)
    case parameter
      when 'r_star'
        (Survey.average(parameter)).to_int
      when 'fp'
        (Survey.average(parameter) * 100).to_int
      when 'ne'
        num = Survey.average(parameter)
        if num >= 1
          Survey.average(parameter).to_int
        else
          (Survey.average(parameter) * 100).to_int
        end 
      when 'fl'
        (Survey.average(parameter) * 100).to_int
      when 'fi'
        (Survey.average(parameter) * 100).to_int
      when 'fc'
        (Survey.average(parameter) * 100).to_int
      when 'l'
        (Survey.average(parameter) / 100000).to_int
      else     
        (average_n / 100000000000).to_int
    end
  end

  def total_by_gender(gender,parameter,option)
    if !self.survey_group_id.nil?
      if parameter == 'n'
        Survey.find(:all,:conditions => ["n between #{option[0]} and #{option[1]} and gender = ? and n is not null and survey_group_id = ?", gender, self.survey_group_id]).count()
      else
        Survey.find(:all,:conditions => [parameter + '_rational_id = ? and gender = ? and n is not null and survey_group_id = ?', option.id, gender, self.survey_group_id]).count()
      end
    else
      if parameter == 'n'
        Survey.find(:all,:conditions => ["n between #{option[0]} and #{option[1]} and gender = ? and n is not null", gender]).count()
      else
        Survey.find(:all,:conditions => [parameter + '_rational_id = ? and gender = ? and n is not null', option.id, gender]).count()
      end
    end
  end

  def total_by_age(age,parameter,option)
    if !self.survey_group_id.nil?  
      if parameter == 'n'
        Survey.find(:all,:conditions => ["n between #{option[0]} and #{option[1]} and age_group_id = ? and n is not null and survey_group_id = ?", age, self.survey_group_id]).count()
      else
        Survey.find(:all,:conditions => [parameter + '_rational_id = ? and age_group_id = ? and n is not null and survey_group_id = ?', option.id, age, self.survey_group_id]).count()
      end
    else
      if parameter == 'n'
        Survey.find(:all,:conditions => ["n between #{option[0]} and #{option[1]} and age_group_id = ? and n is not null", age]).count()
      else
        Survey.find(:all,:conditions => [parameter + '_rational_id = ? and age_group_id = ? and n is not null', option.id, age]).count()
      end    
    end
  end

  def total_combined(age,gender,parameter,option)
    if !self.survey_group_id.nil?
      if parameter == 'n'
        Survey.find(:all,:conditions => ["n between #{option[0]} and #{option[1]} and gender = ? and age_group_id = ? and n is not null and survey_group_id = ?", gender, age, self.survey_group_id]).count()
      else
        Survey.find(:all,:conditions => [parameter + '_rational_id = ? and gender = ? and age_group_id = ? and n is not null and survey_group_id = ?', option.id, gender, age, self.survey_group_id]).count()
      end
    else
      if parameter == 'n'
        Survey.find(:all,:conditions => ["n between #{option[0]} and #{option[1]} and gender = ? and age_group_id = ? and n is not null", gender, age]).count()
      else
        Survey.find(:all,:conditions => [parameter + '_rational_id = ? and gender = ? and age_group_id = ? and n is not null', option.id, gender, age]).count()
      end
    end
  end

  def class_for_results(parameter,option)
    true_class = 'you'
    false_class = ''
    if !self.attributes["#{parameter}"].nil?
      if parameter == 'n'
        if self.n >= option[0] && self.n < option[1]
          true_class
        else
          false_class
        end
      else
        if self.attributes["#{parameter}_rational_id"] == option.id
          true_class
        else
          false_class
        end
      end
    else
      false_class
    end
  end

  def count_by_response(attribute,value)
    self.find(:all, :conditions => ["#{attribute} = ?", value]).count()
  end  
  
  def to_param
    slug
  end
  
  def completed?
    self.n.present?
  end
  
  def address
    "#{self.city}, #{self.state} #{self.country}"
  end

  
  private
  
  def store_group_demographics
    if survey_group
      self.country = survey_group.country
      self.state = survey_group.state
      self.city = survey_group.city
      self.age_group_id = survey_group.age_group_id
    end
  end
  
  def calculate_quotients
    Survey.parameter_columns.each do |column|
      send("#{column}=", send("#{column}_rational").try(:quotient))
    end
    values = Survey.parameter_columns.map { |p| self.send(p) }
    if values.all?
      self.n = values.inject(1.0) { |product, v| product * v }.round
    else
      self.n = nil
    end
    true
  end
  
  def set_slug
    self.slug = ActiveSupport::SecureRandom.hex(4) # 8 hex digits
  end
  
  def strip_at_from_twitter_username
    self.twitter_username.gsub!('@', '') if self.twitter_username.present?
  end
  
  def cleanup_empty_strings
    self.gender = nil if self.gender == ''
  end

end
