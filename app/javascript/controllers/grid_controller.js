// app/javascript/controllers/grid_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = ["details", "character"];

    connect() {
        const gridSize = parseInt(this.element.dataset.gridSize, 10);
        this.gridSize = gridSize;
        this.isMonsterPromptActive = false; // Flag for monster prompt
        this.isDisasterPromptActive = false; // Flag for disaster prompt

        // Remove previous event listener
        document.removeEventListener("keydown", this.moveCharacterBound);
        this.moveCharacterBound = this.moveCharacter.bind(this);
        document.addEventListener("keydown", this.moveCharacterBound);
    }

    disconnect() {
        document.removeEventListener("keydown", this.moveCharacterBound);
    }

    showDetails(event) {
        const cell = event.currentTarget;
        const cellId = cell.getAttribute("data-cell-id");
        console.log(`Cell ${cellId} clicked`);

        fetch(`/cells/${cellId}`)
            .then(response => response.json())
            .then(data => {
                this.detailsTarget.innerHTML = `
                    <p><strong>Weather:</strong> ${data.weather}</p>
                    <p><strong>Terrain:</strong> ${data.terrain}</p>
                `;
                this.highlightSelectedCell(cell);
            })
            .catch((error) => console.error("Error fetching cell details:", error));
    }

    highlightSelectedCell(selectedCell) {
        const previouslySelected = document.querySelector(".grid-cell.selected");
        if (previouslySelected) {
            previouslySelected.classList.remove("selected");
        }
        selectedCell.classList.add("selected");
    }

    moveCharacter(event) {
        const characterElement = document.querySelector(`.character`);
        if (!characterElement) return;

        const characterHp = parseInt(characterElement.getAttribute('data-character-hp'), 10);
        // Prevent movement if either monster or disaster prompt is active or character is dead
        if (this.isMonsterPromptActive || this.isDisasterPromptActive || characterHp <= 0) {
            return;
        }

        const currentCell = characterElement.closest(".grid-cell");
        const currentCellId = parseInt(currentCell.getAttribute("data-cell-id"));

        let gridId = Math.floor(currentCellId / 10000);
        let remainder = currentCellId % 10000;
        let row = Math.floor(remainder / 100);
        let col = remainder % 100;

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

        if (newCell) {
            newCell.appendChild(characterElement);
            this.updateCharacterPosition(characterElement.getAttribute("data-character-id"), newCellId);
        }
    }

    updateCharacterPosition(characterName, newCellId) {
        const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");

        fetch(`/characters/${characterName}`, {
            method: "PATCH",
            headers: {
                "Content-Type": "application/json",
                "Accept": "application/json",
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
                    this.showMonsterPrompt(data.monster);
                    this.checkForDisaster(newCellId)
                } else {
                    this.checkForDisaster(newCellId);
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
        this.isDisasterPromptActive = true;

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

        document.body.appendChild(disasterPrompt);

        document.getElementById("acknowledge-button").addEventListener("click", () => {
            console.log("Disaster acknowledged");
            document.body.removeChild(disasterPrompt);

            // Reset the disaster prompt flag
            this.isDisasterPromptActive = false;

            if (currentHP <= 0) {
                this.displayGameOver();
            } else {
                if (!this.isMonsterPromptActive) {
                    window.location.reload();
                }
            }
        });
    }

    showMonsterPrompt(monster) {
        this.isMonsterPromptActive = true;

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

        document.getElementById("fight-button").addEventListener("click", () => {
            console.log("Fight button clicked");
            this.fightMonster()
                .then((response) => {
                    if (response.status === "ok") {
                        this.startBattleAnimation(
                            response.battle_log,
                            response.outcome,
                            response.exp_gain,
                            response.level_ups,
                            response.current_exp,
                            response.exp_to_level,
                            response.level
                        );
                        document.body.removeChild(monsterPrompt);
                        // Keep isMonsterPromptActive true during the battle if needed until battle ends.
                    } else {
                        const errorMessageDiv = document.getElementById("monster-error-message");
                        errorMessageDiv.textContent = response.message;
                        console.error(response.message);
                        this.isMonsterPromptActive = false;
                    }
                })
                .catch((error) => {
                    const errorMessageDiv = document.getElementById("monster-error-message");
                    errorMessageDiv.textContent = error.message;
                    console.error("Error fighting the monster:", error);
                    this.isMonsterPromptActive = false;
                });
        });

        document.getElementById("bribe-button").addEventListener("click", () => {
            console.log("Bribe button clicked");
            this.bribeMonster()
                .then((response) => {
                    if (response.status === "ok") {
                        document.body.removeChild(monsterPrompt);
                        this.isMonsterPromptActive = false;
                        this.updateShardBalance(-10);
                    } else {
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

