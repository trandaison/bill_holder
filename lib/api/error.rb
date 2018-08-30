module Api
  class Error < StandardError
    def initialize msg, original=$!
      puts "*****************************"
      puts caller(0, 2).last
    end
  end
end
