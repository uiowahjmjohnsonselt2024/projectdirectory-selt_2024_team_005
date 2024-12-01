import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = ["slot", "popover", "hoverPopover"];

    connect() {
        console.log("Inventory grid controller connected!");
        this.selectedSlot = null;
        this.selectedPopover = null;

        // Add event listener for click-off to close the popover
        document.addEventListener("click", this.clickOff.bind(this));
    }

    disconnect() {
        // Remove the event listener when the controller is disconnected
        document.removeEventListener("click", this.clickOff.bind(this));
    }

    select(event) {
        const clickedSlot = event.currentTarget;
        const isEmptySlot = clickedSlot.classList.contains('empty-slot');

        // If the slot is empty, do not show a popover
        if (isEmptySlot) return;

        // Hide the hover popover when an item is clicked
        const hoverPopover = clickedSlot.querySelector('.hover-popover');
        if (hoverPopover) {
            hoverPopover.style.display = 'none'; // Hide the hover popover
        }

        // Remove highlight from previously selected slot
        if (this.selectedSlot) {
            this.selectedSlot.classList.remove("selected");
        }

        // Highlight the clicked slot
        clickedSlot.classList.add("selected");

        // Set the selected slot
        this.selectedSlot = clickedSlot;

        // Show the detailed popover (for the clicked item)
        this.showPopover(clickedSlot);
    }

    hover(event) {
        const hoveredSlot = event.currentTarget;
        const isEmptySlot = hoveredSlot.classList.contains('empty-slot');

        // If the slot is empty, do not show a hover popover
        if (isEmptySlot) return;

        // Show the hover popover (preview)
        const hoverPopover = hoveredSlot.querySelector('.hover-popover');
        if (hoverPopover) {
            hoverPopover.style.display = 'block'; // Show hover popover
        }
    }

    leave(event) {
        const hoveredSlot = event.currentTarget;

        // Hide the hover popover when the mouse leaves the slot
        const hoverPopover = hoveredSlot.querySelector('.hover-popover');
        if (hoverPopover) {
            hoverPopover.style.display = 'none'; // Hide hover popover
        }
    }

    showPopover(slot) {
        // Get the popover element associated with this slot
        const popover = slot.querySelector('.popover-menu');

        if (this.selectedPopover) {
            this.selectedPopover.style.display = 'none'; // Hide previous popover
        }

        if (popover) {
            popover.style.display = 'block'; // Show this popover
            this.selectedPopover = popover; // Set it as the selected popover
        }
    }

    // Method to close the popover if clicked outside of the grid
    clickOff(event) {
        // Check if the clicked element is outside the inventory grid
        if (!this.element.contains(event.target)) {
            // Hide the popover if clicked outside
            if (this.selectedPopover) {
                this.selectedPopover.style.display = 'none';
                this.selectedPopover = null;
            }

            // Remove the highlight from the selected slot if clicked outside
            if (this.selectedSlot) {
                this.selectedSlot.classList.remove("selected");
                this.selectedSlot = null;
            }
        }
    }

    // Add a method to handle mouseleave for the selected popover
    hidePopoverOnMouseLeave(event) {
        const clickedSlot = event.currentTarget;

        // Hide the popover menu when the mouse leaves the clicked item
        const popover = clickedSlot.querySelector('.popover-menu');
        if (popover) {
            popover.style.display = 'none'; // Hide the popover when mouse leaves the item
            this.selectedPopover = null; // Reset selectedPopover to allow new selection
        }

        // Remove the highlight when mouse leaves the selected item
        clickedSlot.classList.remove("selected");
        this.selectedSlot = null; // Reset the selected slot
    }
}
