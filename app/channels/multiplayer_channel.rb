class MultiplayerChannel < ApplicationCable::Channel
  def subscribed
    character = current_user.character
    character.update!(online_status: true)

    stream_from "multiplayer_grid_#{character.grid_id}"

    # Transmit the status of all players in the current grid
    online_players = Character.where(grid_id: character.grid_id, online_status: true).pluck(:character_name, :cell_id)
    transmit({ type: "grid_state", players: online_players })

    # Notify other players that a new player has joined
    ActionCable.server.broadcast("multiplayer_grid_#{character.grid_id}", {
      type: "player_joined",
      character: {
        character_name: character.character_name,
        cell_id: character.cell_id
      }
    })
  end

  def unsubscribed
    character = current_user.character
    character.update!(online_status: false)

    ActionCable.server.broadcast("multiplayer_grid_#{character.grid_id}", {
      type: "player_left",
      username: character.character_name
    })
  end

  def update_position(data)
    character = current_user.character

    character.update!(cell_id: data["cell_id"])

    # Broadcast the player's new location
    ActionCable.server.broadcast("multiplayer_grid_#{character.grid_id}", {
      type: "update_position",
      character: {
        character_name: character.character_name,
        cell_id: character.cell_id
      }
    })
  end
end
