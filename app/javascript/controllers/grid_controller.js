// app/javascript/controllers/grid_controller.js
import { Controller } from "@hotwired/stimulus";
import consumer from "channels/consumer";

export default class extends Controller {
    static targets = ["details", "character"];

    connect() {
        const gridSize = parseInt(this.element.dataset.gridSize, 10);
        this.gridSize = gridSize;
        this.isOnlineMode = false; // Default: Offline

        // Get current character by character-id
        const currentCharacterName = document.body.dataset.currentCharacterName;
        this.currentCharacter = document.querySelector(`.character[data-character-id='${currentCharacterName}']`);
        if (!this.currentCharacter) {
            console.error("Current character not found for movement!");
        } else {
            console.log("Current character found:", this.currentCharacter);
        }

        // Listen to the button event
        const onlineModeButton = document.getElementById("online-mode-toggle");
        if (onlineModeButton) {
            onlineModeButton.addEventListener("click", () => this.toggleOnlineMode());
        }

        this.isMonsterPromptActive = false; // Initialize the flag

        // Remove previous event listener
        document.removeEventListener("keydown", this.moveCharacterBound);
        this.moveCharacterBound = this.moveCharacter.bind(this);
        document.addEventListener("keydown", this.moveCharacterBound);
    }

    disconnect() {
        // Remove the keydown event listener when the controller is disconnected
        if (this.multiplayerChannel) {
            const currentCellId = this.currentCharacter.closest(".grid-cell").dataset.cellId;
            this.multiplayerChannel.perform("update_position", { cell_id: currentCellId });

            this.multiplayerChannel.unsubscribe();
        }

        document.removeEventListener("keydown", this.moveCharacterBound);
    }

    toggleOnlineMode() {
        // Check character's position before switching isOnlineMode
        if (!this.isOnlineMode) {
            if (!this.currentCharacter) {
                alert("Your character is not currently in this grid. You cannot enable online mode.");
                return;
            }
            const currentCell = this.currentCharacter.closest(".grid-cell");
            if (!currentCell) {
                alert("Your character is not currently in a cell on this grid. You cannot enable online mode.");
                return;
            }
        }
        this.isOnlineMode = !this.isOnlineMode;

        if (this.isOnlineMode) {
            this.enableOnlineMode();
        } else {
            this.disableOnlineMode();
        }
    }

    enableOnlineMode() {
        const gridId = document.body.dataset.roomId;
        if (!gridId) return;

        this.multiplayerChannel = consumer.subscriptions.create(
            { channel: "MultiplayerChannel", grid_id: gridId },
            {
                received: (data) => {
                    if (data.type === "grid_state") {
                        console.log("Grid state received:", data.players);
                        // Add characters from the server
                        data.players.forEach(player => this.addCharacterToGrid(player));
                        // Ensure the current character is correctly added to the grid
                        this.currentCharacter = document.querySelector(
                            `.character[data-character-id='${document.body.dataset.currentCharacterName}']`
                        );
                        if (!this.currentCharacter) {
                            console.error("Current character not found after grid_state update!");
                        }
                    } else if (data.type === "player_joined") {
                        console.log("Player joined:", data.character);
                        const exists = document.querySelector(`.character[data-character-id='${data.character.character_name}']`);
                        if (!exists) {
                            this.addCharacterToGrid(data.character);
                        } else {
                            console.log(`Player ${data.character.character_name} already in grid, skipping add.`);
                        }
                    } else if (data.type === "update_position") {
                        console.log("Player moved:", data.character);
                        this.moveOtherCharacter(data.character.character_name, data.character.cell_id);
                    } else if (data.type === "player_left") {
                        console.log("Player left:", data.character);
                        this.removeCharacterFromGrid(data.character.character_name);
                    }
                },
            }
        );

        console.log("Online mode enabled");
        document.getElementById("online-mode-toggle").textContent = "Disable Online Mode";
    }

