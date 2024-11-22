import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = ["details"];

    connect() {
        console.log("Grid Controller Connected");
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
}