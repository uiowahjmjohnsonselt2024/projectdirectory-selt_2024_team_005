class Item < ApplicationRecord
  belongs_to :itemable, polymorphic: true
  delegate :name, :icon, :description, :atk_bonus, :def_bonus, :hp_regen, to: :itemable

  before_save :set_defaults, if: :new_record?
  after_save :update_itemable_attributes

  scope :ordered_by_type_level_rarity, -> {
    order(
      Arel.sql("CASE
                 WHEN itemable_type = 'Weapon' THEN 1
                 WHEN itemable_type = 'Armor' THEN 2
                 WHEN itemable_type = 'Potion' THEN 3
                 ELSE 4
               END"),
      :level,
      :rarity
    )
  }

  RARITY_NAMES = {
    1 => "Common",
    2 => "Uncommon",
    3 => "Rare",
    4 => "Epic",
    5 => "Legendary"
  }.freeze

  RARITY_COLORS = {
    1 => "#ffffff", # White
    2 => "#99ff99", # Green
    3 => "#acebfc", # Blue
    4 => "#e6aae6", # Purple
    5 => "#ff9661"  # Orange
  }.freeze

  def rarity_color
    RARITY_COLORS[rarity] || "Invalid"
  end

  def rarity_name
    RARITY_NAMES[rarity] || "Invalid"
  end

  def category
    itemable_type
  end

  private

  def set_defaults
    self.cost ||= 1
    self.rarity ||= 1
    self.level ||= 1
  end

  def update_itemable_attributes
    case itemable_type
    when "Weapon"
      itemable.update_atk_bonus
    when "Armor"
      itemable.update_def_bonus
    when "Potion"
      itemable.update_hp_regen
    end
  end
end