    disableOnlineMode() {
        if (this.multiplayerChannel) {
            const currentCellId = this.currentCharacter.closest(".grid-cell").dataset.cellId;
            this.multiplayerChannel.perform("update_position", { cell_id: currentCellId });

            this.multiplayerChannel.unsubscribe();
            this.multiplayerChannel = null;
        }

        // Remove all other players' characters
        document.querySelectorAll(".character[data-character-id]").forEach(el => {
            if (el.dataset.characterId !== document.body.dataset.currentCharacterName) {
                el.remove();
            }
        });
        console.log("Online mode disabled");
        document.getElementById("online-mode-toggle").textContent = "Enable Online Mode";
    }

    // Add the showDetails method
    showDetails(event) {
        // Get the cell element that is clicked
        const cell = event.currentTarget;
        const cellId = cell.getAttribute("data-cell-id");
        console.log(`Cell ${cellId} clicked`);

        // Use AJAX requests to fetch cell details
        fetch(`/cells/${cellId}`)
            .then(response => response.json())
            .then(data => {
                this.detailsTarget.innerHTML = `
          <p><strong>Weather:</strong> ${data.weather}</p>
          <p><strong>Terrain:</strong> ${data.terrain}</p>
        `;

                // Call the "highlightSelectedCell" method to highlight the selected cell
                this.highlightSelectedCell(cell);
            })
            .catch((error) => console.error("Error fetching cell details:", error));
    }

    highlightSelectedCell(selectedCell) {
        // Remove the style of the previously selected cell
        const previouslySelected = document.querySelector(".grid-cell.selected");
        if (previouslySelected) {
            previouslySelected.classList.remove("selected");
        }

        // Add a style to the currently selected cell
        selectedCell.classList.add("selected");
    }

    moveCharacter(event) {
        if (!this.currentCharacter) {
            console.error("Current character not found for movement!");
            return;
        }
        // Prevent movement if monster prompt is active or character is dead
        const characterElement = this.currentCharacter;

        if (!characterElement) return;

        const characterHp = parseInt(characterElement.getAttribute('data-character-hp'), 10);
        if (this.isMonsterPromptActive || characterHp <= 0) {
            return;
        }

        const currentCell = characterElement.closest(".grid-cell");
        const currentCellId = parseInt(currentCell.getAttribute("data-cell-id"));

        let gridId = Math.floor(currentCellId / 10000);
        let remainder = currentCellId % 10000;
        let row = Math.floor(remainder / 100);
        let col = remainder % 100;

        // Calculate new row and col
        const gridSize = this.gridSize;

        switch (event.key) {
            case "ArrowUp":
                if (row > 0) row -= 1;
                break;
            case "ArrowDown":
                if (row < gridSize - 1) row += 1;
                break;
            case "ArrowLeft":
                if (col > 0) col -= 1;
                break;
            case "ArrowRight":
                if (col < gridSize - 1) col += 1;
                break;
            default:
                return;
        }

        const newCellId = gridId * 10000 + row * 100 + col;
        const newCell = document.querySelector(`[data-cell-id='${newCellId}']`);

        // Check
        if (newCellId === currentCellId) {
            console.log("No movement: character at boundary");
            return;
        }

        if (newCell) {
            newCell.appendChild(characterElement);
            // Removed the disaster check from here, so we don't immediately trigger it.
            // This line was previously: this.checkForDisaster(newCellId);
            this.updateCharacterPosition(characterElement.getAttribute("data-character-id"), newCellId);

            // Broadcast the player's new location if under multiplayer mode
            if (this.isOnlineMode && this.multiplayerChannel) {
                this.multiplayerChannel.perform("update_position", { cell_id: newCellId });
            }
        }
    }

    addCharacterToGrid(character) {
        const { character_name, cell_id } = character;
        if (!character_name || !cell_id) {
            console.warn("Invalid character data:", character);
            return;
        }

        // Avoid adding duplicate characters
        const existingCharacter = document.querySelector(`.character[data-character-id='${character_name}']`);
        if (existingCharacter) {
            console.warn(`Character ${character_name} already exists in the grid.`);
            // If already exists, remove the old role before adding a new one
            existingCharacter.remove();
            // return;
        }

        const cell = document.querySelector(`[data-cell-id='${cell_id}']`);
        if (cell) {
            const characterDiv = document.createElement("div");
            characterDiv.className = "character";
            characterDiv.dataset.characterId = character_name;
            characterDiv.textContent = character_name;
            cell.appendChild(characterDiv);
        }
    }

