import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = ["details", "character"];

    connect() {
        const gridSize = parseInt(this.element.dataset.gridSize, 10);
        console.log("Grid size:", gridSize);
        this.gridSize = gridSize;
        console.log("Grid Controller Connected");

        // Remove previous event listener
        document.removeEventListener("keydown", this.moveCharacterBound);
        this.moveCharacterBound = this.moveCharacter.bind(this);
        document.addEventListener("keydown", this.moveCharacterBound);
    }

    disconnect() {
        // Remove the keydown event listener when the controller is disconnected
        document.removeEventListener("keydown", this.moveCharacterBound);
    }

    showDetails(event) {
        const cell = event.currentTarget;
        const cellId = cell.getAttribute("data-cell-id");
        console.log(`Cell ${cellId} clicked`);

        // Use AJAX requests to fetch cell details
        fetch(`/cells/${cellId}`)
            .then(response => response.json())
            .then(data => {
                this.detailsTarget.innerHTML = `
          <p><strong>Cell Location:</strong> ${data.cell_loc}</p>
          <p><strong>Monster Probability:</strong> ${data.mons_prob}</p>
          <p><strong>Disaster Probability:</strong> ${data.disaster_prob}</p>
          <p><strong>Weather:</strong> ${data.weather}</p>
          <p><strong>Terrain:</strong> ${data.terrain}</p>
          <p><strong>Has Store:</strong> ${data.has_store ? 'Yes' : 'No'}</p>
        `;

                this.highlightSelectedCell(cell);
            })
            .catch(error => console.error('Error fetching cell details:', error));
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
            console.log("Entering checkForDisaster with newCellId:", newCellId);
            newCell.appendChild(characterElement);
            // Trigger disaster check after the character moves to the new cell
            this.checkForDisaster(newCellId);
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
                "X-CSRF-Token": csrfToken
            },
            body: JSON.stringify({ character: { cell_id: newCellId } })
        })
            .then(response => {
                if (!response.ok) {
                    throw new Error("Network response was not ok");
                }
                return response.json();
            })
            .then(data => {
                console.log("Character position updated successfully", data);
            })
            .catch(error => {
                console.error("Error updating character position:", error);
            });
    }

    checkForDisaster(newCellId) {
        const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");

        // Fetch disaster status after the character moves
        fetch(`/cells/${newCellId}`, { // URL to match the Rails update action in cells_controller
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
                console.log("Response data:", data); // Log the entire response data
                if (data.disaster_message) {
                    // Show disaster prompt with the disaster message, damage, and current HP
                    this.showDisasterPrompt(data.disaster_message, 20, data.current_hp);
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

        // Create the disaster prompt modal
        const disasterPrompt = document.createElement("div");
        disasterPrompt.classList.add("disaster-prompt");

        disasterPrompt.innerHTML = `
    <div class="disaster-popup">
        <h2>Disaster Strikes!</h2>
        <p><strong> ${disasterMessage}</strong></p>
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
            this.isDisasterPromptActive = false;
            window.location.reload();  // This will reload the current page
        });
    }


}
