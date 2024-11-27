import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = ["slot"];

    connect() {
        console.log("Inventory grid controller connected!");
        this.selectedSlot = null;
    }

    select(event) {
        const clickedSlot = event.currentTarget;

        // Remove highlight from previously selected slot
        if (this.selectedSlot) {
            this.selectedSlot.classList.remove("selected");
        }

        // Highlight the clicked slot
        clickedSlot.classList.add("selected");

        // Set the selected slot
        this.selectedSlot = clickedSlot;

        // Optional: log for debugging
        console.log("Selected slot:", clickedSlot);
    }
}
