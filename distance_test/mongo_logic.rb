require 'mongo'

module MongoLogic
  def setup_mongo
    @db = Mongo::Connection.new.db("fred")
    @col = @db.collection("distance_memory")
  end
end
