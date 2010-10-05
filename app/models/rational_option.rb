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

class RationalOption < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::TextHelper


  default_scope :order => 'quotient'
  
  validates_presence_of :numerator, :denominator, :quotient
  
  validates_numericality_of :numerator, :greater_than_or_equal_to => 0
  validates_numericality_of :denominator, :greater_than => 0
  validates_uniqueness_of :quotient
  
  before_validation :calculate_quotient
  
  attr_accessible :numerator, :denominator
  
  named_scope :integers, {:conditions=>{:quotient => Array(0..100)}}

  def quotient_label
    if self.denominator > 1
      # Rational(self.numerator, self.denominator).to_s\
      
      "#{number_with_delimiter(self.numerator)} in #{number_with_delimiter(self.denominator)}"
    else
      number_with_delimiter(self.numerator)
    end
  end
  
  def chart_label(param)   
    if param == 'ne'
      if quotient >= 1
        quotient.to_i
      else
        "#{number_with_delimiter(self.numerator)} in #{number_with_delimiter(self.denominator)}"
      end
    else
      quotient_label
    end
  end

  def r_star_label
    "#{pluralize quotient.to_i, 'star'} #{quotient==1 ? 'forms' : 'form'} in our galaxy each year"
  end

  def fp_label
    if quotient >= 1
      "every star develops planets"
    else
      "#{number_with_delimiter(self.numerator)} star out of every #{number_with_delimiter(self.denominator)} develops planets"
    end
  end

  def ne_label
    if quotient >= 1
      "#{pluralize quotient.to_i, 'body'} in an average solar system could have liquid water"
    else
      "#{number_with_delimiter(self.numerator)} out of every #{pluralize(number_with_delimiter(self.denominator), 'solar system')} will have one body that supports liquid water"
    end
  end

  def fl_label
    if quotient >= 1
      "every suitable planet will develop life"
    else
      "#{quotient_label} suitable planets will develop life"
    end
  end

  def fi_label
    if quotient >= 1
      "intelligence will develop wherever life develops"
    else
      "#{quotient_label} suitable planets with life will develop intelligence"
    end
  end
  
  def fc_label
    if quotient >= 1
      "every intelligent civilization will discover radio and choose to communicate"
    else
      "#{quotient_label} intelligent civilizations will discover radio and choose to communicate"
    end
  end

  def l_label
    "on average, an advanced society survives #{pluralize number_with_delimiter(quotient.to_i), 'year'}"
  end

  private
  
  def calculate_quotient
    self.quotient = self.numerator.to_f / self.denominator.to_f unless self.denominator.to_i == 0
  end
end
