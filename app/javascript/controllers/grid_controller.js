import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = ["details", "character"];

    connect() {
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
        // Get the cell element that is clicked
        const cell = event.currentTarget;
        const cellId = cell.getAttribute("data-cell-id");
        console.log(`Cell ${cellId} clicked`);

        // Use AJAX requests to fetch cell details
        fetch(`/cells/${cellId}`)
            .then(response => response.json())
            .then(data => {
                // Update the details section on the page
                this.detailsTarget.innerHTML = `
                    <p><strong>Cell Location:</strong> ${data.cell_loc}</p>
                    <p><strong>Monster Probability:</strong> ${data.mons_prob}</p>
                    <p><strong>Disaster Probability:</strong> ${data.disaster_prob}</p>
                    <p><strong>Weather:</strong> ${data.weather}</p>
                    <p><strong>Terrain:</strong> ${data.terrain}</p>
                    <p><strong>Has Store:</strong> ${data.has_store ? 'Yes' : 'No'}</p>
                `;

                // Call the "highlightSelectedCell" method to highlight the selected cell
                this.highlightSelectedCell(cell);
            })
            .catch(error => console.error('Error fetching cell details:', error));
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
        switch (event.key) {
            case "ArrowUp":
                if (row > 0) row -= 1;
                break;
            case "ArrowDown":
                if (row < 5) row += 1;
                break;
            case "ArrowLeft":
                if (col > 0) col -= 1;
                break;
            case "ArrowRight":
                if (col < 5) col += 1;
                break;
            default:
                return;
        }

        // Calculate cell_id
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
                "Accept": "application/json",
                "X-CSRF-Token": csrfToken  // CSRF Token to prevent request being blocked
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
}