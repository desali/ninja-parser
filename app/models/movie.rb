# == Schema Information
#
# Table name: movies
#
#  id         :integer          not null, primary key
#  title      :string
#  anime_id   :integer
#  type       :string
#  source     :string
#  link       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Movie < ApplicationRecord
    belongs_to :anime
end
