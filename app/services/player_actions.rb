class PlayerActions
  def self.broadcast_move(world_id, player, new_position)
    ActionCable.server.broadcast(
      "multiplayer_#{world_id}",
      {
        type: "player_move", # Use a type to identify the event
        player_id: player.id,
        username: player.username,
        new_position: new_position
      }
    )
  end
end
