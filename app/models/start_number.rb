class StartNumber < ApplicationRecord
  has_many :race_results
  belongs_to :pool, optional: true
  before_save :strip_tag_id

  private

  def strip_tag_id
    self.tag_id = tag_id.strip if self.tag_id.present?
    self.alternate_tag_id = alternate_tag_id.strip if self.alternate_tag_id.present?
  end
end
