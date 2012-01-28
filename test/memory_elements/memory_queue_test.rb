require 'test_helper'

class MemoryElements::MemoryQueueTest < Test::Unit::TestCase
  def test_initializing_with_no_length
    assert_raise RuntimeError do
      MemoryElements::MemoryQueue.new(nil)
    end
  end

  def test_queue_behaves_like_an_array
    queue = MemoryElements::MemoryQueue.new(4)

    assert_equal 4, queue.max_queue_length
    assert_nothing_raised do
      queue[0]
      queue.first
      queue.last
      queue << 1
      queue.push(1)
    end
  end

  def test_queue_length_is_limited
    queue = MemoryElements::MemoryQueue.new(4)
    queue.push(1,2,3,4)

    queue.push(5)

    assert_equal [2,3,4,5], queue
  end
end
