require "json"
require "open-uri"

class GamesController < ApplicationController
  VOWELS = %w[A E I O U]

  def new
    @letters = Array.new(5) { VOWELS.sample }
    @letters += Array.new(5) { (("A".."Z").to_a - VOWELS).sample }
    @letters.shuffle!
  end

  def score
    @letters = params[:letters].to_s.split
    @word = params[:word].to_s.upcase
    @included = included?(@word, @letters)
    @english_word = @included && english_word?(@word)

    @points = @english_word ? @word.length : 0
    session[:total_score] = session[:total_score].to_i + @points
    @total_score = session[:total_score]
  end

  private

  def included?(word, letters)
    word.present? && word.chars.all? { |letter| word.count(letter) <= letters.count(letter) }
  end

  def english_word?(word)
    response = URI.open("https://dictionary.lewagon.com/#{word.downcase}")
    JSON.parse(response.read)["found"]
  end
end
