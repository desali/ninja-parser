# == Schema Information
#
# Table name: seasons
#
#  id         :integer          not null, primary key
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Season < ApplicationRecord
    has_many :animes
end
