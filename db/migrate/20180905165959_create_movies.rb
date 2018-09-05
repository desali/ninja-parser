class CreateMovies < ActiveRecord::Migration[5.2]
  def change
    create_table :movies do |t|
      t.string :title
      t.integer :anime_id
      t.string :theme
      t.string :source
      t.string :link

      t.timestamps
    end
  end
end
