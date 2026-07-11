class Permalink < ApplicationRecord
  belongs_to :reference, polymorphic: true
  validates :url_path, presence: true

  validates :url_path, uniqueness: {case_sensitive: false}, if: Proc.new { |permalink| not permalink.host.present? }
  validates :url_path, uniqueness: {case_sensitive: false}, if: Proc.new { |permalink| Permalink.where(host: nil, url_path: permalink.url_path).any? }
  validates :url_path, uniqueness: {case_sensitive: false, scope: :host}

  scope :for_host, -> (host) { where(host: [nil, host]) }

end
