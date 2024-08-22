document.getElementById('contactForm').addEventListener('submit', function(event) {
  event.preventDefault();

  var name = document.getElementById('name').value;
  var email = document.getElementById('email').value;

  var message = `Olá, meu nome é ${name}. Gostaria de obter mais detalhes sobre o funcionamento do produto. Meu e-mail de contato é ${email}`;
  var whatsappUrl = `https://api.whatsapp.com/send?phone=+554499707380&text=${encodeURIComponent(message)}`;

  window.open(whatsappUrl, '_blank');
});
