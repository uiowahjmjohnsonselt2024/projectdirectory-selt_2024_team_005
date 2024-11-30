class Character < ApplicationRecord
  belongs_to :user, foreign_key: :username, primary_key: :username
  belongs_to :grid, foreign_key: :grid_id, primary_key: :grid_id
  belongs_to :cell, foreign_key: :cell_id, primary_key: :cell_id
  belongs_to :inventory, foreign_key: :inv_id, primary_key: :inv_id

  validates :username, presence: true
  validates :level, presence: true, numericality: { greater_than_or_equal_to: 1 }

  before_save :set_hp_and_exp, if: :level_changed?
  before_save :set_default_equipment, if: :new_record?

  private

  def set_default_equipment
    self.weapon_item_id ||= Item.find_by(itemable_type: "Weapon", itemable_id: 1).id
    self.armor_item_id ||= Item.find_by(itemable_type: "Armor", itemable_id: 1).id
  end

  def set_hp_and_exp
    self.max_hp = calculate_max_hp(level)
    self.exp_to_level = calculate_exp_to_level(level)

    if level_changed?
      self.current_hp = max_hp
      self.current_exp = 0
    end
  end

  def calculate_max_hp(level)
    200 + (level - 1) * 110
  end

  def calculate_exp_to_level(level)
    1180 * level
  end
end
