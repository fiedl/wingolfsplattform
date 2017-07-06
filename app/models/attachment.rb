require_dependency YourPlatform::Engine.root.join('app/models/attachment').to_s

class Attachment
  scope :wingolfshaus, -> { where("title LIKE ?", "%Wingolfshaus%") }
  scope :wappen, -> { where("title LIKE ?", "%Wappen%") }
end