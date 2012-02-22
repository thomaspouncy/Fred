require 'mongo'

module MongoLogic
  def setup_mongo(db_name="fred",col_name="distance_memory")
    @db = Mongo::Connection.new.db(db_name)
    @col = @db.collection(col_name)
  end
end
