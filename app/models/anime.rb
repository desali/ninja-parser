# == Schema Information
#
# Table name: animes
#
#  id         :integer          not null, primary key
#  title      :string
#  title_ru   :string
#  rating     :decimal(, )
#  views      :integer
#  season_id  :integer
#  year_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Anime < ApplicationRecord
    # belongs_to :season
    # belongs_to :year
    has_many :movies
end
