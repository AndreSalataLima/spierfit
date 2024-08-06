document.addEventListener("turbo:load", function () {
  const startCameraButton = document.getElementById("start-camera");
  const reader = document.getElementById("reader");

  console.log("turbo:load event triggered");

  if (startCameraButton && reader) {
    console.log("Camera button and reader elements found");

    startCameraButton.addEventListener("click", function () {
      console.log("Start camera button clicked");

      const script = document.createElement("script");
      script.src = "https://cdn.jsdelivr.net/npm/html5-qrcode/minified/html5-qrcode.min.js";
      script.onload = function () {
        console.log("QR code library loaded");

        // Adicionar um pequeno atraso para garantir que a biblioteca está carregada
        setTimeout(() => {
          if (typeof Html5Qrcode !== 'undefined') {
            console.log("Html5Qrcode is defined");

            const html5QrCode = new Html5Qrcode("reader");
            console.log("Html5Qrcode instance created:", html5QrCode);

            html5QrCode.start(
              { facingMode: "environment" },
              {
                fps: 10,
                qrbox: { width: 250, height: 250 }
              },
              (decodedText, decodedResult) => {
                console.log(`Code matched = ${decodedText}`, decodedResult);
                // Construir a URL correta
                const machineId = decodedText.match(/\/machines\/(\d+)\/exercises/)[1];
                Turbo.visit(`/machines/${machineId}/exercises`);
              },
              (errorMessage) => {
                console.log(`QR Code no match. Error: ${errorMessage}`);
              }
            ).catch((err) => {
              console.error("Unable to start scanning", err);
            });
          } else {
            console.error("Html5Qrcode is not defined");
          }
        }, 1000); // Aguardar 1 segundo
      };
      script.onerror = function (error) {
        console.error("Failed to load the QR code library", error);
      };
      document.body.appendChild(script);
    });
  } else {
    console.log("Camera button or reader element not found");
  }
});
