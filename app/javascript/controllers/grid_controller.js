// app/javascript/controllers/grid_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = ["details"];

    connect() {
        console.log("Grid Controller Connected");
    }

    showDetails(event) {
        // 获取被点击的 cell 元素
        const cell = event.currentTarget;
        const cellId = cell.getAttribute("data-cell-id");
        console.log(`Cell ${cellId} clicked`);

        // 使用 AJAX 请求获取单元格的详细信息
        fetch(`/cells/${cellId}`)
            .then(response => response.json())
            .then(data => {
                // 更新页面右侧的详细信息部分
                this.detailsTarget.innerHTML = `
          <p><strong>Cell Location:</strong> ${data.cell_loc}</p>
          <p><strong>Monster Probability:</strong> ${data.mons_prob}</p>
          <p><strong>Disaster Probability:</strong> ${data.disaster_prob}</p>
          <p><strong>Weather:</strong> ${data.weather}</p>
          <p><strong>Terrain:</strong> ${data.terrain}</p>
          <p><strong>Has Store:</strong> ${data.has_store ? 'Yes' : 'No'}</p>
        `;

                // 调用方法来高亮选中的 cell
                this.highlightSelectedCell(cell);
            })
            .catch(error => console.error('Error fetching cell details:', error));
    }

    highlightSelectedCell(selectedCell) {
        // 移除之前被选中单元格的样式
        const previouslySelected = document.querySelector(".grid-cell.selected");
        if (previouslySelected) {
            previouslySelected.classList.remove("selected");
        }

        // 给当前选中的单元格添加样式
        selectedCell.classList.add("selected");
    }
}