module Plug
  extend ActiveSupport::Concern
  include EmbedlyService

  included do
    include Mongoid::Document
    include Mongoid::Timestamps

    field :title, type: String
    field :description, type: String
    field :url, type: String
    field :html, type: String
    field :height, type: String
    field :width, type: String

    field :thumbnail_url, type: String
    field :thumbnail_height, type: String
    field :thumbnail_width, type: String

    field :votes, type: Hash, default: -> { Hash.new }
    field :votes_counter, type: Integer, default: 0

    belongs_to :user

    validates_presence_of :user, message: 'Please login to add resources'
    # validates :title, presence: true, on: :create
    # validates :description, presence: true, on: :create
    validates :url, presence: true, uniqueness: true, format: URI::regexp(%w(http https))

    default_scope desc(:votes_counter)

    before_create :fetch_attributes, unless: Proc.new { self.user.nickname == ENV['JIMMY'] }
    before_save :update_votes_count

    embedded_in :repository
  end

  def votes_count
    self.votes.values.sum
  end

  def assign_vote(direction, user)
    if direction == 'up'
      self.votes[user.nickname] = 1
    elsif direction == 'down'
      self.votes[user.nickname] = -1
    end
    self.save
  end

  def update_votes_count
    self.votes_counter = self.votes_count
  end
end
