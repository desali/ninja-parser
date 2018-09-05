class CreateAnimes < ActiveRecord::Migration[5.2]
  def change
    create_table :animes do |t|
      t.string :title
      t.string :title_ru
      t.numeric :rating
      t.integer :views
      t.integer :season_id
      t.integer :year_id

      t.timestamps
    end
  end
end
