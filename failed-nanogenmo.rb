#!/usr/bin/env ruby

# http://dbpedia.org/page/Category:Algorithms


require 'wordnik'
require 'json'
require 'tilt'
require 'yaml'

conf = JSON.parse(File.read("config.json"))

Wordnik.configure do |config|
  config.api_key = conf["wordnik"]["api_key"]
  config.logger = Logger.new('/dev/null')
end

@word_count = 0
@target = 50_000

techniques = File.read("techniques.txt").split(/\n/).collect(&:chomp)
genres = File.read("genres.txt").split(/\n/).collect(&:chomp)
types = File.read("types.txt").split(/\n/).collect(&:chomp)
languages = File.read("languages.txt").split(/\n/).collect(&:chomp)
failures = File.read("failures.txt").split(/\n/).collect(&:chomp)


def adjective
  @adjectives ||= Wordnik.words.get_random_words(
    :include_part_of_speech => "adjective",
    minCorpusCount: 10000,
    limit: 1000
  ).map { |x| x["word"] }

  @adjectives.sample
end

def verb
  @verbs ||= Wordnik.words.get_random_words(
    :include_part_of_speech => "verb",
    minCorpusCount: 10000,
    limit: 1000
  ).map { |x| x["word"] }

  @verbs.sample
end

def noun
  @nouns ||= Wordnik.words.get_random_words(
    :include_part_of_speech => "noun",
    minCorpusCount: 10000,
    limit: 1000
  ).map { |x| x["word"] }
  @nouns.sample
end

@titles = File.read("titles.txt").split(/\n/).collect(&:chomp)  

require 'tilt/string'
def random_title
  str = @titles.sample
  t = Tilt::StringTemplate.new { str }
  t.render(self).split.map(&:capitalize).join(' ')
end



output = ""
index = 1

while @word_count < @target
  title = "Attempt ##{index}"
  genre = genres.sample
  technique = techniques.sample
  type = types.sample
  lang = languages.sample
  failure = failures.sample

  intro = if index == 1
            "The first attempt"
          else
            "The next attempt"
          end

  book_title = random_title
  
  if technique =~ /algorithm$/
    technique << "s"
  end

  adv = ["ultimately", "eventually", "in the end", "upon reflection", "truthfully"].sample.capitalize
  sucked = ["was a failure", "failed", "didn't succeed", "sucked", "was destroyed"].sample

  
  sentences = [
    "#{intro} was titled **#{book_title}**",
    "It was a #{genre} #{type}, written in #{lang}, and using #{technique}",
    "This attempt generated #{rand(10..40000)} words but failed due to #{failure}",
    "#{adv}, the work #{sucked} because the output was #{adjective}"
  ]

  result = "## #{title} ##\n#{sentences.join('. ')}.\n\n"
  
  output = output + result

  # + 2 for the 'attempt x'
  @word_count = output.split.size + 2

  STDERR.puts @word_count
  
  index += 1
end


actual_title = "A Collection of Failed #NaNoGenMo Ideas"

puts "# #{actual_title} #"
puts "\n\n"
puts "## by Colin Mitchell ##"
puts "\n\n"
puts "### ~ ~ ~ for #NaNoGenMo 2015 ~ ~ ~ ###"
puts "\n\n\n"
puts output

puts "## Attempt ##{index}"
puts "The final entry was titled **#{actual_title}**. It was a collection of generated entries, written in ruby. This attempt generated #{@word_count} words but still failed because the author has a lot to learn."

