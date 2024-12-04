// app/javascript/controllers/grid_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = ["details", "character"];

    connect() {
        const gridSize = parseInt(this.element.dataset.gridSize, 10);
        this.gridSize = gridSize;
        this.isMonsterPromptActive = false; // Initialize the flag
        // Remove previous event listener
        document.removeEventListener("keydown", this.moveCharacterBound);
        this.moveCharacterBound = this.moveCharacter.bind(this);
        document.addEventListener("keydown", this.moveCharacterBound);
    }

    disconnect() {
        document.removeEventListener("keydown", this.moveCharacterBound);
    }

    moveCharacter(event) {
        // Prevent movement if monster prompt is active
        if (this.isMonsterPromptActive) {
            return;
        }

        const characterElement = document.querySelector(`.character`);
        if (!characterElement) return;

        const currentCell = characterElement.closest(".grid-cell");
        const currentCellId = parseInt(currentCell.getAttribute("data-cell-id"));

        // Obtain grid_id, row, and col
        const gridId = Math.floor(currentCellId / 10000);
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

        // Calculate new cell_id
        const newCellId = gridId * 10000 + row * 100 + col;

        // Find the new cell
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
                    // Display the monster encounter prompt
                    this.showMonsterPrompt(data.monster);
                }
            })
            .catch((error) => {
                console.error("Error updating character position:", error);
            });
    }

    showMonsterPrompt(monster) {
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
        <button id="fight-button">Fight</button>
        <button id="bribe-button">Bribe the Monster and Run (10 shards)</button>
        <div id="monster-error-message" style="color: red;"></div>
      </div>
    `;

        document.body.appendChild(monsterPrompt);

        // Add event listeners to the buttons
        document.getElementById("fight-button").addEventListener("click", () => {
            // Handle fight action (to be implemented later)
            console.log("Fight button clicked");
            document.body.removeChild(monsterPrompt);
            // Reset the flag when the prompt is dismissed
            this.isMonsterPromptActive = false;
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

    bribeMonster() {
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
    }
}
