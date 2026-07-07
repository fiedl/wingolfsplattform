require_dependency YourPlatform::Engine.root.join('app/models/attachment').to_s

class Attachment
  scope :wingolfshaus, -> { where("title ILIKE ?", "%Wingolfshaus%").where(parent_type: 'Group') }
  scope :wappen, -> { where("title ILIKE ?", "%Wappen%") }
end