# == Schema Information
#
# Table name: years
#
#  id         :integer          not null, primary key
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Year < ApplicationRecord
    has_many :animes
end