    moveOtherCharacter(character_name, newCellId) {
        if (character_name === document.body.dataset.currentCharacterName) {
            console.warn("Attempted to move current user's character");
            return;
        }

        const characterElement = document.querySelector(`.character[data-character-id='${character_name}']`);
        const targetCell = document.querySelector(`[data-cell-id='${newCellId}']`);
        if (!characterElement) {
            console.warn(`Character ${character_name} not found`);
            return;
        }

        if (!targetCell) {
            console.warn(`Target cell ${newCellId} not found`);
            return;
        }
        // Remove the character's original location and then move to the new location
        characterElement.parentElement?.removeChild(characterElement);
        targetCell.appendChild(characterElement);
    }

    removeCharacterFromGrid(character_name) {
        const character = document.querySelector(`.character[data-character-id='${character_name}']`);
        if (character) {
            character.remove();
        }
    }

    updateCharacterPosition(characterName, newCellId) {
        const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");

        fetch(`/characters/${characterName}`, {
            method: "PATCH",
            headers: {
                "Content-Type": "application/json",
                Accept: "application/json",
                "X-CSRF-Token": csrfToken,
            },
            body: JSON.stringify({ character: { cell_id: newCellId } }),
        })
            .then((response) => {
                if (!response.ok) {
                    throw new Error("Network response was not ok");
                }
                return response.json();
            })
            .then((data) => {
                console.log("Character position updated successfully", data);
                if (data.monster) {
                    // Monster encountered: show monster prompt first and do NOT check for disaster now.
                    this.showMonsterPrompt(data.monster);
                    this.checkForDisaster(newCellId)
                }
                else {
                    // No monster encountered: now we can safely check for a disaster.
                    this.checkForDisaster(newCellId);
                    // window.location.reload();
                }
            })
            .catch((error) => {
                console.error("Error updating character position:", error);
            });
    }

    checkForDisaster(newCellId) {
        const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");

        fetch(`/cells/${newCellId}`, {
            method: "PATCH",
            headers: {
                "Content-Type": "application/json",
                "Accept": "application/json",
                "X-CSRF-Token": csrfToken
            }
        })
            .then(response => {
                if (!response.ok) {
                    throw new Error("Network response was not ok");
                }
                return response.json();
            })
            .then(data => {
                console.log("Response data:", data);
                if (data.disaster_message) {
                    // Show disaster prompt with the disaster message, damage, and current HP
                    this.showDisasterPrompt(data.disaster_message, 15, data.current_hp);
                } else {
                    console.warn("No disaster message found in response.");
                }
            })
            .catch(error => {
                console.error("Error checking for disaster:", error);
            });
    }

    showDisasterPrompt(disasterMessage, damage, currentHP) {
        // Set the flag to true to prevent character movement during the disaster prompt
        //this.isDisasterPromptActive = true;

        // Create the disaster prompt modal
        const disasterPrompt = document.createElement("div");
        disasterPrompt.classList.add("disaster-prompt");

        disasterPrompt.innerHTML = `
            <div class="disaster-popup">
                <h2>Disaster Strikes!</h2>
                <p><strong>${disasterMessage}</strong></p>
                <p><strong>Damage Taken:</strong> ${damage} HP</p>
                <p><strong>Better luck next time!</strong></p>
                <button id="acknowledge-button">Accept</button>
                <div id="disaster-error-message" style="color: red;"></div>
            </div>
        `;

        // Append the disaster prompt to the body
        document.body.appendChild(disasterPrompt);

        // Add event listener to the Acknowledge button
        document.getElementById("acknowledge-button").addEventListener("click", () => {
            console.log("Disaster acknowledged");

            // Remove the disaster prompt from the page
            document.body.removeChild(disasterPrompt);

            // Reset the disaster prompt flag
           // this.isDisasterPromptActive = false;
           // window.location.reload();
            if (currentHP <= 0) {
                this.displayGameOver();
            } else {
                if (!this.isMonsterPromptActive) {
                    // window.location.reload();
                    this.updateUIAfterDisaster(currentHP);
                }
            }
        });
    }

