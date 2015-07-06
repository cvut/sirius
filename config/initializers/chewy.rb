require 'chewy'

Chewy.settings = {
  host: Config.elastic_url,
  prefix: Config.elastic_prefix
}

Chewy.repository.instance_exec do

  analyzer :course_code, type: 'custom', tokenizer: 'course_code',
           filter: %w[lowercase asciifolding]

  analyzer :course_code_engram, type: 'custom', tokenizer: 'course_code',
           filter: %w[lowercase asciifolding edge_ngram]

  analyzer :czech_ascii, type: 'custom', tokenizer: 'standard',
           filter: %w[lowercase asciifolding czech_stop czech_stemmer]

  analyzer :standard_ascii, type: 'custom', tokenizer: 'standard',
           filter: %w[lowercase asciifolding]

  analyzer :standard_ascii_engram, type: 'custom', tokenizer: 'standard',
           filter: %w[lowercase asciifolding edge_ngram]

  filter :edge_ngram, type: 'edgeNGram', min_gram: 2, max_gram: 10
  filter :czech_stemmer, type: 'stemmer', language: 'czech'
  filter :czech_stop, type: 'stop', stopwords: '_czech_'

  tokenizer :course_code, type: 'pattern', pattern: '(\\w+\\d|\\w+)', group: 0
end
