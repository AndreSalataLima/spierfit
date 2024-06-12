// import { Controller } from "@hotwired/stimulus";

// export default class extends Controller {
//   static targets = ["form", "flash"]; // Define targets

//   connect() {
//     // Add event listener to form submission
//     this.formTarget.addEventListener("submit", this.handleSubmit.bind(this));
//   }

//   handleSubmit(event) {
//     event.preventDefault(); // Prevent default form submission

//     // Fetch data from the form using FormData
//     const formData = new FormData(this.formTarget);

//     // Get CSRF token from meta tags
//     const csrfToken = document.querySelector("[name='csrf-token']").content;

//     // Send POST request using fetch API
//     fetch(this.formTarget.action, {
//       method: "POST",
//       body: formData,
//       headers: {
//         "X-CSRF-Token": csrfToken,
//         "Accept": "application/json",
//         "Content-Type": "application/json"
//       },
//     })
//     .then(response => {
//       if(response.ok) {
//         return response.json(); // Parse response as JSON if request succeeded
//       } else {
//         response.json().then(data => {
//           if (data.errors) {
//             throw new Error(data.errors.join(', ')); // Throw an error with all error messages
//           }
//         });
//       }
//     })
//     .then(data => {
//       // Handle successful creation (e.g., update UI, display flash message)
//       console.log("User created successfully:", data);
//       if (this.flashTarget) {
//         this.flashTarget.innerHTML = `<p>User created successfully!</p>`; // Example flash message
//       }

//       // Optionally, redirect or update the page here
//     })
//     .catch(error => {
//       // Handle errors (e.g., display error messages)
//       console.error("Error creating user:", error);
//       if (this.flashTarget) {
//         this.flashTarget.innerHTML = `<p>Error: ${error.message}</p>`; // Display error messages
//       }
//     });
//   }
// }
