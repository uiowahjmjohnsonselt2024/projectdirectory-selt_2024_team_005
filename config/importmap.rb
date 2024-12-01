pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin_all_from "app/javascript/channels", under: "channels"
pin "grid_controller", to: "controllers/grid_controller.js"
<<<<<<< HEAD
pin "lodash", to: "https://cdn.jsdelivr.net/npm/lodash@4.17.21/lodash.min.js"
pin "channels", to: "channels/application.js"
pin_all_from "app/javascript/channels", under: "channels"
pin "@rails/ujs", to: "https://cdn.skypack.dev/@rails/ujs"
pin "stimulus", to: "stimulus.js", preload: true
pin "stimulus-loading", to: "stimulus-loading.js"
pin "@rails/actioncable", to: "actioncable.js"
=======
pin "@rails/actioncable", to: "actioncable.esm.js"
>>>>>>> bd3e9e9115042199b9e47c0ac8507840173daca7
