// app/javascript/application.js
import { Turbo } from "@hotwired/turbo-rails";

// Importa a aplicação Stimulus configurada no arquivo application.js dos controllers
// import { application } from "./controllers/application";

// Importações adicionais para funcionalidade
import "channels";             // Importa os canais ActionCable
import "chartkick";            // Para uso com Chart.js
import "Chart.bundle";         // Importa Chart.js


// Adiciona a linha abaixo para importar todos os controladores automaticamente
import "controllers";

import { application } from "./controllers/application";

// import ChartController from "./controllers/chart_controller";
// import WeightController from "./controllers/weight_controller";

// Registra os controladores no objeto de aplicação do Stimulus
// application.register("chart", ChartController);
// application.register("weight", WeightController);

Turbo.start();