    updateUIAfterDisaster(currentHP) {
        document.getElementById("character-current-hp").textContent = currentHP;
        // If there are other logics that needs to be reset after actions, it can be dealt with here
        console.log("UI updated after disaster");
    }

    showMonsterPrompt(monster){
        // Set the flag to true to prevent character movement
        this.isMonsterPromptActive = true;

        // Create a modal or prompt to display the monster's stats
        const monsterPrompt = document.createElement("div");
        monsterPrompt.classList.add("monster-prompt");

        monsterPrompt.innerHTML = `
          <div class="monster-popup">
            <h2>A wild monster appears!</h2>
            <p><strong>ATK:</strong> ${monster.atk}</p>
            <p><strong>DEF:</strong> ${monster.def}</p>
            <p><strong>HP:</strong> ${monster.hp}</p>
            <button id="fight-button">Fight</button>
            <button id="bribe-button">Bribe the Monster and Run (10 shards)</button>
            <div id="monster-error-message" style="color: red;"></div>
          </div>
        `;

        document.body.appendChild(monsterPrompt);

        // Add event listeners to the buttons
        document.getElementById("fight-button").addEventListener("click", () => {
            console.log("Fight button clicked");
            this.fightMonster()
                .then((response) => {
                    if (response.status === "ok") {
                        // Start the battle animation with additional data
                        this.startBattleAnimation(
                            response.battle_log,
                            response.outcome,
                            response.exp_gain,
                            response.level_ups,
                            response.current_exp,
                            response.exp_to_level,
                            response.level
                        );
                        // Remove the monster prompt
                        document.body.removeChild(monsterPrompt);
                        // Keep the isMonsterPromptActive flag true during battle
                    } else {
                        // Handle error
                        const errorMessageDiv = document.getElementById("monster-error-message");
                        errorMessageDiv.textContent = response.message;
                        console.error(response.message);
                        // Allow movement again
                        this.isMonsterPromptActive = false;
                    }
                })
                .catch((error) => {
                    // Display error message
                    const errorMessageDiv = document.getElementById("monster-error-message");
                    errorMessageDiv.textContent = error.message;
                    console.error("Error fighting the monster:", error);
                    // Allow movement again
                    this.isMonsterPromptActive = false;
                });
        });


        document.getElementById("bribe-button").addEventListener("click", () => {
            // Handle bribe action
            console.log("Bribe button clicked");
            this.bribeMonster()
                .then((response) => {
                    if (response.status === "ok") {
                        // Bribe successful, remove the monster prompt
                        document.body.removeChild(monsterPrompt);
                        // Reset the flag when the prompt is dismissed
                        this.isMonsterPromptActive = false;
                        // Update shard balance displayed on the page
                        this.updateShardBalance(-10);
                    } else {
                        // Display error message
                        const errorMessageDiv = document.getElementById("monster-error-message");
                        errorMessageDiv.textContent = response.message;
                    }
                })
                .catch((error) => {
                    console.error("Error bribing the monster:", error);
                });
        });
    }

