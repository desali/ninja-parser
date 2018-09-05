class Api::V1::RequestsController < ApplicationController

    def shuffle
        @shuffle = [1..Anime.count].shuffle
        # render json: @user.errors
    end

    def getMovie
        @anime = Anime.find_by(id: anime_params[:id])

        if @anime
            puts @anime.to_json
            puts @anime.movies.to_json
            @movie = @anime.movies.shuffle.find { |m| m[:theme] == "Openings" }
            render json: {
                'status': true,
                'title': @anime[:title_ru],
                'link': @movie[:link]
            }
        else
            render json: {
                'status': false,
                'desc': "Wrong id!"
            }
        end
    end

    private
    def anime_params
        params.permit(:id)
    end
end
