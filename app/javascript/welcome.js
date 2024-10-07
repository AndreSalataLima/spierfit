// app/assets/javascripts/welcome.js

document.addEventListener('turbo:load', function() {
  // Inicialize o Slick Slider na classe correta
  $('.global-carousel').slick({
    fade: true,
    slidesToShow: 1,
    arrows: true,
    prevArrow: '<button class="slick-arrow slick-prev">PREV</button>',
    nextArrow: '<button class="slick-arrow slick-next">NEXT</button>',
    // Adicione outras configurações necessárias
  });

  // Inicialize o Magnific Popup
  $('.popup-image').magnificPopup({
    type: 'image',
    // Outras configurações
  });

  // Inicialize o Counter Up
  $('.counter-number').counterUp({
    delay: 10,
    time: 1000
  });

  // Qualquer outro código personalizado
});