    bribeMonster(){
        const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
        const characterName = document.querySelector(".character").getAttribute("data-character-id");
        return fetch(`/characters/${characterName}/bribe_monster`, {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                Accept: "application/json",
                "X-CSRF-Token": csrfToken,
            },
            body: JSON.stringify({}),
        })
            .then((response) => response.json())
            .catch((error) => {
                console.error("Error bribing the monster:", error);
                throw error;
            });
    }

    updateShardBalance(amountChange) {
        const shardBalanceElement = document.getElementById("shard-balance");
        if (shardBalanceElement) {
            let currentBalance = parseInt(shardBalanceElement.textContent, 10);
            currentBalance += amountChange;
            shardBalanceElement.textContent = currentBalance;
        }
        window.location.reload();
    }
    // app/javascript/controllers/grid_controller.js
    fightMonster() {
        const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
        const characterName = document.querySelector(".character").getAttribute("data-character-id");
        return fetch(`/characters/${characterName}/fight_monster`, {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                "Accept": "application/json",
                "X-CSRF-Token": csrfToken,
            },
            body: JSON.stringify({}),
        })
            .then((response) => {
                if (!response.ok) {
                    // Handle HTTP errors
                    return response.json().then((errorData) => {
                        throw new Error(errorData.message || 'Error fighting the monster');
                    });
                }
                return response.json();
            })
            .catch((error) => {
                console.error("Error fighting the monster:", error);
                throw error;
            });
    }

    startBattleAnimation(battleLog, outcome, expGain, levelUps, currentExp, expToLevel, newLevel) {
        let index = 0;
        const battleInterval = setInterval(() => {
            if (index >= battleLog.length) {
                clearInterval(battleInterval);
                // Battle over
                if (outcome === "win") {
                    console.log("You defeated the monster!");
                    // Update the character's HP on the page
                    document.getElementById("character-current-hp").textContent = Math.max(battleLog[battleLog.length - 1].character_hp, 0);
                    // Display "You defeated the monster!" message
                    this.displayBattleOutcome("You defeated the monster!", expGain, levelUps, newLevel);
                    // Keep the battle stats display for 0.2 seconds before removing it
                    setTimeout(() => {
                        // Remove battle stats display
                        const battleStatsElement = document.getElementById("battle-stats");
                        if (battleStatsElement) {
                            document.body.removeChild(battleStatsElement);
                        }
                        // Update character's EXP and Level on the page
                        document.getElementById("character-current-exp").textContent = currentExp;
                        document.getElementById("character-exp-to-level").textContent = expToLevel;
                        if (levelUps > 0) {
                            document.getElementById("character-level").textContent = newLevel;
                        }
                        // Allow movement again
                        this.isMonsterPromptActive = false;
                    }, 500); // 500 milliseconds
                } else {
                    console.log("You have been defeated!");
                    document.getElementById("character-current-hp").textContent = Math.max(battleLog[battleLog.length - 1].character_hp, 0);
                    // Display GAME OVER banner
                    this.displayGameOver();
                }
                return;
            }

            const currentRound = battleLog[index];
            // Update the battle stats on the page
            this.updateBattleStats(currentRound);
            index++;
        }, 500);
    }

    updateBattleStats(roundData) {
        // Create or update the battle stats display
        let battleStatsElement = document.getElementById("battle-stats");
        if (!battleStatsElement) {
            battleStatsElement = document.createElement("div");
            battleStatsElement.id = "battle-stats";
            battleStatsElement.classList.add("battle-stats");
            document.body.appendChild(battleStatsElement);
        }

        battleStatsElement.innerHTML = `
          <h2>Battle Round ${roundData.round}</h2>
          <p>Your HP: ${Math.max(roundData.character_hp, 0)}</p>
          <p>Monster HP: ${Math.max(roundData.monster_hp, 0)}</p>
          <p>You dealt ${roundData.damage_to_monster} damage.</p>
          <p>Monster dealt ${roundData.damage_to_character} damage.</p>
        `;

        // Update character's current HP data attribute
        const characterElement = document.querySelector('.character');
        if (characterElement) {
            characterElement.setAttribute('data-character-hp', roundData.character_hp);
        }

        // Update the HP displayed on the page
        document.getElementById("character-current-hp").textContent = Math.max(roundData.character_hp, 0);
    }

    displayBattleOutcome(message, expGain, levelUps, newLevel) {
        let battleStatsElement = document.getElementById("battle-stats");
        if (battleStatsElement) {
            battleStatsElement.innerHTML = `
      <h2>${message}</h2>
      <p>You gained ${expGain} EXP!</p>
      ${levelUps > 0 ? `<p>You leveled up! New level: ${newLevel}</p>` : ''}
    `;
        }
    }

    displayGameOver() {
        // Remove battle stats
        const battleStatsElement = document.getElementById("battle-stats");
        if (battleStatsElement) {
            document.body.removeChild(battleStatsElement);
        }

        // Display GAME OVER banner
        const gameOverBanner = document.createElement("div");
        gameOverBanner.id = "game-over-banner";
        gameOverBanner.innerHTML = `
          <h1>GAME OVER</h1>
        `;
        document.body.appendChild(gameOverBanner);

        // Prevent further movement
        this.isMonsterPromptActive = true;
    }
}

