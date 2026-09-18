# frozen_string_literal: true

require 'fileutils'
require 'securerandom'
require 'json'

module SmsTrap
  # Filesystem-backed store of every message SmsTrap has intercepted: one JSON file per
  # message under a shared directory. Because every process using {SmsTrap.store} points at
  # the same directory, messages recorded by one process (e.g. one Puma cluster worker) are
  # visible to another (e.g. the worker serving the viewer UI) without any in-process
  # coordination.
  class Store
    # @param directory [String, Pathname] where message files are read from and written to;
    #   defaults to a directory under the host app's tmp/
    def initialize(directory: self.class.default_directory)
      @directory = directory.to_s
      FileUtils.mkdir_p(@directory)
    end

    # @return [Pathname] the default storage directory, under the host app's tmp/
    def self.default_directory
      Rails.root.join('tmp/sms_trap')
    end

    # Records a single message.
    #
    # @param from [String] the sending phone number
    # @param to [String] the receiving phone number
    # @param text [String] the message body
    # @param direction [String] "outbound" or "inbound"
    # @param sent_at [Time] when the message was sent; defaults to now
    # @return [Message] the recorded message, with its assigned id
    def record(from:, to:, text:, direction:, sent_at: Time.zone.now)
      message = Message.new(generate_id, from, to, text, direction, sent_at)
      write(message)
      message
    end

    # @return [Array<Conversation>] every conversation recorded so far, most-recently-active first
    def conversations
      messages_snapshot
        .group_by { |message| Conversation.key_for(message.from, message.to) }
        .values
        .map { |messages| Conversation.new(messages) }
        .sort_by { |conversation| conversation.messages.first.sent_at }
        .reverse
    end

    # Discards every recorded message.
    #
    # @return [void]
    def clear
      FileUtils.rm_rf(@directory)
      FileUtils.mkdir_p(@directory)
    end

    private

    # Writes a message to its own file. A new file is always created, never an existing one
    # modified, so concurrent writers never contend for the same path. The rename is atomic,
    # so a reader glob-ing the directory never sees a partially written file.
    def write(message)
      path = message_path(message.id)
      tmp_path = "#{path}.tmp-#{Process.pid}-#{Thread.current.object_id}"
      File.write(tmp_path, serialize(message))
      File.rename(tmp_path, path)
    end

    def messages_snapshot
      Dir.glob(File.join(@directory, '*.json')).filter_map { |path| deserialize(File.read(path)) }
    end

    def message_path(id)
      File.join(@directory, "#{id}.json")
    end

    def generate_id
      "#{Time.current.strftime('%Y%m%d%H%M%S%6N')}-#{SecureRandom.hex(4)}"
    end

    def serialize(message)
      JSON.generate(message.to_h.merge(sent_at: message.sent_at.iso8601))
    end

    def deserialize(json)
      data = JSON.parse(json, symbolize_names: true)
      Message.new(data[:id], data[:from], data[:to], data[:text], data[:direction], Time.zone.parse(data[:sent_at]))
    end
  end
end
