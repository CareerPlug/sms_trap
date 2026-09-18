# frozen_string_literal: true

require 'test_helper'

module SmsTrap
  class StoreTest < ActiveSupport::TestCase
    def setup
      @store = Store.new(directory: Dir.mktmpdir)
    end

    test 'conversations groups messages by an unordered from/to pair' do
      @store.record(from: '+15551234567', to: '+15559876543', text: 'hi', direction: 'outbound')
      @store.record(from: '+15551234567', to: '+15559876543', text: 'again', direction: 'outbound')
      @store.record(from: '+15550001111', to: '+15552223333', text: 'other thread', direction: 'outbound')

      assert_equal 2, @store.conversations.size
    end

    test 'conversations are ordered most-recent-first' do
      @store.record(from: 'a', to: 'b', text: 'older', direction: 'outbound', sent_at: 1.hour.ago)
      @store.record(from: 'c', to: 'd', text: 'newer', direction: 'outbound', sent_at: Time.current)

      newest_first = @store.conversations.map { |conversation| conversation.messages.first.text }
      assert_equal %w[newer older], newest_first
    end

    test 'messages within a conversation are ordered most-recent-first' do
      @store.record(from: 'a', to: 'b', text: 'first', direction: 'outbound', sent_at: 2.minutes.ago)
      @store.record(from: 'a', to: 'b', text: 'second', direction: 'outbound', sent_at: 1.minute.ago)

      assert_equal %w[second first], @store.conversations.first.messages.map(&:text)
    end

    test 'record is safe under concurrent writes' do
      threads = Array.new(20) do |i|
        Thread.new { @store.record(from: 'a', to: 'b', text: "message #{i}", direction: 'outbound') }
      end
      threads.each(&:join)

      recorded = @store.conversations.first.messages
      assert_equal 20, recorded.size
      assert_equal 20, recorded.map(&:id).uniq.size
    end

    test 'a message recorded by one Store instance is visible to another pointed at the same directory' do
      directory = Dir.mktmpdir
      writer = Store.new(directory: directory)
      reader = Store.new(directory: directory)

      writer.record(from: 'a', to: 'b', text: 'hi', direction: 'outbound')

      assert_equal 1, reader.conversations.size
    end
  end
end
