# An exception class used for signalling that there is no more data to generate by
# {#generate_row} method in {ETLProducer} actor.
class EndOfData < StandardError
end
