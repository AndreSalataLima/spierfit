function initializeQrCodeScanner() {
  const startCameraButton = document.getElementById("start-camera");
  const reader = document.getElementById("reader");

  function startQrCodeScanner() {
    if (window.html5QrCodeInstance) {
      window.html5QrCodeInstance.clear().then(() => {
        window.html5QrCodeInstance = null;
        createQrCodeInstance();
      }).catch(err => {});
    } else {
      createQrCodeInstance();
    }
  }

  function createQrCodeInstance() {
    const html5QrCode = new Html5Qrcode("reader");
    html5QrCode.start(
      { facingMode: "environment" },
      {
        fps: 10,
        qrbox: { width: 250, height: 250 }
      },
      function onScanSuccess(decodedText, decodedResult) {
        html5QrCode.stop().then(() => {
          window.location.href = decodedText;
        }).catch(err => {});
      },
      function onScanError(errorMessage) {}
    ).catch(err => {});
    window.html5QrCodeInstance = html5QrCode;

    // Verificar se o vídeo está disponível e ajustá-lo
    waitForVideoToLoad();
  }

  function waitForVideoToLoad() {
    const video = document.querySelector('video');
    if (video) {
      if (video.readyState >= 2) { // Verifica se metadados estão disponíveis
        adjustVideoElement(video);
      } else {
        video.addEventListener('loadedmetadata', () => {
          adjustVideoElement(video);
        });
      }
    } else {
      // Caso o vídeo ainda não esteja no DOM, tente novamente após 100 ms
      setTimeout(waitForVideoToLoad, 100);
    }
  }

  function adjustVideoElement(video) {
    video.style.position = 'absolute';
    video.style.top = '50%';
    video.style.left = '50%';
    video.style.transform = 'translate(-50%, -50%)';
    video.style.maxWidth = '100%';
    video.style.height = 'auto';
  }

  if (startCameraButton && reader) {
    startCameraButton.addEventListener("click", function () {
      if (typeof Html5Qrcode !== 'undefined') {
        startQrCodeScanner();
      } else {
        console.error("Html5Qrcode is not defined.");
      }
    });
  }
}

document.addEventListener("turbo:render", initializeQrCodeScanner);
document.addEventListener("turbo:load", initializeQrCodeScanner);
